---
dir: ltr
lang: en-US
---

<!-- CODE_FIX_HISTORY_EN — explains what was wrong with the author's original
     dynamic solver (New Cods/Main_Dyn.m and its Main_Dyn_R2..R4 follow-ups,
     supplied ~2 weeks before this document) and exactly what was changed to
     produce the first working revision, claude_R1.m. All claims below are
     grounded in a direct line-by-line comparison of the two files, not
     recollection — see the file paths cited in each section. -->

# Why the original dynamic solver didn't work, and what was fixed

## 1. The file

The author's own file `New Cods/Main_Dyn.m` (and its follow-up attempts
`Main_Dyn_R2.m`, `Main_Dyn_R3.m`, `Main_Dyn_R4.m`) was meant to extend an
already-working **static** thermoelastic solver (`New Cods/Main-EN.m`) into a
**transient, Lord–Shulman coupled** solver: layerwise differential
quadrature (DQM) in the radial and axial directions, Newmark time
integration, GPL-reinforced porous layers. It did not produce a correct
transient response — in some revisions it crashed outright, in others it ran
to completion but the reported temperature/displacement barely moved from
zero regardless of the applied load.

Four distinct problems were found, one of which is a plain crash and three of
which are silent numerical errors that let the code *run* while computing
the wrong physics. All four are still visible in the file today; nothing
below is guesswork.

## 2. Problem 1 — a genuinely undefined variable (immediate crash)

`Main_Dyn.m`, inside the time-marching loop, computes the thermal-stress
contribution to the axial-momentum load:

```matlab
% Main_Dyn.m, line 513
F_rhs(row_w) = F_rhs(row_w) + (C13+C23+C33)*alpha * dTdz;
```

`C23` is never assigned anywhere in that scope — only `C11`, `C12`, `C13`,
`C33` are computed a few lines above (lines 502–504). MATLAB throws
`Undefined function or variable 'C23'` the first time this line executes,
i.e. on the very first time step. The same undefined-`C23` pattern recurs in
every later revision (`Main_Dyn_R2.m` .. `Main_Dyn_R4.m`) — it was never
actually caught and fixed, only worked around by re-running with different
settings.

**Fix.** The rewritten solver (`claude/code/solver/claude_R1.m`) computes the
full isotropic elastic-constant set per layer up front —
`C11, C12, C13, C22, C23, C33, C55` (line 179–182) — and uses it
consistently everywhere it's needed, so no stress term ever references an
unassigned constant.

## 3. Problem 2 — the Newmark scheme solves for one thing and uses the result as another

This is the most consequential bug, and it is present identically in
`Main_Dyn.m` and in the later `Main_Dyn_R4.m`:

```matlab
% Main_Dyn.m, lines 522-528 (and Main_Dyn_R4.m, lines 860-866 — unchanged)
d_pred = d + dt*v + (0.5-beta)*dt^2*a;
v_pred = v + (1-gamma)*dt*a;
F_eff  = F_rhs + M*(c1*d_pred + c3*v + c4*a) + C*(c2*d_pred + c5*v + c6*a);
a_new  = Q_eff * (U_eff \ (L_eff \ (P_eff * F_eff)));   % <- solved with K_eff = K + c1*M + c2*C
d = d_pred + beta*dt^2 * a_new;
v = v_pred + gamma*dt  * a_new;
```

`K_eff = K + c1*M + c2*C` (with `c1 = 1/(beta*dt^2)`) is the **effective
matrix of the displacement-form Newmark method** — the correct way to use it
is to solve `K_eff * d_new = F_eff` directly for the new displacement `d_new`.
Instead, this code solves the same displacement-form system and then labels
the result `a_new` (an *acceleration*), and applies it back to the
displacement update scaled by `beta*dt^2` — a factor of order `1e-8` here.
The result is a genuine displacement being reinterpreted as an acceleration
and then re-shrunk by eight orders of magnitude before being added to the
state. In practice this freezes the visible response at roughly
`beta*dt^2` of its true value: the solver runs, the numbers move, but they
never approach the physically correct magnitude.

**Fix.** `claude_R1.m` implements displacement-form Newmark the way it is
actually meant to be used: solve directly for the new displacement, then
*derive* velocity/acceleration from it algebraically —

```matlab
% claude_R1.m, lines 617-624
rhs   = F + M*(a0*x + a2*xd + a3*xdd) + C*(a1*x + a4*xd + a5*xdd);
x_new = Qf*(Uf\(Lf\(Pf_*rhs)));          % <- this IS the new displacement, used as such
xdd_new = a0*(x_new - x) - a2*xd - a3*xdd;
xd_new  = xd + a6*xdd + a7*xdd_new;
x = x_new;  xd = xd_new;  xdd = xdd_new;
```

The reference pattern for this (correctly-implemented, already working)
displacement-form scheme is `M/Equation_Termo_Elastic_chand_layer_model_1.m`,
an existing file in the repository — `claude_R1.m`'s header explicitly notes
it was rewritten to match that reference exactly.

## 4. Problem 3 — the sign of the stiffness matrix is backwards

Both the thermal-diffusion and the mechanical-elasticity rows in
`Main_Dyn.m` are assembled with the **natural, positive** sign of the
spatial operator, e.g.:

