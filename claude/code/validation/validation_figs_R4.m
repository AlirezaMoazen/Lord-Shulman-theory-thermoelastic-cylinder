
%% validation_figs_R4.m — figure for Chapter-4 verification test 1 (Figure 4-5)
%  R4 (2026-10-07, author request) deletes the right-hand (difference) panel of
%  Figure 4-5, leaving the displacement panel alone. The maximum absolute and
%  relative differences are already in Table 4-7, so that panel duplicated the
%  table. Single panel, so the figure is sized like the single-panel Figure 4-8
%  (760x470). Data, style and numbers are unchanged from R3: free-end comparison,
%  45 radial points, 2.202e-11 relative agreement. Output verif_test1_static_R3.
%  R1-R3 kept frozen; the test-1 / test-5 CSV tables are unchanged and are not
%  rewritten here.
clearvars; clc; close all;
base = 'c:/Users/InfosaicUser/Desktop/MSc/Lord-Shulman-theory-thermoelastic-cylinder/claude';
fdir = fullfile(base,'figures_validation'); if ~exist(fdir,'dir'), mkdir(fdir); end

% ---- Chapter-4 house style (identical constants to R3 / catalog_R11/_color) ----
CO.co={[0 0.447 0.741],[0.850 0.325 0.098],[0.466 0.674 0.188],[0.494 0.184 0.556],[0.20 0.20 0.20]};
CO.ls={'-','-','-','-','-'}; CO.mk={'o','s','^','d','v'}; CO.lw=[1.6 1.4 1.4 1.4 1.4];
BW.co={[0 0 0],[0 0 0],[0.45 0.45 0.45],[0.45 0.45 0.45],[0.68 0.68 0.68]};
BW.ls={'-','--',':','-.','-'}; BW.mk={'o','s','^','d','v'}; BW.lw=[1.4 1.2 1.2 1.2 1.4];
FNT='Times New Roman'; FSZ=14; LGSZ=14;

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
fprintf('TEST 1  n=%d  max|u|=%.6e m  max abs diff=%.3e m  max rel diff=%.3e\n', ...
        n, max(abs(U_stat)), max(dabs), max(dabs)/max(abs(U_stat)));

mi = unique(round(linspace(1,n,8)));   % spaced markers, as in the catalog
for mode = 1:2
    if mode==1, STY=CO; sfx=''; else, STY=BW; sfx='_bw'; end
    f = figure('Position',[60 60 760 470],'Color','w');
    tiledlayout(f,1,1,'TileSpacing','tight','Padding','tight');
    nexttile; hold on;
    plot(xi, U_stat*1e6, 'Color',STY.co{1},'LineStyle',STY.ls{1},'LineWidth',STY.lw(1), ...
         'Marker',STY.mk{1},'MarkerIndices',mi,'MarkerSize',5,'MarkerFaceColor','w');
    plot(xi, U_dyn*1e6,  'Color',STY.co{2},'LineStyle',STY.ls{2},'LineWidth',STY.lw(2), ...
         'Marker',STY.mk{2},'MarkerIndices',mi,'MarkerSize',5,'MarkerFaceColor','w');
    grid on; box on; set(gca,'FontName',FNT,'FontSize',FSZ);
    xlabel('\xi','FontName',FNT); ylabel('u  (\mum)','FontName',FNT);
    legend({'independent static solver','dynamic solver, static limit'}, ...
           'Location','northeast','FontName',FNT,'FontSize',LGSZ-2);
    print(f, fullfile(fdir,['verif_test1_static_R3' sfx '.png']),'-dpng','-r130');
    savefig(f, fullfile(fdir,['verif_test1_static_R3' sfx '.fig']));
    close(f);
end
disp('VALIDATION_FIGS_R4 DONE');
