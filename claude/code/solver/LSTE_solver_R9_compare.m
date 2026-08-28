%% LSTE_solver_R9_compare.m — exact numerical diff between R8 and R9 check runs.
%  Not a revision file (no physics, no cfg) -- a one-off validation script,
%  loads the chk_*_R8.mat / chk_*_R9.mat pairs written by the correctness
%  sweep and reports max abs / max rel differences per field. Run this
%  script itself (via run()) from code/solver/ so the chk_*.mat files are
%  found by their plain names.
clearvars; clc;
cases = {'default','fourier','dpl','gn3','mesh'};
fields = {'hist_T','hist_U','hist_W','r_all','T_all','U_all','S_rr','S_tt','S_zz','x_inf'};

for ci = 1:numel(cases)
    cname = cases{ci};
    d8 = load(sprintf('chk_%s_R8.mat', cname));
    d9 = load(sprintf('chk_%s_R9.mat', cname));
    fprintf('\n===== case: %s =====\n', cname);
    for fi = 1:numel(fields)
        fn = fields{fi};
        if ~isfield(d8,fn) || ~isfield(d9,fn), continue; end
        a = d8.(fn)(:); b = d9.(fn)(:);
        if numel(a) ~= numel(b)
            fprintf('  %-8s SIZE MISMATCH: R8=%d R9=%d\n', fn, numel(a), numel(b));
            continue;
        end
        dabs = max(abs(a-b));
        scale = max(max(abs(a)), eps);
        drel = dabs/scale;
        fprintf('  %-8s max|R8-R9|=%.3e   max|R8-R9|/max|R8|=%.3e   (n=%d)\n', ...
            fn, dabs, drel, numel(a));
    end
end
fprintf('\nDone. Differences at ~1e-10 relative or smaller are floating-point\n');
fprintf('roundoff from reordered arithmetic, not a correctness issue.\n');
