---
dir: ltr
lang: en
---

# Coupled Lord–Shulman thermoelastic response of multilayer porous GPL-reinforced thick cylinders: a full interaction map of graphene and porosity distribution patterns

**Authors.** *[Author 1]*ᵃ, *[Supervisor 1]*ᵃ, *[Supervisor 2]*ᵃ
ᵃ Department of Mechanical Engineering, Persian Gulf University, Bushehr, Iran

> *Author order and affiliations to be settled with the supervisors before submission.*
> *Footnote to add on submission: "This paper is based in part on the first author's MSc thesis at Persian Gulf University."*

**Target journal.** *Composite Structures* (alternates: *Composites Part B*, *IJPVP*)

---

## Abstract

The through-thickness distribution of graphene platelets and the through-thickness
distribution of porosity are the two principal design levers available in a porous
GPL-reinforced composite, and each has been studied on its own. This paper asks whether
they can be chosen independently, and shows that they cannot. A fully coupled
Lord–Shulman thermoelastic analysis of a multilayer porous GPL-reinforced thick-walled
hollow cylinder is developed, discretized by a layerwise differential quadrature method in
the radial and axial directions and marched in time by the Newmark scheme, and verified
against five independent references including an exact Fourier–Bessel solution. All
twenty-five pairings of five graphene patterns with five porosity patterns are then
computed under a combined internal thermal ramp and internal pressure. Porosity pattern A,
which concentrates the pores at the cooled outer surface, emerges as a universal thermal
barrier: it yields the lowest outer-surface temperature whatever the graphene pattern
paired with it, and it flips the inner-surface hoop stress into compression in every one of
those five pairings. The best combination overall, graphene pattern V with porosity pattern
A, holds the dimensionless outer-surface temperature at 0.034 against the uniform
reference's 0.883 — a twenty-six-fold reduction — at a mildly compressive inner hoop stress
of −0.378. The governing mechanism is the alignment or opposition of the two mirror
patterns: pairing the same graphene-V with porosity-V, so that both phases crowd the heated
inner surface, cancels most of the benefit and returns the outer surface to 0.692.
Screening on temperature alone is shown to be unsafe — the pairing of a stiff X-graphene
skeleton with an inner-concentrated porosity-V is only moderately hot yet carries the
largest hoop stress of the entire matrix, 4.20 at peak. The resulting design chart
identifies the corners of the achievable envelope and recommends an outer-concentrated
porosity paired with an inner-rich graphene grading for internal thermal-shock protection.

**Keywords.** Lord–Shulman thermoelasticity; graphene platelets; functionally graded
porosity; layerwise differential quadrature; thick-walled cylinder; thermal shock

---

## 1. Introduction

*[Target length ≈ 1200 words. Structure below; the author should expand each paragraph with
the citations already collected in the thesis bibliography.]*

**Paragraph 1 — the material class.** Graphene platelets as a reinforcing phase: very high
specific modulus and thermal conductivity at low weight fraction, and the percolation
behaviour of the effective conductivity that makes small additions disproportionately
effective. Cite the experimental basis and the Halpin–Tsai homogenization route.

**Paragraph 2 — porosity as a second, independent grading.** Porous metal and polymer
foams; the weight saving and energy absorption they buy; the stiffness penalty they cost;
and the established idea of *grading* the porosity through the thickness rather than
distributing it uniformly. Note that the GPL phase and the pore phase are usually
introduced together precisely because the graphene is there to recover the stiffness the
pores gave away.

**Paragraph 3 — why the classical heat equation is not enough here.** Fourier conduction is
parabolic and therefore implies infinite propagation speed. Under thermal shock, laser
pulses or blast loading this is not an admissible idealization. Introduce the generalized
theories — Cattaneo–Vernotte flux law, Lord and Shulman's single relaxation time, and the
resulting hyperbolic ("second sound") conduction — and note that Lord–Shulman remains the
most used because it adds a single relaxation time and stays thermodynamically consistent.

