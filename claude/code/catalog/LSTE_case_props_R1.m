function [P, D] = LSTE_case_props_R1(pdir, name)
%LSTE_CASE_PROPS_R1  Layer constants of one Chapter-4 campaign case.
%  R1 (2026-11-14). Looks up the property-relevant cfg overrides of case `name`
%  (copied from campaign/run_ch4_campaign.ps1 and the three sweep scripts
%  run_aspect_sweep_R1/R2, run_thickness_sweep_R1) and builds the layer
%  constants with LSTE_props_R1. Geometry (NL, R_i, R_o) is read from the
%  saved .mat, so thickness/layer-count cases need no entry here.
%  Cases not listed use the thesis BASE properties; geometry/BC/time-only
%  cases (L, h_c, P_i, BC, theory, tau, ...) do not change the moduli.
%  D : the geometry fields of the .mat (NL, N_r, N_z, r_nodes, z_nodes).
D = load(fullfile(pdir,[name '.mat']),'NL','N_r','N_z','r_nodes','z_nodes');
ov = struct();
tok = regexp(name,'^A_GPL_([OXVA])$','tokens','once');
if ~isempty(tok), ov.GPL_pattern = tok{1}; end
tok = regexp(name,'^B_POR_([OXVA])$','tokens','once');
if ~isempty(tok), ov.porosity_pattern = tok{1}; end
switch name
    case 'E_EM3_9675', ov.em3 = 0.9675;
    case 'E_EM3_7776', ov.em3 = 0.7776;
    case 'D_W_001',  ov.W_GPL_total = 0.001;
    case 'D_W_005',  ov.W_GPL_total = 0.005;
    case 'D_W_009',  ov.W_GPL_total = 0.009;
    case 'D_W_015',  ov.W_GPL_total = 0.015;
    case 'D2_W_010', ov.W_GPL_total = 0.01;
    case 'D2_W_020', ov.W_GPL_total = 0.02;
    case 'D2_W_040', ov.W_GPL_total = 0.04;
    case 'D2_W_080', ov.W_GPL_total = 0.08;
    case 'O_AB_100',  ov.a_GPL = 1.5e-6;     % a/b = 1
    case 'O_AB_400',  ov.a_GPL = 6.0e-6;     % a/b = 4
    case 'O_AB_1000', ov.a_GPL = 15.0e-6;    % a/b = 10
    case 'P_BT_010',  ov.t_GPL = 1.5e-7;     % b/t = 10
    case 'P_BT_100',  ov.t_GPL = 1.5e-8;     % b/t = 100
    case 'P_BT_200',  ov.t_GPL = 7.5e-9;     % b/t = 200
    case 'P_BT_500T', ov.t_GPL = 3.0e-9;     % b/t = 500
    case 'P_BT_2000T',ov.t_GPL = 0.75e-9;    % b/t = 2000
end
P = LSTE_props_R1(ov, D.NL, D.r_nodes{1}(1), D.r_nodes{end}(end));
end
