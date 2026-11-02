function res = LSTE_solver_R12(cfg)
%LSTE_SOLVER_R12  Dynamic coupled thermoelastic analysis of a multilayer porous
%   GPL-reinforced hollow cylinder (layerwise DQM in space, Newmark-beta in time).
%
%   res = LSTE_solver_R12(cfg)   cfg: complete input struct from default_input()
%
%   Unknown vector x = [theta ; u ; w],  theta = T - T_ref.
%   Convention:  M x'' + C x' + K x = F,  K = -(natural spatial operator).
%
%   Scenario:
%     inner surface r = R_i : temperature ramp / Gaussian pulse / heat flux,
%                             plus internal pressure P_i for t > 0
%     outer surface r = R_o : convection (or theta = 0)
%     ends z = 0, z = L     : thermally insulated; mechanical support S/F/C/R
%
%   theory = 'FOURIER' : classical coupled theory
%            'LS'      : Lord-Shulman, relaxation time tau0
%            'DPL'     : dual-phase-lag (tau_q = tau0, tau_T)
%            'GN3'     : Green-Naghdi type III
%
%   Porosity: em3 (mass-side UD coefficient) is the primary input; the other
%   pattern coefficients follow from it. P_m = mass factor, P_E = P_m^2 scales
%   E, k and c; rho scales with P_m.

%% ----- unpack input -----
theory = cfg.theory;   tau0 = cfg.tau0;   tau_T = cfg.tau_T;   k_star = cfg.k_star;
coupling_on = cfg.coupling_on;
BC_z = cfg.BC_z;  BC_z0 = cfg.BC_z0;  BC_zL = cfg.BC_zL;
T_BC_in = cfg.T_BC_in;  T_in_mode = cfg.T_in_mode;  t_g0 = cfg.t_g0;  sig_g = cfg.sig_g;
T_BC_out = cfg.T_BC_out;  Mech_BC_in = cfg.Mech_BC_in;  q_in_fun = cfg.q_in_fun;
P_time_mode = cfg.P_time_mode;  t0_P = cfg.t0_P;
NL = cfg.NL;  R_i = cfg.R_i;  R_o = cfg.R_o;  L = cfg.L;  N_r = cfg.N_r;  N_z = cfg.N_z;
GPL_pattern = cfg.GPL_pattern;  porosity_on = cfg.porosity_on;
porosity_pattern = cfg.porosity_pattern;  W_GPL_total = cfg.W_GPL_total;  em3 = cfg.em3;
a_GPL = cfg.a_GPL;  b_GPL = cfg.b_GPL;  t_GPL = cfg.t_GPL;
material_mode = cfg.material_mode;
FG_E_i = cfg.FG_E_i;  FG_nE = cfg.FG_nE;  FG_rho_i = cfg.FG_rho_i;  FG_nrho = cfg.FG_nrho;
FG_nu = cfg.FG_nu;  FG_k = cfg.FG_k;  FG_c = cfg.FG_c;  FG_alpha = cfg.FG_alpha;
E_GPL = cfg.E_GPL;  rho_GPL = cfg.rho_GPL;  c_GPL = cfg.c_GPL;
alpha_GPL = cfg.alpha_GPL;  k_GPL = cfg.k_GPL;  nu_GPL = cfg.nu_GPL;
E_m = cfg.E_m;  nu_m = cfg.nu_m;  rho_m = cfg.rho_m;
c_m = cfg.c_m;  alpha_m = cfg.alpha_m;  k_m = cfg.k_m;  gamma_conn = cfg.gamma_conn;
T_ref = cfg.T_ref;  T_inf = cfg.T_inf;  h_c = cfg.h_c;  T_in_val = cfg.T_in_val;
t0_ramp = cfg.t0_ramp;  P_i = cfg.P_i;
total_time = cfg.total_time;  dt = cfg.dt;  gam = cfg.gam;  bet = cfg.bet;
store_full_history = cfg.store_full_history;
verbose = cfg.verbose;

%% ----- time steps, theory flags, grids -----
% tau_q (=tau0) terms are active for LS and DPL
LSDPL_on = strcmpi(theory,'LS') || strcmpi(theory,'DPL');
Nt = round(total_time/dt);
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

%% ========================= 3. Material properties (per layer) ========

E_L_  = zeros(NL,1); nu_L_ = zeros(NL,1); rho_L = zeros(NL,1);
c_L   = zeros(NL,1); k_L   = zeros(NL,1); al_L  = zeros(NL,1);