**Paragraph 4 — what has been done for cylinders and shells.** Bagri and Eslami's unified
generalized solution for cylinders and spheres; Malekzadeh and co-workers on transient
response of rotating laminated FG cylindrical shells; Heydarpour and co-workers extending
Lord–Shulman to GPL-reinforced spherical shells and to multilayered FG spherical shells;
the spinning FG-GPLRC Lord–Shulman cylinder. Establish that the individual ingredients are
all present in the literature.

**Paragraph 5 — the gap.** Individual GPL patterns have been compared. Individual porosity
patterns have been compared. What has not been examined is the *pair*: whether the effect
of a graphene grading survives being placed on a different porosity background, or whether
the two gradings interact. For a fully coupled Lord–Shulman, multilayer, porous,
GPL-reinforced thick cylinder no such interaction study exists. State the contribution
explicitly:

1. A fully coupled Lord–Shulman thermoelastic formulation for the multilayer porous
   GPL-reinforced thick-walled cylinder in the (r, z) plane, solved by layerwise
   differential quadrature and Newmark integration and verified in five independent tests.
2. The complete 5 × 5 graphene × porosity interaction map under combined thermal and
   pressure loading, reported in both temperature and stress.
3. Identification of porosity pattern A as a universal thermal barrier and of the
   mirror-pattern alignment mechanism that governs the interaction.
4. A design chart marking the corners of the achievable envelope, including the
   counter-intuitive case that a temperature-only screening would wrongly pass.

---

## 2. Problem formulation

### 2.1 Geometry and material architecture

A hollow circular cylinder of inner radius $R_i$, outer radius $R_o$ and length $L$,
built from $N_L$ perfectly bonded layers of equal thickness. Within each layer the
graphene weight fraction and the porosity coefficient take the values prescribed by the
chosen through-thickness pattern, so that a layerwise-constant approximation of a
continuous grading is obtained; convergence with respect to $N_L$ is reported in §5.1.

The five graphene distribution patterns (UD, O, X, V, A) and the five porosity patterns
(UD, O, X, V, A) are defined on the centred through-thickness coordinate. UD is uniform; O
concentrates the phase at mid-thickness; X at both surfaces; V at the inner surface; A at
the outer surface. V and A are geometric mirror images of one another, and that
relationship turns out to drive the central result of this paper.

*[Insert Table 1: the pattern definitions, with the mass-conservation constraint that fixes
each pattern's coefficients so that all patterns carry the same total graphene mass and the
same total porosity. Insert Figure 1: schematic of the geometry and the ten patterns —
available as `figures_ch123/geometry_schematic.png`, `GPL_patterns_schematic.png`,
`porosity_patterns_schematic_R7.png`.]*

### 2.2 Effective properties

Effective Young modulus by the Halpin–Tsai micromechanical model for randomly oriented
platelets, with the platelet geometry entering through the two aspect ratios; effective
density and specific heat by the rule of mixtures; effective thermal conductivity by the
percolation-type model. The porosity then reduces each property pointwise through the
porosity coefficient, with the mass-based relation between the mechanical and the mass
porosity coefficients as given in §2.1.

*[Reproduce the property equations from thesis Chapter 3, §3-2 to §3-4. Keep this
subsection compact — it is standard — and give the numerical property set in a table.]*

### 2.3 Governing equations — Lord–Shulman coupled thermoelasticity

Axisymmetric deformation with radial and axial displacement components. The equations of
motion in cylindrical coordinates, and the Lord–Shulman energy equation obtained by
substituting the Cattaneo–Vernotte flux law

$$ \mathbf{q} + \tau_0 \dot{\mathbf{q}} = -k\,\nabla T $$

into the energy balance, giving the hyperbolic coupled energy equation with the relaxation
time $\tau_0$ multiplying both the second time derivative of temperature and the
dilatation-rate coupling term. Setting $\tau_0 = 0$ recovers classical coupled
thermoelasticity, which is used as a comparison case.

