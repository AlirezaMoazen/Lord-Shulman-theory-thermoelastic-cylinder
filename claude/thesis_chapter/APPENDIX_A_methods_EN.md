# Appendix A. The Newmark time-integration method and the comparison methods

This appendix describes the Newmark time-integration scheme used for all
transient solutions of this thesis, and briefly the alternative time-integration
and spatial-discretization methods used in the method-comparison studies of
Chapter 4 (Sections 4-18 to 4-19).

## A.1 The semi-discrete system

After the layerwise differential-quadrature (DQM) discretization in the $(r,z)$
plane described in Chapter 3, the coupled Lord-Shulman thermoelastic problem is
reduced to a system of ordinary differential equations in time for the vector of
nodal unknowns

$$ \mathbf{x} = \begin{bmatrix} \boldsymbol{\theta} \\ \mathbf{u} \\ \mathbf{w} \end{bmatrix}, $$

where $\boldsymbol{\theta}$, $\mathbf{u}$ and $\mathbf{w}$ collect the nodal
temperature increment $\theta = T - T_\infty$ and the radial and axial
displacements at all $(r,z)$ grid points of all layers. The semi-discrete system
is written in the unified second-order form

$$ \mathbf{M}\,\ddot{\mathbf{x}} + \mathbf{C}\,\dot{\mathbf{x}} + \mathbf{K}\,\mathbf{x} = \mathbf{F}(t). $$

The three matrices are assembled directly from the governing equations:

- **Mechanical rows** ($\mathbf{u},\mathbf{w}$): the momentum equations
  $\rho\ddot{u} - (\mathcal{L}\mathbf{u})_r + \bar{\beta}\,\partial_r\theta = 0$
  are second order in time, so they contribute $\rho$ to $\mathbf{M}$, nothing to
  $\mathbf{C}$ (elastodynamics is undamped), and the elastic operator together
  with the thermoelastic coupling $\bar{\beta}\,\partial\theta$ to $\mathbf{K}$.
- **Thermal rows** ($\boldsymbol{\theta}$) under Lord-Shulman: the energy
  equation
  $\rho c(\dot{\theta} + \tau_0\ddot{\theta}) + \bar{\beta}T_0(\dot{e} + \tau_0\ddot{e}) - \nabla\!\cdot(k\nabla\theta) = 0$
  contributes $\rho c\,\tau_0$ (and the coupling $\bar{\beta}T_0\tau_0\,e$) to
  $\mathbf{M}$, $\rho c$ (and $\bar{\beta}T_0\,e$) to $\mathbf{C}$, and the
  conduction operator $-\nabla\!\cdot(k\nabla\,\cdot)$ to $\mathbf{K}$.

Here $e = \nabla\!\cdot\mathbf{u}$ is the dilatation, $\tau_0$ the relaxation
time, $\bar\beta = \bar\alpha(3\bar\lambda + 2\bar\mu)$ the thermal modulus of
the homogenized material, and $T_0$ the reference temperature. The relaxation
term $\tau_0\ddot\theta$ is exactly what makes the thermal rows carry a mass
term and turns the parabolic Fourier system into the hyperbolic (wave-type)
Lord-Shulman system. Setting $\tau_0 = 0$ recovers the classical coupled Fourier
model, in which the thermal rows have no mass term.

## A.2 The Newmark scheme

The system is advanced in time with the Newmark $\beta$ family. Given the state
$(\mathbf{x}_n,\dot{\mathbf{x}}_n,\ddot{\mathbf{x}}_n)$ at time $t_n$, the state
at $t_{n+1} = t_n + \Delta t$ is defined by the two Newmark approximations

$$ \mathbf{x}_{n+1} = \mathbf{x}_n + \Delta t\,\dot{\mathbf{x}}_n + \frac{\Delta t^2}{2}\Big[(1-2\beta)\,\ddot{\mathbf{x}}_n + 2\beta\,\ddot{\mathbf{x}}_{n+1}\Big], $$

