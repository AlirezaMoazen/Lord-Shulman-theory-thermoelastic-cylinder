function res = run_LSTE(input, runName, opts)
%RUN_LSTE  Input -> solver -> post-processing -> results folder, in one call.
%
%   res = run_LSTE()                      thesis reference case
%   res = run_LSTE('fourier')             named case from input/case_library.m
%   res = run_LSTE(cfg)                   cfg struct (see input/default_input.m)
%   res = run_LSTE(input, runName)        results folder name (default: case name / timestamp)
%   res = run_LSTE(input, runName, opts)  opts.figures (true), opts.show (false); see postprocess_LSTE
%
%   Results are written to <package>/results/<runName>/ :
%     Results.mat (res), DOFmap.csv, time_histories.png/.fig,
%     time_history.csv, radial_profile.csv, summary.txt
%
%   All paths are derived from the location of this file, so the package
%   can be copied to any folder or machine and run as is.
if nargin < 1 || isempty(input), input = 'reference'; end
if nargin < 3, opts = struct(); end

root = fileparts(mfilename('fullpath'));
addpath(fullfile(root,'input'), fullfile(root,'core'), fullfile(root,'post'));

if ischar(input) || isstring(input)
    cfg = case_library(char(input));
    if nargin < 2 || isempty(runName), runName = char(input); end
else
    cfg = input;
    if nargin < 2 || isempty(runName), runName = ['run_' datestr(now,'yyyymmdd_HHMMSS')]; end
end

outdir = fullfile(root, 'results', runName);
if ~exist(outdir, 'dir'), mkdir(outdir); end

res = LSTE_solver_R12(cfg);

save(fullfile(outdir, 'Results.mat'), 'res', '-v7.3');
writeDofMap(res, fullfile(outdir, 'DOFmap.csv'));
postprocess_LSTE(res, outdir, opts);
if cfg.verbose, fprintf('Results written to %s\n', outdir); end
end

function writeDofMap(res, fname)
cn = {'theta','u','w'};
fid = fopen(fname, 'w');
fprintf(fid, 'gdof,component,comp_name,layer_e,ir,iz,localnode,r,z\n');
D = res.DOFmap;
for g = 1:size(D,1)
    fprintf(fid, '%d,%d,%s,%d,%d,%d,%d,%.6g,%.6g\n', ...
        D(g,1), D(g,2), cn{D(g,2)}, D(g,3), D(g,4), D(g,5), D(g,6), D(g,7), D(g,8));
end
fclose(fid);
end
