%% Compare_R1.m
%  Cross-validation: static limit of the dynamic solver (claude_R1 with
%  pressure-only load) vs the independent validated static solver
%  (Static_Baseline_R1 = Main-EN). Both use the same grid (NL=5,N_r=9,N_z=11),
%  the same material config (W_GPL=0, UD porosity e3=0.7) and free ends.
%  Run claude_R1 with cfg.out_name='Results_R5_verif.mat' (or edit below).
clear; clc;

S = load('Results_Static.mat');     % static baseline
D = load('Results_R5_verif.mat');   % dynamic solver, verification config

z_mid = round(S.N_z/2);

% static radial profile of u at mid-length (concatenate layers)
U_stat = [];
for e = 1:S.NL
    U_stat = [U_stat; S.U_layer{e}(:, z_mid)]; %#ok<AGROW>
end
U_dyn_inf = D.U_inf_prof(:);        % static limit computed inside R5

fprintf('n static points  : %d,  dynamic points: %d\n', numel(U_stat), numel(U_dyn_inf));
fprintf('max |u| static   : %.6e m\n', max(abs(U_stat)));
fprintf('max |u| dyn-limit: %.6e m\n', max(abs(U_dyn_inf)));
fprintf('max abs diff     : %.3e m\n', max(abs(U_stat - U_dyn_inf)));
fprintf('max rel diff     : %.3e\n', max(abs(U_stat - U_dyn_inf))/max(abs(U_stat)));

% transient settling check: final time-history value vs static limit
p_mid = (ceil(D.NL/2)-1)*D.N_r + round(D.N_r/2);
fprintf('\nu_mid transient(end) : %.6e m\n', D.hist_U(end));
fprintf('u_mid static limit   : %.6e m\n', D.U_inf_prof(p_mid));
fprintf('settling rel error   : %.3e\n', ...
    abs(D.hist_U(end)-D.U_inf_prof(p_mid))/max(abs(D.U_inf_prof(p_mid)),eps));
