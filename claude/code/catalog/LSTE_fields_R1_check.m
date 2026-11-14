%% LSTE_fields_R1_check.m — integrity check of the strain/stress post-processing
%  R1 (2026-11-14). For every case used by catalog_fields_R1 the final stored
%  state is turned into stresses with LSTE_fields_R1 + LSTE_case_props_R1 and
%  compared with the S_rr, S_tt, S_zz and T that the solver itself saved at
%  z = L/2. A pass means the recomputed moduli, DQ derivatives and Hooke law
%  reproduce the solver's own post-processing; only then are the new fields
%  (strains, shear, w) trusted. Prints one line per case; errors if any case
%  exceeds tol (relative to max|S|).
%  Run from claude/:  addpath('code/catalog'); LSTE_fields_R1_check
pdir = 'param_studies_ch4'; tol = 1e-8;
cases = {'BASE','A_GPL_O','A_GPL_X','A_GPL_V','A_GPL_A','B_POR_O','B_POR_X','B_POR_V','B_POR_A', ...
    'E_EM3_9675','E_EM3_7776','D_W_001','D_W_005','D_W_009','D_W_015','D2_W_010','D2_W_020', ...
    'D2_W_040','D2_W_080','C_FOURIER','C_TAU_004','C_TAU_015','F_BC_SC','F_BC_C','G_P000', ...
    'G_P010','G_P100','I_UNCOUPLED','J_HC_100','J_HC_1000','K_RO_200','K_RO_500','L_NL_3', ...
    'L_NL_5','L_NL_9','L_NL_15','Q_L_1','Q_L_5','Q_L_10','O_AB_100','O_AB_400','O_AB_1000', ...
    'P_BT_010','P_BT_100','P_BT_200','P_BT_500T','P_BT_2000T','M_GAUSS_LS','M_GAUSS_FOU', ...
    'T3_DPL','T3_GN3'};
worst = 0;
for i = 1:numel(cases)
    nm = cases{i};
    [P,D] = LSTE_case_props_R1(pdir,nm);
    S = load(fullfile(pdir,[nm '.mat']),'snaps','snap_t','S_rr','S_tt','S_zz','T_all','r_all');
    iz0 = round(D.N_z/2);
    [E,IR] = ndgrid(1:D.NL,1:D.N_r);
    sel = [E(:)'; IR(:)'; iz0*ones(1,numel(E))]';     % layer-major, as r_all
    sel = sortrows([sel],[1 2]);
    F = LSTE_fields_R1(D,P,S.snaps{end},sel);
    sc = max(abs(S.S_tt));
    e1 = max(abs(F.Srr(:)-S.S_rr(:)))/max(abs(S.S_rr));
    e2 = max(abs(F.Stt(:)-S.S_tt(:)))/sc;
    e3 = max(abs(F.Szz(:)-S.S_zz(:)))/max(abs(S.S_zz));
    e4 = max(abs(F.r(:)-S.r_all(:)));
    e5 = max(abs(300+F.th(:)-S.T_all(:)));
    m  = max([e1 e2 e3]);
    worst = max(worst,m);
    fprintf('%-12s Srr %.1e  Stt %.1e  Szz %.1e  r %.1e  T %.1e  t_end %g\n',nm,e1,e2,e3,e4,e5,S.snap_t(end));
end
fprintf('worst relative stress error over %d cases: %.2e (tol %.0e)\n',numel(cases),worst,tol);
if worst > tol, error('LSTE_fields_R1_check:fail','post-processing does not reproduce the solver stresses'); end
disp('LSTE_fields_R1_check PASSED');
