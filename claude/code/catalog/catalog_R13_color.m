%% catalog_R13_color.m — COLOR 4-panel Chapter-4 figures, legend placement per study
%  R13 (2026-10-03, author request): same studies and same data as R12; only
%  where the legends sit changes, and only in three figures:
%    B_porosity_patterns, G_pressure : the four in-panel legends are replaced by
%      ONE legend in a strip of its own under the whole figure (tiledlayout
%      south tile). All four panels share it, it cannot cover a curve, and the
%      panels get back the space the repeated legends were using.
%    Q_length panel 2 (U* vs Fo) : the legend sat in the gap between the L=1
%      curve and the bundle of the other three. It is now placed as usual and
%      then walked upwards in 0.003 steps for as long as it still covers no
%      plotted point, so it ends as high as it can go without touching a curve.
%  Every other figure keeps the R12 behaviour: one verified legend per panel.
%  Output folder: figures_ch4_color_R13.
%
%  (R12 header follows)
%% COLOR 4-panel Chapter-4 figures (legend on every panel)
%  R12 (2026-10-03, author request): RELAXATION AND THICKNESS STUDIES REVISED.
%  Identical to R11 in style, layout, data maps and every other study; only two
%  study definitions changed:
%    C_relaxation  tau* = Fourier / 0.04 / 0.15   -- the 0.44 curve is dropped.
%                  The remaining spread still brackets the physical value used
%                  in the thesis (tau0 = 418 s => tau* = 0.15).
%    K_thickness   R_o/R_i = 1.5 / 2.0 / 5.0      -- the 1.25 curve is dropped
%                  and a genuinely thick wall is added at R_o/R_i = 5.
%  K_RO_500 is a NEW solve (campaign/run_thickness_sweep_R1.ps1, solver R11,
%  physics-identical to the R7 used for BASE). Following the convention of the
%  existing thickness cases, its simulated time is scaled with h^2 so each case
%  spans a comparable Fo range: h = 4.0 -> 192000 s at dt = 64 (3000 steps, as
%  in BASE). Note the dimensionless maps all divide by that case's own h, so the
%  curves remain directly comparable even though R_o/R_i = 5 is a stubby
%  geometry (h = 4.0 against L = 2.1).
%  Output folder: figures_ch4_color_R12.
%
%  (R11 header follows)
%% COLOR 4-panel Chapter-4 figures (legend on every panel)
%  R11 (2026-10-03, author request): WIDER GPL ASPECT-RATIO SWEEPS. Identical to
%  R10 in style, layout, data maps and every other study; only the two aspect
%  studies changed, plus one new figure:
%    O_aspect_ab      a/b = 1.0 / 1.67 / 4 / 10        (was 1.0 / 1.67 / 2.67)
%    P_aspect_bt      b/t = 10 / 100 / 1000            (was 500 / 1000 / 2000)
%    P_aspect_bt_fine b/t = 100 / 200 / 500 / 1000 / 2000   (NEW)
%  New cases come from campaign/run_aspect_sweep_R1.ps1 and _R2.ps1 (solver R11,
%  physics-identical to the R7 used for BASE, so all curves stay comparable).
%
%  TWO THINGS TO KNOW ABOUT THE b/t FIGURES:
%  (1) CONVENTION CHANGE. The new b/t cases vary t_GPL at fixed a_GPL and b_GPL,
%      so a/b stays at the reference 1.67 across the sweep. The OLD P_BT_500 /
%      P_BT_2000 varied b_GPL instead, which moved a/b at the same time
%      (a/b = 3.33 at P_BT_500) and so confounded the two ratios. Varying t_GPL
%      is also what the Ch4 4-8 text describes. => the new P_aspect_bt figure is
%      NOT comparable curve-for-curve with the R10 one. P_BT_500T / P_BT_2000T
%      are the t_GPL-based replacements for the old b_GPL-based cases.
%  (2) PERCOLATION SWITCH. The conductivity model percolates only when
%      V_GPL > 1/p, p = a_GPL/t_GPL. At W_GPL = 0.3% (V_GPL = 0.003395) that is
%      a/t > 294.6, i.e. b/t > 176.7 at a/b = 1.67. So in P_aspect_bt the two
%      lower curves (b/t = 10 and 100) are BOTH below the threshold: k_eff falls
%      to the bare-matrix 0.2961 W/mK and almost no heat reaches the probe in
%      3000 s, making their T* curves flat and mutually indistinguishable. They
%      still differ mechanically, because Halpin-Tsai's xi_T = 2b/t varies
%      continuously even where the conductivity switch has flipped. The
%      P_aspect_bt_fine figure exists to resolve that transition.
%
%  Output goes to a NEW folder so the R10 figures are not overwritten.
%  Same studies, data and dimensionless maps as the previous revision; only the
%  layout changed. The four panels used subplot(2,2,n), which leaves wide
%  margins between and around the axes. They now use a tiled layout with
%  compact spacing, so each panel is noticeably larger inside the same canvas,
%  and the legend and axis fonts are larger to match.
%  Output goes to a NEW folder so the previous figures are not overwritten.
clearvars; clc; close all;
pdir='param_studies_ch4'; cdir='figures_ch4_color_R13'; if ~exist(cdir,'dir'), mkdir(cdir); end
ahat=8.9708e-5; E_ref=4.433e9; nu_ref=0.3395; alp_ref=5.9814e-5; T_inf=300;
Fo=@(t,h) ahat.*t./h.^2; Tst=@(T)(T-T_inf)./T_inf;
Ust=@(u,h) u./((1-nu_ref).*alp_ref.*T_inf.*h); Sst=@(s)(1+nu_ref).*s./(E_ref.*alp_ref.*T_inf);

