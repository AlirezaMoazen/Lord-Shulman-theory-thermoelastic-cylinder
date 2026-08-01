%% claude_catalog_R6.m — CHAPTER-4 FIGURE CATALOG (new geometry, new convention)
%  REVISION 6 of the catalog. Complete rebuild for the new-geometry campaign
%  (param_studies_ch4) and the app10041397 (Heydarpour) dimensionless convention.
%    * length scale = wall thickness h = R_o - R_i  (notation: l=length, h=thickness)
%    * Fo   = t * ahat / h^2         (ahat = effective diffusivity, base material)
%    * T*   = (T - T_inf)/T_inf
%    * U*   = u / [(1-nu) alpha T_inf h]
%    * Sig* = (1+nu) sigma / (E alpha T_inf)
%    * xi   = (r - R_i)/(R_o - R_i)
%  Fixed BASE-material reference props are used for ALL cases so curves are
%  directly comparable and Fo,U*,Sig* are O(1). Author's 4-panel set per study:
%    (1) T*(Fo)  (2) U*(Fo)   [mid-point time histories]
%    (3) T*(xi)  (4) Sig_thth(xi)   [profiles at final time]
%  Aspect legends use a/b and b/t (Prom.3). Sine-pressure study dropped (Prom.3).
%  New revision file; does not modify any earlier catalog revision or the solver.

clearvars; clc; close all;
pdir = 'param_studies_ch4';
cdir = 'figures_ch4';
if ~exist(cdir,'dir'), mkdir(cdir); end

%% ---- fixed reference (BASE material: W=0.3%, e_m3=0.8604) for dimensionless maps
ahat  = 8.9708e-5;                 % effective thermal diffusivity (m^2/s)
E_ref = 4.433e9;  nu_ref = 0.3395; alp_ref = 5.9814e-5;   % base eff. E, nu, alpha_exp
T_inf = 300;
Fo  = @(t,h) ahat.*t./h.^2;
Tst = @(T)   (T - T_inf)./T_inf;
Ust = @(u,h) u./((1-nu_ref).*alp_ref.*T_inf.*h);
Sst = @(s)   (1+nu_ref).*s./(E_ref.*alp_ref.*T_inf);

%% ---- styles (B&W, up to 5 curves) ----
STY.co = {[0 0 0],[0 0 0],[0.45 0.45 0.45],[0.45 0.45 0.45],[0.68 0.68 0.68]};
STY.ls = {'-','--',':','-.','-'};  STY.mk = {'o','s','^','d','v'};
STY.lw = [1.4 1.2 1.2 1.2 1.4];  FNT='Times New Roman'; FSZ=9;

%% ---- studies: {name, {cases}, {labels}} ----
studies = { ...
 'A_GPL_patterns',    {'BASE','A_GPL_O','A_GPL_X','A_GPL_V','A_GPL_A'}, {'UD','O','X','V','A'};
 'B_porosity_patterns',{'BASE','B_POR_O','B_POR_X','B_POR_V','B_POR_A'}, {'UD','O','X','V','A'};
 'E_porosity_level',  {'E_EM3_9675','BASE','E_EM3_7776'}, {'e_{m3}=0.9675','0.8604','0.7776'};
 'D_wt_low',          {'D_W_001','BASE','D_W_005','D_W_009','D_W_015'}, {'W=0.1%','0.3%','0.5%','0.9%','1.5%'};
 'D2_wt_high',        {'D2_W_010','D2_W_020','D2_W_040','D2_W_080'}, {'W=1%','2%','4%','8%'};
 'C_relaxation',      {'C_FOURIER','C_TAU_004','C_TAU_015','C_TAU_044','C_TAU_087'}, {'Fourier','\tau^*=0.04','0.15','0.44','0.87'};
 'F_end_BC',          {'BASE','F_BC_SC','F_BC_C'}, {'S-S','S-C','C-C'};
 'G_pressure',        {'G_P000','G_P010','BASE','G_P100'}, {'P_i=0','10 MPa','50 MPa','100 MPa'};
 'I_coupling',        {'BASE','I_UNCOUPLED'}, {'coupled','uncoupled'};
 'J_convection',      {'BASE','J_HC_100','J_HC_1000'}, {'h_c=10','100','1000'};
 'K_thickness',       {'K_RO_125','BASE','K_RO_200'}, {'R_o/R_i=1.25','1.5','2.0'};
 'L_layers',          {'L_NL_3','L_NL_5','BASE','L_NL_9','L_NL_15'}, {'N_L=3','5','7','9','15'};
 'Q_length',          {'Q_L_1','BASE','Q_L_5','Q_L_10'}, {'l=1','2.1','5','10'};
 'O_aspect_ab',       {'O_AB_100','BASE','O_AB_267'}, {'a/b=1.0','1.67','2.67'};
 'P_aspect_bt',       {'P_BT_500','BASE','P_BT_2000'}, {'b/t=500','1000','2000'};
 'M_gauss_shock',     {'M_GAUSS_LS','M_GAUSS_FOU'}, {'LS','Fourier'};
 'T3_theories',       {'C_FOURIER','C_TAU_015','T3_DPL','T3_GN3'}, {'Fourier','LS','DPL','GN-III'} };

