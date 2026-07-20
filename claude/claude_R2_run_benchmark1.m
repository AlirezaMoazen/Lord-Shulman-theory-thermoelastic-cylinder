%% ========================================================================
%  claude_R2_run_benchmark1.m — VALIDATION BENCHMARK 1
%  ------------------------------------------------------------------------
%  Reproduces: Malekzadeh & Heydarpour, Int. J. Pressure Vessels & Piping
%  98 (2012) 43-56, Table 6 / Fig. 2 — stationary (omega=0) FG cylinder,
%  CLAMPED ends, dynamic internal pressure  P(t) = P0*sin(pi*t/t0):
%
%     R_i = 0.08 m, R_o = 0.1 m, L = 1 m
%     E(r)   = E_m*(r/R_i)^2      , E_m  = 223 GPa
%     rho(r) = rho_m*(r/R_i)^-5.93, rho_m= 8900 kg/m^3,  nu = 0.3
%     P0 = 100 MPa, t0 = 1 s, dt = 5e-3 s (Newmark gamma=1/2, beta=1/4)
%
%  Reported at the inner surface (xi=0), mid-length (eta=0.5):
%     U*   = u * k_star/(P0*h),  k_star = 10 GPa, h = R_o-R_i
%     S*ii = sigma_ii / P0
%  Published reference values (paper "Present" and ANSYS, Table 6) are
%  embedded below for automatic comparison.
%
%  Uses the claude_R2 solver via the cfg override mechanism — the solver
%  file itself is not modified by this driver.
%  ========================================================================
clearvars -except BENCH; clc; close all;

%% ------------------------- configure and run ----------------------------
% Optional refinement override: set BENCH = struct('NL',...,'N_r',...,'N_z',...)
% in the workspace before running this script (used for convergence sweeps).
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
    'T_in_val',300, ...                    % no thermal load -> theta = 0
    'total_time',1.0, 'dt',5e-3, ...
    'store_full_history',true, ...
    'out_name',sprintf('Results_R2_bench1_NL%d_Nr%d.mat',BENCH.NL,BENCH.N_r));

claude_R2;    % run the solver (all workspace variables remain available)

%% ---------------------- extract benchmark quantities --------------------
P0     = 100e6;
k_star = 10e9;
h_th   = R_o - R_i;
iz0    = round(N_z/2);          % mid-length (N_z odd -> exact mid node)
r_in   = r_nodes{1}(1);         % = R_i

% index vectors for the inner-surface node column
rows_u_rad = zeros(N_r,1);      % u at (e=1, jr, iz0) for radial derivative
for jr = 1:N_r, rows_u_rad(jr) = idx_U(1,jr,iz0); end
rows_w_ax  = zeros(N_z,1);      % w at (e=1, ir=1, jz) for axial derivative
for jz = 1:N_z, rows_w_ax(jz) = idx_W(1,1,jz); end
row_u_in   = idx_U(1,1,iz0);

% time histories at the inner surface node
u_in   = X_hist(row_u_in, :).';                      % (Nt+1) x 1
dudr_t = (A_r{1}(1,:) * X_hist(rows_u_rad, :)).';    % du/dr(t)
dwdz_t = (A_z(iz0,:)  * X_hist(rows_w_ax, :)).';     % dw/dz(t)
eps_tt_t = u_in / r_in;

Srr_t = C11(1)*dudr_t + C12(1)*eps_tt_t + C13(1)*dwdz_t;
Stt_t = C12(1)*dudr_t + C11(1)*eps_tt_t + C13(1)*dwdz_t;
Szz_t = C13(1)*dudr_t + C13(1)*eps_tt_t + C33(1)*dwdz_t;

Ustar  = u_in * k_star/(P0*h_th);
SttS   = Stt_t / P0;
SzzS   = Szz_t / P0;
SrrS   = Srr_t / P0;
tstar  = tv / 1.0;              % t* = t/t0, t0 = 1 s

%% ------------------------- comparison table -----------------------------
% Published values: [t*  U*  S*tt  S*zz  S*rr]
ref_paper = [0.1  0.202  1.102  0.231  -0.309 ;
             0.3  0.530  2.885  0.596  -0.809 ;
             0.5  0.655  3.566  0.735  -1.000 ];
ref_ansys = [0.1  0.201  1.109  0.232  -0.296 ;
             0.3  0.525  2.903  0.606  -0.774 ;
             0.5  0.652  3.589  0.749  -0.956 ];

