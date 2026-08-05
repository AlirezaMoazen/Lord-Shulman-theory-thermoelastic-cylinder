%% claude_catalog_R1.m — QUANTITY CATALOG for choosing chapter-4 figures
%  For each parametric study, draws ONE overview image with 9 panels overlaying
%  all cases of that study, covering every field quantity available from the
%  saved .mat files (no re-run needed):
%     row 1 (mid-point time histories):   T*(Fo)   u*(Fo)   w*(Fo)
%     row 2 (final radial profiles):      T*(xi)   u*(xi)   eps_theta(xi)
%     row 3 (final radial stress profiles): sig*_rr(xi)  sig*_thth(xi)  sig*_zz(xi)
%  Purpose: a menu to DECIDE which graphs to place in the thesis chapter 4.
%  NOTE: stress/strain *time histories* are NOT available from the saved data
%  (only T,u,w mid-point histories were stored); they need a full-history re-run.
%  Output: figures_catalog\<study>_catalog.png  (+ .fig)
%  This is a NEW post-processing script; it does not modify any solver file.

clearvars; clc; close all;
pdir = 'param_studies';
cdir = 'figures_catalog';
if ~exist(cdir,'dir'), mkdir(cdir); end

%% ---- reference (BASE UD) material -> dimensionless maps (same as R4 figs) --
E_GPL=1.01e12; rho_GPL=1062.5; c_GPL=644; alpha_GPL=5e-6; k_GPL=3000; nu_GPL=0.186;
E_m=3.0e9; nu_m=0.34; rho_m=1200; c_m=1110; alpha_m=60e-6; k_m=0.246;
a_GPL=2.5e-6; b_GPL=1.5e-6; t_GPL=1.5e-9; gamma_conn=0.5; Wg=0.04; em3=0.8980;
Vg = Wg/(Wg+(rho_GPL/rho_m)*(1-Wg));
xiL=2*a_GPL/t_GPL; xiT=2*b_GPL/t_GPL;
etL=(E_GPL/E_m-1)/(E_GPL/E_m+xiL); etT=(E_GPL/E_m-1)/(E_GPL/E_m+xiT);
Es = (3/8*(1+xiL*etL*Vg)/(1-etL*Vg) + 5/8*(1+xiT*etT*Vg)/(1-etT*Vg))*E_m;
nus= Vg*nu_GPL+(1-Vg)*nu_m;  rhs=Vg*rho_GPL+(1-Vg)*rho_m;
cs = Vg*c_GPL+(1-Vg)*c_m;    als=Vg*alpha_GPL+(1-Vg)*alpha_m;
p  = a_GPL/t_GPL;  Hp = log(p+sqrt(p^2-1))*p/sqrt((p^2-1)^3)-1/(p^2-1);
ks = ((2/3)*(Vg-1/p)^gamma_conn/(Hp+1/(k_GPL/k_m-1)))*k_m + k_m;
Pm=em3; Pf=em3^2;
E_ref=Es*Pf; nu_ref=nus; rho_ref=rhs*Pm; c_ref=cs*Pf; k_ref=ks*Pf; al_ref=als;
alpha_diff = k_ref/(rho_ref*c_ref);
lam_ = nu_ref*E_ref/((1+nu_ref)*(1-2*nu_ref)); mu_ = E_ref/(2*(1+nu_ref));
beta_ref = al_ref*(3*lam_+2*mu_);
R_o=0.2; dT=300; T_inf=300; hthick=0.1;
Fo  = @(t) alpha_diff*t/R_o^2;
Tst = @(T) (T - T_inf)/dT;
ust = @(u) u*(lam_+2*mu_)/(beta_ref*dT*hthick);
sst = @(s) s/(beta_ref*dT);

%% ---- styles (B&W, up to 5 curves) --------------------------------------
STY.co = {[0 0 0],[0 0 0],[0.45 0.45 0.45],[0.45 0.45 0.45],[0.68 0.68 0.68]};
STY.ls = {'-','--',':','-.','-'};  STY.mk = {'o','s','^','d','v'};
STY.lw = [1.4 1.2 1.2 1.2 1.4];  FNT='Times New Roman'; FSZ=9;

