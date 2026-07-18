%% ========================================================================
%  DYNAMIC THERMOELASTIC ANALYSIS (LORD-SHULMAN / FOURIER) – FULLY CORRECTED
%  With capability to adjust boundary conditions, porosity, and full display of stresses and strains
%  ========================================================================
clear; clc; close all;

%% ========================= 0. Select model and boundary conditions =========================
% --- Enable/disable models ---
LS_enabled = false;          % true: Lord-Shulman, false: Fourier
porosity_enabled = true;    % true: apply porosity, false: no porosity

% --- Mechanical boundary conditions for each face (options: 'C', 'S', 'F') ---
BC_r_in   = 'F';   % inner surface (r=Ri)
BC_r_out  = 'F';   % outer surface (r=Ro)
BC_z_left = 'C';   % left end (z=0)
BC_z_right= 'C';   % right end (z=L)   <-- one free end

% --- Thermal boundary conditions for each face ---
% Options: 'Dirichlet', 'Neumann', 'Convection', 'Insulated'
T_BC_r_in    = 'Dirichlet';    % constant temperature at r=Ri
T_BC_r_out   = 'Convection';   % convection at r=Ro (matches original code)
T_BC_z_left  = 'Insulated';    % insulated at z=0
T_BC_z_right = 'Insulated';    % insulated at z=L

% Temperature values for Dirichlet or Convection conditions
T_fixed_r_in    = 30;    % constant temperature at r=Ri
T_fixed_r_out   = 40;    % ambient temperature for convection at r=Ro (T_inf)
T_fixed_z_left  = 10;    % constant temperature at z=0 (if Dirichlet)
T_fixed_z_right = 10;    % constant temperature at z=L (if Dirichlet)
h_conv = 10;           % convection coefficient

% --- GPL and porosity patterns (for material properties) ---
GPL_patern = 3;          % 1='O', 2='X', 3='UD', 4='V', 5='A'
Porosity_pattern = 3;    % 0='no porosity', 1='O', 2='X', 3='UD', 4='V', 5='A'
e_3 = 0.8064;            % UD porosity coefficient (only for Porosity_pattern=3)

%% ========================= 1. Geometry and discretization =========================
NL = 3;                     % number of layers
R_i = 0.1;                  % inner radius (m)
R_o = 0.2;                  % outer radius (m)
L = 0.5;                    % cylinder length (m)
N_r = 5;                    % radial points per layer
N_z = 7;                   % axial points

t_layer = (R_o - R_i) / NL;
R_boundaries = linspace(R_i, R_o, NL+1);
Lt = t_layer;

% Chebyshev grids
z_nodes = chebyshev_grid(0, L, N_z);
r_nodes = cell(NL,1);
for e = 1:NL
    r_nodes{e} = chebyshev_grid(R_boundaries(e), R_boundaries(e+1), N_r);
end

% DQ weights (replaced with new code)
[A_z, B_z] = DQ_weights_new(z_nodes);
A_r = cell(NL,1); B_r = cell(NL,1);
for e = 1:NL
    [A_r{e}, B_r{e}] = DQ_weights_new(r_nodes{e});
end

%% ========================= 2. Material properties (replaced with new code) =========================
% GPL
a_GPL = 2.5e-6;   b_GPL = 1.5e-6;   t_GPL = 1.5e-9;
E_GPL = 1.01e12;  rho_GPL = 1060;   c_GPL = 710;
alpha_GPL = 5e-6; k_GPL = 5000;
% Matrix
E_m = 3.0e9;      nu_m = 0.34;      rho_m = 1200;
c_m = 800;        alpha_m = 45e-6;  k_m = 0.4;
nu_GPL = 0.186;   % Poisson's ratio of GPL (from new code)

% GPL mass fraction
W_GPL_total = 0.05;

% Halpin‑Tsai
xi_L = 2*a_GPL/t_GPL;          xi_T = 2*b_GPL/t_GPL;
eta_L = (E_GPL/E_m-1)/(E_GPL/E_m+xi_L);
eta_T = (E_GPL/E_m-1)/(E_GPL/E_m+xi_T);

% Thermal conductivity
p = a_GPL/t_GPL;
if p>1
    Hp = log(p+sqrt(p^2-1))*p/sqrt((p^2-1)^3) - 1/(p^2-1);
else
    Hp = 0;
end
gamma_conn = 1;

% Loading and BCs
T_ref = 300;      T_inf = 300;        h_c = 10;
T_i_amp = 500;    t0 = 0.01;          P_i = 1*10e6;

% Lord‑Shulman parameters
tau0 = 1e-5;               % relaxation time (s)
total_time = 0.1;          % total simulation time (s)
dt = 1e-3;                 % time step (s)
Nt = round(total_time / dt);

%% ========================= 3. Porosity coefficients for V & A =========================
% Define porosity coefficients (matching original code)
% e1 = 0.3;  e2 = 0.3;  e3 = 0.7;   % main porosity coefficients
% 
% l_total = R_o - R_i;
% 
% % Compute int_ref only for V and A patterns (which need e1)
% if strcmpi(Porosity_pattern,'V') || strcmpi(Porosity_pattern,'A')
%     int_ref = integral(@(r) sqrt(1 - e1*cos(pi*r/l_total)), R_i, R_o);
% else
%     int_ref = 0;  % default value for other patterns
% end
% 
% if strcmpi(Porosity_pattern,'V')
%     fun_V = @(r,e4) sqrt(e4*abs(cos(pi*r/(2*l_total)+pi/4)));
%     e4_sol = fzero(@(e4) integral(@(r)fun_V(r,e4),R_i,R_o)-int_ref,0.5);
%     e5_sol = NaN;
% elseif strcmpi(Porosity_pattern,'A')
%     fun_A = @(r,e5) sqrt(e5*abs(cos(pi*r/(2*l_total)+5*pi/4)));
%     e5_sol = fzero(@(e5) integral(@(r)fun_A(r,e5),R_i,R_o)-int_ref,0.5);
%     e4_sol = NaN;
% else
%     e4_sol = NaN; e5_sol = NaN;
% end

%% ========================= 4. Effective properties (replaced with new code) =========================
E_node = cell(NL,1);  nu_node = cell(NL,1);  rho_node = cell(NL,1);
c_node = cell(NL,1);  k_node = cell(NL,1);   alpha_node = cell(NL,1);

