%% ========================================================================
%  claude_R1.m  —  DYNAMIC THERMOELASTIC ANALYSIS (LORD-SHULMAN / FOURIER)
%  Multilayer porous GPL-reinforced cylinder, layerwise DQM + Newmark (beta)
%  (revision R1 of the corrected solver; companions: Static_Baseline_R1.m,
%   Compare_R1.m)
%  ------------------------------------------------------------------------
%  REWRITTEN from scratch on top of the VALIDATED static assembly (Main-EN.m),
%  fixing the fatal problems of Main_Dyn .. Main_Dyn_R4:
%
%   FIX 1 (Newmark): displacement-form Newmark implemented correctly
%          (solve for x_{n+1}, THEN update acceleration), exactly like the
%          working reference M/Equation_Termo_Elastic_chand_layer_model_1.m.
%          R4 solved the displacement-form system but used the result as
%          acceleration -> response frozen at ~beta*dt^2 of the true value.
%
%   FIX 2 (signs): consistent convention  M*x'' + C*x' + K*x = F  with
%          K = -(spatial PDE operator in natural form). R4 kept the natural
%          sign of K with positive M,C -> anti-diffusion + negative stiffness.
%
%   FIX 3 (no fake volumes): DQM is point collocation. Mass/damping entries
%          are just rho, rho*c (NO Veff=2*pi*r*dr*dz), pressure RHS is just
%          -P_i (stress units, no area factor).
%
%   FIX 4 (boundary rows): BC/interface rows are pure algebraic constraints
%          (their M and C rows are zero; in displacement-form Newmark this
%          enforces the constraint exactly every step). Thermal Dirichlet is
%          applied ONLY at the true inner surface (layer 1), NOT at every
%          layer interface. No stale-iz bugs. Traction BCs include the
%          thermal stress term. LS coupling includes the T0 factor.
%
%  Unknown vector x = [theta ; u ; w],  theta = T - T_ref  (so x(0) = 0).
%
%  Physical scenario (confirmed with author):
%    inner surface r=Ri : prescribed temperature ramp
%                         theta_in(t) = (T_in_val - T_ref)*(1 - exp(-t/t0))
%                         + internal pressure P_i applied for t > 0
%    outer surface r=Ro : convection  -k dT/dr = h_c (T - T_inf)
%    ends z=0, z=L      : thermally insulated; mechanical support S / F / C
%  ========================================================================
clearvars -except cfg; clc; close all;

%% ========================= 0. Model configuration =========================
LS_enabled = true;          % true: Lord-Shulman (tau0 > 0), false: Fourier
tau0       = 1e-5;          % relaxation time (s)  (used only if LS_enabled)
coupling_on = true;         % thermoelastic coupling term in the energy eq.

% Mechanical support at z = 0 and z = L :  'S' simply, 'F' free, 'C' clamped
BC_z = 'S';

% GPL and porosity patterns.
% NOTE: only 'UD' is fully confirmed against the spec (MZ-R 0.docx evaluates
% patterns at layer mid-radius -> piecewise-constant properties). The other
% patterns are implemented from the docx formulas but must be verified
% against the reference paper before production runs.
GPL_pattern      = 'UD';    % 'UD','O','X','V','A'
porosity_on      = true;
porosity_pattern = 'UD';    % 'UD','O','X','V','A'
W_GPL_total = 0.04;         % total GPL mass fraction
e3   = 0.8064;              % UD porosity coefficient (docx table)
e1   = 0.3;   e2 = 0.5103;  e4 = 0.7813;  e5 = 0.7813;   % matched-mass set (docx)

%% ========================= 1. Geometry and discretization =========================
NL  = 5;                    % number of layers
R_i = 0.1;                  % inner radius (m)
R_o = 0.2;                  % outer radius (m)
L   = 0.5;                  % cylinder length (m)
N_r = 9;                    % radial DQ points per layer
N_z = 11;                   % axial DQ points

R_bound = linspace(R_i, R_o, NL+1);
l_total = R_o - R_i;

z_nodes = chebyshev_grid(0, L, N_z);
r_nodes = cell(NL,1);
for e = 1:NL
    r_nodes{e} = chebyshev_grid(R_bound(e), R_bound(e+1), N_r);
end

[A_z, B_z] = DQ_weights(z_nodes);
A_r = cell(NL,1); B_r = cell(NL,1);
for e = 1:NL
    [A_r{e}, B_r{e}] = DQ_weights(r_nodes{e});
end

%% ========================= 2. Loading and time parameters =========================
T_ref    = 300;             % reference / initial temperature (K)
T_inf    = 300;             % ambient temperature for outer convection (K)
h_c      = 100;             % convection coefficient (W/m^2K)
T_in_val = 500;             % final inner surface temperature (K)
t0_ramp  = 0.01;            % ramp time constant (s)
P_i      = 1e6;             % internal pressure (Pa), applied as step for t>0

total_time = 0.05;          % total simulation time (s)
dt         = 5e-4;          % time step (s)

% Newmark parameters (gam > 0.5 adds numerical damping, useful for
% verification runs that must settle to the static solution)
gam = 0.5;  bet = 0.25;
out_name = 'Results_claude_R1.mat';    % output file for saved results

