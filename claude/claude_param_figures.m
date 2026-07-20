%% ========================================================================
%  claude_param_figures.m — thesis figures from the parametric campaign
%  ------------------------------------------------------------------------
%  Reads param_studies\<case>.mat and produces DIMENSIONLESS comparison
%  figures per study (time histories at mid-thickness + radial profiles).
%
%  Nondimensionalization (group-consistent):
%    Fo   = alpha_ref * t / R_o^2          (alpha_ref: base UD material)
%    T*   = (T - T_inf)/(T_in - T_inf)
%    xi   = (r - R_i)/(R_o - R_i)
%    u*   = u*(lam+2mu)_ref/(beta_ref*dT*h)
%    s*   = sigma/(beta_ref*dT)
%  ========================================================================
clearvars; clc; close all;
pdir = 'param_studies';
fdir = fullfile(pdir,'figures');
if ~exist(fdir,'dir'), mkdir(fdir); end

%% ---- reference properties of the BASE UD material (W=0.04, em3=0.8980) --
% (same formulas as the solver, one layer, UD/UD)
E_GPL=1.01e12; rho_GPL=1062.5; c_GPL=644; alpha_GPL=5e-6; k_GPL=3000; nu_GPL=0.186;
E_m=3.0e9; nu_m=0.34; rho_m=1200; c_m=1110; alpha_m=60e-6; k_m=0.246;
a_GPL=2.5e-6; b_GPL=1.5e-6; t_GPL=1.5e-9; gamma_conn=0.5;
Wg=0.04; em3=0.8980;
Vg = Wg/(Wg+(rho_GPL/rho_m)*(1-Wg));
xiL=2*a_GPL/t_GPL; xiT=2*b_GPL/t_GPL;
etL=(E_GPL/E_m-1)/(E_GPL/E_m+xiL); etT=(E_GPL/E_m-1)/(E_GPL/E_m+xiT);
Es = (3/8*(1+xiL*etL*Vg)/(1-etL*Vg) + 5/8*(1+xiT*etT*Vg)/(1-etT*Vg))*E_m;
nus= Vg*nu_GPL+(1-Vg)*nu_m;  rhs=Vg*rho_GPL+(1-Vg)*rho_m;
cs = Vg*c_GPL+(1-Vg)*c_m;    als=Vg*alpha_GPL+(1-Vg)*alpha_m;
p  = a_GPL/t_GPL;  Hp = log(p+sqrt(p^2-1))*p/sqrt((p^2-1)^3)-1/(p^2-1);
ks = ((2/3)*(Vg-1/p)^gamma_conn/(Hp+1/(k_GPL/k_m-1)))*k_m + k_m;
Pm = em3;  Pf = em3^2;
E_ref=Es*Pf; nu_ref=nus; rho_ref=rhs*Pm; c_ref=cs*Pf; k_ref=ks*Pf; al_ref=als;
alpha_diff = k_ref/(rho_ref*c_ref);              % thermal diffusivity (m^2/s)
lam_ = nu_ref*E_ref/((1+nu_ref)*(1-2*nu_ref));
mu_  = E_ref/(2*(1+nu_ref));
beta_ref = al_ref*(3*lam_+2*mu_);

R_i=0.1; R_o=0.2; hthick=R_o-R_i; dT=300; T_inf=300;
Fo   = @(t) alpha_diff*t/R_o^2;
Tst  = @(T) (T - T_inf)/dT;
ust  = @(u) u*(lam_+2*mu_)/(beta_ref*dT*hthick);
sst  = @(s) s/(beta_ref*dT);
fprintf('alpha_ref = %.3e m^2/s ; Fo(100 s) = %.3f ; tau_bar(50 s) = %.3f\n', ...
        alpha_diff, Fo(100), alpha_diff*50/R_o^2);

