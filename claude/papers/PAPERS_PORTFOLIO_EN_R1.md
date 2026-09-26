---
dir: ltr
lang: en
---

# Publication portfolio from the thesis — proposed papers, targets, and scope boundaries

This note proposes how the thesis material should be split into journal papers, which
journal each should target, what each one's defensible novelty claim is, and — importantly
— where the boundaries between them must be drawn so that the set does not read as
salami-slicing to an editor.

Three papers are proposed. The thesis contains enough *distinct* material for three
because the three address different questions, for different readerships, with different
methods sections. A fourth paper is **not** recommended; the remaining material is better
used to strengthen these three.

---

## A word of caution before submitting

Editors at Composite Structures, IJPVP and Journal of Thermal Stresses all screen for
duplicate submission and redundant publication. Three papers from one MSc thesis is
defensible **only if** each has its own question, its own results, and its own conclusions.
The rules that keep this set clean:

1. **One results figure never appears in two papers.** The figure inventory below assigns
   each existing figure to exactly one paper. If a figure is genuinely needed as context in
   a second paper, redraw it in reduced form and cite the first paper.
2. **The formulation section is written fresh each time and kept short in Papers 2 and 3.**
   Paper 1 carries the full derivation; Papers 2 and 3 compress it to half a page and cite
   Paper 1. Do not copy-paste paragraphs between them — that is text recycling and will be
   caught by similarity screening.
3. **Submit Paper 1 first, and cite it as "submitted"/"in press" in Papers 2 and 3.** This
   makes the relationship explicit and is what reviewers expect to see.
4. **Disclose the thesis.** A footnote — "This paper is based in part on the first author's
   MSc thesis at Persian Gulf University" — is standard, honest, and causes no problem.
   Omitting it can.

---

## Paper 1 (flagship) — the GPL × porosity pattern interaction map

**Working title**
> Coupled Lord–Shulman thermoelastic response of multilayer porous GPL-reinforced thick
> cylinders: a full interaction map of graphene and porosity distribution patterns

**The question.** Given that both the graphene platelet distribution and the porosity
distribution can each be graded through the wall, does the *pair* behave as the sum of the
two individual choices — or do the patterns interact?