% ---- optional overrides from workspace struct `cfg` (for batch testing) ----
if exist('cfg','var') && isstruct(cfg)
    fn = fieldnames(cfg);
    for iov = 1:numel(fn)
        eval([fn{iov} ' = cfg.(fn{iov});']);   %#ok<EVLDOT>
    end
    if any(strcmp(fn,'gam')) && ~any(strcmp(fn,'bet'))
        bet = (gam + 0.5)^2 / 4;               % consistent dissipative pair
    end
end
Nt = round(total_time/dt);

%% ========================= 3. Material properties (per layer, docx style) ========
% GPL
a_GPL = 2.5e-6;  b_GPL = 1.5e-6;  t_GPL = 1.5e-9;
E_GPL = 1.01e12; rho_GPL = 1062.5; c_GPL = 644;
alpha_GPL = 5e-6; k_GPL = 3000;  nu_GPL = 0.186;
% Matrix (epoxy)
E_m = 3.0e9;  nu_m = 0.34;  rho_m = 1200;
c_m = 1110;   alpha_m = 60e-6;  k_m = 0.246;
gamma_conn = 0.5;           % docx: gamma = 1/2

E_L_  = zeros(NL,1); nu_L_ = zeros(NL,1); rho_L = zeros(NL,1);
c_L   = zeros(NL,1); k_L   = zeros(NL,1); al_L  = zeros(NL,1);

for e = 1:NL
    % --- GPL weight fraction of this layer (docx patterns) ---
    switch upper(GPL_pattern)
        case 'UD', Wg = W_GPL_total;
        case 'O',  Wg = 4*W_GPL_total*(((NL+1)/2) - abs(e-(NL+1)/2))/(NL+2);
        case 'X',  Wg = 4*W_GPL_total*(0.5 + abs(e-(NL+1)/2))/(NL+2);
        case 'V',  Wg = 2*W_GPL_total*e/(NL+1);
        case 'A',  Wg = 2*W_GPL_total*(NL+1-e)/(NL+1);
        otherwise, error('bad GPL_pattern');
    end
    Vg = Wg / (Wg + (rho_GPL/rho_m)*(1-Wg));

    % --- Halpin-Tsai + rule of mixtures (docx) ---
    xiL = 2*a_GPL/t_GPL;  xiT = 2*b_GPL/t_GPL;
    etL = (E_GPL/E_m-1)/(E_GPL/E_m+xiL);
    etT = (E_GPL/E_m-1)/(E_GPL/E_m+xiT);
    EL  = (1+xiL*etL*Vg)/(1-etL*Vg)*E_m;
    ET  = (1+xiT*etT*Vg)/(1-etT*Vg)*E_m;
    Es  = 3/8*EL + 5/8*ET;
    nus = Vg*nu_GPL + (1-Vg)*nu_m;
    rhs = Vg*rho_GPL + (1-Vg)*rho_m;
    cs  = Vg*c_GPL  + (1-Vg)*c_m;
    als = Vg*alpha_GPL + (1-Vg)*alpha_m;
    p   = a_GPL/t_GPL;
    Hp  = log(p+sqrt(p^2-1))*p/sqrt((p^2-1)^3) - 1/(p^2-1);
    if Vg > 1/p     % formula valid only for V_GPL > 1/p (else complex/negative)
        ks = ((2/3)*(Vg-1/p)^gamma_conn / (Hp + 1/(k_GPL/k_m-1)))*k_m + k_m;
    else
        ks = k_m;   % no GPL network: pure matrix conductivity
    end

    % --- porosity factor at layer mid-radius (docx: piecewise constant) ---
    if porosity_on
        rm = R_i + l_total/(2*NL) + (e-1)*l_total/NL;    % layer mid radius
        s  = (rm - R_i)/l_total;                          % 0..1 through thickness
        switch upper(porosity_pattern)
            case 'UD', Pf = e3;             Pm = sqrt(e3);
            case 'O',  Pf = 1-e1*cos(pi*s);           Pm = sqrt(max(Pf,0));
            case 'X',  Pf = 1-e2*(1-cos(pi*s));       Pm = sqrt(max(Pf,0));
            case 'V',  Pf = e4*sqrt(2)*cos(pi*s/2+pi/4); Pm = sqrt(max(Pf,0));
            case 'A',  Pf = e5*sqrt(2)*cos(pi*s/2-pi/4); Pm = sqrt(max(Pf,0));
            otherwise, error('bad porosity_pattern');
        end
        Pf = max(0,min(1,Pf));  Pm = max(0,min(1,Pm));
    else
        Pf = 1; Pm = 1;
    end

    E_L_(e)  = Es*Pf;   nu_L_(e) = nus;   rho_L(e) = rhs*Pm;
    c_L(e)   = cs*Pf;   k_L(e)   = ks*Pf; al_L(e)  = als;
end

% Elastic constants per layer (isotropic)
C11 = (1-nu_L_).*E_L_./((1+nu_L_).*(1-2*nu_L_));
C12 = nu_L_.*E_L_./((1+nu_L_).*(1-2*nu_L_));
C13 = C12;  C22 = C11;  C23 = C12;  C33 = C11;
C55 = E_L_./(2*(1+nu_L_));
beta_th = al_L.*(C11+C12+C13);    % = alpha*(3*lambda+2*mu), thermal modulus