% COLOUR style set (up to 5 curves)
STY.co={[0 0.447 0.741],[0.850 0.325 0.098],[0.466 0.674 0.188],[0.494 0.184 0.556],[0.20 0.20 0.20]};
STY.ls={'-','-','-','-','-'}; STY.mk={'o','s','^','d','v'};   % solid lines only in colour plots
STY.lw=[1.6 1.4 1.4 1.4 1.4]; FNT='Times New Roman'; FSZ=14; LGSZ=14;

studies = { ...
 'A_GPL_patterns',    {'BASE','A_GPL_O','A_GPL_X','A_GPL_V','A_GPL_A'}, {'UD','O','X','V','A'};
 'B_porosity_patterns',{'BASE','B_POR_O','B_POR_X','B_POR_V','B_POR_A'}, {'UD','O','X','V','A'};
 'E_porosity_level',  {'E_EM3_9675','BASE','E_EM3_7776'}, {'e_{m3}=0.9675','0.8604','0.7776'};
 'D_wt_low',          {'D_W_001','BASE','D_W_005','D_W_009','D_W_015'}, {'W=0.1%','0.3%','0.5%','0.9%','1.5%'};
 'D2_wt_high',        {'D2_W_010','D2_W_020','D2_W_040','D2_W_080'}, {'W=1%','2%','4%','8%'};
 'C_relaxation',      {'C_FOURIER','C_TAU_004','C_TAU_015'}, {'Fourier','\tau^*=0.04','0.15'};
 'F_end_BC',          {'BASE','F_BC_SC','F_BC_C'}, {'S-S','S-C','C-C'};
 'G_pressure',        {'G_P000','G_P010','BASE','G_P100'}, {'P_i=0','10 MPa','50 MPa','100 MPa'};
 'I_coupling',        {'BASE','I_UNCOUPLED'}, {'coupled','uncoupled'};
 'J_convection',      {'BASE','J_HC_100','J_HC_1000'}, {'h_c=10','100','1000'};
 'K_thickness',       {'BASE','K_RO_200','K_RO_500'}, {'R_o/R_i=1.5','2.0','5.0'};
 'L_layers',          {'L_NL_3','L_NL_5','BASE','L_NL_9','L_NL_15'}, {'N_L=3','5','7','9','15'};
 'Q_length',          {'Q_L_1','BASE','Q_L_5','Q_L_10'}, {'L=1','2.1','5','10'};
 'O_aspect_ab',       {'O_AB_100','BASE','O_AB_400','O_AB_1000'}, {'a/b=1.0','1.67','4','10'};
 'P_aspect_bt',       {'P_BT_010','P_BT_100','BASE'}, {'b/t=10','100','1000'};
 'P_aspect_bt_fine',  {'P_BT_100','P_BT_200','P_BT_500T','BASE','P_BT_2000T'}, {'b/t=100','200','500','1000','2000'};
 'M_gauss_shock',     {'M_GAUSS_LS','M_GAUSS_FOU'}, {'LS','Fourier'};
 'T3_theories',       {'C_FOURIER','C_TAU_015','T3_DPL','T3_GN3'}, {'Fourier','LS','DPL','GN-III'} };

