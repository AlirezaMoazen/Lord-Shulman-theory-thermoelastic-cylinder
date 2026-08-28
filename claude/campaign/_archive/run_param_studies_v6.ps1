# run_param_studies_v6.ps1 — LOW GPL weight-fraction study (author 2026-07-28)
# Replaces the 2-4% fill (D_W_020..035) with the literature-range low fractions
# W_GPL = 0.1, 0.3, 0.5, 0.9, 1.5 %. Same base cfg + solver (LSTE_solver_R4) as the
# other weight cases so they are directly comparable. 3 concurrent, skip-existing.
$ErrorActionPreference = 'Continue'
$here = "c:\Users\InfosaicUser\Desktop\MSc\Lord-Shulman-theory-thermoelastic-cylinder\claude"
$out  = "$here\param_studies"
New-Item -ItemType Directory -Force $out | Out-Null
$log = "$out\run_log_v6.txt"
"CAMPAIGN v6 START $(Get-Date -Format 'HH:mm:ss')" | Out-File $log -Encoding utf8

$base = "'LS_enabled',true,'tau0',50,'coupling_on',true," +
        "'GPL_pattern','UD','porosity_on',true,'porosity_pattern','UD'," +
        "'W_GPL_total',0.04,'em3',0.8980,'BC_z','S'," +
        "'NL',5,'N_r',9,'N_z',11,'R_i',0.1,'R_o',0.2,'L',0.5," +
        "'T_in_val',600,'T_inf',300,'h_c',10,'t0_ramp',0.5,'P_i',1e6," +
        "'total_time',100,'dt',0.1"

# low weight fractions: name D3_W_<per-mille>  (0.1%=001 ... 1.5%=015)
$cases = [ordered]@{
  'D3_W_001' = ",'W_GPL_total',0.001"   # 0.1 %
  'D3_W_003' = ",'W_GPL_total',0.003"   # 0.3 %
  'D3_W_005' = ",'W_GPL_total',0.005"   # 0.5 %
  'D3_W_009' = ",'W_GPL_total',0.009"   # 0.9 %
  'D3_W_015' = ",'W_GPL_total',0.015"   # 1.5 %
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
    $ovPairs = $ov.TrimStart(',')
    $cfg += " ov=struct($ovPairs); fo=fieldnames(ov); for ii=1:numel(fo), cfg.(fo{ii})=ov.(fo{ii}); end;"
    $cfg += " cfg.out_name='param_studies\$name.mat'; cfg.store_full_history=false;"
    $cmd = "cd('$here'); try, $cfg LSTE_solver_R4; catch ME, disp(getReport(ME)); exit(1); end; exit(0)"
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
"CAMPAIGN v6 END $(Get-Date -Format 'HH:mm:ss')" | Add-Content $log -Encoding utf8
$d = (Get-Content $log | Where-Object { $_ -like 'DONE*' }).Count
$f = (Get-Content $log | Where-Object { $_ -like 'FAIL*' }).Count
$s = (Get-Content $log | Where-Object { $_ -like 'SKIP*' }).Count
Write-Output "v6 done=$d failed=$f skipped=$s of $($cases.Count)"