%% ========================= 4. Global assembly =========================
Nn     = NL*N_r*N_z;             % nodes per field
Ndof   = 3*Nn;                   % theta, u, w
idx_Th = @(e,ir,iz)        (e-1)*N_r*N_z + (ir-1)*N_z + iz;
idx_U  = @(e,ir,iz)   Nn + (e-1)*N_r*N_z + (ir-1)*N_z + iz;
idx_W  = @(e,ir,iz) 2*Nn + (e-1)*N_r*N_z + (ir-1)*N_z + iz;

K = sparse(Ndof,Ndof);
C = sparse(Ndof,Ndof);
M = sparse(Ndof,Ndof);

% ------------------- 4.1 interior PDE rows -------------------
% Convention:  M x'' + C x' + K x = F,  K = -(natural spatial operator).
%
% Energy (Lord-Shulman), theta = T - T_ref :
%   rho*c*(th' + tau0*th'') + beta*T_ref*(e' + tau0*e'') - div(k grad th) = 0
%   with dilatation  e = du/dr + u/r + dw/dz
% Momentum:
%   rho*u'' - [elastic op]_r(u,w) + beta*alpha-part * d(th)/dr = 0
%   rho*w'' - [elastic op]_z(u,w) + beta * d(th)/dz            = 0
for e = 1:NL
    rv = r_nodes{e};
    for ir = 1:N_r
        r = rv(ir);
        for iz = 1:N_z
            % ===== energy equation row =====
            eqT = idx_Th(e,ir,iz);
            % -k*(1/r dth/dr + d2th/dr2)   (k constant inside layer)
            for jr = 1:N_r
                cT = idx_Th(e,jr,iz);
                K(eqT,cT) = K(eqT,cT) - k_L(e)*( A_r{e}(ir,jr)/r + B_r{e}(ir,jr) );
            end
            % -k d2th/dz2
            for jz = 1:N_z
                cT = idx_Th(e,ir,jz);
                K(eqT,cT) = K(eqT,cT) - k_L(e)*B_z(iz,jz);
            end
            % rho*c and LS relaxation
            C(eqT,eqT) = C(eqT,eqT) + rho_L(e)*c_L(e);
            if LS_enabled
                M(eqT,eqT) = M(eqT,eqT) + rho_L(e)*c_L(e)*tau0;
            end
            % thermoelastic coupling  beta*T_ref*(d/dt)(e)  [+ tau0 (d2/dt2)]
            cpl = beta_th(e)*T_ref*double(coupling_on);
            for jr = 1:N_r
                cU = idx_U(e,jr,iz);
                C(eqT,cU) = C(eqT,cU) + cpl*A_r{e}(ir,jr);
                if LS_enabled, M(eqT,cU) = M(eqT,cU) + cpl*tau0*A_r{e}(ir,jr); end
            end
            cU = idx_U(e,ir,iz);
            C(eqT,cU) = C(eqT,cU) + cpl/r;
            if LS_enabled, M(eqT,cU) = M(eqT,cU) + cpl*tau0/r; end
            for jz = 1:N_z
                cW = idx_W(e,ir,jz);
                C(eqT,cW) = C(eqT,cW) + cpl*A_z(iz,jz);
                if LS_enabled, M(eqT,cW) = M(eqT,cW) + cpl*tau0*A_z(iz,jz); end
            end

            % ===== r-momentum row =====
            eqU = idx_U(e,ir,iz);
            for jr = 1:N_r
                cU = idx_U(e,jr,iz);
                K(eqU,cU) = K(eqU,cU) - ( C11(e)*B_r{e}(ir,jr) + (C11(e)/r)*A_r{e}(ir,jr) );
            end
            K(eqU,idx_U(e,ir,iz)) = K(eqU,idx_U(e,ir,iz)) + C22(e)/r^2;
            for jz = 1:N_z
                cU = idx_U(e,ir,jz);
                K(eqU,cU) = K(eqU,cU) - C55(e)*B_z(iz,jz);
            end
            for jz = 1:N_z
                cW = idx_W(e,ir,jz);
                K(eqU,cW) = K(eqU,cW) - (C13(e)-C23(e))/r * A_z(iz,jz);   % =0 isotropic
            end
            for jr = 1:N_r
                for jz = 1:N_z
                    cW = idx_W(e,jr,jz);
                    K(eqU,cW) = K(eqU,cW) - (C13(e)+C55(e))*A_r{e}(ir,jr)*A_z(iz,jz);
                end
            end
            % + beta * d(theta)/dr   (moved to LHS -> +)
            for jr = 1:N_r
                cT = idx_Th(e,jr,iz);
                K(eqU,cT) = K(eqU,cT) + beta_th(e)*A_r{e}(ir,jr);
            end
            M(eqU,eqU) = M(eqU,eqU) + rho_L(e);

            % ===== z-momentum row =====
            eqW = idx_W(e,ir,iz);
            for jr = 1:N_r
                cW = idx_W(e,jr,iz);
                K(eqW,cW) = K(eqW,cW) - ( C55(e)*B_r{e}(ir,jr) + (C55(e)/r)*A_r{e}(ir,jr) );
            end
            for jz = 1:N_z
                cW = idx_W(e,ir,jz);
                K(eqW,cW) = K(eqW,cW) - C33(e)*B_z(iz,jz);
            end
            for jz = 1:N_z
                cU = idx_U(e,ir,jz);
                K(eqW,cU) = K(eqW,cU) - (C23(e)+C55(e))/r * A_z(iz,jz);
            end
            for jr = 1:N_r
                for jz = 1:N_z
                    cU = idx_U(e,jr,jz);
                    K(eqW,cU) = K(eqW,cU) - (C13(e)+C55(e))*A_r{e}(ir,jr)*A_z(iz,jz);
                end
            end
            % + beta * d(theta)/dz
            for jz = 1:N_z
                cT = idx_Th(e,ir,jz);
                K(eqW,cT) = K(eqW,cT) + beta_th(e)*A_z(iz,jz);
            end
            M(eqW,eqW) = M(eqW,eqW) + rho_L(e);
        end
    end
