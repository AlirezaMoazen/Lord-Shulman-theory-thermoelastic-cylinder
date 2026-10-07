%% validation_figs_R3.m — figure + tables for Chapter-4 verification tests 1 and 5
%  R3 (2026-10-07, author request) restyles the test-1 figure to the Chapter-4
%  house style used by catalog_R11/_color, and makes the two changes asked for:
%    * both panels now carry a legend (R2 had one only on the left panel);
%    * both panels use the same colour set, taken from catalog_R11_color
%      (colour) and catalog_R11 (B&W), instead of the ad-hoc pair used in R2;
%    * TileSpacing/Padding set to 'tight' as in the catalog, which removes the
%      wide margin that sat between the right-hand panel and the figure border;
%    * fonts, line widths, markers, white marker faces, -r130 print and the
%      paired .png/.fig output all follow the catalog convention.
%  Content and numbers are unchanged from R2: free-end comparison, 45 radial
%  points, 2.202e-11 relative agreement. R1 and R2 kept frozen.
%
%  Test 5 only needs its table assembled (its figure ls_wave_validation_R1
%  already exists); that part is carried over from R2 unchanged.
clearvars; clc; close all;
base = 'c:/Users/InfosaicUser/Desktop/MSc/Lord-Shulman-theory-thermoelastic-cylinder/claude';
fdir = fullfile(base,'figures_validation'); if ~exist(fdir,'dir'), mkdir(fdir); end
tdir = fullfile(base,'thesis_chapter');

% ---- Chapter-4 house style (identical constants to catalog_R11/_color) ----
CO.co={[0 0.447 0.741],[0.850 0.325 0.098],[0.466 0.674 0.188],[0.494 0.184 0.556],[0.20 0.20 0.20]};
CO.ls={'-','-','-','-','-'}; CO.mk={'o','s','^','d','v'}; CO.lw=[1.6 1.4 1.4 1.4 1.4];
BW.co={[0 0 0],[0 0 0],[0.45 0.45 0.45],[0.45 0.45 0.45],[0.68 0.68 0.68]};
BW.ls={'-','--',':','-.','-'}; BW.mk={'o','s','^','d','v'}; BW.lw=[1.4 1.2 1.2 1.2 1.4];
FNT='Times New Roman'; FSZ=14; LGSZ=14;

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

mi = unique(round(linspace(1,n,8)));   % spaced markers, as in the catalog
for mode = 1:2
    if mode==1, STY=CO; sfx=''; else, STY=BW; sfx='_bw'; end
    f = figure('Position',[40 60 1180 470],'Color','w');
    tiledlayout(f,1,2,'TileSpacing','tight','Padding','tight');

    % panel 1 — the two displacement profiles
    nexttile; hold on;
    plot(xi, U_stat*1e6, 'Color',STY.co{1},'LineStyle',STY.ls{1},'LineWidth',STY.lw(1), ...
         'Marker',STY.mk{1},'MarkerIndices',mi,'MarkerSize',5,'MarkerFaceColor','w');
    plot(xi, U_dyn*1e6,  'Color',STY.co{2},'LineStyle',STY.ls{2},'LineWidth',STY.lw(2), ...
         'Marker',STY.mk{2},'MarkerIndices',mi,'MarkerSize',5,'MarkerFaceColor','w');
    grid on; box on; set(gca,'FontName',FNT,'FontSize',FSZ);
    xlabel('\xi','FontName',FNT); ylabel('u  (\mum)','FontName',FNT);
    legend({'independent static solver','dynamic solver, static limit'}, ...
           'Location','northeast','FontName',FNT,'FontSize',LGSZ-2);

    % panel 2 — their difference, same colour set, now with its own legend
    nexttile; hold on;
    plot(xi, max(dabs,realmin)*1e6, 'Color',STY.co{1},'LineStyle',STY.ls{1},'LineWidth',STY.lw(1), ...
         'Marker',STY.mk{1},'MarkerIndices',mi,'MarkerSize',5,'MarkerFaceColor','w');
    set(gca,'YScale','log'); grid on; box on; set(gca,'FontName',FNT,'FontSize',FSZ);
    xlabel('\xi','FontName',FNT); ylabel('|u_{static} - u_{dyn}|  (\mum)','FontName',FNT);
    legend({'difference between the two solvers'}, ...
           'Location','northeast','FontName',FNT,'FontSize',LGSZ-2);

    print(f, fullfile(fdir,['verif_test1_static_R2' sfx '.png']),'-dpng','-r130');
    savefig(f, fullfile(fdir,['verif_test1_static_R2' sfx '.fig']));
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
disp('VALIDATION_FIGS_R3 DONE');
