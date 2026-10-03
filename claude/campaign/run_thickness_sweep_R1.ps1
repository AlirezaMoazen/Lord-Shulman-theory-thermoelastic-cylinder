# run_thickness_sweep_R1.ps1 — adds the thick-wall case R_o/R_i = 5 to the
# K_thickness study. The existing points are R_o/R_i = 1.25 / 1.5 (BASE) / 2.0.
#
# TIME WINDOW: the thickness cases keep the same diffusive window by scaling the
# simulated time with the square of the wall thickness h = R_o - R_i, so every
# case is integrated over a comparable Fourier-number range Fo = a*t/h^2 and
# takes the same number of steps:
#       h = 0.25  ->  750 s  @ dt 0.25
#       h = 0.50  -> 3000 s  @ dt 1       (BASE)
#       h = 1.00  -> 12000 s @ dt 4
#       h = 4.00  -> 192000 s @ dt 64     (this case, factor (4/0.5)^2 = 64)
# 3000 steps, as in BASE.
#
# Same base config and solver (LSTE_solver_R11) as run_aspect_sweep_R2.ps1.
$ErrorActionPreference = 'Continue'
$here = "c:\Users\InfosaicUser\Desktop\MSc\Lord-Shulman-theory-thermoelastic-cylinder\claude"
$out  = "$here\param_studies_ch4"
New-Item -ItemType Directory -Force $out | Out-Null
$log  = "$out\run_log_thickness_R1.txt"
"THICKNESS SWEEP R1 START $(Get-Date -Format 'HH:mm:ss')" | Out-File $log -Encoding utf8

$base = "'LS_enabled',true,'tau0',418,'coupling_on',true,'GPL_pattern','UD'," +
        "'porosity_on',true,'porosity_pattern','UD','W_GPL_total',0.003,'em3',0.8604," +
        "'BC_z','S','NL',7,'N_r',15,'N_z',11,'R_i',1.0,'R_o',1.5,'L',2.1," +
        "'T_in_val',600,'T_inf',300,'h_c',10,'t0_ramp',2,'P_i',50e6," +
        "'total_time',3000,'dt',1,'store_full_history',false"

$cases = [ordered]@{}
$cases["K_RO_500"] = ",'R_o',5.0,'total_time',192000,'dt',64"

$matlab = "C:\Program Files\MATLAB\R2026a\bin\matlab.exe"
$maxPar = 2; $jobs = @()
foreach ($name in $cases.Keys) {
    $mat = "$out\$name.mat"
    if ((Test-Path $mat) -and ((Get-Item $mat).Length -gt 50kb)) { "SKIP $name" | Add-Content $log -Encoding utf8; continue }
    $ov = $cases[$name].TrimStart(',')
    $cfg = "cfg=struct($base); ov=struct($ov); fo=fieldnames(ov); for ii=1:numel(fo), cfg.(fo{ii})=ov.(fo{ii}); end; cfg.out_name='param_studies_ch4/$name.mat';"
    $cmd = "cd('$here'); addpath('code/solver'); try, $cfg LSTE_solver_R11; catch ME, disp(getReport(ME)); exit(1); end; exit(0)"
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
"THICKNESS SWEEP R1 END $(Get-Date -Format 'HH:mm:ss')" | Add-Content $log -Encoding utf8
$d=(Get-Content $log|?{$_ -like 'DONE*'}).Count; $f=(Get-Content $log|?{$_ -like 'FAIL*'}).Count
Write-Output "Thickness sweep R1: done=$d failed=$f of $($cases.Count)"
