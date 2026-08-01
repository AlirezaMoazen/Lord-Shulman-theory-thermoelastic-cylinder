%% ========================================================================
%  claude_R3_run_benchmark3.m — LS-COUPLED CYLINDER BENCHMARK (1-D radial)
%  ------------------------------------------------------------------------
%  Reproduces: Bagri & Eslami, "A unified generalized thermoelasticity;
%  solution for cylinders and spheres", Int. J. Mech. Sci. 49 (2007)
%  1325-1335, Section 4.1 (LS hollow cylinder), Figs 2-4.
%
%  The benchmark is a plane-strain, z-independent (1-D radial) problem, so
%  it is solved here with a dedicated 1-D radial DQM + Newmark code that
%  uses the SAME discretization philosophy (Chebyshev DQ + displacement-
%  form Newmark + algebraic constraint rows + row equilibration) as the
%  2-D solver claude_R3. This validates the Lord-Shulman COUPLED operator
%  (finite thermal wave speed + thermoelastic wave interaction).
%
%  NOTE: the 2-D solver with 'R' (roller) ends develops the same spurious
%  DQM end-mode instability as 'F' ends (u-field unanchored in z), so the
%  1-D reduction is the appropriate vehicle for this 1-D benchmark.
%
%  Dimensionless problem (their Eq. 55):
%    hollow cylinder a=1, b=2, plane strain
%    c1=1, c2=0.535 (=> nu~0.3), coupling xi=0.02, LS tau0_bar=4, cK=1
%    => elastic wave speed 1.0, thermal wave speed cK/sqrt(tau0)=0.5
%    inner: heat-flux shock q=f(t)=1-(1+100t)e^{-100t},  u=0
%    outer: theta=0, sigma_rr=0;  zero ICs
%
%  PASS/FAIL checks: thermal front r=1+0.5t, elastic front r=1+t,
%  reflections at t=1 (elastic@b) and t=2 (thermal@b).
%  ========================================================================
clearvars; clc; close all;

%% ---------------------------- parameters --------------------------------
a  = 1;  b = 2;                 % radii
mu_  = 0.535^2;                 % 0.286225   (lambda+2mu = 1, rho = 1)
lam_ = 1 - 2*mu_;               % 0.427550
C11  = lam_ + 2*mu_;            % = 1
beta_= sqrt(0.02);              % coupling: xi = beta^2 T0/(rho c (lam+2mu)) = 0.02
T0   = 1;  rho = 1;  cheat = 1; % T0, rho, specific heat
kcond= 1;                       % cK^2 = k/(rho c) = 1
tau0 = 4;                       % LS relaxation (dimensionless)
fq   = @(t) 1 - (1+100*t).*exp(-100*t);   % inner heat-flux shock

N    = 161;                     % radial DQ points (sharp fronts need many)
dtt  = 0.002;  t_end = 2.4;  Nt = round(t_end/dtt);
gam  = 0.60;   bet = (gam+0.5)^2/4;       % mild numerical damping (fronts)

%% ---------------------------- DQ setup ----------------------------------
r = a + (b-a)/2*(1 - cos(pi*(0:N-1)/(N-1)));  r = r(:);
[Ar, Br] = DQw(r);

% unknowns x = [theta(1..N); u(1..N)]
nT = 1:N;  nU = N+1:2*N;
K = zeros(2*N); Cm = zeros(2*N); Mm = zeros(2*N);

