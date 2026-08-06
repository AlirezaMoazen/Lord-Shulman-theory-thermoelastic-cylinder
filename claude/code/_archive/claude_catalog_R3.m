%% claude_catalog_R3.m — QUANTITY CATALOG for choosing chapter-4 figures (B&W)
%  REVISION 3 of the catalog (R1 = frozen 9-panel; R2 = two-part + smoothed).
%  R3 ADDS the other strain components to the final-time profiles (Part 2):
%    Part 1  <study>_hist.png : T*(Fo)  u*(Fo)  w*(Fo)      (unchanged from R2)
%    Part 2  <study>_prof.png : T*(xi)  eps_rr eps_thth eps_zz
%                              u*(xi)  sig*_rr sig*_thth sig*_zz   (2x4)
%  eps_rr = du/dr and eps_thth = u/r are at EXACT final time (from saved U_all);
%  eps_zz = dw/dz is taken from the LAST saved snapshot (~final) because the
%  final full w-field was not stored. For eps_zz at the exact final time a
%  full-history re-run is needed. Curves smoothed by makima densification.
%  New revision file; does not modify any solver or earlier catalog revision.

clearvars; clc; close all;
pdir = 'param_studies';
cdir = 'figures_catalog';
if ~exist(cdir,'dir'), mkdir(cdir); end

%% ---- reference (BASE UD) material -> dimensionless maps (same as R4 figs) --
E_GPL=1.01e12; rho_GPL=1062.5; c_GPL=644; alpha_GPL=5e-6; k_GPL=3000; nu_GPL=0.186;
E_m=3.0e9; nu_m=0.34; rho_m=1200; c_m=1110; alpha_m=60e-6; k_m=0.246;
a_GPL=2.5e-6; b_GPL=1.5e-6; t_GPL=1.5e-9; gamma_conn=0.5; Wg=0.04; em3=0.8980;
Vg = Wg/(Wg+(rho_GPL/rho_m)*(1-Wg));
xiL=2*a_GPL/t_GPL; xiT=2*b_GPL/t_GPL;
etL=(E_GPL/E_m-1)/(E_GPL/E_m+xiL); etT=(E_GPL/E_m-1)/(E_GPL/E_m+xiT);
Es = (3/8*(1+xiL*etL*Vg)/(1-etL*Vg) + 5/8*(1+xiT*etT*Vg)/(1-etT*Vg))*E_m;
nus= Vg*nu_GPL+(1-Vg)*nu_m;  rhs=Vg*rho_GPL+(1-Vg)*rho_m;
cs = Vg*c_GPL+(1-Vg)*c_m;    als=Vg*alpha_GPL+(1-Vg)*alpha_m;
p  = a_GPL/t_GPL;  Hp = log(p+sqrt(p^2-1))*p/sqrt((p^2-1)^3)-1/(p^2-1);
ks = ((2/3)*(Vg-1/p)^gamma_conn/(Hp+1/(k_GPL/k_m-1)))*k_m + k_m;
Pm=em3; Pf=em3^2;
E_ref=Es*Pf; nu_ref=nus; rho_ref=rhs*Pm; c_ref=cs*Pf; k_ref=ks*Pf; al_ref=als;
alpha_diff = k_ref/(rho_ref*c_ref);
lam_ = nu_ref*E_ref/((1+nu_ref)*(1-2*nu_ref)); mu_ = E_ref/(2*(1+nu_ref));
beta_ref = al_ref*(3*lam_+2*mu_);
R_o=0.2; dT=300; T_inf=300; hthick=0.1;
Fo  = @(t) alpha_diff*t/R_o^2;
Tst = @(T) (T - T_inf)/dT;
ust = @(u) u*(lam_+2*mu_)/(beta_ref*dT*hthick);
sst = @(s) s/(beta_ref*dT);

%% ---- styles (B&W, up to 5 curves) --------------------------------------
STY.co = {[0 0 0],[0 0 0],[0.45 0.45 0.45],[0.45 0.45 0.45],[0.68 0.68 0.68]};
STY.ls = {'-','--',':','-.','-'};  STY.mk = {'o','s','^','d','v'};
STY.lw = [1.4 1.2 1.2 1.2 1.4];  FNT='Times New Roman'; FSZ=9;

