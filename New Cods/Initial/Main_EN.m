%% ========================================================================
%  STATIC THERMOELASTIC ANALYSIS OF MULTI-LAYER POROUS GPL CYLINDER
%  Using Differential Quadrature Method (DQM) with per-layer meshing
%  ========================================================================
%  LEGEND (main parameters and variables)
%  NL       : number of layers
%  N_r      : number of DQ points in radial direction per layer (including boundaries)
%  N_z      : number of DQ points in axial direction (shared between layers)
%  R_i, R_o : inner and outer radius of cylinder (m)
%  L        : length of cylinder (m)
%  r_nodes{e} : radial point vector of layer e (Chebyshev distribution)
%  z_nodes    : axial point vector (Chebyshev)
%  A_r{e}, B_r{e} : first and second order weight matrices in r-direction for layer e
%  A_z, B_z      : first and second order weight matrices in z-direction (same for all)
%  Base properties: matrix (m) and GPL with specified parameters
%  Effective properties of each layer at grid points: E_node, nu_node, rho_node, c_node, k_node, alpha_node
%  Global indexing: idx_T(e,ir,iz) , idx_U(e,ir,iz) , idx_W(e,ir,iz)
%  ========================================================================

clear; clc; close all;

%% ========================= 1. GEOMETRY AND DISCRETIZATION =========================
NL = 5;                     % number of layers (changeable)
R_i = 0.1;                  % inner radius (m)
R_o = 0.2;                  % outer radius (m)
L = 0.5;                    % cylinder length (m)
N_r = 11;                   % number of radial points per layer (recommended 11 to 15)
N_z = 15;                   % number of axial points

% thickness of each layer (equal assumed)
t_layer = (R_o - R_i) / NL;
R_boundaries = linspace(R_i, R_o, NL+1);   % interlayer boundaries

% axial points with Chebyshev distribution in [0, L]
z_nodes = chebyshev_grid(0, L, N_z);

% radial points in each layer (Chebyshev within each layer)
r_nodes = cell(NL, 1);
for e = 1:NL
    r_nodes{e} = chebyshev_grid(R_boundaries(e), R_boundaries(e+1), N_r);
end

% compute DQ weight matrices in z-direction (first and second order)
[A_z, B_z] = DQ_weights(z_nodes);

% compute DQ weight matrices in r-direction for each layer (independent)
A_r = cell(NL, 1);
B_r = cell(NL, 1);
for e = 1:NL
    [A_r{e}, B_r{e}] = DQ_weights(r_nodes{e});
end

%% ========================= 2. BASE MATERIAL PROPERTIES AND PARAMETERS =========================
% ---------- GPL PROPERTIES ----------
a_GPL = 2.5e-6;     % length (m)
b_GPL = 1.5e-6;     % width (m)
t_GPL = 1.5e-9;     % thickness (m)
E_GPL = 1.01e12;    % Young's modulus (Pa)
rho_GPL = 1060;     % density (kg/m^3)
c_GPL = 710;        % specific heat capacity (J/(kg·K))
alpha_GPL = 5e-6;   % thermal expansion coefficient (1/K)
k_GPL = 5000;       % thermal conductivity (W/(m·K))

% ---------- MATRIX PROPERTIES ----------
E_m = 3.0e9;        % Young's modulus (Pa)
nu_m = 0.34;        % Poisson's ratio
rho_m = 1200;       % density (kg/m^3)
c_m = 800;          % specific heat capacity (J/(kg·K))
alpha_m = 45e-6;    % thermal expansion coefficient (1/K)
k_m = 0.4;          % thermal conductivity (W/(m·K))

% ---------- DISTRIBUTION PATTERNS AND POROSITY ----------
GPL_pattern = 'UD';          % 'UD', 'O', 'X', 'V', 'A'
porosity_pattern = 'UD';     % 'UD', 'O', 'X', 'V', 'A'
W_GPL_total = 0;         % total GPL mass fraction (average)
% Porosity coefficients for UD, O, X patterns (given)
e1 = 0.3;   % for O-type
e2 = 0.3;   % for X-type
e3 = 0.7;   % for UD-type (ratio of effective modulus to base modulus)
% For V and A patterns, e4 and e5 are calculated from constant mass condition (Eq. 46-3).
% These coefficients are determined later when computing properties.

% ---------- HALPIN-TSAI PARAMETERS ----------
xi_L = 2 * (a_GPL / t_GPL);
xi_T = 2 * (b_GPL / t_GPL);
eta_L = (E_GPL/E_m - 1) / (E_GPL/E_m + xi_L);
eta_T = (E_GPL/E_m - 1) / (E_GPL/E_m + xi_T);

% Thermal conductivity parameter (according to Eq. 14-3)
p = a_GPL / t_GPL;          % length-to-thickness ratio
if p > 1
    Hp = log(p + sqrt(p^2-1)) * p / sqrt((p^2-1)^3) - 1/(p^2-1);
else
    Hp = 0;
end
gamma_conn = 1;              % connectivity component (assumed 1)