%% ---- legend handling per study ----
% Default: one verified legend inside each panel.
SHARED_BOTTOM = {'B_porosity_patterns','G_pressure'};  % single legend below all 4
NUDGE_UP_P2   = {'Q_length'};                          % panel 2: raise the legend

made={}; rep={};
for si=1:size(studies,1)
    sname=studies{si,1}; cnames=studies{si,2}; labels=studies{si,3};
    D={}; ok=true;
    for ci=1:numel(cnames)
        f=fullfile(pdir,[cnames{ci} '.mat']);
        if ~exist(f,'file'), fprintf('SKIP %s\n',sname); ok=false; break; end
        D{ci}=load(f,'tv','hist_T','hist_U','r_nodes','r_all','T_all','S_tt'); %#ok<SAGROW>
    end
    if ~ok, continue; end
    shared = any(strcmp(sname,SHARED_BOTTOM));   % one legend under all 4 panels
    nudge  = any(strcmp(sname,NUDGE_UP_P2));     % panel 2: raise the legend
    f1=figure('Position',[30 50 1180 820],'Color','w','Name',sname);
    tl=tiledlayout(f1,2,2,'TileSpacing','tight','Padding','tight');
    nexttile(tl); hold on;
    for ci=1:numel(cnames), d=D{ci}; hh=d.r_nodes{end}(end)-d.r_nodes{1}(1); curve(Fo(d.tv,hh),Tst(d.hist_T),ci,STY); end
    fin(gca,FNT,FSZ,'Fo','T^*','(1) T^*(Fo)'); rep(end+1,:)=panel_legend(gca,labels,FNT,LGSZ,sname,1,shared,nudge); %#ok<SAGROW>
    nexttile(tl); hold on;
    for ci=1:numel(cnames), d=D{ci}; hh=d.r_nodes{end}(end)-d.r_nodes{1}(1); curve(Fo(d.tv,hh),Ust(d.hist_U,hh),ci,STY); end
    fin(gca,FNT,FSZ,'Fo','U^*','(2) U^*(Fo)'); rep(end+1,:)=panel_legend(gca,labels,FNT,LGSZ,sname,2,shared,nudge); %#ok<SAGROW>
    nexttile(tl); hold on;
    for ci=1:numel(cnames), d=D{ci}; Ri=d.r_nodes{1}(1); Ro=d.r_nodes{end}(end); xi=(d.r_all(:)-Ri)/(Ro-Ri); curve(xi,Tst(d.T_all),ci,STY); end
    fin(gca,FNT,FSZ,'\xi','T^*','(3) T^*(\xi)'); rep(end+1,:)=panel_legend(gca,labels,FNT,LGSZ,sname,3,shared,nudge); %#ok<SAGROW>
    nexttile(tl); hold on;
    for ci=1:numel(cnames), d=D{ci}; Ri=d.r_nodes{1}(1); Ro=d.r_nodes{end}(end); xi=(d.r_all(:)-Ri)/(Ro-Ri); curve(xi,Sst(d.S_tt),ci,STY); end
    fin(gca,FNT,FSZ,'\xi','\Sigma_{\theta\theta}','(4) \Sigma_{\theta\theta}(\xi)'); rep(end+1,:)=panel_legend(gca,labels,FNT,LGSZ,sname,4,shared,nudge); %#ok<SAGROW>
    if shared, shared_bottom_legend(tl,labels,FNT,LGSZ,sname); end
    % No sgtitle on the figure (number/caption added in the document)
    print(f1,fullfile(cdir,[sname '.png']),'-dpng','-r130'); savefig(f1,fullfile(cdir,[sname '.fig'])); close(f1);
    made{end+1}=sname; fprintf('color: %s\n',sname); %#ok<SAGROW>
