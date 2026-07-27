# run_R6_verify.ps1 — verify claude_R6 (per-end BC + overridable GPL dims)
#  (1) REGRESSION: identical cfg -> R6 must match R5 digit-for-digit
#  (2) FEATURE: mixed BC (S at z=0, C at z=L) runs and sits between S-S and C-C
#  (3) FEATURE: GPL aspect-ratio override changes the stiffness/result
$here   = "c:\Users\InfosaicUser\Desktop\MSc\Lord-Shulman-theory-thermoelastic-cylinder\claude"
$out    = "$here\results"
$matlab = "C:\Program Files\MATLAB\R2026a\bin\matlab.exe"
New-Item -ItemType Directory -Force $out | Out-Null

# small, quick, but non-trivial test problem (identical for R5 and R6)
$cfg = "'theory','LS','tau0',50,'coupling_on',true,'GPL_pattern','V'," +
       "'porosity_on',true,'porosity_pattern','A','W_GPL_total',0.04,'em3',0.8980," +
       "'BC_z','S','NL',3,'N_r',9,'N_z',11,'R_i',0.1,'R_o',0.2,'L',0.5," +
       "'T_in_val',600,'T_inf',300,'h_c',10,'t0_ramp',0.5,'P_i',1e6,'total_time',20,'dt',0.1"

function Run($solver, $extra, $name) {
    $c = "cfg=struct($cfg $extra); cfg.out_name='results\$name.mat'; cfg.store_full_history=false;"
    $cmd = "cd('$here'); try, $c $solver; catch ME, disp(getReport(ME)); exit(1); end; exit(0)"
    & $matlab -batch $cmd -logfile "$out\$name.log" | Out-Null
    "  $name exit=$LASTEXITCODE"
}

Write-Output "== R6 verification =="
Run "claude_R5" ""                          "R6ver_R5ref"
Run "claude_R6" ""                          "R6ver_R6def"
Run "claude_R6" ",'BC_z0','S','BC_zL','C'"  "R6ver_mixed"
Run "claude_R6" ",'BC_z','S'"               "R6ver_SS"
Run "claude_R6" ",'BC_z','C'"               "R6ver_CC"
Run "claude_R6" ",'a_GPL',5.0e-6"           "R6ver_aspect"

# compare in MATLAB
$cmp = @"
cd('$here');
R5=load('results/R6ver_R5ref.mat'); R6=load('results/R6ver_R6def.mat');
dT=max(abs(R5.T_all(:)-R6.T_all(:))); dS=max(abs(R5.S_tt(:)-R6.S_tt(:)));
fprintf('REGRESSION R6 vs R5: max|dT_all|=%.3e  max|dS_tt|=%.3e\n', dT, dS);
SS=load('results/R6ver_SS.mat'); CC=load('results/R6ver_CC.mat'); MX=load('results/R6ver_mixed.mat');
uSS=max(abs(SS.hist_U)); uCC=max(abs(CC.hist_U)); uMX=max(abs(MX.hist_U));
fprintf('MIXED BC check: |u|max  S-S=%.4e  mixed=%.4e  C-C=%.4e  (mixed between? %d)\n', ...
        uSS,uMX,uCC, (uMX>=min(uSS,uCC)-1e-12)&&(uMX<=max(uSS,uCC)+1e-12));
AS=load('results/R6ver_aspect.mat');
fprintf('ASPECT check: max|dT| base-vs-aspect = %.3e (should be > 0)\n', max(abs(R6.T_all(:)-AS.T_all(:))));
"@
$cmp | Out-File "$out\_cmp.m" -Encoding utf8
& $matlab -batch "run('$out\_cmp.m')" -logfile "$out\R6ver_compare.log" | Out-Null
Get-Content "$out\R6ver_compare.log"