% ---------- BOUNDARY CONDITIONS AND LOADING ----------
% Thermal
T_inf = 300;                % ambient temperature (K)
h_c = 100;                  % heat transfer coefficient (W/(m^2·K))
T_ref = 300;                % reference temperature for thermal strain
T_i_val = T_ref;              % inner surface temperature in static state (K)

% Mechanical
P_i = 10e6;                 % internal pressure (Pa) (10 MPa)
% Support type at z=0 and z=L: 'simply', 'clamped', 'free'
support_type = 'simply';

%% ========================= 3. PRE-COMPUTATION FOR V AND A POROSITY PATTERNS (CORRECTIVE) =========================
l_total = R_o - R_i;
% Reference integral of O-type pattern
int_ref = integral(@(r) sqrt(1 - e1 * cos(pi * r / l_total)), R_i, R_o);

if strcmpi(porosity_pattern, 'V')
    % Define function with absolute cosine (to avoid negative)
    fun_V = @(r, e4) sqrt(e4 * abs(cos(pi * r / (2*l_total) + pi/4)));
    e4_sol = fzero(@(e4) integral(@(r) fun_V(r, e4), R_i, R_o) - int_ref, 0.5);
    e5_sol = NaN;
elseif strcmpi(porosity_pattern, 'A')
    fun_A = @(r, e5) sqrt(e5 * abs(cos(pi * r / (2*l_total) + 5*pi/4)));
    e5_sol = fzero(@(e5) integral(@(r) fun_A(r, e5), R_i, R_o) - int_ref, 0.5);
    e4_sol = NaN;
else
    e4_sol = NaN; e5_sol = NaN;
end

%% ========================= 4. COMPUTATION OF EFFECTIVE PROPERTIES (CORRECTIVE) =========================
E_node = cell(NL, 1);
nu_node = cell(NL, 1);
rho_node = cell(NL, 1);
c_node = cell(NL, 1);
k_node = cell(NL, 1);
alpha_node = cell(NL, 1);

for e = 1:NL
    % ---- GPL mass fraction with prevention of negative and >1 ----
    switch upper(GPL_pattern)
        case 'UD'
            W_GPL_e = W_GPL_total;
        case 'O'
            mid = (NL+1)/2;
            W_GPL_e = 4 * W_GPL_total * (0.5 - abs(e - mid)) / (NL + 2);
            W_GPL_e = max(0, min(1, W_GPL_e));   % correction
        case 'X'
            W_GPL_e = W_GPL_total * (2*e / (NL+1));
            W_GPL_e = min(1, W_GPL_e);           % correction
        case 'V'
            W_GPL_e = W_GPL_total * (2*(NL+1-e) / (NL+1));
            W_GPL_e = min(1, W_GPL_e);
        case 'A'
            W_GPL_e = W_GPL_total * (2*e / (NL+1));
            W_GPL_e = min(1, W_GPL_e);
        otherwise
            error('Invalid GPL pattern.');
    end
    
    % Convert mass fraction to volume fraction
    V_GPL = W_GPL_e / (W_GPL_e + (rho_GPL/rho_m)*(1 - W_GPL_e));
    
    % ---- Properties without porosity ----
    E_L = (1 + xi_L * eta_L * V_GPL) / (1 - eta_L * V_GPL) * E_m;
    E_T = (1 + xi_T * eta_T * V_GPL) / (1 - eta_T * V_GPL) * E_m;
    E_base = 3/8 * E_L + 5/8 * E_T;
    rho_base = V_GPL * rho_GPL + (1-V_GPL) * rho_m;
    c_base   = V_GPL * c_GPL   + (1-V_GPL) * c_m;
    alpha_base= V_GPL * alpha_GPL + (1-V_GPL) * alpha_m;
    k_base = (2/3 * (V_GPL - 1/p)^gamma_conn) / (Hp + 1/(k_GPL/k_m - 1)) * k_m + k_m;
    nu_base = nu_m;
    
    % ---- Apply location-dependent porosity ----
    r_local = r_nodes{e};
    r_rel = r_local - R_i;
    
    switch lower(porosity_pattern)
        case 'ud'
            Factor_E = e3 * ones(size(r_local));
        case 'o'
            Factor_E = 1 - e1 * cos(pi * r_rel / l_total);
            Factor_E = min(1, Factor_E);   % prevent increase of modulus
        case 'x'
            Factor_E = 1 - e2 * (1 - cos(pi * r_rel / l_total));
            Factor_E = min(1, Factor_E);
        case 'v'
            if isnan(e4_sol)
                error('e4_sol not computed. First activate porosity pattern V in section 3.');
            end
            Factor_E = e4_sol * cos(pi * r_rel / (2*l_total) + pi/4);
            Factor_E = max(0, min(1, Factor_E));   % physical limitation
        case 'a'
            if isnan(e5_sol)
                error('e5_sol not computed. First activate porosity pattern A in section 3.');
            end
            Factor_E = e5_sol * cos(pi * r_rel / (2*l_total) + 5*pi/4);
            Factor_E = max(0, min(1, Factor_E));
        otherwise
            error('Invalid porosity pattern.');
    end
    
    Factor_rho = sqrt(Factor_E);
    Factor_k = Factor_E;
    Factor_c = Factor_E;
    
    E_node{e} = E_base * Factor_E;
    nu_node{e} = nu_base * ones(size(r_local));
    rho_node{e} = rho_base * Factor_rho;
    c_node{e} = c_base * Factor_c;
    k_node{e} = k_base * Factor_k;
    alpha_node{e} = alpha_base * ones(size(r_local));
