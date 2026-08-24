# run_conv_explore.ps1 — EXPLORATORY convergence sweep at a new anchor point
# (author request 2026-08-24): anchor N_r=11, N_z=13, N_L=7 (NOT the locked
# reference mesh N_r=15/N_z=11 — that stays unchanged; this is a standalone
# diagnostic study, output kept in its own folder so it never touches
# param_studies_ch4). Runs claude_R9 (validated digit-identical to R8, ~2.1x
# faster) serially for clean timing. Same reference-case physics as the
# locked campaign (run_nz_sweep.ps1), only N_r/N_z/N_L differ per case.
$here = "c:\Users\InfosaicUser\Desktop\MSc\Lord-Shulman-theory-thermoelastic-cylinder\claude"
$out  = "$here\param_studies_conv_explore"
if (-not (Test-Path $out)) { New-Item -ItemType Directory -Path $out | Out-Null }
$matlab = "C:\Program Files\MATLAB\R2026a\bin\matlab.exe"
$base = "'LS_enabled',true,'tau0',418,'coupling_on',true,'GPL_pattern','UD'," +
        "'porosity_on',true,'porosity_pattern','UD','W_GPL_total',0.003,'em3',0.8604," +
        "'BC_z','S','NL',7,'N_r',11,'N_z',13,'R_i',1.0,'R_o',1.5,'L',2.1," +
        "'T_in_val',600,'T_inf',300,'h_c',10,'t0_ramp',2,'P_i',50e6," +
        "'total_time',3000,'dt',1,'store_full_history',false"
# case => @(Nr, Nz, NL); anchor (EXP_ANCHOR) = Nr11/Nz13/NL7, shared by all 3 ladders
$cases = [ordered]@{
    'EXP_ANCHOR' = @(11,13,7)
    'EXP_NR05'=@(5,13,7);  'EXP_NR07'=@(7,13,7);  'EXP_NR09'=@(9,13,7);  'EXP_NR13'=@(13,13,7); 'EXP_NR15'=@(15,13,7)
    'EXP_NZ05'=@(11,5,7);  'EXP_NZ07'=@(11,7,7);  'EXP_NZ09'=@(11,9,7);  'EXP_NZ11'=@(11,11,7); 'EXP_NZ15'=@(11,15,7)
    'EXP_NL03'=@(11,13,3); 'EXP_NL05'=@(11,13,5); 'EXP_NL09'=@(11,13,9); 'EXP_NL15'=@(11,13,15)
}
$tlog = "$out\conv_explore_timing.txt"
"CONV_EXPLORE SWEEP START $(Get-Date -Format 'HH:mm:ss')" | Out-File $tlog -Encoding utf8
foreach ($n in $cases.Keys) {
    $mat = "$out\$n.mat"
    if ((Test-Path $mat) -and ((Get-Item $mat).Length -gt 20kb)) { "SKIP $n" | Add-Content $tlog -Encoding utf8; continue }
    $nr=$cases[$n][0]; $nz=$cases[$n][1]; $nl=$cases[$n][2]
    $cfg = "cfg=struct($base); cfg.N_r=$nr; cfg.N_z=$nz; cfg.NL=$nl; cfg.out_name='param_studies_conv_explore/$n.mat';"
    $cmd = "cd('$here'); addpath('code/solver'); try, $cfg claude_R9; catch ME, disp(getReport(ME)); exit(1); end; exit(0)"
    $el = (Measure-Command { & $matlab -batch $cmd -logfile "$out\$n.log" | Out-Null }).TotalSeconds
    $ok = ($LASTEXITCODE -eq 0) -and (Test-Path $mat)
    "$(if($ok){'DONE'}else{'FAIL'}) $n  Nr=$nr Nz=$nz NL=$nl  $([math]::Round($el)) s  serial" | Add-Content $tlog -Encoding utf8
}
"CONV_EXPLORE SWEEP END $(Get-Date -Format 'HH:mm:ss')" | Add-Content $tlog -Encoding utf8
Get-Content $tlog
