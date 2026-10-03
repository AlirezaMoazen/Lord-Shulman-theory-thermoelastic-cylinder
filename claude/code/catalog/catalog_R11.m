%% catalog_R11.m — CHAPTER-4 FIGURE CATALOG (B&W), wider GPL aspect-ratio sweeps
%  R11 (2026-10-03, author request): identical to R10 except the two aspect
%  studies, plus one new figure:
%    O_aspect_ab      a/b = 1.0 / 1.67 / 4 / 10        (was 1.0 / 1.67 / 2.67)
%    P_aspect_bt      b/t = 10 / 100 / 1000            (was 500 / 1000 / 2000)
%    P_aspect_bt_fine b/t = 100 / 200 / 500 / 1000 / 2000   (NEW)
%  New cases: campaign/run_aspect_sweep_R1.ps1 and _R2.ps1 (solver R11,
%  physics-identical to the R7 used for BASE).
%  b/t cases now vary t_GPL at fixed a_GPL/b_GPL (a/b stays 1.67); the OLD
%  P_BT_500/P_BT_2000 varied b_GPL and so moved a/b too => the new P_aspect_bt
%  is NOT comparable curve-for-curve with R10's. Also note the percolation
%  switch: V_GPL > 1/p with p = a_GPL/t_GPL means b/t > 176.7 at W = 0.3%, so
%  b/t = 10 and 100 are both below threshold (k_eff = bare-matrix 0.2961 W/mK,
%  flat T* curves); P_aspect_bt_fine resolves that transition. Full explanation
%  in the header of catalog_R11_color.m.
%
%  (original R10 header follows)
%% CHAPTER-4 FIGURE CATALOG (new geometry, new convention)
%  Builds the 4-panel comparison figures for the Chapter-4 parameter studies
%  (param_studies_ch4), using the app10041397 (Heydarpour) dimensionless
%  convention:
%    * length scale = wall thickness h = R_o - R_i  (notation: l=length, h=thickness)
%    * Fo   = t * ahat / h^2         (ahat = effective diffusivity, base material)
%    * T*   = (T - T_inf)/T_inf
%    * U*   = u / [(1-nu) alpha T_inf h]
%    * Sig* = (1+nu) sigma / (E alpha T_inf)
%    * xi   = (r - R_i)/(R_o - R_i)
%  Fixed BASE-material reference props are used for ALL cases so curves are
%  directly comparable and Fo,U*,Sig* are O(1). Each study gets a 4-panel set:
%    (1) T*(Fo)  (2) U*(Fo)   [mid-point time histories]
%    (3) T*(xi)  (4) Sig_thth(xi)   [profiles at final time]
%  Aspect legends use a/b and b/t.

clearvars; clc; close all;
pdir = 'param_studies_ch4';
cdir = 'figures_ch4_R11';
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
STY.lw = [1.4 1.2 1.2 1.2 1.4];  FNT='Times New Roman'; FSZ=14; LGSZ=14;

