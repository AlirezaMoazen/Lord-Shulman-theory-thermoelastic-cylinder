function P = LSTE_props_R1(ov, NL, R_i, R_o)
%LSTE_PROPS_R1  Per-layer material constants of LSTE_solver_R11 (section 3), standalone.
%  R1 (2026-11-14): post-processing helper. The campaign .mat files store the
%  displacement/temperature states but not the layer moduli, which are needed
%  to turn a stored state into strains and stresses. This function repeats
%  section 3 of LSTE_solver_R11 (GPL + porosity model, isotropic layers) for the
%  property-relevant cfg fields only, and returns the layer constants.
%  It does not touch the solver. Integrity is checked in LSTE_fields_R1_check:
%  the stress recomputed from a stored state must equal the S_tt the solver saved.
%
%  ov : struct of overrides w.r.t. the thesis BASE case. Recognised fields:
%       GPL_pattern, porosity_on, porosity_pattern, W_GPL_total, em3,
%       a_GPL, b_GPL, t_GPL      (anything else is rejected)
%  NL, R_i, R_o : layer count and inner/outer radius of the case (from the .mat).
%  P  : struct with NL x 1 vectors E, nu, al, C11, C12, C13, C33, C55.

% --- thesis BASE values (run_ch4_campaign.ps1) ---
GPL_pattern = 'UD';  porosity_on = true;  porosity_pattern = 'UD';
W_GPL_total = 0.003; em3 = 0.8604;
a_GPL = 2.5e-6;  b_GPL = 1.5e-6;  t_GPL = 1.5e-9;
if nargin < 1 || isempty(ov), ov = struct(); end
ok = {'GPL_pattern','porosity_on','porosity_pattern','W_GPL_total','em3','a_GPL','b_GPL','t_GPL'};
fn = fieldnames(ov);
for i = 1:numel(fn)
    if ~any(strcmp(fn{i},ok)), error('LSTE_props_R1:badField','unsupported override "%s"',fn{i}); end
    eval([fn{i} ' = ov.(fn{i});']); %#ok<EVLDOT>
end
l_total = R_o - R_i;

% ---- copied from LSTE_solver_R11 section 3 (GPL branch only) ----
E_GPL = 1.01e12; rho_GPL = 1062.5;
alpha_GPL = 5e-6; k_GPL = 3000;  nu_GPL = 0.186;
E_m = 3.0e9;  nu_m = 0.34;  rho_m = 1200;
alpha_m = 60e-6;  k_m = 0.246;
gamma_conn = 0.5;

E_L_ = zeros(NL,1); nu_L_ = zeros(NL,1); al_L = zeros(NL,1);
em1 = (pi/2)*(1 - em3);
em2 = (1 - em3)/(1 - 2/pi);
em4 = (pi/4)*em3;
em5 = em4;
for e = 1:NL
    switch upper(GPL_pattern)
        case 'UD', Wg = W_GPL_total;
        case 'O',  Wg = 4*W_GPL_total*(((NL+1)/2) - abs(e-(NL+1)/2))/(NL+2);
        case 'X',  Wg = 4*W_GPL_total*(0.5 + abs(e-(NL+1)/2))/(NL+2);
        case 'V',  Wg = 2*W_GPL_total*e/(NL+1);
        case 'A',  Wg = 2*W_GPL_total*(NL+1-e)/(NL+1);
        otherwise, error('bad GPL_pattern');
    end
    Vg = Wg / (Wg + (rho_GPL/rho_m)*(1-Wg));
    xiL = 2*a_GPL/t_GPL;  xiT = 2*b_GPL/t_GPL;
    etL = (E_GPL/E_m-1)/(E_GPL/E_m+xiL);
    etT = (E_GPL/E_m-1)/(E_GPL/E_m+xiT);
    EL  = (1+xiL*etL*Vg)/(1-etL*Vg)*E_m;
    ET  = (1+xiT*etT*Vg)/(1-etT*Vg)*E_m;
    Es  = 3/8*EL + 5/8*ET;
    nus = Vg*nu_GPL + (1-Vg)*nu_m;
    als = Vg*alpha_GPL + (1-Vg)*alpha_m;
    if porosity_on
        rm  = R_i + l_total/(2*NL) + (e-1)*l_total/NL;
        zet = (rm - (R_i + R_o)/2)/l_total;
        switch upper(porosity_pattern)
            case 'UD', Pm = em3;
            case 'O',  Pm = 1 - em1*cos(pi*zet);
            case 'X',  Pm = 1 - em2*(1 - cos(pi*zet));
            case 'V',  Pm = 2*em4*cos(pi*zet/2 + pi/4);
            case 'A',  Pm = 2*em5*cos(pi*zet/2 - pi/4);
            otherwise, error('bad porosity_pattern');
        end
        Pm = max(0, min(1, Pm));
        Pf = Pm^2;
    else
        Pf = 1;
    end
    E_L_(e) = Es*Pf;  nu_L_(e) = nus;  al_L(e) = als;
end
P.E = E_L_;  P.nu = nu_L_;  P.al = al_L;
P.C11 = (1-nu_L_).*E_L_./((1+nu_L_).*(1-2*nu_L_));
P.C12 = nu_L_.*E_L_./((1+nu_L_).*(1-2*nu_L_));
P.C13 = P.C12;  P.C33 = P.C11;
P.C55 = E_L_./(2*(1+nu_L_));
end