end

%% ------------------- 4.2 constraint rows (BC + interfaces) -------------------
F0      = zeros(Ndof,1);       % constant part of RHS
rows_Tin  = zeros(N_z,1);      % rows carrying the inner temperature ramp
rows_Pin  = [];                % rows carrying the pressure step

% ---- (a) thermal: inner surface Dirichlet ramp (LAYER 1 ONLY) ----
for iz = 1:N_z
    n = idx_Th(1,1,iz);
    K(n,:)=0; C(n,:)=0; M(n,:)=0;
    K(n,n)=1;                   % theta = theta_in(t)  (F set in time loop)
    rows_Tin(iz) = n;
end

% ---- (b) thermal: outer surface convection ----
%  k dth/dr + h*th = h*theta_inf ,  theta_inf = T_inf - T_ref = 0
for iz = 1:N_z
    n = idx_Th(NL,N_r,iz);
    K(n,:)=0; C(n,:)=0; M(n,:)=0;
    for jr = 1:N_r
        K(n, idx_Th(NL,jr,iz)) = k_L(NL)*A_r{NL}(N_r,jr);
    end
    K(n,n) = K(n,n) + h_c;
    F0(n)  = h_c*(T_inf - T_ref);
end

% ---- (c) thermal: insulated ends dth/dz = 0 ----
for e = 1:NL
    for ir = 1:N_r
        if e==1 && ir==1,       continue; end   % corner: keep Dirichlet
        if e==NL && ir==N_r,    continue; end   % corner: keep convection
        for iz = [1, N_z]
            n = idx_Th(e,ir,iz);
            K(n,:)=0; C(n,:)=0; M(n,:)=0;
            for jz = 1:N_z
                K(n, idx_Th(e,ir,jz)) = A_z(iz,jz);
            end
        end
    end
end

% ---- (d) thermal: interface continuity (temperature + flux) ----
for e = 1:NL-1
    for iz = 2:N_z-1        % end columns already used by insulated rows
        nL = idx_Th(e,N_r,iz);  nR = idx_Th(e+1,1,iz);
        % temperature continuity on left row
        K(nL,:)=0; C(nL,:)=0; M(nL,:)=0;
        K(nL,nL)=1;  K(nL,nR)=-1;
        % flux continuity on right row
        K(nR,:)=0; C(nR,:)=0; M(nR,:)=0;
        for jr = 1:N_r
            K(nR, idx_Th(e,  jr,iz)) =  k_L(e)  *A_r{e}(N_r,jr);
            K(nR, idx_Th(e+1,jr,iz)) = -k_L(e+1)*A_r{e+1}(1,jr);
        end
    end
end
% interface corner nodes (iz=1,N_z) already carry insulated-end rows for both
% layers; add temperature continuity on the left-layer corner row so the two
% coincident nodes cannot drift apart:
for e = 1:NL-1
    for iz = [1, N_z]
        nL = idx_Th(e,N_r,iz);  nR = idx_Th(e+1,1,iz);
        K(nL,:)=0; C(nL,:)=0; M(nL,:)=0;
        K(nL,nL)=1;  K(nL,nR)=-1;
    end
end

