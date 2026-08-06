%% ========================================================================
%  claude_param_figures_R4_color.m — PRODUCTION figures (COLOR variant)
%  ------------------------------------------------------------------------
%  Identical content to claude_param_figures_R4.m but COLOR styling, written
%  to results_*/figures_color/. Used for the color Persian chapter version.
%  (B&W sibling = claude_param_figures_R4.m -> figures_print/.)
%  ------------------------------------------------------------------------
%  Revision of claude_param_figures_R3.m (R3 kept frozen). Supervisor review
%  (Prom 3-7) changes:
%    * fig 4-15 (spatial convergence) legend moved to TOP-RIGHT (northeast)
%    * NEW studies: pressure sweep (0-100 MPa), weight-fraction fill (2-4%),
%      layers 3/5/9/15, GPL aspect ratios (length/width, width/thickness),
%      infinite-length approach, mixed end supports (S-C)
%    * EXTRA component panels: sigma_rr, sigma_zz, axial displacement now
%      plotted where they best show the effect (pressure, supports)
%    * full 4x4 GPL x porosity interaction heatmap (outer-surface T*)
%  Newmark gamma_N = 0.5 everywhere (author decision): honest, unfiltered.
%  ========================================================================
clearvars; clc; close all;
pdir = 'param_studies';
fdir_camp = fullfile('results_campaign','figures_color');
fdir_ext  = fullfile('results_extensions','figures_color');
if ~exist(fdir_camp,'dir'), mkdir(fdir_camp); end
if ~exist(fdir_ext,'dir'),  mkdir(fdir_ext);  end

% ---- COLOR style table (max 5 curves per axes) --------------------------
STY.co = {[0 0.447 0.741],[0.850 0.325 0.098],[0.929 0.694 0.125],...
          [0.494 0.184 0.556],[0.466 0.674 0.188]};
STY.ls = {'-','-','-','-','-'};           % color distinguishes; solid lines
STY.mk = {'o','s','^','d','v'};
STY.lw = [1.6 1.6 1.6 1.6 1.6];
FNT = 'Times New Roman';  FSZ = 10;

%% ---- reference properties of the BASE UD material (W=0.04, em3=0.8980) --
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

%% ---- standard 2x2 studies (existing + NEW) ------------------------------
studies = { ...
 'A_GPL_patterns',   {'BASE_R4','A_GPL_O','A_GPL_X','A_GPL_V','A_GPL_A'}, {'UD','O','X','V','A'};
 'B_porosity_patterns',{'BASE_R4','B_POR_O','B_POR_X','B_POR_V','B_POR_A'}, {'UD','O','X','V','A'};
 'C_relaxation',     {'C_FOURIER','C_TAU_01','BASE_R4','C_TAU_06'}, {'Fourier','\tau^*=0.15','\tau^*=0.44','\tau^*=0.87'};
 'D_GPL_fraction',   {'D_W_000','D_W_001','BASE_R4','D_W_008'}, {'W=0','W=1%','W=4%','W=8%'};
 'D2_GPL_fill',      {'D_W_020','D_W_022','D_W_026','D_W_035','BASE_R4'}, {'W=2%','W=2.2%','W=2.6%','W=3.5%','W=4%'};
 'E_porosity_level', {'E_EM3_9675','BASE_R4','E_EM3_7776'}, {'e_{m3}=0.9675','e_{m3}=0.8980','e_{m3}=0.7776'};
 'F_end_BC',         {'BASE_R4','Q_MIX_SC','F_BC_C'}, {'S-S (simple)','S-C (mixed)','C-C (clamped)'};
 'G_pressure',       {'G_NOPRESS','G_P010','G_P050','G_P100'}, {'P_i=0','P_i=10 MPa','P_i=50 MPa','P_i=100 MPa'};
 'H_interaction',    {'BASE_R4','H_XGPL_OPOR','H_XGPL_APOR','H_VGPL_OPOR','H_VGPL_APOR'}, ...
                     {'UD/UD','X-GPL+O-por','X-GPL+A-por','V-GPL+O-por','V-GPL+A-por'};
 'I_coupling',       {'BASE_R4','I_UNCOUPLED'}, {'coupled','uncoupled'};
 'J_convection',     {'BASE_R4','J_HC_100','J_HC_1000'}, {'h_c=10','h_c=100','h_c=1000'};
 'K_thickness',      {'K_RO_015','BASE_R4','K_RO_030'}, {'R_o=0.15','R_o=0.20','R_o=0.30'};
 'L_layers',         {'L_NL_3','BASE_R4','L_NL_9','L_NL_15'}, {'N_L=3','N_L=5','N_L=9','N_L=15'};
 'M_gauss_shock',    {'M_GAUSS_LS','M_GAUSS_FOU'}, {'Gaussian, LS','Gaussian, Fourier'};
 'N_sine_pressure',  {'BASE_R4','N_SINE_P'}, {'step P=1 MPa','sine P_0=5 MPa'};
 'O_aspect_length',  {'R_ASP_LEN_L','BASE_R4','R_ASP_LEN_H'}, {'2a/2b=1.0','2a/2b=1.67','2a/2b=2.67'};
 'P_aspect_thick',   {'R_ASP_THK_H','BASE_R4','R_ASP_THK_L'}, {'2b/t=500','2b/t=1000','2b/t=2000'};
 'Q_infinite_len',   {'BASE_R4','P_INF_L10','P_INF_L20','P_INF_L40'}, {'L=0.5','L=1','L=2','L=4'};
 'T3_theories',      {'C_FOURIER','BASE_R4','T3_DPL_half','T3_DPL_eq','T3_GN3'}, ...
                     {'Fourier','LS','DPL \tau_T=\tau_q/2','DPL \tau_T=\tau_q','GN-III'} };

