%% validation_figs_R2.m — figures + tables for Chapter-4 verification tests 1 and 5
%  Section 4-4 lists five verification tests in Table 4-6 but shows figures for
%  only two (test 2 bench1_U, test 3 bench2_T_profiles). This supplies:
%    test 1 — static spatial assembly vs the independent static solver
%    test 5 — Lord-Shulman second-sound wave: the figure already exists as
%             figures_validation/ls_wave_validation_R1.png, so only the
%             mesh-convergence table is assembled here from the saved CSV.
%  Test 4 is in validation_fig_bench2_R1.m (it has to run the solver).
%
%  R2 (2026-10-05) fixes the END CONDITION used for test 1. R1 compared the two
%  solvers with SIMPLY SUPPORTED ends and got a 8.0e-02 relative difference,
%  which does not reproduce the 2e-11 quoted in Table 4-6. The documented
%  historical comparison is pressure-only with FREE ends, and the two codes
%  implement the simply-supported axial condition differently, so an S-end
%  comparison comes out as a real physical difference rather than an assembly
%  check. With free ends on both sides the agreement is 2.202e-11, reproducing
%  the table. R1 kept frozen.
%
%  Inputs (regenerated 2026-10-05):
%    Results_Static_F.mat   <- Static_Baseline_R3 (= R2 with support_type='free')
%    Results_verif_F_R1.mat <- LSTE_solver_R11, matching pressure-only cfg:
%      NL=5, N_r=9, N_z=11, R_i=0.1, R_o=0.2, L=0.5, W_GPL=0, UD porosity
%      e3=0.7 (em3=sqrt(0.7)), T_in=T_inf=300 (no thermal load), h_c=100,
%      P_i=10 MPa, BC_z='F'.
%  Chapter-4 house style (Times, 14 pt, grid+box, no title); colour and B&W.
clearvars; clc; close all;
base = 'c:/Users/InfosaicUser/Desktop/MSc/Lord-Shulman-theory-thermoelastic-cylinder/claude';
fdir = fullfile(base,'figures_validation'); if ~exist(fdir,'dir'), mkdir(fdir); end
tdir = fullfile(base,'thesis_chapter');
FNT='Times New Roman'; FSZ=14;

%% ---------------- TEST 1: static assembly cross-check --------------------
S = load(fullfile(base,'Results_Static_F.mat'));
D = load(fullfile(base,'Results_verif_F_R1.mat'));

z_mid = round(S.N_z/2);
U_stat = []; r_stat = [];
for e = 1:S.NL
    U_stat = [U_stat; S.U_layer{e}(:, z_mid)];   %#ok<AGROW>
    r_stat = [r_stat; S.r_nodes{e}(:)];          %#ok<AGROW>
end
U_dyn = D.U_inf_prof(:);
n = min(numel(U_stat), numel(U_dyn));
U_stat = U_stat(1:n); U_dyn = U_dyn(1:n); r_stat = r_stat(1:n);
Ri = r_stat(1); Ro = r_stat(end); xi = (r_stat - Ri)/(Ro - Ri);

dabs = abs(U_stat - U_dyn);
relmax = max(dabs)/max(abs(U_stat));
fprintf('TEST 1  n=%d  max|u|=%.6e m  max abs diff=%.3e m  max rel diff=%.3e\n', ...
        n, max(abs(U_stat)), max(dabs), relmax);

for mode = 1:2
    bw = (mode==2);
    if bw, c1=[0 0 0]; c2=[0.45 0.45 0.45]; sfx='_bw';
    else,  c1=[0 0.447 0.741]; c2=[0.850 0.325 0.098]; sfx=''; end
    f = figure('Position',[60 60 1150 460],'Color','w');
    tiledlayout(f,1,2,'TileSpacing','compact','Padding','compact');

    nexttile; hold on;
    plot(xi, U_stat*1e6, '-', 'Color',c1,'LineWidth',1.8);
    plot(xi(1:2:end), U_dyn(1:2:end)*1e6, 'o','Color',c2,'LineWidth',1.2, ...
         'MarkerSize',7,'MarkerFaceColor','w');
    grid on; box on; set(gca,'FontName',FNT,'FontSize',FSZ);
    xlabel('\xi','FontName',FNT); ylabel('u  (\mum)','FontName',FNT);
    legend({'independent static solver','dynamic solver, static limit'}, ...
           'Location','northeast','FontName',FNT,'FontSize',FSZ-1);

    nexttile;
    semilogy(xi, max(dabs,realmin)*1e6, '-s','Color',c1,'LineWidth',1.5, ...
             'MarkerSize',5,'MarkerFaceColor','w');
    grid on; box on; set(gca,'FontName',FNT,'FontSize',FSZ);
    xlabel('\xi','FontName',FNT); ylabel('|u_{static} - u_{dyn}|  (\mum)','FontName',FNT);

    print(f, fullfile(fdir,['verif_test1_static_R1' sfx '.png']),'-dpng','-r130');
    savefig(f, fullfile(fdir,['verif_test1_static_R1' sfx '.fig']));
    close(f);
end

fid = fopen(fullfile(tdir,'verif_test1_static_R1.csv'),'w');
fprintf(fid,'quantity,value,unit\n');
fprintf(fid,'radial points compared,%d,-\n', n);
fprintf(fid,'max |u| independent static solver,%.6e,m\n', max(abs(U_stat)));
fprintf(fid,'max |u| dynamic solver static limit,%.6e,m\n', max(abs(U_dyn)));
fprintf(fid,'max absolute difference,%.6e,m\n', max(dabs));
fprintf(fid,'max relative difference,%.6e,-\n', relmax);
fclose(fid);

%% ---------------- TEST 5: second-sound wave table ------------------------
M = readtable(fullfile(tdir,'ls_wave_mesh_convergence_R1.csv'));
fid = fopen(fullfile(tdir,'verif_test5_lswave_R1.csv'),'w');
fprintf(fid,'N_r,radial points,Linf relative error,L2 relative error\n');
for i = 1:height(M)
    fprintf(fid,'%d,%d,%.3e,%.3e\n', M.N_r(i), M.radial_points(i), M.Linf_rel(i), M.L2_rel(i));
end
fclose(fid);
fprintf('TEST 5 table written (%d mesh rows)\n', height(M));
disp('VALIDATION_FIGS_R2 DONE');
