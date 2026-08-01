# run_param_studies_v5.ps1 — REVISION cases needing claude_R6
#   infinite-length limit, mixed end supports, GPL aspect-ratio study,
#   full GPL x porosity interaction matrix.
# Parallel (3 concurrent), field-by-field cfg merge, skip-existing.
$ErrorActionPreference = 'Continue'
$here = "c:\Users\InfosaicUser\Desktop\MSc\Lord-Shulman-theory-thermoelastic-cylinder\claude"
$out  = "$here\param_studies"
New-Item -ItemType Directory -Force $out | Out-Null
$log = "$out\run_log_v5.txt"
"CAMPAIGN v5 START $(Get-Date -Format 'HH:mm:ss')" | Out-File $log -Encoding utf8

$base = "'LS_enabled',true,'tau0',50,'coupling_on',true," +
        "'GPL_pattern','UD','porosity_on',true,'porosity_pattern','UD'," +
        "'W_GPL_total',0.04,'em3',0.8980,'BC_z','S'," +
        "'NL',5,'N_r',9,'N_z',11,'R_i',0.1,'R_o',0.2,'L',0.5," +
        "'T_in_val',600,'T_inf',300,'h_c',10,'t0_ramp',0.5,'P_i',1e6," +
        "'total_time',100,'dt',0.1"

$cases = [ordered]@{
  # --- infinite-length approach (L grows; base L=0.5) ---
  'P_INF_L10' = ",'L',1.0"
  'P_INF_L20' = ",'L',2.0"
  'P_INF_L40' = ",'L',4.0"
  # --- mixed end supports (one simple, one clamped) ---
  'Q_MIX_SC'  = ",'BC_z0','S','BC_zL','C'"
  # --- GPL aspect ratios (base a=2.5e-6, b=1.5e-6, t=1.5e-9) ---
  # length/width via a_GPL:
  'R_ASP_LEN_L' = ",'a_GPL',1.5e-6"
  'R_ASP_LEN_H' = ",'a_GPL',4.0e-6"
  # width/thickness via t_GPL:
  'R_ASP_THK_L' = ",'t_GPL',3.0e-9"
  'R_ASP_THK_H' = ",'t_GPL',0.75e-9"
  # --- full GPL x porosity matrix (12 new; X/O,X/A,V/O,V/A already in H) ---
  'S_HM_O_O' = ",'GPL_pattern','O','porosity_pattern','O'"
  'S_HM_O_X' = ",'GPL_pattern','O','porosity_pattern','X'"
  'S_HM_O_V' = ",'GPL_pattern','O','porosity_pattern','V'"
  'S_HM_O_A' = ",'GPL_pattern','O','porosity_pattern','A'"
  'S_HM_X_X' = ",'GPL_pattern','X','porosity_pattern','X'"
  'S_HM_X_V' = ",'GPL_pattern','X','porosity_pattern','V'"
  'S_HM_V_X' = ",'GPL_pattern','V','porosity_pattern','X'"
  'S_HM_V_V' = ",'GPL_pattern','V','porosity_pattern','V'"
  'S_HM_A_O' = ",'GPL_pattern','A','porosity_pattern','O'"
  'S_HM_A_X' = ",'GPL_pattern','A','porosity_pattern','X'"
  'S_HM_A_V' = ",'GPL_pattern','A','porosity_pattern','V'"
  'S_HM_A_A' = ",'GPL_pattern','A','porosity_pattern','A'"
}

$matlab = "C:\Program Files\MATLAB\R2026a\bin\matlab.exe"
$maxPar = 3
$jobs = @()
foreach ($name in $cases.Keys) {
    $mat = "$out\$name.mat"
    if ((Test-Path $mat) -and ((Get-Item $mat).Length -gt 10kb)) {
        "SKIP $name (exists)" | Add-Content $log -Encoding utf8; continue
    }
    $ov  = $cases[$name].TrimStart(',')
    $cfg = "cfg=struct($base); ov=struct($ov); fo=fieldnames(ov); for ii=1:numel(fo), cfg.(fo{ii})=ov.(fo{ii}); end;"
    $cfg += " cfg.out_name='param_studies\$name.mat'; cfg.store_full_history=false;"
    $cmd = "cd('$here'); try, $cfg claude_R6; catch ME, disp(getReport(ME)); exit(1); end; exit(0)"
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
"CAMPAIGN v5 END $(Get-Date -Format 'HH:mm:ss')" | Add-Content $log -Encoding utf8
$d = (Get-Content $log | Where-Object { $_ -like 'DONE*' }).Count
$f = (Get-Content $log | Where-Object { $_ -like 'FAIL*' }).Count
$s = (Get-Content $log | Where-Object { $_ -like 'SKIP*' }).Count
Write-Output "done=$d failed=$f skipped=$s of $($cases.Count)"