end

%% ========================= 5. STATIC THERMAL EQUATION (FOURIER) SOLUTION CONSIDERING k GRADIENT =========================
Ndof_T = NL * N_r * N_z;
K_T = sparse(Ndof_T, Ndof_T);
F_T = sparse(Ndof_T, 1);
idx_T = @(e, ir, iz) (e-1)*N_r*N_z + (ir-1)*N_z + iz;

for e = 1:NL
    r_vec = r_nodes{e};
    k_vec = k_node{e};
    
    % Compute derivative of k w.r.t. r at layer points using A_r
    dk_dr = A_r{e} .* k_vec;   % dk/dr at each node
    
    for ir = 1:N_r
        r_val = r_vec(ir);
        k_val = k_vec(ir);
        dk = dk_dr(ir);
        for iz = 1:N_z
            eq = idx_T(e, ir, iz);
            
            % term (k/r) * dT/dr
            for jr = 1:N_r
                col = idx_T(e, jr, iz);
                K_T(eq, col) = K_T(eq, col) + (k_val / r_val) * A_r{e}(ir, jr);
            end
            % term k * d2T/dr2
            for jr = 1:N_r
                col = idx_T(e, jr, iz);
                K_T(eq, col) = K_T(eq, col) + k_val * B_r{e}(ir, jr);
            end
            % term (dk/dr) * dT/dr  (new term)
            for jr = 1:N_r
                col = idx_T(e, jr, iz);
                K_T(eq, col) = K_T(eq, col) + dk * A_r{e}(ir, jr);
            end
            % term k * d2T/dz2
            for jz = 1:N_z
                col = idx_T(e, ir, jz);
                K_T(eq, col) = K_T(eq, col) + k_val * B_z(iz, jz);
            end
        end
    end
end

% Apply thermal boundary conditions
% a) Temperature condition at inner surface (r = R_i, e=1, ir=1)
for iz = 1:N_z
    node = idx_T(1, 1, iz);
    K_T(node, :) = 0;
    K_T(node, node) = 1;
    F_T(node) = T_i_val;
end

% b) Convection condition at outer surface (r = R_o, e=NL, ir=N_r)
e_last = NL;
for iz = 1:N_z
    node = idx_T(e_last, N_r, iz);
    r_out = r_nodes{e_last}(N_r);
    k_out = k_node{e_last}(N_r);
    % equation: -k dT/dr = h_c (T - T_inf)  ->  k * (A_r * T) + h_c T = h_c T_inf
    K_T(node, :) = 0;
    for jr = 1:N_r
        col = idx_T(e_last, jr, iz);
        K_T(node, col) = k_out * A_r{e_last}(N_r, jr);
    end
    K_T(node, node) = K_T(node, node) + h_c;
    F_T(node) = h_c * T_inf;
end

% c) Insulation condition at z=0 and z=L (∂T/∂z = 0)
% for z=0 (iz=1)
for e = 1:NL
    for ir = 1:N_r
        node = idx_T(e, ir, 1);
        K_T(node, :) = 0;
        for jz = 1:N_z
            col = idx_T(e, ir, jz);
            K_T(node, col) = A_z(1, jz);
        end
        F_T(node) = 0;
    end
end
% for z=L (iz=N_z)
for e = 1:NL
    for ir = 1:N_r
        node = idx_T(e, ir, N_z);
        K_T(node, :) = 0;
        for jz = 1:N_z
            col = idx_T(e, ir, jz);
            K_T(node, col) = A_z(N_z, jz);
        end
        F_T(node) = 0;
    end
end

% d) Thermal compatibility conditions between layers (at common boundary r = R_boundaries(e+1))
for e = 1:NL-1
    for iz = 1:N_z
        idx_left = idx_T(e, N_r, iz);
        idx_right = idx_T(e+1, 1, iz);
        % Condition 1: temperature continuity -> T_left = T_right
        K_T(idx_left, :) = 0;
        K_T(idx_left, idx_left) = 1;
        K_T(idx_left, idx_right) = -1;
        F_T(idx_left) = 0;
        
        % Condition 2: heat flux continuity -> k_left * dT/dr|left = k_right * dT/dr|right
        idx_flux = idx_right;   % replace right side equation with flux condition
        k_left = k_node{e}(N_r);
        k_right = k_node{e+1}(1);
        K_T(idx_flux, :) = 0;
        for jr = 1:N_r
            col_left = idx_T(e, jr, iz);
            K_T(idx_flux, col_left) = k_left * A_r{e}(N_r, jr);
            col_right = idx_T(e+1, jr, iz);
            K_T(idx_flux, col_right) = -k_right * A_r{e+1}(1, jr);
        end
        F_T(idx_flux) = 0;
    end
end

