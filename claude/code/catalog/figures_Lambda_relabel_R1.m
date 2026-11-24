%% ========================================================================
%  figures_Lambda_relabel_R1.m — relabel the pattern name A as Lambda in the Chapter 4 figures of the article
%  ------------------------------------------------------------------------
%  Purpose : author instruction of 2026-11-23 (Prom8, item 3): the figures in which the pattern A is
%            shown are reproduced with the symbol Lambda (correction of the symbol A -> Lambda).
%            This script opens the saved .fig files used in the article, replaces ONLY the pattern
%            label in the legend entries (A -> Lambda, GPL-A -> GPL-Lambda, porosity-A -> porosity-Lambda)
%            and writes new figures. Nothing is recomputed, no solver is run; curves, markers, axes,
%            fonts and layout are those of the source figures.
%  Inputs  : the .fig files listed in 'src' below (Chapter 4 colour figures, folders R11, R17, R20).
%  Outputs : figures_article/<name>_Lambda_R1.png (1598 x 988 px, 130 dpi = size of the sources) and .fig
%  Run from claude/ :  matlab -batch "addpath('code/catalog'); figures_Lambda_relabel_R1; exit(0)"
%  New file (R1); the source figures and the scripts that made them stay untouched.
%  ========================================================================
clearvars; clc; close all;

root = fullfile('figures_ch4_master');
src = {
    fullfile(root,'figures_ch4_color_R11','A_GPL_patterns')
    fullfile(root,'figures_ch4_color_R17','B_porosity_patterns')
    fullfile(root,'figures_ch4_color_R20','gplpor_porO')
    fullfile(root,'figures_ch4_color_R20','gplpor_porX')
    fullfile(root,'figures_ch4_color_R20','gplpor_porV')
    fullfile(root,'figures_ch4_color_R20','gplpor_porA')
    fullfile(root,'figures_ch4_color_R20','bestworst')};
outdir = 'figures_article';
if ~exist(outdir,'dir'), mkdir(outdir); end

Lam = char(923);                       % Greek capital letter Lambda (U+039B)
nChanged = 0;
for k = 1:numel(src)
    [~, nm] = fileparts(src{k});
    f  = openfig([src{k} '.fig'], 'invisible');
    % the source PNGs (1598 x 988 px at 130 dpi) were printed from a window of 1180 x 730 px, whereas the saved .fig
    % stores 1180 x 709 px (window clipped by the screen); restore the printed size so the PNG has the source size
    p0 = f.Position; f.Position = [p0(1) p0(2) 1180 730];
    lg = findall(f, 'Type', 'legend');
    assert(~isempty(lg), '%s: no legend found', nm);
    for i = 1:numel(lg)
        s0 = cellstr(lg(i).String);
        s1 = s0;
        for j = 1:numel(s1)
            if strcmp(s1{j}, 'A')
                s1{j} = Lam;
            else
                s1{j} = regexprep(s1{j}, '(GPL-|porosity-)A(?![A-Za-z])', ['$1' Lam]);
            end
        end
        if ~isequal(s0, s1)
            lg(i).String = s1;
            nChanged = nChanged + 1;
        end
    end
    % annotations of the source figures (kept as they are; printed only as a check)
    an = findall(f, 'Type', 'annotation');
    for i = 1:numel(an)
        if isprop(an(i), 'String') && ~isempty(an(i).String)
            fprintf('  [%s] annotation text: %s\n', nm, strjoin(cellstr(an(i).String), ' / '));
        end
    end
    fprintf('%s : legend[1] = %s\n', nm, strjoin(cellstr(lg(1).String), ' | '));
    out = fullfile(outdir, [nm '_Lambda_R1']);
    print(f, [out '.png'], '-dpng', '-r130');
    savefig(f, [out '.fig']);
    close(f);
end
fprintf('Done: %d legends changed in %d figures, written to %s\n', nChanged, numel(src), outdir);
