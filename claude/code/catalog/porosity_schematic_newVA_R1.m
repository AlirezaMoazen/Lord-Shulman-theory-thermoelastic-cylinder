%% porosity_schematic_newVA_R1.m -- porosity-pattern schematic with the NEW V and A patterns
%  Author request (2026-10-14): draw the new V and A patterns together with the other patterns.
%    UD : P_m = e_m3
%    O  : P_m = 1 - e_m1 cos(pi*zeta)
%    X  : P_m = 1 - e_m2 [1 - cos(pi*zeta)]
%    V  : P_m = 1 - e_m4 cos(pi*zeta/2 + pi/4)      (NEW)
%    A  : P_m = 1 - e_m5 cos(pi*zeta/2 - pi/4)      (NEW)
%  UD, O, X are exactly as in LSTE_solver_R11. e_m4 = e_m5 = (pi/2)(1 - e_m3) is the value that keeps the
%  wall-average mass equal to UD for the new 1 - e*cos form (derived: mean of cos(pi*zeta/2 +- pi/4) over
%  [-1/2,1/2] is 2/pi). With it P_m stays in [1 - e_m4, 1], so no clipping is needed.
%  Two figures in the house style of ch123_figs_R10 / porosity_schematic_R5_zeta_R1 (Times, chapter-4 colour
%  table, markers at the 7 layer centres, z axis from -h/2 to h/2, legend below):
%    porosity_patterns_schematic_newVA_Pm_R1.png : mass factor  P_m = rho/rho_s
%    porosity_patterns_schematic_newVA_e_R1.png  : porosity coefficient  e = E/E_s = P_m^2 (as thesis Fig 3-3)
%  Reference level e_m3 = 0.8604 (thesis reference; the older schematics R1-R9 used 0.8980).
%  All earlier porosity PNGs and scripts are kept frozen; the solver is NOT changed.
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

em3 = 0.8604;
em1 = (pi/2)*(1-em3);
em2 = (1-em3)/(1-2/pi);
em4 = (pi/2)*(1-em3);  em5 = em4;                     % NEW constant for the 1 - e*cos form
zet = linspace(-0.5,0.5,400);                         % z/h, centred coordinate
Pm.UD = em3*ones(size(zet));
Pm.O  = 1 - em1*cos(pi*zet);
Pm.X  = 1 - em2*(1 - cos(pi*zet));
Pm.V  = 1 - em4*cos(pi*zet/2 + pi/4);                 % NEW: lowest density at INNER face
Pm.A  = 1 - em5*cos(pi*zet/2 - pi/4);                 % NEW: lowest density at OUTER face
zlay = ((1:NL)-4)/NL;                                 % 7 layer-centre coords (z/h)
mIdx = arrayfun(@(v) find(abs(zet-v)==min(abs(zet-v)),1), zlay);
fprintf('e_m1=%.4f e_m2=%.4f e_m4=e_m5=%.4f\n',em1,em2,em4);
for k = 1:5
    fprintf('%-2s mean over wall = %.4f ; min = %.4f ; max = %.4f\n',pat{k},mean(Pm.(pat{k})),min(Pm.(pat{k})),max(Pm.(pat{k})));
end

for mode = 1:2
    if mode == 1
        Y = Pm;                                   fn = 'porosity_patterns_schematic_newVA_Pm_R1.png';
        yl = 'mass factor  P_m = \rho/\rho_s';
    else
        for k = 1:5, Y.(pat{k}) = Pm.(pat{k}).^2; end
        fn = 'porosity_patterns_schematic_newVA_e_R1.png';
        yl = 'porosity coefficient  e = E/E_s = (\rho/\rho_s)^2';
    end
    fig = figure('Units','inches','Position',[1 1 7.4 5],'Color','w'); hold on; box on;
    for ci = 1:5
        plot(zet, Y.(pat{ci}),'LineStyle','-','Color',CO{ci},'LineWidth',1.8,...
             'Marker',MK{ci},'MarkerIndices',mIdx,'MarkerSize',7,'MarkerFaceColor','w');
    end
    grid on; set(gca,'FontSize',FSZ);
    set(gca,'XTick',[-0.5 -0.25 0 0.25 0.5],'XTickLabel',{'-h/2','-h/4','0','h/4','h/2'});
    xlabel('z','FontSize',FSZ); ylabel(yl,'FontSize',FSZ);
    legend(pat,'Location','southoutside','Orientation','horizontal','FontSize',10);
    xlim([-0.5 0.5]); ylim([0 1.1]); yline(1,'-','Color',[0.5 0.5 0.5],'HandleVisibility','off');
    drawnow; exportgraphics(gcf,fullfile(outdir,fn),'Resolution',300);
    close(gcf); fprintf('done: %s\n',fn);
end
