%% porosity_schematic_R5_zeta_R1.m -- porosity-pattern schematic (R5 formulas), z axis from -h/2 to h/2
%  Author request (2026-10-14): redraw the R5 porosity-pattern schematic
%  (porosity_patterns_schematic_R5.png) with the through-thickness axis running
%  from -h/2 to h/2 instead of xi = (r-R_i)/h in [0, 1].
%  Only the x-axis changes: z = r - (R_i+R_o)/2 = (xi - 1/2)*h, plotted as z/h in
%  [-1/2, 1/2] with tick labels -h/2, -h/4, 0, h/4, h/2. The R5 formulas are
%  untouched (coefficient 1, denominator 2 in cos(pi*zet/2 +- pi/4); curves plotted
%  exactly as the solver computes them, e = P_m^2, em3 = 0.8980). Same style,
%  colours, markers (at the 7 layer centres), size and y range as R5.
%  Output is a NEW file porosity_patterns_schematic_R5_zeta_R1.png; all existing
%  porosity PNGs (R1-R9) and scripts are kept frozen.
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
      [0.494 0.184 0.556],[0.466 0.674 0.188]};   % chapter-4 colour table
MK = {'o','s','^','d','v'};
FSZ = 11; NL = 7;
pat = {'UD','O','X','V','A'};

%% ---- R5 formulas (frozen) ----
em3 = 0.8980;
em1 = (pi/2)*(1-em3);
em2 = (1-em3)/(1-2/pi);
em4 = (pi/4)*em3;   em5 = em4;
zet = linspace(-0.5,0.5,400);                         % z/h, centred coordinate
Pm.UD = em3*ones(size(zet));
Pm.O  = 1 - em1*cos(pi*zet);
Pm.X  = 1 - em2*(1 - cos(pi*zet));
Pm.V  = 1*em4*cos(pi*zet/2 + pi/4);                   % max at INNER face
Pm.A  = 1*em5*cos(pi*zet/2 - pi/4);                   % max at OUTER face
for k = 1:5, Pf.(pat{k}) = Pm.(pat{k}).^2; end        % porosity coefficient e = P_m^2

zlay = ((1:NL)-4)/NL;                                 % 7 layer-centre coords (z/h)
mIdx = arrayfun(@(v) find(abs(zet-v)==min(abs(zet-v)),1), zlay);

fig = figure('Units','inches','Position',[1 1 7.4 5],'Color','w'); hold on; box on;
for ci = 1:5
    plot(zet, Pf.(pat{ci}),'LineStyle','-','Color',CO{ci},'LineWidth',1.8,...
         'Marker',MK{ci},'MarkerIndices',mIdx,'MarkerSize',7,'MarkerFaceColor','w');
end
grid on; set(gca,'FontSize',FSZ);
set(gca,'XTick',[-0.5 -0.25 0 0.25 0.5],'XTickLabel',{'-h/2','-h/4','0','h/4','h/2'});
xlabel('z','FontSize',FSZ);
ylabel('porosity coefficient  e = E/E_s = (\rho/\rho_s)^2','FontSize',FSZ);
legend(pat,'Location','southoutside','Orientation','horizontal','FontSize',10);
xlim([-0.5 0.5]); ylim([0 2.2]); yline(1,'-','Color',[0.5 0.5 0.5],'HandleVisibility','off');
exportgraphics(fig,fullfile(outdir,'porosity_patterns_schematic_R5_zeta_R1.png'),'Resolution',300);
close(fig);
disp('DONE: porosity_patterns_schematic_R5_zeta_R1.png (all earlier porosity PNGs kept frozen)');
