# run_nz_sweep.ps1 — AXIAL (N_z) convergence sweep, run SERIALLY for clean timing.
# Fills the missing spatial direction for the Prom.3 #4 minimum-nodes study.
# N_r=15, N_L=7 fixed; vary N_z. store_full_history=false. BASE already covers N_z=11.
$here = "c:\Users\InfosaicUser\Desktop\MSc\Lord-Shulman-theory-thermoelastic-cylinder\claude"
$out  = "$here\param_studies_ch4"
$matlab = "C:\Program Files\MATLAB\R2026a\bin\matlab.exe"
$base = "'LS_enabled',true,'tau0',418,'coupling_on',true,'GPL_pattern','UD'," +
        "'porosity_on',true,'porosity_pattern','UD','W_GPL_total',0.003,'em3',0.8604," +
        "'BC_z','S','NL',7,'N_r',15,'N_z',11,'R_i',1.0,'R_o',1.5,'L',2.1," +
        "'T_in_val',600,'T_inf',300,'h_c',10,'t0_ramp',2,'P_i',50e6," +
        "'total_time',3000,'dt',1,'store_full_history',false"
$nz = [ordered]@{ 'SM_NZ05'=5; 'SM_NZ07'=7; 'SM_NZ09'=9; 'SM_NZ13'=13; 'SM_NZ15'=15 }
$tlog = "$out\nz_timing.txt"
"NZ SWEEP START $(Get-Date -Format 'HH:mm:ss')" | Out-File $tlog -Encoding utf8
foreach ($n in $nz.Keys) {
    $mat = "$out\$n.mat"
    if ((Test-Path $mat) -and ((Get-Item $mat).Length -gt 20kb)) { "SKIP $n" | Add-Content $tlog -Encoding utf8; continue }
    $cfg = "cfg=struct($base); cfg.N_z=$($nz[$n]); cfg.out_name='param_studies_ch4/$n.mat';"
    $cmd = "cd('$here'); addpath('code/solver'); try, $cfg claude_R7; catch ME, disp(getReport(ME)); exit(1); end; exit(0)"
    $el = (Measure-Command { & $matlab -batch $cmd -logfile "$out\$n.log" | Out-Null }).TotalSeconds
    $ok = ($LASTEXITCODE -eq 0) -and (Test-Path $mat)
    "$(if($ok){'DONE'}else{'FAIL'}) $n  N_z=$($nz[$n])  $([math]::Round($el)) s  serial" | Add-Content $tlog -Encoding utf8
}
"NZ SWEEP END $(Get-Date -Format 'HH:mm:ss')" | Add-Content $tlog -Encoding utf8
Get-Content $tlog