%% ---- studies (same mapping as claude_param_figures_R4) ------------------
studies = { ...
 'A_GPL_patterns',   {'BASE_R4','A_GPL_O','A_GPL_X','A_GPL_V','A_GPL_A'}, {'UD','O','X','V','A'};
 'B_porosity_patterns',{'BASE_R4','B_POR_O','B_POR_X','B_POR_V','B_POR_A'}, {'UD','O','X','V','A'};
 'C_relaxation',     {'C_FOURIER','C_TAU_01','BASE_R4','C_TAU_06'}, {'Fourier','\tau^*=0.15','\tau^*=0.44','\tau^*=0.87'};
 'D_GPL_fraction',   {'D_W_000','D_W_001','BASE_R4','D_W_008'}, {'W=0','W=1%','W=4%','W=8%'};
 'D2_GPL_fill',      {'D_W_020','D_W_022','D_W_026','D_W_035','BASE_R4'}, {'W=2%','W=2.2%','W=2.6%','W=3.5%','W=4%'};
 'E_porosity_level', {'E_EM3_9675','BASE_R4','E_EM3_7776'}, {'e_{m3}=0.9675','e_{m3}=0.8980','e_{m3}=0.7776'};
 'F_end_BC',         {'BASE_R4','Q_MIX_SC','F_BC_C'}, {'S-S','S-C','C-C'};
 'G_pressure',       {'G_NOPRESS','G_P010','G_P050','G_P100'}, {'P_i=0','10 MPa','50 MPa','100 MPa'};
 'H_interaction',    {'BASE_R4','H_XGPL_OPOR','H_XGPL_APOR','H_VGPL_OPOR','H_VGPL_APOR'}, {'UD/UD','X+O','X+A','V+O','V+A'};
 'I_coupling',       {'BASE_R4','I_UNCOUPLED'}, {'coupled','uncoupled'};
 'J_convection',     {'BASE_R4','J_HC_100','J_HC_1000'}, {'h_c=10','h_c=100','h_c=1000'};
 'K_thickness',      {'K_RO_015','BASE_R4','K_RO_030'}, {'R_o=0.15','0.20','0.30'};
 'L_layers',         {'L_NL_3','BASE_R4','L_NL_9','L_NL_15'}, {'N_L=3','5','9','15'};
 'M_gauss_shock',    {'M_GAUSS_LS','M_GAUSS_FOU'}, {'LS','Fourier'};
 'N_sine_pressure',  {'BASE_R4','N_SINE_P'}, {'step 1 MPa','sine 5 MPa'};
 'O_aspect_length',  {'R_ASP_LEN_L','BASE_R4','R_ASP_LEN_H'}, {'2a/2b=1.0','1.67','2.67'};
 'P_aspect_thick',   {'R_ASP_THK_H','BASE_R4','R_ASP_THK_L'}, {'2b/t=500','1000','2000'};
 'Q_infinite_len',   {'BASE_R4','P_INF_L10','P_INF_L20','P_INF_L40'}, {'L=0.5','1','2','4'};
 'T3_theories',      {'C_FOURIER','BASE_R4','T3_DPL_half','T3_DPL_eq','T3_GN3'}, {'Fourier','LS','DPL 1/2','DPL eq','GN-III'} };