for e = 1:NL
    % Determine GPL mass fraction based on pattern (new code)
    switch GPL_patern
        case 1, W_GPL_e = 4*W_GPL_total*(((NL+1)/2)-abs(e-((NL+1)/2)))/(NL+2);
        case 2, W_GPL_e = 4*W_GPL_total*((1/2)+abs(e-((NL+1)/2)))/(NL+2);
        case 3, W_GPL_e = W_GPL_total;
        case 4, W_GPL_e = 2*W_GPL_total*e/(NL+1);
        case 5, W_GPL_e = 2*W_GPL_total*(NL+1-e)/(NL+1);
        otherwise, error('GPL_patern must be 1 to 5.');
    end
    W_GPL_e = max(0,min(1,W_GPL_e));
    V_GPL = W_GPL_e / (W_GPL_e + (rho_GPL/rho_m)*(1-W_GPL_e));
    
    % Halpin-Tsai (new code)
    ks_L = 2*(a_GPL/t_GPL); ks_W = 2*(b_GPL/t_GPL);
    et_L = (E_GPL/E_m - 1)/(E_GPL/E_m + ks_L);
    et_W = (E_GPL/E_m - 1)/(E_GPL/E_m + ks_W);
    E_L = (1 + ks_L*et_L*V_GPL)/(1 - et_L*V_GPL)*E_m;
    E_T = (1 + ks_W*et_W*V_GPL)/(1 - et_W*V_GPL)*E_m;
    E_base = 3/8*E_L + 5/8*E_T;
    
    % Other properties (new code)
    V_m = 1 - V_GPL;
    nu_base = V_GPL*nu_GPL + V_m*nu_m;
    rho_base = V_GPL*rho_GPL + V_m*rho_m;
    c_base = V_GPL*c_GPL + V_m*c_m;
    alpha_base = V_GPL*alpha_GPL + V_m*alpha_m;
    
    % Thermal conductivity (new code)
    P = a_GPL/t_GPL;
    if P > 1
        H_P = (log(P + sqrt(P^2-1))*P)/(sqrt((P^2-1)^3)) - 1/(P^2-1);
    else
        H_P = 0;
    end
    k_base = (( (2/3)*(V_GPL - 1/P)^gamma_conn ) / (H_P + 1/(k_GPL/k_m - 1))) * k_m + k_m;
    
    % --- Apply porosity (new code with enable/disable capability) ---
    r_rel = r_nodes{e} - R_i;
    if porosity_enabled
        % Select porosity coefficients based on e_3 (for O, X, UD, V, A patterns)
        if e_3 == 0.9361, e1=0.1; e2=0.1738; e4=0.9070; e5=0.9070;
        elseif e_3 == 0.8716, e1=0.2; e2=0.3442; e4=0.8445; e5=0.8445;
        elseif e_3 == 0.8064, e1=0.3; e2=0.5103; e4=0.7813; e5=0.7813;
        elseif e_3 == 0.7404, e1=0.4; e2=0.6708; e4=0.7173; e5=0.7173;
        elseif e_3 == 0.6733, e1=0.5; e2=0.8231; e4=0.6523; e5=0.6523;
        elseif e_3 == 0.6047, e1=0.6; e2=0.9612; e4=0.5859; e5=0.5859;
        else
            error('e_3 is not valid. Must be one of: 0.9361, 0.8716, 0.8064, 0.7404, 0.6733, 0.6047.');
        end
        h = R_o - R_i;
        FacE = zeros(N_r,1); FacRho = zeros(N_r,1);
        for ir = 1:N_r
            rr = r_rel(ir);
            % Use the selected porosity pattern (Porosity_pattern)
            switch Porosity_pattern
                case 1   % O
                    P = 1 - e1*cos(pi*rr/h);
                    P_m = sqrt(1 - e1*cos(pi*rr/h));
                case 2   % X
                    P = 1 - e2*(1 - cos(pi*rr/h));
                    P_m = sqrt(1 - e2*(1 - cos(pi*rr/h)));
                case 3   % UD
                    P = e_3;
                    P_m = sqrt(e_3);
                case 4   % V
                    P = e4*2*cos(pi*rr/(2*h) + pi/4);
                    P_m = sqrt(e4*2*cos(pi*rr/(2*h) + pi/4));
                case 5   % A
                    P = e5*2*cos(pi*rr/(2*h) - pi/4);
                    P_m = sqrt(e5*2*cos(pi*rr/(2*h) - pi/4));
                otherwise
                    error('Porosity_pattern must be 0 to 5.');
            end
            FacE(ir) = max(0, min(1, P));
            FacRho(ir) = max(0, min(1, P_m));
        end
        FacK = FacE;
        FacC = 1.0;
    else
        % No porosity
        FacE = ones(N_r,1);
        FacRho = ones(N_r,1);
        FacK = ones(N_r,1);
        FacC = 1.0;
    end
    
    % Store final properties for each point
    E_node{e}   = E_base   * FacE;
    nu_node{e}  = nu_base  * ones(N_r,1);
    rho_node{e} = rho_base * FacRho;
    c_node{e}   = c_base   * ones(N_r,1);
    k_node{e}   = k_base   * FacK;
    alpha_node{e} = alpha_base * ones(N_r,1);
end

%% ========================= 5. Global assembly =========================
Ndof_T = NL*N_r*N_z;
Ndof_U = NL*N_r*N_z;
Ndof_W = NL*N_r*N_z;
Ndof = Ndof_T + Ndof_U + Ndof_W;

idx_T = @(e,ir,iz) (e-1)*N_r*N_z + (ir-1)*N_z + iz;
idx_U = @(e,ir,iz) Ndof_T + (e-1)*N_r*N_z + (ir-1)*N_z + iz;
idx_W = @(e,ir,iz) Ndof_T+Ndof_U + (e-1)*N_r*N_z + (ir-1)*N_z + iz;

% Global node numbering matrix (new)
global_node_numbers = struct('T', zeros(NL,N_r,N_z), ...
                             'U', zeros(NL,N_r,N_z), ...
                             'W', zeros(NL,N_r,N_z));
for e=1:NL
    for ir=1:N_r
        for iz=1:N_z
            global_node_numbers.T(e,ir,iz) = idx_T(e,ir,iz);
            global_node_numbers.U(e,ir,iz) = idx_U(e,ir,iz);
            global_node_numbers.W(e,ir,iz) = idx_W(e,ir,iz);
        end
    end
end

K = sparse(Ndof,Ndof);
M = sparse(Ndof,Ndof);
C = sparse(Ndof,Ndof);

%% -------------------- 5.1 Thermal stiffness --------------------
for e = 1:NL
    rv = r_nodes{e}; kv = k_node{e};
    for ir = 1:N_r
        r = rv(ir); kk = kv(ir);
        dkdr_ir = sum(A_r{e}(ir,:) * kv(:));
        for iz = 1:N_z
            eq = idx_T(e,ir,iz);
            for jr = 1:N_r
                K(eq, idx_T(e,jr,iz)) = K(eq, idx_T(e,jr,iz)) ...
                    + (kk/r + dkdr_ir) * A_r{e}(ir,jr) ...
                    + kk * B_r{e}(ir,jr);
            end
            for jz = 1:N_z
                K(eq, idx_T(e,ir,jz)) = K(eq, idx_T(e,ir,jz)) + kk * B_z(iz,jz);
            end
        end
    end
end