% ---- interior energy rows (i = 2..N-1):
%  rho c (th' + tau0 th'') + beta T0 (e' + tau0 e'') - k(th'' + th'/r) = 0
%  with dilatation e = u' + u/r   (plane strain, w=0)
for i = 2:N-1
    K(i, nT) = -kcond*( Br(i,:) + Ar(i,:)/r(i) );
    Cm(i, i) = rho*cheat;
    Mm(i, i) = rho*cheat*tau0;
    Cm(i, nU) = beta_*T0*( Ar(i,:) + (1:N==i)/r(i) );
    Mm(i, nU) = tau0*beta_*T0*( Ar(i,:) + (1:N==i)/r(i) );
end
% ---- interior momentum rows (i = 2..N-1):
%  rho u'' - C11(u''_r + u'/r - u/r^2) + beta th' = 0
for i = 2:N-1
    K(N+i, nU) = -C11*( Br(i,:) + Ar(i,:)/r(i) - (1:N==i)/r(i)^2 );
    K(N+i, nT) =  beta_*Ar(i,:);
    Mm(N+i, N+i) = rho;
end
% ---- boundary rows:
% r=a: -k th' = f(t)  |  u = 0
K(1, nT) = -kcond*Ar(1,:);            % RHS = f(t)
K(N+1, N+1) = 1;                      % u(a) = 0
% r=b: theta = 0  |  sigma_rr = C11 u' + lam u/r - beta th = 0
K(N, N) = 1;
K(2*N, nU) = C11*Ar(N,:);
K(2*N, 2*N) = K(2*N, 2*N) + lam_/r(N);
K(2*N, N)   = -beta_;

%% ------------------------ row equilibration -----------------------------
a0 = 1/(bet*dtt^2); a1 = gam/(bet*dtt); a2 = 1/(bet*dtt); a3 = 1/(2*bet)-1;
a4 = gam/bet-1;     a5 = dtt/2*(gam/bet-2); a6 = dtt*(1-gam); a7 = dtt*gam;

s_row = max(abs([K, a0*Mm, a1*Cm]), [], 2);  s_row(s_row==0) = 1;
Sc = diag(1./s_row);
K = Sc*K;  Mm = Sc*Mm;  Cm = Sc*Cm;
rs_q = 1/s_row(1);                    % scaling of the flux row

K_eff = K + a0*Mm + a1*Cm;
fprintf('1-D benchmark: N=%d, dofs=%d, rcond=%.2e\n', N, 2*N, rcond(K_eff));
[Lf,Uf,pp] = lu(K_eff,'vector');

%% --------------------------- time marching ------------------------------
x = zeros(2*N,1); xd = x; xdd = x;
X = zeros(2*N, Nt+1);
for n = 1:Nt
    t = n*dtt;
    F = zeros(2*N,1);
    F(1) = fq(t)*rs_q;
    rhs = F + Mm*(a0*x + a2*xd + a3*xdd) + Cm*(a1*x + a4*xd + a5*xdd);
    xn  = Uf\(Lf\rhs(pp));
    xddn = a0*(xn - x) - a2*xd - a3*xdd;
    xd   = xd + a6*xdd + a7*xddn;
    x = xn;  xdd = xddn;
    X(:,n+1) = x;
    if any(~isfinite(x)), error('diverged at t=%.3f', t); end
end
fprintf('marching complete: %d steps\n', Nt);

%% ------------------------ wave-front checks -----------------------------
t_check = [0.2 0.6 1.0 1.4 1.8];
fprintf('\n===== BENCHMARK 3: Bagri & Eslami (2007) LS cylinder (1-D) =====\n');
fprintf('%-6s %-24s %-24s\n','t','thermal front num/theory','elastic front num/theory');
front_tab = zeros(numel(t_check),5);
for kk = 1:numel(t_check)
    tt = t_check(kk);  n_t = round(tt/dtt)+1;
    th = X(nT, n_t);   uu = X(nU, n_t);
    srr = C11*(Ar*uu) + lam_*uu./r - beta_*th;
    % thermal front = outermost radius where theta exceeds 2% of its max
    thr = 0.02*max(abs(th));
    i1  = find(abs(th) > thr, 1, 'last');  r_thf = r(min(i1+1,N));
    % elastic front:
    %   before reflection (t<=1): outermost radius with |srr| > 2% of max
    %   after reflection  (t>1) : interior max |d(srr)/dr| (kink of the
    %                             back-running front), boundaries excluded
    if tt <= 1
        sthr = 0.02*max(abs(srr));
        i2 = find(abs(srr) > sthr, 1, 'last');  r_elf = r(min(i2+1,N));
        el_theo = min(a+tt, b);
    else
        ds = abs(Ar*srr);  ds([1:8, N-7:N]) = 0;
        [~,i2] = max(ds);  r_elf = r(i2);
        el_theo = b - (tt-1);
    end
    th_theo = min(a+0.5*tt, b);
    fprintf('%-6.2f %9.3f / %-9.3f    %9.3f / %-9.3f\n', tt, r_thf, th_theo, r_elf, el_theo);
    front_tab(kk,:) = [tt, r_thf, th_theo, r_elf, el_theo];
end

%% ------------------------------ figures ---------------------------------
outdir = 'Validation';
if ~exist(outdir,'dir'), mkdir(outdir); end
tshow = [0.2 0.6 1.0 1.4 1.8 2.2];
cols = lines(numel(tshow));

figA = figure('Position',[80 80 860 560],'Color','w'); hold on;
for kk = 1:numel(tshow)
    n_t = round(tshow(kk)/dtt)+1;
    plot(r, X(nT,n_t), '-', 'Color',cols(kk,:), 'LineWidth',1.5, ...
         'DisplayName',sprintf('t = %.1f',tshow(kk)));
end
xlabel('r'); ylabel('\theta'); grid on; box on; legend('Location','northeast');
title('LS cylinder: temperature (cf. Bagri & Eslami Fig. 2)');
saveas(figA, fullfile(outdir,'bench3_theta.fig'));
print(figA, fullfile(outdir,'bench3_theta.png'), '-dpng','-r300');

figB = figure('Position',[100 100 860 560],'Color','w'); hold on;
for kk = 1:numel(tshow)
    n_t = round(tshow(kk)/dtt)+1;
    th = X(nT,n_t);  uu = X(nU,n_t);
    srr = C11*(Ar*uu) + lam_*uu./r - beta_*th;
    plot(r, srr, '-', 'Color',cols(kk,:), 'LineWidth',1.5, ...
         'DisplayName',sprintf('t = %.1f',tshow(kk)));
end
xlabel('r'); ylabel('\sigma_{rr}'); grid on; box on; legend('Location','southeast');
title('LS cylinder: radial stress (cf. Bagri & Eslami Fig. 3)');
saveas(figB, fullfile(outdir,'bench3_srr.fig'));
print(figB, fullfile(outdir,'bench3_srr.png'), '-dpng','-r300');

figC = figure('Position',[120 120 860 560],'Color','w'); hold on;
for kk = 1:numel(tshow)
    n_t = round(tshow(kk)/dtt)+1;
    th = X(nT,n_t);  uu = X(nU,n_t);
    stt = lam_*(Ar*uu) + C11*uu./r - beta_*th;
    plot(r, stt, '-', 'Color',cols(kk,:), 'LineWidth',1.5, ...
         'DisplayName',sprintf('t = %.1f',tshow(kk)));
end
xlabel('r'); ylabel('\sigma_{\theta\theta}'); grid on; box on; legend('Location','southeast');
title('LS cylinder: hoop stress (cf. Bagri & Eslami Fig. 4)');
saveas(figC, fullfile(outdir,'bench3_stt.fig'));
print(figC, fullfile(outdir,'bench3_stt.png'), '-dpng','-r300');

Ttab = array2table(front_tab, 'VariableNames', ...
    {'t','r_thermal_num','r_thermal_theory','r_elastic_num','r_elastic_theory'});
writetable(Ttab, fullfile(outdir,'bench3_fronts.csv'));
save(fullfile(outdir,'Results_R3_bench3_1D.mat'),'r','X','front_tab','N','dtt');
fprintf('\nSaved: Validation\\bench3_theta/srr/stt (.png/.fig) + bench3_fronts.csv\n');

%% ------------------------------ helpers ---------------------------------
function [A,B] = DQw(x)
    N = numel(x);  A = zeros(N);
    for i = 1:N
        for j = 1:N
            if i~=j
                num=1; den=1;
                for k=1:N
                    if k~=i && k~=j
                        num = num*(x(i)-x(k));
                        den = den*(x(j)-x(k));
                    end
                end
                A(i,j) = num/(den*(x(j)-x(i)));
            end
        end
    end
    for i=1:N, A(i,i) = -sum(A(i,:)); end
    B = A*A;
end
