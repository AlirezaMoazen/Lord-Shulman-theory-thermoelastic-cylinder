# run_param_studies_v4.ps1 — REVISION cases from supervisor review (Prom 3-7)
# Parallel (3 concurrent), field-by-field cfg merge, skip-existing.
# Groups: pressure sweep, extra layer counts, weight-fraction fill (2-4%).
$ErrorActionPreference = 'Continue'
$here = "c:\Users\InfosaicUser\Desktop\MSc\Lord-Shulman-theory-thermoelastic-cylinder\claude"
$out  = "$here\param_studies"
New-Item -ItemType Directory -Force $out | Out-Null
$log = "$out\run_log_v4.txt"
"CAMPAIGN v4 START $(Get-Date -Format 'HH:mm:ss')" | Out-File $log -Encoding utf8

$base = "'LS_enabled',true,'tau0',50,'coupling_on',true," +
        "'GPL_pattern','UD','porosity_on',true,'porosity_pattern','UD'," +
        "'W_GPL_total',0.04,'em3',0.8980,'BC_z','S'," +
        "'NL',5,'N_r',9,'N_z',11,'R_i',0.1,'R_o',0.2,'L',0.5," +
        "'T_in_val',600,'T_inf',300,'h_c',10,'t0_ramp',0.5,'P_i',1e6," +
        "'total_time',100,'dt',0.1"

# NOTE P_i in Pascals: 10 MPa = 10e6. 0 MPa = existing G_NOPRESS; 1 MPa = BASE_R4.
$cases = [ordered]@{
  # --- pressure sweep (supervisor: 0,10,30,50,70,(100) MPa) ---
  'G_P010'   = ",'P_i',10e6"
  'G_P030'   = ",'P_i',30e6"
  'G_P050'   = ",'P_i',50e6"
  'G_P070'   = ",'P_i',70e6"
  'G_P100'   = ",'P_i',100e6"
  # --- extra layer counts (supervisor: NL = 3,5,9,15; have 3,5,8) ---
  'L_NL_9'   = ",'NL',9"
  'L_NL_15'  = ",'NL',15"
  # --- weight-fraction fill 2-4% (supervisor: 2,2.2,2.6,3.5,4%; 4%=base) ---
  'D_W_020'  = ",'W_GPL_total',0.020"
  'D_W_022'  = ",'W_GPL_total',0.022"
  'D_W_026'  = ",'W_GPL_total',0.026"
  'D_W_035'  = ",'W_GPL_total',0.035"
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
"CAMPAIGN v4 END $(Get-Date -Format 'HH:mm:ss')" | Add-Content $log -Encoding utf8
$d = (Get-Content $log | Where-Object { $_ -like 'DONE*' }).Count
$f = (Get-Content $log | Where-Object { $_ -like 'FAIL*' }).Count
$s = (Get-Content $log | Where-Object { $_ -like 'SKIP*' }).Count
Write-Output "done=$d failed=$f skipped=$s of $($cases.Count)"
