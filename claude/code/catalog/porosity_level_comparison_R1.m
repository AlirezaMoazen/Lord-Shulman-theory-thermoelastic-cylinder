%% ========================================================================
%  porosity_level_comparison_R1.m — porosity patterns at the 3 thesis porosity levels
%  ------------------------------------------------------------------------
%  Shows the 5 porosity distribution patterns (UD/O/X/V/A) as the porosity
%  coefficient e = E/E_s = (rho/rhos)^2 vs through-thickness coordinate xi,
%  one panel per porosity level. The 3 levels (e_m3 = 0.9675 / 0.8604 /
%  0.7776) are the ones used in the thesis's E_porosity_level parametric
%  study (Fig 4-8/4-9), matching campaign/run_ch4_campaign.ps1's cfg cases
%  E_EM3_9675 / BASE / E_EM3_7776.
%
%  V/A use the real solver's coefficient (2, no shift -- LSTE_solver_R11.m),
%  but like the rest of the ch123_figs_R9.m schematic family, plotted
%  unclipped so the overshoot past e=1 near the peak face is visible.
%  All figure text is in ENGLISH (MATLAB renders RTL/Persian unreliably).
%  ========================================================================
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
FSZ = 11;
pat = {'UD','O','X','V','A'};

NL  = 7;
zet = linspace(-0.5,0.5,400);                       % centered coord (fine)
xi  = zet + 0.5;                                     % through-thickness in [0,1]
zlay  = ((1:NL)-4)/NL;                               % 7 layer-centre coords
xilay = zlay + 0.5;
mIdx  = arrayfun(@(v) find(abs(xi-v)==min(abs(xi-v)),1), xilay);

em3_levels = [0.9675, 0.8604, 0.7776];
labels     = {'e_{m3} = 0.9675','e_{m3} = 0.8604 (base)','e_{m3} = 0.7776'};

fig = figure('Units','inches','Position',[1 1 13 4.6],'Color','w');
for pnl = 1:3
    em3 = em3_levels(pnl);
    em1 = (pi/2)*(1-em3);
    em2 = (1-em3)/(1-2/pi);
    em4 = (pi/4)*em3;   em5 = em4;      % real solver em4/em5 (LSTE_solver_R11.m)
    Pm.UD = em3*ones(size(zet));
    Pm.O  = 1 - em1*cos(pi*zet);
    Pm.X  = 1 - em2*(1 - cos(pi*zet));
    Pm.V  = 2*em4*cos(pi*zet/2 + pi/4);              % max at INNER face
    Pm.A  = 2*em5*cos(pi*zet/2 - pi/4);              % max at OUTER face

    ax = subplot(1,3,pnl); hold(ax,'on'); box(ax,'on');
    for ci = 1:5
        plot(xi, Pm.(pat{ci}),'LineStyle','-','Color',CO{ci},'LineWidth',1.8,...
             'Marker',MK{ci},'MarkerIndices',mIdx,'MarkerSize',7,'MarkerFaceColor','w');
    end
    grid on; set(ax,'FontSize',FSZ);
    xlabel('\xi = (r-R_i)/h','FontSize',FSZ);
    if pnl==1
        ylabel('porosity pattern coefficient (P_m)','FontSize',FSZ);
    end
    title(labels{pnl},'FontWeight','normal','FontSize',FSZ);
    xlim([0 1]);
    % zoom to this panel's actual data range, centered, with a small
    % padding, so every panel's curves fill the plot instead of sitting
    % in a slice of a wide shared scale.
    allv = [Pm.UD(:); Pm.O(:); Pm.X(:); Pm.V(:); Pm.A(:)];
    vlo = min(allv); vhi = max(allv);
    pad = 0.08*(vhi-vlo);
    ylim([vlo-pad, vhi+pad]);
    set(ax,'YTick',round((vlo-pad)*20)/20 : 0.05 : round((vhi+pad)*20)/20);
    yline(1,'-','Color',[0.5 0.5 0.5],'HandleVisibility','off');
    if pnl==2
        legend(pat,'Location','southoutside','Orientation','horizontal','FontSize',9);
    end
end

exportgraphics(fig,fullfile(outdir,'porosity_level_comparison_R1.png'),'Resolution',300);
close(fig);
fprintf('done: porosity_level_comparison_R1.png\n');
