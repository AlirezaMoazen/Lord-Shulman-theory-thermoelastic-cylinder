%% claude_catalog_matrix25_4panel.m — all 25 GPL x porosity combinations in ONE 4-panel figure
%  Author request (2026-08-25): the full 5x5 GPL x porosity interaction set
%  (25 cases) overlaid in the standard Chapter-4 4-panel format, instead of
%  the 5x5 grid-of-subplots view (claude_catalog_R6_extras) or the per-
%  porosity unpacking (claude_catalog_gplpor). Same 4 quantities and display
%  standard as claude_catalog_bestworst.m:
%     (2,2,1) T* vs Fo    (2,2,2) U* vs Fo
%     (2,2,3) T* vs xi    (2,2,4) Sigma_thth vs xi
%  Legibility for 25 curves: COLOR encodes the GPL pattern (5), MARKER SHAPE
%  encodes the porosity pattern (5) — MATLAB has only 4 line styles, so
%  marker-shape is the practical realization of "style per porosity". Solid
%  connecting lines, white-face markers (Ch4 standard). Compact 10-entry
%  legend (5 GPL + 5 porosity) via dummy handles, drawn in panel 1 only.
%  Reads param_studies_ch4 (25 cached H_<GPL>_<Por>.mat); B&W -> figures_ch4_bw,
%  colour -> figures_ch4_color. New file; changes no earlier catalog or the solver.
clearvars; clc; close all;
base='c:/Users/InfosaicUser/Desktop/MSc/Lord-Shulman-theory-thermoelastic-cylinder/claude';
pdir=fullfile(base,'param_studies_ch4');
ahat=8.9708e-5; E_ref=4.433e9; nu_ref=0.3395; alp_ref=5.9814e-5; T_inf=300;
Fo=@(t,h) ahat.*t./h.^2; Tst=@(T)(T-T_inf)./T_inf;
Ust=@(u,h) u./((1-nu_ref).*alp_ref.*T_inf.*h); Sst=@(s)(1+nu_ref).*s./(E_ref.*alp_ref.*T_inf);

pat={'UD','O','X','V','A'};           % GPL index g (color) and porosity index p (marker)
% load the 25 cases into D{g,p}
D=cell(5,5);
for g=1:5, for p=1:5
    f=fullfile(pdir,sprintf('H_%s_%s.mat',pat{g},pat{p}));
    D{g,p}=load(f,'tv','hist_T','hist_U','r_nodes','r_all','T_all','S_tt');
end, end

% styling: color = GPL, marker = porosity
CO.col={[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250],[0.4940 0.1840 0.5560],[0.4660 0.6740 0.1880]};
BW.col={[0 0 0],[0.30 0.30 0.30],[0.48 0.48 0.48],[0.64 0.64 0.64],[0.78 0.78 0.78]};
mk={'o','s','^','d','v'};             % porosity marker shapes
FNT='Times New Roman'; FSZ=9;

for mode=1:2
  if mode==1, COL=BW.col; outdir=fullfile(base,'figures_ch4_bw'); else, COL=CO.col; outdir=fullfile(base,'figures_ch4_color'); end
  f1=figure('Position',[20 40 1200 860],'Color','w');
  for panel=1:4
    subplot(2,2,panel); hold on;
    for g=1:5, for p=1:5
      d=D{g,p};
      hh=d.r_nodes{end}(end)-d.r_nodes{1}(1);
      Ri=d.r_nodes{1}(1); Ro=d.r_nodes{end}(end);
      switch panel
        case 1, x=Fo(d.tv,hh);          y=Tst(d.hist_T);
        case 2, x=Fo(d.tv,hh);          y=Ust(d.hist_U,hh);
        case 3, x=(d.r_all(:)-Ri)/(Ro-Ri); y=Tst(d.T_all);
        case 4, x=(d.r_all(:)-Ri)/(Ro-Ri); y=Sst(d.S_tt);
      end
      cv(x,y,COL{g},mk{p},p);          % real curve (hidden from legend)
    end, end
    switch panel
      case 1, fn(gca,FNT,FSZ,'Fo','T^*');
      case 2, fn(gca,FNT,FSZ,'Fo','U^*');
      case 3, fn(gca,FNT,FSZ,'\xi','T^*');
      case 4, fn(gca,FNT,FSZ,'\xi','\Sigma_{\theta\theta}');
    end
    if panel==1                        % compact 10-entry legend in panel 1 only
      hG=gobjects(5,1); hP=gobjects(5,1);
      for g=1:5, hG(g)=plot(nan,nan,'-','Color',COL{g},'LineWidth',1.8,'DisplayName',['GPL-' pat{g}]); end
      for p=1:5, hP(p)=plot(nan,nan,'LineStyle','none','Color',[0 0 0],'Marker',mk{p},'MarkerFaceColor','w','MarkerSize',5.5,'DisplayName',['porosity-' pat{p}]); end
      legend([hG;hP],'Location','eastoutside','FontSize',7.5,'FontName',FNT,'NumColumns',1);
    end
  end
  print(f1,fullfile(outdir,'matrix25_4panel.png'),'-dpng','-r150'); savefig(f1,fullfile(outdir,'matrix25_4panel.fig')); close(f1);
  fprintf('matrix25_4panel -> %s\n',outdir);
end
disp('MATRIX25 4PANEL DONE');

function cv(x,y,col,mkr,poff)
  x=x(:); y=y(:);
  if all(isnan(y))||numel(x)<2, return; end
  xm=x; for i=2:numel(xm), if xm(i)<=xm(i-1), xm(i)=xm(i-1)+1e-12; end, end
  nP=max(300,numel(x)); xf=linspace(xm(1),xm(end),nP); yf=interp1(xm,y,xf,'makima');
  % 5 markers per curve, staggered by porosity index so overlapping curves' markers don't collide
  mi=unique(round(linspace(1+round((poff-1)*nP/40),nP,5)));  mi=mi(mi>=1 & mi<=nP);
  plot(xf,yf,'Color',col,'LineStyle','-','LineWidth',1.1,'Marker',mkr, ...
       'MarkerIndices',mi,'MarkerSize',4.5,'MarkerEdgeColor',col,'MarkerFaceColor','w','HandleVisibility','off');
end
function fn(ax,FNT,FSZ,xl,yl)
  grid(ax,'on'); box(ax,'on'); set(ax,'FontName',FNT,'FontSize',FSZ);
  xlabel(ax,xl,'FontName',FNT); ylabel(ax,yl,'FontName',FNT);
end
