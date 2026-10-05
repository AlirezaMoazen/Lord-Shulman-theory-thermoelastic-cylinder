%% validation_fig_bench2_R2.m (R1 crashed: LSTE_solver's clearvars removed `base`
%  before the print call, so no figure was written. R2 re-declares it after the
%  solver call. R1 kept frozen.)
%% validation_fig_bench2 — figure + table for Chapter-4 verification test 4
%  Test 4 compares the Newmark time integration against MATLAB's adaptive stiff
%  solver on the same spatial system. A figure already existed
%  (Validation/bench2_T_history.png) but it overlays the exact, Newmark and
%  ode15s temperature histories, which coincide so closely that the plot reads
%  as a single line and conveys nothing. This script redraws it as two panels:
%  the histories on the left and, on the right, the actual deviation of each
%  scheme from the exact solution on a log axis, which is where the 0.0032 K vs
%  0.00026 K difference between the two integrators becomes visible.
%
%  Configuration is exactly that of benchmark 2 (homogeneous cylinder, inner
%  temperature ramp, outer convection, exact Bessel-series reference), and the
%  ode15s cross-check reproduces the static condensation + first-order recast of
%  LSTE_solver_R2_run_benchmark2.m, which does not save its ode15s solution.
%  Writes figures_validation/verif_test4_integrator_R1{,_bw}.png/.fig and
%  thesis_chapter/verif_test4_integrator_R1.csv.
clearvars; clc; close all;
base = 'c:/Users/InfosaicUser/Desktop/MSc/Lord-Shulman-theory-thermoelastic-cylinder/claude';

k_th0 = 50; rho_th0 = 8000; c_th0 = 500;
Ri0 = 0.08; Ro0 = 0.1; hconv0 = 2000; th00 = 200; t0r0 = 5;
cfg = struct('material_mode','FG_powerlaw', ...
    'FG_E_i',200e9,'FG_nE',0,'FG_rho_i',rho_th0,'FG_nrho',0, ...
    'FG_nu',0.3,'FG_k',k_th0,'FG_c',c_th0,'FG_alpha',0, ...
    'LS_enabled',false,'coupling_on',false,'porosity_on',false, ...
    'BC_z','S','NL',5,'N_r',7,'N_z',9, ...
    'R_i',Ri0,'R_o',Ro0,'L',1.0,'P_i',0, ...
    'T_in_val',300+th00,'t0_ramp',t0r0,'h_c',hconv0,'T_inf',300, ...
    'total_time',40,'dt',0.1,'store_full_history',true, ...
    'out_name','Results_bench2_fig_R1.mat');
LSTE_solver_R11;   % clears the workspace except cfg; leaves matrices + X_hist
base = 'c:/Users/InfosaicUser/Desktop/MSc/Lord-Shulman-theory-thermoelastic-cylinder/claude';  % re-declared: the solver's clearvars removed it

% re-derive the driver constants from the solver workspace
k_th = k_L(1); rho_th = rho_L(1); c_th = c_L(1);
kappa = k_th/(rho_th*c_th);
Ri = R_i; Ro = R_o; hconv = h_c; th0 = T_in_val - T_ref; t0r = t0_ramp;

%% exact Bessel-series solution (as in benchmark 2)
b_c = -hconv/(k_th/Ro + hconv*log(Ro/Ri));  a_c = 1 - b_c*log(Ri);
psi  = @(r) a_c + b_c*log(r);
geig = @(l) -k_th*l.*(besselj(1,l*Ro).*bessely(0,l*Ri) - bessely(1,l*Ro).*besselj(0,l*Ri)) ...
          + hconv*(besselj(0,l*Ro).*bessely(0,l*Ri) - bessely(0,l*Ro).*besselj(0,l*Ri));
Rfun = @(l,r) besselj(0,l*r).*bessely(0,l*Ri) - bessely(0,l*r).*besselj(0,l*Ri);
lam = zeros(60,1); nf = 0; lg = linspace(1,40000,400000); gv = geig(lg);
for i = 1:numel(lg)-1
    if nf >= 60, break; end
    if gv(i)*gv(i+1) < 0, nf = nf+1; lam(nf) = fzero(geig,[lg(i),lg(i+1)]); end
end
lam = lam(1:nf); cn = zeros(nf,1);
for q = 1:nf
    num = integral(@(r) psi(r).*Rfun(lam(q),r).*r, Ri, Ro,'AbsTol',1e-12,'RelTol',1e-10);
    den = integral(@(r) Rfun(lam(q),r).^2.*r,      Ri, Ro,'AbsTol',1e-12,'RelTol',1e-10);
    cn(q) = num/den;
end
bD = 1/t0r;
theta_exact = @(r,t) th0*(1-exp(-t/t0r)).*psi(r) - ...
    sum((cn.*Rfun(lam,r)).*(th0*bD*(exp(-bD*t)-exp(-lam.^2*kappa*t))./(lam.^2*kappa - bD)),1);

