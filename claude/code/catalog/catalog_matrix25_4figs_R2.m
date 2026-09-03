%% catalog_matrix25_4figs_R2.m — all 25 GPL x porosity combinations, as 4 SEPARATE figures
%  Same content as catalog_matrix25_4panel.m but split into 4
%  standalone figures, one per quantity, so each is full-size and more
%  legible than a 2x2 panel:
%     matrix25_T_Fo   — T* vs Fo
%     matrix25_U_Fo   — U* vs Fo
%     matrix25_T_xi   — T* vs xi
%     matrix25_S_xi   — Sigma_thth vs xi
%  Same legibility scheme and display standard: COLOR = GPL pattern (5),
%  MARKER SHAPE = porosity pattern (5), solid lines, white-face markers,
%  compact 10-entry legend (5 GPL + 5 porosity) via dummy handles on each
%  figure. Reads the 25 cached H_<GPL>_<Por>.mat (no solver runs).
%  B&W -> figures_ch4_bw, colour -> figures_ch4_color.
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

CO.col={[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250],[0.4940 0.1840 0.5560],[0.4660 0.6740 0.1880]};
BW.col={[0 0 0],[0.30 0.30 0.30],[0.48 0.48 0.48],[0.64 0.64 0.64],[0.78 0.78 0.78]};
mk={'o','s','^','d','v'};             % porosity marker shapes
FNT='Times New Roman'; FSZ=11;
quant={ {'T_Fo','Fo','T^*'}, {'U_Fo','Fo','U^*'}, {'T_xi','\xi','T^*'}, {'S_xi','\xi','\Sigma_{\theta\theta}'} };

for mode=1:2
  if mode==1, COL=BW.col; outdir=fullfile(base,'figures_ch4_bw'); else, COL=CO.col; outdir=fullfile(base,'figures_ch4_color'); end
  for qi=1:4
    tag=quant{qi}{1}; xl=quant{qi}{2}; yl=quant{qi}{3};
    fg=figure('Position',[60 60 820 600],'Color','w'); hold on;
    for g=1:5, for p=1:5
      d=D{g,p};
      hh=d.r_nodes{end}(end)-d.r_nodes{1}(1);
      Ri=d.r_nodes{1}(1); Ro=d.r_nodes{end}(end);
      switch qi
        case 1, x=Fo(d.tv,hh);              y=Tst(d.hist_T);
        case 2, x=Fo(d.tv,hh);              y=Ust(d.hist_U,hh);
        case 3, x=(d.r_all(:)-Ri)/(Ro-Ri);  y=Tst(d.T_all);
        case 4, x=(d.r_all(:)-Ri)/(Ro-Ri);  y=Sst(d.S_tt);
      end
      cv(x,y,COL{g},mk{p},p);
    end, end
    grid on; box on; set(gca,'FontName',FNT,'FontSize',FSZ);
    xlabel(xl,'FontName',FNT); ylabel(yl,'FontName',FNT);
    hG=gobjects(5,1); hP=gobjects(5,1);
    for g=1:5, hG(g)=plot(nan,nan,'-','Color',COL{g},'LineWidth',1.8,'DisplayName',['GPL-' pat{g}]); end
    for p=1:5, hP(p)=plot(nan,nan,'LineStyle','none','Color',[0 0 0],'Marker',mk{p},'MarkerFaceColor','w','MarkerSize',6,'DisplayName',['porosity-' pat{p}]); end
    legend([hG;hP],'Location','eastoutside','FontSize',9,'FontName',FNT);
    print(fg,fullfile(outdir,['matrix25_' tag '.png']),'-dpng','-r150'); savefig(fg,fullfile(outdir,['matrix25_' tag '.fig'])); close(fg);
    fprintf('matrix25_%s -> %s\n',tag,outdir);
  end
end
disp('MATRIX25 4FIGS DONE');

function cv(x,y,col,mkr,poff)
  x=x(:); y=y(:);
  if all(isnan(y))||numel(x)<2, return; end
  xm=x; for i=2:numel(xm), if xm(i)<=xm(i-1), xm(i)=xm(i-1)+1e-12; end, end
  nP=max(300,numel(x)); xf=linspace(xm(1),xm(end),nP); yf=interp1(xm,y,xf,'makima');
  mi=unique(round(linspace(1+round((poff-1)*nP/40),nP,6)));  mi=mi(mi>=1 & mi<=nP);
  plot(xf,yf,'Color',col,'LineStyle','-','LineWidth',1.1,'Marker',mkr, ...
       'MarkerIndices',mi,'MarkerSize',5,'MarkerEdgeColor',col,'MarkerFaceColor','w','HandleVisibility','off');
end
