em3=0.8604; NL=7;
em1=(pi/2)*(1-em3); em2=(1-em3)/(1-2/pi); em4=(pi/4)*em3; em5=em4;
f.UD=@(z) em3+0*z; f.O=@(z) 1-em1*cos(pi*z); f.X=@(z) 1-em2*(1-cos(pi*z));
f.V=@(z) 2*em4*cos(pi*z/2+pi/4); f.A=@(z) 2*em5*cos(pi*z/2-pi/4);
clipf=@(p) max(0,min(1,p));
z=linspace(-0.5,0.5,801); e=1:NL; zl=((e-0.5)/NL)-0.5;   % centered layer mid-points (same as solver)
names={'UD','O','X','V','A'};
fprintf('em1=%.4f em2=%.4f em4=em5=%.4f  2*em4=%.4f\n',em1,em2,em4,2*em4);
zc=(acos(1/(2*em4))-pi/4)*2/pi; fprintf('V clip threshold: zeta < %.4f (P_m>1 for inner %.1f%% of wall)\n',zc,100*(zc+0.5));
fprintf('layer zeta: '); fprintf('%.4f ',zl); fprintf('\n');
for n=1:5
  g=f.(names{n}); raw=g(zl); cl=clipf(raw);
  fprintf('%s raw: ',names{n}); fprintf('%.4f ',raw); fprintf('\n%s clip: ',names{n}); fprintf('%.4f ',cl); fprintf('\n');
  fprintf('%s mean over wall (continuous) raw=%.4f clipped=%.4f ; mean over 7 layers raw=%.4f clipped=%.4f ; UD target=%.4f ; P_f=Pm^2 layers: ',names{n},mean(g(z)),mean(clipf(g(z))),mean(raw),mean(cl),em3); fprintf('%.4f ',cl.^2); fprintf('\n');
end
col={[0 0.447 0.741],[0.85 0.325 0.098],[0.929 0.694 0.125],[0.494 0.184 0.556],[0.466 0.674 0.188]};
fig=figure('Position',[50 50 1500 480],'Color','w');
subplot(1,3,1); hold on; box on; grid on;
for n=1:5, plot(z,clipf(f.(names{n})(z)),'-','Color',col{n},'LineWidth',2); end
for n=1:5, plot(zl,clipf(f.(names{n})(zl)),'o','Color',col{n},'MarkerFaceColor','w','MarkerSize',6,'HandleVisibility','off'); end
yline(1,'k:','LineWidth',1,'HandleVisibility','off');
xlabel('\zeta = (r_m-(R_i+R_o)/2)/l   (inner face \leftarrow 0 \rightarrow outer face)'); ylabel('P_m after clipping (\rho/\rho_s)');
title('(a) P_m used by the solver, all patterns (e_{m3}=0.8604)'); legend(names,'Location','southoutside','Orientation','horizontal'); ylim([0 1.1]); xlim([-0.5 0.5]);
for k=1:2
  nm=names{3+k}; g=f.(nm); subplot(1,3,1+k); hold on; box on; grid on;
  yl=[0 1.45]; 
  zc2=find(g(z)>1); 
  if ~isempty(zc2), patch([z(zc2(1)) z(zc2(end)) z(zc2(end)) z(zc2(1))],[yl(1) yl(1) yl(2) yl(2)],[1 0.85 0.85],'EdgeColor','none','FaceAlpha',0.6,'HandleVisibility','off'); end
  plot(z,g(z),'--','Color',[0.4 0.4 0.4],'LineWidth',1.6);
  plot(z,clipf(g(z)),'-','Color',col{3+k},'LineWidth',2.4);
  plot(zl,clipf(g(zl)),'o','Color',col{3+k},'MarkerFaceColor',col{3+k},'MarkerSize',7);
  yline(1,'k:','LineWidth',1.2); yline(em3,'-.','Color',[0.2 0.2 0.2],'LineWidth',1);
  text(mean(z(zc2([1 end]))),1.37,'clipped to 1 (pink)','HorizontalAlignment','center','FontSize',9,'Color',[0.7 0 0]);
  if k==1, ttl='P_m = 2 e_{m4} cos(\pi\zeta/2 + \pi/4)'; else, ttl='P_m = 2 e_{m5} cos(\pi\zeta/2 - \pi/4)'; end
  xlabel({'\zeta','dashed: raw formula; solid: after clip','dots: 7 layer mid-points; thin dash-dot: UD 0.8604'},'FontSize',9); ylabel('P_m'); title(sprintf('(%c) %s-pattern: %s',char('a'+k),nm,ttl)); ylim(yl); xlim([-0.5 0.5]);
end
exportgraphics(fig,'C:/Users/InfosaicUser/Desktop/MSc/Lord-Shulman-theory-thermoelastic-cylinder/claude/figures_ch123/AUTHOR_Pm_clipping_VA_R1.png','Resolution',150);
disp('saved');
