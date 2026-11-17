%% ========================================================================
%  validation_fig_bench1_malekzadeh_etal_R1.m — relabel the legend of the mechanical benchmark figure
%  ------------------------------------------------------------------------
%  Purpose : author instruction of 2026-11-17 ("write Malekzadeh et al."). The thesis Fig. 4-6
%            (Validation/bench1_U.png, = figures_ch4_master/figures_ch4_color/bench1_U.png) names
%            its reference "Malekzadeh & Heydarpour (2012)", but the paper (Int. J. Pressure Vessels
%            Piping 98, 2012, 43-56) has four authors. This script opens the saved figure, changes
%            only that legend entry to "Malekzadeh et al. (2012)" and writes a new figure.
%  Inputs  : Validation/bench1_U_NL10.fig (the figure behind the thesis image; same curves, markers,
%            axes, 2188 x 1563 px at 300 dpi). Nothing is recomputed, no solver is run.
%  Outputs : figures_validation/bench1_U_malekzadeh_etal_R1.png (300 dpi) and .fig
%  Run from claude/ :  matlab -batch "addpath('code/validation'); validation_fig_bench1_malekzadeh_etal_R1; exit(0)"
%  New file (R1); the benchmark scripts and the original figure stay untouched.
%  ========================================================================
clearvars; clc; close all;

src    = fullfile('Validation','bench1_U_NL10.fig');
outdir = 'figures_validation';
name   = 'bench1_U_malekzadeh_etal_R1';
oldTxt = 'Malekzadeh & Heydarpour (2012)';
newTxt = 'Malekzadeh et al. (2012)';

if ~exist(outdir,'dir'), mkdir(outdir); end
f  = openfig(src,'invisible');
lg = findobj(f,'Type','Legend');
assert(numel(lg) == 1, 'expected exactly one legend, found %d', numel(lg));
s  = lg.String;
assert(any(strcmp(s,oldTxt)), 'legend entry "%s" not found', oldTxt);
lg.String = strrep(s, oldTxt, newTxt);
fprintf('legend: %s\n', strjoin(lg.String, ' | '));

print(f, fullfile(outdir,[name '.png']), '-dpng', '-r300');
savefig(f, fullfile(outdir,[name '.fig']));
fprintf('Saved %s (.png + .fig) in %s\n', name, outdir);
close(f);