$$ \dot{\mathbf{x}}_{n+1} = \dot{\mathbf{x}}_n + \Delta t\Big[(1-\gamma)\,\ddot{\mathbf{x}}_n + \gamma\,\ddot{\mathbf{x}}_{n+1}\Big]. $$

Substituting these into the equation of motion at $t_{n+1}$ and eliminating
$\dot{\mathbf{x}}_{n+1}$ and $\ddot{\mathbf{x}}_{n+1}$ gives a single linear
system for $\mathbf{x}_{n+1}$ (the *displacement form* of the Newmark method):

$$ \mathbf{K}_{\mathrm{eff}}\,\mathbf{x}_{n+1} = \mathbf{F}_{n+1} + \mathbf{M}\big(a_0\mathbf{x}_n + a_2\dot{\mathbf{x}}_n + a_3\ddot{\mathbf{x}}_n\big) + \mathbf{C}\big(a_1\mathbf{x}_n + a_4\dot{\mathbf{x}}_n + a_5\ddot{\mathbf{x}}_n\big), $$

with the effective stiffness matrix

$$ \mathbf{K}_{\mathrm{eff}} = \mathbf{K} + a_0\mathbf{M} + a_1\mathbf{C}, $$

and the integration constants

$$ a_0 = \frac{1}{\beta\,\Delta t^2},\quad a_1 = \frac{\gamma}{\beta\,\Delta t},\quad a_2 = \frac{1}{\beta\,\Delta t},\quad a_3 = \frac{1}{2\beta} - 1, $$

$$ a_4 = \frac{\gamma}{\beta} - 1,\quad a_5 = \frac{\Delta t}{2}\!\left(\frac{\gamma}{\beta} - 2\right),\quad a_6 = \Delta t\,(1-\gamma),\quad a_7 = \Delta t\,\gamma. $$

Once $\mathbf{x}_{n+1}$ is obtained, the acceleration and velocity are updated by

$$ \ddot{\mathbf{x}}_{n+1} = a_0\big(\mathbf{x}_{n+1} - \mathbf{x}_n\big) - a_2\dot{\mathbf{x}}_n - a_3\ddot{\mathbf{x}}_n, $$

$$ \dot{\mathbf{x}}_{n+1} = \dot{\mathbf{x}}_n + a_6\,\ddot{\mathbf{x}}_n + a_7\,\ddot{\mathbf{x}}_{n+1}. $$

### Choice of parameters

Throughout this thesis the parameters are set to $\gamma = \tfrac{1}{2}$ and
$\beta = \tfrac{1}{4}$, which correspond to the constant-average-acceleration
(trapezoidal) rule. This choice is:

- **unconditionally stable** for the linear system, so the time step $\Delta t$
  is limited only by accuracy, not by stability;
- **second-order accurate** in time; and
- **free of algorithmic (numerical) damping**, because $\gamma = \tfrac{1}{2}$.

The absence of numerical damping is deliberate: the mild oscillations visible
behind the sharp thermal wave fronts in the results of Chapter 4 are the
genuine Gibbs oscillations of the spectral (DQM) spatial discretization, and are
reported without artificial smoothing so that the physical wave response is not
masked. A value $\gamma > \tfrac{1}{2}$ would add numerical dissipation that
damps these oscillations but also artificially attenuates the physical thermal
wave; it is therefore avoided here. (The symbol $\gamma$ used for the percolation
exponent of the conductivity model in Chapter 3 is unrelated to the Newmark
$\gamma$; to avoid confusion the Newmark parameter is written $\delta$ in the
main text and $\gamma$ only within this appendix.)

### Computational remarks

