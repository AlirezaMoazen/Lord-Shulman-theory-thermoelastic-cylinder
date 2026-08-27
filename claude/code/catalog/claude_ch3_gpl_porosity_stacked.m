%% claude_ch3_gpl_porosity_stacked.m — GPL + porosity pattern schematics, stacked
%  Author request: combine GPL_patterns_schematic.png and
%  porosity_patterns_schematic.png (both from claude_ch123_figs.m) into ONE
%  figure, stacked vertically (top = GPL, bottom = porosity) rather than
%  side by side -- the two have different x-axes (discrete layer index vs
%  continuous xi), so they are two stacked panels, not a shared-axis overlay.
%  Same data/formulas/styling as claude_ch123_figs.m (ground-truth: frozen
%  solver claude_R7.m). New file; does not modify claude_ch123_figs.m or its
%  standalone PNGs.
clearvars; clc; close all;
outdir = 'C:/Users/InfosaicUser/Desktop/MSc/Lord-Shulman-theory-thermoelastic-cylinder/claude/figures_ch123';
if ~exist(outdir,'dir'), mkdir(outdir); end

try
    set(groot,'defaultAxesFontName','Times New Roman');
    set(groot,'defaultTextFontName','Times New Roman');
    set(groot,'defaultLegendFontName','Times New Roman');
catch
end
CO = {[0 0.447 0.741],[0.850 0.325 0.098],[0.929 0.694 0.125],...
      [0.494 0.184 0.556],[0.466 0.674 0.188]};
MK = {'o','s','^','d','v'};
FSZ = 11;
NL = 7;
pat = {'UD','O','X','V','A'};

fig = figure('Units','inches','Position',[1 1 7 9],'Color','w');

%% ---- top panel: GPL weight-fraction patterns vs layer index ----
ax1 = subplot(2,1,1); hold(ax1,'on'); box(ax1,'on');
W = 0.003;
e = (1:NL)';  hlf = (NL+1)/2;
Wg.UD = W*ones(NL,1);
Wg.O  = 4*W*((hlf) - abs(e-hlf))/(NL+2);
Wg.X  = 4*W*(0.5 + abs(e-hlf))/(NL+2);
Wg.V  = 2*W*e/(NL+1);
Wg.A  = 2*W*(NL+1-e)/(NL+1);
for ci = 1:5
    plot(ax1, e, Wg.(pat{ci})*100,'LineStyle','-','Color',CO{ci},'LineWidth',1.8,...
         'Marker',MK{ci},'MarkerSize',7,'MarkerFaceColor','w');
end
grid(ax1,'on'); set(ax1,'FontSize',FSZ,'XTick',1:NL);
xlabel(ax1,'layer index  e  ( 1 = inner  \rightarrow  7 = outer )','FontSize',FSZ);
ylabel(ax1,'GPL weight fraction  W_{GPL}^{(e)}  (%)','FontSize',FSZ);
legend(ax1,pat,'Location','northoutside','Orientation','horizontal','FontSize',10);
xlim(ax1,[0.7 NL+0.3]); ylim(ax1,[0 0.62]);

%% ---- bottom panel: porosity coefficient vs xi ----
ax2 = subplot(2,1,2); hold(ax2,'on'); box(ax2,'on');
em3 = 0.8980;
em1 = (pi/2)*(1-em3);
em2 = (1-em3)/(1-2/pi);
em4 = (pi/4)*em3;   em5 = em4;
zet = linspace(-0.5,0.5,400);
xi  = zet + 0.5;
Pm.UD = em3*ones(size(zet));
Pm.O  = 1 - em1*cos(pi*zet);
Pm.X  = 1 - em2*(1 - cos(pi*zet));
Pm.V  = 2*em4*cos(pi*zet/2 + pi/4);
Pm.A  = 2*em5*cos(pi*zet/2 - pi/4);
Pf.UD = Pm.UD.^2; Pf.O = Pm.O.^2; Pf.X = Pm.X.^2; Pf.V = Pm.V.^2; Pf.A = Pm.A.^2;
zlay = ((1:NL)-4)/NL;
xilay = zlay + 0.5;
mIdx = arrayfun(@(v) find(abs(xi-v)==min(abs(xi-v)),1), xilay);
for ci = 1:5
    plot(ax2, xi, Pf.(pat{ci}),'LineStyle','-','Color',CO{ci},'LineWidth',1.8,...
         'Marker',MK{ci},'MarkerIndices',mIdx,'MarkerSize',7,'MarkerFaceColor','w');
end
grid(ax2,'on'); set(ax2,'FontSize',FSZ);
xlabel(ax2,'\xi = (r-R_i)/h','FontSize',FSZ);
ylabel(ax2,'porosity coefficient  e = E/E_s = (\rho/\rho_s)^2','FontSize',FSZ);
legend(ax2,pat,'Location','northoutside','Orientation','horizontal','FontSize',10);
xlim(ax2,[0 1]); ylim(ax2,[0 2.2]); yline(ax2,1,'-','Color',[0.5 0.5 0.5],'HandleVisibility','off');

exportgraphics(fig,fullfile(outdir,'GPL_porosity_stacked.png'),'Resolution',300);
close(fig);
fprintf('done: GPL_porosity_stacked.png -> %s\n', outdir);
