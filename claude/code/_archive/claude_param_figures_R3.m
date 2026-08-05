%% ========================================================================
%  claude_param_figures_R3.m — PRODUCTION (print) figures, B&W-safe
%  ------------------------------------------------------------------------
%  Revision of claude_param_figures_R2.m (R2 kept frozen = color screen
%  versions). Changes for thesis printing (black & white):
%    * curves distinguished by LINE STYLE + MARKER + gray level (not color)
%    * serif font (Times New Roman), sizes for print
%    * VECTOR PDF export (exportgraphics) in addition to .fig + 300dpi PNG
%    * output to figures_print\ subfolders (color versions stay untouched)
%    * extra: re-plots the T2.1 spatial-convergence figure in B&W from its
%      CSV (the frozen T2_1 script is not touched)
%  Newmark gamma_N = 0.5 everywhere (author decision 2026-07-22): honest
%  results, mild wave-front wiggles kept and mentioned in captions.
%  ========================================================================
clearvars; clc; close all;
pdir = 'param_studies';
fdir_camp = fullfile('results_campaign','figures_print');
fdir_ext  = fullfile('results_extensions','figures_print');
if ~exist(fdir_camp,'dir'), mkdir(fdir_camp); end
if ~exist(fdir_ext,'dir'),  mkdir(fdir_ext);  end

% ---- B&W style table (max 5 curves per axes) ----------------------------
STY.co = {[0 0 0],[0 0 0],[0.45 0.45 0.45],[0.45 0.45 0.45],[0.68 0.68 0.68]};
STY.ls = {'-','--',':','-.','-'};
STY.mk = {'o','s','^','d','v'};
STY.lw = [1.4 1.2 1.2 1.2 1.4];
FNT = 'Times New Roman';  FSZ = 10;

%% ---- reference properties of the BASE UD material (W=0.04, em3=0.8980) --
% (same formulas as the solver, one layer, UD/UD)
E_GPL=1.01e12; rho_GPL=1062.5; c_GPL=644; alpha_GPL=5e-6; k_GPL=3000; nu_GPL=0.186;
E_m=3.0e9; nu_m=0.34; rho_m=1200; c_m=1110; alpha_m=60e-6; k_m=0.246;
a_GPL=2.5e-6; b_GPL=1.5e-6; t_GPL=1.5e-9; gamma_conn=0.5;
Wg=0.04; em3=0.8980;
Vg = Wg/(Wg+(rho_GPL/rho_m)*(1-Wg));
xiL=2*a_GPL/t_GPL; xiT=2*b_GPL/t_GPL;
etL=(E_GPL/E_m-1)/(E_GPL/E_m+xiL); etT=(E_GPL/E_m-1)/(E_GPL/E_m+xiT);
Es = (3/8*(1+xiL*etL*Vg)/(1-etL*Vg) + 5/8*(1+xiT*etT*Vg)/(1-etT*Vg))*E_m;
nus= Vg*nu_GPL+(1-Vg)*nu_m;  rhs=Vg*rho_GPL+(1-Vg)*rho_m;
cs = Vg*c_GPL+(1-Vg)*c_m;    als=Vg*alpha_GPL+(1-Vg)*alpha_m;
p  = a_GPL/t_GPL;  Hp = log(p+sqrt(p^2-1))*p/sqrt((p^2-1)^3)-1/(p^2-1);
ks = ((2/3)*(Vg-1/p)^gamma_conn/(Hp+1/(k_GPL/k_m-1)))*k_m + k_m;
Pm = em3;  Pf = em3^2;
E_ref=Es*Pf; nu_ref=nus; rho_ref=rhs*Pm; c_ref=cs*Pf; k_ref=ks*Pf; al_ref=als;
alpha_diff = k_ref/(rho_ref*c_ref);
lam_ = nu_ref*E_ref/((1+nu_ref)*(1-2*nu_ref));
mu_  = E_ref/(2*(1+nu_ref));
beta_ref = al_ref*(3*lam_+2*mu_);

R_i=0.1; R_o=0.2; hthick=R_o-R_i; dT=300; T_inf=300;
Fo   = @(t) alpha_diff*t/R_o^2;
Tst  = @(T) (T - T_inf)/dT;
ust  = @(u) u*(lam_+2*mu_)/(beta_ref*dT*hthick);
sst  = @(s) s/(beta_ref*dT);
fprintf('alpha_ref = %.3e m^2/s ; Fo(100 s) = %.3f\n', alpha_diff, Fo(100));