%% ---- study definitions: {study title, {case names}, {legend labels}} ----
studies = { ...
 'A_GPL_patterns',   {'BASE_R4','A_GPL_O','A_GPL_X','A_GPL_V','A_GPL_A'}, {'UD','O','X','V','A'};
 'B_porosity_patterns',{'BASE_R4','B_POR_O','B_POR_X','B_POR_V','B_POR_A'}, {'UD','O','X','V','A'};
 'C_relaxation',     {'C_FOURIER','C_TAU_01','BASE_R4','C_TAU_06'}, {'Fourier','\tau^*=0.15','\tau^*=0.44','\tau^*=0.87'};
 'D_GPL_fraction',   {'D_W_000','D_W_001','BASE_R4','D_W_008'}, {'W=0','W=1%','W=4%','W=8%'};
 'E_porosity_level', {'E_EM3_9675','BASE_R4','E_EM3_7776'}, {'e_{m3}=0.9675','e_{m3}=0.8980','e_{m3}=0.7776'};
 'F_end_BC',         {'BASE_R4','F_BC_C'}, {'Simply supported','Clamped'};
 'G_pressure',       {'BASE_R4','G_NOPRESS'}, {'P_i = 1 MPa','P_i = 0'};
 'H_interaction',    {'BASE_R4','H_XGPL_OPOR','H_XGPL_APOR','H_VGPL_OPOR','H_VGPL_APOR'}, ...
                     {'UD/UD','X-GPL+O-por','X-GPL+A-por','V-GPL+O-por','V-GPL+A-por'};
 'I_coupling',       {'BASE_R4','I_UNCOUPLED'}, {'coupled','uncoupled'};
 'J_convection',     {'BASE_R4','J_HC_100','J_HC_1000'}, {'h_c=10','h_c=100','h_c=1000'};
 'K_thickness',      {'K_RO_015','BASE_R4','K_RO_030'}, {'R_o=0.15','R_o=0.20','R_o=0.30'};
 'L_layers',         {'L_NL_3','BASE_R4','L_NL_8'}, {'N_L=3','N_L=5','N_L=8'};
 'M_gauss_shock',    {'M_GAUSS_LS','M_GAUSS_FOU'}, {'Gaussian, LS','Gaussian, Fourier'};
 'N_sine_pressure',  {'BASE_R4','N_SINE_P'}, {'step P=1 MPa','sine P_0=5 MPa'};
 'T3_theories',      {'C_FOURIER','BASE_R4','T3_DPL_half','T3_DPL_eq','T3_GN3'}, ...
                     {'Fourier','LS','DPL \tau_T=\tau_q/2','DPL \tau_T=\tau_q','GN-III'} };

%% ---- generate one 2x2 figure per study ----------------------------------
for si = 1:size(studies,1)
    sname = studies{si,1}; cnames = studies{si,2}; labels = studies{si,3};
    D = {};  ok = true;
    for ci = 1:numel(cnames)
        f = fullfile(pdir, [cnames{ci} '.mat']);
        if ~exist(f,'file'), fprintf('SKIP %s (missing %s)\n', sname, cnames{ci}); ok=false; break; end
        D{ci} = load(f);
    end
    if ~ok, continue; end

    fig = figure('Position',[60 60 1150 800],'Color','w','Name',sname);
    cols = lines(numel(cnames));

    % (1) mid-point temperature history vs Fo
    subplot(2,2,1); hold on;
    for ci = 1:numel(cnames)
        plot(Fo(D{ci}.tv), Tst(D{ci}.hist_T), '-', 'Color',cols(ci,:), 'LineWidth',1.5);
    end
    xlabel('Fo'); ylabel('T^*'); grid on; box on; title('Mid-point temperature');
    legend(labels,'Location','best','FontSize',8);

    % (2) mid-point radial displacement history
    subplot(2,2,2); hold on;
    for ci = 1:numel(cnames)
        plot(Fo(D{ci}.tv), ust(D{ci}.hist_U), '-', 'Color',cols(ci,:), 'LineWidth',1.5);
    end
    xlabel('Fo'); ylabel('u^*'); grid on; box on; title('Mid-point radial displacement');

    % (3) final radial temperature profile vs xi
    subplot(2,2,3); hold on;
    for ci = 1:numel(cnames)
        Ri_c = D{ci}.r_nodes{1}(1);  Ro_c = D{ci}.r_nodes{end}(end);
        xi = (D{ci}.r_all - Ri_c)/(Ro_c - Ri_c);
        plot(xi, Tst(D{ci}.T_all), '.-', 'Color',cols(ci,:), 'LineWidth',1.2);
    end
    xlabel('\xi'); ylabel('T^*'); grid on; box on; title('T(\xi) at final time, z = L/2');

    % (4) final hoop-stress profile
    subplot(2,2,4); hold on;
    for ci = 1:numel(cnames)
        Ri_c = D{ci}.r_nodes{1}(1);  Ro_c = D{ci}.r_nodes{end}(end);
        xi = (D{ci}.r_all - Ri_c)/(Ro_c - Ri_c);
        plot(xi, sst(D{ci}.S_tt), '.-', 'Color',cols(ci,:), 'LineWidth',1.2);
    end
    xlabel('\xi'); ylabel('\sigma^*_{\theta\theta}'); grid on; box on;
    title('Hoop stress at final time, z = L/2');

    saveas(fig, fullfile(fdir, [sname '.fig']));
    print(fig, fullfile(fdir, [sname '.png']), '-dpng', '-r300');
    fprintf('figure written: %s\n', sname);
    close(fig);
end
fprintf('\nAll study figures in %s\n', fdir);
