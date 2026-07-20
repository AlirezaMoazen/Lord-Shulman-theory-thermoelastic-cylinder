# ARCHITECTURE — how the solver works

## Problem
Axisymmetric (r, z) transient thermoelasticity of a multilayer hollow cylinder.
Unknown vector per node: `x = [theta; u; w]` with `theta = T − T_ref`
(so the initial condition is exactly zero).
Theory: **Lord-Shulman** (relaxation time τ0 → finite heat-wave speed,
two-way thermo-mechanical coupling) or classical Fourier (`LS_enabled=false`).

## Discretization
- **Layerwise DQM**: each of the `NL` physical layers carries its own
  Chebyshev-Gauss-Lobatto radial grid (`N_r` points) with per-layer DQ
  weighting matrices `A_r{e}` (1st derivative) and `B_r{e} = A_r{e}²` (2nd);
  one shared axial grid (`N_z`, matrices `A_z`, `B_z`).
- Material properties are **piecewise-constant per layer**, evaluated at the
  layer mid-radius (per the thesis spec MZ-R 0.docx).
- Porosity patterns (R3_1, final): centered coordinate ζ∈[−½,½]; mass-side
  factor `P_m` is primary (UD/O/X/V/A with exact conservation constants
  derived from em3); stiffness factor `P_E = P_m²` pointwise.

## Assembly (`M ẍ + C ẋ + K x = F(t)`, K = −(natural spatial operator))
- **Interior rows** = collocated PDEs:
  - energy: `ρc(θ̇ + τ0 θ̈) + βT0(ė + τ0 ë) − ∇·(k∇θ) = 0`,
    dilatation `e = ∂u/∂r + u/r + ∂w/∂z`, `β = α(3λ+2μ)`
  - momentum r/z: `ρü − L_r(u,w) + β ∂θ/∂r = 0`, similarly for w
- **Constraint rows** (algebraic; their M and C rows are zero — the
  displacement-form Newmark then enforces them exactly each step):
  - thermal: inner Dirichlet-ramp OR prescribed flux; outer convection OR
    θ=0; insulated ends; interface continuity of θ and k∂θ/∂r
  - mechanical: inner σ_rr=−P(t) OR u=0; outer σ_rr=0; τ_rz=0 rows;
    end supports S/F/C/R; interface continuity of u, w, σ_rr (incl. thermal
    term), τ_rz; rigid-body pin (w=0 at one node) when ends are S or F
- **Row equilibration**: every equation row divided by its largest
  coefficient (rcond ~1e-24 → ~1e-10 typical).

## Time integration — displacement-form Newmark (γ=½, β=¼ default)
```
K_eff = K + a0 M + a1 C            (LU factorized once)
x_{n+1} = K_eff \ (F_{n+1} + M(a0 x + a2 ẋ + a3 ẍ) + C(a1 x + a4 ẋ + a5 ẍ))
ẍ_{n+1} = a0(x_{n+1}−x_n) − a2 ẋ_n − a3 ẍ_n ;  ẋ_{n+1} = ẋ_n + a6 ẍ_n + a7 ẍ_{n+1}
```
`gam > 0.5` (with `bet = (γ+½)²/4`) adds numerical damping — useful to
smooth Gibbs oscillations behind sharp LS wave fronts.

## Configuration (`cfg` mechanism)
The solver script starts with `clearvars -except cfg`. Any configuration
variable can be overridden by a field of the workspace struct `cfg`
(unknown field names produce a warning). Drivers must re-derive their local
constants **after** calling the solver (the call clears the workspace).

## Results organization (thesis results chapter)
- `param_studies\` — raw data store: one `<case>.mat` (+ `.log`) per run;
  campaign cases (A–N + BASE) and extension cases (T3_*) live side by side.
- `results_campaign\figures\` — chapter figures of the **parametric
  campaign** (studies A–N), written by `claude_param_figures_R2.m`.
- `results_extensions\` — chapter figures/tables of the **method & theory
  extensions**: T1 integrator table, T2.1 spatial convergence
  (DQM-Chebyshev / DQM-uniform / FDM / FEM-linear / FEM-quadratic),
  T3 theory comparison. Written by `claude_param_figures_R2.m` and
  `claude_T2_1_spatial_methods.m`.

## Known limits / findings
- **F (free) and R (roller) end supports are dynamically unstable** in the
  2-D solver: the u-field needs kinematic anchoring at the z-ends
  (spurious DQM end modes; independent of γ and of the coupling).
  Use S or C for transient runs. Purely 1-D radial problems (plane strain)
  are solved with the self-contained 1-D solver in
  `claude_R3_run_benchmark3.m`.
- Assembly uses scalar sparse writes (simple, slow: ~1–5 min at ~1500 DOF).
  A vectorized assembly is a planned future revision (claude_R4 candidate).
- Stress recovery evaluates layer-constant properties; the layerwise
  homogenization makes σ_θθ/σ_zz converge first-order in NL (documented in
  the Benchmark-1 convergence table).
