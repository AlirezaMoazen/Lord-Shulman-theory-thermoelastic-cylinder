%% ========================================================================
%  claude_T2_spatial_methods.m — SPATIAL DISCRETIZATION COMPARISON (T2)
%  ------------------------------------------------------------------------
%  1-D radial transient conduction (exact Bessel-series reference):
%    DQM (Chebyshev grid)  vs  DQM (uniform grid)  vs  FDM (2nd order)
%  Same Newmark time integration (small dt) for all — the error measured at
%  t = 10 s is the SPATIAL error. Produces the log-log convergence figure
%  ("DQM needs ~15 points where FDM needs hundreds").
%  ========================================================================
clearvars; clc; close all;

k_th=50; rho_th=8000; c_th=500; kappa=k_th/(rho_th*c_th);
Ri=0.08; Ro=0.1; hconv=2000; th0=200; t0r=5;
t_end=10; dtt=0.01; Ntt=round(t_end/dtt);

%% ---- exact solution ----
b_c = -hconv/(k_th/Ro + hconv*log(Ro/Ri));  a_c = 1 - b_c*log(Ri);
psi  = @(r) a_c + b_c*log(r);
geig = @(l) -k_th*l.*(besselj(1,l*Ro).*bessely(0,l*Ri) - bessely(1,l*Ro).*besselj(0,l*Ri)) ...
          + hconv*(besselj(0,l*Ro).*bessely(0,l*Ri) - bessely(0,l*Ro).*besselj(0,l*Ri));
Rfun = @(l,r) besselj(0,l*r).*bessely(0,l*Ri) - bessely(0,l*r).*besselj(0,l*Ri);
lam=zeros(60,1); nf=0; lg=linspace(1,40000,400000); gv=geig(lg);
for i=1:numel(lg)-1
    if nf>=60, break; end
    if gv(i)*gv(i+1)<0, nf=nf+1; lam(nf)=fzero(geig,[lg(i),lg(i+1)]); end
end
lam=lam(1:nf); cn=zeros(nf,1);
for n=1:nf
    num=integral(@(r) psi(r).*Rfun(lam(n),r).*r, Ri,Ro,'AbsTol',1e-12,'RelTol',1e-10);
    den=integral(@(r) Rfun(lam(n),r).^2.*r,      Ri,Ro,'AbsTol',1e-12,'RelTol',1e-10);
    cn(n)=num/den;
end
bD=1/t0r;
th_exact = @(r,t) th0*(1-exp(-t/t0r)).*psi(r) - ...
    sum((cn.*Rfun(lam,r)).*(th0*bD*(exp(-bD*t)-exp(-lam.^2*kappa*t))./(lam.^2*kappa-bD)),1);

% physical parameter bundle for the 1-D solver helper (script-local
% functions do NOT share the script workspace — pass everything explicitly)
P = struct('k',k_th,'rhoc',rho_th*c_th,'h',hconv,'th0',th0,'t0r',t0r, ...
           'dtt',dtt,'Ntt',Ntt);