made = {};
for si = 1:size(studies,1)
    sname = studies{si,1}; cnames = studies{si,2}; labels = studies{si,3};
    D = {}; ok = true;
    for ci = 1:numel(cnames)
        f = fullfile(pdir,[cnames{ci} '.mat']);
        if ~exist(f,'file'), fprintf('SKIP %s (missing %s)\n',sname,cnames{ci}); ok=false; break; end
        D{ci} = load(f,'tv','hist_T','hist_U','r_nodes','r_all','T_all','S_tt'); %#ok<SAGROW>
    end
    if ~ok, continue; end

    f1 = figure('Position',[30 50 1180 820],'Color','w','Name',sname);
    % (1) T*(Fo) mid-point history
    subplot(2,2,1); hold on;
    for ci=1:numel(cnames)
        d=D{ci}; hh=d.r_nodes{end}(end)-d.r_nodes{1}(1);
        curve(Fo(d.tv,hh), Tst(d.hist_T), ci, STY);
    end
    fin(gca,FNT,FSZ,'Fo','T^*','(1) T^*(Fo)'); legend(labels,'Location','best','FontSize',8,'FontName',FNT);
    % (2) U*(Fo) mid-point history
    subplot(2,2,2); hold on;
    for ci=1:numel(cnames)
        d=D{ci}; hh=d.r_nodes{end}(end)-d.r_nodes{1}(1);
        curve(Fo(d.tv,hh), Ust(d.hist_U,hh), ci, STY);
    end
    fin(gca,FNT,FSZ,'Fo','U^*','(2) U^*(Fo)');
    % (3) T*(xi) profile
    subplot(2,2,3); hold on;
    for ci=1:numel(cnames)
        d=D{ci}; Ri=d.r_nodes{1}(1); Ro=d.r_nodes{end}(end);
        xi=(d.r_all(:)-Ri)/(Ro-Ri);
        curve(xi, Tst(d.T_all), ci, STY);
    end
    fin(gca,FNT,FSZ,'\xi','T^*','(3) T^*(\xi)');
    % (4) Sigma_thth(xi) profile
    subplot(2,2,4); hold on;
    for ci=1:numel(cnames)
        d=D{ci}; Ri=d.r_nodes{1}(1); Ro=d.r_nodes{end}(end);
        xi=(d.r_all(:)-Ri)/(Ro-Ri);
        curve(xi, Sst(d.S_tt), ci, STY);
    end
    fin(gca,FNT,FSZ,'\xi','\Sigma_{\theta\theta}','(4) \Sigma_{\theta\theta}(\xi)');

    sgtitle(sprintf('%s', strrep(sname,'_','\_')),'FontName',FNT,'FontSize',12);
    print(f1, fullfile(cdir,[sname '.png']), '-dpng','-r130');
    savefig(f1, fullfile(cdir,[sname '.fig'])); close(f1);
    made{end+1}=sname; %#ok<SAGROW>
    fprintf('catalog R6: %s\n', sname);
end
fprintf('\nDONE: %d studies -> %s\n', numel(made), cdir);

%% ---- helpers ----
function curve(x,y,ci,STY)
    k=mod(ci-1,5)+1; x=x(:); y=y(:);
    if all(isnan(y))||numel(x)<2, return; end
    xm=x; for i=2:numel(xm), if xm(i)<=xm(i-1), xm(i)=xm(i-1)+1e-12; end, end
    nP=max(300,numel(x)); xf=linspace(xm(1),xm(end),nP); yf=interp1(xm,y,xf,'makima');
    mi=unique(round(linspace(1,nP,8)));
    plot(xf,yf,'Color',STY.co{k},'LineStyle',STY.ls{k},'LineWidth',STY.lw(k),...
        'Marker',STY.mk{k},'MarkerIndices',mi,'MarkerSize',4.5,'MarkerFaceColor','w');
end
function fin(ax,FNT,FSZ,xl,yl,tl)
    grid(ax,'on'); box(ax,'on'); set(ax,'FontName',FNT,'FontSize',FSZ);
    xlabel(ax,xl,'FontName',FNT); ylabel(ax,yl,'FontName',FNT);
    title(ax,tl,'FontName',FNT,'FontWeight','normal','FontSize',FSZ+1);
end
