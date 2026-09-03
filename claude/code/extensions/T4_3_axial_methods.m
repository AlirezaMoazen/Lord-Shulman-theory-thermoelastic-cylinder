%% ========================================================================
%  claude_T4_3_axial_methods.m — AXIAL SPATIAL DISCRETIZATION COMPARISON (T4.3)
%  ------------------------------------------------------------------------
%  Revision of claude_T4_1_axial_methods.m (T4_1 kept frozen). Author
%  request (mirrors T2.9): revert to T4.1's node sweep (T4.2's densified-
%  DQM/extended-FEM sweep not wanted for the shipped figure) but keep the
%  x-axis label fix — drop "N" ("number of axial points N" -> "number of
%  axial points"). Everything else identical to T4.1.
%  ------------------------------------------------------------------------
%  Axial-direction companion to claude_T2_9_spatial_methods.m (which is the
%  RADIAL benchmark). Author request 2026-08-25: a T2-style figure but for
%  axial (N_z) nodes. T2's benchmark is a radial annulus (Bessel exact
%  solution, no z-dependence), so it cannot simply be relabelled — this is
%  a genuinely separate 1-D AXIAL benchmark with its own exact solution:
%
%     finite rod  z in [0, L],  rho*c dth/dt = k d2th/dz2
%     z = 0 : th = ramp(t) = th0 (1 - e^{-t/t0})        (Dirichlet)
%     z = L : dth/dz = 0                                 (insulated)
%     th(z,0) = 0
%
%  Exact solution (separation of variables; eigenfunctions sin(bn z) with
%  bn = (2n-1)pi/(2L) satisfying th(0)=0-perturbation + insulated at L):
%     th(z,t) = g(t) + sum_n B_n(t) sin(bn z),   g(t)=th0(1-e^{-t/t0})
%     c_n = 2/(bn L),  lam_n = kappa bn^2,  bD = 1/t0
%     B_n(t) = -th0 bD c_n /(lam_n - bD) * (e^{-bD t} - e^{-lam_n t})
%
%  Same five methods and same display standard as T2_7 (first-edition
%  palette, white-face markers, slope-2 dotted ref, y-axis capped, legend
%  top-right). Same Newmark march (dt = 0.01 s) so the error at t = 10 s is
%  the SPATIAL (axial) error of each method. Cartesian weak form for FEM
%  (weight 1, no r-weighting) and no 1/r term in the strong-form operators.
%  Output -> results_extensions\ (figure T4_axial_convergence + table).
%  New file; reads/writes nothing the solver campaign touches.
%  ========================================================================
clearvars; clc; close all;

k_th=50; rho_th=8000; c_th=500; kappa=k_th/(rho_th*c_th);
Lz=0.02; th0=200; t0r=5;                 % rod length matches radial wall thickness
t_end=10; dtt=0.01; Ntt=round(t_end/dtt);

%% ---- exact solution (Fourier series) ------------------------------------
bD=1/t0r; nmax=200;
nn=(1:nmax).';  bn=(2*nn-1)*pi/(2*Lz);  lamn=kappa*bn.^2;  cn=2./(bn*Lz);
th_exact = @(z,t) th0*(1-exp(-t/t0r)) + ...
    sum( (-th0*bD.*cn./(lamn-bD)).*(exp(-bD*t)-exp(-lamn*t)).*sin(bn*z), 1);

% physical parameter bundle for the script-local solver helpers
P = struct('k',k_th,'rhoc',rho_th*c_th,'th0',th0,'t0r',t0r, ...
           'dtt',dtt,'Ntt',Ntt,'Lz',Lz);

