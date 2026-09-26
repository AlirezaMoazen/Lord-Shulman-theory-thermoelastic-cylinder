---
dir: ltr
lang: en
---

# Spatial and temporal discretization of coupled generalized thermoelasticity: a measured comparison and an exact second-sound benchmark for layered cylinders

**Authors.** *[Author 1]*ᵃ, *[Supervisor 1]*ᵃ, *[Supervisor 2]*ᵃ
ᵃ Department of Mechanical Engineering, Persian Gulf University, Bushehr, Iran

> *Author order to be settled with the supervisors. Add the thesis-derivation footnote.*
> *Cite Paper 1 for the formulation.*

**Target journal.** *Applied Mathematical Modelling* (alternates: *Computers & Structures*,
*Engineering with Computers*)

---

## Abstract

Coupled generalized thermoelasticity produces a stiff, strongly heterogeneous system in
which a hyperbolic thermal wave is carried alongside an essentially undamped elastic field,
and the numerical choices made in solving it are usually asserted rather than measured.
This paper reports a like-for-like comparison of five spatial discretizations and six time
integrators on identical problems with known exact solutions, together with an exact
benchmark that other second-sound codes can reuse. Differential quadrature on a Chebyshev
grid reaches the temporal error floor at roughly 9–11 points per direction, where quadratic
finite elements need about 21 and both linear finite elements and second-order finite
differences need about 161 — a fifteen-fold reduction per direction, squared in the plane.
The same study exposes a limitation rarely emphasized: the differential quadrature error
does not continue to fall but degrades and eventually breaks down under further refinement,
catastrophically so on a uniform grid, so the method has a usable window rather than a
convergence curve. Among the time integrators, Newmark, Houbolt and HHT-α are of
equal accuracy at equal step, Wilson-θ pays a five-fold error penalty for its added
dissipation, and the adaptive stiff solver buys one decimal digit at eight times the cost.
The Laplace-transform route is shown to fail *structurally* on the fully coupled system,
not merely to converge slowly: the undamped elastic poles of the coupled operator lie on the
Bromwich inversion contour, so the numerical inversion is poisoned by near-singular solves —
which explains why transform methods appear in this literature only when applied to the
thermal subsystem. Finally, an exact Fourier–Bessel eigenfunction solution for the
Lord–Shulman wave in a hollow cylinder is derived and independently verified (steady limit
to 1.9 × 10⁻¹⁶, hyperbolic causality to 4 × 10⁻⁶, front-jump ray law to 0.16 %), then used
to measure a layerwise differential quadrature solver at 0.32 % pointwise error.

**Keywords.** Generalized thermoelasticity; differential quadrature; time integration;
Laplace inversion; second sound; benchmark solution

---

## 1. Introduction

*[Target ≈ 900 words.]*

**Paragraph 1 — what makes this system hard.** Coupled hyperbolic thermoelasticity carries
two very different physical timescales in one system: a thermal wave that is damped and
relatively slow, and an elastic field that is fast and essentially undamped. Spatial
discretization produces a stiff ordinary differential system whose eigenvalue spectrum
spans many orders of magnitude, and the boundary and interface conditions enter as
algebraic constraints, so the semi-discrete problem is a differential-algebraic system
rather than a pure ODE. Row scales differ by ten orders of magnitude between the thermal,
mechanical and constraint equations.

**Paragraph 2 — what the literature does.** Differential quadrature is widely used for this
class of problem and is routinely asserted to be more efficient than finite elements or
finite differences, usually without a controlled measurement on the same problem with the
same time march. Newmark is the default integrator, again largely by convention. Laplace
transform methods appear regularly, but — a point this paper takes up — essentially always
applied to the thermal subsystem alone.

**Paragraph 3 — verification practice.** Second-sound codes are frequently verified
qualitatively, by observing that a front appears and moves at about the right speed. Exact
references for the hyperbolic problem in a hollow cylinder are not readily available, and
digitizing figures from earlier papers is the common substitute.

