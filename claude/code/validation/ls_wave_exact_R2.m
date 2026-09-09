function [th, info] = ls_wave_exact_R2(r, t, P, Nmode)
%LS_WAVE_EXACT_R2  Exact uncoupled Lord-Shulman thermal wave in a hollow cylinder.
%   Fourier-Bessel eigenfunction expansion -- exact in time, spectral in space.
%
%   [th, info] = ls_wave_exact_R2(r, t, P)         default number of modes
%   [th, info] = ls_wave_exact_R2(r, t, P, Nmode)  explicit number of modes
%
%   Solves, on Ri < r < Ro,
%       rho*c*( dtheta/dt + tau0*d2theta/dt2 ) = k*( d2theta/dr2 + (1/r) dtheta/dr )
%       theta(Ri,t) = Delta*(1 - exp(-t/t0))    (P.t0 <= 0  ->  ideal step Delta)
%       k*dtheta/dr(Ro,t) + h_c*theta(Ro,t) = 0
%       theta(r,0) = 0,  dtheta/dt(r,0) = 0
%
%   which is exactly the solver's energy row for theory='LS', coupling_on=false
%   (the beta*T0 term is the only temperature->mechanics coupling, so disabling
%   it makes the thermal field independent of u,w; with insulated ends and a
%   z-uniform boundary condition the solver's 2-D field must reduce to this).
%
%   METHOD.  Lift the time-dependent Dirichlet datum with the steady conduction
%   profile phi(r) = a + b*ln(r), which satisfies laplacian(phi) = 0 exactly and
%   carries both boundary conditions:
%       theta(r,t) = g(t)*phi(r) + sum_n v_n(t) * R_n(r)
%   The residual field expands in the Sturm-Liouville eigenfunctions of the
%   homogeneous problem (weight r),
%       R_n(r) = J0(lam_n r) Y0(lam_n Ri) - Y0(lam_n r) J0(lam_n Ri)
%   (R_n(Ri) = 0 by construction; lam_n from the Robin condition at Ro). Each
%   modal amplitude then obeys a *damped-oscillator ODE with exponential
%   forcing*, solved in CLOSED FORM:
%       tau0*v_n'' + v_n' + alpha*lam_n^2*v_n = -(g' + tau0*g'')*phi_n
%   so there is no time discretisation and no numerical Laplace inversion --
%   the only truncation is the number of radial modes, which is convergence-
%   tested by the caller.
%
%   Note the physics that makes this problem hard for contour-integral
%   inversion: every mode decays at the SAME rate exp(-t/(2 tau0)) once
%   alpha*lam^2/tau0 > 1/(4 tau0^2), i.e. high modes are NOT extra-damped.
%   That is precisely why a sharp front survives in hyperbolic conduction, and
%   why the modal route (which represents each mode exactly) is the right tool.
%
%   P: struct with Ri, Ro, k, rho, c, tau0, h_c, Delta, t0
%   info: struct with lam (eigenvalues), C (wave speed), alpha, phi coefficients

if nargin < 4 || isempty(Nmode), Nmode = 160; end

r = r(:);
alpha = P.k/(P.rho*P.c);
C     = sqrt(alpha/P.tau0);

% ---- lifting profile phi = a + b ln r : phi(Ri)=1, k phi'(Ro) + h phi(Ro)=0 ----
b = -P.h_c/(P.k/P.Ro + P.h_c*log(P.Ro/P.Ri));
a = 1 - b*log(P.Ri);
phi  = @(x) a + b*log(x);

% ---- eigenvalues of the homogeneous radial problem ----
lam = local_eigs(P, Nmode);

% ---- modal projections of phi (weight r) ----
Rn   = @(x,L) besselj(0,L*x).*bessely(0,L*P.Ri) - bessely(0,L*x).*besselj(0,L*P.Ri);
phin = zeros(Nmode,1);
for n = 1:Nmode
    L  = lam(n);
    f2 = @(x) x.*Rn(x,L).^2;
    f1 = @(x) x.*phi(x).*Rn(x,L);
    Nn = integral(f2, P.Ri, P.Ro, 'RelTol',1e-12,'AbsTol',1e-14);
    phin(n) = integral(f1, P.Ri, P.Ro, 'RelTol',1e-12,'AbsTol',1e-14)/Nn;
