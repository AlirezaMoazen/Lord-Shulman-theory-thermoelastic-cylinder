---
title: "Exact Bessel-Series Solution of Transient Heat Conduction in a Hollow Cylinder — Full Equations and Step-by-Step Derivation"
subtitle: "Validation test 3 (Section 4-4-3) — author reference note"
lang: en-US
---

<!-- AUTHOR_CH4_SECTION_4_4_TEST3_BESSEL_DERIVATION_EN_R1 — English version of AUTHOR_CH4_SECTION_4_4_TEST3_BESSEL_DERIVATION_FA_R2. Author-only note (AUTHOR_ prefix), not part of the thesis.
     Code source: code/validation/LSTE_solver_R2_run_benchmark2.m. All numbers and identities were re-verified by an independent MATLAB run (2026-10-16). -->

# 0. Overview

**Problem.** Transient Fourier heat conduction in a homogeneous hollow cylinder, in the radial direction only. The inner surface temperature rises as an exponential ramp and the outer surface exchanges heat by convection.

**Idea.**

1. The inhomogeneous boundary condition is removed with a *unit steady profile* $\psi(r)$.
2. What remains is a problem that is homogeneous in space. It is expanded in **Bessel** eigenfunctions (combinations of $J_0$ and $Y_0$).
3. The amplitude of each mode obeys a first-order ordinary differential equation in time, which is solved exactly.

No spatial or temporal discretisation is involved. The only approximation is truncating the series to $N$ modes.

**Final result.** With $\beta = 1/t_0$ and $T = T_\infty + \theta$:

$$
\theta(r,t)=\theta_0\bigl(1-e^{-\beta t}\bigr)\,\psi(r)\;-\;\theta_0\sum_{n=1}^{N}c_n\,R_n(r)\,
\frac{\beta\bigl(e^{-\beta t}-e^{-\kappa\lambda_n^{2}t}\bigr)}{\kappa\lambda_n^{2}-\beta}
$$

# 1. Problem statement

## 1.1 Material, geometry and loading (test 4-4-3)

| Quantity | Value |
|---|---|
| Conductivity | $k = 50\ \mathrm{W/(m\,K)}$ |
| Density | $\rho = 8000\ \mathrm{kg/m^{3}}$ |
| Specific heat | $c = 500\ \mathrm{J/(kg\,K)}$ |
| Thermal diffusivity | $\kappa = k/(\rho c) = 1.25\times10^{-5}\ \mathrm{m^{2}/s}$ |
| Radii | $R_i = 0.08\ \mathrm{m}$, $R_o = 0.1\ \mathrm{m}$ |
| Outer convection | $h = 2000\ \mathrm{W/(m^{2}\,K)}$ |
| Biot number | $\mathrm{Bi} = h(R_o-R_i)/k = 0.8$ |
| Ramp amplitude and time constant | $\theta_0 = 200\ \mathrm{K}$, $t_0 = 5\ \mathrm{s}$ |
| Reference temperature | $T_\infty = 300\ \mathrm{K}$ |

## 1.2 Why the problem is one-dimensional

Both ends of the cylinder are insulated, the material is homogeneous, and the inner and outer boundary conditions do not depend on $z$. Hence the temperature field depends on $(r,t)$ only.

## 1.3 Governing equation and conditions

With $\theta = T - T_\infty$:

$$
\frac{\partial\theta}{\partial t}=\kappa\left(\frac{\partial^{2}\theta}{\partial r^{2}}+\frac1r\frac{\partial\theta}{\partial r}\right),\qquad R_i<r<R_o,\quad t>0
$$

$$
\theta(R_i,t)=f(t)\equiv\theta_0\bigl(1-e^{-\beta t}\bigr),\qquad
k\,\theta_r(R_o,t)+h\,\theta(R_o,t)=0,\qquad
\theta(r,0)=0 .
$$

