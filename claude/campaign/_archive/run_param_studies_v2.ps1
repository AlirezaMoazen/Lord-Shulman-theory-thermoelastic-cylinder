# run_param_studies_v2.ps1 — FULL thesis parametric campaign, SEQUENTIAL
# (parallel MATLAB instances hit license limits -> one at a time, robust)
# All cases run claude_R4 (regression case BASE_R4 included).
$ErrorActionPreference = 'Continue'
$here = "c:\Users\InfosaicUser\Desktop\MSc\Lord-Shulman-theory-thermoelastic-cylinder\claude"
$out  = "$here\param_studies"
New-Item -ItemType Directory -Force $out | Out-Null
$log = "$out\run_log_v2.txt"
"CAMPAIGN START $(Get-Date -Format 'HH:mm:ss')" | Out-File $log -Encoding utf8

$base = "'LS_enabled',true,'tau0',50,'coupling_on',true," +
        "'GPL_pattern','UD','porosity_on',true,'porosity_pattern','UD'," +
        "'W_GPL_total',0.04,'em3',0.8980,'BC_z','S'," +
        "'NL',5,'N_r',9,'N_z',11,'R_i',0.1,'R_o',0.2,'L',0.5," +
        "'T_in_val',600,'T_inf',300,'h_c',10,'t0_ramp',0.5,'P_i',1e6," +
        "'total_time',100,'dt',0.1"

$cases = [ordered]@{
  # ---- regression: R4 with base config must equal R3_1 BASE ----
  'BASE_R4'     = ""
  # ---- Study A: GPL patterns ----
  'A_GPL_O'     = ",'GPL_pattern','O'"
  'A_GPL_X'     = ",'GPL_pattern','X'"
  'A_GPL_V'     = ",'GPL_pattern','V'"
  'A_GPL_A'     = ",'GPL_pattern','A'"
  # ---- Study B: porosity patterns ----
  'B_POR_O'     = ",'porosity_pattern','O'"
  'B_POR_X'     = ",'porosity_pattern','X'"
  'B_POR_V'     = ",'porosity_pattern','V'"
  'B_POR_A'     = ",'porosity_pattern','A'"
  # ---- Study C: relaxation time ----
  'C_FOURIER'   = ",'LS_enabled',false"
  'C_TAU_01'    = ",'tau0',17"
  'C_TAU_06'    = ",'tau0',100"
  # ---- Study D: GPL weight fraction ----
  'D_W_000'     = ",'W_GPL_total',0"
  'D_W_001'     = ",'W_GPL_total',0.01"
  'D_W_008'     = ",'W_GPL_total',0.08"
  # ---- Study E: porosity level ----
  'E_EM3_9675'  = ",'em3',0.9675"
  'E_EM3_7776'  = ",'em3',0.7776"
  # ---- Study F: end BCs ----
  'F_BC_C'      = ",'BC_z','C'"
  # ---- Study G: pressure ----
  'G_NOPRESS'   = ",'P_i',0"
  # ================= UNIQUE EXTENSION STUDIES (beyond Rezaei) =============
  # ---- Study H: GPL x porosity INTERACTION matrix (nobody has this) ----
  'H_XGPL_OPOR' = ",'GPL_pattern','X','porosity_pattern','O'"
  'H_XGPL_APOR' = ",'GPL_pattern','X','porosity_pattern','A'"
  'H_VGPL_OPOR' = ",'GPL_pattern','V','porosity_pattern','O'"
  'H_VGPL_APOR' = ",'GPL_pattern','V','porosity_pattern','A'"
  # ---- Study I: thermo-mechanical coupling contribution ----
  'I_UNCOUPLED' = ",'coupling_on',false"
  # ---- Study J: outer convection strength (Biot study) ----
  'J_HC_100'    = ",'h_c',100"
  'J_HC_1000'   = ",'h_c',1000"
  # ---- Study K: wall thickness (incl. the MZ-spec geometry Ro=0.3) ----
  'K_RO_015'    = ",'R_o',0.15"
  'K_RO_030'    = ",'R_o',0.3"
  # ---- Study L: number of physical layers (manufacturing granularity) ----
  'L_NL_3'      = ",'NL',3"
  'L_NL_8'      = ",'NL',8"
  # ---- Study M: Gaussian thermal shock (novelty loading, LS vs Fourier) ----
  'M_GAUSS_LS'  = ",'T_in_mode','gauss','t_g0',10,'sig_g',3"
  'M_GAUSS_FOU' = ",'T_in_mode','gauss','t_g0',10,'sig_g',3,'LS_enabled',false"
  # ---- Study N: dynamic (sinusoidal) pressure with LS ----
  'N_SINE_P'    = ",'P_time_mode','sine','t0_P',50,'P_i',5e6"
}

$matlab = "C:\Program Files\MATLAB\R2026a\bin\matlab.exe"
$done=0; $failed=0
foreach ($name in $cases.Keys) {
    $mat = "$out\$name.mat"
    if ((Test-Path $mat) -and ((Get-Item $mat).Length -gt 10kb)) {
        "SKIP $name (exists)" | Add-Content $log -Encoding utf8; continue
    }
    $ov  = $cases[$name]
    # merge overrides into the base struct field-by-field (struct() forbids
    # duplicate field names, so appending pairs does NOT work)
    $cfg = "cfg=struct($base);"
    if ($ov -ne "") {
        $ovPairs = $ov.TrimStart(',')
        $cfg += " ov=struct($ovPairs); fo=fieldnames(ov); for ii=1:numel(fo), cfg.(fo{ii})=ov.(fo{ii}); end;"
    }
    $cfg += " cfg.out_name='param_studies\$name.mat'; cfg.store_full_history=false;"
    $cmd = "cd('$here'); try, $cfg claude_R4; catch ME, disp(getReport(ME)); exit(1); end; exit(0)"
    "RUN  $name  $(Get-Date -Format 'HH:mm:ss')" | Add-Content $log -Encoding utf8
    & $matlab -batch $cmd -logfile "$out\$name.log" | Out-Null
    if ($LASTEXITCODE -eq 0 -and (Test-Path $mat)) {
        $done++;   "DONE $name  $(Get-Date -Format 'HH:mm:ss')" | Add-Content $log -Encoding utf8
    } else {
        $failed++; "FAIL $name (exit=$LASTEXITCODE)" | Add-Content $log -Encoding utf8
    }
}
"CAMPAIGN END $(Get-Date -Format 'HH:mm:ss')  done=$done failed=$failed" | Add-Content $log -Encoding utf8
Write-Output "done=$done failed=$failed"