Because $\mathbf{K}_{\mathrm{eff}}$ is constant for a fixed time step (the
problem is linear), it is factorized **once** by an LU decomposition before the
time loop, and each step reuses the factors in forward/backward substitution;
only the right-hand side is rebuilt each step. Before factorization every
equation row is **equilibrated** — divided by its largest coefficient — so that
the thermal rows (of magnitude $\sim 10^{3}$), the mechanical rows ($\sim
10^{13}$) and the constraint rows ($\sim 1$) attain comparable magnitudes; this
row scaling reduces the condition number of $\mathbf{K}_{\mathrm{eff}}$ by many
orders of magnitude and is essential for an accurate solution of the strongly
heterogeneous coupled system. The reference solution uses $\Delta t$ small
enough that the time-discretization error lies below the spatial error floor, as
verified by the convergence study of Section 4-3.

## A.3 The comparison methods

To position the Newmark scheme and the DQM spatial discretization, several
alternative methods were implemented on identical benchmark problems; their
results are reported in Chapter 4 and summarized here.

### A.3.1 Alternative time integrators (Section 4-18, Table 4-3)

Five alternative time integrators were run on the same spatial system and the
same transient-conduction benchmark (with a known exact solution):

- **Wilson-$\theta$** ($\theta = 1.4$): an implicit scheme that evaluates the
  equilibrium at $t_n + \theta\Delta t$; unconditionally stable but with extra
  numerical dissipation, giving a roughly fivefold larger error than Newmark at
  equal step.
- **Houbolt**: a backward multi-step scheme built from a cubic backward
  difference; comparable accuracy to Newmark but with strong high-frequency
  damping.
- **HHT-$\alpha$** ($\alpha = -0.1$): the Hilber-Hughes-Taylor generalization of
  Newmark that introduces controlled high-frequency damping while retaining
  second-order accuracy; practically as accurate as Newmark here.
- **ode15s**: MATLAB's adaptive, variable-step/variable-order stiff solver
  (default NDF — a modified form of the backward differentiation formulas
  BDF; the `'BDF'` option was not explicitly enabled), used as an
  independent reference on a statically-condensed version of the system
  (boundary-condition constraint rows eliminated algebraically, then
  recast as a first-order state-space form with an analytic Jacobian);
  about ten times more accurate but about eight times more expensive than
  Newmark.
- **Laplace-Durbin**: a Laplace-transform-in-time method with Durbin's numerical
  inversion, applicable only to the **thermal subsystem**. It is three orders of
  magnitude slower and, importantly, **cannot be applied to the full coupled
  system**, because the undamped elastic poles of the coupled operator lie
  exactly on the Bromwich inversion contour — which is precisely why transform
  methods appear in the literature only for uncoupled thermal problems.

Newmark, Houbolt and HHT-$\alpha$ are practically equally accurate at equal step;
Newmark offers the best overall accuracy-to-cost ratio and was therefore adopted
for all production runs.

### A.3.2 Alternative spatial discretizations (Section 4-19, Figure 4-2)

Four spatial discretizations were compared on the transient-conduction benchmark
with the same Newmark time march:

- **Layerwise differential quadrature (DQM)** with Chebyshev-Gauss-Lobatto and
  with uniform grids: the temperature/displacement derivatives at each node are
  written as weighted sums of all nodal values along a line, giving a spectral
  (quasi-exponential) convergence rate.
- **Second-order finite differences (FDM)**: standard central differences.
- **Finite elements (FEM)**, Galerkin formulation with consistent capacitance
  and conductance matrices, using **linear (2-node)** and **quadratic (3-node)**
  Lagrange elements. Because the transient-conduction operator is self-adjoint
  (no convection), the standard Bubnov-Galerkin method (test = trial functions)
  is optimal and Petrov-Galerkin weighting is not needed.

The number of radial points required to reach the time-step error floor is
$N \approx 9\text{-}11$ for DQM, $N \approx 21$ for quadratic FEM, and
$N \approx 161$ for linear FEM and second-order FDM. At equal accuracy the DQM
equation system is therefore about fifteen times smaller per direction — squared
in the $(r,z)$ plane — which is the quantitative justification for the layerwise
differential-quadrature choice adopted throughout this thesis.