%% -------------------- 5.2 Mechanical stiffness --------------------
for e = 1:NL
    rv = r_nodes{e};
    for ir = 1:N_r
        r = rv(ir);
        E = E_node{e}(ir); nu = nu_node{e}(ir);
        C11 = (1-nu)*E/((1+nu)*(1-2*nu));
        C12 = nu*E/((1+nu)*(1-2*nu));
        C13 = C12;  C22 = C11;  C23 = C12;  C33 = C11;
        C55 = E/(2*(1+nu));
        for iz = 1:N_z
            eq_u = idx_U(e,ir,iz);
            for jr = 1:N_r
                K(eq_u, idx_U(e,jr,iz)) = K(eq_u, idx_U(e,jr,iz)) ...
                    + C11*B_r{e}(ir,jr) + (C11/r)*A_r{e}(ir,jr);
                if ir == jr
                    K(eq_u, idx_U(e,ir,iz)) = K(eq_u, idx_U(e,ir,iz)) ...
                        - (C11 + C22 - C12 + C22) / r^2;
                end
            end
            for jz = 1:N_z
                K(eq_u, idx_U(e,ir,jz)) = K(eq_u, idx_U(e,ir,jz)) + C55*B_z(iz,jz);
            end
            for jz = 1:N_z
                K(eq_u, idx_W(e,ir,jz)) = K(eq_u, idx_W(e,ir,jz)) + (C13-C23)/r * A_z(iz,jz);
            end
            for jr = 1:N_r
                for jz = 1:N_z
                    K(eq_u, idx_W(e,jr,jz)) = K(eq_u, idx_W(e,jr,jz)) ...
                        + (C13+C55) * A_r{e}(ir,jr) * A_z(iz,jz);
                end
            end

            eq_w = idx_W(e,ir,iz);
            for jr = 1:N_r
                K(eq_w, idx_W(e,jr,iz)) = K(eq_w, idx_W(e,jr,iz)) ...
                    + C55*B_r{e}(ir,jr) + (C55/r)*A_r{e}(ir,jr);
            end
            for jz = 1:N_z
                K(eq_w, idx_W(e,ir,jz)) = K(eq_w, idx_W(e,ir,jz)) + C33*B_z(iz,jz);
            end
            for jz = 1:N_z
                K(eq_w, idx_U(e,ir,jz)) = K(eq_w, idx_U(e,ir,jz)) + (C23+C55)/r * A_z(iz,jz);
            end
            for jr = 1:N_r
                for jz = 1:N_z
                    K(eq_w, idx_U(e,jr,jz)) = K(eq_w, idx_U(e,jr,jz)) ...
                        + (C13+C55) * A_r{e}(ir,jr) * A_z(iz,jz);
                end
            end
        end
    end
end

%% ========================= 6. Add mass and damping =========================
% Thermal mass and damping
for e = 1:NL
    for ir = 1:N_r
        for iz = 1:N_z
            eq = idx_T(e,ir,iz);
            dr = t_layer/(N_r-1);
            dz = L/(N_z-1);
            Veff = 2*pi*r_nodes{e}(ir)*dr*dz;
            rc = rho_node{e}(ir)*c_node{e}(ir)*Veff;
            if LS_enabled
                M(eq,eq)=M(eq,eq)+rc*tau0;
            else
                M(eq,eq)=M(eq,eq)+0;   % in Fourier model, thermal mass is zero
            end
            C(eq,eq)=C(eq,eq)+rc;
        end
    end
end

% Mechanical mass
dr = t_layer/(N_r-1);
dz = L/(N_z-1);
for e = 1:NL
    for ir = 1:N_r
        r = r_nodes{e}(ir);
        rho_val = rho_node{e}(ir);
        Veff = 2*pi*r*dr*dz;
        for iz = 1:N_z
            M(idx_U(e,ir,iz),idx_U(e,ir,iz)) = ...
                M(idx_U(e,ir,iz),idx_U(e,ir,iz)) + rho_val*Veff;
            M(idx_W(e,ir,iz),idx_W(e,ir,iz)) = ...
                M(idx_W(e,ir,iz),idx_W(e,ir,iz)) + rho_val*Veff;
        end
    end
end

%% ========================= 7. Boundary-condition flags =========================
is_fixed = false(Ndof,1);

% Thermal Dirichlet BC: inner surface temperature
for e = 1:NL
    for iz = 1:N_z
        is_fixed(idx_T(e,1,iz)) = true;
    end
end

% Mechanical clamped BCs (based on new boundary conditions)
for e = 1:NL
    for ir = 1:N_r
        if BC_r_in == 'C'
            is_fixed(idx_U(e,1,iz)) = true;
            is_fixed(idx_W(e,1,iz)) = true;
        end
        if BC_r_out == 'C'
            is_fixed(idx_U(e,N_r,iz)) = true;
            is_fixed(idx_W(e,N_r,iz)) = true;
        end
        if BC_z_left == 'C'
            is_fixed(idx_U(e,ir,1)) = true;
            is_fixed(idx_W(e,ir,1)) = true;
        end
        if BC_z_right == 'C'
            is_fixed(idx_U(e,ir,N_z)) = true;
            is_fixed(idx_W(e,ir,N_z)) = true;
        end
    end
end

%% ========================= 7.1 Thermal-mechanical coupling =========================
if LS_enabled
    for e = 1:NL
        rv = r_nodes{e};
        for ir = 1:N_r
            r = rv(ir);
            alpha = alpha_node{e}(ir);
            E     = E_node{e}(ir);
            nu    = nu_node{e}(ir);
            lambda = nu*E/((1+nu)*(1-2*nu));
            mu     = E/(2*(1+nu));
            coeff  = alpha*(3*lambda + 2*mu);
            for iz = 1:N_z
                eq = idx_T(e,ir,iz);
                if is_fixed(eq), continue; end
                for jr = 1:N_r
                    col = idx_U(e,jr,iz);
                    if is_fixed(col), continue; end
                    M(eq, col) = M(eq, col) + coeff * tau0 * A_r{e}(ir,jr);
                    C(eq, col) = C(eq, col) + coeff * A_r{e}(ir,jr);
                end
                col_u_self = idx_U(e,ir,iz);
                if ~is_fixed(col_u_self)
                    M(eq, col_u_self) = M(eq, col_u_self) + coeff * tau0 / r;
                    C(eq, col_u_self) = C(eq, col_u_self) + coeff / r;
                end
                for jz = 1:N_z
                    col = idx_W(e,ir,jz);
                    if is_fixed(col), continue; end
                    M(eq, col) = M(eq, col) + coeff * tau0 * A_z(iz,jz);
                    C(eq, col) = C(eq, col) + coeff * A_z(iz,jz);
                end
            end
        end
    end
end

%% ========================= 7. Apply boundary conditions =========================
% Convection on outer surface (Neumann condition) - adjustable
if strcmp(T_BC_r_out, 'Convection')
    e_last = NL;
    for iz = 1:N_z
        node = idx_T(e_last,N_r,iz);
        k_out = k_node{e_last}(N_r);
        K(node,:) = 0; % K(:,node) = 0;
        C(node,:) = 0; % C(:,node) = 0;
        M(node,:) = 0; % M(:,node) = 0;
        K(node,node)=1; M(node,node)=1; C(node,node)=1;
        for jr = 1:N_r
            K(node, idx_T(e_last,jr,iz)) = k_out * A_r{e_last}(N_r,jr);
        end
        K(node,node) = K(node,node) + h_conv;
    end