% Solve thermal system
T_global = K_T \ F_T;
% Rearrange temperature in each layer (N_r × N_z matrix)
T_layer = cell(NL, 1);
for e = 1:NL
    T_layer{e} = zeros(N_r, N_z);
    for ir = 1:N_r
        for iz = 1:N_z
            T_layer{e}(ir, iz) = T_global(idx_T(e, ir, iz));
        end
    end
end

%% ========================= 6. STATIC ELASTIC EQUATION SOLUTION (COUPLED WITH TEMPERATURE) WITH FULL BOUNDARY CONDITIONS =========================
% Total number of mechanical degrees of freedom (U and W)
Ndof_M = 2 * NL * N_r * N_z;
K_M = sparse(Ndof_M, Ndof_M);
F_M = sparse(Ndof_M, 1);

% Indexing for U and W
idx_U = @(e, ir, iz) (e-1)*N_r*N_z*2 + (ir-1)*N_z*2 + (iz-1)*2 + 1;
idx_W = @(e, ir, iz) idx_U(e, ir, iz) + 1;

% =======================  ASSEMBLE EQUILIBRIUM EQUATIONS WITHIN EACH LAYER =======================
for e = 1:NL
    r_vec = r_nodes{e};
    for ir = 1:N_r
        r_val = r_vec(ir);
        E_val = E_node{e}(ir);
        nu_val = nu_node{e}(ir);
        % Elastic coefficients (isotropic)
        C11 = (1-nu_val)*E_val / ((1+nu_val)*(1-2*nu_val));
        C12 = nu_val*E_val / ((1+nu_val)*(1-2*nu_val));
        C13 = C12;
        C22 = C11;
        C23 = C12;
        C33 = C11;
        C55 = E_val / (2*(1+nu_val));
        
        for iz = 1:N_z
            % ---- Equation in r-direction (66-3) ----
            eq_r = idx_U(e, ir, iz);
            % u terms
            for jr = 1:N_r
                col_u = idx_U(e, jr, iz);
                K_M(eq_r, col_u) = K_M(eq_r, col_u) + C11 * B_r{e}(ir, jr) ...
                                    + (C11 / r_val) * A_r{e}(ir, jr);
                if ir == jr
                    K_M(eq_r, col_u) = K_M(eq_r, col_u) - C22 / (r_val^2);
                end
            end
            for jz = 1:N_z
                col_u = idx_U(e, ir, jz);
                K_M(eq_r, col_u) = K_M(eq_r, col_u) + C55 * B_z(iz, jz);
            end
            % w terms
            for jz = 1:N_z
                col_w = idx_W(e, ir, jz);
                K_M(eq_r, col_w) = K_M(eq_r, col_w) + (C13 - C23)/r_val * A_z(iz, jz);
            end
            for jr = 1:N_r
                for jz = 1:N_z
                    col_w = idx_W(e, jr, jz);
                    K_M(eq_r, col_w) = K_M(eq_r, col_w) + (C13 + C55) * A_r{e}(ir, jr) * A_z(iz, jz);
                end
            end
            % Thermal right-hand side (r)
            DeltaT = T_layer{e}(ir, iz) - T_ref;
            dTdr = 0;
            for jr = 1:N_r
                dTdr = dTdr + A_r{e}(ir, jr) * T_layer{e}(jr, iz);
            end
            F_M(eq_r) = (C11 + C12 + C13) * alpha_node{e}(ir) * dTdr;
            
            % ---- Equation in z-direction (67-3) ----
            eq_z = idx_W(e, ir, iz);
            % w terms
            for jr = 1:N_r
                col_w = idx_W(e, jr, iz);
                K_M(eq_z, col_w) = K_M(eq_z, col_w) + C55 * B_r{e}(ir, jr) ...
                                    + (C55 / r_val) * A_r{e}(ir, jr);
            end
            for jz = 1:N_z
                col_w = idx_W(e, ir, jz);
                K_M(eq_z, col_w) = K_M(eq_z, col_w) + C33 * B_z(iz, jz);
            end
            % u terms
            for jz = 1:N_z
                col_u = idx_U(e, ir, jz);
                K_M(eq_z, col_u) = K_M(eq_z, col_u) + (C23 + C55)/r_val * A_z(iz, jz);
            end
            for jr = 1:N_r
                for jz = 1:N_z
                    col_u = idx_U(e, jr, jz);
                    K_M(eq_z, col_u) = K_M(eq_z, col_u) + (C13 + C55) * A_r{e}(ir, jr) * A_z(iz, jz);
                end
            end
            % Thermal right-hand side (z)
            dTdz = 0;
            for jz = 1:N_z
                dTdz = dTdz + A_z(iz, jz) * T_layer{e}(ir, jz);
            end
            F_M(eq_z) = (C13 + C23 + C33) * alpha_node{e}(ir) * dTdz;
        end
    end
end

%% ============================================================
%  Mechanical Interface Continuity (Between Layers)
%  Added at: After internal mechanical assembly, Before BCs
%% ============================================================
disp('Applying mechanical interface continuity conditions...');

