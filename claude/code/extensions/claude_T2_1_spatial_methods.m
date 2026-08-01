%% ========================================================================
%  claude_T2_1_spatial_methods.m — SPATIAL DISCRETIZATION COMPARISON (T2.1)
%  ------------------------------------------------------------------------
%  Revision of claude_T2_spatial_methods.m (T2 kept frozen). Additions:
%    + FEM, linear 2-node elements   (Galerkin weak form, r-weighted)
%    + FEM, quadratic 3-node elements
%  Everything from T2 is unchanged: same exact Bessel-series reference,
%  same Newmark time march (dt = 0.01 s) so the measured error at t = 10 s
%  is the SPATIAL error of each method.
%  Output goes to results_extensions\ (method/theory comparisons are kept
%  separate from the parametric campaign for the results chapter).
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

% physical parameter bundle for the 1-D solver helpers (script-local
% functions do NOT share the script workspace — pass everything explicitly)
P = struct('k',k_th,'rhoc',rho_th*c_th,'h',hconv,'th0',th0,'t0r',t0r, ...
           'dtt',dtt,'Ntt',Ntt,'Ri',Ri,'Ro',Ro);

%% ---- sweeps -------------------------------------------------------------
fprintf('===== T2.1: SPATIAL METHOD CONVERGENCE incl. FEM (error at t=10 s) =====\n');
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

