%% LSTE_solver_R9_check_benchmark1.m — validation benchmark check against LSTE_solver_R9.
%  Runs LSTE_solver_R9 and confirms its vectorized assembly reproduces the
%  literature benchmark (Malekzadeh & Heydarpour, IJPVP 98 (2012) Table 6).
%  Writes to a separate out_name/outdir so it does not overwrite other
%  validation artifacts.
clearvars -except BENCH; clc; close all;
if ~exist('BENCH','var'), BENCH = struct('NL',10,'N_r',5,'N_z',13); end

cfg = struct( ...
    'material_mode','FG_powerlaw', ...
    'FG_E_i',223e9, 'FG_nE',2, 'FG_rho_i',8900, 'FG_nrho',-5.93, ...
    'FG_nu',0.3, 'FG_k',10, 'FG_c',500, 'FG_alpha',0, ...
    'LS_enabled',false, 'coupling_on',false, 'porosity_on',false, ...
    'BC_z','C', ...
    'NL',BENCH.NL, 'N_r',BENCH.N_r, 'N_z',BENCH.N_z, ...
    'R_i',0.08, 'R_o',0.1, 'L',1.0, ...
    'P_i',100e6, 'P_time_mode','sine', 't0_P',1.0, ...
    'T_in_val',300, ...
    'total_time',1.0, 'dt',5e-3, ...
    'store_full_history',true, ...
    'out_name',sprintf('R9check_bench1_NL%d_Nr%d.mat',BENCH.NL,BENCH.N_r));

LSTE_solver_R9;    % run the R9 solver (vectorized assembly)

%% ---------------------- extract benchmark quantities --------------------
P0     = 100e6;
k_star = 10e9;
h_th   = R_o - R_i;
iz0    = round(N_z/2);
r_in   = r_nodes{1}(1);

rows_u_rad = zeros(N_r,1);
for jr = 1:N_r, rows_u_rad(jr) = idx_U(1,jr,iz0); end
rows_w_ax  = zeros(N_z,1);
for jz = 1:N_z, rows_w_ax(jz) = idx_W(1,1,jz); end
row_u_in   = idx_U(1,1,iz0);

u_in   = X_hist(row_u_in, :).';
dudr_t = (A_r{1}(1,:) * X_hist(rows_u_rad, :)).';
dwdz_t = (A_z(iz0,:)  * X_hist(rows_w_ax, :)).';
eps_tt_t = u_in / r_in;

Srr_t = C11(1)*dudr_t + C12(1)*eps_tt_t + C13(1)*dwdz_t;
Stt_t = C12(1)*dudr_t + C11(1)*eps_tt_t + C13(1)*dwdz_t;
Szz_t = C13(1)*dudr_t + C13(1)*eps_tt_t + C33(1)*dwdz_t;

Ustar  = u_in * k_star/(P0*h_th);
SttS   = Stt_t / P0;
SzzS   = Szz_t / P0;
SrrS   = Srr_t / P0;
tstar  = tv / 1.0;

%% ------------------------- comparison table -----------------------------
ref_paper = [0.1  0.202  1.102  0.231  -0.309 ;
             0.3  0.530  2.885  0.596  -0.809 ;
             0.5  0.655  3.566  0.735  -1.000 ];
ref_ansys = [0.1  0.201  1.109  0.232  -0.296 ;
             0.3  0.525  2.903  0.606  -0.774 ;
             0.5  0.652  3.589  0.749  -0.956 ];

fprintf('\n========== BENCHMARK 1 re-check against LSTE_solver_R9 (vectorized) ==========\n');
fprintf('IJPVP 98 (2012) Table 6 -- FG cylinder, clamped ends, P(t)=P0*sin(pi*t)\n');
fprintf('Grid: NL=%d layers, N_r=%d, N_z=%d\n', NL, N_r, N_z);
fprintf('%-6s %-10s %10s %10s %10s %10s\n','t*','source','U*','S*_tt','S*_zz','S*_rr');
for k = 1:size(ref_paper,1)
    ts = ref_paper(k,1);
    [~,n_ts] = min(abs(tstar - ts));
    mine = [Ustar(n_ts) SttS(n_ts) SzzS(n_ts) SrrS(n_ts)];
    fprintf('%-6.2f %-10s %10.3f %10.3f %10.3f %10.3f\n', ts,'LSTE_solver_R9', mine);
    fprintf('%-6s %-10s %10.3f %10.3f %10.3f %10.3f\n','','Paper',  ref_paper(k,2:5));
    fprintf('%-6s %-10s %10.3f %10.3f %10.3f %10.3f\n','','ANSYS',  ref_ansys(k,2:5));
    err = abs(mine - ref_paper(k,2:5)) ./ max(abs(ref_paper(k,2:5)), eps) * 100;
    fprintf('%-6s %-10s %9.1f%% %9.1f%% %9.1f%% %9.1f%%\n','','diff-paper', err);
end
fprintf('\n(No figures/CSV written -- this is a numeric check only, not a\n');
fprintf(' replacement for the archived Validation/bench1_* artifacts.)\n');
