%% catalog_bestworst_R2.m — best/worst GPL x porosity combinations, 4-panel figure
%  Overlays the best and worst combinations in BOTH thermal and mechanical
%  terms, against the UD-UD reference, drawn from the 25-combination data
%  (H_<GPL>_<Por>.mat). Extremes (final outer-surface T* and peak
%  hoop stress) computed from the saved results:
%    best thermal   = V-A  (outer T* = 0.034)     worst thermal   = A-UD (0.896)
%    best mechanical= UD-UD (peak hoop 2.11)       worst mechanical= X-V  (4.20)
%  UD-UD is both the reference and the best-mechanical case, so four curves suffice.
%  Same 4-panel format & Heydarpour convention as the main catalog script;
%  title-free, legend kept. B&W (-> figures_ch4_bw) and colour (-> figures_ch4_color).
clearvars; clc; close all;
base='c:/Users/InfosaicUser/Desktop/MSc/Lord-Shulman-theory-thermoelastic-cylinder/claude';
pdir=fullfile(base,'param_studies_ch4');
ahat=8.9708e-5; E_ref=4.433e9; nu_ref=0.3395; alp_ref=5.9814e-5; T_inf=300;
Fo=@(t,h) ahat.*t./h.^2; Tst=@(T)(T-T_inf)./T_inf;
Ust=@(u,h) u./((1-nu_ref).*alp_ref.*T_inf.*h); Sst=@(s)(1+nu_ref).*s./(E_ref.*alp_ref.*T_inf);
% UD-UD reference; V-A best thermal & best mechanical (inner-surface hoop); A-UD worst thermal;
% X-V worst mechanical; O-A second-best mechanical (also second-best thermal). Legend spells out
% GPL-/porosity- per label; best/worst still spelled out in the caption and §4-13 text.
cases ={'H_UD_UD','H_V_A','H_A_UD','H_X_V','H_O_A'};
labels={'GPL-UD, porosity-UD','GPL-V, porosity-A','GPL-A, porosity-UD','GPL-X, porosity-V','GPL-O, porosity-A'};
D={}; for ci=1:5, D{ci}=load(fullfile(pdir,[cases{ci} '.mat']),'tv','hist_T','hist_U','r_nodes','r_all','T_all','S_tt'); end
BW.co={[0 0 0],[0.45 0.45 0.45],[0 0 0],[0.55 0.55 0.55],[0.72 0.72 0.72]}; BW.ls={'-','-','--','--',':'}; BW.mk={'o','^','s','d','v'}; BW.lw=[1.5 1.4 1.4 1.4 1.3];
CO.co={[0.20 0.20 0.20],[0 0.447 0.741],[0.850 0.325 0.098],[0.466 0.674 0.188],[0.494 0.184 0.556]}; CO.ls={'-','-','-','-','-'}; CO.mk={'o','^','s','d','v'}; CO.lw=[1.6 1.5 1.5 1.5 1.4];
FNT='Times New Roman'; FSZ=9;
for mode=1:2
  if mode==1, STY=BW; outdir=fullfile(base,'figures_ch4_bw'); else, STY=CO; outdir=fullfile(base,'figures_ch4_color'); end
  f1=figure('Position',[30 50 1180 820],'Color','w');
  subplot(2,2,1); hold on;
  for ci=1:5, d=D{ci}; hh=d.r_nodes{end}(end)-d.r_nodes{1}(1); cv(Fo(d.tv,hh),Tst(d.hist_T),ci,STY); end
  fn(gca,FNT,FSZ,'Fo','T^*'); legend(labels,'Location','best','FontSize',8,'FontName',FNT);
  subplot(2,2,2); hold on;
  for ci=1:5, d=D{ci}; hh=d.r_nodes{end}(end)-d.r_nodes{1}(1); cv(Fo(d.tv,hh),Ust(d.hist_U,hh),ci,STY); end
  fn(gca,FNT,FSZ,'Fo','U^*');
  subplot(2,2,3); hold on;
  for ci=1:5, d=D{ci}; Ri=d.r_nodes{1}(1); Ro=d.r_nodes{end}(end); xi=(d.r_all(:)-Ri)/(Ro-Ri); cv(xi,Tst(d.T_all),ci,STY); end
  fn(gca,FNT,FSZ,'\xi','T^*');
  subplot(2,2,4); hold on;
  for ci=1:5, d=D{ci}; Ri=d.r_nodes{1}(1); Ro=d.r_nodes{end}(end); xi=(d.r_all(:)-Ri)/(Ro-Ri); cv(xi,Sst(d.S_tt),ci,STY); end
  fn(gca,FNT,FSZ,'\xi','\Sigma_{\theta\theta}');
  print(f1,fullfile(outdir,'bestworst.png'),'-dpng','-r130'); savefig(f1,fullfile(outdir,'bestworst.fig')); close(f1);
  fprintf('bestworst -> %s\n',outdir);
end
disp('BESTWORST DONE');
function cv(x,y,ci,STY)
  k=mod(ci-1,numel(STY.co))+1; x=x(:); y=y(:);
  if all(isnan(y))||numel(x)<2, return; end
  xm=x; for i=2:numel(xm), if xm(i)<=xm(i-1), xm(i)=xm(i-1)+1e-12; end, end
  nP=max(300,numel(x)); xf=linspace(xm(1),xm(end),nP); yf=interp1(xm,y,xf,'makima');
  mi=unique(round(linspace(1,nP,8)));
  plot(xf,yf,'Color',STY.co{k},'LineStyle',STY.ls{k},'LineWidth',STY.lw(k),'Marker',STY.mk{k},'MarkerIndices',mi,'MarkerSize',4.5,'MarkerFaceColor','w');
end
function fn(ax,FNT,FSZ,xl,yl)
  grid(ax,'on'); box(ax,'on'); set(ax,'FontName',FNT,'FontSize',FSZ);
  xlabel(ax,xl,'FontName',FNT); ylabel(ax,yl,'FontName',FNT);
end