```matlab
% Main_Dyn.m, lines 152-154 (thermal conduction row)
K(eq, idx_T(e,jr,iz)) = K(eq, idx_T(e,jr,iz)) + (kk/r)*A_r{e}(ir,jr);
K(eq, idx_T(e,jr,iz)) = K(eq, idx_T(e,jr,iz)) + kk * B_r{e}(ir,jr);
```

Under the standard convention this code itself adopts elsewhere,
`M*x'' + C*x' + K*x = F`, the diffusion/elasticity operator must enter with
a **negative** sign (moving `k∇²T` from the right side of
`ρc·Ṫ = k∇²T` to the left gives `ρc·Ṫ − k∇²T = 0`, i.e. `K` should be
`−k∇²`, not `+k∇²`). Building `K` with the positive operator flips this into
an **anti-diffusion** equation for temperature and a **negative-stiffness**
equation for displacement — the system doesn't resist deformation or
smooth out temperature gradients, it does the opposite. Combined with
Problem 2's near-zero response scaling, this sign error mostly went
unnoticed because the response was already too small to visibly diverge in
most short test runs.

**Fix.** `claude_R1.m` assembles every interior row with the operator
negated up front, documented explicitly at the top of the assembly section:

```matlab
% claude_R1.m, lines 196-197
% Convention:  M x'' + C x' + K x = F,  K = -(natural spatial operator).
...
K(eqT,cT) = K(eqT,cT) - k_L(e)*( A_r{e}(ir,jr)/r + B_r{e}(ir,jr) );   % note the minus
```

## 5. Problem 4 — a fabricated cylindrical "volume" factor in the mass matrix

By the `Main_Dyn_R4.m` revision, an extra scaling factor had been introduced
into the mass and damping terms:

```matlab
% Main_Dyn_R4.m, lines 335-336, 354-359
Veff = 2*pi*r_nodes{e}(ir)*dr*dz;
rc = rho_node{e}(ir)*c_node{e}(ir)*Veff;
...
Veff = 2*pi*r*dr*dz;
M(idx_U(e,ir,iz),idx_U(e,ir,iz)) + rho_val*Veff;
```

This treats each collocation point as if it owned a finite-volume "cell"
(`2π·r·dr·dz`) and weights its mass contribution by that cell's volume —
correct practice for a finite-volume or finite-element scheme, but **wrong**
for differential quadrature. DQM is a point-collocation method: each
equation row represents the governing PDE evaluated exactly at that node,
with no implied cell or weighting volume. Multiplying by a fabricated
`Veff` (which varies by three or more orders of magnitude across the mesh,
since `dr` and `dz` differ hugely between a ~0.1 m cylinder and mesh spacing
in meters vs. the actual node coordinates) distorts the relative mass of
every node arbitrarily and has no basis in the DQM formulation being used
everywhere else in the same file.

**Fix.** `claude_R1.m` uses the raw physical values with no invented
geometric weighting, e.g. for mechanical mass:

```matlab
% claude_R1.m, line 269
M(eqU,eqU) = M(eqU,eqU) + rho_L(e);       % just rho, no Veff
```

and correspondingly, the pressure boundary condition is written directly in
stress units (`sigma_rr = -P_i`) rather than being converted through any
invented area/volume factor.

## 6. Two smaller but real issues, folded into the same rewrite

- **Boundary/interface rows must be pure algebraic constraints.** In a
  displacement-form Newmark scheme, a constraint row (a Dirichlet value, a
  traction condition, an interface-continuity equation) has to have its
  mass (`M`) and damping (`C`) matrix rows set to exactly zero, leaving only
  `K`, so the constraint is enforced exactly at every step rather than being
  blended with inertia/damping terms. `claude_R1.m` does this systematically
  for every constraint row (search for `M(...)=0; C(...)=0;` throughout
  section 4.2 of the file) and adds a diagnostic check
  (`if ~isempty(zr), error('K_eff has empty rows...')`) that fails loudly if
  any row is accidentally left without a governing equation — a defensive
  check the original code never had.
- **Row equilibration.** Thermal rows (~1e3 in magnitude), mechanical rows
  (~1e13), and constraint rows (~1) sit many orders of magnitude apart in
  the same sparse matrix, which makes the linear solve numerically
  ill-conditioned. `claude_R1.m` divides every row by its largest
  coefficient before factorizing (`claude_R1.m`, lines 564–577), improving
  the estimated reciprocal condition number from around `1e-24`
  (numerically singular) to around `1e-10` (solvable to full double
  precision) in later validation runs — see `claude/code_docs` and the
  project's validation benchmarks for the resulting accuracy figures.

## 7. Net result

`claude_R1.m` is a from-scratch rewrite built directly on top of the
already-validated **static** solver (`Main-EN.m`), keeping its geometry,
material-property, and mesh-assembly logic, but replacing the transient time
-integration and matrix-sign conventions entirely. Its later revisions
(`claude_R2` .. the current `claude_R8`) added features (FG-powerlaw
material mode, sine pressure loading, additional boundary-condition types,
porosity patterns, GPL distribution patterns) without ever needing to
revisit these four fixes — they were validated once, against six independent
benchmarks (an exact static limit, two literature benchmarks with reported
ANSYS comparisons, an exact Bessel-function transient-conduction solution,
a published Lord–Shulman wave-propagation benchmark, and a qualitative
wave-speed check), and have stayed correct ever since.