*[Reproduce equations from thesis §3-5 and §3-6, in the paper's own notation. State the
full initial and boundary conditions: inner-surface temperature ramp
$T_{in}(t) = T_\infty + \Delta T\,(1 - e^{-t/t_0})$, inner pressure $P_i$, outer-surface
convection to ambient with coefficient $h_c$, and the end conditions.]*

---

## 3. Solution method

### 3.1 Layerwise differential quadrature discretization

Each layer is discretized independently by $N_r$ Chebyshev–Gauss–Lobatto points in the
radial direction, with $N_z$ Chebyshev points shared in the axial direction. Derivatives at
each node are written as weighted sums of all nodal values along the corresponding line,
with weighting coefficients from the Lagrange-polynomial formulation. Continuity of
temperature, heat flux, displacement and traction is imposed at each interlayer interface;
the boundary and interface conditions enter as algebraic constraint rows.

### 3.2 Time integration and system solution

The semi-discrete system takes the form
$\mathbf{M}\ddot{\mathbf{x}} + \mathbf{C}\dot{\mathbf{x}} + \mathbf{K}\mathbf{x} = \mathbf{F}(t)$
with the unknown vector collecting the nodal temperatures and the two displacement
components. Boundary and interface rows are algebraic ($\mathbf{M} = \mathbf{C} = 0$ on
those rows). The Newmark scheme with $\delta = 1/2$, $\beta = 1/4$ (no numerical damping) is
used throughout. Because the effective stiffness matrix is constant for a fixed time step,
it is factorized once before the time loop. Each equation row is equilibrated before
factorization — the thermal rows, the mechanical rows and the constraint rows differ by
many orders of magnitude in scale — which reduces the condition number by several orders
and is essential for an accurate solution of this strongly heterogeneous coupled system.

*[Insert Figure 2: solution flowchart — `figures_ch123/solution_flowchart.png`.]*

---

## 4. Verification

Five independent verification tests are reported; the full details belong in an appendix.

| # | Test | Reference | Result |
|---|---|---|---|
| 1 | Static limit of the dynamic assembly | Independent static solver | max displacement difference 2 × 10⁻¹¹ |
| 2 | Dynamic mechanical response | Malekzadeh et al., and the ANSYS column reported there | within 0.1–0.2 % |
| 3 | Transient conduction | Exact Bessel-series solution | relative error 9 × 10⁻⁵ → 1 × 10⁻⁷ |
| 4 | Time integration | Adaptive stiff solver (NDF/BDF) | agreement to 3 × 10⁻⁴ K |
| 5 | Second-sound wave propagation | Exact Fourier–Bessel eigenfunction solution | 0.32 % pointwise, 0.065 % L₂ |

Test 5 deserves emphasis because the thermal wave is the central physical feature of the
model. The exact reference is constructed for the solver's own geometry by an
eigenfunction expansion in which each modal amplitude obeys a damped-oscillator equation
solved analytically, so the reference carries no time discretization. It was itself
verified before use — steady-state limit to 1.9 × 10⁻¹⁶ of ΔT, strict hyperbolic causality
ahead of the front to 4 × 10⁻⁶, and front-jump ratios matching the analytic ray law to
0.16 %. Against it the solver's error falls monotonically under refinement, which also
establishes that the small oscillations trailing the sharp front are a Gibbs artefact of
the spectral discretization rather than a physical instability. They are left unfiltered
throughout the paper so that no result is presented after manipulation.

*[Insert Figure 3: solver vs exact second-sound comparison —
`figures_validation/ls_wave_validation_R1.png`.]*

---

## 5. Results and discussion

### 5.0 Reference case and dimensionless quantities