% ---- NEW: FEM sweeps -----------------------------------------------------
Ns_fe1 = [11 21 41 81 161 321];              % linear elements (N-1 elements)
err_fe1 = zeros(size(Ns_fe1));
for q = 1:numel(Ns_fe1)
    N = Ns_fe1(q);
    r = linspace(Ri,Ro,N).';
    [Kf,Cf] = femmat(r, 1, P);
    thxE = arrayfun(@(rr) th_exact(rr, t_end), r(:).');
    err_fe1(q) = run1d_mat(Kf, Cf, P, thxE);
    fprintf('FEM1 N=%3d : err=%.3e\n', N, err_fe1(q));
end
Ns_fe2 = [11 21 41 81 161];                  % quadratic (odd N, (N-1)/2 elems)
err_fe2 = zeros(size(Ns_fe2));
for q = 1:numel(Ns_fe2)
    N = Ns_fe2(q);
    r = linspace(Ri,Ro,N).';
    [Kf,Cf] = femmat(r, 2, P);
    thxE = arrayfun(@(rr) th_exact(rr, t_end), r(:).');
    err_fe2(q) = run1d_mat(Kf, Cf, P, thxE);
    fprintf('FEM2 N=%3d : err=%.3e\n', N, err_fe2(q));
end

%% ---- figure -------------------------------------------------------------
outdir='results_extensions';  fdir=fullfile(outdir,'figures');
if ~exist(fdir,'dir'), mkdir(fdir); end
fig = figure('Position',[100 100 780 560],'Color','w');
loglog(Ns_dqm, err_dqm, 'bo-', 'LineWidth',1.6,'MarkerFaceColor','b'); hold on;
loglog(Ns_dqm, err_dqu, 'ms--','LineWidth',1.3);
loglog(Ns_fdm, err_fdm, 'r^-', 'LineWidth',1.6,'MarkerFaceColor','r');
loglog(Ns_fe1, err_fe1, 'gd-', 'LineWidth',1.6,'MarkerFaceColor','g');
loglog(Ns_fe2, err_fe2, 'kv-', 'LineWidth',1.6,'MarkerFaceColor',[.4 .4 .4]);
loglog(Ns_fdm, err_fdm(1)*(Ns_fdm(1)./Ns_fdm).^2, 'k:', 'LineWidth',1);
xlabel('number of radial points N'); ylabel('max error at t = 10 s (K)');
legend('DQM (Chebyshev)','DQM (uniform)','FDM (2nd order)', ...
       'FEM (linear)','FEM (quadratic)','slope -2','Location','southwest');
grid on; box on; title('Spatial convergence: DQM vs FDM vs FEM (transient conduction)');
saveas(fig, fullfile(fdir,'T2_spatial_convergence.fig'));
print(fig, fullfile(fdir,'T2_spatial_convergence.png'), '-dpng','-r300');
T = table([Ns_dqm.'; Ns_dqm.'; Ns_fdm.'; Ns_fe1.'; Ns_fe2.'], ...
    [err_dqm.'; err_dqu.'; err_fdm.'; err_fe1.'; err_fe2.'], ...
    [repmat("DQM-cheb",numel(Ns_dqm),1); repmat("DQM-unif",numel(Ns_dqm),1); ...
     repmat("FDM",numel(Ns_fdm),1); repmat("FEM-lin",numel(Ns_fe1),1); ...
     repmat("FEM-quad",numel(Ns_fe2),1)], ...
    'VariableNames', {'N','max_err_K','method'});
writetable(T, fullfile(outdir,'T2_spatial_table.csv'));
fprintf('Saved %s\\figures\\T2_spatial_convergence + T2_spatial_table.csv\n', outdir);

%% ---- helpers ------------------------------------------------------------
function err = run1d(r, D1, D2, P, thx)
    % 1-D radial transient conduction with inner ramp + outer convection.
    % (unchanged from claude_T2_spatial_methods.m)
    N = numel(r);
    K = zeros(N); Cm = zeros(N);
    for i = 2:N-1
        K(i,:) = -P.k*( D2(i,:) + D1(i,:)/r(i) );
        Cm(i,i) = P.rhoc;
    end
    K(1,1) = 1;                                     % theta = ramp(t)
    K(N,:) = P.k*D1(N,:);  K(N,N) = K(N,N) + P.h;   % convection
    err = march(K, Cm, P, thx);
end

function err = run1d_mat(K, Cm, P, thx)
    % same Newmark march for a PRE-ASSEMBLED (weak-form) system.
    % Inner Dirichlet row is already the constraint row K(1,:)=[1 0...0].
    err = march(K, Cm, P, thx);
end

function err = march(K, Cm, P, thx)
    N = size(K,1);
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

function [K, Cm] = femmat(r, order, P)
    % Galerkin FEM for  rho*c dth/dt - k (th'' + th'/r) = 0  on [Ri,Ro],
    % weak form with cylindrical weight r:
    %   K_ij  = int k Ni' Nj' r dr   (+ h*Ro at outer node)
    %   Cm_ij = int rho*c Ni Nj r dr
    % order 1: 2-node linear elements; order 2: 3-node quadratic (N odd).
    N = numel(r);
    K = zeros(N); Cm = zeros(N);
    if order == 1
        for e = 1:N-1
            r1=r(e); r2=r(e+1); Le=r2-r1; idx=[e e+1];
            Ke = P.k*(r1+r2)/(2*Le)*[1 -1; -1 1];
            Ce = P.rhoc*Le/12*[3*r1+r2, r1+r2; r1+r2, r1+3*r2];
            K(idx,idx)  = K(idx,idx)  + Ke;
            Cm(idx,idx) = Cm(idx,idx) + Ce;
        end
    else
        assert(mod(N,2)==1, 'quadratic FEM needs odd N');
        % 3-point Gauss (exact for the degree-5 integrands here)
        gp = [-sqrt(3/5) 0 sqrt(3/5)];  gw = [5/9 8/9 5/9];
        for e = 1:(N-1)/2
            idx = 2*e-1 : 2*e+1;  re = r(idx);  Le = re(3)-re(1);
            Ke = zeros(3); Ce = zeros(3);
            for g = 1:3
                xi = gp(g);
                Nsh  = [xi*(xi-1)/2, 1-xi^2, xi*(xi+1)/2];
                dNxi = [xi-1/2,      -2*xi,  xi+1/2];
                rg   = re(1) + (xi+1)*Le/2;         % equally spaced nodes
                dNdr = dNxi*(2/Le);
                Ke = Ke + gw(g)*P.k    *(dNdr.'*dNdr)*rg*(Le/2);
                Ce = Ce + gw(g)*P.rhoc *(Nsh.' *Nsh )*rg*(Le/2);
            end
            K(idx,idx)  = K(idx,idx)  + Ke;
            Cm(idx,idx) = Cm(idx,idx) + Ce;
        end
    end
    K(N,N) = K(N,N) + P.h*P.Ro;        % natural convection BC (weak form)
    K(1,:) = 0; K(1,1) = 1; Cm(1,:) = 0;   % inner Dirichlet constraint row
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