end

% ---- time factors ----
p = 1/(2*P.tau0);
th = zeros(size(r));

if P.t0 > 0
    g = P.Delta*(1 - exp(-t/P.t0));
else
    g = P.Delta;                                   % ideal step (t > 0)
end
th = th + g*phi(r);

for n = 1:Nmode
    L   = lam(n);
    w2  = alpha*L^2/P.tau0;
    disc = p^2 - w2;
    sq  = sqrt(complex(disc));
    m1  = -p + sq;   m2 = -p - sq;

    if P.t0 > 0
        % forcing  F_n*exp(-t/t0),  F_n = -phi_n*Delta*(t0 - tau0)/t0^2
        Fn  = -phin(n)*P.Delta*(P.t0 - P.tau0)/P.t0^2;
        den = 1/P.t0^2 - 1/(P.tau0*P.t0) + alpha*L^2/P.tau0;
        A   = (Fn/P.tau0)/den;                     % particular amplitude
        v0  = -A;                                  % v(0) = 0
        vd0 = -(P.Delta/P.t0)*phin(n) + A/P.t0;    % v'(0) = -g'(0)*phi_n
        [c1,c2] = local_pair(m1,m2,v0,vd0);
        v = A*exp(-t/P.t0) + c1*exp(m1*t) + c2*exp(m2*t);
    else
        % ideal step: homogeneous for t>0 with v(0)=-Delta*phi_n, v'(0)=0
        v0  = -P.Delta*phin(n);
        vd0 = 0;
        [c1,c2] = local_pair(m1,m2,v0,vd0);
        v = c1*exp(m1*t) + c2*exp(m2*t);
    end
    th = th + real(v)*Rn(r,L);
end

info.lam = lam;  info.C = C;  info.alpha = alpha;  info.a = a;  info.b = b;
end

% ------------------------------------------------------------------------
function [c1,c2] = local_pair(m1,m2,v0,vd0)
% constants of the homogeneous pair from v(0)=v0, v'(0)=vd0
if abs(m1-m2) < 1e-14*max(1,abs(m1))
    c1 = v0;  c2 = vd0 - m1*v0;                    % degenerate (unused in practice)
else
    c2 = (vd0 - m1*v0)/(m2 - m1);
    c1 = v0 - c2;
end
end

% ------------------------------------------------------------------------
function lam = local_eigs(P, Nmode)
% roots of  -k*lam*[J1(lam Ro)Y0(lam Ri) - Y1(lam Ro)J0(lam Ri)]
%            + h*[J0(lam Ro)Y0(lam Ri) - Y0(lam Ro)J0(lam Ri)] = 0
F = @(L) -P.k*L.*( besselj(1,L*P.Ro).*bessely(0,L*P.Ri) ...
                 - bessely(1,L*P.Ro).*besselj(0,L*P.Ri) ) ...
        + P.h_c*( besselj(0,L*P.Ro).*bessely(0,L*P.Ri) ...
                 - bessely(0,L*P.Ro).*besselj(0,L*P.Ri) );

dl   = pi/(P.Ro-P.Ri)/60;            % well below the asymptotic root spacing
Lmax = (Nmode+8)*pi/(P.Ro-P.Ri);
Ls   = (1e-4:dl:Lmax).';
Fs   = F(Ls);
idx  = find(Fs(1:end-1).*Fs(2:end) < 0);

lam = zeros(numel(idx),1);
for j = 1:numel(idx)
    lam(j) = fzero(F, [Ls(idx(j)) Ls(idx(j)+1)]);
end
lam = lam(lam > 1e-6);
if numel(lam) < Nmode
    error('ls_wave_exact_R2:eigs','found %d eigenvalues, need %d', numel(lam), Nmode);
end
lam = lam(1:Nmode);
end
