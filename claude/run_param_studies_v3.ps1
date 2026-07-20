# run_param_studies_v3.ps1 — parametric campaign, PARALLEL (3 concurrent)
# Fixed cfg merging (field-by-field). Skips cases whose .mat already exists.
$ErrorActionPreference = 'Continue'
$here = "c:\Users\InfosaicUser\Desktop\MSc\Lord-Shulman-theory-thermoelastic-cylinder\claude"
$out  = "$here\param_studies"
New-Item -ItemType Directory -Force $out | Out-Null
$log = "$out\run_log_v3.txt"
"CAMPAIGN v3 START $(Get-Date -Format 'HH:mm:ss')" | Out-File $log -Encoding utf8

$base = "'LS_enabled',true,'tau0',50,'coupling_on',true," +
        "'GPL_pattern','UD','porosity_on',true,'porosity_pattern','UD'," +
        "'W_GPL_total',0.04,'em3',0.8980,'BC_z','S'," +
        "'NL',5,'N_r',9,'N_z',11,'R_i',0.1,'R_o',0.2,'L',0.5," +
        "'T_in_val',600,'T_inf',300,'h_c',10,'t0_ramp',0.5,'P_i',1e6," +
        "'total_time',100,'dt',0.1"

$cases = [ordered]@{
  'BASE_R4'     = ""
  'A_GPL_O'     = ",'GPL_pattern','O'"
  'A_GPL_X'     = ",'GPL_pattern','X'"
  'A_GPL_V'     = ",'GPL_pattern','V'"
  'A_GPL_A'     = ",'GPL_pattern','A'"
  'B_POR_O'     = ",'porosity_pattern','O'"
  'B_POR_X'     = ",'porosity_pattern','X'"
  'B_POR_V'     = ",'porosity_pattern','V'"
  'B_POR_A'     = ",'porosity_pattern','A'"
  'C_FOURIER'   = ",'LS_enabled',false"
  'C_TAU_01'    = ",'tau0',17"
  'C_TAU_06'    = ",'tau0',100"
  'D_W_000'     = ",'W_GPL_total',0"
  'D_W_001'     = ",'W_GPL_total',0.01"
  'D_W_008'     = ",'W_GPL_total',0.08"
  'E_EM3_9675'  = ",'em3',0.9675"
  'E_EM3_7776'  = ",'em3',0.7776"
  'F_BC_C'      = ",'BC_z','C'"
  'G_NOPRESS'   = ",'P_i',0"
  'H_XGPL_OPOR' = ",'GPL_pattern','X','porosity_pattern','O'"
  'H_XGPL_APOR' = ",'GPL_pattern','X','porosity_pattern','A'"
  'H_VGPL_OPOR' = ",'GPL_pattern','V','porosity_pattern','O'"
  'H_VGPL_APOR' = ",'GPL_pattern','V','porosity_pattern','A'"
  'I_UNCOUPLED' = ",'coupling_on',false"
  'J_HC_100'    = ",'h_c',100"
  'J_HC_1000'   = ",'h_c',1000"
  'K_RO_015'    = ",'R_o',0.15"
  'K_RO_030'    = ",'R_o',0.3"
  'L_NL_3'      = ",'NL',3"
  'L_NL_8'      = ",'NL',8"
  'M_GAUSS_LS'  = ",'T_in_mode','gauss','t_g0',10,'sig_g',3"
  'M_GAUSS_FOU' = ",'T_in_mode','gauss','t_g0',10,'sig_g',3,'LS_enabled',false"
  'N_SINE_P'    = ",'P_time_mode','sine','t0_P',50,'P_i',5e6"
}

$matlab = "C:\Program Files\MATLAB\R2026a\bin\matlab.exe"
$maxPar = 3
$jobs = @()
foreach ($name in $cases.Keys) {
    $mat = "$out\$name.mat"
    if ((Test-Path $mat) -and ((Get-Item $mat).Length -gt 10kb)) {
        "SKIP $name (exists)" | Add-Content $log -Encoding utf8; continue
    }
    $ov  = $cases[$name]
    $cfg = "cfg=struct($base);"
    if ($ov -ne "") {
        $ovPairs = $ov.TrimStart(',')
        $cfg += " ov=struct($ovPairs); fo=fieldnames(ov); for ii=1:numel(fo), cfg.(fo{ii})=ov.(fo{ii}); end;"
    }
    $cfg += " cfg.out_name='param_studies\$name.mat'; cfg.store_full_history=false;"
    $cmd = "cd('$here'); try, $cfg claude_R4; catch ME, disp(getReport(ME)); exit(1); end; exit(0)"
    while (@($jobs | Where-Object { $_.State -eq 'Running' }).Count -ge $maxPar) { Start-Sleep -Seconds 8 }
    "RUN  $name  $(Get-Date -Format 'HH:mm:ss')" | Add-Content $log -Encoding utf8
    $jobs += Start-Job -Name $name -ScriptBlock {
        param($m, $c, $n, $od, $lg)
        & $m -batch $c -logfile "$od\$n.log" | Out-Null
        $ok = ($LASTEXITCODE -eq 0) -and (Test-Path "$od\$n.mat")
        $tag = if ($ok) { 'DONE' } else { 'FAIL' }
        "$tag $n  $(Get-Date -Format 'HH:mm:ss')" | Add-Content $lg -Encoding utf8
    } -ArgumentList $matlab, $cmd, $name, $out, $log
}
$jobs | Wait-Job | Out-Null
"CAMPAIGN v3 END $(Get-Date -Format 'HH:mm:ss')" | Add-Content $log -Encoding utf8
$d = (Get-Content $log | Where-Object { $_ -like 'DONE*' }).Count
$f = (Get-Content $log | Where-Object { $_ -like 'FAIL*' }).Count
$s = (Get-Content $log | Where-Object { $_ -like 'SKIP*' }).Count
Write-Output "done=$d failed=$f skipped=$s of $($cases.Count)"