end

% Insulated end surfaces (dT/dz=0) - adjustable
if strcmp(T_BC_z_left, 'Insulated')
    for e = 1:NL
        for ir = 1:N_r
            n0 = idx_T(e,ir,1);
            K(n0,:)=0; C(n0,:)=0; M(n0,:)=0;
            for jz=1:N_z, K(n0, idx_T(e,ir,jz)) = A_z(1,jz); end
        end
    end
end
if strcmp(T_BC_z_right, 'Insulated')
    for e = 1:NL
        for ir = 1:N_r
            nL = idx_T(e,ir,N_z);
            K(nL,:)=0; C(nL,:)=0; M(nL,:)=0;
            for jz=1:N_z, K(nL, idx_T(e,ir,jz)) = A_z(N_z,jz); end
        end
    end
end

% Thermal continuity between layers(main)
for e = 1:NL-1
    for iz = 2:N_z-1
        left = idx_T(e,N_r,iz);  right = idx_T(e+1,1,iz);
        K(left,:)=0; C(left,:)=0; M(left,:)=0;
        K(left,left)=1; K(left,right)=-1;
        K(right,:)=0; C(right,:)=0; M(right,:)=0;
        kL = k_node{e}(N_r);  kR = k_node{e+1}(1);
        for jr=1:N_r
            K(right, idx_T(e,jr,iz)) = kL * A_r{e}(N_r,jr);
            K(right, idx_T(e+1,jr,iz)) = -kR * A_r{e+1}(1,jr);
        end
    end
end


% % Thermal continuity between layers
% for e = 1:NL-1
%     for iz = 2:N_z-1
%         left = idx_T(e,N_r,iz);  right = idx_T(e+1,1,iz);
%         
%         K(left,:)=0; C(left,:)=0; M(left,:)=0;
% %         K(left,left)=1; K(left,right)=-1;
%         
%         kL = k_node{e}(N_r);  kR = k_node{e+1}(1);
%         for jr=1:N_r
%             K(left, idx_T(e,jr,iz)) = kL * A_r{e}(N_r,jr);
%             K(left, idx_T(e+1,jr,iz)) = -kR * A_r{e+1}(1,jr);
%         end
%         
%         K(right,:)=0; C(right,:)=0; M(right,:)=0;
%         K(right,left)=1; K(right,right)=-1;
%         
%         kL = k_node{e}(N_r);  kR = k_node{e+1}(1);
% %         for jr=1:N_r
% %             K(right, idx_T(e,jr,iz)) = kL * A_r{e}(N_r,jr);
% %             K(right, idx_T(e+1,jr,iz)) = -kR * A_r{e+1}(1,jr);
% %         end
%     end
% end




% --- Mechanical boundary conditions at ends (for all radial points) ---
for e = 1:NL
    for ir = 1:N_r
        r = r_nodes{e}(ir);
        E = E_node{e}(ir); nu = nu_node{e}(ir);
        C13 = nu*E/((1+nu)*(1-2*nu));
        C33 = (1-nu)*E/((1+nu)*(1-2*nu));
        C55 = E/(2*(1+nu));
        
        % r=Ri
        iz_range = 2:N_z-1;
        switch BC_r_in
            case 'C'
                is_fixed(idx_U(e,1,iz)) = true;
                is_fixed(idx_W(e,1,iz)) = true;
            case 'S'
                is_fixed(idx_U(e,1,iz)) = true;
                row_w = idx_W(e,1,iz);
                K(row_w,:)=0; C(row_w,:)=0; M(row_w,:)=0;
                for jr=1:N_r
                    K(row_w, idx_U(e,jr,iz)) = C13 * A_r{e}(1,jr);
                end
                K(row_w, idx_U(e,1,iz)) = K(row_w, idx_U(e,1,iz)) + C13/R_i;
                for jz=1:N_z
                    K(row_w, idx_W(e,1,jz)) = C33 * A_z(iz,jz);
                end
            case 'F'
                row_u = idx_U(e,1,iz);
                K(row_u,:)=0; C(row_u,:)=0; M(row_u,:)=0;
                for jz=1:N_z
                    K(row_u, idx_U(e,1,jz)) = C55 * A_z(iz,jz);
                end
                for jr=1:N_r
                    K(row_u, idx_W(e,jr,iz)) = C55 * A_r{e}(1,jr);
                end
                row_w = idx_W(e,1,iz);
                K(row_w,:)=0; C(row_w,:)=0; M(row_w,:)=0;
                for jr=1:N_r
                    K(row_w, idx_U(e,jr,iz)) = C13 * A_r{e}(1,jr);
                end
                K(row_w, idx_U(e,1,iz)) = K(row_w, idx_U(e,1,iz)) + C13/R_i;
                for jz=1:N_z
                    K(row_w, idx_W(e,1,jz)) = C33 * A_z(iz,jz);
                end
        end
        
        % r=Ro
        switch BC_r_out
            case 'C'
                is_fixed(idx_U(e,N_r,iz)) = true;
                is_fixed(idx_W(e,N_r,iz)) = true;
            case 'S'
                is_fixed(idx_U(e,N_r,iz)) = true;
                row_w = idx_W(e,N_r,iz);
                K(row_w,:)=0; C(row_w,:)=0; M(row_w,:)=0;
                for jr=1:N_r
                    K(row_w, idx_U(e,jr,iz)) = C13 * A_r{e}(N_r,jr);
                end
                K(row_w, idx_U(e,N_r,iz)) = K(row_w, idx_U(e,N_r,iz)) + C13/R_o;
                for jz=1:N_z
                    K(row_w, idx_W(e,N_r,jz)) = C33 * A_z(iz,jz);
                end
            case 'F'
                row_u = idx_U(e,N_r,iz);
                K(row_u,:)=0; C(row_u,:)=0; M(row_u,:)=0;
                for jz=1:N_z
                    K(row_u, idx_U(e,N_r,jz)) = C55 * A_z(iz,jz);
                end
                for jr=1:N_r
                    K(row_u, idx_W(e,jr,iz)) = C55 * A_r{e}(N_r,jr);
                end
                row_w = idx_W(e,N_r,iz);
                K(row_w,:)=0; C(row_w,:)=0; M(row_w,:)=0;
                for jr=1:N_r
                    K(row_w, idx_U(e,jr,iz)) = C13 * A_r{e}(N_r,jr);
                end
                K(row_w, idx_U(e,N_r,iz)) = K(row_w, idx_U(e,N_r,iz)) + C13/R_o;
                for jz=1:N_z
                    K(row_w, idx_W(e,N_r,jz)) = C33 * A_z(iz,jz);
                end
        end
        
        % z=0 and z=L (original code)
        for iz = [1, N_z]
            if iz == 1, BC = BC_z_left; else, BC = BC_z_right; end
            switch BC
                case 'C'
                    is_fixed(idx_U(e,ir,iz)) = true;
                    is_fixed(idx_W(e,ir,iz)) = true;
                case 'S'
                    is_fixed(idx_U(e,ir,iz)) = true;
                    row_w = idx_W(e,ir,iz);
                    K(row_w,:)=0; C(row_w,:)=0; M(row_w,:)=0;
                    for jr=1:N_r
                        K(row_w, idx_U(e,jr,iz)) = C13 * A_r{e}(ir,jr);
                    end
                    K(row_w, idx_U(e,ir,iz)) = K(row_w, idx_U(e,ir,iz)) + C13/r;
                    for jz=1:N_z
                        K(row_w, idx_W(e,ir,jz)) = C33 * A_z(iz,jz);
                    end
                case 'F'
                    row_u = idx_U(e,ir,iz);
                    K(row_u,:)=0; C(row_u,:)=0; M(row_u,:)=0;
                    for jz=1:N_z
                        K(row_u, idx_U(e,ir,jz)) = C55 * A_z(iz,jz);
                    end
                    for jr=1:N_r
                        K(row_u, idx_W(e,jr,iz)) = C55 * A_r{e}(ir,jr);
                    end
                    row_w = idx_W(e,ir,iz);
                    K(row_w,:)=0; C(row_w,:)=0; M(row_w,:)=0;
                    for jr=1:N_r
                        K(row_w, idx_U(e,jr,iz)) = C13 * A_r{e}(ir,jr);
                    end
                    K(row_w, idx_U(e,ir,iz)) = K(row_w, idx_U(e,ir,iz)) + C13/r;
                    for jz=1:N_z
                        K(row_w, idx_W(e,ir,jz)) = C33 * A_z(iz,jz);
                    end
            end
        end
    end
