%% ========================================================================
%  claude_chapter_stats.m — key dimensionless numbers per campaign case
%  ------------------------------------------------------------------------
%  Loads every case .mat in param_studies\ and tabulates the quantities the
%  results-chapter text cites:
%    Tmax_star / Fo_at_Tmax : peak mid-point temperature (overshoot check)
%    Tend_star              : mid-point temperature at t_end
%    Tout_end_star          : OUTER-surface temperature at t_end (barrier)
%    umax_star / uend_star  : peak & final mid-point radial displacement
%    Stt_in/out_end_star    : final hoop stress at inner & outer surface
%    Stt_min/max_end_star   : final hoop-stress extremes over the wall
%  Output: results chapter grounding table -> thesis_chapter\chapter_stats.csv
%  ========================================================================
clearvars; clc;

% ---- reference constants (identical to claude_param_figures_R3) ---------
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
R_o=0.2; hthick=0.1; dT=300; T_inf=300;
Fo  = @(t) alpha_diff*t/R_o^2;
Tst = @(T) (T - T_inf)/dT;
ust = @(u) u*(lam_+2*mu_)/(beta_ref*dT*hthick);
sst = @(s) s/(beta_ref*dT);

% ---- sweep all case files ------------------------------------------------
outdir = 'thesis_chapter';  if ~exist(outdir,'dir'), mkdir(outdir); end
L = dir(fullfile('param_studies','*.mat'));
skip = {'BASE','T1_newmark','T3_LS_R5REG'};      % duplicates / non-case files
rows = {};
for i = 1:numel(L)
    [~,cname] = fileparts(L(i).name);
    if any(strcmp(cname, skip)), continue; end
    D = load(fullfile('param_studies', L(i).name));
    if ~isfield(D,'hist_T') || ~isfield(D,'tv'), continue; end
    Th = Tst(D.hist_T(:));  Uh = ust(D.hist_U(:));  tv = D.tv(:);
    [Tmx, imx] = max(Th);
    Sp = sst(D.S_tt(:));
    rows(end+1,:) = {cname, Tmx, Fo(tv(imx)), Th(end), Tst(D.T_all(end)), ...
        max(abs(Uh)), Uh(end), Sp(1), Sp(end), min(Sp), max(Sp)}; %#ok<SAGROW>
end
T = cell2table(rows, 'VariableNames', {'case_','Tmax_star','Fo_at_Tmax', ...
    'Tend_star','Tout_end_star','umax_star','uend_star', ...
    'Stt_in_end_star','Stt_out_end_star','Stt_min_end_star','Stt_max_end_star'});
T = sortrows(T,'case_');
writetable(T, fullfile(outdir,'chapter_stats.csv'));
disp(T);
fprintf('\n%d cases -> %s\\chapter_stats.csv\n', height(T), outdir);