made = {};
for si = 1:size(studies,1)
    sname = studies{si,1}; cnames = studies{si,2}; labels = studies{si,3};
    D = {}; ok = true;
    for ci = 1:numel(cnames)
        f = fullfile(pdir,[cnames{ci} '.mat']);
        if ~exist(f,'file'), fprintf('SKIP %s (missing %s)\n', sname, cnames{ci}); ok=false; break; end
        D{ci} = load(f);
    end
    if ~ok, continue; end

    fig = figure('Position',[40 40 1350 980],'Color','w','Name',[sname '_catalog']);
    xiOf = @(d) (d.r_all - d.r_nodes{1}(1)) / (d.r_nodes{end}(end) - d.r_nodes{1}(1));

    % ---- row 1: mid-point time histories ----
    subplot(3,3,1); hold on;
    for ci=1:numel(cnames), curve(Fo(D{ci}.tv), Tst(D{ci}.hist_T), ci, STY); end
    fin(gca,FNT,FSZ,'Fo','T^*','(1) T^* history'); legend(labels,'Location','best','FontSize',7,'FontName',FNT);
    subplot(3,3,2); hold on;
    for ci=1:numel(cnames), curve(Fo(D{ci}.tv), ust(D{ci}.hist_U), ci, STY); end
    fin(gca,FNT,FSZ,'Fo','u^*','(2) u^* history (radial)');
    subplot(3,3,3); hold on;
    for ci=1:numel(cnames), curve(Fo(D{ci}.tv), ust(D{ci}.hist_W), ci, STY); end
    fin(gca,FNT,FSZ,'Fo','w^*','(3) w^* history (axial)');

    % ---- row 2: final radial profiles: T, u, hoop strain ----
    subplot(3,3,4); hold on;
    for ci=1:numel(cnames), curve(xiOf(D{ci}), Tst(D{ci}.T_all), ci, STY); end
    fin(gca,FNT,FSZ,'\xi','T^*','(4) T^*(\xi) final');
    subplot(3,3,5); hold on;
    for ci=1:numel(cnames), curve(xiOf(D{ci}), ust(D{ci}.U_all), ci, STY); end
    fin(gca,FNT,FSZ,'\xi','u^*','(5) u^*(\xi) final');
    subplot(3,3,6); hold on;
    for ci=1:numel(cnames)
        eth = D{ci}.U_all ./ D{ci}.r_all;        % hoop strain eps_theta = u/r (exact)
        curve(xiOf(D{ci}), eth, ci, STY);
    end
    fin(gca,FNT,FSZ,'\xi','\epsilon_{\theta\theta}','(6) hoop strain(\xi) final');

    % ---- row 3: final radial stress profiles ----
    subplot(3,3,7); hold on;
    for ci=1:numel(cnames), curve(xiOf(D{ci}), sst(D{ci}.S_rr), ci, STY); end
    fin(gca,FNT,FSZ,'\xi','\sigma^*_{rr}','(7) \sigma^*_{rr}(\xi) final');
    subplot(3,3,8); hold on;
    for ci=1:numel(cnames), curve(xiOf(D{ci}), sst(D{ci}.S_tt), ci, STY); end
    fin(gca,FNT,FSZ,'\xi','\sigma^*_{\theta\theta}','(8) \sigma^*_{\theta\theta}(\xi) final');
    subplot(3,3,9); hold on;
    for ci=1:numel(cnames), curve(xiOf(D{ci}), sst(D{ci}.S_zz), ci, STY); end
    fin(gca,FNT,FSZ,'\xi','\sigma^*_{zz}','(9) \sigma^*_{zz}(\xi) final');

    sgtitle(sprintf('%s  —  quantity catalog (choose panels for the thesis)', strrep(sname,'_','\_')), ...
        'FontName',FNT,'FontSize',12);
    print(fig, fullfile(cdir,[sname '_catalog.png']), '-dpng','-r130');
    savefig(fig, fullfile(cdir,[sname '_catalog.fig']));
    close(fig);
    made{end+1} = sname; %#ok<SAGROW>
    fprintf('catalog: %s\n', sname);
end
fprintf('\nDONE: %d study catalogs -> %s\n', numel(made), cdir);

%% ---- local helpers ----
function curve(x,y,ci,STY)
    k = mod(ci-1,5)+1;
    n = numel(x); mi = unique(round(linspace(1,n,10)));
    plot(x,y,'Color',STY.co{k},'LineStyle',STY.ls{k},'LineWidth',STY.lw(k));
    plot(x(mi),y(mi),'LineStyle','none','Marker',STY.mk{k},'MarkerSize',4.5,...
        'Color',STY.co{k},'MarkerFaceColor','w');
end
function fin(ax,FNT,FSZ,xl,yl,tl)
    grid(ax,'on'); box(ax,'on'); set(ax,'FontName',FNT,'FontSize',FSZ);
    xlabel(ax,xl,'FontName',FNT); ylabel(ax,yl,'FontName',FNT);
    title(ax,tl,'FontName',FNT,'FontWeight','normal','FontSize',FSZ+1);
end