% ---- (e) mechanical: end supports at z=0 and z=L ----
%  S: u=0            and sigma_zz = 0 (with thermal term)
%  F: tau_rz = 0     and sigma_zz = 0 (with thermal term)
%  C: u=0 and w=0
for e = 1:NL
    for ir = 2:N_r-1                       % radial corners handled by r-faces
        r = r_nodes{e}(ir);
        for iz = [1, N_z]
            rU = idx_U(e,ir,iz);  rW = idx_W(e,ir,iz);
            switch upper(BC_z)
                case 'C'
                    K(rU,:)=0; C(rU,:)=0; M(rU,:)=0; K(rU,rU)=1;
                    K(rW,:)=0; C(rW,:)=0; M(rW,:)=0; K(rW,rW)=1;
                case 'S'
                    K(rU,:)=0; C(rU,:)=0; M(rU,:)=0; K(rU,rU)=1;   % u = 0
                    K(rW,:)=0; C(rW,:)=0; M(rW,:)=0;               % sigma_zz = 0
                    for jr = 1:N_r
                        K(rW, idx_U(e,jr,iz)) = C13(e)*A_r{e}(ir,jr);
                    end
                    K(rW, idx_U(e,ir,iz)) = K(rW, idx_U(e,ir,iz)) + C23(e)/r;
                    for jz = 1:N_z
                        K(rW, idx_W(e,ir,jz)) = C33(e)*A_z(iz,jz);
                    end
                    K(rW, idx_Th(e,ir,iz)) = -(C13(e)+C23(e)+C33(e))*al_L(e);
                case 'F'
                    K(rU,:)=0; C(rU,:)=0; M(rU,:)=0;               % tau_rz = 0
                    for jz = 1:N_z
                        K(rU, idx_U(e,ir,jz)) = C55(e)*A_z(iz,jz);
                    end
                    for jr = 1:N_r
                        K(rU, idx_W(e,jr,iz)) = C55(e)*A_r{e}(ir,jr);
                    end
                    K(rW,:)=0; C(rW,:)=0; M(rW,:)=0;               % sigma_zz = 0
                    for jr = 1:N_r
                        K(rW, idx_U(e,jr,iz)) = C13(e)*A_r{e}(ir,jr);
                    end
                    K(rW, idx_U(e,ir,iz)) = K(rW, idx_U(e,ir,iz)) + C23(e)/r;
                    for jz = 1:N_z
                        K(rW, idx_W(e,ir,jz)) = C33(e)*A_z(iz,jz);
                    end
                    K(rW, idx_Th(e,ir,iz)) = -(C13(e)+C23(e)+C33(e))*al_L(e);
                otherwise
                    error('BC_z must be S, F or C');
            end
        end
    end
end

% ---- (f) mechanical: inner surface  sigma_rr = -P_i(t), tau_rz = 0 ----
e = 1; ir = 1; r = r_nodes{1}(1);
for iz = 1:N_z
    rU = idx_U(e,ir,iz);
    K(rU,:)=0; C(rU,:)=0; M(rU,:)=0;
    for jr = 1:N_r
        K(rU, idx_U(e,jr,iz)) = C11(e)*A_r{e}(ir,jr);
    end
    K(rU, idx_U(e,ir,iz)) = K(rU, idx_U(e,ir,iz)) + C12(e)/r;
    for jz = 1:N_z
        K(rU, idx_W(e,ir,jz)) = C13(e)*A_z(iz,jz);
    end
    K(rU, idx_Th(e,ir,iz)) = -(C11(e)+C12(e)+C13(e))*al_L(e);   % thermal term
    rows_Pin(end+1) = rU;                                       %#ok<SAGROW>
end
for iz = 2:N_z-1
    rW = idx_W(e,ir,iz);
    K(rW,:)=0; C(rW,:)=0; M(rW,:)=0;
    for jz = 1:N_z
        K(rW, idx_U(e,ir,jz)) = C55(e)*A_z(iz,jz);
    end
    for jr = 1:N_r
        K(rW, idx_W(e,jr,iz)) = C55(e)*A_r{e}(ir,jr);
    end
end

% ---- (g) mechanical: outer surface  sigma_rr = 0, tau_rz = 0 ----
e = NL; ir = N_r; r = r_nodes{NL}(N_r);
for iz = 1:N_z
    rU = idx_U(e,ir,iz);
    K(rU,:)=0; C(rU,:)=0; M(rU,:)=0;
    for jr = 1:N_r
        K(rU, idx_U(e,jr,iz)) = C11(e)*A_r{e}(ir,jr);
    end
    K(rU, idx_U(e,ir,iz)) = K(rU, idx_U(e,ir,iz)) + C12(e)/r;
    for jz = 1:N_z
        K(rU, idx_W(e,ir,jz)) = C13(e)*A_z(iz,jz);
    end
    K(rU, idx_Th(e,ir,iz)) = -(C11(e)+C12(e)+C13(e))*al_L(e);
end
for iz = 2:N_z-1
    rW = idx_W(e,ir,iz);
    K(rW,:)=0; C(rW,:)=0; M(rW,:)=0;
    for jz = 1:N_z
        K(rW, idx_U(e,ir,jz)) = C55(e)*A_z(iz,jz);
    end
    for jr = 1:N_r
        K(rW, idx_W(e,jr,iz)) = C55(e)*A_r{e}(ir,jr);
    end
end