for e = 1:NL-1
    % Interface between layer e and e+1
    % for all axial points iz
    for iz = 1:N_z
        % Define equation rows (using equations of layer e at boundary r=Ro)
        row_u = idx_U(e, N_r, iz);
        row_w = idx_W(e, N_r, iz);
        row_s = idx_U(e+1, 1, iz); % radial stress condition (for layer e+1 at Ri)
        row_t = idx_W(e+1, 1, iz); % shear stress condition (for layer e+1 at Ri)
        
        % 1. Radial displacement continuity: U_e = U_{e+1}
        K_M(row_u, :) = 0; F_M(row_u) = 0;
        K_M(row_u, idx_U(e, N_r, iz)) = 1;
        K_M(row_u, idx_U(e+1, 1, iz)) = -1;
        
        % 2. Axial displacement continuity: W_e = W_{e+1}
        K_M(row_w, :) = 0; F_M(row_w) = 0;
        K_M(row_w, idx_W(e, N_r, iz)) = 1;
        K_M(row_w, idx_W(e+1, 1, iz)) = -1;
        
        % Extract coefficients for stress (on both sides of the boundary)
        E_l = E_node{e}(N_r); nu_l = nu_node{e}(N_r);
        C11_l = (1-nu_l)*E_l/((1+nu_l)*(1-2*nu_l)); C12_l = nu_l*E_l/((1+nu_l)*(1-2*nu_l)); C13_l = C12_l; C55_l = E_l/(2*(1+nu_l));
        
        E_r = E_node{e+1}(1); nu_r = nu_node{e+1}(1);
        C11_r = (1-nu_r)*E_r/((1+nu_r)*(1-2*nu_r)); C12_r = nu_r*E_r/((1+nu_r)*(1-2*nu_r)); C13_r = C12_r; C55_r = E_r/(2*(1+nu_r));
        
        r_b = R_boundaries(e+1);
        
        % 3. Radial stress continuity: Sigma_rr_l = Sigma_rr_r
        K_M(row_s, :) = 0; F_M(row_s) = 0;
        for jr = 1:N_r
            K_M(row_s, idx_U(e, jr, iz)) = C11_l * A_r{e}(N_r, jr);
            K_M(row_s, idx_U(e+1, jr, iz)) = -C11_r * A_r{e+1}(1, jr);
        end
        K_M(row_s, idx_U(e, N_r, iz)) = K_M(row_s, idx_U(e, N_r, iz)) + C12_l / r_b;
        K_M(row_s, idx_U(e+1, 1, iz)) = K_M(row_s, idx_U(e+1, 1, iz)) - C12_r / r_b;
        for jz = 1:N_z
            K_M(row_s, idx_W(e, N_r, jz)) = C13_l * A_z(iz, jz);
            K_M(row_s, idx_W(e+1, 1, jz)) = -C13_r * A_z(iz, jz);
        end
        
        % 4. Shear stress continuity: Tau_rz_l = Tau_rz_r
        K_M(row_t, :) = 0; F_M(row_t) = 0;
        for jz = 1:N_z
            K_M(row_t, idx_U(e, N_r, jz)) = C55_l * A_z(iz, jz);
            K_M(row_t, idx_U(e+1, 1, jz)) = -C55_r * A_z(iz, jz);
        end
        for jr = 1:N_r
            K_M(row_t, idx_W(e, jr, iz)) = C55_l * A_r{e}(N_r, jr);
            K_M(row_t, idx_W(e+1, jr, iz)) = -C55_r * A_r{e+1}(1, jr);
        end
    end
end

%% ============================================================
%  Mechanical Boundary Conditions - Corrected Version
%  Apply after assembling internal mechanical equations
%% ============================================================

% ------------------------------------------------------------
% 1) z = 0 and z = L
% For free axial ends:
% tau_rz = 0
% sigma_zz = 0
%
% Important:
% Apply only for internal radial points:
% ir = 2 : N_r-1
% Do not apply at radial corners.
% ------------------------------------------------------------

for e = 1:NL

    for ir = 2:N_r-1

        r_val = r_nodes{e}(ir);

        E_val  = E_node{e}(ir);
        nu_val = nu_node{e}(ir);

        C11 = (1-nu_val)*E_val / ((1+nu_val)*(1-2*nu_val));
        C12 = nu_val*E_val     / ((1+nu_val)*(1-2*nu_val));
        C13 = C12;
        C22 = C11;
        C23 = C12;
        C33 = C11;
        C55 = E_val / (2*(1+nu_val));

        for iz = [1, N_z]

            % =================================================
            % tau_rz = C55 * (du/dz + dw/dr) = 0
            % Use U-row
            % =================================================

            row_tau = idx_U(e, ir, iz);

            K_M(row_tau, :) = 0;
            F_M(row_tau) = 0;

            % du/dz term
            for jz = 1:N_z
                col_u = idx_U(e, ir, jz);
                K_M(row_tau, col_u) = K_M(row_tau, col_u) + C55 * A_z(iz, jz);
            end

            % dw/dr term
            for jr = 1:N_r
                col_w = idx_W(e, jr, iz);
                K_M(row_tau, col_w) = K_M(row_tau, col_w) + C55 * A_r{e}(ir, jr);
            end


            % =================================================
            % sigma_zz = C13 du/dr + C23 u/r + C33 dw/dz
            %            - thermal_part = 0
            % Use W-row
            % =================================================

            row_sig = idx_W(e, ir, iz);

            K_M(row_sig, :) = 0;

            % C13 du/dr
            for jr = 1:N_r
                col_u = idx_U(e, jr, iz);
                K_M(row_sig, col_u) = K_M(row_sig, col_u) + C13 * A_r{e}(ir, jr);
            end

            % C23 u/r
            col_u_center = idx_U(e, ir, iz);
            K_M(row_sig, col_u_center) = K_M(row_sig, col_u_center) + C23 / r_val;

            % C33 dw/dz
            for jz = 1:N_z
                col_w = idx_W(e, ir, jz);
                K_M(row_sig, col_w) = K_M(row_sig, col_w) + C33 * A_z(iz, jz);
            end

            % thermal term
            DeltaT = T_layer{e}(ir, iz) - T_ref;
            alpha_val = alpha_node{e}(ir);

            F_M(row_sig) = (C13 + C23 + C33) * alpha_val * DeltaT;

        end
    end
