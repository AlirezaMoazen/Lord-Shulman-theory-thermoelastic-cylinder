%% catalog_matrix25_4panel_R3.m — all 25 GPL x porosity combinations in ONE 4-panel figure
%  Same figure, data and encoding as R2; the display is brought up to the
%  Chapter-4 standard used by catalog_R12_color and catalog_conv2_R4:
%    * subplot(2,2,n) -> tiledlayout with tight spacing and padding, so the four
%      panels are noticeably larger inside a slightly larger canvas;
%    * axis fonts 9 pt -> 14 pt;
%    * the 10-entry key (5 GPL colours + 5 porosity markers) is drawn in EVERY
%      panel, not only in panel 1, in two columns so it stays compact, and each
%      placement is verified not to cover any plotted point;
%    * output goes to the R12 figure folders.
%  Encoding (unchanged): COLOR = GPL pattern, MARKER SHAPE = porosity pattern —
%  MATLAB has only 4 line styles, so marker shape is the practical realization
%  of "one style per porosity pattern". Solid connecting lines, white-face
%  markers (Ch4 standard). Panels:
%     (1) T* vs Fo   (2) U* vs Fo   (3) T* vs xi   (4) Sigma_thth vs xi
%  Reads param_studies_ch4 (25 cached H_<GPL>_<Por>.mat).
clearvars; clc; close all;
base='c:/Users/InfosaicUser/Desktop/MSc/Lord-Shulman-theory-thermoelastic-cylinder/claude';
pdir=fullfile(base,'param_studies_ch4');
ahat=8.9708e-5; E_ref=4.433e9; nu_ref=0.3395; alp_ref=5.9814e-5; T_inf=300;
Fo=@(t,h) ahat.*t./h.^2; Tst=@(T)(T-T_inf)./T_inf;
Ust=@(u,h) u./((1-nu_ref).*alp_ref.*T_inf.*h); Sst=@(s)(1+nu_ref).*s./(E_ref.*alp_ref.*T_inf);

pat={'UD','O','X','V','A'};           % GPL index g (color) and porosity index p (marker)
D=cell(5,5);
for g=1:5, for p=1:5
    f=fullfile(pdir,sprintf('H_%s_%s.mat',pat{g},pat{p}));
    D{g,p}=load(f,'tv','hist_T','hist_U','r_nodes','r_all','T_all','S_tt');
end, end

% styling: color = GPL, marker = porosity
CO.col={[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250],[0.4940 0.1840 0.5560],[0.4660 0.6740 0.1880]};
BW.col={[0 0 0],[0.30 0.30 0.30],[0.48 0.48 0.48],[0.64 0.64 0.64],[0.78 0.78 0.78]};
mk={'o','s','^','d','v'};             % porosity marker shapes
FNT='Times New Roman'; FSZ=14; LGSZ=11;

rep={};
for mode=1:2
  if mode==1, COL=BW.col; outdir=fullfile(base,'figures_ch4_R12'); tag='bw';
  else,       COL=CO.col; outdir=fullfile(base,'figures_ch4_color_R12'); tag='color'; end
  if ~exist(outdir,'dir'), mkdir(outdir); end
  f1=figure('Position',[20 40 1280 920],'Color','w');
  tl=tiledlayout(f1,2,2,'TileSpacing','tight','Padding','tight');
  for panel=1:4
    ax=nexttile(tl,panel); hold(ax,'on');
    for g=1:5, for p=1:5
      d=D{g,p};
      hh=d.r_nodes{end}(end)-d.r_nodes{1}(1);
      Ri=d.r_nodes{1}(1); Ro=d.r_nodes{end}(end);
      switch panel
        case 1, x=Fo(d.tv,hh);             y=Tst(d.hist_T);
        case 2, x=Fo(d.tv,hh);             y=Ust(d.hist_U,hh);
        case 3, x=(d.r_all(:)-Ri)/(Ro-Ri); y=Tst(d.T_all);
        case 4, x=(d.r_all(:)-Ri)/(Ro-Ri); y=Sst(d.S_tt);
      end
      cv(ax,x,y,COL{g},mk{p},p);          % real curve (hidden from legend)
    end, end
    switch panel
      case 1, fn(ax,FNT,FSZ,'Fo','T^*');
      case 2, fn(ax,FNT,FSZ,'Fo','U^*');
      case 3, fn(ax,FNT,FSZ,'\xi','T^*');
      case 4, fn(ax,FNT,FSZ,'\xi','\Sigma_{\theta\theta}');
    end
    % 10-entry key in every panel, via dummy handles (two columns to stay compact)
    hG=gobjects(5,1); hP=gobjects(5,1); lab=cell(10,1);
    for g=1:5
        hG(g)=plot(ax,nan,nan,'-','Color',COL{g},'LineWidth',1.8);
        lab{g}=['GPL-' pat{g}];
    end
    for p=1:5
        hP(p)=plot(ax,nan,nan,'LineStyle','none','Color',[0 0 0],'Marker',mk{p}, ...
                   'MarkerFaceColor','w','MarkerSize',6);
        lab{5+p}=['porosity-' pat{p}];
    end
    rep(end+1,:)=place_legend(ax,[hG;hP],lab,FNT,LGSZ,['matrix25_4panel_' tag],panel); %#ok<SAGROW>
  end
  print(f1,fullfile(outdir,'matrix25_4panel.png'),'-dpng','-r150');
  savefig(f1,fullfile(outdir,'matrix25_4panel.fig')); close(f1);
  fprintf('matrix25_4panel -> %s\n',outdir);
