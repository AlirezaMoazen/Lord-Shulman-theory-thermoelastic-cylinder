%% test_r7_regression.m — LSTE_solver_R7 must equal LSTE_solver_R6 in physics; DOF map correct
%  Runs both solvers at a small fast config and compares all physics outputs,
%  then checks the R7 DOF-mapping artifacts (NodeMap, DOFmap, GridDOF).
clc;
% NOTE: each solver does `clearvars -except cfg` internally, so set cfg fresh
% before each call (nothing else survives the call).
cfg = struct('N_r',6,'N_z',7,'NL',3,'total_time',3,'dt',0.5,'store_full_history',false,'out_name','test_R6.mat'); LSTE_solver_R6;
cfg = struct('N_r',6,'N_z',7,'NL',3,'total_time',3,'dt',0.5,'store_full_history',false,'out_name','test_R7.mat'); LSTE_solver_R7;

clearvars;
A = load('test_R6.mat'); B = load('test_R7.mat');
flds = {'S_rr','S_tt','S_zz','T_all','U_all','hist_T','hist_U','hist_W','tv'};
maxd = 0;
fprintf('\n===== R6 vs R7 physics regression =====\n');
for i = 1:numel(flds)
    f = flds{i}; d = max(abs(A.(f)(:) - B.(f)(:)));
    maxd = max(maxd, d);
    fprintf('  %-8s  max|R6-R7| = %.3e\n', f, d);
end
if maxd == 0, verdict = 'DIGIT-IDENTICAL'; else, verdict = sprintf('DIFF=%.2e',maxd); end
fprintf('  OVERALL physics diff: %s\n', verdict);

fprintf('\n===== R7 DOF-mapping artifacts =====\n');
Nn = B.NL*B.N_r*B.N_z; Ndof = 3*Nn;
fprintf('  NodeMap %dx%d (expect %dx%d);  DOFmap %dx%d (expect %dx8);  GridDOF %s\n', ...
    size(B.NodeMap,1),size(B.NodeMap,2),B.N_r,B.N_z, ...
    size(B.DOFmap,1),size(B.DOFmap,2),Ndof, mat2str(size(B.GridDOF)));
% NodeMap(ir,iz) must equal (ir-1)*N_z+iz
NM = ((1:B.N_r).'-1)*B.N_z + (1:B.N_z);
fprintf('  NodeMap correct ? %d\n', isequal(B.NodeMap, NM));
% DOFmap: gdof column is 1..Ndof, comp blocks in order, decode matches idx
okg = isequal(B.DOFmap(:,1)', 1:Ndof);
okc = isequal(B.DOFmap(:,2)', [ones(1,Nn) 2*ones(1,Nn) 3*ones(1,Nn)]);
fprintf('  DOFmap gdof==1:Ndof ? %d   comp-blocks theta|u|w ? %d\n', okg, okc);
% spot-check GridDOF vs the field-major formula
e=2; ir=3; iz=4; base_lin = (e-1)*B.N_r*B.N_z + (ir-1)*B.N_z + iz;
gd = squeeze(B.GridDOF(e,ir,iz,:)).';
fprintf('  GridDOF(2,3,4,:) = %s  expect [%d %d %d] ? %d\n', ...
    mat2str(gd), base_lin, Nn+base_lin, 2*Nn+base_lin, ...
    isequal(gd,[base_lin, Nn+base_lin, 2*Nn+base_lin]));
% CSV present?
fprintf('  DOFmap CSV exists ? %d\n', exist('test_R7_DOFmap.csv','file')==2);