for si = 1:size(studies,1)
    sname = studies{si,1}; cnames = studies{si,2}; labels = studies{si,3};
    if sname(1)=='T', fdir = fdir_ext; else, fdir = fdir_camp; end
    D = {}; ok = true;
    for ci = 1:numel(cnames)
        f = fullfile(pdir, [cnames{ci} '.mat']);
        if ~exist(f,'file'), fprintf('SKIP %s (missing %s)\n', sname, cnames{ci}); ok=false; break; end
        D{ci} = load(f);
    end
    if ~ok, continue; end
    fig = figure('Position',[60 60 1150 800],'Color','w','Name',sname);
    subplot(2,2,1); hold on;
    for ci=1:numel(cnames), plotbw(Fo(D{ci}.tv), Tst(D{ci}.hist_T), ci, STY, histmarks(numel(D{ci}.tv),ci)); end
    prep(gca,FNT,FSZ,'Fo','T^*','Mid-point temperature'); legend(labels,'Location','best','FontSize',9,'FontName',FNT);
    subplot(2,2,2); hold on;
    for ci=1:numel(cnames), plotbw(Fo(D{ci}.tv), ust(D{ci}.hist_U), ci, STY, histmarks(numel(D{ci}.tv),ci)); end
    prep(gca,FNT,FSZ,'Fo','u^*','Mid-point radial displacement');
    subplot(2,2,3); hold on;
    for ci=1:numel(cnames)
        xi=(D{ci}.r_all-D{ci}.r_nodes{1}(1))/(D{ci}.r_nodes{end}(end)-D{ci}.r_nodes{1}(1));
        plotbw(xi, Tst(D{ci}.T_all), ci, STY, profmarks(numel(xi),ci));
    end
    prep(gca,FNT,FSZ,'\xi','T^*','T(\xi) at final time, z = L/2');
    subplot(2,2,4); hold on;
    for ci=1:numel(cnames)
        xi=(D{ci}.r_all-D{ci}.r_nodes{1}(1))/(D{ci}.r_nodes{end}(end)-D{ci}.r_nodes{1}(1));
        plotbw(xi, sst(D{ci}.S_tt), ci, STY, profmarks(numel(xi),ci));
    end
    prep(gca,FNT,FSZ,'\xi','\sigma^*_{\theta\theta}','Hoop stress at final time, z = L/2');
    saveall(fig, fdir, sname); fprintf('fig: %s -> %s\n', sname, fdir); close(fig);
end

%% ---- pressure: extra stress-component figure (sigma_rr, sigma_zz) -------
pc = {'G_NOPRESS','G_P010','G_P030','G_P050','G_P070','G_P100'};
pl = {'0','10','30','50','70','100'};
if all(cellfun(@(c) exist(fullfile(pdir,[c '.mat']),'file'), pc))
    Pv = [0 10 30 50 70 100];  sig_in = zeros(size(Pv));  u_end = zeros(size(Pv));
    for ci=1:numel(pc), d=load(fullfile(pdir,[pc{ci} '.mat'])); sig_in(ci)=sst(d.S_tt(1)); u_end(ci)=ust(d.hist_U(end)); end
    fig=figure('Position',[60 60 1150 420],'Color','w','Name','G2_pressure_components');
    subplot(1,2,1); hold on;                      % sigma_rr(xi) for 3 pressures
    sel=[1 4 6];
    for q=1:3
        d=load(fullfile(pdir,[pc{sel(q)} '.mat']));
        xi=(d.r_all-d.r_nodes{1}(1))/(d.r_nodes{end}(end)-d.r_nodes{1}(1));
        plotbw(xi, sst(d.S_rr), q, STY, profmarks(numel(xi),q));
    end
    prep(gca,FNT,FSZ,'\xi','\sigma^*_{rr}','Radial stress at final time');
    legend({'P_i=0','P_i=50 MPa','P_i=100 MPa'},'Location','best','FontSize',9,'FontName',FNT);
    subplot(1,2,2); hold on;                       % linear trends vs P_i
    plot(Pv, sig_in, 'ko-','LineWidth',1.4,'MarkerFaceColor','k');
    plot(Pv, u_end, 'ks-','LineWidth',1.2,'MarkerFaceColor','w');
    prep(gca,FNT,FSZ,'P_i (MPa)','dimensionless value','Inner hoop stress & final u^* vs pressure');
    legend({'\sigma^*_{\theta\theta} (inner)','u^* (final)'},'Location','northwest','FontSize',9,'FontName',FNT);
    saveall(fig, fdir_camp, 'G2_pressure_components'); fprintf('fig: G2_pressure_components\n'); close(fig);