The outer condition is a Robin (convective) condition: the conductive flux reaching the surface equals the convective flux leaving it, $-k\theta_r = h\theta$.

# 2. Step 1 — Removing the inhomogeneous boundary condition with the unit steady profile

Separation of variables needs *homogeneous* boundary conditions, but the inner condition $f(t)$ is inhomogeneous. Split the solution into two parts:

$$
\theta(r,t)=f(t)\,\psi(r)+v(r,t),
$$

where $\psi$ is the steady profile with unit inner temperature:

$$
\nabla^{2}\psi=0,\qquad \psi(R_i)=1,\qquad k\,\psi'(R_o)+h\,\psi(R_o)=0 .
$$

The general solution of $\psi''+\psi'/r=0$ is $\psi = a + b\ln r$. The inner condition gives $a = 1-b\ln R_i$, and the outer Robin condition gives

$$
\frac{k\,b}{R_o}+h\left(1+b\ln\frac{R_o}{R_i}\right)=0
\quad\Longrightarrow\quad
\boxed{\,b=-\frac{h}{k/R_o+h\ln(R_o/R_i)},\qquad a=1-b\ln R_i\,}
$$

**Numbers.** $b=-2.11352$, $a=-4.33819$, $\psi(R_o)=a+b\ln R_o=0.52838$. In the steady state the outer surface therefore receives 52.8 % of the inner amplitude, i.e. $T_o^{\infty}=300+200\times0.52838=405.68\ \mathrm{K}$.

**Two properties of $\psi$ used later.**

(a) $r\,\psi'(r)=b$ is constant, hence $(r\psi')'=0$.

(b) From the Robin condition, $b = R_o\,\psi'(R_o) = -R_o\,(h/k)\,\psi(R_o)$.

# 3. Step 2 — The remaining problem for $v$

Because $\nabla^{2}(f\psi)=0$, only the time-derivative term of $f\psi$ survives:

$$
v_t=\kappa\nabla^{2}v-f'(t)\,\psi(r),\qquad
v(R_i,t)=0,\qquad k\,v_r+h\,v=0\ \ (r=R_o),\qquad v(r,0)=0 .
$$

The initial condition of $v$ is zero because $f(0)=0$. This compatibility between the boundary and initial conditions is the reason for using an exponential ramp rather than a step. The source term is
$-f'(t)\psi(r)=-\theta_0\beta\,e^{-\beta t}\psi(r)$, a pure exponential in time.

# 4. Step 3 — Eigenfunctions: Bessel's equation

Expand the spatial part of $v$ in the eigenfunctions of $\nabla^{2}R+\lambda^{2}R=0$:

$$
R''+\frac1r R'+\lambda^{2}R=0
\quad\Longleftrightarrow\quad
\bigl(rR'\bigr)'+\lambda^{2}\,r\,R=0 .
$$

With $x=\lambda r$ this is **Bessel's equation of order zero**, with general solution $A\,J_0(\lambda r)+B\,Y_0(\lambda r)$. Since the domain excludes $r=0$, both functions are admissible. The inner Dirichlet condition $R(R_i)=0$ fixes the ratio $A:B$:

$$
\boxed{\,R_n(r)=J_0(\lambda_n r)\,Y_0(\lambda_n R_i)-Y_0(\lambda_n r)\,J_0(\lambda_n R_i)\,}
$$

Using $\dfrac{d}{dr}J_0(\lambda r)=-\lambda J_1(\lambda r)$ and the same rule for $Y_0$:

$$
R_n'(r)=-\lambda_n\Bigl[J_1(\lambda_n r)\,Y_0(\lambda_n R_i)-Y_1(\lambda_n r)\,J_0(\lambda_n R_i)\Bigr].
$$

# 5. Step 4 — The Robin condition gives the eigenvalue equation

Substituting into $k\,R'(R_o)+h\,R(R_o)=0$:

$$
\boxed{\,G(\lambda)=-k\lambda\Bigl[J_1(\lambda R_o)Y_0(\lambda R_i)-Y_1(\lambda R_o)J_0(\lambda R_i)\Bigr]
+h\Bigl[J_0(\lambda R_o)Y_0(\lambda R_i)-Y_0(\lambda R_o)J_0(\lambda R_i)\Bigr]=0\,}
$$

The positive roots $\lambda_1<\lambda_2<\cdots$ are the eigenvalues. For $k,h>0$ all $\lambda^{2}$ are real and positive; this follows from the self-adjointness of the problem and from the positivity of $\int r R'^{2}\,dr+\tfrac{h}{k}R_oR(R_o)^{2}$. The roots have no closed form and are found numerically.

**Structure of the roots.** For large $\lambda$ the Bessel functions behave like sines, and

$$
R_n\approx\frac{2}{\pi\lambda\sqrt{r R_i}}\,\sin\bigl(\lambda(R_i-r)\bigr),
$$

so the root spacing is approximately $\pi/(R_o-R_i)=157\ \mathrm{m^{-1}}$. Computed values:

| $n$ | 1 | 2 | 3 | 4 | 10 | 60 |
|---|---|---|---|---|---|---|
| $\lambda_n\ (\mathrm{m^{-1}})$ | 95.867 | 242.71 | 397.06 | 552.91 | 1493.4 | 9346.4 |
| $1/(\kappa\lambda_n^{2})\ (\mathrm{s})$ | 8.70 | 1.36 | 0.51 | — | — | — |

# 6. Step 5 — Orthogonality with weight $r$

For two eigenfunctions $R_m, R_n$, the relation $(rR')'=-\lambda^{2}rR$ gives

$$
(\lambda_m^{2}-\lambda_n^{2})\int_{R_i}^{R_o} r\,R_m R_n\,dr=\Bigl[r\bigl(R_mR_n'-R_nR_m'\bigr)\Bigr]_{R_i}^{R_o}.
$$

At $R_i$ both functions vanish. At $R_o$ the Robin condition $R'=-(h/k)R$ gives $R_mR_n'-R_nR_m'=-(h/k)(R_mR_n-R_nR_m)=0$. Therefore, for $\lambda_m\neq\lambda_n$,

$$
\int_{R_i}^{R_o}R_m(r)\,R_n(r)\,r\,dr=0 .
$$

(In MATLAB the normalised orthogonality for $n=1,2$ came out as $2.3\times10^{-16}$.) The norm is

$$
N_n=\int_{R_i}^{R_o}R_n^{2}\,r\,dr
=\frac{R_o^{2}}{2}\left[R_n(R_o)^{2}+\frac{R_n'(R_o)^{2}}{\lambda_n^{2}}\right]
-\frac{R_i^{2}}{2}\,\frac{R_n'(R_i)^{2}}{\lambda_n^{2}} ,
$$

which follows from Lommel's identity $\int r\,Z_0(\lambda r)^{2}dr=\tfrac{r^{2}}{2}\bigl[Z_0^{2}+Z_1^{2}\bigr]$ for any order-zero cylinder function $Z_0$, together with $R_n(R_i)=0$.

# 7. Step 6 — Expansion coefficients $c_n$

Expand $\psi$ in the basis $\{R_n\}$: $\psi=\sum_n c_n R_n$. By orthogonality,

$$
c_n=\frac{\displaystyle\int_{R_i}^{R_o}\psi\,R_n\,r\,dr}{\displaystyle\int_{R_i}^{R_o}R_n^{2}\,r\,dr}.
$$

The code evaluates both integrals numerically. **The numerator, however, has a closed form** (derived here and checked numerically).

Starting from $(rR_n')'=-\lambda_n^{2}rR_n$, integrating by parts twice and using $(r\psi')'=0$:

$$
\lambda_n^{2}\int_{R_i}^{R_o} r\,\psi R_n\,dr
=-\Bigl[r\psi R_n'\Bigr]_{R_i}^{R_o}+\Bigl[r\psi' R_n\Bigr]_{R_i}^{R_o}
=-\psi(R_o)R_oR_n'(R_o)+\psi(R_i)R_iR_n'(R_i)+b\,R_n(R_o).
$$

With the Robin condition $R_n'(R_o)=-(h/k)R_n(R_o)$ and property (b) of Section 2 ($b=-R_o(h/k)\psi(R_o)$), the first and third terms **cancel exactly**, leaving only $R_iR_n'(R_i)$. The Wronskian identity $J_1(x)Y_0(x)-J_0(x)Y_1(x)=\dfrac{2}{\pi x}$ gives $R_n'(R_i)=-\lambda_n\cdot\dfrac{2}{\pi\lambda_nR_i}=-\dfrac{2}{\pi R_i}$. Hence

$$
\boxed{\,\int_{R_i}^{R_o}\psi\,R_n\,r\,dr=-\frac{2}{\pi\lambda_n^{2}},\qquad
c_n=-\frac{2}{\pi\lambda_n^{2}\,N_n}\,}
$$

**Numerical check** ($\lambda_1,\dots,\lambda_4$). The closed form and the numerical integral agree to all printed digits (for $n=1$ both give $-6.926908\times10^{-5}$), and $N_n$ from the integral and from Lommel's formula agree (for $n=1$: $6.413852\times10^{-6}$). The coefficients are

$$
c_1,\dots,c_5=-10.800,\ -12.218,\ -12.432,\ -12.497,\ -12.524 .
$$

**Why $c_n$ does not decay with $n$.** For large $\lambda$, $N_n\approx\dfrac{2(R_o-R_i)}{\pi^{2}\lambda_n^{2}R_i}$, and therefore

$$
c_n\ \longrightarrow\ -\frac{\pi R_i}{R_o-R_i}=-12.566 .
$$

The reason is that $\psi(R_i)=1$ while every $R_n(R_i)=0$, so the expansion of $\psi$ converges non-uniformly (Gibbs-like) at the inner surface. In the final solution this is compensated by the time factor $1/\lambda_n^{2}$ (next step). It also helps that $\psi$ is multiplied by $f(t)$ outside the series and therefore satisfies the inner condition exactly; the series part $v$ vanishes at $R_i$ by construction.

# 8. Step 7 — Time equation of each mode (Duhamel)

Insert $v=\sum_n v_n(t)R_n(r)$ into the equation of Step 2. Since $\nabla^{2}R_n=-\lambda_n^{2}R_n$ and $\psi=\sum c_nR_n$, the coefficient of each $R_n$ must vanish separately:

$$
\dot v_n+\kappa\lambda_n^{2}\,v_n=-c_n\,f'(t)=-c_n\,\theta_0\beta\,e^{-\beta t},\qquad v_n(0)=0 .
$$

This is a linear first-order equation. With the integrating factor $e^{\kappa\lambda_n^{2}t}$ (Duhamel integral):

$$
v_n(t)=-c_n\theta_0\beta\int_0^{t}e^{-\beta s}\,e^{-\kappa\lambda_n^{2}(t-s)}\,ds
=-c_n\,\theta_0\,\frac{\beta\bigl(e^{-\beta t}-e^{-\kappa\lambda_n^{2}t}\bigr)}{\kappa\lambda_n^{2}-\beta}.
$$

**Technical remark.** If $\kappa\lambda_n^{2}=\beta$ the denominator vanishes, but the singularity is removable (the limit is $t\,e^{-\beta t}$). For $\beta=0.2\ \mathrm{s^{-1}}$ this happens at $\lambda=\sqrt{\beta/\kappa}=126.5\ \mathrm{m^{-1}}$, which lies between $\lambda_1=95.87$ and $\lambda_2=242.7$ and is not an eigenvalue. So it never occurs in this test; it may come close if $t_0$ is changed.

# 9. Step 8 — Final solution

$$
\boxed{\;\theta(r,t)=\theta_0\bigl(1-e^{-\beta t}\bigr)\psi(r)\;-\;\theta_0\sum_{n=1}^{\infty}c_n\,R_n(r)\,
\frac{\beta\bigl(e^{-\beta t}-e^{-\kappa\lambda_n^{2}t}\bigr)}{\kappa\lambda_n^{2}-\beta}\;}
$$

with $\psi=a+b\ln r$, $R_n$ from Step 3, $\lambda_n$ the roots of $G=0$, and $c_n=-2/(\pi\lambda_n^{2}N_n)$.

**Limiting behaviour (for physical insight).**

- $t\to\infty$: all exponentials decay and $\theta\to\theta_0\psi(r)$, the steady logarithmic profile.
- $t\to 0$: $f\psi\to 0$ and the series vanishes, so the initial condition holds (check: $\theta(0.09,0)=0$ exactly).
- Higher modes die quickly ($e^{-\kappa\lambda_n^{2}t}$ with $\lambda_n\propto n$). At $t=40\ \mathrm{s}$ only the first mode remains (time constant 8.7 s, i.e. $e^{-4.6}=1\,\%$).
- Convergence of the series: term $n$ behaves like $c_n\,|R_n|\,\beta/(\kappa\lambda_n^{2})$ with $|R_n|\lesssim 2/(\pi\lambda_n\sqrt{rR_i})$, that is $O(\lambda_n^{-3})\sim O(n^{-3})$, so the series converges absolutely.

# 10. Step 9 — Numerical evaluation

1. **Root finding.** $G(\lambda)$ is sampled on the grid $\lambda\in[1,\,4\times10^{4}]$ with 400 000 points (step $\approx 0.1$); sign changes are located and each bracket is refined with a root finder (`fzero`). Because the root spacing is about 157, a 0.1 grid cannot miss a root.
2. **Number of modes:** $N=60$ ($\lambda_{60}=9346$).
3. **Coefficients:** either numerical integration (relative tolerance $10^{-10}$) or the closed form of Section 7; the two agree.
4. **Evaluation:** a vectorised sum over modes.

**Convergence with the number of modes** at $r=0.09\ \mathrm{m}$ (temperature $T$ in kelvin):

| $t$ (s) | 5 modes | 10 modes | 20 modes | **60 modes** | 200 modes |
|---|---|---|---|---|---|
| 2 | 303.9610 | 303.8618 | 303.9019 | **303.8976** | 303.8974 |
| 10 | 368.9965 | 368.9764 | 368.9845 | **368.9836** | 368.9836 |
| 40 | 446.98543 | 446.98538 | 446.98540 | **446.98540** | 446.98540 |

The truncation error at 60 modes is about $1.7\times10^{-4}\ \mathrm{K}$ at 2 s, $3\times10^{-5}\ \mathrm{K}$ at 10 s and $\sim10^{-8}\ \mathrm{K}$ at 40 s. That is about 3 % of the solver error ($5.7\times10^{-3}\ \mathrm{K}$ at 2 s).

# 11. Verification of the solution itself (independent run)

Temperatures $T$ at three radii (kelvin):

| $t$ (s) | $T(R_i)$ | $T(0.09)$ | $T(R_o)$ |
|---|---|---|---|
| 2 | 365.936 | 303.8976 | 300.098 |
| 10 | 472.933 | 368.9836 | 330.220 |
| 40 | 499.933 | 446.9854 | 402.198 |
| steady state | 500 | — | 405.68 |

- **Differential equation** at $r=0.09\ \mathrm{m}$, $t=10\ \mathrm{s}$, with fine central differences: $\theta_t=7.473$ versus $\kappa(\theta_{rr}+\theta_r/r)=7.435$. The 0.5 % difference is within the noise of second-order finite differences with step $10^{-5}$ plus series truncation.
- **Robin condition** at $R_o$ ($t=10\ \mathrm{s}$): $k\theta_r=-60555$ and $h\theta=60441$ (sum about 0.2 % of either term; the derivative is a one-sided first-order difference).
- **Initial condition:** $\theta(0.09,0)=0$ exactly. **Inner condition:** $\theta(R_i,t)=f(t)$ exactly, because $R_n(R_i)=0$.
- **Orthogonality** ($n=1,2$): $2.3\times10^{-16}$. **Coefficients and norm:** closed form equals numerical integral; $R_n'(R_i)=-7.95775=-2/(\pi R_i)$.

# 12. Map to the variables in the code

The code is `LSTE_solver_R2_run_benchmark2.m`.

| Mathematics | Name in the code |
|---|---|
| $\kappa$ | `kappa` |
| $\beta = 1/t_0$ | `bD = 1/t0r` |
| $b,\ a,\ \psi$ | `b_c`, `a_c`, `psi` |
| $R_n(r)$ | `Rfun(l,r)` |
| $G(\lambda)$ | `geig(l)` |
| $\lambda_n$ | `lam` (60 modes) |
| $c_n$ | `cn` (numerical integrals of numerator and denominator) |
| $\theta(r,t)$ | `theta_exact(r,t)` |

# 13. Eight-line summary for an appendix or a slide

1. $\theta_t=\kappa(\theta_{rr}+\theta_r/r)$; $\ \theta(R_i)=\theta_0(1-e^{-\beta t})$, $\ k\theta_r+h\theta=0$ at $R_o$, $\ \theta(0)=0$.
2. $\theta=f(t)\psi(r)+v$ with $\psi=a+b\ln r$ (unit steady profile).
3. $v_t=\kappa\nabla^{2}v-f'\psi$ with homogeneous boundary conditions.
4. Eigenfunctions: $R_n=J_0(\lambda_nr)Y_0(\lambda_nR_i)-Y_0(\lambda_nr)J_0(\lambda_nR_i)$.
5. Eigenvalues from the Robin condition: $G(\lambda_n)=0$.
6. Orthogonality with weight $r$; $\ c_n=-2/(\pi\lambda_n^{2}N_n)$.
7. $\dot v_n+\kappa\lambda_n^{2}v_n=-c_nf'$ $\Rightarrow$ $v_n=-c_n\theta_0\beta\,(e^{-\beta t}-e^{-\kappa\lambda_n^{2}t})/(\kappa\lambda_n^{2}-\beta)$.
8. $\theta=f\psi+\sum_n v_nR_n$; with 60 modes the truncation error is $\le 2\times10^{-4}\ \mathrm{K}$.

# 14. Likely questions from the jury

- **"Why is this solution exact?"** It involves no spatial or temporal discretisation; the only approximation is truncating the series (error $\le 2\times10^{-4}\ \mathrm{K}$ with 60 modes, table in Section 10). Its correctness was checked by confirming that it satisfies the equation, the boundary conditions and the initial condition (Section 11).
- **"Why do the coefficients $c_n$ not decay?"** Because $\psi(R_i)=1$ whereas $R_n(R_i)=0$; the limit is $c_n\to-\pi R_i/(R_o-R_i)$. The time factor $1/\lambda_n^{2}$ nevertheless makes the final series absolutely convergent.
- **"Why an exponential ramp rather than a step?"** Compatibility with the initial condition and better convergence. It is also the same type of load as the main problem ($T_{in}=300+300(1-e^{-t/2})$).
- **"Does this solution also cover Lord–Shulman?"** No, it is for Fourier conduction. For the Lord–Shulman wave, the time problem of each mode becomes a damped (second-order) oscillator, which is solved analytically in `ls_wave_exact_R2.m`.