%% ---- study definitions (same as R2) -------------------------------------
studies = { ...
 'A_GPL_patterns',   {'BASE_R4','A_GPL_O','A_GPL_X','A_GPL_V','A_GPL_A'}, {'UD','O','X','V','A'};
 'B_porosity_patterns',{'BASE_R4','B_POR_O','B_POR_X','B_POR_V','B_POR_A'}, {'UD','O','X','V','A'};
 'C_relaxation',     {'C_FOURIER','C_TAU_01','BASE_R4','C_TAU_06'}, {'Fourier','\tau^*=0.15','\tau^*=0.44','\tau^*=0.87'};
 'D_GPL_fraction',   {'D_W_000','D_W_001','BASE_R4','D_W_008'}, {'W=0','W=1%','W=4%','W=8%'};
 'E_porosity_level', {'E_EM3_9675','BASE_R4','E_EM3_7776'}, {'e_{m3}=0.9675','e_{m3}=0.8980','e_{m3}=0.7776'};
 'F_end_BC',         {'BASE_R4','F_BC_C'}, {'Simply supported','Clamped'};
 'G_pressure',       {'BASE_R4','G_NOPRESS'}, {'P_i = 1 MPa','P_i = 0'};
 'H_interaction',    {'BASE_R4','H_XGPL_OPOR','H_XGPL_APOR','H_VGPL_OPOR','H_VGPL_APOR'}, ...
                     {'UD/UD','X-GPL+O-por','X-GPL+A-por','V-GPL+O-por','V-GPL+A-por'};
 'I_coupling',       {'BASE_R4','I_UNCOUPLED'}, {'coupled','uncoupled'};
 'J_convection',     {'BASE_R4','J_HC_100','J_HC_1000'}, {'h_c=10','h_c=100','h_c=1000'};
 'K_thickness',      {'K_RO_015','BASE_R4','K_RO_030'}, {'R_o=0.15','R_o=0.20','R_o=0.30'};
 'L_layers',         {'L_NL_3','BASE_R4','L_NL_8'}, {'N_L=3','N_L=5','N_L=8'};
 'M_gauss_shock',    {'M_GAUSS_LS','M_GAUSS_FOU'}, {'Gaussian, LS','Gaussian, Fourier'};
 'N_sine_pressure',  {'BASE_R4','N_SINE_P'}, {'step P=1 MPa','sine P_0=5 MPa'};
 'T3_theories',      {'C_FOURIER','BASE_R4','T3_DPL_half','T3_DPL_eq','T3_GN3'}, ...
                     {'Fourier','LS','DPL \tau_T=\tau_q/2','DPL \tau_T=\tau_q','GN-III'} };

%% ---- generate one 2x2 production figure per study -----------------------
for si = 1:size(studies,1)
    sname = studies{si,1}; cnames = studies{si,2}; labels = studies{si,3};
    if sname(1)=='T', fdir = fdir_ext; else, fdir = fdir_camp; end
    D = {};  ok = true;
    for ci = 1:numel(cnames)
        f = fullfile(pdir, [cnames{ci} '.mat']);
        if ~exist(f,'file'), fprintf('SKIP %s (missing %s)\n', sname, cnames{ci}); ok=false; break; end
        D{ci} = load(f);
    end
    if ~ok, continue; end

    fig = figure('Position',[60 60 1150 800],'Color','w','Name',sname);

    % (1) mid-point temperature history vs Fo
    subplot(2,2,1); hold on;
    for ci = 1:numel(cnames)
        x = Fo(D{ci}.tv); y = Tst(D{ci}.hist_T);
        plotbw(x, y, ci, STY, histmarks(numel(x), ci));
    end
    prep(gca, FNT, FSZ, 'Fo', 'T^*', 'Mid-point temperature');
    legend(labels,'Location','best','FontSize',9,'FontName',FNT);

    % (2) mid-point radial displacement history
    subplot(2,2,2); hold on;
    for ci = 1:numel(cnames)
        x = Fo(D{ci}.tv); y = ust(D{ci}.hist_U);
        plotbw(x, y, ci, STY, histmarks(numel(x), ci));
    end
    prep(gca, FNT, FSZ, 'Fo', 'u^*', 'Mid-point radial displacement');

    % (3) final radial temperature profile vs xi
    subplot(2,2,3); hold on;
    for ci = 1:numel(cnames)
        Ri_c = D{ci}.r_nodes{1}(1);  Ro_c = D{ci}.r_nodes{end}(end);
        xi = (D{ci}.r_all - Ri_c)/(Ro_c - Ri_c);
        plotbw(xi, Tst(D{ci}.T_all), ci, STY, profmarks(numel(xi), ci));
    end
    prep(gca, FNT, FSZ, '\xi', 'T^*', 'T(\xi) at final time, z = L/2');

    % (4) final hoop-stress profile
    subplot(2,2,4); hold on;
    for ci = 1:numel(cnames)
        Ri_c = D{ci}.r_nodes{1}(1);  Ro_c = D{ci}.r_nodes{end}(end);
        xi = (D{ci}.r_all - Ri_c)/(Ro_c - Ri_c);
        plotbw(xi, sst(D{ci}.S_tt), ci, STY, profmarks(numel(xi), ci));
    end
    prep(gca, FNT, FSZ, '\xi', '\sigma^*_{\theta\theta}', 'Hoop stress at final time, z = L/2');

    saveall(fig, fdir, sname);
    fprintf('print figure written: %s -> %s\n', sname, fdir);
    close(fig);