%% ---- sweeps -------------------------------------------------------------
fprintf('===== T4.3: AXIAL SPATIAL METHOD CONVERGENCE incl. FEM (error at t=10 s) =====\n');
Ns_dqm = [7 9 11 15 21 31 41 61 81 121 161 201];
err_dqm = nan(size(Ns_dqm)); err_dqu = err_dqm;
for q = 1:numel(Ns_dqm)
    N = Ns_dqm(q);
    % global-polynomial DQM ill-conditions at high N (esp. uniform nodes,
    % Runge blow-up); guard so one bad N doesn't abort the whole sweep.
    try
        zC = Lz/2*(1-cos(pi*(0:N-1)/(N-1)));  zC = zC(:);          % Chebyshev
        thxC = arrayfun(@(zz) th_exact(zz, t_end), zC(:).');
        [A1,A2] = dqw(zC);      err_dqm(q) = run1d(zC, A1, A2, P, thxC);
    catch ME
        fprintf('DQM  N=%3d : cheb FAILED (%s)\n', N, ME.message);
    end
    try
        zU = linspace(0,Lz,N).';                                   % uniform
        thxU = arrayfun(@(zz) th_exact(zz, t_end), zU(:).');
        [B1,B2] = dqw(zU);      err_dqu(q) = run1d(zU, B1, B2, P, thxU);
    catch ME
        fprintf('DQM  N=%3d : uniform FAILED (%s)\n', N, ME.message);
    end
    fprintf('DQM  N=%3d : cheb err=%.3e   uniform err=%.3e\n', N, err_dqm(q), err_dqu(q));
end
Ns_fdm = [11 21 41 81 161 321];
err_fdm = zeros(size(Ns_fdm));
for q = 1:numel(Ns_fdm)
    N = Ns_fdm(q);
    z = linspace(0,Lz,N).';  h = z(2)-z(1);
    D1 = zeros(N); D2 = zeros(N);
    for i = 2:N-1
        D1(i,i-1)=-1/(2*h); D1(i,i+1)=1/(2*h);
        D2(i,i-1)=1/h^2; D2(i,i)=-2/h^2; D2(i,i+1)=1/h^2;
    end
    D1(1,1:3)=[-3 4 -1]/(2*h);  D1(N,N-2:N)=[1 -4 3]/(2*h);   % one-sided
    thxF = arrayfun(@(zz) th_exact(zz, t_end), z(:).');
    err_fdm(q) = run1d(z, D1, D2, P, thxF);
    fprintf('FDM  N=%3d : err=%.3e\n', N, err_fdm(q));
end
Ns_fe1 = [11 21 41 81 161 321];              % linear elements (N-1 elements)
err_fe1 = zeros(size(Ns_fe1));
for q = 1:numel(Ns_fe1)
    N = Ns_fe1(q);
    z = linspace(0,Lz,N).';
    [Kf,Cf] = femmat(z, 1, P);
    thxE = arrayfun(@(zz) th_exact(zz, t_end), z(:).');
    err_fe1(q) = run1d_mat(Kf, Cf, P, thxE);
    fprintf('FEM1 N=%3d : err=%.3e\n', N, err_fe1(q));
end
Ns_fe2 = [11 21 41 81 161];                  % quadratic (odd N, (N-1)/2 elems)
err_fe2 = zeros(size(Ns_fe2));
for q = 1:numel(Ns_fe2)
    N = Ns_fe2(q);
    z = linspace(0,Lz,N).';
    [Kf,Cf] = femmat(z, 2, P);
    thxE = arrayfun(@(zz) th_exact(zz, t_end), z(:).');
    err_fe2(q) = run1d_mat(Kf, Cf, P, thxE);
    fprintf('FEM2 N=%3d : err=%.3e\n', N, err_fe2(q));
end

%% ---- figure (same display standard as T2_7) ----------------------------
outdir='results_extensions';  fdir=fullfile(outdir,'figures');
if ~exist(fdir,'dir'), mkdir(fdir); end
fig = figure('Position',[100 100 780 560],'Color','w');
cBlue=[0 0.4470 0.7410]; cRed=[0.8500 0.3250 0.0980]; cYel=[0.9290 0.6940 0.1250];
cPur=[0.4940 0.1840 0.5560]; cGrn=[0.4660 0.6740 0.1880];
loglog(Ns_dqm, err_dqm, 'o-', 'Color',cBlue,'LineWidth',1.6,'MarkerSize',6,'MarkerFaceColor','w'); hold on;
loglog(Ns_dqm, err_dqu, 's-', 'Color',cRed, 'LineWidth',1.4,'MarkerSize',6,'MarkerFaceColor','w');
loglog(Ns_fdm, err_fdm, '^-', 'Color',cYel, 'LineWidth',1.6,'MarkerSize',6,'MarkerFaceColor','w');
loglog(Ns_fe1, err_fe1, 'd-', 'Color',cPur, 'LineWidth',1.6,'MarkerSize',6,'MarkerFaceColor','w');
loglog(Ns_fe2, err_fe2, 'v-', 'Color',cGrn, 'LineWidth',1.6,'MarkerSize',6,'MarkerFaceColor','w');
loglog(Ns_fdm, err_fdm(1)*(Ns_fdm(1)./Ns_fdm).^2, 'k:', 'LineWidth',1);
xlabel('number of axial points'); ylabel('max error at t = 10 s (K)');
legend('DQM (Chebyshev)','DQM (uniform)','FDM (2nd order)', ...
       'FEM (linear)','FEM (quadratic)','slope -2','Location','northeast');
grid on; box on;
% axial problem resolves to lower error than the radial T2 case, so the
% y-axis extends down to 1e-6 to reveal the full DQM / quadratic-FEM
% convergence — incl. the lowest DQM(uniform) point (N=31, ~7.5e-6) —
% instead of clipping it. Top still capped so the divergent uniform-DQM
% branch (~1e50) doesn't flatten the readable curves.
ylim([1e-6 3e-1]);
saveas(fig, fullfile(fdir,'T4_axial_convergence.fig'));
print(fig, fullfile(fdir,'T4_axial_convergence.png'), '-dpng','-r300');
T = table([Ns_dqm.'; Ns_dqm.'; Ns_fdm.'; Ns_fe1.'; Ns_fe2.'], ...
    [err_dqm.'; err_dqu.'; err_fdm.'; err_fe1.'; err_fe2.'], ...
    [repmat("DQM-cheb",numel(Ns_dqm),1); repmat("DQM-unif",numel(Ns_dqm),1); ...
     repmat("FDM",numel(Ns_fdm),1); repmat("FEM-lin",numel(Ns_fe1),1); ...
     repmat("FEM-quad",numel(Ns_fe2),1)], ...
    'VariableNames', {'N','max_err_K','method'});
writetable(T, fullfile(outdir,'T4_axial_table.csv'));
fprintf('Saved %s\\figures\\T4_axial_convergence + T4_axial_table.csv\n', outdir);

%% ---- helpers ------------------------------------------------------------
function err = run1d(z, D1, D2, P, thx)
    % 1-D axial (Cartesian) transient conduction: end ramp + insulated end.
    N = numel(z);
    K = zeros(N); Cm = zeros(N);
    for i = 2:N-1
        K(i,:) = -P.k*D2(i,:);          % no 1/r term (Cartesian rod)
        Cm(i,i) = P.rhoc;
    end
    K(1,1) = 1;                          % theta = ramp(t) at z=0
    K(N,:) = P.k*D1(N,:);               % insulated: k dtheta/dz = 0 at z=L
    err = march(K, Cm, P, thx);
end

function err = run1d_mat(K, Cm, P, thx)
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

function [K, Cm] = femmat(z, order, P)
    % Galerkin FEM for  rho*c dth/dt - k th'' = 0  on [0,Lz] (Cartesian):
    %   K_ij  = int k Ni' Nj' dz     Cm_ij = int rho*c Ni Nj dz
    % insulated end at z=Lz is the natural BC (nothing added); Dirichlet
    % ramp at z=0 enforced by the constraint row. order 1: linear; 2: quad.
    N = numel(z);
    K = zeros(N); Cm = zeros(N);
    if order == 1
        for e = 1:N-1
            Le = z(e+1)-z(e); idx=[e e+1];
            Ke = P.k/Le*[1 -1; -1 1];
            Ce = P.rhoc*Le/6*[2 1; 1 2];
            K(idx,idx)  = K(idx,idx)  + Ke;
            Cm(idx,idx) = Cm(idx,idx) + Ce;
        end
    else
        assert(mod(N,2)==1, 'quadratic FEM needs odd N');
        gp = [-sqrt(3/5) 0 sqrt(3/5)];  gw = [5/9 8/9 5/9];
        for e = 1:(N-1)/2
            idx = 2*e-1 : 2*e+1;  ze = z(idx);  Le = ze(3)-ze(1);
            Ke = zeros(3); Ce = zeros(3);
            for g = 1:3
                xi = gp(g);
                Nsh  = [xi*(xi-1)/2, 1-xi^2, xi*(xi+1)/2];
                dNxi = [xi-1/2,      -2*xi,  xi+1/2];
                dNdz = dNxi*(2/Le);
                Ke = Ke + gw(g)*P.k    *(dNdz.'*dNdz)*(Le/2);
                Ce = Ce + gw(g)*P.rhoc *(Nsh.' *Nsh )*(Le/2);
            end
            K(idx,idx)  = K(idx,idx)  + Ke;
            Cm(idx,idx) = Cm(idx,idx) + Ce;
        end
    end
    K(1,:) = 0; K(1,1) = 1; Cm(1,:) = 0;   % Dirichlet constraint row at z=0
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