% ---- (h) mechanical: interface continuity ----
%  u, w continuity + sigma_rr, tau_rz continuity (sigma_rr includes thermal)
for e = 1:NL-1
    rb = R_bound(e+1);
    for iz = 2:N_z-1
        ru = idx_U(e,N_r,iz);   rw = idx_W(e,N_r,iz);
        rs = idx_U(e+1,1,iz);   rt = idx_W(e+1,1,iz);
        % u continuity
        K(ru,:)=0; C(ru,:)=0; M(ru,:)=0;
        K(ru, idx_U(e,N_r,iz))=1;  K(ru, idx_U(e+1,1,iz))=-1;
        % w continuity
        K(rw,:)=0; C(rw,:)=0; M(rw,:)=0;
        K(rw, idx_W(e,N_r,iz))=1;  K(rw, idx_W(e+1,1,iz))=-1;
        % sigma_rr continuity
        K(rs,:)=0; C(rs,:)=0; M(rs,:)=0;
        for jr = 1:N_r
            K(rs, idx_U(e,  jr,iz)) =  C11(e)  *A_r{e}(N_r,jr);
            K(rs, idx_U(e+1,jr,iz)) = -C11(e+1)*A_r{e+1}(1,jr);
        end
        K(rs, idx_U(e,N_r,iz)) = K(rs, idx_U(e,N_r,iz)) + C12(e)/rb;
        K(rs, idx_U(e+1,1,iz)) = K(rs, idx_U(e+1,1,iz)) - C12(e+1)/rb;
        for jz = 1:N_z
            K(rs, idx_W(e,N_r,jz)) = K(rs, idx_W(e,N_r,jz)) + C13(e)  *A_z(iz,jz);
            K(rs, idx_W(e+1,1,jz)) = K(rs, idx_W(e+1,1,jz)) - C13(e+1)*A_z(iz,jz);
        end
        K(rs, idx_Th(e,N_r,iz)) = K(rs, idx_Th(e,N_r,iz)) - (C11(e)+C12(e)+C13(e))*al_L(e);
        K(rs, idx_Th(e+1,1,iz)) = K(rs, idx_Th(e+1,1,iz)) + (C11(e+1)+C12(e+1)+C13(e+1))*al_L(e+1);
        % tau_rz continuity
        K(rt,:)=0; C(rt,:)=0; M(rt,:)=0;
        for jz = 1:N_z
            K(rt, idx_U(e,N_r,jz)) = K(rt, idx_U(e,N_r,jz)) + C55(e)  *A_z(iz,jz);
            K(rt, idx_U(e+1,1,jz)) = K(rt, idx_U(e+1,1,jz)) - C55(e+1)*A_z(iz,jz);
        end
        for jr = 1:N_r
            K(rt, idx_W(e,  jr,iz)) = K(rt, idx_W(e,jr,iz))   + C55(e)  *A_r{e}(N_r,jr);
            K(rt, idx_W(e+1,jr,iz)) = K(rt, idx_W(e+1,jr,iz)) - C55(e+1)*A_r{e+1}(1,jr);
        end
    end
    % interface corner nodes iz = 1, N_z : impose u,w continuity on the
    % left-layer rows (the right-layer rows keep their end-support BCs)
    for iz = [1, N_z]
        ru = idx_U(e,N_r,iz);   rw = idx_W(e,N_r,iz);
        K(ru,:)=0; C(ru,:)=0; M(ru,:)=0;
        K(ru, idx_U(e,N_r,iz))=1;  K(ru, idx_U(e+1,1,iz))=-1;
        K(rw,:)=0; C(rw,:)=0; M(rw,:)=0;
        K(rw, idx_W(e,N_r,iz))=1;  K(rw, idx_W(e+1,1,iz))=-1;
    end
end

% End-support rows for radial-face corner nodes of layer 1 inner / layer NL
% outer are already occupied by sigma_rr rows (f,g). For the interface corner
% nodes we now write the end support into the right-layer rows:
for e = 2:NL
    r2 = r_nodes{e}(1);
    for iz = [1, N_z]
        rU2 = idx_U(e,1,iz);  rW2 = idx_W(e,1,iz);
        switch upper(BC_z)
            case 'C'
                K(rU2,:)=0; C(rU2,:)=0; M(rU2,:)=0; K(rU2,rU2)=1;
                K(rW2,:)=0; C(rW2,:)=0; M(rW2,:)=0; K(rW2,rW2)=1;
            case 'S'
                K(rU2,:)=0; C(rU2,:)=0; M(rU2,:)=0; K(rU2,rU2)=1;
                K(rW2,:)=0; C(rW2,:)=0; M(rW2,:)=0;
                for jr = 1:N_r
                    K(rW2, idx_U(e,jr,iz)) = C13(e)*A_r{e}(1,jr);
                end
                K(rW2, idx_U(e,1,iz)) = K(rW2, idx_U(e,1,iz)) + C23(e)/r2;
                for jz = 1:N_z
                    K(rW2, idx_W(e,1,jz)) = C33(e)*A_z(iz,jz);
                end
                K(rW2, idx_Th(e,1,iz)) = -(C13(e)+C23(e)+C33(e))*al_L(e);
            case 'F'
                K(rU2,:)=0; C(rU2,:)=0; M(rU2,:)=0;
                for jz = 1:N_z
                    K(rU2, idx_U(e,1,jz)) = C55(e)*A_z(iz,jz);
                end
                for jr = 1:N_r
                    K(rU2, idx_W(e,jr,iz)) = C55(e)*A_r{e}(1,jr);
                end
                K(rW2,:)=0; C(rW2,:)=0; M(rW2,:)=0;
                for jr = 1:N_r
                    K(rW2, idx_U(e,jr,iz)) = C13(e)*A_r{e}(1,jr);
                end
                K(rW2, idx_U(e,1,iz)) = K(rW2, idx_U(e,1,iz)) + C23(e)/r2;
                for jz = 1:N_z
                    K(rW2, idx_W(e,1,jz)) = C33(e)*A_z(iz,jz);
                end
                K(rW2, idx_Th(e,1,iz)) = -(C13(e)+C23(e)+C33(e))*al_L(e);
        end
    end
