%% ========================================================================
%  LSTE_solver_R9.m  —  DYNAMIC THERMOELASTIC ANALYSIS (MULTI-THEORY)  [PERFORMANCE REVISION]
%  Multilayer porous GPL-reinforced cylinder, layerwise DQM + Newmark (beta)
%  ------------------------------------------------------------------------
%  REVISION R9 (performance only, additive on frozen R8):
%   PHYSICS AND EVERY OUTPUT ARE UNCHANGED FROM R8. The ONLY thing that
%   changed is section 4.1 (interior PDE assembly) and one line in section 5
%   (row equilibration) — pure performance work, no new features, no changed
%   defaults, no changed formulas.
%
%   WHAT CHANGED — section 4.1 (interior PDE rows):
%   R8 wrote into the sparse K/C/M matrices with an individual scalar
%   assignment per (jr) or (jr,jz) pair, e.g.
%       for jr = 1:N_r
%           K(eqU,idx_U(e,jr,iz)) = K(eqU,idx_U(e,jr,iz)) - C11(e)*B_r{e}(ir,jr);
%       end
%   Each of those is a separate sparse-matrix indexed write, and MATLAB's
%   sparse (CSC) format makes scalar-at-a-time indexed writes expensive —
%   this loop runs Ndof-many times (NL*N_r*N_z = 1155 nodes at the thesis
%   mesh), each doing on the order of a hundred such scalar writes.
%   R9 replaces every one of those inner loops with a SINGLE vectorized
%   row-assignment, using the fact that A_r{e}(ir,:) and A_z(iz,:) are
%   already the full coefficient rows needed for every jr / jz at once:
%       cols = idx_U(e,1:N_r,iz);                       % vector of columns
%       K(eqU,cols) = K(eqU,cols) - C11(e)*B_r{e}(ir,:); % one indexed write
%   Double loops (jr AND jz together, e.g. the u/w elastic-coupling block)
%   are collapsed the same way using kron(): for a FIXED layer e, the W (or
%   U) field's columns for ALL (jr,jz) combinations form one CONTIGUOUS
%   index range (because idx_*(e,jr,jz) = base + (jr-1)*N_z + jz), and
%   kron(A_r{e}(ir,:), A_z(iz,:)) produces exactly the (jr-major, jz-minor)
%   flattened outer product A_r{e}(ir,jr)*A_z(iz,jz) needed to fill that
%   whole range in one call. This is mathematically the SAME set of
%   additions to the SAME matrix cells as R8 — just batched into fewer,
%   larger sparse-indexing calls instead of many scalar ones — so results
%   are expected to be numerically identical to R8 (not merely close).
%   The three theory-branch conditions that R8 re-evaluated on every one of
%   the 1155 loop iterations (strcmpi(theory,'GN3'), the DPL tau_T check,
%   LSDPL_on) are now evaluated ONCE before the loop into plain booleans
%   (isGN3, dplActive, LSDPL_on) and just tested inside the loop — same
%   logic, no repeated string comparison.
%
%   WHAT CHANGED — section 5 (row equilibration):
%   R8 computed s_row via
%       s_row = full(max(abs([K, a0*M, a1*C]), [], 2));
%   which concatenates K, a0*M, a1*C into one Ndof x 3*Ndof matrix and
%   converts THAT to a dense (full) matrix just to take a row-max — 3x more
%   peak memory than necessary, and it would become a real problem at a
%   much larger mesh than the thesis reference case. R9 takes the row-max
%   of each matrix separately (each full() call only materializes one
%   Ndof x Ndof matrix) and combines the three results — same s_row values,
%   1/3 the peak memory.
%
%   WHAT DID NOT CHANGE: sections 0-3 (configuration, geometry, material
%   properties), section 4.2 (every boundary condition and interface row —
%   copied verbatim from R8, byte-for-byte), section 6 (Newmark time
%   integration), section 7 (post-processing), the helper functions. The
%   cfg-override mechanism, all defaults, and out_name are the only other
%   difference (out_name updated to reflect R9; was a stale 'R5' string
%   left over in R8's config block).
%
%   VALIDATION (2026-08-06): LSTE_solver_R9_compare.m diffed R8 vs R9 output
%   field-by-field (hist_T/U/W, r_all/T_all/U_all, S_rr/S_tt/S_zz, x_inf)
%   across 5 configurations -- default (LS, thesis mesh), FOURIER, DPL
%   (tau_T>0), GN3, and a different mesh size (NL=5,N_r=9,N_z=9) -- and on
%   the FULL 3000-step thesis reference case. Every field matched to
%   floating-point roundoff (relative differences ~1e-9 to 1e-16; the only
%   larger relative numbers were for hist_W, which is ~0 by symmetry, so
%   the ratio is noise/noise -- the absolute difference there was ~1e-11).
%   LSTE_solver_R9_check_benchmark1.m independently re-ran literature benchmark
%   1 (Malekzadeh & Heydarpour, IJPVP 98 (2012) Table 6) through R9 and
%   reproduced the same documented accuracy (U* within 0.1-0.2%, sigma_rr
%   exact) as the original solver -- not just self-consistency with R8.
%   Timing (sequential, uncontended, full 3000-step reference case):
%   R8 = 1039.1 s total (899.9 s assembly+setup, 139.2 s Newmark loop);
%   R9 =  495.2 s total (364.4 s assembly+setup, 130.9 s Newmark loop) --
%   about 2.1x faster overall, 2.5x faster on assembly+setup specifically.
%  ========================================================================
%  ------------------------------------------------------------------------
%  (Everything below this line is R8's own header, unchanged, for context.)
%  ------------------------------------------------------------------------
%  REVISION R8 — FINAL / DEFINITIVE REVISION (the code the thesis and all
%  Chapter-4 results are based on). Consolidates revisions R1..R7.
%   * PHYSICS DIGIT-IDENTICAL to R7 (hence to R6): solver logic, matrix
%     assembly and the Newmark march are byte-for-byte unchanged. ONLY the
%     default model configuration was changed — set to the THESIS REFERENCE
%     CASE so a standalone run reproduces the thesis reference results (R7
%     defaulted to a small test geometry that had to be supplied via cfg).
%   * Reference-case defaults: theory='LS', N_L=7, R_i=1.0, R_o=1.5, L=2.1 m,
%     N_r=15, N_z=11, W_GPL=0.3%, h_c=10 W/m^2K, T_in 300->600 K (t0=2 s),
%     P_i=50 MPa, tau0=418 s (tau*~0.15), total_time=3000 s, dt=1 s.
%   * POROSITY PATTERNS left exactly as R7 and MARKED for the author to
%     finalize against the MZ reference file (see section 0). No porosity
%     equation or coefficient was modified in R8.
%  ------------------------------------------------------------------------
%  REVISION R7 (additive, on frozen R6 -- supervisor review Prom.2 page 4):
%   EXPLICIT DOF NUMBERING / MAPPING MATRICES. Adds, right after the DOF index
%   functions, three inspectable objects that document the assembly ordering
%   WITHOUT changing any physics (K, C, M, the solve and every saved result are
%   digit-identical to R6):
%     * NodeMap(ir,iz)  -- rectangular (N_r x N_z) grid node-numbering matrix.
%     * DOFmap(g,:) = [gdof comp e ir iz localnode r z] -- one row per global
%       DOF, in the exact order the equations use (theta|u|w field blocks).
%     * GridDOF(e,ir,iz,:) = [theta u w] global DOFs at each grid point.
%   All three are saved into the .mat; DOFmap is also written as <out>_DOFmap.csv
%   for the code documentation. (Answers Prom.2 p.4: rectangular stiffness/mass
%   organisation + a DOF numbering/mapping matrix in equation order.)
%  ------------------------------------------------------------------------
%  REVISION R6 (additive, on verified R5 -- supervisor review Prom 3-7):
%   (1) PER-END mechanical supports: BC_z0 (z=0) and BC_zL (z=L). Empty ->
%       fall back to BC_z, so all previous single-BC runs are byte-identical.
%       Enables the mixed case (one end simply supported, the other clamped).
%   (2) GPL platelet dimensions a_GPL,b_GPL,t_GPL moved into the config block
%       (before the cfg override) so the aspect-ratio study can set them via
%       cfg. Defaults identical to R5 -> UD regression unchanged.
%  ....................................................................
%  REVISION R5 (additive): GENERALIZED THERMOELASTICITY THEORY SWITCH
%   theory = 'FOURIER' : classical coupled (parabolic heat conduction)
%            'LS'      : Lord-Shulman, one relaxation time tau0   (default)
%            'DPL'     : dual-phase-lag, lags tau_q (=tau0) and tau_T:
%                        rho*c*(th'+tau_q*th'') + beta*T0*(e'+tau_q*e'')
%                          = div(k grad th) + tau_T * div(k grad th')
%                        (LS is DPL with tau_T = 0)
%            'GN3'     : Green-Naghdi type III (energy dissipation):
%                        rho*c*th'' + beta*T0*e''
%                          = k_star*div(grad th) + k*div(grad th')
%   Back-compat: cfg.LS_enabled=false maps to theory='FOURIER'.
%   Regression: default (theory='LS') is digit-identical to LSTE_solver_R4.
%  ------------------------------------------------------------------------
%  REVISION R4 (additive): generalized inner-surface thermal loading
%   (+) T_in_mode 'ramp' (default, R3_1 behavior)
%                 'gauss': Gaussian thermal pulse
%                   theta_in(t) = (T_in_val - T_ref) * exp(-(t-t_g0)^2/(2*sig_g^2))
%       (novelty loading: Gaussian shock + LS + porous GPL cylinder)
%  ------------------------------------------------------------------------
%  REVISION R3_1 — POROSITY PATTERNS FINALIZED (per the author's porosity
%  document, Google Doc 2026-07-20, which confirms:)
%   * centered coordinate  zeta = (r - r_mid)/l  in [-1/2, +1/2]
%   * PRIMARY = mass-side factors P_m with exact conservation:
%       UD: P_m = em3
%       O : P_m = 1 - em1*cos(pi*zeta),          em1 = (pi/2)(1-em3)
%       X : P_m = 1 - em2*(1-cos(pi*zeta)),      em2 = (1-em3)/(1-2/pi)
%       V : P_m = 2*em4*cos(pi*zeta/2 + pi/4),   em4 = (pi/4)*em3  (max INNER)
%       A : P_m = 2*em5*cos(pi*zeta/2 - pi/4),   em5 = em4         (max OUTER)
%   * E-side factor pointwise:  P_E = P_m^2   (E/Es = (rho/rhos)^2)
%     (tabulated e1..e5 are equivalent-integral reporting values;
%      e3 = em3^2 and e4 = e5 = (pi/2)*em4^2 hold exactly)
%   * k and c scale with P_E; rho with P_m; alpha, nu unchanged
%   * V/A shapes are mirrors; asymmetric thermal loading distinguishes them
%   * P_m is clipped to <= 1 where the V/A shape exceeds 1 near its peak
%  Input: user sets em3 (preferred) or e3 (converted em3 = sqrt(e3)).
%  Verified against the author's tables by claude_porosity_check_R3_1.m
%  ------------------------------------------------------------------------
%  REVISION R3 (new features, additive only — R2_1 logic unchanged):
%   (+) T_BC_in  'dirichlet' (default) | 'flux'  : inner thermal BC can be a
%       prescribed heat flux  -k dT/dr = q_in_fun(t)  (Bagri-Eslami benchmark)
%   (+) T_BC_out 'convection' (default) | 'dirichlet0' : outer T = T_ref
%   (+) Mech_BC_in 'pressure' (default) | 'fixed' : inner surface u = 0
%   (+) BC_z 'R' : roller / plane-strain ends (w = 0, tau_rz = 0) — needed
%       to reproduce 1-D plane-strain radial benchmarks in the 2-D solver
%   Purpose: run the Lord-Shulman coupled-cylinder benchmark of
%   Bagri & Eslami, Int. J. Mech. Sci. 49 (2007) 1325, sec. 4.1, Figs 2-4.
%  ------------------------------------------------------------------------
%  REVISION HISTORY
%   R1   : corrected solver, verified (static-limit 2e-11, IJPVP Table 6,
%          exact conduction benchmark, LS wave demo).
%   R2   : + material_mode 'FG_powerlaw', P_time_mode 'sine',
%          store_full_history, cfg geometry rebuild, Newmark CPU timer,
%          V/A porosity phase updated per thesis R0.1 (still provisional).
%   R2_1 : line-by-line audit fixes (2026-07-19, user approved):
%          - e1/e2 corrected to the MZ-R 0.docx table row for e3=0.8064
%            (e1: 0.3 -> 0.3100, e2: 0.5103 -> 0.5123)
%          - cfg override now warns about unknown (misspelled) field names
%          - porosity-pattern uncertainty warning extended to O/X (the
%            coordinate convention does not reproduce the MZ mass table;
%            centered version does — PENDING source-paper verification;
%            only UD is fully confirmed)
%          - single warning per run instead of one per layer
%          - final sigma_rr printout uses P(t_end) in 'sine' pressure mode
%  PENDING DECISIONS (do not use in thesis until resolved):
%   * O/X/V/A porosity formulas — verify against source paper + MZ tables
%   * thesis loading values: h_c (10 vs 100), T_in (250 vs 500), t0_ramp, tau0
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
LS_enabled = true;          % legacy switch (kept for old drivers; see theory)
tau0       = 418;           % relaxation time tau_q (s): thesis reference tau* ~ 0.15
coupling_on = true;         % thermoelastic coupling term in the energy eq.

% --- (R5 addition) thermoelasticity theory selector ----------------------
theory = 'LS';              % 'FOURIER' | 'LS' | 'DPL' | 'GN3'
tau_T  = 0;                 % DPL temperature-gradient lag (s)
k_star = 1;                 % GN3 conductivity-rate constant k* (W/m/K/s)

% Mechanical support at z = 0 and z = L :
%   'S' simply, 'F' free, 'C' clamped, 'R' roller/plane-strain (R3 addition)
BC_z = 'S';
% (R6 addition) per-end override: leave '' to use BC_z at that end, or set to
% 'S'/'F'/'C'/'R' for an asymmetric (mixed) support, e.g. BC_z0='S', BC_zL='C'.
BC_z0 = '';                 % support at z = 0   ('' -> BC_z)
BC_zL = '';                 % support at z = L   ('' -> BC_z)

% (R6 addition) GPL platelet dimensions moved here (were below section 3) so
% the aspect-ratio study can override them via cfg. length 2a, width 2b,
% thickness t -> Halpin-Tsai xiL = 2a/t, xiT = 2b/t.
a_GPL = 2.5e-6;  b_GPL = 1.5e-6;  t_GPL = 1.5e-9;

% --- (R3 addition) boundary-condition type selectors ---------------------
T_BC_in    = 'dirichlet';   % 'dirichlet': theta = ramp(t) | 'flux': -k dT/dr = q_in_fun(t)
% (R4 addition) inner-temperature time shape when T_BC_in='dirichlet':
T_in_mode  = 'ramp';        % 'ramp' (default) | 'gauss' (Gaussian pulse)
t_g0       = 10;            % Gaussian pulse center time (s)
sig_g      = 3;             % Gaussian pulse standard deviation (s)
T_BC_out   = 'convection';  % 'convection' | 'dirichlet0' (theta = 0)
Mech_BC_in = 'pressure';    % 'pressure': sigma_rr = -P(t) | 'fixed': u = 0
q_in_fun   = @(t) 0;        % inner heat-flux time function (used when T_BC_in='flux')

% GPL and porosity patterns.
% NOTE: only 'UD' is fully confirmed against the spec (MZ-R 0.docx evaluates
% patterns at layer mid-radius -> piecewise-constant properties). The other
% patterns are implemented from the docx formulas but must be verified
% against the reference paper before production runs.
GPL_pattern      = 'UD';    % 'UD','O','X','V','A'
porosity_on      = true;
porosity_pattern = 'UD';    % 'UD','O','X','V','A'
W_GPL_total = 0.003;        % total GPL mass fraction (thesis reference 0.3%)
% >>> A7 — AUTHOR TO FINALIZE: the porosity-pattern equations (section for
%     P_m below) and em3 are left EXACTLY as R7, pending correction against
%     the MZ reference file. The porosity distribution is NOT final until
%     that update; no porosity equation/coefficient was changed in R8/R9. <<<
% (R3_1) porosity level: set em3 (mass-side, primary). All other pattern
% coefficients are DERIVED exactly (see header). e3 = em3^2.
em3  = 0.8980;              % mass-side UD coefficient  ->  e3 = 0.8064
e3   = em3^2;               % kept for output/reporting

% --- (R2 addition) material mode -----------------------------------------
% 'GPL'         : GPL + porosity model from the docx spec (LSTE_solver_R1 behavior)
% 'FG_powerlaw' : P(r) = P_i_val*(r/R_i)^n, evaluated at layer mid-radius
material_mode = 'GPL';
FG_E_i   = 223e9;   FG_nE   = 2;       % E at inner radius, exponent
FG_rho_i = 8900;    FG_nrho = -5.93;   % rho at inner radius, exponent
FG_nu    = 0.3;                        % constant Poisson ratio
FG_k     = 10;      FG_c    = 500;     % conductivity / heat capacity (unused if isothermal)
FG_alpha = 0;                          % thermal expansion (0 -> pure mechanics)

% --- (R2 addition) pressure time function --------------------------------
P_time_mode = 'step';       % 'step' (LSTE_solver_R1 behavior) or 'sine'
t0_P        = 1.0;          % period parameter for 'sine': P(t)=P_i*sin(pi*t/t0_P)

% --- (R2 addition) full time-history storage -----------------------------
store_full_history = false; % true: save x at every step in X_hist (Ndof x Nt+1)

%% ========================= 1. Geometry and discretization =========================
NL  = 7;                    % number of layers (thesis reference)
R_i = 1.0;                  % inner radius (m) (thesis reference)
R_o = 1.5;                  % outer radius (m) (thesis reference)
L   = 2.1;                  % cylinder length (m) (thesis reference)
N_r = 15;                   % radial DQ points per layer (locked mesh)
N_z = 11;                   % axial DQ points (locked mesh)

% NOTE (R2_1): this first grid build is only used when the script runs with
% no cfg overrides; if cfg overrides geometry, everything below is rebuilt
% after the override block in section 2. Kept for standalone-run clarity.
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
h_c      = 10;              % convection coefficient (W/m^2K) (thesis reference)
T_in_val = 600;             % final inner surface temperature (K): 300 -> 600
t0_ramp  = 2;               % ramp time constant (s) (thesis reference)
P_i      = 50e6;            % internal pressure (Pa) = 50 MPa (thesis reference)

total_time = 3000;          % total simulation time (s) (thesis reference)
dt         = 1;             % time step (s) (thesis reference)

% Newmark parameters (gam > 0.5 adds numerical damping, useful for
% verification runs that must settle to the static solution)
gam = 0.5;  bet = 0.25;
out_name = 'Results_LSTE_solver_R9.mat';    % output file for saved results
% NOTE (R5/GN3): thermal boundary rows keep the standard -k*dth/dr flux form;
% for GN3 this is an approximation of its rate-type flux (documented choice).

% ---- optional overrides from workspace struct `cfg` (for batch testing) ----
if exist('cfg','var') && isstruct(cfg)
    fn = fieldnames(cfg);
    for iov = 1:numel(fn)
        % (R2_1 fix) typo protection: warn if the cfg field does not match
        % any existing configuration variable (a misspelled field would
        % otherwise be silently ignored by the solver)
        if ~exist(fn{iov}, 'var')
            warning('LSTE_solver_R2_1:unknownCfgField', ...
                'cfg field "%s" does not match any configuration variable — check spelling!', fn{iov});
        end
        eval([fn{iov} ' = cfg.(fn{iov});']);   %#ok<EVLDOT>
    end
    if any(strcmp(fn,'gam')) && ~any(strcmp(fn,'bet'))
        bet = (gam + 0.5)^2 / 4;               % consistent dissipative pair
    end
    % (R5) legacy mapping: cfg.LS_enabled=false without explicit cfg.theory
    % selects the classical coupled (Fourier) theory
    if ~any(strcmp(fn,'theory')) && any(strcmp(fn,'LS_enabled')) && ~LS_enabled
        theory = 'FOURIER';
    end
end
% (R5) tau_q (=tau0) terms are active for LS and DPL
LSDPL_on = strcmpi(theory,'LS') || strcmpi(theory,'DPL');
Nt = round(total_time/dt);

% (R2 addition) rebuild geometry-dependent grids and DQ weights, because
% section 1 ran BEFORE the cfg overrides — without this, overriding NL,
% N_r, N_z, R_i, R_o or L via cfg leaves stale grids/weight matrices.
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

%% ========================= 3. Material properties (per layer, docx style) ========
% GPL
% (R6) a_GPL,b_GPL,t_GPL now set in the config block above (cfg-overridable);
% the previous hardcoded assignment here is removed so cfg values survive.
E_GPL = 1.01e12; rho_GPL = 1062.5; c_GPL = 644;
alpha_GPL = 5e-6; k_GPL = 3000;  nu_GPL = 0.186;
% Matrix (epoxy)
E_m = 3.0e9;  nu_m = 0.34;  rho_m = 1200;
c_m = 1110;   alpha_m = 60e-6;  k_m = 0.246;
gamma_conn = 0.5;           % docx: gamma = 1/2

E_L_  = zeros(NL,1); nu_L_ = zeros(NL,1); rho_L = zeros(NL,1);
c_L   = zeros(NL,1); k_L   = zeros(NL,1); al_L  = zeros(NL,1);

% (R3_1) porosity coefficients — derived EXACTLY from em3 per the author's
% porosity document (all patterns confirmed; warnings removed):
em1 = (pi/2)*(1 - em3);
em2 = (1 - em3)/(1 - 2/pi);
em4 = (pi/4)*em3;
em5 = em4;
% reporting values (equivalent-integral convention of the document):
e1_rep = NaN;  e2_rep = NaN;          % descriptive only (not used)
e4 = (pi/2)*em4^2;  e5 = e4;          % exact document relations

for e = 1:NL
    % --- (R2 addition) FG power-law mode: bypass the GPL model entirely ---
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

    % --- (R3_1) porosity factors at layer mid-radius, CENTERED coordinate ---
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
        Pm = max(0, min(1, Pm));      % physical clip (document V/A peak > 1)
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

%% ---- (R7, Prom.2 p.4) EXPLICIT DOF NUMBERING / MAPPING MATRICES ----------
%  The DOFs above are numbered FIELD-MAJOR: theta -> [1..Nn], u -> [Nn+1..2Nn],
%  w -> [2Nn+1..3Nn]. Within each field the node order is (e, ir, iz) with the
%  axial index iz fastest, then radial ir, then layer e. The objects below make
%  that numbering EXPLICIT and inspectable (supervisor's page-4 note), in exactly
%  the same order the K/C/M equations use -- they add NO physics and change no
%  result (K, C, M, the solve and every output are identical to LSTE_solver_R6).
%
%  (1) NodeMap : rectangular (N_r x N_z) grid-numbering matrix for one layer;
%      NodeMap(ir,iz) = local node index 1..N_r*N_z  (axial index iz fastest).
NodeMap = reshape(1:N_r*N_z, N_z, N_r).';       % (ir,iz) -> (ir-1)*N_z + iz
%
%  (2) DOFmap : one row per global DOF, in equation order. Columns:
%      [ gdof | comp(1=theta,2=u,3=w) | e | ir | iz | localnode | r | z ]
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
%
%  (3) GridDOF : grid view -- the three global DOFs [theta u w] at each point.
GridDOF = zeros(NL, N_r, N_z, 3);
for e = 1:NL
    for ir = 1:N_r
        for iz = 1:N_z
            GridDOF(e,ir,iz,:) = [idx_Th(e,ir,iz), idx_U(e,ir,iz), idx_W(e,ir,iz)];
        end
    end
end
fprintf('(R7) DOF map: Ndof=%d = 3 x %d nodes; NodeMap %dx%d; blocks theta|u|w.\n',...
        Ndof, Nn, N_r, N_z);
%% -------------------------------------------------------------------------

K = sparse(Ndof,Ndof);
C = sparse(Ndof,Ndof);
M = sparse(Ndof,Ndof);

% ------------------- 4.1 interior PDE rows (R9: VECTORIZED) -------------------
% Convention:  M x'' + C x' + K x = F,  K = -(natural spatial operator).
%
% Energy (Lord-Shulman), theta = T - T_ref :
%   rho*c*(th' + tau0*th'') + beta*T_ref*(e' + tau0*e'') - div(k grad th) = 0
%   with dilatation  e = du/dr + u/r + dw/dz
% Momentum:
%   rho*u'' - [elastic op]_r(u,w) + beta*alpha-part * d(th)/dr = 0
%   rho*w'' - [elastic op]_z(u,w) + beta * d(th)/dz            = 0
%
% (R9) Every "for jr=1:N_r" / "for jz=1:N_z" inner loop in R8 is replaced by
% ONE vectorized row-assignment, using A_r{e}(ir,:) / A_z(iz,:) (already the
% full coefficient row needed for every jr/jz at once) as the column vector
% of values, and idx_*(e,1:N_r,iz) / idx_*(e,ir,1:N_z) (vectorized index
% functions) as the matching column indices. Double loops (jr AND jz) are
% collapsed with kron(A_r{e}(ir,:), A_z(iz,:)), which produces exactly the
% (jr-major, jz-minor) flattened outer product needed to fill the whole
% (contiguous, for fixed e) column range in one indexed write. Same cells,
% same values, same accumulation -- just batched. Theory-branch booleans are
% evaluated once here instead of inside the 1155-iteration loop.
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

            % ===== energy equation row (R5: theory-dependent) =====
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
%  (R9: byte-for-byte copied from R8 -- unchanged. K, C, M are ordinary
%  sparse matrices at this point regardless of how section 4.1 built them,
%  so this section's K(n,:)=0; K(n,n)=...  idiom works identically.)
F0      = zeros(Ndof,1);       % constant part of RHS
rows_Tin  = zeros(N_z,1);      % rows carrying the inner temperature ramp
rows_Pin  = [];                % rows carrying the pressure step

% ---- (a) thermal: inner surface — Dirichlet ramp OR heat flux (R3) ----
for iz = 1:N_z
    n = idx_Th(1,1,iz);
    K(n,:)=0; C(n,:)=0; M(n,:)=0;
    if strcmpi(T_BC_in,'flux')
        % (R3 addition)  -k dtheta/dr = q_in_fun(t)  at r = R_i
        for jr = 1:N_r
            K(n, idx_Th(1,jr,iz)) = -k_L(1)*A_r{1}(1,jr);
        end
    else
        K(n,n)=1;               % theta = theta_in(t)  (F set in time loop)
    end
    rows_Tin(iz) = n;
end

% ---- (b) thermal: outer surface — convection OR theta = 0 (R3) ----
for iz = 1:N_z
    n = idx_Th(NL,N_r,iz);
    K(n,:)=0; C(n,:)=0; M(n,:)=0;
    if strcmpi(T_BC_out,'dirichlet0')
        K(n,n) = 1;  F0(n) = 0;         % (R3 addition) theta(R_o) = 0
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
%  R: tau_rz = 0 and w=0  (roller / plane strain, R3 addition)
for e = 1:NL
    for ir = 2:N_r-1                       % radial corners handled by r-faces
        r = r_nodes{e}(ir);
        for iz = [1, N_z]
            rU = idx_U(e,ir,iz);  rW = idx_W(e,ir,iz);
            bcE = BC_z;                                   % (R6) per-end support
            if iz==1  && ~isempty(BC_z0), bcE = BC_z0; end
            if iz==N_z && ~isempty(BC_zL), bcE = BC_zL; end
            switch upper(bcE)
                case 'R'                    % (R3) rollers: tau_rz=0, w=0
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
%  'pressure' (default): sigma_rr = -P_i(t)   |   'fixed' (R3): u = 0
e = 1; ir = 1; r = r_nodes{1}(1);
for iz = 1:N_z
    rU = idx_U(e,ir,iz);
    K(rU,:)=0; C(rU,:)=0; M(rU,:)=0;
    if strcmpi(Mech_BC_in,'fixed')
        K(rU,rU) = 1;                       % (R3 addition) u(R_i) = 0
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

% End-support rows for radial-face corner nodes of layer 1 inner / layer NL
% outer are already occupied by sigma_rr rows (f,g). For the interface corner
% nodes we now write the end support into the right-layer rows:
for e = 2:NL
    r2 = r_nodes{e}(1);
    for iz = [1, N_z]
        rU2 = idx_U(e,1,iz);  rW2 = idx_W(e,1,iz);
        bcE = BC_z;                                   % (R6) per-end support
        if iz==1  && ~isempty(BC_z0), bcE = BC_z0; end
        if iz==N_z && ~isempty(BC_zL), bcE = BC_zL; end
        switch upper(bcE)
            case 'R'                        % (R3) rollers at interface corners
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
% (R3) 'R'/'C' ends already fix w at the ends -> no pin needed
% (R6) with per-end supports, the pin is skipped if EITHER end is C or R
bc0 = BC_z; if ~isempty(BC_z0), bc0 = BC_z0; end
bcL = BC_z; if ~isempty(BC_zL), bcL = BC_zL; end
if ~any(ismember(upper({bc0, bcL}), {'C','R'}))
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

% (R9) same s_row values as R8, computed without ever forming a dense
% Ndof x 3*Ndof matrix: take each matrix's row-max separately (each full()
% call now only materializes one Ndof x Ndof matrix), then combine.
s_row = max([full(max(abs(K),[],2)), full(max(abs(a0*M),[],2)), full(max(abs(a1*C),[],2))], [], 2);
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
if strcmpi(T_BC_in,'flux')
    F_inf(rows_Tin) = q_in_fun(1e9).*rs_Tin;   % (R3) long-time flux value
elseif strcmpi(T_in_mode,'gauss')
    F_inf(rows_Tin) = 0;                       % (R4) pulse ends -> theta_in=0
else
    F_inf(rows_Tin) = (T_in_val - T_ref).*rs_Tin;
end
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

% (R2 addition) full history storage
if store_full_history, X_hist = zeros(Ndof, Nt+1); end

snap_every = max(1,round(Nt/6));  snaps = {};  snap_t = [];

newmark_tic = tic;   % (R2 addition) CPU timing of the time-integration loop
for n = 1:Nt
    t = n*dt;
    % ----- RHS at t_{n+1} (row-scaled) -----
    F = F0;
    if strcmpi(T_in_mode,'gauss')        % (R4 addition) Gaussian pulse
        th_in = (T_in_val - T_ref)*exp(-(t-t_g0)^2/(2*sig_g^2));
    else
        th_in = (T_in_val - T_ref)*(1 - exp(-t/t0_ramp));
    end
    if strcmpi(T_BC_in,'flux')
        F(rows_Tin) = q_in_fun(t).*rs_Tin;   % (R3) prescribed inner heat flux
    else
        F(rows_Tin) = th_in.*rs_Tin;
    end
    % (R2 addition) pressure time function
    if strcmpi(P_time_mode, 'sine')
        P_now = P_i*sin(pi*t/t0_P);
    else
        P_now = P_i;                        % step (LSTE_solver_R1 behavior)
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
    if store_full_history, X_hist(:,n+1) = x; end   % (R2 addition)

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
newmark_cpu = toc(newmark_tic);  % (R2 addition)
fprintf('Newmark time-integration CPU: %.2f s (%d steps)\n', newmark_cpu, Nt);

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
% (R2_1 fix) compare against the pressure actually applied at t_end
if strcmpi(P_time_mode,'sine'), P_end = P_i*sin(pi*total_time/t0_P);
else,                           P_end = P_i; end
fprintf('sigma_rr at inner node : %.4e Pa  (target -P(t_end) = %.4e)\n', S_rr(1), -P_end);
fprintf('sigma_rr at outer node : %.4e Pa  (target 0)\n', S_rr(end));

save(out_name,'tv','hist_T','hist_U','hist_W','r_all','T_all','U_all', ...
     'S_rr','S_tt','S_zz','snaps','snap_t','x_inf','T_inf_prof','U_inf_prof', ...
     'NL','N_r','N_z','r_nodes','z_nodes', ...
     'NodeMap','DOFmap','GridDOF');           % (R7) explicit DOF-mapping artifacts
if store_full_history, save(out_name,'X_hist','-append'); end   % (R2 addition)
fprintf('Saved %s\n', out_name);

% (R7, Prom.2 p.4) export the DOF mapping matrix as a CSV for the code documentation
try
    dofcsv = strrep(out_name, '.mat', '_DOFmap.csv');
    fid = fopen(dofcsv,'w');
    fprintf(fid,'gdof,component,comp_name,layer_e,ir,iz,localnode,r,z\n');
    cn = {'theta','u','w'};
    for g = 1:Ndof
        rr = DOFmap(g,:);
        fprintf(fid,'%d,%d,%s,%d,%d,%d,%d,%.6g,%.6g\n', ...
            rr(1),rr(2),cn{rr(2)},rr(3),rr(4),rr(5),rr(6),rr(7),rr(8));
    end
    fclose(fid);
    fprintf('(R7) wrote DOF mapping matrix -> %s  (%d rows)\n', dofcsv, Ndof);
catch ME
    fprintf('(R7) DOF map CSV export skipped: %s\n', ME.message);
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
