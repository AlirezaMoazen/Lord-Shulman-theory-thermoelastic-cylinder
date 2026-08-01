# run_ch4_campaign.ps1 — full Chapter-4 campaign at the NEW geometry (claude_R7)
# Base: R_i=1, R_o=1.5, h=0.5, l=2.1, N_L=7, W=0.3%, e_m3=0.8604, T_in=600, P_i=50 MPa,
#       LS tau0=418 (tau*=0.15), total_time=3000 s, dt=1 s. Prom.1/2/3 folded in.
# store_full_history=true only for shock studies (relaxation C, gaussian M, theory T3).
# 3 concurrent MATLAB, skip-existing. Merge pattern (last field wins) so overrides work.
$ErrorActionPreference = 'Continue'
$here = "c:\Users\InfosaicUser\Desktop\MSc\Lord-Shulman-theory-thermoelastic-cylinder\claude"
$out  = "$here\param_studies_ch4"
New-Item -ItemType Directory -Force $out | Out-Null
$log  = "$out\run_log.txt"
"CAMPAIGN CH4 START $(Get-Date -Format 'HH:mm:ss')" | Out-File $log -Encoding utf8

$base = "'LS_enabled',true,'tau0',418,'coupling_on',true,'GPL_pattern','UD'," +
        "'porosity_on',true,'porosity_pattern','UD','W_GPL_total',0.003,'em3',0.8604," +
        "'BC_z','S','NL',7,'N_r',15,'N_z',11,'R_i',1.0,'R_o',1.5,'L',2.1," +
        "'T_in_val',600,'T_inf',300,'h_c',10,'t0_ramp',2,'P_i',50e6," +
        "'total_time',3000,'dt',1,'store_full_history',false"

$cases = [ordered]@{}
foreach ($p in 'O','X','V','A') { $cases["A_GPL_$p"] = ",'GPL_pattern','$p'" }
foreach ($p in 'O','X','V','A') { $cases["B_POR_$p"] = ",'porosity_pattern','$p'" }
$cases["E_EM3_9675"]=",'em3',0.9675";  $cases["E_EM3_7776"]=",'em3',0.7776"
$cases["D_W_001"]=",'W_GPL_total',0.001"; $cases["D_W_005"]=",'W_GPL_total',0.005"
$cases["D_W_009"]=",'W_GPL_total',0.009"; $cases["D_W_015"]=",'W_GPL_total',0.015"
$cases["D2_W_010"]=",'W_GPL_total',0.01"; $cases["D2_W_020"]=",'W_GPL_total',0.02"
$cases["D2_W_040"]=",'W_GPL_total',0.04"; $cases["D2_W_080"]=",'W_GPL_total',0.08"
$cases["C_FOURIER"]=",'LS_enabled',false,'total_time',6000,'store_full_history',true"
$cases["C_TAU_004"]=",'tau0',111,'total_time',6000,'store_full_history',true"
$cases["C_TAU_015"]=",'total_time',6000,'store_full_history',true"
$cases["C_TAU_044"]=",'tau0',1226,'total_time',6000,'store_full_history',true"
$cases["C_TAU_087"]=",'tau0',2425,'total_time',6000,'store_full_history',true"
$cases["F_BC_C"]=",'BC_z','C'"; $cases["F_BC_SC"]=",'BC_z0','S','BC_zL','C'"
$cases["G_P000"]=",'P_i',0"; $cases["G_P010"]=",'P_i',10e6"; $cases["G_P100"]=",'P_i',100e6"
foreach ($g in 'UD','O','X','V','A') { foreach ($p in 'UD','O','X','V','A') {
    $cases["H_${g}_${p}"] = ",'GPL_pattern','$g','porosity_pattern','$p'" } }