end

%% ---- T2.1 spatial-convergence figure, B&W from CSV ----------------------
Tt = readtable(fullfile('results_extensions','T2_spatial_table.csv'));
meth = {'DQM-cheb','DQM-unif','FDM','FEM-lin','FEM-quad'};
mlab = {'DQM (Chebyshev)','DQM (uniform)','FDM (2nd order)','FEM (linear)','FEM (quadratic)'};
fig = figure('Position',[100 100 780 560],'Color','w');
for q = 1:numel(meth)
    m = strcmp(Tt.method, meth{q});
    loglog(Tt.N(m), Tt.max_err_K(m), 'LineStyle',STY.ls{q}, 'Color',STY.co{q}, ...
        'LineWidth',STY.lw(q), 'Marker',STY.mk{q}, 'MarkerSize',5.5, ...
        'MarkerFaceColor','w'); hold on;
end
mF = strcmp(Tt.method,'FDM');  NF = Tt.N(mF);  eF = Tt.max_err_K(mF);
loglog(NF, eF(1)*(NF(1)./NF).^2, ':', 'Color',[0.55 0.55 0.55], 'LineWidth',0.9);
prep(gca, FNT, FSZ, 'number of radial points N', 'max error at t = 10 s (K)', ...
     'Spatial convergence: DQM vs FDM vs FEM');
legend([mlab, {'slope -2'}], 'Location','southwest','FontSize',9,'FontName',FNT);
saveall(fig, fdir_ext, 'T2_spatial_convergence');
fprintf('print figure written: T2_spatial_convergence -> %s\n', fdir_ext);
close(fig);
fprintf('\nAll PRODUCTION figures written (PDF vector + PNG 300dpi + FIG).\n');

%% ---- helpers ------------------------------------------------------------
function plotbw(x, y, ci, STY, midx)
    plot(x, y, 'LineStyle',STY.ls{ci}, 'Color',STY.co{ci}, 'LineWidth',STY.lw(ci), ...
        'Marker',STY.mk{ci}, 'MarkerIndices',midx, 'MarkerSize',5, 'MarkerFaceColor','w');
end
function idx = histmarks(n, ci)
    idx = unique(max(1, round(linspace(1+(ci-1)*floor(n/40), n, 9))));
end
function idx = profmarks(n, ci)
    idx = unique(max(1, round(linspace(1+mod(ci-1,3), n, 12))));
end
function prep(ax, fnt, fsz, xl, yl, ttl)
    set(ax,'FontName',fnt,'FontSize',fsz); grid(ax,'on'); box(ax,'on');
    xlabel(ax, xl); ylabel(ax, yl); title(ax, ttl, 'FontWeight','normal');
end
function saveall(fig, fdir, name)
    saveas(fig, fullfile(fdir,[name '.fig']));
    print(fig, fullfile(fdir,[name '.png']), '-dpng','-r300');
    exportgraphics(fig, fullfile(fdir,[name '.pdf']), 'ContentType','vector');
end
