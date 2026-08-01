%% ========================================================================
%  claude_R2_run_LSdemo.m — LORD-SHULMAN WAVE-PROPAGATION DEMONSTRATION
%  ------------------------------------------------------------------------
%  Thermal shock on the inner surface of the GPL-reinforced porous cylinder
%  (docx material), full LS coupling, no pressure. Four cases:
%     case 1 : Fourier   (LS off)
%     case 2 : LS, tau0 = 1 s
%     case 3 : LS, tau0 = 2 s
%     case 4 : LS, tau0 = 4 s
%  (Relaxation times are exaggerated in the standard nondimensional sense
%   so the finite-speed heat wave is visible across the 0.1 m thickness —
%   same practice as the reference papers.)
%
%  Produces:  Validation\LSdemo_T_profiles.png/.fig  (wave fronts vs Fourier)
%             Validation\LSdemo_T_history.png/.fig   (delayed arrival vs tau0)
%             Validation\LSdemo_U_history.png/.fig   (radial displacement)
%  NOTE: claude_R2 clears the workspace at each call, so the four runs are
%  written as explicit blocks and all data is exchanged through .mat files.
%  ========================================================================
clearvars; clc; close all;

base = struct( ...
    'LS_enabled',false, 'coupling_on',true, ...
    'GPL_pattern','UD', 'porosity_on',true, 'porosity_pattern','UD', ...
    'W_GPL_total',0.04, 'e3',0.8064, ...
    'BC_z','S', ...
    'NL',5, 'N_r',9, 'N_z',9, ...
    'R_i',0.1, 'R_o',0.2, 'L',0.5, ...
    'P_i',0, ...
    'T_in_val',500, 't0_ramp',0.1, 'h_c',100, 'T_inf',300, ...
    'total_time',15, 'dt',0.025, ...
    'store_full_history',true);

% ---- case 1: Fourier ----
cfg = base;  cfg.LS_enabled = false;
cfg.out_name = 'Results_LSdemo_F.mat';
claude_R2;

% ---- case 2: LS tau0 = 1 ----
load('Results_LSdemo_F.mat','NL');   %#ok<LOAD> % (no-op: keeps analyzers quiet)
base = struct( ...
    'LS_enabled',true, 'coupling_on',true, ...
    'GPL_pattern','UD', 'porosity_on',true, 'porosity_pattern','UD', ...
    'W_GPL_total',0.04, 'e3',0.8064, ...
    'BC_z','S', ...
    'NL',5, 'N_r',9, 'N_z',9, ...
    'R_i',0.1, 'R_o',0.2, 'L',0.5, ...
    'P_i',0, ...
    'T_in_val',500, 't0_ramp',0.1, 'h_c',100, 'T_inf',300, ...
    'total_time',15, 'dt',0.025, ...
    'store_full_history',true);
cfg = base;  cfg.tau0 = 1.0;  cfg.out_name = 'Results_LSdemo_t1.mat';
claude_R2;

% ---- case 3: LS tau0 = 2 ----
base = struct( ...
    'LS_enabled',true, 'coupling_on',true, ...
    'GPL_pattern','UD', 'porosity_on',true, 'porosity_pattern','UD', ...
    'W_GPL_total',0.04, 'e3',0.8064, ...
    'BC_z','S', ...
    'NL',5, 'N_r',9, 'N_z',9, ...
    'R_i',0.1, 'R_o',0.2, 'L',0.5, ...
    'P_i',0, ...
    'T_in_val',500, 't0_ramp',0.1, 'h_c',100, 'T_inf',300, ...
    'total_time',15, 'dt',0.025, ...
    'store_full_history',true);
cfg = base;  cfg.tau0 = 2.0;  cfg.out_name = 'Results_LSdemo_t2.mat';
claude_R2;

% ---- case 4: LS tau0 = 4 ----
base = struct( ...
    'LS_enabled',true, 'coupling_on',true, ...
    'GPL_pattern','UD', 'porosity_on',true, 'porosity_pattern','UD', ...
    'W_GPL_total',0.04, 'e3',0.8064, ...
    'BC_z','S', ...
    'NL',5, 'N_r',9, 'N_z',9, ...
    'R_i',0.1, 'R_o',0.2, 'L',0.5, ...
    'P_i',0, ...
    'T_in_val',500, 't0_ramp',0.1, 'h_c',100, 'T_inf',300, ...
    'total_time',15, 'dt',0.025, ...
    'store_full_history',true);