$cases["I_UNCOUPLED"]=",'coupling_on',false"
$cases["J_HC_100"]=",'h_c',100"; $cases["J_HC_1000"]=",'h_c',1000"
$cases["K_RO_125"]=",'R_o',1.25,'total_time',750,'dt',0.25"
$cases["K_RO_200"]=",'R_o',2.0,'total_time',12000,'dt',4"
$cases["L_NL_3"]=",'NL',3"; $cases["L_NL_5"]=",'NL',5"; $cases["L_NL_9"]=",'NL',9"; $cases["L_NL_15"]=",'NL',15"
$cases["Q_L_1"]=",'L',1"; $cases["Q_L_5"]=",'L',5"; $cases["Q_L_10"]=",'L',10"
$cases["O_AB_100"]=",'a_GPL',1.5e-6";  $cases["O_AB_267"]=",'a_GPL',4.0e-6"
$cases["P_BT_500"]=",'b_GPL',0.75e-6"; $cases["P_BT_2000"]=",'b_GPL',3.0e-6"
$cases["M_GAUSS_LS"]=",'T_in_mode','gauss','t_g0',300,'sig_g',90,'store_full_history',true"
$cases["M_GAUSS_FOU"]=",'T_in_mode','gauss','t_g0',300,'sig_g',90,'LS_enabled',false,'store_full_history',true"
$cases["T3_DPL"]=",'theory','DPL','tau_T',209,'total_time',6000,'store_full_history',true"
$cases["T3_GN3"]=",'theory','GN3','total_time',6000,'store_full_history',true"
$cases["BASE"]=",'store_full_history',true"
# Prom.3 #4: time-integration convergence (dt) + spatial convergence (N_r)
$cases["TI_DT_05"]=",'dt',0.5"; $cases["TI_DT_20"]=",'dt',2"; $cases["TI_DT_50"]=",'dt',5"
$cases["SM_NR07"]=",'N_r',7"; $cases["SM_NR09"]=",'N_r',9"; $cases["SM_NR11"]=",'N_r',11"; $cases["SM_NR13"]=",'N_r',13"

$matlab = "C:\Program Files\MATLAB\R2026a\bin\matlab.exe"
$maxPar = 3; $jobs = @()
foreach ($name in $cases.Keys) {
    $mat = "$out\$name.mat"
    if ((Test-Path $mat) -and ((Get-Item $mat).Length -gt 50kb)) { "SKIP $name" | Add-Content $log -Encoding utf8; continue }
    $ov = $cases[$name].TrimStart(',')
    $cfg = "cfg=struct($base); ov=struct($ov); fo=fieldnames(ov); for ii=1:numel(fo), cfg.(fo{ii})=ov.(fo{ii}); end; cfg.out_name='param_studies_ch4/$name.mat';"
    $cmd = "cd('$here'); addpath('code/solver'); try, $cfg claude_R7; catch ME, disp(getReport(ME)); exit(1); end; exit(0)"
    while (@($jobs | Where-Object { $_.State -eq 'Running' }).Count -ge $maxPar) { Start-Sleep -Seconds 5 }
    "RUN  $name  $(Get-Date -Format 'HH:mm:ss')" | Add-Content $log -Encoding utf8
    $jobs += Start-Job -Name $name -ScriptBlock {
        param($m, $c, $n, $od, $lg)
        & $m -batch $c -logfile "$od\$n.log" | Out-Null
        $ok = ($LASTEXITCODE -eq 0) -and (Test-Path "$od\$n.mat")
        "$(if($ok){'DONE'}else{'FAIL'}) $n  $(Get-Date -Format 'HH:mm:ss')" | Add-Content $lg -Encoding utf8
    } -ArgumentList $matlab, $cmd, $name, $out, $log
}
$jobs | Wait-Job | Out-Null
"CAMPAIGN CH4 END $(Get-Date -Format 'HH:mm:ss')" | Add-Content $log -Encoding utf8
$d=(Get-Content $log|?{$_ -like 'DONE*'}).Count; $f=(Get-Content $log|?{$_ -like 'FAIL*'}).Count; $s=(Get-Content $log|?{$_ -like 'SKIP*'}).Count
Write-Output "CH4 campaign: done=$d failed=$f skipped=$s of $($cases.Count)"
