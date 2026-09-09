function th = ls_wave_exact_R1(r, t, P, M)
%LS_WAVE_EXACT_R1  SUPERSEDED -- do NOT use as a reference for wave problems.
%   Kept frozen for provenance only. Use ls_wave_exact_R2.m instead.
%
%   WHY THIS APPROACH FAILS HERE (measured, not assumed):
%   This computes the same exact Laplace-domain solution as R2 but inverts it
%   with the fixed-Talbot contour algorithm. The Laplace-domain formula itself is
%   correct -- it reproduces the steady-state limit to 7e-9 of Delta. The
%   INVERSION is what breaks:
%     * for large s, Theta ~ exp(-s*(r-Ri)/C)/s, i.e. a pure time DELAY. Talbot
%       must then cancel exp(t*s) against exp(-s*delay) over the contour, which
%       is a catastrophic cancellation before the wave arrives.
%     * Talbot's node radius carries a factor exp(2M/5), so raising M to fight
%       the error amplifies round-off instead. Measured on this problem:
%         |M64-M32| = 3.2e1 K,  |M96-M64| = 8.6e2 K,  |M128-M96| = 4.2e8 K
%       -- the error GROWS with M; there is no usable convergence window.
%     * consequences: ~2-5% of Delta leaking ahead of the front (a hyperbolic
%       solution must be exactly zero there), and a front amplitude landing on
%       the midpoint of the jump rather than its value.
%   The modal (Fourier-Bessel) route in R2 has no inversion step at all -- each
%   mode is solved exactly in time -- and delivers ~8e-4 relative accuracy with
%   causality satisfied to 4e-6 of Delta.
%
%   Original description follows.
%
%   th = ls_wave_exact_R1(r, t, P)      uses the default number of Talbot terms
%   th = ls_wave_exact_R1(r, t, P, M)   uses M Talbot terms
%
%   Returns theta(r,t) = T(r,t) - T_ref for the ONE-DIMENSIONAL radial problem
%
%       rho*c*( dtheta/dt + tau0*d2theta/dt2 ) = k*( d2theta/dr2 + (1/r) dtheta/dr )
%
%   on Ri < r < Ro, with
%       theta(Ri,t) = Delta*(1 - exp(-t/t0))     (t0 <= 0  ->  ideal step Delta)
%       k*dtheta/dr(Ro,t) + h_c*theta(Ro,t) = 0  (convection to ambient = T_ref)
%       theta(r,0) = 0,   dtheta/dt(r,0) = 0
%
%   This is exactly the equation the solver assembles for its energy row when
%   coupling_on = false and theory = 'LS' (the beta*T0 coupling term is the only
%   thing that couples temperature to u,w, so switching it off makes the thermal
%   field independent of the mechanics). With the ends insulated and a boundary
%   condition uniform in z, the solver's 2-D (r,z) field is z-independent and
%   must reproduce this 1-D solution.
%
%   METHOD.  In the Laplace domain the PDE becomes the modified Bessel equation
%       d2/dr2 + (1/r) d/dr - q^2 = 0,     q(s) = sqrt( (s + tau0*s^2)/alpha )
%   whose solution satisfying both boundary conditions is
%       Theta(r,s) = g(s) * [ Pp*K0(q r) - Qq*I0(q r) ]
%                         / [ Pp*K0(q Ri) - Qq*I0(q Ri) ]
%       Pp = k*q*I1(q Ro) + h_c*I0(q Ro)
%       Qq = -k*q*K1(q Ro) + h_c*K0(q Ro)
%       g(s) = Delta*(1/s - 1/(s + 1/t0))   (ramp)   or   Delta/s   (step)
%   The transform is inverted numerically with the fixed-Talbot algorithm
%   (Abate & Valko 2004), which is well suited to wave-like (hyperbolic)
%   responses. Everything except that inversion is closed form, so the result is
%   exact to the inversion tolerance -- verified by self-convergence in M and
%   against the analytic wave-front law (see ls_wave_benchmark_R1.m).
%
%   The Bessel evaluations use MATLAB's exponentially scaled forms and an
%   algebraically refactored ratio, so no intermediate overflows for large |q r|
%   (which is what happens at the large Laplace arguments Talbot needs).
%
%   P is a struct with fields: Ri, Ro, k, rho, c, tau0, h_c, Delta, t0
%   Derived quantities: alpha = k/(rho*c), wave speed C = sqrt(alpha/tau0).

if nargin < 4 || isempty(M), M = 48; end

r = r(:);
alpha = P.k/(P.rho*P.c);

if t <= 0
    th = zeros(size(r));
    return;
end

% ---- fixed-Talbot nodes (Abate & Valko) ----
rr = 2*M/(5*t);
kk = (1:M-1).';
tk = kk*pi/M;
ct = cot(tk);
sk = rr*tk.*(ct + 1i);                       % contour points
sg = tk + (tk.*ct - 1).*ct;                  % sigma_k
wk = exp(t*sk).*(1 + 1i*sg);                 % time kernel * (1+i sigma)

% ---- accumulate:  0.5*F(rr)*exp(rr*t)  +  sum_k F(s_k)*w_k ----
S = 0.5*exp(rr*t)*Ffun(rr, r, P, alpha);
for j = 1:numel(sk)
    S = S + wk(j)*Ffun(sk(j), r, P, alpha);
end
th = real((rr/M)*S);

end

% ========================================================================
function F = Ffun(s, r, P, alpha)
% Laplace-domain temperature Theta(r,s) at all radii r for one s.

% boundary-data transform g(s)
if P.t0 > 0
    g = P.Delta*(1/s - 1/(s + 1/P.t0));
else
    g = P.Delta/s;                                   % ideal step
end

q = sqrt((s + P.tau0*s^2)/alpha);
if real(q) < 0, q = -q; end                          % branch with Re(q) >= 0

zi = q*P.Ri;   zo = q*P.Ro;   zr = q*r;

% exponentially scaled Bessels:
%   besseli(n,z,1) = I_n(z)*exp(-|Re z|)  ->  here Re z >= 0, so factor exp(-Re z)
%   besselk(n,z,1) = K_n(z)*exp(+z)
I0s = @(z) besseli(0,z,1);   I1s = @(z) besseli(1,z,1);
K0s = @(z) besselk(0,z,1);   K1s = @(z) besselk(1,z,1);

Pt = P.k*q*I1s(zo) + P.h_c*I0s(zo);                  % Pp = exp(+Re zo)*Pt
Qt = -P.k*q*K1s(zo) + P.h_c*K0s(zo);                 % Qq = exp(-zo)  *Qt

% N(x) = Pp*K0(q x) - Qq*I0(q x)
%      = exp(Re zo - z_x) * [ Pt*K0s(z_x) - E(x)*Qt*I0s(z_x) ]
% with E(x) = exp( (z_x - zo) + (Re z_x - Re zo) ),  |E| <= 1 for x <= Ro.
Er = exp((zr - zo) + (real(zr) - real(zo)));
Ei = exp((zi - zo) + (real(zi) - real(zo)));

num = Pt*K0s(zr) - Er.*(Qt*I0s(zr));
den = Pt*K0s(zi) - Ei .*(Qt*I0s(zi));

% the leftover exponential prefactors cancel to exp(zi - zr), |.| <= 1 for r >= Ri
F = g*exp(zi - zr).*num/den;

end
