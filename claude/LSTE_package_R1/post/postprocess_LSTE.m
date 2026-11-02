function postprocess_LSTE(res, outdir, opts)
%POSTPROCESS_LSTE  Figures, CSV tables and a text summary from a solver result.
%
%   postprocess_LSTE(res, outdir)         write tables + figure files to outdir
%   postprocess_LSTE(res, outdir, opts)   opts.figures (default true): write the figure files
%                                         opts.show    (default false): also display the figure
%
%   Writes into outdir:
%     time_histories.png/.fig   mid-point T, u, w vs t; T(r), u(r), stresses(r)
%     time_history.csv          t, T_mid, u_mid, w_mid, T_inner
%     radial_profile.csv        r, T, u, sigma_rr, sigma_tt, sigma_zz at z = L/2
%     summary.txt               final-state values
if nargin < 3, opts = struct(); end
if ~isfield(opts, 'figures'), opts.figures = true; end
if ~isfield(opts, 'show'), opts.show = false; end
show = opts.show;
if ~exist(outdir, 'dir'), mkdir(outdir); end

tv = res.tv;  cfg = res.cfg;

%% ---- figure ----
if opts.figures
vis = 'off'; if show, vis = 'on'; end
fig = figure('Visible', vis, 'Position', [80 80 1250 750], 'Color', 'w');
subplot(2,3,1); plot(tv, res.hist_T, 'b-', tv, res.hist_Ti, 'k--', 'LineWidth', 1.4);
xlabel('t (s)'); ylabel('T (K)'); grid on;
legend('T_{mid}', 'T_{inner}(t)', 'Location', 'best');
subplot(2,3,2); plot(tv, res.hist_U*1e6, 'r-', 'LineWidth', 1.4);
xlabel('t (s)'); ylabel('u (\mum)'); grid on;
subplot(2,3,3); plot(tv, res.hist_W*1e6, 'g-', 'LineWidth', 1.4);
xlabel('t (s)'); ylabel('w (\mum)'); grid on;
subplot(2,3,4); plot(res.r_all, res.T_all, 'b.-');
xlabel('r (m)'); ylabel('T (K)'); grid on;
subplot(2,3,5); plot(res.r_all, res.U_all*1e6, 'r.-');
xlabel('r (m)'); ylabel('u (\mum)'); grid on;
subplot(2,3,6);
plot(res.r_all, res.S_rr/1e6, '.-', res.r_all, res.S_tt/1e6, '.-', res.r_all, res.S_zz/1e6, '.-');
xlabel('r (m)'); ylabel('\sigma (MPa)'); grid on;
legend('\sigma_{rr}', '\sigma_{\theta\theta}', '\sigma_{zz}', 'Location', 'best');
print(fig, fullfile(outdir, 'time_histories.png'), '-dpng', '-r200');
savefig(fig, fullfile(outdir, 'time_histories.fig'));
if ~show, close(fig); end
end

%% ---- CSV tables ----
writetable(table(tv, res.hist_T, res.hist_U, res.hist_W, res.hist_Ti, ...
    'VariableNames', {'t_s','T_mid_K','u_mid_m','w_mid_m','T_inner_K'}), ...
    fullfile(outdir, 'time_history.csv'));
writetable(table(res.r_all(:), res.T_all(:), res.U_all(:), res.S_rr(:), res.S_tt(:), res.S_zz(:), ...
    'VariableNames', {'r_m','T_K','u_m','sigma_rr_Pa','sigma_tt_Pa','sigma_zz_Pa'}), ...
    fullfile(outdir, 'radial_profile.csv'));

%% ---- summary ----
if strcmpi(cfg.P_time_mode, 'sine')
    P_end = cfg.P_i * sin(pi*cfg.total_time/cfg.t0_P);
else
    P_end = cfg.P_i;
end
fid = fopen(fullfile(outdir, 'summary.txt'), 'w');
fprintf(fid, 'theory                 : %s\n', res.theory);
fprintf(fid, 'layers / N_r / N_z     : %d / %d / %d   (Ndof = %d)\n', res.NL, res.N_r, res.N_z, res.Ndof);
fprintf(fid, 'total time / dt        : %g s / %g s\n', cfg.total_time, cfg.dt);
fprintf(fid, 'inner-surface T (end)  : %.2f K\n', res.hist_Ti(end));
fprintf(fid, 'mid-point T (end)      : %.2f K\n', res.hist_T(end));
fprintf(fid, 'mid-point u (end)      : %.4e m\n', res.hist_U(end));
fprintf(fid, 'sigma_rr inner node    : %.4e Pa  (target -P = %.4e)\n', res.S_rr(1), -P_end);
fprintf(fid, 'sigma_rr outer node    : %.4e Pa  (target 0)\n', res.S_rr(end));
fprintf(fid, 'Newmark CPU time       : %.2f s\n', res.newmark_cpu);
fclose(fid);
end
