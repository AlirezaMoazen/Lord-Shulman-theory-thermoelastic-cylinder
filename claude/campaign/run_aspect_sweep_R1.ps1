# run_aspect_sweep_R1.ps1 — extended GPL aspect-ratio sweeps (author request 2026-10-03)
#
# Adds the 4 cases needed for the wider aspect-ratio ranges:
#     a/b = 1, 1.67, 4, 10      and      b/t = 10, 100, 1000
# a/b = 1 already exists as O_AB_100; a/b = 1.67 and b/t = 1000 are BASE.
#
# SWEEP CONVENTION (differs from the original O_AB/P_BT cases — read this):
#   a/b sweep : vary a_GPL, hold b_GPL = 1.5e-6 and t_GPL = 1.5e-9.
#               Same convention as the original O_AB_100/O_AB_267.
#   b/t sweep : vary t_GPL, hold a_GPL = 2.5e-6 and b_GPL = 1.5e-6, so a/b
#               stays at the reference 1.67 across the whole sweep.
#               The ORIGINAL P_BT_500/P_BT_2000 instead varied b_GPL, which
#               changes a/b at the same time (a/b = 3.33 at P_BT_500) and so
#               confounded the two ratios. Varying t_GPL is also what the
#               Ch4 §4-8 text actually describes ("b/t, entering through the
#               characteristic thickness t_GPL"). Reaching b/t = 10 via b_GPL
#               would need b_GPL = 1.5e-8, forcing a/b = 167 — meaningless.
#               => the new b/t figure is NOT directly comparable to the old one.
#
# Base config and solver: identical to run_ch4_campaign.ps1 except the solver is
# LSTE_solver_R11 (physics-identical to R7 per REVISIONS §1: R8 byte-identical to
# R7, R9 digit-identical to R8 and ~2.1x faster, R10 reporting-only, R11 comments),
# so these cases are directly comparable with the existing BASE/O_AB_100 data.
$ErrorActionPreference = 'Continue'
$here = "c:\Users\InfosaicUser\Desktop\MSc\Lord-Shulman-theory-thermoelastic-cylinder\claude"
$out  = "$here\param_studies_ch4"
New-Item -ItemType Directory -Force $out | Out-Null
$log  = "$out\run_log_aspect_R1.txt"
"ASPECT SWEEP R1 START $(Get-Date -Format 'HH:mm:ss')" | Out-File $log -Encoding utf8

$base = "'LS_enabled',true,'tau0',418,'coupling_on',true,'GPL_pattern','UD'," +
        "'porosity_on',true,'porosity_pattern','UD','W_GPL_total',0.003,'em3',0.8604," +
        "'BC_z','S','NL',7,'N_r',15,'N_z',11,'R_i',1.0,'R_o',1.5,'L',2.1," +
        "'T_in_val',600,'T_inf',300,'h_c',10,'t0_ramp',2,'P_i',50e6," +
        "'total_time',3000,'dt',1,'store_full_history',false"

$cases = [ordered]@{}
# a/b sweep (b_GPL = 1.5e-6 fixed) : a_GPL = (a/b) * 1.5e-6
$cases["O_AB_400"]  = ",'a_GPL',6.0e-6"     # a/b = 4
$cases["O_AB_1000"] = ",'a_GPL',15.0e-6"    # a/b = 10
# b/t sweep (b_GPL = 1.5e-6 fixed) : t_GPL = 1.5e-6 / (b/t)
$cases["P_BT_010"]  = ",'t_GPL',1.5e-7"     # b/t = 10
$cases["P_BT_100"]  = ",'t_GPL',1.5e-8"     # b/t = 100

$matlab = "C:\Program Files\MATLAB\R2026a\bin\matlab.exe"
$maxPar = 3; $jobs = @()
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
"ASPECT SWEEP R1 END $(Get-Date -Format 'HH:mm:ss')" | Add-Content $log -Encoding utf8
$d=(Get-Content $log|?{$_ -like 'DONE*'}).Count; $f=(Get-Content $log|?{$_ -like 'FAIL*'}).Count; $s=(Get-Content $log|?{$_ -like 'SKIP*'}).Count
Write-Output "Aspect sweep R1: done=$d failed=$f skipped=$s of $($cases.Count)"
