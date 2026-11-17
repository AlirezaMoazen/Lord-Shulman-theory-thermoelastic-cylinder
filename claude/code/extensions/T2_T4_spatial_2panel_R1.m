%% ========================================================================
%  T2_T4_spatial_2panel_R1.m — spatial discretisation comparison, ONE figure with TWO panels
%  ------------------------------------------------------------------------
%  Purpose : journal-article figure (papers/ARTICLE_FULL_THESIS_EN_R4). Combines the two
%            thesis figures 4-32 (radial nodes, T2_spatial_convergence) and 4-33 (axial nodes,
%            T4_axial_convergence) into one two-panel figure (a) radial, (b) axial, with a
%            single legend at the bottom, and leaves out the DIVERGING part of the DQM with the
%            uniform grid (N > 31; the saved errors there are 1e47 ... 1e254 or NaN).
%  Inputs  : results_extensions/T2_spatial_table.csv, results_extensions/T4_axial_table.csv
%            (the saved data of the thesis figures; nothing is recomputed, no solver is run).
%  Outputs : results_extensions/figures_article/T2T4_spatial_2panel_R1.png  (300 dpi)
%            results_extensions/figures_article/T2T4_spatial_2panel_R1.fig
%  Run from claude/ :  matlab -batch "addpath('code/extensions'); T2_T4_spatial_2panel_R1; exit(0)"
%  Style   : same as the thesis figures (default colour order, o s ^ d v markers, slope -2 line).
%  New file (R1); the scripts that made the thesis figures stay untouched.
%  ========================================================================
clearvars; clc; close all;

cfg.csv     = {fullfile('results_extensions','T2_spatial_table.csv'), ...
               fullfile('results_extensions','T4_axial_table.csv')};
cfg.xlab    = {'number of radial points','number of axial points'};
cfg.ylim    = {[1e-4 0.3],[1e-6 0.3]};
cfg.ptitle  = {'(a) radial direction','(b) axial direction'};
cfg.unifMax = 31;                       % DQM (uniform): keep N <= 31, drop the diverging range
cfg.outdir  = fullfile('results_extensions','figures_article');
cfg.name    = 'T2T4_spatial_2panel_R1';

meth = {'DQM-cheb','DQM-unif','FDM','FEM-lin','FEM-quad'};
mlab = {'DQM (Chebyshev)','DQM (uniform)','FDM (2nd order)','FEM (linear)','FEM (quadratic)'};
mk   = {'o','s','^','d','v'};
co   = [0.0000 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250; ...
        0.4940 0.1840 0.5560; 0.4660 0.6740 0.1880];

if ~exist(cfg.outdir,'dir'), mkdir(cfg.outdir); end
fig = figure('Position',[60 60 1500 620],'Color','w');
tl  = tiledlayout(fig,1,2,'TileSpacing','compact','Padding','compact');
for p = 1:2
    T  = readtable(cfg.csv{p});
    ax = nexttile(tl); hold(ax,'on');
    h  = gobjects(1,numel(meth)+1);
    for m = 1:numel(meth)
        s = strcmp(T.method, meth{m}) & isfinite(T.max_err_K);
        if strcmp(meth{m},'DQM-unif'), s = s & (T.N <= cfg.unifMax); end
        h(m) = loglog(ax, T.N(s), T.max_err_K(s), ['-' mk{m}], 'Color',co(m,:), ...
                      'LineWidth',2,'MarkerSize',8);
    end
    sF = strcmp(T.method,'FDM');  NF = T.N(sF);  eF = T.max_err_K(sF);
    h(end) = loglog(ax, NF, eF(1)*(NF(1)./NF).^2, ':k', 'LineWidth',1.5);
    set(ax,'XScale','log','YScale','log','FontSize',14,'Box','on','XGrid','on','YGrid','on', ...
           'XMinorGrid','on','YMinorGrid','on','GridAlpha',0.25);
    xlim(ax,[6 400]); ylim(ax,cfg.ylim{p});
    xlabel(ax,cfg.xlab{p}); ylabel(ax,'max error at t = 10 s (K)');
    title(ax,cfg.ptitle{p},'FontWeight','normal');
    if p == 1, hLeg = h; ax1 = ax; end
end
lg = legend(ax1, hLeg, [mlab,{'slope -2'}], 'NumColumns',6,'FontSize',13);
lg.Layout.Tile = 'south';

exportgraphics(fig, fullfile(cfg.outdir,[cfg.name '.png']), 'Resolution',300);
savefig(fig, fullfile(cfg.outdir,[cfg.name '.fig']));
fprintf('Saved %s (.png + .fig) in %s\n', cfg.name, cfg.outdir);
close(fig);