**Paragraph 4 — contribution.**

1. A controlled comparison of five spatial discretizations on an identical problem with an
   exact solution and an identical time march, reporting the node count each needs to reach
   the temporal error floor.
2. The observation that differential quadrature has a usable window rather than a
   monotone convergence curve, with measured breakdown on both Chebyshev and uniform grids.
3. A comparison of six time integrators on the same system, including cost.
4. A structural — not merely practical — explanation of why the Laplace route fails on the
   fully coupled operator, supported by two independent measured failures.
5. An exact, independently verified Fourier–Bessel benchmark for the Lord–Shulman wave in a
   hollow cylinder, offered for reuse.

---

## 2. Model problem and semi-discrete system

Cite Paper 1 for the physical formulation; state here only what the numerical study needs.

The semi-discrete system is
$$\mathbf{M}\ddot{\mathbf{x}} + \mathbf{C}\dot{\mathbf{x}} + \mathbf{K}\mathbf{x} = \mathbf{F}(t)$$
with $\mathbf{x}$ collecting nodal temperatures and the two displacement components. Rows
arising from boundary and interface conditions are algebraic, with zero mass and damping
entries, so the system is an index-1 differential-algebraic one. The thermal rows scale as
$\sim 10^3$, the mechanical rows as $\sim 10^{13}$ and the constraint rows as $\sim 1$;
each row is therefore equilibrated by its largest coefficient before factorization, which
reduces the condition number of the effective matrix by several orders of magnitude and is
a precondition for any of the comparisons that follow being meaningful.

*[Figure 1: node layout and DOF numbering — `figures_ch123/DQM_nodes_schematic.png`.]*

---

## 3. An exact benchmark for the Lord–Shulman wave

### 3.1 Construction

The benchmark is constructed so that it can be compared against the *same* solver
configuration rather than against an idealized separate problem. Disabling the coupling
term removes the only temperature-to-displacement feedback, so the energy row becomes
exactly
$$ \rho c\,(\dot{\theta} + \tau_0\ddot{\theta}) = k\left(\theta_{,rr} + \theta_{,r}/r\right) $$
Taking constant layer properties and an axially uniform inner boundary condition with
insulated ends reduces the two-dimensional field to a one-dimensional radial problem.

That problem is solved in closed form by a Fourier–Bessel eigenfunction expansion. The
time-dependent Dirichlet datum is lifted with the steady profile $\varphi = a + b\ln r$,
which satisfies $\nabla^2\varphi = 0$ exactly, and each modal amplitude then obeys a damped
oscillator equation with exponential forcing that is solved **analytically**. There is
consequently no time discretization anywhere in the reference and no numerical transform
inversion; the only truncation is the number of retained modes.

### 3.2 Verification of the reference itself

A reference is only useful if it has been checked independently of the code it will be used
to judge. Four checks were applied:

| check | result |
|---|---|
| Steady-state limit | 1.9 × 10⁻¹⁶ of ΔT |
| Strict hyperbolic causality (field ahead of the front) | 4 × 10⁻⁶ of ΔT |
| Front-jump ratios against the analytic ray law $\Delta\cdot\sqrt{R_i/r}\,e^{-(r-R_i)/2C\tau_0}$ | 0.16 % |
| Fourier limit $\tau_0 \to 0$ against an independent Crank–Nicolson solve | agreement |
| Self-convergence at 400 modes | 8 × 10⁻⁴ relative |

### 3.3 Measured solver accuracy

Against this reference the layerwise differential quadrature solver attains a maximum
pointwise error of 0.32 % of ΔT and an L₂ error of 0.065 % on the finest mesh at the final
time, with errors falling monotonically under refinement (L∞ 1.34 % → 0.32 %, L₂ 0.49 % →
0.065 % for 49 → 147 radial points). The measured front position tracks the exact front to
within one grid spacing at every snapshot. The premise of the comparison is verified in-run:
the solver's two-dimensional field is axially uniform to 3.9 × 10⁻¹¹ of ΔT, confirming that
it really did collapse to the one-dimensional problem being compared against.

