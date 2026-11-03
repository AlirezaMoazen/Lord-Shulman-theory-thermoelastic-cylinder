%% validation_fig_bench2_R5.m — Chapter-4 verification test 4 figure (Newmark vs ode15s), 'exact' legend entry removed
%  R5 (2026-11-03, author request): the legend line labelled 'exact' (the exact Bessel-series solution) is removed
%  from the legend of the Newmark-vs-ode15s temperature-history figure. The legend now lists only
%  'DQM + Newmark' and 'DQM + ode15s'. The exact curve itself stays in the plot, unchanged.
%  Nothing else changes from R4: the saved figures_validation/verif_test4_integrator_R3{,_bw}.fig are loaded and
%  only the legend is edited, so data, colours, markers, size and print resolution (-r130) are identical and the
%  solver / ode15s are not re-run. Output: figures_validation/verif_test4_integrator_R4{,_bw}.png/.fig.
%  R1-R3 figures and scripts R1-R4 stay frozen. (The CSV of R1 is unaffected.)
clearvars; clc; close all;
base = 'c:/Users/InfosaicUser/Desktop/MSc/Lord-Shulman-theory-thermoelastic-cylinder/claude';
fdir = fullfile(base,'figures_validation');

for sfx = {'', '_bw'}
    s = sfx{1};
    f  = openfig(fullfile(fdir,['verif_test4_integrator_R3' s '.fig']),'invisible');
    ax = findobj(f,'Type','axes');
    ln = flipud(findobj(ax,'Type','line'));          % plotting order: exact, Newmark, ode15s
    assert(numel(ln)==3, 'unexpected line layout in verif_test4_integrator_R3%s.fig', s);
    lg = findobj(f,'Type','legend');                 % keep the existing legend styling, change entries only
    pos = lg.Location; fs = lg.FontSize; fn = lg.FontName;
    legend(ax, ln(2:3), {'DQM + Newmark','DQM + ode15s'}, 'Location',pos, 'FontSize',fs, 'FontName',fn);
    print(f, fullfile(fdir,['verif_test4_integrator_R4' s '.png']), '-dpng','-r130');
    savefig(f, fullfile(fdir,['verif_test4_integrator_R4' s '.fig']));
    close(f);
end
disp('DONE: figures_validation/verif_test4_integrator_R4{,_bw}.png/.fig (R3 kept frozen)');