end

% --- Mechanical continuity between layers ---
for e = 1:NL-1
    for iz = 2:N_z-1
        ru = idx_U(e,N_r,iz); rw = idx_W(e,N_r,iz);
        K(ru,:)=0; C(ru,:)=0; M(ru,:)=0;
        K(ru, idx_U(e,N_r,iz)) = 1; K(ru, idx_U(e+1,1,iz)) = -1;
        K(rw,:)=0; C(rw,:)=0; M(rw,:)=0;
        K(rw, idx_W(e,N_r,iz)) = 1; K(rw, idx_W(e+1,1,iz)) = -1;
        
        rsig = idx_U(e+1,1,iz);  rtau = idx_W(e+1,1,iz);
        r_b = R_boundaries(e+1);
        EL = E_node{e}(N_r); nuL = nu_node{e}(N_r);
        C11L = (1-nuL)*EL/((1+nuL)*(1-2*nuL));
        C12L = nuL*EL/((1+nuL)*(1-2*nuL));
        C13L = C12L;  C55L = EL/(2*(1+nuL));
        ER = E_node{e+1}(1); nuR = nu_node{e+1}(1);
        C11R = (1-nuR)*ER/((1+nuR)*(1-2*nuR));
        C12R = nuR*ER/((1+nuR)*(1-2*nuR));
        C13R = C12R;  C55R = ER/(2*(1+nuR));
        K(rsig,:)=0; C(rsig,:)=0; M(rsig,:)=0;
        for jr=1:N_r
            K(rsig, idx_U(e,jr,iz)) = C11L * A_r{e}(N_r,jr);
            K(rsig, idx_U(e+1,jr,iz)) = -C11R * A_r{e+1}(1,jr);
        end
        K(rsig, idx_U(e,N_r,iz)) = K(rsig, idx_U(e,N_r,iz)) + C12L/r_b;
        K(rsig, idx_U(e+1,1,iz)) = K(rsig, idx_U(e+1,1,iz)) - C12R/r_b;
        for jz=1:N_z
            K(rsig, idx_W(e,N_r,jz)) = C13L * A_z(iz,jz);
            K(rsig, idx_W(e+1,1,jz)) = -C13R * A_z(iz,jz);
        end
        K(rtau,:)=0; C(rtau,:)=0; M(rtau,:)=0;
        for jz=1:N_z
            K(rtau, idx_U(e,N_r,jz)) = C55L * A_z(iz,jz);
            K(rtau, idx_U(e+1,1,jz)) = -C55R * A_z(iz,jz);
        end
        for jr=1:N_r
            K(rtau, idx_W(e,jr,iz)) = C55L * A_r{e}(N_r,jr);
            K(rtau, idx_W(e+1,jr,iz)) = -C55R * A_r{e+1}(1,jr);
        end
    end
end

% --- Additional constraint for S and F cases ---
if BC_z_left ~= 'C' || BC_z_right ~= 'C'
    e_pin = 1; ir_pin = 1; iz_pin = 1;
    is_fixed(idx_U(e_pin, ir_pin, iz_pin)) = true;
    is_fixed(idx_W(e_pin, ir_pin, iz_pin)) = true;
    fprintf('Added u=0 and w=0 at (Ri, z=0) to prevent rigid motion.\n');
end

% --- Radial boundary conditions ---
% Inner surface (r=Ri)
e=1; ir=1;
for iz = 2:N_z-1
    r = r_nodes{e}(ir);
    E = E_node{e}(ir); nu = nu_node{e}(ir);
    C11 = (1-nu)*E/((1+nu)*(1-2*nu));
    C12 = nu*E/((1+nu)*(1-2*nu));
    C13 = C12; C55 = E/(2*(1+nu));
    row = idx_U(e,ir,iz);
    K(row,:)=0; C(row,:)=0; M(row,:)=0;
    for jr=1:N_r
        K(row, idx_U(e,jr,iz)) = C11 * A_r{e}(ir,jr);
    end
    K(row, idx_U(e,ir,iz)) = K(row, idx_U(e,ir,iz)) + C12/r;
    for jz=1:N_z
        K(row, idx_W(e,ir,jz)) = C13 * A_z(iz,jz);
    end
    row_tau = idx_W(e,ir,iz);
    K(row_tau,:)=0; C(row_tau,:)=0; M(row_tau,:)=0;
    for jz=1:N_z
        K(row_tau, idx_U(e,ir,jz)) = C55 * A_z(iz,jz);
    end
    for jr=1:N_r
        K(row_tau, idx_W(e,jr,iz)) = C55 * A_r{e}(ir,jr);
    end
end

% Outer surface (r=Ro)
e=NL; ir=N_r;
for iz = 2:N_z-1
    r = r_nodes{e}(ir);
    E = E_node{e}(ir); nu = nu_node{e}(ir);
    C11 = (1-nu)*E/((1+nu)*(1-2*nu));
    C12 = nu*E/((1+nu)*(1-2*nu));
    C13 = C12; C55 = E/(2*(1+nu));
    row = idx_U(e,ir,iz);
    K(row,:)=0; C(row,:)=0; M(row,:)=0;
    for jr=1:N_r
        K(row, idx_U(e,jr,iz)) = C11 * A_r{e}(ir,jr);
    end
    K(row, idx_U(e,ir,iz)) = K(row, idx_U(e,ir,iz)) + C12/r;
    for jz=1:N_z
        K(row, idx_W(e,ir,jz)) = C13 * A_z(iz,jz);
    end
    row_tau = idx_W(e,ir,iz);
    K(row_tau,:)=0; C(row_tau,:)=0; M(row_tau,:)=0;
    for jz=1:N_z
        K(row_tau, idx_U(e,ir,jz)) = C55 * A_z(iz,jz);
    end
    for jr=1:N_r
        K(row_tau, idx_W(e,jr,iz)) = C55 * A_r{e}(ir,jr);
    end