end


% ------------------------------------------------------------
% 2) Inner radial surface r = Ri
% sigma_rr = -P_i
%
% Apply on U-row for all z-points.
% ------------------------------------------------------------

e  = 1;
ir = 1;

r_val = r_nodes{e}(ir);

E_val  = E_node{e}(ir);
nu_val = nu_node{e}(ir);

C11 = (1-nu_val)*E_val / ((1+nu_val)*(1-2*nu_val));
C12 = nu_val*E_val     / ((1+nu_val)*(1-2*nu_val));
C13 = C12;

for iz = 1:N_z

    row_sig = idx_U(e, ir, iz);

    K_M(row_sig, :) = 0;

    % sigma_rr = C11 du/dr + C12 u/r + C13 dw/dz - thermal
    % C11 du/dr
    for jr = 1:N_r
        col_u = idx_U(e, jr, iz);
        K_M(row_sig, col_u) = K_M(row_sig, col_u) + C11 * A_r{e}(ir, jr);
    end

    % C12 u/r
    col_u_center = idx_U(e, ir, iz);
    K_M(row_sig, col_u_center) = K_M(row_sig, col_u_center) + C12 / r_val;

    % C13 dw/dz
    for jz = 1:N_z
        col_w = idx_W(e, ir, jz);
        K_M(row_sig, col_w) = K_M(row_sig, col_w) + C13 * A_z(iz, jz);
    end

    DeltaT = T_layer{e}(ir, iz) - T_ref;
    alpha_val = alpha_node{e}(ir);

    % sigma_rr = -P_i
    F_M(row_sig) = -P_i + (C11 + C12 + C13) * alpha_val * DeltaT;

end


% ------------------------------------------------------------
% 3) Outer radial surface r = Ro
% sigma_rr = 0
%
% Apply on U-row for all z-points.
% ------------------------------------------------------------

e  = NL;
ir = N_r;

r_val = r_nodes{e}(ir);

E_val  = E_node{e}(ir);
nu_val = nu_node{e}(ir);

C11 = (1-nu_val)*E_val / ((1+nu_val)*(1-2*nu_val));
C12 = nu_val*E_val     / ((1+nu_val)*(1-2*nu_val));
C13 = C12;

for iz = 1:N_z

    row_sig = idx_U(e, ir, iz);

    K_M(row_sig, :) = 0;

    % sigma_rr = C11 du/dr + C12 u/r + C13 dw/dz - thermal
    % C11 du/dr
    for jr = 1:N_r
        col_u = idx_U(e, jr, iz);
        K_M(row_sig, col_u) = K_M(row_sig, col_u) + C11 * A_r{e}(ir, jr);
    end

    % C12 u/r
    col_u_center = idx_U(e, ir, iz);
    K_M(row_sig, col_u_center) = K_M(row_sig, col_u_center) + C12 / r_val;

    % C13 dw/dz
    for jz = 1:N_z
        col_w = idx_W(e, ir, jz);
        K_M(row_sig, col_w) = K_M(row_sig, col_w) + C13 * A_z(iz, jz);
    end

    DeltaT = T_layer{e}(ir, iz) - T_ref;
    alpha_val = alpha_node{e}(ir);

    % sigma_rr = 0
    F_M(row_sig) = (C11 + C12 + C13) * alpha_val * DeltaT;

end


% ------------------------------------------------------------
% 4) Inner and outer radial surfaces
% tau_rz = 0
%
% Apply only for internal z-points:
% iz = 2 : N_z-1
%
% Use W-row.
% ------------------------------------------------------------