%% ---- sweeps -------------------------------------------------------------
fprintf('===== T2: SPATIAL METHOD CONVERGENCE (error at t=10 s) =====\n');
Ns_dqm = [7 9 11 15 21 31];
err_dqm = zeros(size(Ns_dqm)); err_dqu = err_dqm;
for q = 1:numel(Ns_dqm)
    N = Ns_dqm(q);
    rC = Ri + (Ro-Ri)/2*(1-cos(pi*(0:N-1)/(N-1)));  rC = rC(:);   % Chebyshev
    thxC = arrayfun(@(rr) th_exact(rr, t_end), rC(:).');
    [A1,A2] = dqw(rC);      err_dqm(q) = run1d(rC, A1, A2, P, thxC);
    rU = linspace(Ri,Ro,N).';                                     % uniform
    thxU = arrayfun(@(rr) th_exact(rr, t_end), rU(:).');
    [B1,B2] = dqw(rU);      err_dqu(q) = run1d(rU, B1, B2, P, thxU);
    fprintf('DQM  N=%3d : cheb err=%.3e   uniform err=%.3e\n', N, err_dqm(q), err_dqu(q));
end
Ns_fdm = [11 21 41 81 161 321];
err_fdm = zeros(size(Ns_fdm));
for q = 1:numel(Ns_fdm)
    N = Ns_fdm(q);
    r = linspace(Ri,Ro,N).';  h = r(2)-r(1);
    D1 = zeros(N); D2 = zeros(N);
    for i = 2:N-1
        D1(i,i-1)=-1/(2*h); D1(i,i+1)=1/(2*h);
        D2(i,i-1)=1/h^2; D2(i,i)=-2/h^2; D2(i,i+1)=1/h^2;
    end
    D1(1,1:3)=[-3 4 -1]/(2*h);  D1(N,N-2:N)=[1 -4 3]/(2*h);   % one-sided
    thxF = arrayfun(@(rr) th_exact(rr, t_end), r(:).');
    err_fdm(q) = run1d(r, D1, D2, P, thxF);
    fprintf('FDM  N=%3d : err=%.3e\n', N, err_fdm(q));
end

%% ---- figure -------------------------------------------------------------
outdir='param_studies';  fdir=fullfile(outdir,'figures');
if ~exist(fdir,'dir'), mkdir(fdir); end
fig = figure('Position',[100 100 780 560],'Color','w');
loglog(Ns_dqm, err_dqm, 'bo-', 'LineWidth',1.6,'MarkerFaceColor','b'); hold on;
loglog(Ns_dqm, err_dqu, 'ms--','LineWidth',1.3);
loglog(Ns_fdm, err_fdm, 'r^-', 'LineWidth',1.6,'MarkerFaceColor','r');
loglog(Ns_fdm, err_fdm(1)*(Ns_fdm(1)./Ns_fdm).^2, 'k:', 'LineWidth',1);
xlabel('number of radial points N'); ylabel('max error at t = 10 s (K)');
legend('DQM (Chebyshev)','DQM (uniform)','FDM (2nd order)','slope -2','Location','southwest');
grid on; box on; title('Spatial convergence: DQM vs FDM (transient conduction)');
saveas(fig, fullfile(fdir,'T2_spatial_convergence.fig'));
print(fig, fullfile(fdir,'T2_spatial_convergence.png'), '-dpng','-r300');
T = table([Ns_dqm.'; Ns_fdm.'], [err_dqm.'; err_fdm.'], ...
    [repmat("DQM-cheb",numel(Ns_dqm),1); repmat("FDM",numel(Ns_fdm),1)], ...
    'VariableNames', {'N','max_err_K','method'});
writetable(T, fullfile(outdir,'T2_spatial_table.csv'));
fprintf('Saved figures\\T2_spatial_convergence + T2_spatial_table.csv\n');

%% ---- helpers ------------------------------------------------------------
function err = run1d(r, D1, D2, P, thx)
    % 1-D radial transient conduction with inner ramp + outer convection.
    N = numel(r);
    K = zeros(N); Cm = zeros(N);
    for i = 2:N-1
        K(i,:) = -P.k*( D2(i,:) + D1(i,:)/r(i) );
        Cm(i,i) = P.rhoc;
    end
    K(1,1) = 1;                                     % theta = ramp(t)
    K(N,:) = P.k*D1(N,:);  K(N,N) = K(N,N) + P.h;   % convection
    s_row = max(abs([K, (2/P.dtt)*Cm]),[],2); s_row(s_row==0)=1;
    K = K./s_row; Cm = Cm./s_row; rs1 = 1/s_row(1);
    a0=1/(0.25*P.dtt^2); a1=0.5/(0.25*P.dtt); a2=1/(0.25*P.dtt); a3=1;
    a4=1; a5=0; a6=P.dtt*0.5; a7=P.dtt*0.5;
    Keff = K + a1*Cm;                               % M = 0 (Fourier)
    x=zeros(N,1); xd=x; xdd=x;
    [Lf,Uf,pp] = lu(Keff,'vector');
    for n = 1:P.Ntt
        t = n*P.dtt;
        F = zeros(N,1);  F(1) = P.th0*(1-exp(-t/P.t0r))*rs1;
        rhs = F + Cm*(a1*x + a4*xd + a5*xdd);
        xn = Uf\(Lf\rhs(pp));
        xddn = a0*(xn-x) - a2*xd - a3*xdd;
        xd = xd + a6*xdd + a7*xddn;  x = xn;  xdd = xddn;
    end
    err = max(abs(x(2:end-1).' - thx(2:end-1)));
end

function [A,B] = dqw(x)
    N = numel(x);  A = zeros(N);
    for i = 1:N
        for j = 1:N
            if i~=j
                num=1; den=1;
                for k=1:N
                    if k~=i && k~=j, num=num*(x(i)-x(k)); den=den*(x(j)-x(k)); end
                end
                A(i,j) = num/(den*(x(j)-x(i)));
            end
        end
    end
    for i=1:N, A(i,i) = -sum(A(i,:)); end
    B = A*A;
end
