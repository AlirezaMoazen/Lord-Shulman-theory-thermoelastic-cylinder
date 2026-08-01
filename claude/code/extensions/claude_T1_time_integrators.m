%% ========================================================================
%  claude_T1_time_integrators.m — TIME-INTEGRATION METHOD COMPARISON (T1)
%  ------------------------------------------------------------------------
%  Compares SIX time-integration methods on the SAME spatial system, against
%  the exact Bessel-series solution of transient conduction (benchmark-2
%  configuration: homogeneous cylinder, inner ramp, outer convection):
%    1. Newmark (gamma=1/2, beta=1/4)   [the thesis method]
%    2. Wilson-theta (theta=1.4)
%    3. Houbolt (3-step backward; Newmark startup)
%    4. HHT-alpha (alpha=-0.1)
%    5. ode15s on the condensed first-order system  (adaptive, independent)
%    6. Laplace transform + Durbin numerical inversion
%  Reports max error vs exact + CPU seconds. This mirrors the method-
%  comparison tables of the reference papers (Newmark vs NURBS vs Laplace).
%  ========================================================================
clearvars; clc; close all;

%% ---- assemble the system via the solver (benchmark-2 configuration) ----
k_th = 50;  rho_th = 8000;  c_th = 500;
Ri = 0.08;  Ro = 0.1;  hconv = 2000;
th0 = 200;  t0r = 5;
cfg = struct('material_mode','FG_powerlaw', ...
    'FG_E_i',200e9,'FG_nE',0,'FG_rho_i',rho_th,'FG_nrho',0, ...
    'FG_nu',0.3,'FG_k',k_th,'FG_c',c_th,'FG_alpha',0, ...
    'theory','FOURIER','coupling_on',false,'porosity_on',false, ...
    'BC_z','S','NL',5,'N_r',7,'N_z',9, ...
    'R_i',Ri,'R_o',Ro,'L',1.0,'P_i',0, ...
    'T_in_val',300+th0,'t0_ramp',t0r,'h_c',hconv,'T_inf',300, ...
    'total_time',40,'dt',0.1,'store_full_history',true, ...
    'out_name','param_studies\T1_newmark.mat');
claude_R5;    % Newmark run; workspace keeps K,M,C,F0,rows_*,rs_*,a0..a7 etc.

k_th=k_L(1); rho_th=rho_L(1); c_th=c_L(1); kappa=k_th/(rho_th*c_th);
Ri=R_i; Ro=R_o; hconv=h_c; th0=T_in_val-T_ref; t0r=t0_ramp;
newmark_err_ref = NaN; %#ok<NASGU>

%% ---- exact solution (Bessel series + Duhamel), as in benchmark 2 --------
b_c = -hconv/(k_th/Ro + hconv*log(Ro/Ri));  a_c = 1 - b_c*log(Ri);
psi  = @(r) a_c + b_c*log(r);
geig = @(l) -k_th*l.*(besselj(1,l*Ro).*bessely(0,l*Ri) - bessely(1,l*Ro).*besselj(0,l*Ri)) ...
          + hconv*(besselj(0,l*Ro).*bessely(0,l*Ri) - bessely(0,l*Ro).*besselj(0,l*Ri));
Rfun = @(l,r) besselj(0,l*r).*bessely(0,l*Ri) - bessely(0,l*r).*besselj(0,l*Ri);
lam = zeros(60,1); nfound=0; lg=linspace(1,40000,400000); gv=geig(lg);
for i=1:numel(lg)-1
    if nfound>=60, break; end
    if gv(i)*gv(i+1)<0, nfound=nfound+1; lam(nfound)=fzero(geig,[lg(i),lg(i+1)]); end
end
lam = lam(1:nfound);
cn = zeros(nfound,1);
for n = 1:nfound
    num = integral(@(r) psi(r).*Rfun(lam(n),r).*r, Ri, Ro,'AbsTol',1e-12,'RelTol',1e-10);
    den = integral(@(r) Rfun(lam(n),r).^2.*r,      Ri, Ro,'AbsTol',1e-12,'RelTol',1e-10);
    cn(n) = num/den;
end
bD = 1/t0r;
theta_exact = @(r,t) th0*(1-exp(-t/t0r)).*psi(r) - ...
    sum((cn .* Rfun(lam, r)) .* (th0*bD*(exp(-bD*t)-exp(-lam.^2*kappa*t))./(lam.^2*kappa - bD)), 1);

probe = idx_Th(ceil(NL/2), round(N_r/2), round(N_z/2));
r_probe = r_nodes{ceil(NL/2)}(round(N_r/2));
th_ex = arrayfun(@(t) theta_exact(r_probe, max(t,1e-12)), tv);