% Porosity coefficients, derived exactly from em3 (mass-side input):
em1 = (pi/2)*(1 - em3);
em2 = (1 - em3)/(1 - 2/pi);
em4 = (pi/4)*em3;
em5 = em4;
% e1, e2 (O/X patterns): no closed form, solved numerically; reporting only.
e1 = fzero(@(x) integral(@(r) sqrt(max(1 - x*cos(pi*r),0)), -0.5, 0.5) - em3, [0, 0.999]);
e2 = fzero(@(x) integral(@(r) sqrt(max(1 - x*(1-cos(pi*r)),0)), -0.5, 0.5) - em3, [0, 0.999]);
e4 = (pi/2)*em4^2;  e5 = e4;          % exact closed-form relations

for e = 1:NL
    % --- FG power-law mode: bypass the GPL model entirely ---
    if strcmpi(material_mode, 'FG_powerlaw')
        rm = R_i + l_total/(2*NL) + (e-1)*l_total/NL;   % layer mid radius
        E_L_(e)  = FG_E_i  *(rm/R_i)^FG_nE;
        rho_L(e) = FG_rho_i*(rm/R_i)^FG_nrho;
        nu_L_(e) = FG_nu;
        k_L(e)   = FG_k;
        c_L(e)   = FG_c;
        al_L(e)  = FG_alpha;
        continue;
    end
    % --- GPL weight fraction of this layer ---
    switch upper(GPL_pattern)
        case 'UD', Wg = W_GPL_total;
        case 'O',  Wg = 4*W_GPL_total*(((NL+1)/2) - abs(e-(NL+1)/2))/(NL+2);
        case 'X',  Wg = 4*W_GPL_total*(0.5 + abs(e-(NL+1)/2))/(NL+2);
        case 'V',  Wg = 2*W_GPL_total*e/(NL+1);
        case 'A',  Wg = 2*W_GPL_total*(NL+1-e)/(NL+1);
        otherwise, error('bad GPL_pattern');
    end
    Vg = Wg / (Wg + (rho_GPL/rho_m)*(1-Wg));

    % --- Halpin-Tsai + rule of mixtures ---
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

    % --- porosity factors at layer mid-radius, centered coordinate ---
    %  zeta = (r - r_mid)/l in [-1/2,+1/2];  P_m = mass factor (primary),
    %  P_E = P_m^2 (pointwise, E/Es = (rho/rhos)^2). k,c scale with P_E.
    if porosity_on
        rm  = R_i + l_total/(2*NL) + (e-1)*l_total/NL;    % layer mid radius
        zet = (rm - (R_i + R_o)/2)/l_total;               % centered: -1/2..+1/2
        switch upper(porosity_pattern)
            case 'UD', Pm = em3;
            case 'O',  Pm = 1 - em1*cos(pi*zet);
            case 'X',  Pm = 1 - em2*(1 - cos(pi*zet));
            case 'V',  Pm = 2*em4*cos(pi*zet/2 + pi/4);   % max at INNER face
            case 'A',  Pm = 2*em5*cos(pi*zet/2 - pi/4);   % max at OUTER face
            otherwise, error('bad porosity_pattern');
        end
        Pm = max(0, min(1, Pm));      % physical clip (V/A peak > 1 near mid-domain)
        Pf = Pm^2;                    % E-side factor, pointwise square
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

% DOF numbering: field-major [theta | u | w]; within a field the order is (layer, ir, iz), iz fastest.
NodeMap = reshape(1:N_r*N_z, N_z, N_r).';       % (ir,iz) -> (ir-1)*N_z + iz
DOFmap  = zeros(Ndof, 8);
idxfun  = {idx_Th, idx_U, idx_W};
for cc = 1:3
    for e = 1:NL
        for ir = 1:N_r
            for iz = 1:N_z
                gg = idxfun{cc}(e,ir,iz);
                DOFmap(gg,:) = [gg, cc, e, ir, iz, NodeMap(ir,iz), r_nodes{e}(ir), z_nodes(iz)];
            end
        end
    end
end
GridDOF = zeros(NL, N_r, N_z, 3);
for e = 1:NL
    for ir = 1:N_r
        for iz = 1:N_z
            GridDOF(e,ir,iz,:) = [idx_Th(e,ir,iz), idx_U(e,ir,iz), idx_W(e,ir,iz)];
        end
    end
