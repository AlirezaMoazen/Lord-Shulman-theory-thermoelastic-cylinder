$matlab = "C:\Program Files\MATLAB\R2026a\bin\matlab.exe"
$cmd = "addpath('code/catalog'); run_smooth_T3; exit(0)"
& $matlab -batch $cmd