$R_i = 1.0$ m, $R_o = 1.5$ m (radius ratio 1.5, wall thickness $h = 0.5$ m), $L = 2.1$ m,
$N_L = 7$ layers, uniform graphene at $W_{GPL} = 0.3\,\%$ and uniform porosity at
$e_{m3} = 0.8604$, Lord–Shulman theory at dimensionless relaxation time $\tau^* = 0.15$,
fully coupled, both ends simply supported. The inner surface is ramped from 300 K to 600 K
with time constant $t_0 = 2$ s while carrying an internal pressure of 50 MPa; the outer
surface convects to a 300 K environment with $h_c = 10$ W/m²K. Discretization
$N_r = 15$ per layer, $N_z = 11$, $\Delta t = 1$ s to 3000 s.

Results are reported dimensionlessly with the wall thickness as length scale:
$Fo = \hat{\alpha}t/h^2$, $T^* = (T - T_\infty)/T_\infty$, $\xi = (r - R_i)/h$,
$U^* = u/[(1-\nu)\alpha T_\infty h]$ and $\Sigma^* = (1+\nu)\sigma/(E\alpha T_\infty)$,
with $\hat{\alpha} = 8.97 \times 10^{-5}$ m²/s. Since the inner surface is raised to twice
the ambient temperature, the inner boundary is at $T^* = 1$ and any excursion above unity
is a genuine overshoot produced by the reflected thermal wave.

*[Insert Table 2 — the dimensionless definitions, from thesis Table 4-1.]*

### 5.1 Convergence

Convergence is established independently in each direction: radial ($N_r \geq 7$), axial
(the binding direction — $N_z = 5$ still carries a 9.4 % error, converged by $N_z = 9$),
layers ($N_L \geq 3$–5) and time step ($\Delta t \leq 2$ s). The axial direction being the
binding one is worth stating explicitly, since radial refinement is where effort is usually
spent in this class of problem.

### 5.2 The graphene pattern on a uniform porosity background

On the uniform porosity background the five graphene patterns order by outer-surface
temperature as V (0.587) < X (0.700) < O (0.805) < UD (0.883) < A (0.896). Pattern V — the
conductive phase concentrated at the heated inner surface — is the coolest at the outer
wall, and pattern A the hottest. The mechanism is straightforward: a conductive inner layer
spreads the incoming heat quickly over a larger volume of material before it can reach the
outer wall, whereas concentrating the conductive phase at the outer surface provides a
direct path for the heat to arrive there.

*[Figure 4: `figures_ch4_color/A_GPL_patterns.png` — 4-panel T*(Fo), U*(Fo), T*(ξ), Σ_θθ(ξ).]*

### 5.3 The porosity pattern on a uniform graphene background

The porosity pattern is by far the stronger lever. On the uniform graphene background the
outer-surface temperature ranges from 0.107 for pattern A to 0.883 for uniform porosity —
almost an order of magnitude, against the graphene patterns' factor of 1.5. Pattern A, with
the pores concentrated at the cooled outer surface, acts as an insulating skin exactly where
the heat is trying to leave.

Pattern V is the interesting counter-case: it produces the *highest* mid-wall temperature
of any single-pattern case, $T^*_{max} = 1.109$, a genuine overshoot above the inner-surface
value, because the pore-rich inner region both insulates and, having low thermal inertia,
heats rapidly — so the thermal wave that eventually propagates outward starts from a hotter
launch point.

*[Figure 5: `figures_ch4_color/B_porosity_patterns.png`.]*

### 5.4 The full interaction matrix

All twenty-five pairings were computed. Two results dominate.

**Porosity-A is a universal thermal barrier.** Reading down the porosity-A column, the
outer-surface temperatures for graphene patterns UD, O, X, V and A are 0.107, 0.064, 0.116,
0.034 and 0.134. Every one of the five is far below the uniform reference's 0.883,
regardless of what the graphene phase is doing. The porosity grading, in other words, sets
the ceiling; the graphene grading then decides where within that much lower band the design
lands.

**The same column flips the inner hoop stress into compression.** The inner-surface hoop
stresses along the porosity-A column are −0.359, −0.372, −0.343, −0.378 and −0.328 — all
compressive, against +1.526 for the uniform reference. This is a second, independent reason
to prefer an outer-concentrated porosity: it removes the tensile inner-surface hoop stress
that would otherwise drive crack initiation at the bore. To the authors' knowledge this
uniformity across the column has not been reported.