cfg = base;  cfg.tau0 = 4.0;  cfg.out_name = 'Results_LSdemo_t4.mat';
claude_R2;

%% ======================= plotting / comparison ==========================
clearvars; close all;
files = {'Results_LSdemo_F.mat','Results_LSdemo_t1.mat', ...
         'Results_LSdemo_t2.mat','Results_LSdemo_t4.mat'};
names = {'Fourier','LS \tau_0=1 s','LS \tau_0=2 s','LS \tau_0=4 s'};

D = cellfun(@load, files);
NL = D(1).NL;  N_r = D(1).N_r;  N_z = D(1).N_z;
iz0 = round(N_z/2);
idxT = @(e,ir,iz) (e-1)*N_r*N_z + (ir-1)*N_z + iz;
Nn   = NL*N_r*N_z;
idxU = @(e,ir,iz) Nn + idxT(e,ir,iz);

% assemble radial point list + row indices
r_pts = []; rT = []; rU = [];
for e = 1:NL
    for ir = 1:N_r
        r_pts(end+1) = D(1).r_nodes{e}(ir);  %#ok<SAGROW>
        rT(end+1)    = idxT(e,ir,iz0);       %#ok<SAGROW>
        rU(end+1)    = idxU(e,ir,iz0);       %#ok<SAGROW>
    end
end
tv = D(1).tv;  dt = tv(2)-tv(1);

outdir = 'Validation';
if ~exist(outdir,'dir'), mkdir(outdir); end

% ---- Fig 1: temperature profiles, LS(tau0=2) vs Fourier, several times ----
tshow = [1 3 6 10];
fig1 = figure('Position',[80 80 860 560],'Color','w'); hold on;
cols = lines(numel(tshow));
for kk = 1:numel(tshow)
    n_t = round(tshow(kk)/dt)+1;
    plot(r_pts, 300 + D(3).X_hist(rT,n_t), '-',  'Color',cols(kk,:), 'LineWidth',1.8);
    plot(r_pts, 300 + D(1).X_hist(rT,n_t), '--', 'Color',cols(kk,:), 'LineWidth',1.2);
end
xlabel('r (m)'); ylabel('T (K)'); grid on; box on;
legend('LS \tau_0=2 s,  t=1 s','Fourier, t=1 s','t=3 s','t=3 s', ...
       't=6 s','t=6 s','t=10 s','t=10 s','Location','northeast');
title('Finite-speed heat wave (LS, solid) vs infinite-speed diffusion (Fourier, dashed)');
saveas(fig1, fullfile(outdir,'LSdemo_T_profiles.fig'));
print(fig1, fullfile(outdir,'LSdemo_T_profiles.png'), '-dpng','-r300');

% ---- Fig 2: temperature history at mid-radius for all tau0 ----
p_mid = rT( round(numel(rT)/2) );
fig2 = figure('Position',[100 100 860 560],'Color','w'); hold on;
sty = {'k-','b-','r-','m-'};
for c = 1:4
    plot(tv, 300 + D(c).X_hist(p_mid,:), sty{c}, 'LineWidth',1.6);
end
xlabel('t (s)'); ylabel('T (K)'); grid on; box on;
legend(names,'Location','southeast');
title('Temperature history at mid-thickness: arrival delay grows with \tau_0');
saveas(fig2, fullfile(outdir,'LSdemo_T_history.fig'));
print(fig2, fullfile(outdir,'LSdemo_T_history.png'), '-dpng','-r300');

% ---- Fig 3: radial displacement history at mid-radius ----
p_umid = rU( round(numel(rU)/2) );
fig3 = figure('Position',[120 120 860 560],'Color','w'); hold on;
for c = 1:4
    plot(tv, 1e6*D(c).X_hist(p_umid,:), sty{c}, 'LineWidth',1.6);
end
xlabel('t (s)'); ylabel('u (\mum)'); grid on; box on;
legend(names,'Location','southeast');
title('Radial displacement at mid-thickness for different relaxation times');
saveas(fig3, fullfile(outdir,'LSdemo_U_history.fig'));
print(fig3, fullfile(outdir,'LSdemo_U_history.png'), '-dpng','-r300');

fprintf('\nLS demo complete. Figures saved in %s\\LSdemo_*.png/.fig\n', outdir);
