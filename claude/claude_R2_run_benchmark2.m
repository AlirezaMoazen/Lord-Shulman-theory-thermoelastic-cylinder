%% ========================================================================
%  claude_R2_run_benchmark2.m — VALIDATION BENCHMARK 2 (THERMAL) + METHOD TABLE
%  ------------------------------------------------------------------------
%  Part A: transient heat conduction in a homogeneous hollow cylinder,
%          inner surface temperature ramp  theta(Ri,t)=th0*(1-exp(-t/t0)),
%          outer surface convection, insulated ends (z-independent field).
%          Compared against the EXACT analytical solution (Bessel-series
%          eigenfunction expansion + Duhamel's theorem).
%
%  Part B: method-versus-method comparison (like the Newmark-vs-NURBS
%          tables in Heydarpour & Malekzadeh / Rezaei's thesis):
%          Newmark (claude_R2) vs MATLAB ode15s on the SAME spatial
%          system (constraints eliminated by static condensation),
%          with accuracy and CPU time reported.
%
%  Uses the claude_R2 solver via cfg — the solver file is not modified.
%  ========================================================================
clearvars; clc; close all;

%% ------------------------- Part A: run the solver -----------------------
k_th = 50;  rho_th = 8000;  c_th = 500;      % homogeneous material
kappa = k_th/(rho_th*c_th);                  % 1.25e-5 m^2/s
Ri = 0.08;  Ro = 0.1;  hconv = 2000;         % Biot = h*(Ro-Ri)/k = 0.8
th0 = 200;  t0r = 5;                         % ramp: 300 K -> 500 K, tau=5 s

cfg = struct( ...
    'material_mode','FG_powerlaw', ...
    'FG_E_i',200e9, 'FG_nE',0, 'FG_rho_i',rho_th, 'FG_nrho',0, ...
    'FG_nu',0.3, 'FG_k',k_th, 'FG_c',c_th, 'FG_alpha',0, ...
    'LS_enabled',false, 'coupling_on',false, 'porosity_on',false, ...
    'BC_z','S', ...
    'NL',5, 'N_r',7, 'N_z',9, ...
    'R_i',Ri, 'R_o',Ro, 'L',1.0, ...
    'P_i',0, ...
    'T_in_val',300+th0, 't0_ramp',t0r, 'h_c',hconv, 'T_inf',300, ...
    'total_time',40, 'dt',0.1, ...
    'store_full_history',true, ...
    'out_name','Results_R2_bench2.mat');

claude_R2;    % solver runs; workspace keeps all matrices and X_hist

% NOTE: claude_R2 begins with clearvars, so the driver-local constants above
% are gone now — re-derive them from the solver workspace (same values):
k_th = k_L(1);  rho_th = rho_L(1);  c_th = c_L(1);
kappa = k_th/(rho_th*c_th);
Ri = R_i;  Ro = R_o;  hconv = h_c;
th0 = T_in_val - T_ref;  t0r = t0_ramp;

%% --------------------- Part A: exact analytic solution ------------------
% Steady unit-inner-temperature profile psi(r) = a + b*ln r :
b_c = -hconv/(k_th/Ro + hconv*log(Ro/Ri));
a_c = 1 - b_c*log(Ri);
psi = @(r) a_c + b_c*log(r);

% Radial eigenfunctions R_n(r) = J0(l r)Y0(l Ri) - Y0(l r)J0(l Ri),
% eigencondition (Robin at Ro):
geig = @(l) -k_th*l.*(besselj(1,l*Ro).*bessely(0,l*Ri) - bessely(1,l*Ro).*besselj(0,l*Ri)) ...
          + hconv*(besselj(0,l*Ro).*bessely(0,l*Ri) - bessely(0,l*Ro).*besselj(0,l*Ri));
Rfun = @(l,r) besselj(0,l*r).*bessely(0,l*Ri) - bessely(0,l*r).*besselj(0,l*Ri);

% find first Nmodes roots by scan + fzero
Nmodes = 60;
lam = zeros(Nmodes,1);  nfound = 0;
lgrid = linspace(1, 40000, 400000);
gv = geig(lgrid);
for i = 1:numel(lgrid)-1
    if nfound >= Nmodes, break; end
    if gv(i)*gv(i+1) < 0
        nfound = nfound + 1;
        lam(nfound) = fzero(geig, [lgrid(i), lgrid(i+1)]);
    end
end
lam = lam(1:nfound);
fprintf('Analytic series: %d eigenvalues found (lambda_1=%.3f, lambda_end=%.1f)\n', ...
        nfound, lam(1), lam(end));

% expansion coefficients c_n of psi(r) in the R_n basis (weight r)
cn = zeros(nfound,1);
for n = 1:nfound
    num = integral(@(r) psi(r).*Rfun(lam(n),r).*r, Ri, Ro, 'AbsTol',1e-12,'RelTol',1e-10);
    den = integral(@(r) Rfun(lam(n),r).^2.*r,      Ri, Ro, 'AbsTol',1e-12,'RelTol',1e-10);
    cn(n) = num/den;
end

% exact field: theta(r,t) = f(t) psi(r) - sum c_n R_n(r) I_n(t)
% with f(t)=th0(1-e^{-t/t0}), I_n = th0*b*(e^{-b t}-e^{-a_n t})/(a_n-b)
bD = 1/t0r;
theta_exact = @(r,t) th0*(1-exp(-t/t0r)).*psi(r) - ...
    sum( (cn .* Rfun(lam, r)) .* (th0*bD*(exp(-bD*t)-exp(-lam.^2*kappa*t))./(lam.^2*kappa - bD)), 1);

%% ------------------- Part A: comparison at radial nodes -----------------
iz0 = round(N_z/2);
r_pts = [];  rowsT = [];
for e = 1:NL
    for ir = 1:N_r
        r_pts(end+1)  = r_nodes{e}(ir);      %#ok<SAGROW>
        rowsT(end+1)  = idx_Th(e,ir,iz0);    %#ok<SAGROW>
    end
end

t_check = [2 5 10 20 40];
fprintf('\n===== BENCHMARK 2: transient conduction vs EXACT solution =====\n');
fprintf('%-8s %-14s %-14s %-10s\n','t (s)','max|err| (K)','max|theta| (K)','rel err');
err_tab = zeros(numel(t_check),3);
for kk = 1:numel(t_check)
    tt = t_check(kk);
    n_t = round(tt/dt) + 1;
    th_num = X_hist(rowsT, n_t);
    th_ex  = arrayfun(@(r) theta_exact(r, tt), r_pts).';
    % exclude the inner Dirichlet node itself (series converges non-uniformly there)
    mask = r_pts.' > Ri + 1e-12;
    emax = max(abs(th_num(mask) - th_ex(mask)));
    tmax = max(abs(th_ex(mask)));
    err_tab(kk,:) = [tt, emax, emax/tmax];
    fprintf('%-8.1f %-14.4f %-14.2f %-10.2e\n', tt, emax, tmax, emax/tmax);
end

% profile figure at three times
outdir = 'Validation';
if ~exist(outdir,'dir'), mkdir(outdir); end
figA = figure('Position',[100 100 750 520],'Color','w'); hold on;
cols = lines(3); tsel = [2 10 40];
for kk = 1:numel(tsel)
    n_t = round(tsel(kk)/dt) + 1;
    plot(r_pts, 300 + X_hist(rowsT, n_t), 'o', 'Color', cols(kk,:), 'MarkerSize',6);
    rr = linspace(Ri, Ro, 200);
    plot(rr, 300 + arrayfun(@(r) theta_exact(r, tsel(kk)), rr), '-', 'Color', cols(kk,:), 'LineWidth',1.4);
end
xlabel('r (m)'); ylabel('T (K)'); grid on; box on;
legend('DQM+Newmark  t=2 s','Exact','t=10 s','Exact','t=40 s','Exact','Location','southwest');
title('Transient conduction: solver vs exact Bessel-series solution');
saveas(figA, fullfile(outdir,'bench2_T_profiles.fig'));
print(figA, fullfile(outdir,'bench2_T_profiles.png'), '-dpng','-r300');

%% ---------------- Part B: independent ode15s cross-check ----------------
% Static condensation of constraint rows (rows with zero M and C):
rsum = full(sum(abs(M),2) + sum(abs(C),2));
isb  = rsum < 1e-10;                 % constraint (algebraic) rows/dofs
ii   = find(~isb);  bb = find(isb);
Kii = K(ii,ii); Kib = K(ii,bb); Kbi = K(bb,ii); Kbb = K(bb,bb);
Cii = C(ii,ii); Mii = M(ii,ii);
dKbb = decomposition(Kbb);

% time-dependent constraint RHS: F_b(t) = f_ramp(t)*e_ramp (inner ramp rows)
e_ramp = zeros(numel(bb),1);
[tfb, locb] = ismember(rows_Tin, bb);
e_ramp(locb(tfb)) = rs_Tin(tfb);
Fb0 = F0(bb);                        % constant part (convection rhs = 0 here)
w_r  = dKbb \ e_ramp;                % K_bb^{-1} e_ramp
w_c  = dKbb \ Fb0;
Kib_wr = Kib*w_r;  Kib_wc = Kib*w_c;
Kred = Kii - Kib*(dKbb\Kbi);
Fi0  = F0(ii);
fr   = @(t) th0*(1-exp(-t/t0r));     % ramp function

% split interior dofs: thermal (M=0, C>0) vs mechanical (M>0)
mdia = full(diag(Mii));  cdia = full(diag(Cii));
iT = find(mdia < 1e-14);             % first-order rows (Fourier thermal)
iM = find(mdia >= 1e-14);            % second-order rows (mechanics)
CT = cdia(iT);  MM = mdia(iM);
KTT = Kred(iT,iT); KTM = Kred(iT,iM); KMT = Kred(iM,iT); KMM = Kred(iM,iM);

nT = numel(iT); nM = numel(iM);
% state y = [thetaI; xM; vM]
odefun = @(t,y) [ (Fi0(iT) + fr(t)*(-Kib_wr(iT)) - Kib_wc(iT) - KTT*y(1:nT) - KTM*y(nT+1:nT+nM)) ./ CT ; ...
                  y(nT+nM+1:end) ; ...
                  (Fi0(iM) + fr(t)*(-Kib_wr(iM)) - Kib_wc(iM) - KMT*y(1:nT) - KMM*y(nT+1:nT+nM)) ./ MM ];
Jode = [ -spdiags(1./CT,0,nT,nT)*KTT,  -spdiags(1./CT,0,nT,nT)*KTM,  sparse(nT,nM); ...
          sparse(nM,nT),                sparse(nM,nM),               speye(nM); ...
         -spdiags(1./MM,0,nM,nM)*KMT,  -spdiags(1./MM,0,nM,nM)*KMM,  sparse(nM,nM)];
opts = odeset('Jacobian',Jode,'RelTol',1e-7,'AbsTol',1e-9);

t15 = tic;
[tsol, ysol] = ode15s(odefun, tv, zeros(nT+2*nM,1), opts);
ode_cpu = toc(t15);

% map probe (mid-radius, mid-z thermal dof) into reduced numbering
probe_glob = idx_Th(ceil(NL/2), round(N_r/2), iz0);
pg_i = find(ii == probe_glob);  pg_T = find(iT == pg_i);
th_ode  = ysol(:, pg_T);
th_newm = X_hist(probe_glob, :).';
r_probe = r_nodes{ceil(NL/2)}(round(N_r/2));
th_ex_t = arrayfun(@(t) theta_exact(r_probe, max(t,1e-12)), tsol);

fprintf('\n===== METHOD COMPARISON (probe: r=%.4f m, z=L/2) =====\n', r_probe);
fprintf('%-22s %-14s %-12s\n','method','max err vs exact','CPU (s)');
fprintf('%-22s %-14.4f %-12.2f\n','Newmark (claude_R2)', max(abs(th_newm - th_ex_t)), newmark_cpu);
fprintf('%-22s %-14.4f %-12.2f\n','ode15s (reduced)',    max(abs(th_ode  - th_ex_t)), ode_cpu);
fprintf('%-22s %-14.4f\n','Newmark vs ode15s',  max(abs(th_newm - th_ode)));

figB = figure('Position',[120 120 750 520],'Color','w');
plot(tsol, 300+th_ex_t,'k-','LineWidth',1.8); hold on;
plot(tsol, 300+th_newm,'b--','LineWidth',1.4);
plot(tsol, 300+th_ode ,'r:','LineWidth',1.6);
xlabel('t (s)'); ylabel('T (K)'); grid on; box on;
legend('Exact','DQM + Newmark','DQM + ode15s','Location','southeast');
title(sprintf('Temperature history at r=%.3f m (mid-thickness)', r_probe));
saveas(figB, fullfile(outdir,'bench2_T_history.fig'));
print(figB, fullfile(outdir,'bench2_T_history.png'), '-dpng','-r300');

Tt = array2table([err_tab(:,1), err_tab(:,2), err_tab(:,3)], ...
     'VariableNames', {'t_s','max_abs_err_K','rel_err'});
writetable(Tt, fullfile(outdir,'bench2_error_table.csv'));
meth = table({'Newmark';'ode15s'}, ...
     [max(abs(th_newm-th_ex_t)); max(abs(th_ode-th_ex_t))], ...
     [newmark_cpu; ode_cpu], 'VariableNames', {'method','max_err_K','cpu_s'});
writetable(meth, fullfile(outdir,'bench2_method_table.csv'));
fprintf('\nSaved: Validation\\bench2_T_profiles / bench2_T_history (.png/.fig) + 2 CSV tables\n');