%% ode15s on the condensed first-order system
rsum = full(sum(abs(M),2) + sum(abs(C),2));
isb = rsum < 1e-10; ii = find(~isb); bb = find(isb);
Kii=K(ii,ii); Kib=K(ii,bb); Kbi=K(bb,ii); Kbb=K(bb,bb);
Cii=C(ii,ii); Mii=M(ii,ii); dKbb=decomposition(Kbb);
e_ramp=zeros(numel(bb),1); [tf2,loc2]=ismember(rows_Tin,bb); e_ramp(loc2(tf2))=rs_Tin(tf2);
w_r=dKbb\e_ramp; w_c=dKbb\F0(bb); Kib_wr=Kib*w_r; Kib_wc=Kib*w_c;
Kred=Kii-Kib*(dKbb\Kbi); Fi0=F0(ii); fr=@(t) th0*(1-exp(-t/t0r));
mdia=full(diag(Mii)); cdia=full(diag(Cii));
iT=find(mdia<1e-14); iM=find(mdia>=1e-14); CT=cdia(iT); MM=mdia(iM);
KTT=Kred(iT,iT); KTM=Kred(iT,iM); KMT=Kred(iM,iT); KMM=Kred(iM,iM);
nT=numel(iT); nM=numel(iM);
odef=@(t,y)[ (Fi0(iT)+fr(t)*(-Kib_wr(iT))-Kib_wc(iT)-KTT*y(1:nT)-KTM*y(nT+1:nT+nM))./CT ; ...
             y(nT+nM+1:end) ; ...
             (Fi0(iM)+fr(t)*(-Kib_wr(iM))-Kib_wc(iM)-KMT*y(1:nT)-KMM*y(nT+1:nT+nM))./MM ];
J=[ -spdiags(1./CT,0,nT,nT)*KTT, -spdiags(1./CT,0,nT,nT)*KTM, sparse(nT,nM); ...
     sparse(nM,nT), sparse(nM,nM), speye(nM); ...
    -spdiags(1./MM,0,nM,nM)*KMT, -spdiags(1./MM,0,nM,nM)*KMM, sparse(nM,nM)];
t15=tic;
[tsol,ysol]=ode15s(odef, tv, zeros(nT+2*nM,1), odeset('Jacobian',J,'RelTol',1e-7,'AbsTol',1e-9));
ode_cpu=toc(t15);

probe_glob = idx_Th(ceil(NL/2), round(N_r/2), iz0);
pg_i=find(ii==probe_glob); pg_T=find(iT==pg_i);
th_ode  = ysol(:,pg_T);
th_newm = X_hist(probe_glob,:).';
r_probe = r_nodes{ceil(NL/2)}(round(N_r/2));
th_ex   = arrayfun(@(t) theta_exact(r_probe, max(t,1e-12)), tsol);

e_newm = abs(th_newm - th_ex);  e_ode = abs(th_ode - th_ex);
fprintf('TEST 4  probe r=%.4f  Newmark max err=%.5f K  ode15s max err=%.5f K  |N-o| max=%.5f K  ode cpu=%.1f s\n', ...
        r_probe, max(e_newm), max(e_ode), max(abs(th_newm-th_ode)), ode_cpu);

FNT='Times New Roman'; FSZ=14;
for mode=1:2
    bw=(mode==2);
    if bw, c1=[0 0 0]; c2=[0.45 0.45 0.45]; c3=[0.70 0.70 0.70]; sfx='_bw';
    else,  c1=[0.20 0.20 0.20]; c2=[0 0.447 0.741]; c3=[0.850 0.325 0.098]; sfx=''; end
    f=figure('Position',[60 60 1150 460],'Color','w');
    tiledlayout(f,1,2,'TileSpacing','compact','Padding','compact');

    nexttile; hold on;
    plot(tsol, 300+th_ex,  '-','Color',c1,'LineWidth',2.0);
    plot(tsol(1:25:end), 300+th_newm(1:25:end),'o','Color',c2,'LineWidth',1.2,'MarkerSize',6,'MarkerFaceColor','w');
    plot(tsol(1:25:end), 300+th_ode(1:25:end), 's','Color',c3,'LineWidth',1.2,'MarkerSize',6,'MarkerFaceColor','w');
    grid on; box on; set(gca,'FontName',FNT,'FontSize',FSZ);
    xlabel('t  (s)','FontName',FNT); ylabel('T  (K)','FontName',FNT);
    legend({'exact','DQM + Newmark','DQM + ode15s'},'Location','southeast','FontName',FNT,'FontSize',FSZ-1);

    nexttile;
    semilogy(tsol, max(e_newm,realmin),'-','Color',c2,'LineWidth',1.6); hold on;
    semilogy(tsol, max(e_ode,realmin), '-','Color',c3,'LineWidth',1.6);
    grid on; box on; set(gca,'FontName',FNT,'FontSize',FSZ);
    xlabel('t  (s)','FontName',FNT); ylabel('|T - T_{exact}|  (K)','FontName',FNT);
    legend({'Newmark','ode15s'},'Location','northeast','FontName',FNT,'FontSize',FSZ-1);

    print(f, fullfile(base,'figures_validation',['verif_test4_integrator_R1' sfx '.png']),'-dpng','-r130');
    savefig(f, fullfile(base,'figures_validation',['verif_test4_integrator_R1' sfx '.fig']));
    close(f);
end

fid=fopen(fullfile(base,'thesis_chapter','verif_test4_integrator_R1.csv'),'w');
fprintf(fid,'method,max error vs exact (K),CPU (s)\n');
fprintf(fid,'DQM + Newmark,%.6f,%.2f\n', max(e_newm), newmark_cpu);
fprintf(fid,'DQM + ode15s,%.6f,%.2f\n',  max(e_ode),  ode_cpu);
fprintf(fid,'Newmark vs ode15s,%.6f,-\n', max(abs(th_newm-th_ode)));
fclose(fid);
disp('VALIDATION_FIG_BENCH2_R1 DONE');