A by-product worth stating explicitly: the monotone convergence establishes that the
oscillations trailing a sharp second-sound front in spectral discretizations of this problem
are a Gibbs artefact, not a physical or numerical instability. This is often asserted; here
it is measured.

*[Figure 2: `figures_validation/ls_wave_validation_R1.png`. Table: the mesh-convergence and
time-error data, available as `thesis_chapter/ls_wave_mesh_convergence_R1.csv` and
`ls_wave_time_errors_R1.csv`.]*

---

## 4. Spatial discretizations compared

Five discretizations are run on the transient-conduction problem with the exact
Bessel-series solution, using an identical Newmark march so that the temporal error is
common to all of them.

| method | nodes to reach the temporal floor |
|---|---|
| Differential quadrature, Chebyshev grid | ≈ 9–11 |
| Differential quadrature, uniform grid | ≈ 11 |
| Finite elements, quadratic (3-node) | ≈ 21 |
| Finite elements, linear (2-node) | ≈ 161 |
| Finite differences, second order | ≈ 161 |

The linear-FEM and FDM curves lie on the slope −2 reference line, confirming second-order
convergence; quadratic FEM gains roughly one order of magnitude per refinement step; the
differential quadrature error falls quasi-exponentially until it meets the temporal floor.
At equal accuracy the DQM system is therefore about fifteen times smaller per direction, and
that ratio is squared in the $(r,z)$ plane — the quantitative justification for the
layerwise DQM choice, and consistent with the mesh study in which a handful of radial points
already delivered three-digit accuracy.

The finite-element comparison uses a standard Bubnov–Galerkin weighted-residual formulation
with the cylindrical weight $r$ in the weak form, C⁰ Lagrange elements, consistent
capacitance matrices, natural Robin boundary conditions and essential Dirichlet conditions.
Because the transient conduction operator is self-adjoint — there is no convection term —
Bubnov–Galerkin is optimal in the best-approximation sense and no Petrov–Galerkin upwinding
is required; this is worth stating because referees in this area routinely ask.

### 4.1 Differential quadrature has a window, not a curve

The most practically useful finding of this section is a negative one. The DQM error does
not keep falling. On the Chebyshev grid it flattens after $N \approx 11$, drifts slightly
upward through $N \approx 21$–121, and the solution then fails outright at $N \approx 161$.
On the uniform grid the degradation is violent: the error is competitive at
$N = 11$–31 and then diverges by tens of orders of magnitude by $N = 41$.

The mechanism is the well-known ill-conditioning of the differential quadrature weighting
matrices, whose condition number grows rapidly with the number of nodes; on a uniform grid
it grows faster still. The practical consequence is that DQM must be used inside a window
whose upper edge should be located before production runs, and that the usual habit of
"refine until the answer stops changing" is *unsafe* here — refinement past the window
degrades the answer silently before it fails loudly. Since the method's whole advantage is
that it needs few nodes, this is not a serious restriction, but it does need to be stated.

*[Figure 3: `results_extensions/figures/spatial_convergence` — log-log error against N for
all five methods with the slope −2 reference line.]*

### 4.2 The binding direction

A companion study varying $N_r$, $N_z$ and $N_L$ independently about a fixed anchor shows
that the **axial** direction is the binding one: $N_z = 5$ still carries a 9.4 % error in
the hoop-stress profile, crossing below 1 % only by $N_z = 7$–9, while $N_r$ and $N_L$ are
already within a few tenths of a percent at their coarsest tested values. Effort in this
class of problem is conventionally spent on radial refinement; this result says it is
better spent axially.

### 4.3 A caution on end conditions