%% ---- studies: {name, {cases}, {labels}} ----
studies = { ...
 'A_GPL_patterns',    {'BASE','A_GPL_O','A_GPL_X','A_GPL_V','A_GPL_A'}, {'UD','O','X','V','A'};
 'B_porosity_patterns',{'BASE','B_POR_O','B_POR_X','B_POR_V','B_POR_A'}, {'UD','O','X','V','A'};
 'E_porosity_level',  {'E_EM3_9675','BASE','E_EM3_7776'}, {'e_{m3}=0.9675','0.8604','0.7776'};
 'D_wt_low',          {'D_W_001','BASE','D_W_005','D_W_009','D_W_015'}, {'W=0.1%','0.3%','0.5%','0.9%','1.5%'};
 'D2_wt_high',        {'D2_W_010','D2_W_020','D2_W_040','D2_W_080'}, {'W=1%','2%','4%','8%'};
 'C_relaxation',      {'C_FOURIER','C_TAU_004','C_TAU_015','C_TAU_044'}, {'Fourier','\tau^*=0.04','0.15','0.44'};
 'F_end_BC',          {'BASE','F_BC_SC','F_BC_C'}, {'S-S','S-C','C-C'};
 'G_pressure',        {'G_P000','G_P010','BASE','G_P100'}, {'P_i=0','10 MPa','50 MPa','100 MPa'};
 'I_coupling',        {'BASE','I_UNCOUPLED'}, {'coupled','uncoupled'};
 'J_convection',      {'BASE','J_HC_100','J_HC_1000'}, {'h_c=10','100','1000'};
 'K_thickness',       {'K_RO_125','BASE','K_RO_200'}, {'R_o/R_i=1.25','1.5','2.0'};
 'L_layers',          {'L_NL_3','L_NL_5','BASE','L_NL_9','L_NL_15'}, {'N_L=3','5','7','9','15'};
 'Q_length',          {'Q_L_1','BASE','Q_L_5','Q_L_10'}, {'L=1','2.1','5','10'};
 'O_aspect_ab',       {'O_AB_100','BASE','O_AB_400','O_AB_1000'}, {'a/b=1.0','1.67','4','10'};
 'P_aspect_bt',       {'P_BT_010','P_BT_100','BASE'}, {'b/t=10','100','1000'};
 'P_aspect_bt_fine',  {'P_BT_100','P_BT_200','P_BT_500T','BASE','P_BT_2000T'}, {'b/t=100','200','500','1000','2000'};
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
    tl = tiledlayout(f1,2,2,'TileSpacing','tight','Padding','tight');
    % (1) T*(Fo) mid-point history
    nexttile(tl); hold on;
    for ci=1:numel(cnames)
        d=D{ci}; hh=d.r_nodes{end}(end)-d.r_nodes{1}(1);
        curve(Fo(d.tv,hh), Tst(d.hist_T), ci, STY);
    end
    fin(gca,FNT,FSZ,'Fo','T^*','(1) T^*(Fo)'); place_legend(gca,labels,FNT,LGSZ,sname,1);
    % (2) U*(Fo) mid-point history
    nexttile(tl); hold on;
    for ci=1:numel(cnames)
        d=D{ci}; hh=d.r_nodes{end}(end)-d.r_nodes{1}(1);
        curve(Fo(d.tv,hh), Ust(d.hist_U,hh), ci, STY);
    end
    fin(gca,FNT,FSZ,'Fo','U^*','(2) U^*(Fo)'); place_legend(gca,labels,FNT,LGSZ,sname,2);
    % (3) T*(xi) profile
    nexttile(tl); hold on;
    for ci=1:numel(cnames)
        d=D{ci}; Ri=d.r_nodes{1}(1); Ro=d.r_nodes{end}(end);
        xi=(d.r_all(:)-Ri)/(Ro-Ri);
        curve(xi, Tst(d.T_all), ci, STY);
    end
    fin(gca,FNT,FSZ,'\xi','T^*','(3) T^*(\xi)'); place_legend(gca,labels,FNT,LGSZ,sname,3);
    % (4) Sigma_thth(xi) profile
    nexttile(tl); hold on;
    for ci=1:numel(cnames)
        d=D{ci}; Ri=d.r_nodes{1}(1); Ro=d.r_nodes{end}(end);
        xi=(d.r_all(:)-Ri)/(Ro-Ri);
        curve(xi, Sst(d.S_tt), ci, STY);
    end
    fin(gca,FNT,FSZ,'\xi','\Sigma_{\theta\theta}','(4) \Sigma_{\theta\theta}(\xi)'); place_legend(gca,labels,FNT,LGSZ,sname,4);

    % No sgtitle on the figure — the figure number/caption is added in the document
    print(f1, fullfile(cdir,[sname '.png']), '-dpng','-r130');
    savefig(f1, fullfile(cdir,[sname '.fig'])); close(f1);
    made{end+1}=sname; %#ok<SAGROW>
    fprintf('catalog: %s\n', sname);
end
fprintf('\nDONE: %d studies -> %s\n', numel(made), cdir);

%% ---- helpers ----
function out = place_legend(ax,labels,FNT,SZ,sname,panel)
% Put a legend on THIS axes and verify it does not sit on top of any plotted
% line. MATLAB's 'best' only minimises overlap -- it does not guarantee zero --
% so every candidate location is tried and the overlap is measured directly:
% each data point is mapped into figure-normalised coordinates and tested
% against the legend's own rectangle. The first location with zero covered
% points wins; if every in-axes location still covers data, the legend is moved
% outside the axes, which cannot overlap by construction.
    cand = {'best','northeast','northwest','southeast','southwest','north','south','east','west'};
    ln = findobj(ax,'Type','line');
    X = []; Y = [];
    for i = 1:numel(ln)
        X = [X, ln(i).XData(:).']; Y = [Y, ln(i).YData(:).']; %#ok<AGROW>
    end
    good = isfinite(X) & isfinite(Y); X = X(good); Y = Y(good);
    bestLoc = cand{1}; bestN = inf;
    for c = 1:numel(cand)
        lg = legend(ax,labels,'Location',cand{c},'FontSize',SZ,'FontName',FNT);
        drawnow limitrate;
        n = count_covered(ax,lg,X,Y);
        if n < bestN, bestN = n; bestLoc = cand{c}; end
        if n == 0, break; end
    end
    if bestN > 0
        lg = legend(ax,labels,'Location','eastoutside','FontSize',SZ,'FontName',FNT);
        drawnow limitrate;
        bestLoc = 'eastoutside'; bestN = 0;
    else
        lg = legend(ax,labels,'Location',bestLoc,'FontSize',SZ,'FontName',FNT); %#ok<NASGU>
    end
    fprintf('    %-18s panel %d: legend %-13s covered points = %d\n', sname, panel, bestLoc, bestN);
    out = {sname, panel, bestLoc, bestN};
end

function n = count_covered(ax,lg,X,Y)
% number of plotted points falling inside the legend rectangle
    set(lg,'Units','normalized'); LP = lg.Position;
    P  = ax.Position;                      % axes box, figure-normalised
    xl = xlim(ax); yl = ylim(ax);
    if strcmp(ax.XScale,'log'), xs = (log10(X)-log10(xl(1)))/(log10(xl(2))-log10(xl(1)));
    else,                       xs = (X-xl(1))/(xl(2)-xl(1)); end
    if strcmp(ax.YScale,'log'), ys = (log10(Y)-log10(yl(1)))/(log10(yl(2))-log10(yl(1)));
    else,                       ys = (Y-yl(1))/(yl(2)-yl(1)); end
    vis = xs>=0 & xs<=1 & ys>=0 & ys<=1;   % only points actually drawn in view
    xn = P(1) + xs*P(3);  yn = P(2) + ys*P(4);
    inx = xn>=LP(1) & xn<=LP(1)+LP(3);
    iny = yn>=LP(2) & yn<=LP(2)+LP(4);
    n = sum(vis & inx & iny);
end

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
    % Panel title intentionally omitted; panel identified by axis labels and figure number (tl unused)
end
