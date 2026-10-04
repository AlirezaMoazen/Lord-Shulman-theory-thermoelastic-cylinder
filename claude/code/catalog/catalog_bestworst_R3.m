%% catalog_bestworst_R3.m — best/worst GPL x porosity combinations, 4-panel figure
%  Overlays the best and worst combinations in BOTH thermal and mechanical terms
%  against the UD-UD reference, drawn from the 25-combination data
%  (H_<GPL>_<Por>.mat). Extremes (final outer-surface T* and peak hoop stress)
%  computed from the saved results:
%    best thermal    = V-A  (outer T* = 0.034)    worst thermal    = A-UD (0.896)
%    best mechanical = UD-UD (peak hoop 2.11)     worst mechanical = X-V  (4.20)
%  UD-UD is both the reference and the best-mechanical case, so five curves cover
%  the reference plus both extremes in both senses.
%
%  R3 (2026-10-04): same figure and same data as R2; the display is brought to
%  the Chapter-4 standard the main catalog has used since R9/R10, which this
%  figure never received:
%    * subplot(2,2,n) -> tiledlayout with tight spacing and padding;
%    * axis and legend fonts 9 pt -> 14 pt (legend 12 pt, since the five labels
%      spell out both patterns and are long);
%    * a legend on EVERY panel, each verified not to cover any plotted point and
%      then pinned (see finalize_legends).
%  Output: figures_ch4_R18 (B&W) and figures_ch4_color_R18 (colour).
clearvars; clc; close all;
base='c:/Users/InfosaicUser/Desktop/MSc/Lord-Shulman-theory-thermoelastic-cylinder/claude';
pdir=fullfile(base,'param_studies_ch4');
ahat=8.9708e-5; E_ref=4.433e9; nu_ref=0.3395; alp_ref=5.9814e-5; T_inf=300;
Fo=@(t,h) ahat.*t./h.^2; Tst=@(T)(T-T_inf)./T_inf;
Ust=@(u,h) u./((1-nu_ref).*alp_ref.*T_inf.*h); Sst=@(s)(1+nu_ref).*s./(E_ref.*alp_ref.*T_inf);

cases ={'H_UD_UD','H_V_A','H_A_UD','H_X_V','H_O_A'};
labels={'GPL-UD, porosity-UD','GPL-V, porosity-A','GPL-A, porosity-UD','GPL-X, porosity-V','GPL-O, porosity-A'};
D={}; for ci=1:5, D{ci}=load(fullfile(pdir,[cases{ci} '.mat']),'tv','hist_T','hist_U','r_nodes','r_all','T_all','S_tt'); end

BW.co={[0 0 0],[0.45 0.45 0.45],[0 0 0],[0.55 0.55 0.55],[0.72 0.72 0.72]};
BW.ls={'-','-','--','--',':'}; BW.mk={'o','^','s','d','v'}; BW.lw=[1.5 1.4 1.4 1.4 1.3];
CO.co={[0.20 0.20 0.20],[0 0.447 0.741],[0.850 0.325 0.098],[0.466 0.674 0.188],[0.494 0.184 0.556]};
CO.ls={'-','-','-','-','-'}; CO.mk={'o','^','s','d','v'}; CO.lw=[1.6 1.5 1.5 1.5 1.4];
FNT='Times New Roman'; FSZ=14; LGSZ=12;

rep={};
for mode=1:2
  if mode==1, STY=BW; outdir=fullfile(base,'figures_ch4_R18');
  else,       STY=CO; outdir=fullfile(base,'figures_ch4_color_R18'); end
  if ~exist(outdir,'dir'), mkdir(outdir); end
  f1=figure('Position',[30 50 1180 820],'Color','w','Name','bestworst');
  tl=tiledlayout(f1,2,2,'TileSpacing','tight','Padding','tight');
  nexttile(tl); hold on;
  for ci=1:5, d=D{ci}; hh=d.r_nodes{end}(end)-d.r_nodes{1}(1); curve(Fo(d.tv,hh),Tst(d.hist_T),ci,STY); end
  fin(gca,FNT,FSZ,'Fo','T^*'); place_legend(gca,labels,FNT,LGSZ);
  nexttile(tl); hold on;
  for ci=1:5, d=D{ci}; hh=d.r_nodes{end}(end)-d.r_nodes{1}(1); curve(Fo(d.tv,hh),Ust(d.hist_U,hh),ci,STY); end
  fin(gca,FNT,FSZ,'Fo','U^*'); place_legend(gca,labels,FNT,LGSZ);
  nexttile(tl); hold on;
  for ci=1:5, d=D{ci}; Ri=d.r_nodes{1}(1); Ro=d.r_nodes{end}(end); xi=(d.r_all(:)-Ri)/(Ro-Ri); curve(xi,Tst(d.T_all),ci,STY); end
  fin(gca,FNT,FSZ,'\xi','T^*'); place_legend(gca,labels,FNT,LGSZ);
  nexttile(tl); hold on;
  for ci=1:5, d=D{ci}; Ri=d.r_nodes{1}(1); Ro=d.r_nodes{end}(end); xi=(d.r_all(:)-Ri)/(Ro-Ri); curve(xi,Sst(d.S_tt),ci,STY); end
  fin(gca,FNT,FSZ,'\xi','\Sigma_{\theta\theta}'); place_legend(gca,labels,FNT,LGSZ);
  r=finalize_legends(f1,labels,FNT,LGSZ,'bestworst'); rep=[rep; r];
  print(f1,fullfile(outdir,'bestworst.png'),'-dpng','-r130');
  savefig(f1,fullfile(outdir,'bestworst.fig')); close(f1);
  fprintf('bestworst -> %s\n',outdir);