Not all mechanically admissible end conditions are numerically admissible in this
discretization. With simply supported or clamped ends the solution is stable. With free or
roller ends it diverges — isolation tests confirm the cause is spurious mechanical end modes
arising from the absence of kinematic anchoring of the displacement field at the axial
boundaries, and that the divergence is independent of the Newmark parameters and of the
thermomechanical coupling. The practical rule is that the $u$-field requires kinematic
anchoring at the axial ends in a layerwise DQM formulation of this problem; one-dimensional
radial problems avoid the issue entirely.

---

## 5. Time integrators compared

Six schemes on the identical spatial system, measured against the exact solution.

| method | max error (K) | CPU (s) |
|---|---|---|
| Newmark (δ = ½, β = ¼) | 0.0032 | 0.33 |
| Wilson-θ (θ = 1.4) | 0.0164 | 0.19 |
| Houbolt | 0.0025 | 0.24 |
| HHT-α (α = −0.1) | 0.0033 | 0.29 |
| Adaptive stiff solver (NDF/BDF) | 0.00026 | 2.57 |
| Laplace–Durbin (thermal subsystem only) | 0.137 | 193 |

Newmark, Houbolt and HHT-α are of practically equal accuracy at equal step. Wilson-θ is the
cheapest but accepts a roughly five-fold error for its additional numerical dissipation. The
adaptive stiff solver is an order of magnitude more accurate but roughly eight times more
expensive, and it is worth noting what it required: because the semi-discrete system is a
differential-algebraic one, the constraint rows had to be eliminated by static condensation
and the remaining second-order system recast in first-order state-space form before the
solver could be applied at all, with an analytic Jacobian supplied to keep the cost down.
The default formula in that solver is the modified NDF family rather than classical BDF,
which is worth stating precisely since the distinction is routinely blurred in the applied
literature.

Newmark's combination of accuracy, cost and implementation simplicity justifies it as the
production choice — a conclusion that is unsurprising but that, as far as the authors are
aware, has not previously been *measured* for this class of problem.

---

## 6. Why the Laplace route fails on the coupled system

The Laplace-transform method with numerical inversion is the slowest entry in the table, but
its real interest is that its failure is structural rather than one of efficiency.

**The obstruction.** Numerical inversion evaluates the transformed solution along a contour
in the complex plane. For the thermal subsystem alone the conduction poles lie on the
negative real axis, comfortably away from any sensible contour, and the inversion is
well behaved — merely expensive. For the *fully coupled* system the operator additionally
carries the elastic poles, and those are undamped: they lie on the imaginary axis, which is
exactly where the Durbin contour samples. Every contour evaluation is then a near-singular
solve, and the alternating sum that reconstructs the time-domain solution is poisoned by the
resulting cancellation. No refinement of the inversion parameters repairs this, because the
difficulty is in the location of the spectrum, not in the quadrature.

This provides the explanation, usually left implicit, for why transform methods in the
generalized-thermoelasticity literature are applied to thermal subproblems and not to fully
coupled ones.

**Two measured failures support the diagnosis.** A fixed-Talbot inversion applied to the
wave problem produced errors that *grew* with the number of nodes — 3.2 × 10¹, 8.6 × 10²,
4.2 × 10⁸ K — because the transformed field behaves as a pure delay, $\sim e^{-s\Delta r/C}/s$,
and Talbot's node radius grows as $e^{2M/5}$, amplifying exactly the cancellation that a
pure delay produces. This is why the modal route of §3 was needed for the benchmark.

**An arithmetic caution worth recording.** In implementing the Durbin inversion, the
half-period node spacing $s_k = a + ik\pi/T$ with $T = t_{end}$ and prefactor
$(1/T)e^{at}\left[\tfrac{1}{2}F(a) + \sum\right]$, with $a = 7/(2T)$, is required. Using
full-period spacing instead yields a result that is uniformly and exactly twice the correct
one — a discrepancy that is easy to mistake for a modelling error and that was isolated here
by testing against an analytically invertible transform. Early times shorter than
$T_{per}/(2N)$ are unresolvable in any case.