end
fprintf('DONE color 4-panel: %d -> %s\n',numel(made),cdir);

function out = panel_legend(ax,labels,FNT,SZ,sname,panel,shared,nudge)
% Legend for one panel, in whichever of the three modes the study asks for:
%   shared  -> no panel legend at all; one legend is drawn under the whole
%              figure afterwards by shared_bottom_legend.
%   nudge   -> panel 2 only: the legend is placed as usual and then walked
%              upwards as far as it can go without touching a curve.
%   default -> the standard verified in-panel placement.
    if shared
        out = {sname, panel, 'shared-bottom', 0};
        return;
    end
    out = place_legend(ax,labels,FNT,SZ,sname,panel);
    if nudge && panel == 2
        out = nudge_up(ax,sname,panel);
    end
end

function shared_bottom_legend(tl,labels,FNT,SZ,sname)
% One legend for all four panels, in its own strip under the tiled layout.
% It occupies a tile of its own, so it cannot overlap any curve by
% construction -- no placement search is needed.
    axs = findobj(tl.Children,'flat','Type','axes');
    ax1 = axs(end);                       % first-created panel
    lg = legend(ax1,labels,'Orientation','horizontal','NumColumns',numel(labels), ...
                'FontSize',SZ,'FontName',FNT);
    lg.Layout.Tile = 'south';
    drawnow limitrate;
    fprintf('    %-18s one shared legend below all 4 panels (%d entries)\n',sname,numel(labels));
end

function out = nudge_up(ax,sname,panel)
% Walk an already-placed legend upwards in small steps and keep the highest
% position that still covers no plotted point. The legend is switched to
% manual positioning first; the walk stops at the first step that touches a
% curve, or when the legend would leave the top of the axes, and the last
% clean position is restored.
    lg = get(ax,'Legend');
    if isempty(lg), out = {sname,panel,'none',0}; return; end
    ln = findobj(ax,'Type','line');
    X = []; Y = [];
    for i = 1:numel(ln)
        X = [X, ln(i).XData(:).']; Y = [Y, ln(i).YData(:).']; %#ok<AGROW>
    end
    good = isfinite(X) & isfinite(Y); X = X(good); Y = Y(good);
    set(lg,'Units','normalized');
    lg.Location = 'none';                  % take manual control of Position
    best = lg.Position;  start = best(2);
    axTop = ax.Position(2) + ax.Position(4);
    step = 0.003;
    while true
        trial = best; trial(2) = trial(2) + step;
        if trial(2) + trial(4) > axTop - 0.004, break; end   % would leave the axes
        lg.Position = trial; drawnow limitrate;
        if count_covered(ax,lg,X,Y) > 0, break; end          % would touch a curve
        best = trial;
    end
    lg.Position = best; drawnow limitrate;
    n = count_covered(ax,lg,X,Y);
    fprintf('    %-18s panel %d: legend raised %.3f (of axes height %.3f), covered points = %d\n', ...
            sname, panel, best(2)-start, ax.Position(4), n);
    out = {sname, panel, 'raised', n};
end

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