**The mirror-pattern mechanism.** Patterns V and A are mirror images. When graphene-V
(conductive at the inner surface) is paired with porosity-A (insulating at the outer
surface) the two act on different, complementary parts of the wall, and the outer-surface
temperature reaches the global minimum of 0.034. Pair the same graphene-V with porosity-V,
so that both phases crowd the inner surface, and the two mechanisms compete for the same
material: the outer-surface temperature climbs back to 0.692. The worst thermal cases
belong to graphene-A — a conductive outer layer — paired with the symmetric porosities,
reaching 0.896. It is therefore not the individual pattern but the *relative orientation*
of the two gradings that governs performance.

*[Figure 6: the 5 × 5 matrix — `figures_ch4_color/matrix25_T_xi.png` and
`matrix25_S_xi.png`. Figures 7–11: the per-porosity unpackings `gplpor_por{UD,O,X,V,A}`.]*

### 5.5 Temperature-only screening is unsafe

The largest hoop stress of the entire matrix does not occur in the hottest case. Graphene-X
paired with porosity-V reaches an inner-surface hoop stress of 4.15 and a peak of 4.20 —
roughly twice the uniform reference's peak of 2.11 — while being only moderately hot. A
screening study that ranked the twenty-five combinations on temperature alone would pass
this case. The mechanism is that a stiff X-graphene skeleton, with the reinforcement at
both surfaces, meets an inner-concentrated porosity that puts the compliant, pore-rich
material exactly where the thermal gradient is steepest; the stiff surface layers then
carry a disproportionate share of the constrained thermal expansion.

### 5.6 The design chart

Collecting the corners: the best case on both counts is V-A, with outer-surface
$T^* = 0.034$ and a mildly compressive inner hoop stress of −0.378. The second-best on both
counts is O-A (0.064 and −0.372), which is worth carrying as the practical alternative. The
worst thermal case is A-UD (0.896) and the worst mechanical case is X-V (peak 4.20). The
uniform reference sits unremarkably in the interior, thermally ordinary but with the lowest
peak stress of the set — a safe but unambitious baseline.

The design recommendation that follows is compact: **for internal thermal-shock protection,
concentrate the porosity at the outer surface and the graphene at the inner surface; avoid
any pairing of a stiff, surface-reinforced graphene pattern with an inner-concentrated
porosity.** The price of the recommended V-A design is a somewhat larger radial
displacement, which the chart makes explicit.

*[Figure 12: `figures_ch4_color/bestworst.png`.]*

### 5.7 Secondary levers

Brief treatment, each a short paragraph with one figure:

- **Graphene weight fraction.** In the low-fraction regime a small graphene addition
  switches the wall from a poor to a good thermal conductor; beyond that, further addition
  mainly raises the thermal stresses, the inner hoop stress reversing sign by 8 %.
- **Platelet aspect ratios.** At this low weight fraction, only a second-order lever.
- **Internal pressure.** Enters linearly and produces no discontinuity up to 100 MPa; at
  the 50 MPa reference it is a first-order contributor to stress and displacement while the
  temperature field remains thermally governed.
- **End supports.** Clamped ends reduce the mid-length hoop stress substantially; support
  effects are end-localized and the mid-length response approaches the long-cylinder limit
  as the cylinder lengthens.

---

## 6. Conclusions

1. A fully coupled Lord–Shulman thermoelastic model of a multilayer porous GPL-reinforced
   thick-walled cylinder has been developed, solved by layerwise differential quadrature
   with Newmark integration, and verified in five independent tests including against an
   exact Fourier–Bessel second-sound solution (0.32 % pointwise).
2. The graphene and porosity gradings cannot be chosen independently. Their interaction is
   governed by whether the two gradings are aligned or mirrored.