end

%% ========================= Final Dirichlet enforcement =========================
for node = find(is_fixed)'
%     K(:,node) = 0;   C(:,node) = 0;   M(:,node) = 0;
    K(node,:) = 0;   C(node,:) = 0;   M(node,:) = 0;
    K(node,node) = 1; M(node,node) = 1; C(node,node) = 1;
end

%% ========================= Diagnostics before time integration =========================
beta  = 0.25; gamma = 0.5;
c1 = 1/(beta*dt^2); c2 = gamma/(beta*dt);
fprintf('rank(K)     = %d out of %d\n', rank(full(K)), Ndof);
fprintf('rank(M)     = %d out of %d\n', rank(full(M)), Ndof);
fprintf('rank(C)     = %d out of %d\n', rank(full(C)), Ndof);

%% ========================= DIAGNOSTIC: zero/weak rows =========================
row_norm_K = full(sum(abs(K),2));
row_norm_M = full(sum(abs(M),2));
row_norm_C = full(sum(abs(C),2));
tol = 1e-12;
zero_rows_K = find(row_norm_K < tol);
zero_rows_M = find(row_norm_M < tol);
zero_rows_C = find(row_norm_C < tol);
fprintf('\n=== DIAGNOSTIC REPORT ===\n');
fprintf('Zero/near-zero rows in K: %d\n', numel(zero_rows_K));
fprintf('Zero/near-zero rows in M: %d\n', numel(zero_rows_M));
fprintf('Zero/near-zero rows in C: %d\n', numel(zero_rows_C));
K_eff = K + c1*M + c2*C;
fprintf('rank(K_eff) = %d out of %d\n', rank(full(K_eff)), Ndof);
fprintf('rcond(K_eff)= %.3e\n', rcond(full(K_eff)));

%% ========================= 8. Newmark time integration =========================
beta = 0.25; gamma = 0.5;
c1 = 1/(beta*dt^2);   c2 = gamma/(beta*dt);
c3 = 1/(beta*dt);     c4 = 1/(2*beta);
c5 = gamma/beta;      c6 = dt*(1 - gamma/(2*beta));
K_eff = K + c1*M + c2*C;
[L_eff, U_eff, P_eff, Q_eff] = lu(K_eff);

% Initial vectors
d = zeros(Ndof,1); v = zeros(Ndof,1); a = zeros(Ndof,1);
for e = 1:NL
    for ir = 1:N_r
        for iz = 1:N_z
            d(idx_T(e,ir,iz)) = T_ref;
        end
    end
end

% Monitoring points
e_mid = ceil(NL/2); ir_mid = round(N_r/2); iz_mid = round(N_z/2);
idx_T_mid = idx_T(e_mid, ir_mid, iz_mid);
idx_U_mid = idx_U(e_mid, ir_mid, iz_mid);
idx_W_mid = idx_W(e_mid, ir_mid, iz_mid);

T_mid = zeros(Nt+1,1); U_mid = zeros(Nt+1,1); W_mid = zeros(Nt+1,1);
T_mid(1) = d(idx_T_mid); U_mid(1) = d(idx_U_mid); W_mid(1) = d(idx_W_mid);

PressureBC = zeros(Ndof,1);
e = 1; ir = 1;
for iz = 2:N_z-1
    row = idx_U(e,ir,iz);
    PressureBC(row) = -P_i * 2*pi*R_i*dz;
end

for tstep = 1:Nt
    time = tstep * dt;
    F_rhs = zeros(Ndof,1);
    F_rhs = F_rhs + PressureBC;
    T_inner = T_ref + (T_i_amp - T_ref)*(1 - exp(-time/t0));
    
    % Thermal loads: Dirichlet values for inner surface
    if strcmp(T_BC_r_in, 'Dirichlet')
        for iz = 1:N_z
            node = idx_T(1,1,iz);
            F_rhs(node) = T_inner;
        end
    end
    
    % Convection condition on outer surface
    if strcmp(T_BC_r_out, 'Convection')
        for iz = 1:N_z
            node = idx_T(NL,N_r,iz);
            F_rhs(node) = h_conv * T_inf;
        end
    end
    
    % Thermal loads in mechanical equations (thermal expansion)
    for e = 1:NL
        for ir = 2:N_r-1
            r = r_nodes{e}(ir);
            E = E_node{e}(ir); nu = nu_node{e}(ir);
            C11 = (1-nu)*E/((1+nu)*(1-2*nu));
            C12 = nu*E/((1+nu)*(1-2*nu));
            C13 = C12;  C33 = C11;
            alpha = alpha_node{e}(ir);
            for iz = 2:N_z-1
                dTdr = 0; dTdz = 0;
                for jr = 1:N_r
                    dTdr = dTdr + A_r{e}(ir,jr) * d(idx_T(e,jr,iz));
                end
                for jz = 1:N_z
                    dTdz = dTdz + A_z(iz,jz) * d(idx_T(e,ir,jz));
                end
                row_u = idx_U(e,ir,iz);
                if ~is_fixed(row_u)
                    T_at_node = d(idx_T(e, ir, iz)) - T_ref;
                    F_rhs(row_u) = F_rhs(row_u) + (C11 + C12 + C13) * alpha * (dTdr + T_at_node/r);
                end
                row_w = idx_W(e,ir,iz);
                if ~is_fixed(row_w)
                    F_rhs(row_w) = F_rhs(row_w) + (C13 + C12 + C33) * alpha * dTdz;
                end
            end
        end
    end
    
    % Newmark predictor
    d_pred = d + dt*v + (0.5-beta)*dt^2*a;
    v_pred = v + (1-gamma)*dt*a;
    F_eff = F_rhs + M*(c1*d_pred + c3*v + c4*a) + C*(c2*d_pred + c5*v + c6*a);
    a_new = Q_eff * (U_eff \ (L_eff \ (P_eff * F_eff)));
    d = d_pred + beta*dt^2 * a_new;
    v = v_pred + gamma*dt * a_new;
    a = a_new;
    
    % Reapply Dirichlet conditions
    if strcmp(T_BC_r_in, 'Dirichlet')
        for iz = 1:N_z
            node = idx_T(1,1,iz);
            d(node) = T_inner;
            v(node) = 0; a(node) = 0;
        end
    end
    for node = find(is_fixed)'
        if ~any(node == idx_T(1,1,1:N_z))
            d(node) = 0; v(node) = 0; a(node) = 0;
        end
    end
    
    T_mid(tstep+1) = d(idx_T_mid);
    U_mid(tstep+1) = d(idx_U_mid);
    W_mid(tstep+1) = d(idx_W_mid);