%% ---- studies (same mapping as claude_param_figures_R4) ------------------
studies = { ...
 'A_GPL_patterns',   {'BASE_R4','A_GPL_O','A_GPL_X','A_GPL_V','A_GPL_A'}, {'UD','O','X','V','A'};
 'B_porosity_patterns',{'BASE_R4','B_POR_O','B_POR_X','B_POR_V','B_POR_A'}, {'UD','O','X','V','A'};
 'C_relaxation',     {'C_FOURIER','C_TAU_01','BASE_R4','C_TAU_06'}, {'Fourier','\tau^*=0.15','\tau^*=0.44','\tau^*=0.87'};
 'D_GPL_fraction',   {'D_W_000','D_W_001','BASE_R4','D_W_008'}, {'W=0','W=1%','W=4%','W=8%'};
 'D2_GPL_fill',      {'D_W_020','D_W_022','D_W_026','D_W_035','BASE_R4'}, {'W=2%','W=2.2%','W=2.6%','W=3.5%','W=4%'};
 'E_porosity_level', {'E_EM3_9675','BASE_R4','E_EM3_7776'}, {'e_{m3}=0.9675','e_{m3}=0.8980','e_{m3}=0.7776'};
 'F_end_BC',         {'BASE_R4','Q_MIX_SC','F_BC_C'}, {'S-S','S-C','C-C'};
 'G_pressure',       {'G_NOPRESS','G_P010','G_P050','G_P100'}, {'P_i=0','10 MPa','50 MPa','100 MPa'};
 'H_interaction',    {'BASE_R4','H_XGPL_OPOR','H_XGPL_APOR','H_VGPL_OPOR','H_VGPL_APOR'}, {'UD/UD','X+O','X+A','V+O','V+A'};
 'I_coupling',       {'BASE_R4','I_UNCOUPLED'}, {'coupled','uncoupled'};
 'J_convection',     {'BASE_R4','J_HC_100','J_HC_1000'}, {'h_c=10','h_c=100','h_c=1000'};
 'K_thickness',      {'K_RO_015','BASE_R4','K_RO_030'}, {'R_o=0.15','0.20','0.30'};
 'L_layers',         {'L_NL_3','BASE_R4','L_NL_9','L_NL_15'}, {'N_L=3','5','9','15'};
 'M_gauss_shock',    {'M_GAUSS_LS','M_GAUSS_FOU'}, {'LS','Fourier'};
 'N_sine_pressure',  {'BASE_R4','N_SINE_P'}, {'step 1 MPa','sine 5 MPa'};
 'O_aspect_length',  {'R_ASP_LEN_L','BASE_R4','R_ASP_LEN_H'}, {'2a/2b=1.0','1.67','2.67'};
 'P_aspect_thick',   {'R_ASP_THK_H','BASE_R4','R_ASP_THK_L'}, {'2b/t=500','1000','2000'};
 'Q_infinite_len',   {'BASE_R4','P_INF_L10','P_INF_L20','P_INF_L40'}, {'L=0.5','1','2','4'};
 'T3_theories',      {'C_FOURIER','BASE_R4','T3_DPL_half','T3_DPL_eq','T3_GN3'}, {'Fourier','LS','DPL 1/2','DPL eq','GN-III'} };

made = {};
for si = 1:size(studies,1)
    sname = studies{si,1}; cnames = studies{si,2}; labels = studies{si,3};
    D = {}; ok = true;
    for ci = 1:numel(cnames)
        f = fullfile(pdir,[cnames{ci} '.mat']);
        if ~exist(f,'file'), fprintf('SKIP %s (missing %s)\n', sname, cnames{ci}); ok=false; break; end
        D{ci} = load(f);
    end
    if ~ok, continue; end
    xiOf = @(d) (d.r_all - d.r_nodes{1}(1)) / (d.r_nodes{end}(end) - d.r_nodes{1}(1));

    % ===== PART 1: mid-point time histories (1x3) =====  (unchanged from R2)
    f1 = figure('Position',[40 60 1360 430],'Color','w','Name',[sname '_hist']);
    subplot(1,3,1); hold on;
    for ci=1:numel(cnames), curve(Fo(D{ci}.tv), Tst(D{ci}.hist_T), ci, STY); end
    fin(gca,FNT,FSZ,'Fo','T^*','(1) T^* history'); legend(labels,'Location','best','FontSize',8,'FontName',FNT);
    subplot(1,3,2); hold on;
    for ci=1:numel(cnames), curve(Fo(D{ci}.tv), ust(D{ci}.hist_U), ci, STY); end
    fin(gca,FNT,FSZ,'Fo','u^*','(2) u^* history (radial)');
    subplot(1,3,3); hold on;
    for ci=1:numel(cnames), curve(Fo(D{ci}.tv), ust(D{ci}.hist_W), ci, STY); end
    fin(gca,FNT,FSZ,'Fo','w^*','(3) w^* history (axial)');
    print(f1, fullfile(cdir,[sname '_hist.png']), '-dpng','-r130');
    savefig(f1, fullfile(cdir,[sname '_hist.fig'])); close(f1);

    % ===== PART 2: final radial profiles (2x4) — now with all 3 strains =====
    f2 = figure('Position',[20 40 1660 760],'Color','w','Name',[sname '_prof']);
    % row 1: temperature + the three strains
    subplot(2,4,1); hold on;
    for ci=1:numel(cnames), curve(xiOf(D{ci}), Tst(D{ci}.T_all), ci, STY); end
    fin(gca,FNT,FSZ,'\xi','T^*','(1) T^*(\xi)'); legend(labels,'Location','best','FontSize',8,'FontName',FNT);
    subplot(2,4,2); hold on;
    for ci=1:numel(cnames), [err,~,~]=strainprof(D{ci}); curve(xiOf(D{ci}), err, ci, STY); end
    fin(gca,FNT,FSZ,'\xi','\epsilon_{rr}','(2) \epsilon_{rr}(\xi) radial');
    subplot(2,4,3); hold on;
    for ci=1:numel(cnames), [~,ett,~]=strainprof(D{ci}); curve(xiOf(D{ci}), ett, ci, STY); end
    fin(gca,FNT,FSZ,'\xi','\epsilon_{\theta\theta}','(3) \epsilon_{\theta\theta}(\xi) hoop');
    subplot(2,4,4); hold on;
    for ci=1:numel(cnames), [~,~,ezz]=strainprof(D{ci}); curve(xiOf(D{ci}), ezz, ci, STY); end
    fin(gca,FNT,FSZ,'\xi','\epsilon_{zz}','(4) \epsilon_{zz}(\xi) axial [last snapshot]');
    % row 2: displacement + the three stresses
    subplot(2,4,5); hold on;
    for ci=1:numel(cnames), curve(xiOf(D{ci}), ust(D{ci}.U_all), ci, STY); end
    fin(gca,FNT,FSZ,'\xi','u^*','(5) u^*(\xi)');
    subplot(2,4,6); hold on;
    for ci=1:numel(cnames), curve(xiOf(D{ci}), sst(D{ci}.S_rr), ci, STY); end
    fin(gca,FNT,FSZ,'\xi','\sigma^*_{rr}','(6) \sigma^*_{rr}(\xi)');
    subplot(2,4,7); hold on;
    for ci=1:numel(cnames), curve(xiOf(D{ci}), sst(D{ci}.S_tt), ci, STY); end
    fin(gca,FNT,FSZ,'\xi','\sigma^*_{\theta\theta}','(7) \sigma^*_{\theta\theta}(\xi)');
    subplot(2,4,8); hold on;
    for ci=1:numel(cnames), curve(xiOf(D{ci}), sst(D{ci}.S_zz), ci, STY); end
    fin(gca,FNT,FSZ,'\xi','\sigma^*_{zz}','(8) \sigma^*_{zz}(\xi)');
    print(f2, fullfile(cdir,[sname '_prof.png']), '-dpng','-r130');
    savefig(f2, fullfile(cdir,[sname '_prof.fig'])); close(f2);

    made{end+1} = sname; %#ok<SAGROW>
    fprintf('catalog R3: %s (hist + prof w/ strains)\n', sname);