for iz = 2:N_z-1

    % ========================================================
    % Inner surface r = Ri
    % ========================================================

    e  = 1;
    ir = 1;

    E_val  = E_node{e}(ir);
    nu_val = nu_node{e}(ir);
    C55 = E_val / (2*(1+nu_val));

    row_tau = idx_W(e, ir, iz);

    K_M(row_tau, :) = 0;
    F_M(row_tau) = 0;

    % tau_rz = C55 * (du/dz + dw/dr)

    % du/dz
    for jz = 1:N_z
        col_u = idx_U(e, ir, jz);
        K_M(row_tau, col_u) = K_M(row_tau, col_u) + C55 * A_z(iz, jz);
    end

    % dw/dr
    for jr = 1:N_r
        col_w = idx_W(e, jr, iz);
        K_M(row_tau, col_w) = K_M(row_tau, col_w) + C55 * A_r{e}(ir, jr);
    end


    % ========================================================
    % Outer surface r = Ro
    % ========================================================

    e  = NL;
    ir = N_r;

    E_val  = E_node{e}(ir);
    nu_val = nu_node{e}(ir);
    C55 = E_val / (2*(1+nu_val));

    row_tau = idx_W(e, ir, iz);

    K_M(row_tau, :) = 0;
    F_M(row_tau) = 0;

    % du/dz
    for jz = 1:N_z
        col_u = idx_U(e, ir, jz);
        K_M(row_tau, col_u) = K_M(row_tau, col_u) + C55 * A_z(iz, jz);
    end

    % dw/dr
    for jr = 1:N_r
        col_w = idx_W(e, jr, iz);
        K_M(row_tau, col_w) = K_M(row_tau, col_w) + C55 * A_r{e}(ir, jr);
    end

end


% ------------------------------------------------------------
% 5) Remove rigid body axial motion
%
% Important:
% Do NOT fix radial displacement u.
% Only fix one axial displacement w.
% ------------------------------------------------------------

e_fix  = 1;
ir_fix = round(N_r/2);
iz_fix = round(N_z/2);

row_fix = idx_W(e_fix, ir_fix, iz_fix);

K_M(row_fix, :) = 0;
K_M(row_fix, row_fix) = 1;
F_M(row_fix) = 0;

%% ============================================================
%  Scaling and solving mechanical system
%% ============================================================

disp('---------------------------------------------');
disp('Mechanical matrix check before scaling');

rank_K = rank(full(K_M));
size_K = size(K_M,1);
zero_rows = find(all(abs(K_M) < 1e-14, 2));

disp(['Rank of full(K_M): ', num2str(rank_K)]);
disp(['Size of K_M: ', num2str(size_K)]);
disp(['Number of zero rows: ', num2str(length(zero_rows))]);

try
    cond_K = condest(K_M);
    disp(['Condition number estimate of K_M: ', num2str(cond_K)]);
catch
    disp('condest failed for K_M.');
end

% Row scaling
rowNorm = full(max(abs(K_M), [], 2));
rowNorm(rowNorm == 0) = 1;

S = spdiags(1 ./ rowNorm, 0, size(K_M,1), size(K_M,1));

K_scaled = S * K_M;
F_scaled = S * F_M;

disp('---------------------------------------------');
disp('Mechanical matrix check after scaling');

rank_Ks = rank(full(K_scaled));
zero_rows_s = find(all(abs(K_scaled) < 1e-14, 2));

disp(['Rank of full(K_scaled): ', num2str(rank_Ks)]);
disp(['Size of K_scaled: ', num2str(size(K_scaled,1))]);
disp(['Number of zero rows scaled: ', num2str(length(zero_rows_s))]);

try
    cond_Ks = condest(K_scaled);
    disp(['Condition number estimate of K_scaled: ', num2str(cond_Ks)]);
catch
    disp('condest failed for K_scaled.');
end

disp('---------------------------------------------');

if rank_Ks < size(K_scaled,1)
    warning('K_scaled is still rank deficient. Check boundary conditions.');
end

% Solve
U_global = K_scaled \ F_scaled;

%% ========================= 7. COMPUTATION OF STRESSES =========================
% Radial (rr), circumferential (θθ), axial (zz) and shear (rz) stresses
Stress_rr = cell(NL,1);
Stress_tt = cell(NL,1);
Stress_zz = cell(NL,1);
Tau_rz = cell(NL,1);

%% ============================================================
%  Extract U and W fields from global solution vector
%% ============================================================

U_layer = cell(NL,1);
W_layer = cell(NL,1);

for e = 1:NL

    Ue = zeros(N_r, N_z);
    We = zeros(N_r, N_z);

    for ir = 1:N_r
        for iz = 1:N_z

            Ue(ir, iz) = U_global(idx_U(e, ir, iz));
            We(ir, iz) = U_global(idx_W(e, ir, iz));

        end
    end

    U_layer{e} = Ue;
    W_layer{e} = We;

end