end

%% ========================= 9. Compute stresses and strains (new) =========================
% Create 3D matrices to store quantities
T_matrix = zeros(NL,N_r,N_z);
U_matrix = zeros(NL,N_r,N_z);
W_matrix = zeros(NL,N_r,N_z);
sigma_rr = zeros(NL,N_r,N_z);
sigma_tt = zeros(NL,N_r,N_z);
sigma_zz = zeros(NL,N_r,N_z);
tau_rz   = zeros(NL,N_r,N_z);
eps_rr   = zeros(NL,N_r,N_z);
eps_tt   = zeros(NL,N_r,N_z);
eps_zz   = zeros(NL,N_r,N_z);
gamma_rz = zeros(NL,N_r,N_z);

for e=1:NL
    for ir=1:N_r
        r = r_nodes{e}(ir);
        E = E_node{e}(ir); nu = nu_node{e}(ir);
        C11 = (1-nu)*E/((1+nu)*(1-2*nu));
        C12 = nu*E/((1+nu)*(1-2*nu));
        C13 = C12;  C33 = C11;  C55 = E/(2*(1+nu));
        alpha = alpha_node{e}(ir);
        for iz=1:N_z
            T_val = d(idx_T(e,ir,iz));
            U_val = d(idx_U(e,ir,iz));
            W_val = d(idx_W(e,ir,iz));
            T_matrix(e,ir,iz) = T_val;
            U_matrix(e,ir,iz) = U_val;
            W_matrix(e,ir,iz) = W_val;
            
            e;
            iz;
            ir;
%             T_val = d(idx_T(ir,iz,e));
%             U_val = d(idx_U(ir,iz,e));
%             W_val = d(idx_W(ir,iz,e));
%             T_matrix(ir,iz,e) = T_val;
%             U_matrix(ir,iz,e) = U_val;
%             W_matrix(ir,iz,e) = W_val;
            
            
%             T_val = d(1:N_r*N_z*e);
%             U_val = d(N_r*N_z*e+1:N_r*N_z*(e+1));
%             W_val = d(N_r*N_z*(e+1)+1:N_r*N_z*(e+2));
            
