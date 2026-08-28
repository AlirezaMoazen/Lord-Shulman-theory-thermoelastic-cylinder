# run_R6_verify2.ps1 — corrected R6 verification (field-merge cfg, ASCII compare)
$here   = "c:\Users\InfosaicUser\Desktop\MSc\Lord-Shulman-theory-thermoelastic-cylinder\claude"
$out    = "$here\results"
$matlab = "C:\Program Files\MATLAB\R2026a\bin\matlab.exe"

$base = "'theory','LS','tau0',50,'coupling_on',true,'GPL_pattern','V'," +
        "'porosity_on',true,'porosity_pattern','A','W_GPL_total',0.04,'em3',0.8980," +
        "'BC_z','S','NL',3,'N_r',9,'N_z',11,'R_i',0.1,'R_o',0.2,'L',0.5," +
        "'T_in_val',600,'T_inf',300,'h_c',10,'t0_ramp',0.5,'P_i',1e6,'total_time',20,'dt',0.1"

function Run($solver, $ov, $name) {
    $cfg = "cfg=struct($base);"
    if ($ov -ne "") { $cfg += " ov=struct($ov); fo=fieldnames(ov); for ii=1:numel(fo), cfg.(fo{ii})=ov.(fo{ii}); end;" }
    $cfg += " cfg.out_name='results\$name.mat'; cfg.store_full_history=false;"
    $cmd = "cd('$here'); try, $cfg $solver; catch ME, disp(getReport(ME)); exit(1); end; exit(0)"
    & $matlab -batch $cmd -logfile "$out\$name.log" | Out-Null
    "  $name exit=$LASTEXITCODE"
}

Write-Output "== R6 verification (corrected) =="
Run "LSTE_solver_R5" ""                          "R6ver_R5ref"
Run "LSTE_solver_R6" ""                          "R6ver_R6def"
Run "LSTE_solver_R6" "'BC_z0','S','BC_zL','C'"   "R6ver_mixed"
Run "LSTE_solver_R6" "'BC_z','S'"                "R6ver_SS"
Run "LSTE_solver_R6" "'BC_z','C'"                "R6ver_CC"
Run "LSTE_solver_R6" "'a_GPL',5.0e-6"            "R6ver_aspect"

$cmp = "cd('$here');" +
"R5=load('results/R6ver_R5ref.mat'); R6=load('results/R6ver_R6def.mat');" +
"dT=max(abs(R5.T_all(:)-R6.T_all(:))); dS=max(abs(R5.S_tt(:)-R6.S_tt(:)));" +
"fprintf('REGRESSION R6 vs R5: max|dT_all|=%.3e  max|dS_tt|=%.3e\n', dT, dS);" +
"SS=load('results/R6ver_SS.mat'); CC=load('results/R6ver_CC.mat'); MX=load('results/R6ver_mixed.mat');" +
"uSS=max(abs(SS.hist_U)); uCC=max(abs(CC.hist_U)); uMX=max(abs(MX.hist_U));" +
"fprintf('MIXED BC: |u|max S-S=%.4e mixed=%.4e C-C=%.4e  between=%d\n', uSS,uMX,uCC, (uMX>=min(uSS,uCC)-1e-9)&&(uMX<=max(uSS,uCC)+1e-9));" +
"AS=load('results/R6ver_aspect.mat');" +
"fprintf('ASPECT: max|dT| base-vs-aspect=%.3e (should be >0)\n', max(abs(R6.T_all(:)-AS.T_all(:))));"
[IO.File]::WriteAllText("$out\_cmp2.m", $cmp, (New-Object System.Text.ASCIIEncoding))
& $matlab -batch "cd('$out'); _cmp2" -logfile "$out\R6ver_compare2.log" | Out-Null
Get-Content "$out\R6ver_compare2.log"