for e = 1:NL
    N_r_local = N_r;
    Stress_rr{e} = zeros(N_r_local, N_z);
    Stress_tt{e} = zeros(N_r_local, N_z);
    Stress_zz{e} = zeros(N_r_local, N_z);
    Tau_rz{e} = zeros(N_r_local, N_z);
    for ir = 1:N_r_local
        r_val = r_nodes{e}(ir);
        E_val = E_node{e}(ir);
        nu_val = nu_node{e}(ir);
        C11 = (1-nu_val)*E_val / ((1+nu_val)*(1-2*nu_val));
        C12 = nu_val*E_val / ((1+nu_val)*(1-2*nu_val));
        C13 = C12;
        C33 = C11;
        C55 = E_val / (2*(1+nu_val));
        for iz = 1:N_z
            % displacement derivatives
            du_dr = 0; dw_dr = 0; du_dz = 0; dw_dz = 0;
            for jr = 1:N_r_local
                du_dr = du_dr + A_r{e}(ir, jr) * U_layer{e}(jr, iz);
                dw_dr = dw_dr + A_r{e}(ir, jr) * W_layer{e}(jr, iz);
            end
            for jz = 1:N_z
                du_dz = du_dz + A_z(iz, jz) * U_layer{e}(ir, jz);
                dw_dz = dw_dz + A_z(iz, jz) * W_layer{e}(ir, jz);
            end
            eps_rr = du_dr;
            eps_tt = U_layer{e}(ir, iz) / r_val;
            eps_zz = dw_dz;
            gamma_rz = du_dz + dw_dr;
            eps_th = alpha_node{e}(ir) * (T_layer{e}(ir, iz) - T_ref);
            % stresses
            Stress_rr{e}(ir, iz) = C11*(eps_rr - eps_th) + C12*(eps_tt - eps_th) + C13*(eps_zz - eps_th);
            Stress_tt{e}(ir, iz) = C12*(eps_rr - eps_th) + C11*(eps_tt - eps_th) + C13*(eps_zz - eps_th);
            Stress_zz{e}(ir, iz) = C13*(eps_rr - eps_th) + C13*(eps_tt - eps_th) + C33*(eps_zz - eps_th);
            Tau_rz{e}(ir, iz) = C55 * gamma_rz;
        end
    end
end

%% ========================= 8. DISPLAY OF RESULTS (AT MID-LENGTH CROSS SECTION) =========================
z_mid = round(N_z/2);
figure('Name', 'Results at mid-length (z = L/2)');

for e = 1:NL
    r_plot = r_nodes{e};
    subplot(2,3,1);
    plot(r_plot, T_layer{e}(:,z_mid), 'o-', 'LineWidth', 1.5); hold on;
    xlabel('r (m)'); ylabel('Temperature (K)'); title('Temperature');
    
    subplot(2,3,2);
    plot(r_plot, U_layer{e}(:,z_mid)*1e6, 'o-', 'LineWidth', 1.5); hold on;
    xlabel('r (m)'); ylabel('U (μm)'); title('Radial displacement');
    
    subplot(2,3,3);
    plot(r_plot, W_layer{e}(:,z_mid)*1e6, 'o-', 'LineWidth', 1.5); hold on;
    xlabel('r (m)'); ylabel('W (μm)'); title('Axial displacement');
    
    subplot(2,3,4);
    plot(r_plot, Stress_rr{e}(:,z_mid)/1e6, 'o-', 'LineWidth', 1.5); hold on;
    xlabel('r (m)'); ylabel('\sigma_{rr} (MPa)'); title('Radial stress');
    
    subplot(2,3,5);
    plot(r_plot, Stress_tt{e}(:,z_mid)/1e6, 'o-', 'LineWidth', 1.5); hold on;
    xlabel('r (m)'); ylabel('\sigma_{\theta\theta} (MPa)'); title('Hoop stress');
    
    subplot(2,3,6);
    plot(r_plot, Tau_rz{e}(:,z_mid)/1e6, 'o-', 'LineWidth', 1.5); hold on;
    xlabel('r (m)'); ylabel('\tau_{rz} (MPa)'); title('Shear stress');
end
legend(arrayfun(@(x) sprintf('Layer %d',x), 1:NL, 'UniformOutput', false), 'Location', 'best');

disp('=== Layer-wise effective properties ===');
for e = 1:NL
    fprintf('Layer %d:\n', e);
    fprintf('  E range      = [%g, %g] Pa\n', min(E_node{e}), max(E_node{e}));
    fprintf('  nu range     = [%g, %g]\n', min(nu_node{e}), max(nu_node{e}));
    fprintf('  rho range    = [%g, %g] kg/m^3\n', min(rho_node{e}), max(rho_node{e}));
    fprintf('  k range      = [%g, %g] W/mK\n', min(k_node{e}), max(k_node{e}));
    fprintf('  alpha range  = [%g, %g] 1/K\n', min(alpha_node{e}), max(alpha_node{e}));
end

%% =========================  HELPER FUNCTIONS (AT END OF FILE) =========================

function x = chebyshev_grid(a, b, N)
% Generate Chebyshev points in interval [a, b]
    x = a + (b-a)/2 * (1 - cos(pi*(0:N-1)/(N-1)));
end

function [A, B] = DQ_weights(x)
    N = length(x);
    A = zeros(N,N);

    for i = 1:N
        for j = 1:N
            if i ~= j
                num = 1; 
                den = 1;
                for k = 1:N
                    if k ~= i && k ~= j
                        num = num * (x(i) - x(k));
                        den = den * (x(j) - x(k));
                    end
                end
                A(i,j) = num / (den * (x(j)-x(i)));
            end
        end
    end

    for i = 1:N
        A(i,i) = -sum(A(i,:));
    end

    % more stable second derivative
    B = A * A;
end