%             T_matrix(ir,iz,e) = reshape(T_val,ir,iz,e);
%             U_matrix(ir,iz,e) = reshape(U_val,ir,iz,e);
%             W_matrix(ir,iz,e) = reshape(W_val,ir,iz,e);
            
            % Derivatives
            dUdr=0; dWdr=0; dUdz=0; dWdz=0;
            for jr=1:N_r
                dUdr = dUdr + A_r{e}(ir,jr)*d(idx_U(e,jr,iz));
                dWdr = dWdr + A_r{e}(ir,jr)*d(idx_W(e,jr,iz));
            end
            for jz=1:N_z
                dUdz = dUdz + A_z(iz,jz)*d(idx_U(e,ir,jz));
                dWdz = dWdz + A_z(iz,jz)*d(idx_W(e,ir,jz));
            end
            % Strains
            eps_rr(e,ir,iz) = dUdr;
            eps_tt(e,ir,iz) = U_val/r;
            eps_zz(e,ir,iz) = dWdz;
            gamma_rz(e,ir,iz) = dUdz + dWdr;
            % Thermal strain
            eps_th = alpha*(T_val - T_ref);
            % Stresses (Hooke's law with thermal effect)
            sigma_rr(e,ir,iz) = C11*(eps_rr(e,ir,iz)-eps_th) + C12*(eps_tt(e,ir,iz)-eps_th) + C13*(eps_zz(e,ir,iz)-eps_th);
            sigma_tt(e,ir,iz) = C12*(eps_rr(e,ir,iz)-eps_th) + C11*(eps_tt(e,ir,iz)-eps_th) + C13*(eps_zz(e,ir,iz)-eps_th);
            sigma_zz(e,ir,iz) = C13*(eps_rr(e,ir,iz)-eps_th) + C13*(eps_tt(e,ir,iz)-eps_th) + C33*(eps_zz(e,ir,iz)-eps_th);
            tau_rz(e,ir,iz)   = C55 * gamma_rz(e,ir,iz);
        end
    end
end

%% ========================= 10. Plot results (original code + stresses and strains) =========================
time_vec = (0:Nt)*dt;
figure('Position',[100,100,1200,800]);

% Time histories (original code)
subplot(2,3,1);
plot(time_vec, T_mid, 'b-', 'LineWidth',1.5);
xlabel('Time (s)'); ylabel('Temperature (K)'); 
title('Mid-point T(t)'); grid on;

subplot(2,3,2);
plot(time_vec, U_mid*1e6, 'r-', 'LineWidth',1.5);
xlabel('Time (s)'); ylabel('Radial displacement (\mum)'); 
title('Mid-point U(t)'); grid on;

subplot(2,3,3);
plot(time_vec, W_mid*1e6, 'g-', 'LineWidth',1.5);
xlabel('Time (s)'); ylabel('Axial displacement (\mum)'); 
title(sprintf('Mid-point W(t) – BC: %s/%s', BC_z_left, BC_z_right)); grid on;

% Radial profiles at mid-height (original code)
iz_mid = round(N_z/2);
r_global = []; T_radial = []; U_radial = []; W_radial = [];
sig_rr_rad = []; sig_tt_rad = []; sig_zz_rad = []; tau_rz_rad = [];
eps_rr_rad = []; eps_zz_rad = [];

for e = 1:NL
    if e == 1
        r_layer = r_nodes{e}(:);
        idx_range = 1:N_r;
    else
        r_layer = r_nodes{e}(2:end);
        idx_range = 2:N_r;
    end
    r_global = [r_global; r_layer(:)];
    for ir = idx_range
        T_radial = [T_radial; T_matrix(e,ir,iz_mid)];
        U_radial = [U_radial; U_matrix(e,ir,iz_mid)];
        W_radial = [W_radial; W_matrix(e,ir,iz_mid)];
        sig_rr_rad = [sig_rr_rad; sigma_rr(e,ir,iz_mid)];
        sig_tt_rad = [sig_tt_rad; sigma_tt(e,ir,iz_mid)];
        sig_zz_rad = [sig_zz_rad; sigma_zz(e,ir,iz_mid)];
        tau_rz_rad = [tau_rz_rad; tau_rz(e,ir,iz_mid)];
        eps_rr_rad = [eps_rr_rad; eps_rr(e,ir,iz_mid)];
        eps_zz_rad = [eps_zz_rad; eps_zz(e,ir,iz_mid)];
    end
end

subplot(2,3,4);
plot(r_global, T_radial, 'b-o', 'LineWidth',1.5);
xlabel('r (m)'); ylabel('Temperature (K)'); 
title('Radial T at z=L/2'); grid on;

subplot(2,3,5);
plot(r_global, U_radial*1e6, 'r-o', 'LineWidth',1.5);
xlabel('r (m)'); ylabel('U (\mum)'); 
title('Radial displacement'); grid on;

subplot(2,3,6);
plot(r_global, W_radial*1e6, 'g-o', 'LineWidth',1.5);
xlabel('r (m)'); ylabel('W (\mum)'); 
title('Axial displacement at mid-height'); grid on;

% Axial profiles at mid-radius (original code)
e_mid = ceil(NL/2); ir_mid = round(N_r/2);
z_global = z_nodes;
T_axial = zeros(N_z,1); U_axial = zeros(N_z,1); W_axial = zeros(N_z,1);
for iz = 1:N_z
    T_axial(iz) = d(idx_T(e_mid, ir_mid, iz));
    U_axial(iz) = d(idx_U(e_mid, ir_mid, iz));
    W_axial(iz) = d(idx_W(e_mid, ir_mid, iz));
end

figure('Position',[100,100,1200,400]);
subplot(1,3,1);
plot(z_global, T_axial, 'b-o', 'LineWidth',1.5);
xlabel('z (m)'); ylabel('Temperature (K)'); 
title('Axial T at mid-radius'); grid on;
subplot(1,3,2);
plot(z_global, U_axial*1e6, 'r-o', 'LineWidth',1.5);
xlabel('z (m)'); ylabel('U (\mum)'); 
title('Axial variation of U'); grid on;
subplot(1,3,3);
plot(z_global, W_axial*1e6, 'g-o', 'LineWidth',1.5);
xlabel('z (m)'); ylabel('W (\mum)'); 
title(sprintf('Axial displacement W – BC %s / %s', BC_z_left, BC_z_right)); grid on;

% --- New plots: stresses and strains at mid-length ---
figure('Position',[100,100,1400,900]);
subplot(2,3,1);
plot(r_global, sig_rr_rad, 'b-o', 'LineWidth',1.5);
xlabel('r (m)'); ylabel('\sigma_{rr} (Pa)'); title('Radial stress'); grid on;
subplot(2,3,2);
plot(r_global, sig_tt_rad, 'r-o', 'LineWidth',1.5);
xlabel('r (m)'); ylabel('\sigma_{\theta\theta} (Pa)'); title('Hoop stress'); grid on;
subplot(2,3,3);
plot(r_global, sig_zz_rad, 'g-o', 'LineWidth',1.5);
xlabel('r (m)'); ylabel('\sigma_{zz} (Pa)'); title('Axial stress'); grid on;
subplot(2,3,4);
plot(r_global, tau_rz_rad, 'm-o', 'LineWidth',1.5);
xlabel('r (m)'); ylabel('\tau_{rz} (Pa)'); title('Shear stress'); grid on;
subplot(2,3,5);
plot(r_global, eps_rr_rad, 'b-o', 'LineWidth',1.5);
xlabel('r (m)'); ylabel('\epsilon_{rr}'); title('Radial strain'); grid on;
subplot(2,3,6);
plot(r_global, eps_zz_rad, 'g-o', 'LineWidth',1.5);
xlabel('r (m)'); ylabel('\epsilon_{zz}'); title('Axial strain'); grid on;

fprintf('\n===== FINAL RESULTS at t = %.2e s =====\n', total_time);
fprintf('Mid‑point temperature: %.2f K\n', T_mid(end));
fprintf('Mid‑point radial displacement: %.3e m\n', U_mid(end));
fprintf('Mid‑point axial displacement: %.3e m\n', W_mid(end));
fprintf('Maximum radial displacement: %.3e m at r=%.3f m\n', max(U_radial), r_global(U_radial==max(U_radial)));
fprintf('Minimum axial displacement: %.3e m\n', min(W_axial));

%% ========================= 11. Save results for convergence testing =========================
Results = struct('T_mid', T_mid, 'U_mid', U_mid, 'W_mid', W_mid, ...
                 'T_matrix', T_matrix, 'U_matrix', U_matrix, 'W_matrix', W_matrix, ...
                 'sigma_rr', sigma_rr, 'sigma_tt', sigma_tt, 'sigma_zz', sigma_zz, 'tau_rz', tau_rz, ...
                 'eps_rr', eps_rr, 'eps_tt', eps_tt, 'eps_zz', eps_zz, 'gamma_rz', gamma_rz, ...
                 'time_vec', time_vec, 'r_nodes', r_nodes, 'z_nodes', z_nodes, ...
                 'global_node_numbers', global_node_numbers);
save('Results.mat', 'Results');
disp('Results saved in Results.mat');

%%

% for e=1:NL
%     T_new = d(1:N_r*N_z*e);
%     U_new = d(N_r*N_z*e+1:N_r*N_z*(e+1));
%     W_new = d(N_r*N_z*(e+1)+1:N_r*N_z*(e+2));
%     
% end

T_new = d(1:N_r*N_z*NL);
U_new = d(N_r*N_z*NL+1:2*(N_r*N_z*NL));
W_new = d(2*(N_r*N_z*NL)+1:3*(N_r*N_z*NL));


for i=0:NL-1
    
    T_calc(i*N_r+1:i*N_r+N_r,1:N_z)=reshape(T_new(i*(N_r*N_z)+1:i*(N_r*N_z)+(N_r*N_z),1),N_r,N_z);
    U_calc(i*N_r+1:i*N_r+N_r,1:N_z)=reshape(U_new(i*(N_r*N_z)+1:i*(N_r*N_z)+(N_r*N_z),1),N_r,N_z);
    W_calc(i*N_r+1:i*N_r+N_r,1:N_z)=reshape(W_new(i*(N_r*N_z)+1:i*(N_r*N_z)+(N_r*N_z),1),N_r,N_z);
    
end

T_real = T_calc';
U_real = U_calc';
W_real = W_calc';



%%

K_new=zeros(N_r*N_z*e);

for i=1:N_r*N_z*e
    for j=1:N_r*N_z*e
        K_new(i,j)=K(i,j);
    end
end




%% ========================= Auxiliary functions =========================
function x = chebyshev_grid(a,b,N)
    x = a + (b-a)/2 * (1 - cos(pi*(0:N-1)/(N-1)));
end

function [A,B] = DQ_weights_new(x)
    N = length(x);
    A = zeros(N,N); B = zeros(N,N);
    for i = 1:N
        for j = 1:N
            if i ~= j
                qi_r = 1; qj_r = 1;
                for k = 1:N
                    if k ~= i, qi_r = (x(i) - x(k)) * qi_r; end
                    if k ~= j, qj_r = (x(j) - x(k)) * qj_r; end
                end
                A(i,j) = qi_r / ((x(i) - x(j)) * qj_r);
            end
        end
        for k = 1:N
            if k ~= i, A(i,i) = A(i,i) - A(i,k); end
        end
    end
    for i = 1:N
        for j = 1:N
            if i ~= j
                B(i,j) = 2 * ( A(i,i) * A(i,j) - (A(i,j) / (x(i) - x(j))) );
            end
        end
        for k = 1:N
            if k ~= i, B(i,i) = B(i,i) - B(i,k); end
        end
    end
end