end

%% ---- 4x4 GPL x porosity interaction heatmap (outer-surface T*) ----------
gg={'O','X','V','A'};  pp={'O','X','V','A'};
namemap = @(g,p) hmname(g,p);
HM=nan(4,4);
for ig=1:4, for ip=1:4
    f=fullfile(pdir,[namemap(gg{ig},pp{ip}) '.mat']);
    if exist(f,'file'), d=load(f); HM(ig,ip)=Tst(d.T_all(end)); end
end, end
if ~any(isnan(HM(:)))
    fig=figure('Position',[80 80 620 560],'Color','w','Name','S_interaction_matrix');
    imagesc(HM); colormap(parula); cb=colorbar; ylabel(cb,'outer-surface T^*','FontName',FNT);
    set(gca,'XTick',1:4,'XTickLabel',pp,'YTick',1:4,'YTickLabel',gg,'FontName',FNT,'FontSize',FSZ);
    xlabel('porosity pattern'); ylabel('GPL pattern');
    for ig=1:4, for ip=1:4
        tc = 'k'; if HM(ig,ip)<0.4, tc='w'; end
    end, end
    saveall(fig, fdir_camp, 'S_interaction_matrix'); fprintf('fig: S_interaction_matrix\n'); close(fig);
end

%% ---- T2 spatial convergence, B&W, legend NORTHEAST (review fix) ---------
Tt = readtable(fullfile('results_extensions','T2_spatial_table.csv'));
meth={'DQM-cheb','DQM-unif','FDM','FEM-lin','FEM-quad'};
mlab={'DQM (Chebyshev)','DQM (uniform)','FDM (2nd order)','FEM (linear)','FEM (quadratic)'};
fig=figure('Position',[100 100 780 560],'Color','w');
for q=1:numel(meth)
    m=strcmp(Tt.method,meth{q});
    loglog(Tt.N(m),Tt.max_err_K(m),'LineStyle',STY.ls{q},'Color',STY.co{q},'LineWidth',STY.lw(q),...
        'Marker',STY.mk{q},'MarkerSize',5.5,'MarkerFaceColor','w'); hold on;
end
mF=strcmp(Tt.method,'FDM'); NF=Tt.N(mF); eF=Tt.max_err_K(mF);
loglog(NF, eF(1)*(NF(1)./NF).^2, '-','Color',[0.55 0.55 0.55],'LineWidth',0.9);
prep(gca,FNT,FSZ,'number of radial points N','max error at t = 10 s (K)','Spatial convergence: DQM vs FDM vs FEM');
legend([mlab,{'slope -2'}],'Location','northeast','FontSize',9,'FontName',FNT);   % <-- review fix
saveall(fig, fdir_ext, 'T2_spatial_convergence'); fprintf('fig: T2_spatial_convergence (legend NE)\n'); close(fig);
fprintf('\nAll R4 production figures written.\n');

%% ---- helpers ------------------------------------------------------------
function nm = hmname(g,p)
    % map (GPL,porosity) pattern pair to its stored case name (v5 S_HM_* or
    % existing H_* combos), so the 4x4 matrix reads from whichever exists.
    key = [g '_' p];
    switch key
        case 'X_O', nm='H_XGPL_OPOR';  case 'X_A', nm='H_XGPL_APOR';
        case 'V_O', nm='H_VGPL_OPOR';  case 'V_A', nm='H_VGPL_APOR';
        otherwise,  nm=['S_HM_' g '_' p];
    end
end
function plotbw(x,y,ci,STY,midx)
    plot(x,y,'LineStyle',STY.ls{ci},'Color',STY.co{ci},'LineWidth',STY.lw(ci),...
        'Marker',STY.mk{ci},'MarkerIndices',midx,'MarkerSize',5,'MarkerFaceColor','w');
end
function idx=histmarks(n,ci), idx=unique(max(1,round(linspace(1+(ci-1)*floor(n/40),n,9)))); end
function idx=profmarks(n,ci), idx=unique(max(1,round(linspace(1+mod(ci-1,3),n,12)))); end
function prep(ax,fnt,fsz,xl,yl,ttl)
    set(ax,'FontName',fnt,'FontSize',fsz); grid(ax,'on'); box(ax,'on');
    xlabel(ax,xl); ylabel(ax,yl);
end
function saveall(fig,fdir,name)
    saveas(fig,fullfile(fdir,[name '.fig']));
    print(fig,fullfile(fdir,[name '.png']),'-dpng','-r300');
    exportgraphics(fig,fullfile(fdir,[name '.pdf']),'ContentType','vector');
end
