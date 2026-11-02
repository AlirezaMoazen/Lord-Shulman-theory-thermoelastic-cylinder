function ok = selftest_LSTE()
%SELFTEST_LSTE  Quick installation check (about 1 s): runs the 'quick' case and compares
%   with reference values computed by the verified R11 solver (tests/reference_quick.mat).
%   Figure files are not tested here (they need a working graphics display).
%   Use after copying the package to a new machine / MATLAB version.
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'input'), fullfile(root,'core'), fullfile(root,'post'));

ref = load(fullfile(root,'tests','reference_quick.mat'));
res = LSTE_solver_R12(case_library('quick'));

names = fieldnames(ref);
dmax = 0;
for k = 1:numel(names)
    dmax = max(dmax, max(abs(res.(names{k})(:) - ref.(names{k})(:))));
end
ok = dmax < 1e-9 * max(1, max(abs(ref.S_rr(:))));
fprintf('max |new - reference| = %.3e  -> %s\n', dmax, ternary(ok, 'PASS', 'FAIL'));

outdir = fullfile(root,'results','_selftest');
postprocess_LSTE(res, outdir, struct('figures', false));
files = {'time_history.csv','radial_profile.csv','summary.txt'};
for k = 1:numel(files)
    present = exist(fullfile(outdir, files{k}), 'file') == 2;
    ok = ok && present;
    if ~present, fprintf('missing output: %s\n', files{k}); end
end
fprintf('SELFTEST %s\n', ternary(ok, 'PASSED', 'FAILED'));
end

function s = ternary(c, a, b)
if c, s = a; else, s = b; end
end