fprintf('\n================ BENCHMARK 1: IJPVP 98 (2012), Table 6 ================\n');
fprintf('FG cylinder, clamped ends, P(t)=P0*sin(pi*t), inner surface, z=L/2\n');
fprintf('Grid: NL=%d layers, N_r=%d, N_z=%d\n', NL, N_r, N_z);
fprintf('%-6s %-10s %10s %10s %10s %10s\n','t*','source','U*','S*_tt','S*_zz','S*_rr');
rows_out = [];
for k = 1:size(ref_paper,1)
    ts = ref_paper(k,1);
    [~,n_ts] = min(abs(tstar - ts));
    mine = [Ustar(n_ts) SttS(n_ts) SzzS(n_ts) SrrS(n_ts)];
    fprintf('%-6.2f %-10s %10.3f %10.3f %10.3f %10.3f\n', ts,'claude_R2', mine);
    fprintf('%-6s %-10s %10.3f %10.3f %10.3f %10.3f\n','','Paper',  ref_paper(k,2:5));
    fprintf('%-6s %-10s %10.3f %10.3f %10.3f %10.3f\n','','ANSYS',  ref_ansys(k,2:5));
    err = abs(mine - ref_paper(k,2:5)) ./ max(abs(ref_paper(k,2:5)), eps) * 100;
    fprintf('%-6s %-10s %9.1f%% %9.1f%% %9.1f%% %9.1f%%\n','','diff-paper', err);
    rows_out = [rows_out; ts, mine, ref_paper(k,2:5), ref_ansys(k,2:5)]; %#ok<AGROW>
end

%% ------------------------- figures (thesis quality) ---------------------
outdir = 'Validation';
if ~exist(outdir,'dir'), mkdir(outdir); end

fig1 = figure('Position',[100 100 700 500],'Color','w');
plot(tstar, Ustar, 'b-', 'LineWidth', 1.6); hold on;
plot(ref_paper(:,1), ref_paper(:,2), 'ks', 'MarkerSize',9, 'MarkerFaceColor','k');
plot(ref_ansys(:,1), ref_ansys(:,2), 'r^', 'MarkerSize',9);
xlabel('t^* = t/t_0'); ylabel('U^* = u k^*/(P_0 h)');
legend('Present (claude\_R2)','Malekzadeh & Heydarpour (2012)','ANSYS', ...
       'Location','northwest');
grid on; box on;
title('Radial displacement at inner surface, z = L/2');
saveas(fig1, fullfile(outdir,sprintf('bench1_U_NL%d.fig',NL)));
print(fig1, fullfile(outdir,sprintf('bench1_U_NL%d.png',NL)), '-dpng', '-r300');

fig2 = figure('Position',[120 120 900 500],'Color','w');
plot(tstar, SttS,'b-', tstar, SzzS,'g-', tstar, SrrS,'m-','LineWidth',1.6); hold on;
plot(ref_paper(:,1), ref_paper(:,3),'ks', 'MarkerFaceColor','k','MarkerSize',9);
plot(ref_paper(:,1), ref_paper(:,4),'ks', 'MarkerFaceColor','k','MarkerSize',9);
plot(ref_paper(:,1), ref_paper(:,5),'ks', 'MarkerFaceColor','k','MarkerSize',9);
xlabel('t^* = t/t_0'); ylabel('S^*_{ii} = \sigma_{ii}/P_0');
legend('S^*_{\theta\theta}','S^*_{zz}','S^*_{rr}','Reference values', ...
       'Location','northwest');
grid on; box on;
title('Stresses at inner surface, z = L/2');
saveas(fig2, fullfile(outdir,sprintf('bench1_S_NL%d.fig',NL)));
print(fig2, fullfile(outdir,sprintf('bench1_S_NL%d.png',NL)), '-dpng', '-r300');

% CSV table for the thesis
Ttab = array2table(rows_out, 'VariableNames', ...
   {'t_star','U_R2','Stt_R2','Szz_R2','Srr_R2', ...
    'U_paper','Stt_paper','Szz_paper','Srr_paper', ...
    'U_ansys','Stt_ansys','Szz_ansys','Srr_ansys'});
writetable(Ttab, fullfile(outdir,sprintf('bench1_table_NL%d.csv',NL)));

fprintf('\nSaved: %s\\bench1_U_NL%d.png/.fig, bench1_S_NL%d.png/.fig, bench1_table_NL%d.csv\n', ...
        outdir, NL, NL, NL);