end
nz=sum(cellfun(@(v)v>0,rep(:,4)));
fprintf('MATRIX25 4PANEL DONE — legends placed: %d, still covering data: %d\n',size(rep,1),nz);

%% ---- helpers ----
function out = place_legend(ax,h,labels,FNT,SZ,sname,panel)
% As in catalog_R12_color, but for a legend built from explicit dummy handles.
% Every candidate location is tried and the overlap with the plotted data is
% measured directly (data points mapped into figure-normalised coordinates and
% tested against the legend rectangle); the first location with zero covered
% points wins, and if none is clean the legend goes outside the axes, which
% cannot overlap by construction.
    cand = {'best','northeast','northwest','southeast','southwest','north','south','east','west'};
    ln = findobj(ax,'Type','line');
    X = []; Y = [];
    for i = 1:numel(ln)
        X = [X, ln(i).XData(:).']; Y = [Y, ln(i).YData(:).']; %#ok<AGROW>
    end
    good = isfinite(X) & isfinite(Y); X = X(good); Y = Y(good);
    bestLoc = cand{1}; bestN = inf;
    for c = 1:numel(cand)
        lg = legend(ax,h,labels,'Location',cand{c},'FontSize',SZ,'FontName',FNT,'NumColumns',2);
        drawnow limitrate;
        n = count_covered(ax,lg,X,Y);
        if n < bestN, bestN = n; bestLoc = cand{c}; end
        if n == 0, break; end
    end
    if bestN > 0
        lg = legend(ax,h,labels,'Location','eastoutside','FontSize',SZ,'FontName',FNT,'NumColumns',1);
        drawnow limitrate;
        bestLoc = 'eastoutside'; bestN = 0;
    else
        lg = legend(ax,h,labels,'Location',bestLoc,'FontSize',SZ,'FontName',FNT,'NumColumns',2); %#ok<NASGU>
    end
    fprintf('    %-22s panel %d: legend %-13s covered points = %d\n', sname, panel, bestLoc, bestN);
    out = {sname, panel, bestLoc, bestN};
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

function cv(ax,x,y,col,mkr,poff)
  x=x(:); y=y(:);
  if all(isnan(y))||numel(x)<2, return; end
  xm=x; for i=2:numel(xm), if xm(i)<=xm(i-1), xm(i)=xm(i-1)+1e-12; end, end
  nP=max(300,numel(x)); xf=linspace(xm(1),xm(end),nP); yf=interp1(xm,y,xf,'makima');
  % 5 markers per curve, staggered by porosity index so overlapping curves' markers don't collide
  mi=unique(round(linspace(1+round((poff-1)*nP/40),nP,5)));  mi=mi(mi>=1 & mi<=nP);
  plot(ax,xf,yf,'Color',col,'LineStyle','-','LineWidth',1.1,'Marker',mkr, ...
       'MarkerIndices',mi,'MarkerSize',5,'MarkerEdgeColor',col,'MarkerFaceColor','w','HandleVisibility','off');
end
function fn(ax,FNT,FSZ,xl,yl)
  grid(ax,'on'); box(ax,'on'); set(ax,'FontName',FNT,'FontSize',FSZ);
  xlabel(ax,xl,'FontName',FNT); ylabel(ax,yl,'FontName',FNT);
end
