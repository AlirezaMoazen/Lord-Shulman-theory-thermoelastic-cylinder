function cfg = default_input(overrides)
%DEFAULT_INPUT  Complete input data set (thesis reference case, SI units).
%
%   cfg = default_input()            reference case
%   cfg = default_input(overrides)   reference case with fields replaced
%
%   overrides : struct whose fields are a subset of the fields below.
%               An unknown field name raises an error (typo protection).
%   If only gam is overridden, bet is set to (gam+0.5)^2/4.

%% ---- thermoelasticity theory -------------------------------------------
cfg.theory      = 'LS';       % 'FOURIER' | 'LS' | 'DPL' | 'GN3'
cfg.tau0        = 418;        % relaxation time tau_q (s); thesis tau* ~ 0.15
cfg.tau_T       = 0;          % DPL temperature-gradient lag (s)
cfg.k_star      = 1;          % GN3 conductivity-rate constant (W/m/K/s)
cfg.coupling_on = true;       % thermoelastic coupling term in the energy equation

%% ---- geometry and mesh -------------------------------------------------
cfg.NL  = 7;                  % number of layers
cfg.R_i = 1.0;                % inner radius (m)
cfg.R_o = 1.5;                % outer radius (m)
cfg.L   = 2.1;                % length (m)
cfg.N_r = 15;                 % radial DQ points per layer
cfg.N_z = 11;                 % axial DQ points

%% ---- GPL and porosity --------------------------------------------------
cfg.material_mode     = 'GPL';  % 'GPL' | 'FG_powerlaw'
cfg.GPL_pattern       = 'UD';   % 'UD' | 'O' | 'X' | 'V' | 'A'
cfg.porosity_on       = true;
cfg.porosity_pattern  = 'UD';   % 'UD' | 'O' | 'X' | 'V' | 'A'
cfg.W_GPL_total       = 0.003;  % total GPL mass fraction
cfg.em3               = 0.8980; % mass-side UD porosity coefficient (e3 = em3^2)
cfg.a_GPL = 2.5e-6;             % GPL half-length a (m)
cfg.b_GPL = 1.5e-6;             % GPL half-width b (m)
cfg.t_GPL = 1.5e-9;             % GPL thickness t (m)

%% ---- constituent properties --------------------------------------------
cfg.E_GPL = 1.01e12;  cfg.rho_GPL = 1062.5;  cfg.c_GPL = 644;
cfg.alpha_GPL = 5e-6; cfg.k_GPL = 3000;      cfg.nu_GPL = 0.186;
cfg.E_m = 3.0e9;      cfg.nu_m = 0.34;       cfg.rho_m = 1200;
cfg.c_m = 1110;       cfg.alpha_m = 60e-6;   cfg.k_m = 0.246;
cfg.gamma_conn = 0.5;           % conductivity network exponent

%% ---- FG power-law mode (material_mode = 'FG_powerlaw') -----------------
cfg.FG_E_i   = 223e9;  cfg.FG_nE   = 2;       % E at R_i, exponent
cfg.FG_rho_i = 8900;   cfg.FG_nrho = -5.93;   % rho at R_i, exponent
cfg.FG_nu    = 0.3;
cfg.FG_k     = 10;     cfg.FG_c    = 500;
cfg.FG_alpha = 0;

%% ---- boundary and loading conditions ------------------------------------
cfg.BC_z       = 'S';         % end support: 'S' simply | 'F' free | 'C' clamped | 'R' roller
cfg.BC_z0      = '';          % override at z = 0  ('' -> BC_z)
cfg.BC_zL      = '';          % override at z = L  ('' -> BC_z)
cfg.T_BC_in    = 'dirichlet'; % inner thermal BC: 'dirichlet' | 'flux'
cfg.T_in_mode  = 'ramp';      % dirichlet shape: 'ramp' | 'gauss'
cfg.t_g0       = 10;          % Gaussian pulse centre time (s)
cfg.sig_g      = 3;           % Gaussian pulse standard deviation (s)
cfg.q_in_fun   = @(t) 0;      % inner heat flux q(t) (W/m^2), used when T_BC_in = 'flux'
cfg.T_BC_out   = 'convection';% outer thermal BC: 'convection' | 'dirichlet0'
cfg.Mech_BC_in = 'pressure';  % inner mechanical BC: 'pressure' | 'fixed'
cfg.P_time_mode = 'step';     % pressure time shape: 'step' | 'sine'
cfg.t0_P       = 1.0;         % period parameter for 'sine': P = P_i*sin(pi*t/t0_P)

cfg.T_ref    = 300;           % reference / initial temperature (K)
cfg.T_inf    = 300;           % ambient temperature at the outer surface (K)
cfg.h_c      = 10;            % convection coefficient (W/m^2/K)
cfg.T_in_val = 600;           % final inner-surface temperature (K)
cfg.t0_ramp  = 2;             % ramp time constant (s)
cfg.P_i      = 50e6;          % internal pressure (Pa)

%% ---- time integration (Newmark) ------------------------------------------
cfg.total_time = 3000;        % total time (s)
cfg.dt         = 1;           % time step (s)
cfg.gam        = 0.5;         % Newmark gamma (> 0.5 adds numerical damping)
cfg.bet        = 0.25;        % Newmark beta

%% ---- run control ---------------------------------------------------------
cfg.store_full_history = false; % true: keep x at every step (res.X_hist)
cfg.verbose            = true;  % print progress to the command window

%% ---- apply overrides -----------------------------------------------------
if nargin > 0 && ~isempty(overrides)
    fn = fieldnames(overrides);
    for i = 1:numel(fn)
        if ~isfield(cfg, fn{i})
            error('default_input:unknownField', ...
                'Unknown input field "%s" (check spelling).', fn{i});
        end
        cfg.(fn{i}) = overrides.(fn{i});
    end
    if isfield(overrides,'gam') && ~isfield(overrides,'bet')
        cfg.bet = (cfg.gam + 0.5)^2 / 4;
    end
end
end