end
fprintf('\nDONE: %d studies x 2 parts -> %s\n', numel(made), cdir);

%% ---- local helpers ----
function [err,ett,ezz] = strainprof(d)
    % eps_rr = du/dr and eps_theta = u/r at EXACT final time (from U_all);
    % eps_zz = dw/dz from the LAST snapshot (~final). All at mid-length z=L/2.
    NL=d.NL; Nr=d.N_r; Nz=d.N_z;
    ett = d.U_all(:) ./ d.r_all(:);
    err = zeros(numel(d.U_all),1);
    for e=1:NL
        Ar = dqA(d.r_nodes{e});
        idx = (e-1)*Nr + (1:Nr);
        err(idx) = Ar * d.U_all(idx).';
    end
    ezz = nan(numel(d.U_all),1);
    try
        xs = d.snaps{end}; Az = dqA(d.z_nodes); iz0 = round(Nz/2);
        Nn = NL*Nr*Nz;
        for e=1:NL
            for ir=1:Nr
                base = 2*Nn + (e-1)*Nr*Nz + (ir-1)*Nz;
                wcol = xs(base+(1:Nz));
                ezz((e-1)*Nr+ir) = Az(iz0,:) * wcol(:);
            end
        end
    catch
        % snapshot missing -> leave eps_zz as NaN (panel just skips it)
    end
end
function A = dqA(x)                    % first-derivative DQ weights (as in solver)
    x=x(:); N=numel(x); A=zeros(N);
    for i=1:N, for j=1:N
        if i~=j
            num=1; den=1;
            for k=1:N, if k~=i && k~=j, num=num*(x(i)-x(k)); den=den*(x(j)-x(k)); end, end
            A(i,j)=num/(den*(x(j)-x(i)));
        end
    end, end
    for i=1:N, A(i,i)=-sum(A(i,:)); end
end
function curve(x,y,ci,STY)
    k = mod(ci-1,5)+1; x=x(:); y=y(:);
    if all(isnan(y)), return; end
    xm=x; for i=2:numel(xm), if xm(i)<=xm(i-1), xm(i)=xm(i-1)+1e-9; end, end
    nP=max(300,numel(x)); xf=linspace(xm(1),xm(end),nP); yf=interp1(xm,y,xf,'makima');
    mi=unique(round(linspace(1,nP,8)));
    plot(xf,yf,'Color',STY.co{k},'LineStyle',STY.ls{k},'LineWidth',STY.lw(k),...
        'Marker',STY.mk{k},'MarkerIndices',mi,'MarkerSize',4.5,'MarkerFaceColor','w');
end
function fin(ax,FNT,FSZ,xl,yl,tl) %#ok<INUSD>
    grid(ax,'on'); box(ax,'on'); set(ax,'FontName',FNT,'FontSize',FSZ);
    xlabel(ax,xl,'FontName',FNT); ylabel(ax,yl,'FontName',FNT);
end