**The answer (the paper's headline).** They interact strongly, and the interaction is
governed by whether the two gradings are aligned or mirrored. Porosity pattern A
(pore-rich at the cooled outer surface) is a *universal* thermal barrier: it gives the
lowest outer-surface temperature regardless of which GPL pattern it is paired with
(0.107, 0.064, 0.116, 0.034, 0.134 along that column). The best pair of all twenty-five,
GPL-V with porosity-A, holds the outer surface at T\* = 0.034 against the uniform
reference's 0.883 — a twenty-six-fold reduction — while its inner hoop stress stays a
benign compressive −0.378. Pair the *same* GPL-V with porosity-V instead, so both phases
crowd the inner surface, and the two mechanisms cancel: the outer surface climbs back to
0.692. And a temperature-only screening would miss the real hazard: X-GPL with V-porosity
is only moderately hot yet carries a peak hoop stress of 4.20, the largest of the matrix.

**Why it is publishable.** Individual GPL patterns and individual porosity patterns have
each been studied. The 5 × 5 pairing has not — for this configuration nothing comparable
exists, and the mirror-pattern cancellation mechanism is a genuine physical result, not a
parameter sweep. The design chart (best/worst corners in both temperature and stress) is
the kind of concrete deliverable applied journals like.

**Supporting content.** Full formulation; layerwise DQM + Newmark solution; the five-test
validation; the individual pattern studies (§4-5, 4-6) as the setup for the matrix; the
interaction matrix (§4-13) as the core; weight fraction (§4-7) and aspect ratio (§4-8) as
secondary levers; pressure (§4-11) and end supports (§4-10) as the loading context.

**Target journals**

| Rank | Journal | Fit |
|---|---|---|
| 1 | *Composite Structures* | GPL-reinforced graded structures are its core diet; design-oriented results welcomed |
| 2 | *Composites Part B: Engineering* | Published Heydarpour's LS GPL spherical shell work — direct lineage |
| 3 | *International Journal of Pressure Vessels and Piping* | Best fit for the *thick*-walled cylinder framing (R_o/R_i = 1.5) |

Note on *Thin-Walled Structures*: despite the GPL literature living there, the cylinder
here is explicitly thick-walled, and a referee will say so. Use TWS only if the framing is
changed, which is not recommended.

---

## Paper 2 — which generalized thermoelasticity theory actually matters

**Working title**
> Do the generalized thermoelasticity theories differ for porous GPL-reinforced cylinders?
> A four-theory comparison under ramp and impulsive thermal loading

**The question.** Fourier, Lord–Shulman, dual-phase-lag and Green–Naghdi type III are all
in routine use. For this class of structure, under what loading do they actually give
different answers — and by how much?

**The answer.** Under a smooth ramp at a mild relaxation time the three dissipative
theories are nearly indistinguishable (Fourier 0.950, DPL 0.956, LS 0.962) and DPL sits
between Fourier and LS exactly as its structure predicts. Green–Naghdi III is the
outlier: peak 1.581 at Fo ≈ 0.33, still 0.870 at the end of the window, because its energy
equation carries no dissipative mechanism — its long-time behaviour is *qualitatively*
different, not merely quantitatively. Change the loading to a short Gaussian pulse and the
Fourier/LS gap opens decisively: the classical pulse arrives early, smeared and weak (0.195
at Fo ≈ 0.18) and has effectively vanished by the end, while the LS pulse arrives later
(Fo ≈ 0.31), two and a half times stronger (0.478), and persists as a coherent packet.
The practical conclusion is a loading-dependent one: for slow thermal loads the theory
choice is nearly irrelevant and Fourier is defensible; for impulsive loads the classical
theory substantially under-predicts severity.

**Why it is publishable.** The theory-comparison literature is largely on homogeneous or
simple FG media. Doing it on a porous GPL-reinforced layered cylinder — where the
effective properties themselves vary by an order of magnitude through the wall — is new,
and the loading-dependence framing ("when does it matter?") is more useful to a reader
than yet another single-theory solution.

**Supporting content.** §4-9 (relaxation time sweep, τ\* = 0.04/0.15/0.44/0.87, showing the
overshoot growing to 1.166), §4-17 (Gaussian shock), §4-20 (the four-theory map), §4-14
(coupling on/off — the thermoelastic damping of the wave), plus the quantitative
second-sound validation against the exact Fourier–Bessel solution as the credibility
anchor.

**Target journals**

| Rank | Journal | Fit |
|---|---|---|
| 1 | *Journal of Thermal Stresses* | The natural home of generalized-thermoelasticity theory comparison |
| 2 | *Acta Mechanica* | Publishes exactly this kind of theory-boundary study |
| 3 | *Continuum Mechanics and Thermodynamics* | If the framing leans further toward the GN-III dissipation argument |

---

## Paper 3 — the numerical-methods assessment and benchmark

**Working title**
> Spatial and temporal discretization of coupled generalized thermoelasticity: a measured
> comparison and an exact second-sound benchmark for layered cylinders

**The question.** For fully coupled hyperbolic thermoelasticity, which discretizations are
actually worth their cost — and how should a new solver in this field be verified?

**The answer.** Three results, in increasing order of interest:

1. Differential quadrature reaches the time-step error floor at roughly 9–11 radial points
   where quadratic FEM needs ~21 and both linear FEM and second-order FDM need ~161 — about
   a fifteen-fold reduction per direction, squared in the (r,z) plane.
2. Among six time integrators, Newmark, Houbolt and HHT-α are of equal accuracy at equal
   step; Wilson-θ costs a five-fold error penalty to its extra dissipation; adaptive
   NDF/BDF (ode15s) buys one decimal digit for eight times the cost.
3. The one that is genuinely worth a paper: **the Laplace-transform route structurally
   fails on the fully coupled system.** The undamped elastic poles of the coupled operator
   lie *on* the Bromwich inversion contour, so the Durbin sum is poisoned by near-singular
   solves — which is precisely why the literature only ever applies transform methods to
   the thermal subsystem. That is usually left unstated; here it is demonstrated and
   explained.

Alongside this sits the **exact benchmark**: a closed-form Fourier–Bessel eigenfunction
solution for the Lord–Shulman wave in a hollow cylinder, verified independently (steady
limit to 1.9 × 10⁻¹⁶ of ΔT, hyperbolic causality to 4 × 10⁻⁶, front-jump ray law to 0.16 %,
self-converged to 8 × 10⁻⁴ at 400 modes) and then used to measure the solver at 0.32 %
pointwise / 0.065 % L₂. A reusable exact reference for second-sound codes is a service to
the field and gives the paper standalone value.

**Why it is publishable.** Method papers in this area are usually "our method works";
this one is a measured, like-for-like comparison with a negative result (Laplace) and a
reusable benchmark. That is a different and more citable contribution.

**Supporting content.** §4-3 (convergence in all four directions, including the finding
that N_z is the binding direction — 9.4 % error at N_z = 5), §4-18 (integrators), §4-19
(spatial methods), §4-4 (the validation suite), and the exact-solution derivation.

**Target journals**

| Rank | Journal | Fit |
|---|---|---|
| 1 | *Applied Mathematical Modelling* | Method comparison plus benchmark is squarely in scope |
| 2 | *Computers & Structures* | If the framing leans on the solver/assembly side |
| 3 | *Engineering with Computers* | Receptive to benchmark + comparative-assessment papers |

---

## What deliberately does **not** become a fourth paper

- **The DQM end-mode instability** (free and roller end conditions excite spurious
  mechanical modes and diverge, while simply-supported and clamped stay stable). This is a
  real and reportable numerical finding, but it is one figure and one mechanism — not a
  paper. It belongs as a subsection of Paper 3, where it strengthens the methods argument.
- **The convergence/minimum-node study alone.** Also Paper 3 material.
- **The pressure, convection, thickness, length and layer-count sweeps.** These are
  competent parametric results but carry no distinct question. They are the supporting cast
  of Paper 1. Splitting them out would be exactly the salami-slicing to avoid.

---

## Figure allocation (no figure appears twice)

| Paper | Existing figures to use |
|---|---|
| 1 | `A_GPL_patterns*`, `B_porosity_patterns*`, `E_porosity_level*`, `D_wt_low*`, `D2_wt_high*`, aspect-ratio figures, `F_end_BC*`, `G_pressure*`, `matrix25_*` (all), `gplpor_por{UD,O,X,V,A}`, `bestworst`, geometry + pattern schematics from `figures_ch123` |
| 2 | `C_relaxation*` (incl. the N35 variants), `BASE_wavefront`, `C_TAU_087_wavefront`, `M_gauss_shock`, `T3_theories`, `I_coupling`, `theory_taxonomy` schematic |
| 3 | `spatial_convergence`, convergence master figures (`conv_*`), `ls_wave_validation_R1`, validation figures from `figures_validation`, `DQM_nodes_schematic`, `solution_flowchart` |

---

## Suggested sequence and realistic timeline

| Step | Work | Notes |
|---|---|---|
| 1 | Finish and submit **Paper 1** | Highest-impact, strongest novelty; establishes the citable formulation reference |
| 2 | **Paper 3** while Paper 1 is under review | Least dependent on Paper 1's fate; the benchmark stands alone |
| 3 | **Paper 2** last | Cites both; benefits from any referee feedback on the formulation |

Submitting all three simultaneously is not advised — if a referee of one discovers the
other two independently, the overlap question is asked in the worst possible way.

---

## Open decisions for the author

1. **Authorship and order** — supervisors' names and the order have to be settled with them
   before anything is submitted. The drafts carry a placeholder byline.
2. **Which journal to try first for Paper 1** — Composite Structures and IJPVP imply
   slightly different framings (composite-design vs. pressure-vessel). The draft is written
   toward Composite Structures; switching to IJPVP means foregrounding the thick-wall and
   pressure aspects.
3. **Whether the τ0 values used should be defended as physical or presented as
   parametric.** The exaggerated relaxation times make the wave visible but are far above
   measured values for polymer composites; the drafts currently present them explicitly as
   a parametric device, which is the honest framing, but a referee will still raise it and
   it is worth having the answer ready.