end
K = sparse(Ndof,Ndof);
C = sparse(Ndof,Ndof);
M = sparse(Ndof,Ndof);

% Convention:  M x'' + C x' + K x = F,  K = -(natural spatial operator).
%
% Energy (Lord-Shulman), theta = T - T_ref :
%   rho*c*(th' + tau0*th'') + beta*T_ref*(e' + tau0*e'') - div(k grad th) = 0
%   with dilatation  e = du/dr + u/r + dw/dz
% Momentum:
%   rho*u'' - [elastic op]_r(u,w) + beta*alpha-part * d(th)/dr = 0
%   rho*w'' - [elastic op]_z(u,w) + beta * d(th)/dz            = 0
isGN3     = strcmpi(theory,'GN3');
dplActive = strcmpi(theory,'DPL') && tau_T > 0;
for e = 1:NL
    rv = r_nodes{e};
    WblockLo = idx_W(e,1,1); WblockHi = idx_W(e,N_r,N_z);   % contiguous for fixed e
    UblockLo = idx_U(e,1,1); UblockHi = idx_U(e,N_r,N_z);
    for ir = 1:N_r
        r = rv(ir);
        Ar_row = A_r{e}(ir,:);  Br_row = B_r{e}(ir,:);
        for iz = 1:N_z
            Az_row = A_z(iz,:);  Bz_row = B_z(iz,:);
            krAz   = kron(Ar_row, Az_row);   % (jr-major, jz-minor), matches idx_*(e,jr,jz)

            % ===== energy equation row (theory-dependent) =====
            eqT = idx_Th(e,ir,iz);
            cpl = beta_th(e)*T_ref*double(coupling_on);
            colsT_r = idx_Th(e,1:N_r,iz);
            colsT_z = idx_Th(e,ir,1:N_z);
            colsU_r = idx_U(e,1:N_r,iz);
            colsW_z = idx_W(e,ir,1:N_z);
            if isGN3
                % GN-III: rho*c*th'' + beta*T0*e'' = k*grad2(th) + k grad2(th')
                opr = Ar_row/r + Br_row;
                K(eqT,colsT_r) = K(eqT,colsT_r) - k_star*opr;
                C(eqT,colsT_r) = C(eqT,colsT_r) - k_L(e)*opr;
                K(eqT,colsT_z) = K(eqT,colsT_z) - k_star*Bz_row;
                C(eqT,colsT_z) = C(eqT,colsT_z) - k_L(e)*Bz_row;
                M(eqT,eqT) = M(eqT,eqT) + rho_L(e)*c_L(e);
                % coupling: beta*T0*e''  (second time derivative only)
                M(eqT,colsU_r) = M(eqT,colsU_r) + cpl*Ar_row;
                M(eqT,idx_U(e,ir,iz)) = M(eqT,idx_U(e,ir,iz)) + cpl/r;
                M(eqT,colsW_z) = M(eqT,colsW_z) + cpl*Az_row;
            else
                % FOURIER / LS / DPL family (LS = DPL with tau_T = 0)
                opr = Ar_row/r + Br_row;
                K(eqT,colsT_r) = K(eqT,colsT_r) - k_L(e)*opr;
                if dplActive
                    C(eqT,colsT_r) = C(eqT,colsT_r) - tau_T*k_L(e)*opr;
                end
                K(eqT,colsT_z) = K(eqT,colsT_z) - k_L(e)*Bz_row;
                if dplActive
                    C(eqT,colsT_z) = C(eqT,colsT_z) - tau_T*k_L(e)*Bz_row;
                end
                % rho*c and relaxation (tau_q for LS/DPL)
                C(eqT,eqT) = C(eqT,eqT) + rho_L(e)*c_L(e);
                if LSDPL_on
                    M(eqT,eqT) = M(eqT,eqT) + rho_L(e)*c_L(e)*tau0;
                end
                % thermoelastic coupling  beta*T0*(e' [+ tau_q e''])
                C(eqT,colsU_r) = C(eqT,colsU_r) + cpl*Ar_row;
                if LSDPL_on, M(eqT,colsU_r) = M(eqT,colsU_r) + cpl*tau0*Ar_row; end
                cU = idx_U(e,ir,iz);
                C(eqT,cU) = C(eqT,cU) + cpl/r;
                if LSDPL_on, M(eqT,cU) = M(eqT,cU) + cpl*tau0/r; end
                C(eqT,colsW_z) = C(eqT,colsW_z) + cpl*Az_row;
                if LSDPL_on, M(eqT,colsW_z) = M(eqT,colsW_z) + cpl*tau0*Az_row; end
            end

            % ===== r-momentum row =====
            eqU = idx_U(e,ir,iz);
            K(eqU,colsU_r) = K(eqU,colsU_r) - ( C11(e)*Br_row + (C11(e)/r)*Ar_row );
            K(eqU,idx_U(e,ir,iz)) = K(eqU,idx_U(e,ir,iz)) + C22(e)/r^2;
            colsU_z = idx_U(e,ir,1:N_z);
            K(eqU,colsU_z) = K(eqU,colsU_z) - C55(e)*Bz_row;
            K(eqU,colsW_z) = K(eqU,colsW_z) - (C13(e)-C23(e))/r * Az_row;   % =0 isotropic
            K(eqU,WblockLo:WblockHi) = K(eqU,WblockLo:WblockHi) - (C13(e)+C55(e))*krAz;
            K(eqU,colsT_r) = K(eqU,colsT_r) + beta_th(e)*Ar_row;
            M(eqU,eqU) = M(eqU,eqU) + rho_L(e);

            % ===== z-momentum row =====
            eqW = idx_W(e,ir,iz);
            colsW_r = idx_W(e,1:N_r,iz);
            K(eqW,colsW_r) = K(eqW,colsW_r) - ( C55(e)*Br_row + (C55(e)/r)*Ar_row );
            K(eqW,colsW_z) = K(eqW,colsW_z) - C33(e)*Bz_row;
            K(eqW,colsU_z) = K(eqW,colsU_z) - (C23(e)+C55(e))/r * Az_row;
            K(eqW,UblockLo:UblockHi) = K(eqW,UblockLo:UblockHi) - (C13(e)+C55(e))*krAz;
            K(eqW,colsT_z) = K(eqW,colsT_z) + beta_th(e)*Az_row;
            M(eqW,eqW) = M(eqW,eqW) + rho_L(e);
        end
    end
end

%% ------------------- 4.2 constraint rows (BC + interfaces) -------------------
F0      = zeros(Ndof,1);       % constant part of RHS
rows_Tin  = zeros(N_z,1);      % rows carrying the inner temperature ramp
rows_Pin  = [];                % rows carrying the pressure step

% ---- (a) thermal: inner surface — Dirichlet ramp OR heat flux ----
for iz = 1:N_z
    n = idx_Th(1,1,iz);
    K(n,:)=0; C(n,:)=0; M(n,:)=0;
    if strcmpi(T_BC_in,'flux')
        % -k dtheta/dr = q_in_fun(t)  at r = R_i
        for jr = 1:N_r
            K(n, idx_Th(1,jr,iz)) = -k_L(1)*A_r{1}(1,jr);
        end
    else
        K(n,n)=1;               % theta = theta_in(t)  (F set in time loop)
    end
    rows_Tin(iz) = n;
end

% ---- (b) thermal: outer surface — convection OR theta = 0 ----
for iz = 1:N_z
    n = idx_Th(NL,N_r,iz);
    K(n,:)=0; C(n,:)=0; M(n,:)=0;
    if strcmpi(T_BC_out,'dirichlet0')
        K(n,n) = 1;  F0(n) = 0;         % theta(R_o) = 0
    else
        %  k dth/dr + h*th = h*theta_inf ,  theta_inf = T_inf - T_ref
        for jr = 1:N_r
            K(n, idx_Th(NL,jr,iz)) = k_L(NL)*A_r{NL}(N_r,jr);
        end
        K(n,n) = K(n,n) + h_c;
        F0(n)  = h_c*(T_inf - T_ref);
    end
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
%  R: tau_rz = 0 and w=0  (roller / plane strain)
for e = 1:NL
    for ir = 2:N_r-1                       % radial corners handled by r-faces
        r = r_nodes{e}(ir);
        for iz = [1, N_z]
            rU = idx_U(e,ir,iz);  rW = idx_W(e,ir,iz);
            bcE = BC_z;                                   % per-end support
            if iz==1  && ~isempty(BC_z0), bcE = BC_z0; end
            if iz==N_z && ~isempty(BC_zL), bcE = BC_zL; end
            switch upper(bcE)
                case 'R'                    % rollers: tau_rz=0, w=0
                    K(rU,:)=0; C(rU,:)=0; M(rU,:)=0;
                    for jz = 1:N_z
                        K(rU, idx_U(e,ir,jz)) = C55(e)*A_z(iz,jz);
                    end
                    for jr = 1:N_r
                        K(rU, idx_W(e,jr,iz)) = C55(e)*A_r{e}(ir,jr);
                    end
                    K(rW,:)=0; C(rW,:)=0; M(rW,:)=0; K(rW,rW)=1;
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
                    error('BC_z must be S, F, C or R');
            end
        end
    end
end

% ---- (f) mechanical: inner surface ----
%  'pressure' (default): sigma_rr = -P_i(t)   |   'fixed': u = 0
e = 1; ir = 1; r = r_nodes{1}(1);
for iz = 1:N_z
    rU = idx_U(e,ir,iz);
    K(rU,:)=0; C(rU,:)=0; M(rU,:)=0;
    if strcmpi(Mech_BC_in,'fixed')
        K(rU,rU) = 1;                       % u(R_i) = 0
    else
        for jr = 1:N_r
            K(rU, idx_U(e,jr,iz)) = C11(e)*A_r{e}(ir,jr);
        end
        K(rU, idx_U(e,ir,iz)) = K(rU, idx_U(e,ir,iz)) + C12(e)/r;
        for jz = 1:N_z
            K(rU, idx_W(e,ir,jz)) = C13(e)*A_z(iz,jz);
        end
        K(rU, idx_Th(e,ir,iz)) = -(C11(e)+C12(e)+C13(e))*al_L(e);  % thermal term
        rows_Pin(end+1) = rU;                                      %#ok<SAGROW>
    end
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

% End-support rows at the interface corner nodes (right-layer rows):
for e = 2:NL
    r2 = r_nodes{e}(1);
    for iz = [1, N_z]
        rU2 = idx_U(e,1,iz);  rW2 = idx_W(e,1,iz);
        bcE = BC_z;                                   % per-end support
        if iz==1  && ~isempty(BC_z0), bcE = BC_z0; end
        if iz==N_z && ~isempty(BC_zL), bcE = BC_zL; end
        switch upper(bcE)
            case 'R'                        % rollers at interface corners
                K(rU2,:)=0; C(rU2,:)=0; M(rU2,:)=0;
                for jz = 1:N_z
                    K(rU2, idx_U(e,1,jz)) = C55(e)*A_z(iz,jz);
                end
                for jr = 1:N_r
                    K(rU2, idx_W(e,jr,iz)) = C55(e)*A_r{e}(1,jr);
                end
                K(rW2,:)=0; C(rW2,:)=0; M(rW2,:)=0; K(rW2,rW2)=1;
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
% 'R'/'C' ends already fix w at the ends -> no pin needed. With per-end
% supports, the pin is skipped if EITHER end is C or R.
bc0 = BC_z; if ~isempty(BC_z0), bc0 = BC_z0; end
bcL = BC_z; if ~isempty(BC_zL), bcL = BC_zL; end
if ~any(ismember(upper({bc0, bcL}), {'C','R'}))
    n = idx_W(1, round(N_r/2), round(N_z/2));
    K(n,:)=0; C(n,:)=0; M(n,:)=0; K(n,n)=1;   % w = 0 at one interior node
end

%% ========================= 5. Row equilibration + diagnostics =========================
a0 = 1/(bet*dt^2); a1 = gam/(bet*dt); a2 = 1/(bet*dt); a3 = 1/(2*bet)-1;
a4 = gam/bet-1;    a5 = dt/2*(gam/bet-2); a6 = dt*(1-gam); a7 = dt*gam;

% Row equilibration: each equation row is scaled by its largest coefficient.
s_row = max([full(max(abs(K),[],2)), full(max(abs(a0*M),[],2)), full(max(abs(a1*C),[],2))], [], 2);
s_row(s_row==0) = 1;
S = spdiags(1./s_row, 0, Ndof, Ndof);
K = S*K;  M = S*M;  C = S*C;  F0 = S*F0;
rs_Tin = 1./s_row(rows_Tin);
rs_Pin = 1./s_row(rows_Pin);

K_eff = K + a0*M + a1*C;
vp(verbose, 'Ndof = %d\n', Ndof);
if verbose, fprintf('rcond-est of K_eff (after equilibration): %.3e\n', 1/condest(K_eff)); end
zr = find(all(abs(K_eff)<1e-14, 2));
vp(verbose, 'zero rows in K_eff : %d\n', numel(zr));
if ~isempty(zr), error('K_eff has empty rows — BC bookkeeping error.'); end

[Lf,Uf,Pf_,Qf] = lu(K_eff);

% ---- static-limit self-check: solve K*x = F(t->inf) directly ----
F_inf = F0;
if strcmpi(T_BC_in,'flux')
    F_inf(rows_Tin) = q_in_fun(1e9).*rs_Tin;   % long-time flux value
elseif strcmpi(T_in_mode,'gauss')
    F_inf(rows_Tin) = 0;                       % pulse ends -> theta_in=0
else
    F_inf(rows_Tin) = (T_in_val - T_ref).*rs_Tin;
end
F_inf(rows_Pin) = -P_i.*rs_Pin;
x_inf = K \ F_inf;
vp(verbose, 'static limit  : T_mid = %.2f K, u_mid = %.4e m\n', ...
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

if store_full_history, X_hist = zeros(Ndof, Nt+1); end

snap_every = max(1,round(Nt/6));  snaps = {};  snap_t = [];

newmark_tic = tic;   % CPU timing of the time-integration loop
for n = 1:Nt
    t = n*dt;
    % ----- RHS at t_{n+1} (row-scaled) -----
    F = F0;
    if strcmpi(T_in_mode,'gauss')        % Gaussian pulse
        th_in = (T_in_val - T_ref)*exp(-(t-t_g0)^2/(2*sig_g^2));
    else
        th_in = (T_in_val - T_ref)*(1 - exp(-t/t0_ramp));
    end
    if strcmpi(T_BC_in,'flux')
        F(rows_Tin) = q_in_fun(t).*rs_Tin;   % prescribed inner heat flux
    else
        F(rows_Tin) = th_in.*rs_Tin;
    end
    if strcmpi(P_time_mode, 'sine')
        P_now = P_i*sin(pi*t/t0_P);
    else
        P_now = P_i;                        % step (default)
    end
    F(rows_Pin) = -P_now.*rs_Pin;

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
    if store_full_history, X_hist(:,n+1) = x; end

    if mod(n,snap_every)==0
        snaps{end+1} = x; snap_t(end+1) = t;                     %#ok<SAGROW>
    end

    if mod(n, max(1,round(Nt/20)))==0
        vp(verbose, '  step %4d/%d  t=%.3e  max|theta|=%.3e  max|u|=%.3e\n', ...
            n, Nt, t, max(abs(x(1:Nn))), max(abs(x(Nn+1:2*Nn))));
    end
    if any(~isfinite(x)) || max(abs(x)) > 1e15
        error('Solution diverged at step %d (t=%.3e s), max|x|=%.3e', n, t, max(abs(x)));
    end
end
newmark_cpu = toc(newmark_tic);
vp(verbose, 'Newmark time-integration CPU: %.2f s (%d steps)\n', newmark_cpu, Nt);

tv = (0:Nt)'*dt;

%% ========================= 7. Stress recovery at mid-length (z = L/2) =========================
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

%% ----- output -----
res = struct();
res.cfg = cfg;
res.theory = theory;
res.tv = tv;
res.hist_T = hist_T;  res.hist_U = hist_U;  res.hist_W = hist_W;  res.hist_Ti = hist_Ti;
res.r_all = r_all;  res.T_all = T_all;  res.U_all = U_all;
res.S_rr = S_rr;  res.S_tt = S_tt;  res.S_zz = S_zz;
res.snaps = snaps;  res.snap_t = snap_t;
res.x_final = x;  res.x_inf = x_inf;
res.T_inf_prof = T_inf_prof;  res.U_inf_prof = U_inf_prof;
res.NL = NL;  res.N_r = N_r;  res.N_z = N_z;  res.Ndof = Ndof;
res.r_nodes = r_nodes;  res.z_nodes = z_nodes;
res.NodeMap = NodeMap;  res.DOFmap = DOFmap;  res.GridDOF = GridDOF;
res.layer = struct('E', E_L_, 'nu', nu_L_, 'rho', rho_L, 'c', c_L, 'k', k_L, 'alpha', al_L);
res.porosity = struct('em1', em1, 'em2', em2, 'em3', em3, 'em4', em4, 'em5', em5, ...
                      'e1', e1, 'e2', e2, 'e3', em3^2, 'e4', e4, 'e5', e5);
res.newmark_cpu = newmark_cpu;
if store_full_history, res.X_hist = X_hist; end
end

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

function vp(verbose, varargin)
    if verbose, fprintf(varargin{:}); end
end