end

% ---- (i) rigid-body pin (needed for S and F ends: axial translation) ----
if upper(BC_z) ~= 'C'
    n = idx_W(1, round(N_r/2), round(N_z/2));
    K(n,:)=0; C(n,:)=0; M(n,:)=0; K(n,n)=1;   % w = 0 at one interior node
end

%% ========================= 5. Row equilibration + diagnostics =========================
% Each equation row is divided by its largest coefficient so that thermal
% rows (~1e3), mechanical rows (~1e13) and constraint rows (~1) end up with
% comparable magnitudes. RHS values written per-row in the time loop must be
% scaled the same way (rs_Tin, rs_Pin).
a0 = 1/(bet*dt^2); a1 = gam/(bet*dt); a2 = 1/(bet*dt); a3 = 1/(2*bet)-1;
a4 = gam/bet-1;    a5 = dt/2*(gam/bet-2); a6 = dt*(1-gam); a7 = dt*gam;

s_row = full(max(abs([K, a0*M, a1*C]), [], 2));
s_row(s_row==0) = 1;
S = spdiags(1./s_row, 0, Ndof, Ndof);
K = S*K;  M = S*M;  C = S*C;  F0 = S*F0;
rs_Tin = 1./s_row(rows_Tin);
rs_Pin = 1./s_row(rows_Pin);

K_eff = K + a0*M + a1*C;
fprintf('Ndof = %d\n', Ndof);
fprintf('rcond-est of K_eff (after equilibration): %.3e\n', 1/condest(K_eff));
zr = find(all(abs(K_eff)<1e-14, 2));
fprintf('zero rows in K_eff : %d\n', numel(zr));
if ~isempty(zr), error('K_eff has empty rows — BC bookkeeping error.'); end

[Lf,Uf,Pf_,Qf] = lu(K_eff);

% ---- static-limit self-check: solve K*x = F(t->inf) directly ----
F_inf = F0;
F_inf(rows_Tin) = (T_in_val - T_ref).*rs_Tin;
F_inf(rows_Pin) = -P_i.*rs_Pin;
x_inf = K \ F_inf;
fprintf('static limit  : T_mid = %.2f K, u_mid = %.4e m\n', ...
    T_ref + x_inf(idx_Th(ceil(NL/2),round(N_r/2),round(N_z/2))), ...
    x_inf(idx_U(ceil(NL/2),round(N_r/2),round(N_z/2))));

%% ========================= 6. Newmark time integration (displacement form) ====
x  = zeros(Ndof,1);      % theta=0, u=0, w=0  (equilibrium at T_ref)
xd = zeros(Ndof,1);      % velocities
xdd= zeros(Ndof,1);      % accelerations

e_mid = ceil(NL/2); ir_mid = round(N_r/2); iz_mid = round(N_z/2);
hist_T = zeros(Nt+1,1); hist_U = zeros(Nt+1,1); hist_W = zeros(Nt+1,1);
hist_Ti= zeros(Nt+1,1);
hist_T(1) = T_ref;   % theta=0

snap_every = max(1,round(Nt/6));  snaps = {};  snap_t = [];

for n = 1:Nt
    t = n*dt;
    % ----- RHS at t_{n+1} (row-scaled) -----
    F = F0;
    th_in = (T_in_val - T_ref)*(1 - exp(-t/t0_ramp));
    F(rows_Tin) = th_in.*rs_Tin;
    F(rows_Pin) = -P_i.*rs_Pin;             % pressure step (t>0)

    % ----- displacement-form Newmark solve -----
    rhs = F + M*(a0*x + a2*xd + a3*xdd) + C*(a1*x + a4*xd + a5*xdd);
    x_new = Qf*(Uf\(Lf\(Pf_*rhs)));

    xdd_new = a0*(x_new - x) - a2*xd - a3*xdd;
    xd_new  = xd + a6*xdd + a7*xdd_new;

    x = x_new;  xd = xd_new;  xdd = xdd_new;

    hist_T(n+1) = T_ref + x(idx_Th(e_mid,ir_mid,iz_mid));
    hist_U(n+1) = x(idx_U (e_mid,ir_mid,iz_mid));
    hist_W(n+1) = x(idx_W (e_mid,ir_mid,iz_mid));
    hist_Ti(n+1)= T_ref + th_in;

    if mod(n,snap_every)==0
        snaps{end+1} = x; snap_t(end+1) = t;                     %#ok<SAGROW>
    end

    if mod(n, max(1,round(Nt/20)))==0
        fprintf('  step %4d/%d  t=%.3e  max|theta|=%.3e  max|u|=%.3e\n', ...
            n, Nt, t, max(abs(x(1:Nn))), max(abs(x(Nn+1:2*Nn))));
    end
    if any(~isfinite(x)) || max(abs(x)) > 1e15
        error('Solution diverged at step %d (t=%.3e s), max|x|=%.3e', n, t, max(abs(x)));
    end