end
nz=sum(cellfun(@(v)v>0,rep(:,4)));
fprintf('BESTWORST DONE — legends placed: %d, still covering data: %d\n',size(rep,1),nz);
%% ---- helpers ----
function place_legend(ax,labels,FNT,SZ)
% First-pass placement: try each candidate location, draw, and measure how many
% plotted points fall inside the legend rectangle. The first clean location is
% KEPT (the legend is not re-created afterwards, so the object measured is the
% object that stays); if none is clean the legend goes outside the axes, where
% it cannot overlap. finalize_legends re-checks all of this once the layout is
% final.
    cand = {'best','northeast','northwest','southeast','southwest','north','south','east','west'};
    [X,Y] = line_points(ax);
    bestN = inf;
    for c = 1:numel(cand)
        lg = legend(ax,labels,'Location',cand{c},'FontSize',SZ,'FontName',FNT);
        drawnow;
        n = count_covered(ax,lg,X,Y);
        if n < bestN, bestN = n; end
        if n == 0, break; end
    end
    if bestN > 0
        legend(ax,labels,'Location','eastoutside','FontSize',SZ,'FontName',FNT);
        drawnow;
    end
end

function rep = finalize_legends(f1,labels,FNT,SZ,sname)
% Re-check every legend AFTER all four panels exist, then freeze it. A legend on
% an automatic Location is re-solved whenever the tiled layout reflows, and the
% layout reflows as each later panel is added, so a placement that was clean
% when its own panel was built can drift onto the curves before printing. Here
% the geometry is final, so what is measured is what is saved. In-axes legends
% are pinned; legends sitting OUTSIDE the axes are left on their Location,
% because the strip they occupy is reserved by the layout only while the
% Location still says "outside" -- pinning one frees the strip and the axes
% grows back under it.
    drawnow;
    axs  = flipud(findobj(f1,'Type','axes'));
    cand = {'best','northeast','northwest','southeast','southwest','north','south','east','west'};
    rep  = {};
    for p = 1:numel(axs)
        ax = axs(p); lg = get(ax,'Legend');
        if isempty(lg), continue; end
        [X,Y] = line_points(ax);
        n = count_covered(ax,lg,X,Y);
        loc = lg.Location;
        if n > 0
            for c = 1:numel(cand)
                lg = legend(ax,labels,'Location',cand{c},'FontSize',SZ,'FontName',FNT);
                drawnow; n = count_covered(ax,lg,X,Y); loc = cand{c};
                if n == 0, break; end
            end
            if n > 0
                lg = legend(ax,labels,'Location','eastoutside','FontSize',SZ,'FontName',FNT);
                drawnow; loc = 'eastoutside'; n = count_covered(ax,lg,X,Y);
            end
        end
        if isempty(strfind(loc,'outside')) %#ok<STREMP>
            P = lg.Position; lg.Location = 'none'; lg.Position = P; drawnow;
        end
        n = count_covered(ax,lg,X,Y);
        fprintf('    %-16s panel %d: legend %-13s covered points = %d\n',sname,p,loc,n);
        rep(end+1,:) = {sname,p,loc,n}; %#ok<AGROW>
    end
end

function [X,Y] = line_points(ax)
% every finite plotted point in the axes
    ln = findobj(ax,'Type','line');
    X = []; Y = [];
    for i = 1:numel(ln)
        X = [X, ln(i).XData(:).']; Y = [Y, ln(i).YData(:).']; %#ok<AGROW>
    end
    good = isfinite(X) & isfinite(Y); X = X(good); Y = Y(good);
end

function n = count_covered(ax,lg,X,Y)
% number of plotted points falling inside the legend rectangle
    set(lg,'Units','normalized'); LP = lg.Position;
    P  = ax.Position;
    xl = xlim(ax); yl = ylim(ax);
    if strcmp(ax.XScale,'log'), xs = (log10(X)-log10(xl(1)))/(log10(xl(2))-log10(xl(1)));
    else,                       xs = (X-xl(1))/(xl(2)-xl(1)); end
    if strcmp(ax.YScale,'log'), ys = (log10(Y)-log10(yl(1)))/(log10(yl(2))-log10(yl(1)));
    else,                       ys = (Y-yl(1))/(yl(2)-yl(1)); end
    vis = xs>=0 & xs<=1 & ys>=0 & ys<=1;
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
function fin(ax,FNT,FSZ,xl,yl)
    grid(ax,'on'); box(ax,'on'); set(ax,'FontName',FNT,'FontSize',FSZ);
    xlabel(ax,xl,'FontName',FNT); ylabel(ax,yl,'FontName',FNT);
end
