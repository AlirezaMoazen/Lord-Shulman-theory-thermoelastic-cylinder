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

N=N_r;
M=N_z;

% thickness of each layer (equal assumed)
t_layer = (R_o - R_i) / NL;
R_boundaries = linspace(R_i, R_o, NL+1);   % interlayer boundaries

% axial points with Chebyshev distribution in [0, L]
z_nodes = chebyshev_grid(0, L, N_z);

% radial points in each layer (Chebyshev within each layer)
r_nodes = cell(NL, 1);
for e = 1:NL
    r_nodes{e} = chebyshev_grid(R_boundaries(e), R_boundaries(e+1), N_r)
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
P_i = 1*10e6;                 % internal pressure (Pa) (10 MPa)
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
            W_GPL_e = 4 * W_GPL_total * (mid - abs(e - mid)) / (NL + 2);
%             W_GPL_e = max(0, min(1, W_GPL_e));   % correction
        case 'X'
            mid = (NL+1)/2;
            W_GPL_e = 4 * W_GPL_total * (0.5 - abs(e - mid)) / (NL + 2);
%             W_GPL_e = min(1, W_GPL_e);           % correction
        case 'V'
            W_GPL_e = W_GPL_total * (2*e / (NL+1));
%             W_GPL_e = min(1, W_GPL_e);
        case 'A'
            W_GPL_e = W_GPL_total * (2*(NL+1-e) / (NL+1));
%             W_GPL_e = min(1, W_GPL_e);
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
    
    Factor_rho = sqrt(Factor_E);     % it's wrang
    Factor_k = Factor_E;
    Factor_c = Factor_E;
    
    E_node{e} = E_base * Factor_E;
    nu_node{e} = nu_base * ones(size(r_local));
    rho_node{e} = rho_base * Factor_rho;
    c_node{e} = c_base * Factor_c;
    k_node{e} = k_base * Factor_k;
    alpha_node{e} = alpha_base * ones(size(r_local));
end

%%


A_z_old=zeros(M);
B_z_old=zeros(M);
z=zeros(1,M);
 
      for i=1:M
        z(i)=0.5*(1-cos((i-1)*pi/(M-1))); %z1(i,1)=z(i); 
      end
       z;
      for i=1:M
         for j=1:M
              qi_z=1;qj_z=1;
            for k=1:M 
               if k~=i  
                  qi_z=(z(i)-z(k))*qi_z;
               end
               if k~=j  
                  qj_z=(z(j)-z(k))*qj_z;
               end   
            end
            if i~=j 
               A_z_old(i,j)=qi_z/((z(i)-z(j))*qj_z);
            end   
         end  
         for k=1:M  
             if k~=i
                A_z_old(i,i)=A_z_old(i,i)-A_z_old(i,k);
             end
         end   
      end
      A_z_old;
      for i=1:M
         for j=1:M
             B_z_old(i,j)=0;
         end  
      end      
      for i=1:M
         for j=1:M
            if i~=j
               B_z_old(i,j)=2*(A_z_old(i,i)*A_z_old(i,j)-(A_z_old(i,j)/(z(i)-z(j))));
            end   
         end      
         for k=1:M
            if i~=k
               B_z_old(i,i)=B_z_old(i,i)-B_z_old(i,k);
            end   
         end    
      end
      B_z_old;
      
%%
      A_new=abs(A_z)-abs(A_z_old)
      B_new=abs(B_z)-abs(B_z_old)


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