end

%% ========================= 7. Post-processing =========================
tv = (0:Nt)'*dt;

figure('Position',[80 80 1250 750],'Name','Time histories');
subplot(2,3,1); plot(tv,hist_T,'b-',tv,hist_Ti,'k--','LineWidth',1.4);
xlabel('t (s)'); ylabel('T (K)'); grid on;
title('Mid-point temperature'); legend('T_{mid}','T_{inner}(t)','Location','best');
subplot(2,3,2); plot(tv,hist_U*1e6,'r-','LineWidth',1.4);
xlabel('t (s)'); ylabel('u (\mum)'); grid on; title('Mid-point radial displacement');
subplot(2,3,3); plot(tv,hist_W*1e6,'g-','LineWidth',1.4);
xlabel('t (s)'); ylabel('w (\mum)'); grid on; title('Mid-point axial displacement');

% radial profiles at mid-length, final time (+ static limit for comparison)
iz0 = round(N_z/2);
r_all=[]; T_all=[]; U_all=[]; S_rr=[]; S_tt=[]; S_zz=[];
T_inf_prof=[]; U_inf_prof=[];
for e = 1:NL
    for ir = 1:N_r
        T_inf_prof(end+1) = T_ref + x_inf(idx_Th(e,ir,iz0));   %#ok<SAGROW>
        U_inf_prof(end+1) = x_inf(idx_U(e,ir,iz0));            %#ok<SAGROW>
    end
end
for e = 1:NL
    for ir = 1:N_r
        r  = r_nodes{e}(ir);
        th = x(idx_Th(e,ir,iz0));
        u  = x(idx_U(e,ir,iz0));
        dudr=0; dwdz=0;
        for jr=1:N_r, dudr = dudr + A_r{e}(ir,jr)*x(idx_U(e,jr,iz0)); end
        for jz=1:N_z, dwdz = dwdz + A_z(iz0,jz)*x(idx_W(e,ir,jz)); end
        err=dudr; ett=u/r; ezz=dwdz; eth=al_L(e)*th;
        r_all(end+1)=r;  T_all(end+1)=T_ref+th;  U_all(end+1)=u;   %#ok<SAGROW>
        S_rr(end+1)=C11(e)*(err-eth)+C12(e)*(ett-eth)+C13(e)*(ezz-eth); %#ok<SAGROW>
        S_tt(end+1)=C12(e)*(err-eth)+C11(e)*(ett-eth)+C13(e)*(ezz-eth); %#ok<SAGROW>
        S_zz(end+1)=C13(e)*(err-eth)+C13(e)*(ett-eth)+C33(e)*(ezz-eth); %#ok<SAGROW>
    end
end
subplot(2,3,4); plot(r_all,T_all,'b.-'); xlabel('r (m)'); ylabel('T (K)');
grid on; title(sprintf('T(r) at z=L/2, t=%.3g s',total_time));
subplot(2,3,5); plot(r_all,U_all*1e6,'r.-'); xlabel('r (m)'); ylabel('u (\mum)');
grid on; title('u(r) at z=L/2');
subplot(2,3,6); plot(r_all,S_rr/1e6,'.-',r_all,S_tt/1e6,'.-',r_all,S_zz/1e6,'.-');
xlabel('r (m)'); ylabel('\sigma (MPa)'); grid on;
legend('\sigma_{rr}','\sigma_{\theta\theta}','\sigma_{zz}','Location','best');
title('Stresses at z=L/2');

fprintf('\n===== FINAL STATE (t = %.3g s) =====\n', total_time);
fprintf('inner-surface target T : %.2f K\n', T_ref+(T_in_val-T_ref)*(1-exp(-total_time/t0_ramp)));
fprintf('mid-point  T           : %.2f K\n', hist_T(end));
fprintf('mid-point  u           : %.4e m\n', hist_U(end));
fprintf('sigma_rr at inner node : %.4e Pa  (target -P_i = %.4e)\n', S_rr(1), -P_i);
fprintf('sigma_rr at outer node : %.4e Pa  (target 0)\n', S_rr(end));

save(out_name,'tv','hist_T','hist_U','hist_W','r_all','T_all','U_all', ...
     'S_rr','S_tt','S_zz','snaps','snap_t','x_inf','T_inf_prof','U_inf_prof', ...
     'NL','N_r','N_z','r_nodes','z_nodes');
fprintf('Saved %s\n', out_name);

%% ========================= helper functions =========================
function x = chebyshev_grid(a,b,N)
    x = a + (b-a)/2*(1 - cos(pi*(0:N-1)/(N-1)));
end

function [A,B] = DQ_weights(x)
    N = numel(x);  A = zeros(N);
    for i = 1:N
        for j = 1:N
            if i~=j
                num=1; den=1;
                for k=1:N
                    if k~=i && k~=j
                        num = num*(x(i)-x(k));
                        den = den*(x(j)-x(k));
                    end
                end
                A(i,j) = num/(den*(x(j)-x(i)));
            end
        end
    end
    for i=1:N, A(i,i) = -sum(A(i,:)); end
    B = A*A;
end