3. Porosity pattern A is a universal thermal barrier: it produces the lowest outer-surface
   temperature on every graphene background, and it turns the inner-surface hoop stress
   compressive in all five pairings.
4. The best pairing, graphene-V with porosity-A, reduces the outer-surface temperature
   twenty-six-fold relative to the uniform reference at a mildly compressive inner hoop
   stress.
5. Screening on temperature alone is unsafe: graphene-X with porosity-V is thermally
   unremarkable yet carries the largest hoop stress of the matrix.
6. The recommended configuration for internal thermal-shock protection is an
   outer-concentrated porosity paired with an inner-rich graphene grading.

**Future work.** Temperature-dependent properties; within-layer continuous grading rather
than layerwise-constant; radiation at the outer boundary; and extension of the interaction
map to other generalized theories.

---

## References

*[The thesis bibliography already contains all of these; renumber to the journal's style on
submission. Minimum set for this paper:]*

1. Lord HW, Shulman Y. A generalized dynamical theory of thermoelasticity. *J Mech Phys Solids* 1967;15(5):299–309.
2. Bagri A, Eslami MR. A unified generalized thermoelasticity; solution for cylinders and spheres. *Int J Mech Sci* 2007;49(12):1325–35.
3. Malekzadeh P, et al. Transient response of rotating laminated functionally graded cylindrical shells in thermal environment. *Int J Press Vessels Pip* 2012;98:43–56. doi:10.1016/j.ijpvp.2012.07.003
4. Heydarpour Y, et al. Thermoelastic analysis of FG-GPLRC spherical shells under thermo-mechanical loadings based on Lord–Shulman theory. *Compos Part B* 2019;164:400–24. doi:10.1016/j.compositesb.2018.12.073
5. Heydarpour Y, et al. Thermoelastic analysis of multilayered FG spherical shells based on Lord–Shulman theory. *Iran J Sci Technol Trans Mech Eng* 2019. doi:10.1007/s40997-018-0199-0
6. Zhao J, et al. Thermoelastic wave propagation damping in a hollow FG-GPLRC cylinder with spinning motion. *Thin-Walled Struct* 2022;177:109367.
7. Kitipornchai S, Chen D, Yang J. Free vibration and elastic buckling of functionally graded porous beams reinforced by graphene platelets. *Mater Des* 2017;116:656–65.
8. Affdl JCH, Kardos JL. The Halpin–Tsai equations: a review. *Polym Eng Sci* 1976;16(5):344–52.
9. Shu C. *Differential Quadrature and Its Application in Engineering*. Springer; 2000.
10. Bellman R, Casti J. Differential quadrature and long-term integration. *J Math Anal Appl* 1971;34(2):235–8.
11. Newmark NM. A method of computation for structural dynamics. *J Eng Mech Div ASCE* 1959;85(3):67–94.
12. Cattaneo C. Sur une forme de l'équation de la chaleur éliminant le paradoxe d'une propagation instantanée. *C R Acad Sci* 1958;247:431–3.
13. Hetnarski RB, Eslami MR. *Thermal Stresses — Advanced Theory and Applications*. Springer.
14. Ignaczak J, Ostoja-Starzewski M. *Thermoelasticity with Finite Wave Speeds*. Oxford University Press; 2010.
15. Gibson LJ, Ashby MF. *Cellular Solids: Structure and Properties*. Cambridge University Press.

---

## Submission checklist

- [ ] Author order and affiliations confirmed with supervisors
- [ ] Thesis-derivation footnote added
- [ ] Every figure redrawn at journal resolution; colour and B&W variants both exist already
- [ ] Table 1 (pattern definitions) and Table 2 (dimensionless quantities) written out
- [ ] Introduction expanded to full length with the thesis bibliography
- [ ] §2.2 and §2.3 equations transcribed from thesis Chapter 3
- [ ] Decide: present the relaxation time as physical or explicitly parametric (see portfolio note)
- [ ] Cover letter naming the interaction map as the contribution