res = {};   % {name, maxerr, cpu}
res(end+1,:) = {'Newmark (g=1/2,b=1/4)', max(abs(X_hist(probe,:).' - th_ex)), newmark_cpu};

% RHS builder (row-scaled), shared by the step methods
Fof = @(t) local_F(t, F0, rows_Tin, rs_Tin, th0, t0r);

%% ---- 2. Wilson-theta (theta = 1.4) --------------------------------------
tho = 1.4;  x=zeros(Ndof,1); xd=x; xdd=x;
b0 = 6/(tho*dt)^2; b1 = 3/(tho*dt); b2 = 2*b1; b3 = tho*dt/2;
KW = K + b0*M + b1*C;  [Lw,Uw,Pw,Qw] = lu(KW);
tW = tic;  errW = 0;
for n = 1:Nt
    t  = n*dt;  tth = (n-1)*dt + tho*dt;
    Fth = Fof((n-1)*dt) + tho*(Fof(t) - Fof((n-1)*dt));   %#ok<NASGU>
    Fth = Fof(min(tth, total_time));
    rhs = Fth + M*(b0*x + b2*xd + 2*xdd) + C*(b1*x + 2*xd + b3*xdd);
    xth = Qw*(Uw\(Lw\(Pw*rhs)));
    xddth = b0*(xth - x) - b2*xd - 2*xdd;
    xddn  = xdd + (xddth - xdd)/tho;
    xdn   = xd + dt/2*(xddn + xdd);
    x     = x + dt*xd + dt^2/6*(xddn + 2*xdd);
    xd = xdn; xdd = xddn;
    errW = max(errW, abs(x(probe) - th_ex(n+1)));
end
res(end+1,:) = {'Wilson-theta (1.4)', errW, toc(tW)};

%% ---- 3. Houbolt (Newmark startup for 2 steps) ---------------------------
xm2=zeros(Ndof,1); % x_{n-2}
% two Newmark startup steps
x=zeros(Ndof,1); xd=x; xdd=x; Xh=zeros(Ndof,3); % columns: n-2, n-1, n
KN = K + a0*M + a1*C; [Ln,Un,Pn,Qn] = lu(KN);
tH = tic;  errH = 0;
for n = 1:2
    F = Fof(n*dt);
    rhs = F + M*(a0*x + a2*xd + a3*xdd) + C*(a1*x + a4*xd + a5*xdd);
    xn = Qn*(Un\(Ln\(Pn*rhs)));
    xddn = a0*(xn-x) - a2*xd - a3*xdd;  xd = xd + a6*xdd + a7*xddn;
    Xh(:,n) = xn;  xdd = xddn;  xprev = x;  x = xn;                   %#ok<NASGU>
    errH = max(errH, abs(x(probe) - th_ex(n+1)));
end
Xh = [zeros(Ndof,1), Xh(:,1:2)];  % [n-2, n-1, n] with x0 = 0
h0 = 2/dt^2; h1 = 11/(6*dt);
KH = h0*M + h1*C + K;  [Lh,Uh,Ph,Qh] = lu(KH);
for n = 3:Nt
    F = Fof(n*dt);
    rhs = F + M*( (5*Xh(:,3) - 4*Xh(:,2) + Xh(:,1))/dt^2 ) ...
            + C*( (3*Xh(:,3) - 1.5*Xh(:,2) + Xh(:,1)/3)/dt );
    xn = Qh*(Uh\(Lh\(Ph*rhs)));
    Xh = [Xh(:,2:3), xn];
    errH = max(errH, abs(xn(probe) - th_ex(n+1)));
end
res(end+1,:) = {'Houbolt', errH, toc(tH)};

%% ---- 4. HHT-alpha (alpha = -0.1), acceleration form ---------------------
%  M a1 + (1+al)[C v1 + K d1] - al[C v0 + K d0] = (1+al)F(t1) - al F(t0)
%  with Newmark kinematics d1 = dp + bH dt^2 a1, v1 = vp + gH dt a1
al = -0.1;  gH = (1-2*al)/2;  bH = (1-al)^2/4;
KA = M + (1+al)*gH*dt*C + (1+al)*bH*dt^2*K;  [La,Ua,Pa,Qa] = lu(KA);
x=zeros(Ndof,1); xd=x; xdd=x;
tA = tic;  errA = 0;
for n = 1:Nt
    t1 = n*dt;  t0_ = (n-1)*dt;
    dp = x  + dt*xd + (0.5-bH)*dt^2*xdd;      % predictors
    vp = xd + (1-gH)*dt*xdd;
    rhs = (1+al)*Fof(t1) - al*Fof(t0_) ...
        - (1+al)*(C*vp + K*dp) + al*(C*xd + K*x);
    xddn = Qa*(Ua\(La\(Pa*rhs)));
    x  = dp + bH*dt^2*xddn;
    xd = vp + gH*dt*xddn;
    xdd = xddn;
    errA = max(errA, abs(x(probe) - th_ex(n+1)));
end
res(end+1,:) = {'HHT-alpha (-0.1)', errA, toc(tA)};

%% ---- 5. ode15s (condensed first-order system) ---------------------------
rsum = full(sum(abs(M),2) + sum(abs(C),2));
isb  = rsum < 1e-10;  ii = find(~isb);  bb = find(isb);
Kii=K(ii,ii); Kib=K(ii,bb); Kbi=K(bb,ii); Kbb=K(bb,bb);
Cii=C(ii,ii); Mii=M(ii,ii); dKbb=decomposition(Kbb);
e_ramp=zeros(numel(bb),1); [tf2,loc2]=ismember(rows_Tin,bb); e_ramp(loc2(tf2))=rs_Tin(tf2);
w_r=dKbb\e_ramp; w_c=dKbb\F0(bb); Kib_wr=Kib*w_r; Kib_wc=Kib*w_c;
Kred=Kii-Kib*(dKbb\Kbi); Fi0=F0(ii);
fr = @(t) th0*(1-exp(-t/t0r));
mdia=full(diag(Mii)); cdia=full(diag(Cii));
iT=find(mdia<1e-14); iM=find(mdia>=1e-14); CT=cdia(iT); MM=mdia(iM);
KTT=Kred(iT,iT); KTM=Kred(iT,iM); KMT=Kred(iM,iT); KMM=Kred(iM,iM);
nT=numel(iT); nM=numel(iM);
odef = @(t,y) [ (Fi0(iT)+fr(t)*(-Kib_wr(iT))-Kib_wc(iT)-KTT*y(1:nT)-KTM*y(nT+1:nT+nM))./CT ; ...
                y(nT+nM+1:end) ; ...
                (Fi0(iM)+fr(t)*(-Kib_wr(iM))-Kib_wc(iM)-KMT*y(1:nT)-KMM*y(nT+1:nT+nM))./MM ];
J = [ -spdiags(1./CT,0,nT,nT)*KTT, -spdiags(1./CT,0,nT,nT)*KTM, sparse(nT,nM);
       sparse(nM,nT), sparse(nM,nM), speye(nM);
      -spdiags(1./MM,0,nM,nM)*KMT, -spdiags(1./MM,0,nM,nM)*KMM, sparse(nM,nM)];
t15=tic;
[ts,ys]=ode15s(odef, tv, zeros(nT+2*nM,1), odeset('Jacobian',J,'RelTol',1e-7,'AbsTol',1e-9));
cpu15=toc(t15);
pg_i=find(ii==probe); pg_T=find(iT==pg_i);
res(end+1,:) = {'ode15s (adaptive)', max(abs(ys(:,pg_T)-th_ex)), cpu15};

%% ---- 6. Laplace + Durbin numerical inversion (reduced THERMAL system) ---
%  NOTE: applying Durbin to the FULL thermoelastic system fails, because the
%  undamped elastic resonances put poles ON the imaginary axis — exactly
%  where the Durbin contour samples (near-singular solves poison the sum).
%  This is why the literature applies Laplace inversion to the thermal
%  problem: the conduction poles are on the negative real axis. We therefore
%  invert the condensed theta-subsystem (same reduction as ode15s above):
%  (s*diag(CT) + KTT) th_hat = Fh_red(s),  Fh_red = -Kib_wr(iT)*th0*(1/s-1/(s+bD))
tL = tic;
TD = total_time;  aD = 7/(2*TD);  ND = 600;   % Durbin: half-period spacing
CTd  = spdiags(CT,0,nT,nT);
fvec = -Kib_wr(iT)*th0;
th_hat = @(s) (s*CTd + KTT) \ (fvec*(1/s - 1/(s+bD)));
x0 = th_hat(aD);  x0p = x0(pg_T);
acc = +0.5*real(x0p)*ones(numel(tv),1);
for kk = 1:ND
    s  = aD + 1i*kk*pi/TD;
    xh = th_hat(s);
    xp = xh(pg_T);
    acc = acc + real(xp)*cos(kk*pi*tv/TD) - imag(xp)*sin(kk*pi*tv/TD);
end
xLap = (1/TD)*exp(aD*tv).*acc;
cpuL = toc(tL);
late = tv >= 2;    % Durbin resolution Tper/(2*ND) ~ 0.07 s: earliest times excluded
err_late = max(abs(xLap(late)-th_ex(late)));
err_full = max(abs(xLap(2:end)-th_ex(2:end)));
fprintf('Laplace-Durbin: full-range err = %.4f K, t>=2s err = %.4f K\n', err_full, err_late);
res(end+1,:) = {'Laplace-Durbin (thermal)', err_late, cpuL};

%% ---- report -------------------------------------------------------------
fprintf('\n===== T1: TIME-INTEGRATION METHOD COMPARISON =====\n');
fprintf('probe r=%.4f m, exact = Bessel series;  dt=%.3g s, Nt=%d\n', r_probe, dt, Nt);
fprintf('%-28s %-14s %-10s\n','method','max err (K)','CPU (s)');
for q = 1:size(res,1)
    fprintf('%-28s %-14.5f %-10.2f\n', res{q,1}, res{q,2}, res{q,3});
end
outdir='param_studies'; Tt = cell2table(res,'VariableNames',{'method','max_err_K','cpu_s'});
writetable(Tt, fullfile(outdir,'T1_integrators_table.csv'));
fprintf('Saved param_studies\\T1_integrators_table.csv\n');

function F = local_F(t, F0, rows_Tin, rs_Tin, th0, t0r)
    F = F0;
    F(rows_Tin) = th0*(1-exp(-t/t0r)).*rs_Tin;
end
