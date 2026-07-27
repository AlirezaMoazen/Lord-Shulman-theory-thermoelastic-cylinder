cd('c:\Users\InfosaicUser\Desktop\MSc\Lord-Shulman-theory-thermoelastic-cylinder\claude');
R5=load('results/R6ver_R5ref.mat'); R6=load('results/R6ver_R6def.mat');
dT=max(abs(R5.T_all(:)-R6.T_all(:))); dS=max(abs(R5.S_tt(:)-R6.S_tt(:)));
fprintf('REGRESSION R6 vs R5: max|dT_all|=%.3e  max|dS_tt|=%.3e\n', dT, dS);
SS=load('results/R6ver_SS.mat'); CC=load('results/R6ver_CC.mat'); MX=load('results/R6ver_mixed.mat');
uSS=max(abs(SS.hist_U)); uCC=max(abs(CC.hist_U)); uMX=max(abs(MX.hist_U));
fprintf('MIXED BC check: |u|max  S-S=%.4e  mixed=%.4e  C-C=%.4e  (mixed between? %d)\n', ...
        uSS,uMX,uCC, (uMX>=min(uSS,uCC)-1e-12)&&(uMX<=max(uSS,uCC)+1e-12));
AS=load('results/R6ver_aspect.mat');
fprintf('ASPECT check: max|dT| base-vs-aspect = %.3e (should be > 0)\n', max(abs(R6.T_all(:)-AS.T_all(:))));