---

## 7. Conclusions

1. Differential quadrature reaches the temporal error floor at roughly 9–11 nodes per
   direction against approximately 161 for linear finite elements and second-order finite
   differences and 21 for quadratic finite elements — about fifteen times fewer per
   direction, squared in the plane.
2. Differential quadrature has a usable window rather than a monotone convergence curve:
   beyond it the error degrades and then the solution fails, catastrophically on a uniform
   grid. Refining until the answer stops changing is not a safe procedure here.
3. The axial direction is the binding one for mesh convergence in this geometry, contrary to
   where refinement effort is usually directed.
4. Free and roller end conditions excite spurious mechanical end modes in this formulation;
   the displacement field requires kinematic anchoring at the axial ends.
5. Newmark, Houbolt and HHT-α are of equal accuracy at equal step; Wilson-θ trades a
   five-fold error for its dissipation; adaptive NDF/BDF integration gains a decimal digit
   at eight times the cost and requires condensation to a first-order form first.
6. The Laplace route fails structurally on the fully coupled operator because the undamped
   elastic poles lie on the inversion contour — the reason transform methods in this field
   are confined to thermal subsystems.
7. An exact Fourier–Bessel benchmark for the Lord–Shulman wave in a hollow cylinder is
   provided and independently verified, and is offered as a reusable reference for
   second-sound codes.

---

## References

1. Bellman R, Casti J. Differential quadrature and long-term integration. *J Math Anal Appl* 1971;34(2):235–8.
2. Shu C. *Differential Quadrature and Its Application in Engineering*. Springer; 2000.
3. Bert CW, Malik M. Differential quadrature method in computational mechanics: a review. *Appl Mech Rev* 1996;49(1):1–28.
4. Newmark NM. A method of computation for structural dynamics. *J Eng Mech Div ASCE* 1959;85(3):67–94.
5. Hilber HM, Hughes TJR, Taylor RL. Improved numerical dissipation for time integration algorithms in structural dynamics. *Earthq Eng Struct Dyn* 1977;5(3):283–92.
6. Houbolt JC. A recurrence matrix solution for the dynamic response of elastic aircraft. *J Aeronaut Sci* 1950;17(9):540–50.
7. Wilson EL, Farhoomand I, Bathe KJ. Nonlinear dynamic analysis of complex structures. *Earthq Eng Struct Dyn* 1972;1(3):241–52.
8. Durbin F. Numerical inversion of Laplace transforms: an efficient improvement to Dubner and Abate's method. *Comput J* 1974;17(4):371–6.
9. Talbot A. The accurate numerical inversion of Laplace transforms. *J Inst Math Appl* 1979;23(1):97–120.
10. Shampine LF, Reichelt MW. The MATLAB ODE suite. *SIAM J Sci Comput* 1997;18(1):1–22.
11. Lord HW, Shulman Y. A generalized dynamical theory of thermoelasticity. *J Mech Phys Solids* 1967;15(5):299–309.
12. Bagri A, Eslami MR. A unified generalized thermoelasticity; solution for cylinders and spheres. *Int J Mech Sci* 2007;49(12):1325–35.
13. Reddy JN. *An Introduction to the Finite Element Method*. McGraw-Hill.
14. *[Paper 1 of this series — cite as submitted / in press.]*

---

## Submission checklist

- [ ] The DQM-breakdown subsection (§4.1) is the most likely to draw referee pushback — have the condition-number data ready as a response even if it is not in the paper
- [ ] Publish the benchmark data as supplementary material; it is much of the paper's reuse value
- [ ] Confirm the exact-solution derivation is written out in full in an appendix
- [ ] Verify no figure overlaps Papers 1 and 2
- [ ] Author order and thesis footnote
