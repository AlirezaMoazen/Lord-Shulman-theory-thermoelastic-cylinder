# run_aspect_sweep_R2.ps1 — adds the two b/t cases that straddle the percolation
# threshold (2026-10-03). R1 is kept and is not re-run (skip-existing).
#
# WHY: at the reference W_GPL = 0.3% the conductivity model percolates only when
#   V_GPL > 1/p with p = a_GPL/t_GPL, i.e. a/t > 294.6; with a/b = 1.6667 fixed
#   that is b/t > 176.7. Measured k_eff (incl. the UD porosity factor em3^2):
#       b/t <= 176 : 0.2961 W/mK  (bare matrix, no GPL network)
#       b/t = 200  : 21.75        b/t = 500 : 65.16
#       b/t = 1000 : 77.08        b/t = 2000: 82.22
#   So the requested sweep b/t = 10 / 100 / 1000 has its two lower values BOTH
#   below the threshold, where the thermal field is identical (bare epoxy) and
#   essentially no heat reaches the probe within the 3000 s window. These two
#   extra cases put points either side of the switch so the transition is visible.
#
# Same base config and solver (LSTE_solver_R11) as run_aspect_sweep_R1.ps1, and
# the same t_GPL-based b/t convention (a/b held at the reference 1.67).
$ErrorActionPreference = 'Continue'
$here = "c:\Users\InfosaicUser\Desktop\MSc\Lord-Shulman-theory-thermoelastic-cylinder\claude"
$out  = "$here\param_studies_ch4"
New-Item -ItemType Directory -Force $out | Out-Null
$log  = "$out\run_log_aspect_R2.txt"
"ASPECT SWEEP R2 START $(Get-Date -Format 'HH:mm:ss')" | Out-File $log -Encoding utf8

$base = "'LS_enabled',true,'tau0',418,'coupling_on',true,'GPL_pattern','UD'," +
        "'porosity_on',true,'porosity_pattern','UD','W_GPL_total',0.003,'em3',0.8604," +
        "'BC_z','S','NL',7,'N_r',15,'N_z',11,'R_i',1.0,'R_o',1.5,'L',2.1," +
        "'T_in_val',600,'T_inf',300,'h_c',10,'t0_ramp',2,'P_i',50e6," +
        "'total_time',3000,'dt',1,'store_full_history',false"

$cases = [ordered]@{}
$cases["P_BT_200"]  = ",'t_GPL',7.5e-9"      # b/t = 200  (just above threshold)
$cases["P_BT_500T"] = ",'t_GPL',3.0e-9"      # b/t = 500  (t_GPL-based; distinct
                                             # from the old b_GPL-based P_BT_500)
$cases["P_BT_2000T"]= ",'t_GPL',0.75e-9"     # b/t = 2000 (t_GPL-based)

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
"ASPECT SWEEP R2 END $(Get-Date -Format 'HH:mm:ss')" | Add-Content $log -Encoding utf8
$d=(Get-Content $log|?{$_ -like 'DONE*'}).Count; $f=(Get-Content $log|?{$_ -like 'FAIL*'}).Count
Write-Output "Aspect sweep R2: done=$d failed=$f of $($cases.Count)"
