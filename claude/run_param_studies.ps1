# run_param_studies.ps1 — orchestrates the thesis parametric studies
# Each case = one MATLAB batch process running claude_R3_1 with its cfg.
# Results land in param_studies\<case>.mat ; log in param_studies\run_log.txt
$ErrorActionPreference = 'Continue'
$here = "c:\Users\InfosaicUser\Desktop\MSc\Lord-Shulman-theory-thermoelastic-cylinder\claude"
$out  = "$here\param_studies"
New-Item -ItemType Directory -Force $out | Out-Null
$log = "$out\run_log.txt"
"PARAM STUDIES START $(Get-Date -Format 'HH:mm:ss')" | Out-File $log -Encoding utf8

# ---- common (base) configuration ----
# tau0 = 50 s corresponds to tau_bar = tau0*kappa_ref/R_o^2 ~ 0.3 for the
# base UD-GPL material (kappa_ref ~ 2.4e-4 m^2/s, R_o = 0.2 m)
$base = "'LS_enabled',true,'tau0',50,'coupling_on',true," +
        "'GPL_pattern','UD','porosity_on',true,'porosity_pattern','UD'," +
        "'W_GPL_total',0.04,'em3',0.8980,'BC_z','S'," +
        "'NL',5,'N_r',9,'N_z',11,'R_i',0.1,'R_o',0.2,'L',0.5," +
        "'T_in_val',600,'T_inf',300,'h_c',10,'t0_ramp',0.5,'P_i',1e6," +
        "'total_time',100,'dt',0.1"

# ---- case list: name -> cfg overrides appended to base ----
$cases = [ordered]@{
  # base case (shared by all studies)
  'BASE'        = ""
  # Study A: GPL patterns
  'A_GPL_O'     = ",'GPL_pattern','O'"
  'A_GPL_X'     = ",'GPL_pattern','X'"
  'A_GPL_V'     = ",'GPL_pattern','V'"
  'A_GPL_A'     = ",'GPL_pattern','A'"
  # Study B: porosity patterns
  'B_POR_O'     = ",'porosity_pattern','O'"
  'B_POR_X'     = ",'porosity_pattern','X'"
  'B_POR_V'     = ",'porosity_pattern','V'"
  'B_POR_A'     = ",'porosity_pattern','A'"
  # Study C: relaxation time (Fourier + tau_bar ~ 0.1 / 0.3(base) / 0.6)
  'C_FOURIER'   = ",'LS_enabled',false"
  'C_TAU_01'    = ",'tau0',17"
  'C_TAU_06'    = ",'tau0',100"
  # Study D: GPL weight fraction
  'D_W_000'     = ",'W_GPL_total',0"
  'D_W_001'     = ",'W_GPL_total',0.01"
  'D_W_008'     = ",'W_GPL_total',0.08"
  # Study E: porosity level (em3 rows of the author's table)
  'E_EM3_9675'  = ",'em3',0.9675"
  'E_EM3_7776'  = ",'em3',0.7776"
  # Study F: end BCs (S = base, C here) -> feeds the Q4 discussion
  'F_BC_C'      = ",'BC_z','C'"
  # Study G: pressure off (Rezaei-style comparison)
  'G_NOPRESS'   = ",'P_i',0"
}

$matlab = "C:\Program Files\MATLAB\R2026a\bin\matlab.exe"
$maxPar = 3
$jobs = @()
foreach ($name in $cases.Keys) {
    $ov  = $cases[$name]
    $cfg = "cfg=struct($base$ov,'out_name','param_studies\\$name.mat','store_full_history',false);"
    $cmd = "cd('$here'); try, $cfg claude_R3_1; catch ME, disp(getReport(ME)); exit(1); end; exit(0)"
    while (@($jobs | Where-Object { $_.State -eq 'Running' }).Count -ge $maxPar) { Start-Sleep -Seconds 10 }
    "LAUNCH $name  $(Get-Date -Format 'HH:mm:ss')" | Add-Content $log -Encoding utf8
    $jobs += Start-Job -Name $name -ScriptBlock {
        param($m, $c, $n, $lg)
        $o = & $m -batch $c 2>&1 | Out-String
        $tag = if ($LASTEXITCODE -eq 0) { 'DONE ' } else { 'FAIL ' }
        "$tag$n  $(Get-Date -Format 'HH:mm:ss')" | Add-Content $lg -Encoding utf8
        if ($LASTEXITCODE -ne 0) { ($o | Select-String -Pattern 'Error' | Select-Object -First 3) | Add-Content $lg -Encoding utf8 }
    } -ArgumentList $matlab, $cmd, $name, $log
}
$jobs | Wait-Job | Out-Null
"ALL COMPLETE $(Get-Date -Format 'HH:mm:ss')" | Add-Content $log -Encoding utf8
$done = (Get-Content $log | Where-Object { $_ -like 'DONE*' }).Count
$failed = (Get-Content $log | Where-Object { $_ -like 'FAIL*' }).Count
Write-Output "done=$done failed=$failed of $($cases.Count)"
