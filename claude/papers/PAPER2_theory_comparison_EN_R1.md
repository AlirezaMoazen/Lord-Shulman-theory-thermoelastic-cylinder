---
dir: ltr
lang: en
---

# Do the generalized thermoelasticity theories differ for porous GPL-reinforced cylinders? A four-theory comparison under ramp and impulsive thermal loading

**Authors.** *[Author 1]*ᵃ, *[Supervisor 1]*ᵃ, *[Supervisor 2]*ᵃ
ᵃ Department of Mechanical Engineering, Persian Gulf University, Bushehr, Iran

> *Author order to be settled with the supervisors. Add the thesis-derivation footnote.*
> *Cite Paper 1 (formulation and validation) as submitted / in press.*

**Target journal.** *Journal of Thermal Stresses* (alternates: *Acta Mechanica*,
*Continuum Mechanics and Thermodynamics*)

---

## Abstract

Four thermoelasticity theories — classical coupled Fourier, Lord–Shulman, dual-phase-lag
and Green–Naghdi type III — are in routine simultaneous use, and a designer choosing among
them has little quantitative guidance on when the choice actually changes the answer. This
paper supplies that guidance for a structural class in which it has not been examined: a
multilayer porous graphene-platelet-reinforced thick-walled cylinder, whose effective
properties vary by an order of magnitude through the wall. The four theories are solved on
an identical layerwise differential quadrature discretization with matched parameters,
under two loadings chosen to bracket practice — a smooth internal temperature ramp and a
short Gaussian pulse. Under the ramp at a mild relaxation time the three dissipative
theories are nearly indistinguishable, peaking at 0.950 (Fourier), 0.956 (dual-phase-lag)
and 0.962 (Lord–Shulman); the dual-phase-lag result interpolates between the other two
exactly as its structure predicts, and reduces identically to Fourier when the two lags are
equal. Green–Naghdi type III behaves qualitatively differently: it overshoots early and
strongly to 1.581 and is still at 0.870 at the end of the observation window, because its
energy equation carries no mechanism to dissipate the thermal wave. Replacing the ramp with
an impulsive pulse separates Fourier from Lord–Shulman decisively: the classical pulse
arrives early, smeared and weak (0.195), and has effectively vanished by the end of the
window, whereas the Lord–Shulman pulse arrives later, two and a half times stronger
(0.478), and persists as a coherent wave packet. A relaxation-time sweep shows the
mid-wall overshoot growing monotonically from 0.953 to 1.271, and the measured wave arrival
matching the hyperbolic prediction. The practical conclusion is loading-dependent: for slow
thermal loading the classical theory is defensible for this material class, while for
impulsive loading it substantially under-predicts the severity of the event.

**Keywords.** Generalized thermoelasticity; Lord–Shulman; dual-phase-lag; Green–Naghdi;
second sound; graphene platelets; functionally graded porosity

---

## 1. Introduction

*[Target ≈ 1000 words.]*

**Paragraph 1 — the paradox and its repairs.** Fourier's law makes the heat equation
parabolic, implying that a disturbance anywhere is felt instantly everywhere. The
Cattaneo–Vernotte modification introduces a flux relaxation time and restores a finite
propagation speed; Lord and Shulman built the first thermodynamically consistent
generalized thermoelasticity on it. Introduce second sound.

**Paragraph 2 — the family of theories.** Lord–Shulman (one relaxation time);
Green–Lindsay (two); Green–Naghdi types I, II and III, with type II famously dissipationless
and type III containing both a conductivity and a thermal-displacement conductivity;
Tzou's dual-phase-lag with separate flux and gradient lags. Note the known result that
dual-phase-lag collapses onto Fourier when the two lags are equal — useful later as an
internal consistency check.

**Paragraph 3 — where they have been compared.** Comparative studies exist, largely for
homogeneous media or simple functionally graded profiles, and largely under idealized shock
loading. State clearly what is missing: a comparison on a *strongly heterogeneous*
structure, where the through-thickness variation of conductivity, stiffness and thermal
inertia is itself large, and under *more than one* loading type, so that the
loading-dependence of the answer can be seen.

**Paragraph 4 — why this material class is the interesting test.** In a porous
GPL-reinforced wall the effective conductivity varies by an order of magnitude across the
thickness because of the percolation behaviour of the graphene network, and the porosity
independently modulates the thermal inertia. A thermal wave crossing such a wall is
refracted, partially reflected at every property change, and damped unevenly — precisely
the conditions under which theories that differ only in their wave term might be expected
to diverge most.

**Paragraph 5 — contribution.**

1. A four-theory comparison (Fourier / Lord–Shulman / dual-phase-lag / Green–Naghdi III)
   on an identical discretization with matched parameters, for a multilayer porous
   GPL-reinforced cylinder.
2. The comparison repeated under two loading types, establishing that the answer to "does
   the theory matter?" is loading-dependent, not material-dependent alone.
3. Quantification of the Green–Naghdi III departure and attribution of it to the absent
   dissipation mechanism.
4. A relaxation-time sweep verifying that the measured wave arrival obeys the hyperbolic
   prediction, with the coupled-field damping of the wave quantified separately.

---

## 2. The four theories in a common form

Write all four energy equations in a single parameterized form so that the comparison is
manifestly like-for-like. With $\theta = T - T_{ref}$ and $e$ the dilatation:

**Classical coupled (Fourier).**
$$ \rho c\,\dot{\theta} + \beta T_0\,\dot{e} = k\nabla^2\theta $$

**Lord–Shulman.** Flux relaxation $\tau_0$ applied to both the storage and the coupling term:
$$ \rho c\,(\dot{\theta} + \tau_0\ddot{\theta}) + \beta T_0(\dot{e} + \tau_0\ddot{e}) = k\nabla^2\theta $$

**Dual-phase-lag.** Flux lag $\tau_q$ and gradient lag $\tau_T$:
$$ \rho c\,(\dot{\theta} + \tau_q\ddot{\theta}) + \beta T_0(\dot{e} + \tau_q\ddot{e}) = k\nabla^2\theta + k\tau_T\nabla^2\dot{\theta} $$
Setting $\tau_T = \tau_q$ recovers Fourier; setting $\tau_T = 0$ recovers Lord–Shulman.

**Green–Naghdi type III.** With the thermal-displacement conductivity $k^*$:
$$ \rho c\,\ddot{\theta} + \beta T_0\,\ddot{e} = k^*\nabla^2\theta + k\nabla^2\dot{\theta} $$

*[State the matched-parameter choices explicitly: $\tau_q = \tau_0$ and
$\tau_T = \tau_q/2$ for DPL, and $k^* = k/\tau_0$ for GN-III so that its wave speed equals
the Lord–Shulman one. Matching the wave speeds is what makes the GN-III difference
attributable to the dissipation structure rather than to a different propagation speed.
Note the documented approximation that the flux boundary condition is kept in standard form
for GN-III.]*

*[Figure 1: theory taxonomy schematic — `figures_ch123/theory_taxonomy.png`.]*

---

## 3. Model, discretization and verification — summary

Keep this section deliberately short and cite Paper 1 for the full treatment.

Axisymmetric multilayer porous GPL-reinforced hollow cylinder; Halpin–Tsai effective
modulus, rule-of-mixtures density and specific heat, percolation-type effective
conductivity, porosity applied pointwise. Layerwise differential quadrature with Chebyshev
grids in $(r, z)$; Newmark time integration with $\delta = 1/2$, $\beta = 1/4$; row
equilibration before a single factorization.

Verification is reported in full in Paper 1. The test that matters here is the quantitative
second-sound benchmark: an exact Fourier–Bessel eigenfunction reference, itself verified to
1.9 × 10⁻¹⁶ of ΔT in the steady limit, to 4 × 10⁻⁶ for hyperbolic causality ahead of the
front, and to 0.16 % against the analytic ray law for the front-jump ratios. The present
solver matches it to 0.32 % pointwise and 0.065 % in L₂, with monotone convergence under
refinement. This establishes that the wave features discussed below are resolved physics
and not discretization artefacts — an essential precondition for a paper whose subject *is*
the wave term.

**Reference case.** $R_i = 1.0$ m, $R_o = 1.5$ m, $L = 2.1$ m, $N_L = 7$; uniform graphene
at 0.3 % and uniform porosity; inner surface ramped 300 → 600 K with $t_0 = 2$ s; internal
pressure 50 MPa; outer convection $h_c = 10$ W/m²K to 300 K; simply supported ends;
$N_r = 15$, $N_z = 11$, $\Delta t = 1$ s to 3000 s. Dimensionless quantities as in Paper 1,
with the wall thickness as length scale and $\hat{\alpha} = 8.97 \times 10^{-5}$ m²/s.

---

## 4. Results

### 4.1 The relaxation time and the wave signature

Before comparing theories it is necessary to establish that the Lord–Shulman wave is real
and correctly placed. The dimensionless relaxation time is swept over
$\tau^* = 0.04,\ 0.15,\ 0.44,\ 0.87$ against the Fourier limit. The peak mid-wall
temperature rises monotonically:

| case | $\tau^*$ | peak $T^*$ | $Fo$ at peak |
|---|---|---|---|
| Fourier | 0 | 0.950 | 2.153 |
| LS | 0.04 | 0.953 | 2.153 |
| LS | 0.15 | 0.962 | 1.373 |
| LS | 0.44 | 1.166 | 1.675 |
| LS | 0.87 | 1.271 | 2.141 |

Two features are worth noting. The peak exceeds unity from $\tau^* = 0.44$ upward — that is,
the mid-wall temperature exceeds the inner-surface boundary value, which is impossible
under Fourier conduction and is the superposition of the incident and reflected thermal
waves. And the peak arrives *earlier* as the relaxation time grows into the intermediate
range, because the transport mechanism shifts from diffusion to propagation.

The wave speed of the reference material, $v = \sqrt{\hat{\alpha}/\tau_0}$, predicts a
full-wall crossing at $Fo = \sqrt{\tau^*}$; the observed first arrival matches this, which
is the quantitative confirmation that what is seen is the second-sound front and not a
numerical transient.

*[Figure 2: `figures_ch4_color/C_relaxation.png`, or the finer-mesh `C_relaxation_N35`
variant. Figures 3–4: wave-front snapshots `BASE_wavefront.png`, `C_TAU_087_wavefront.png`.]*

**A note on the magnitude of $\tau_0$.** The relaxation times that make the wave clearly
visible here are far above any measured value for a polymer-matrix composite. They are used
as a parametric device to expose the structure of the solution, not as a claim about the
material — and this should be stated plainly in the paper rather than left for a referee to
raise. The physically realistic regime for this material is the small-$\tau^*$ end, where
the paper's own conclusion is that the theory choice barely matters under slow loading.

### 4.2 The four theories under ramp loading

With matched parameters the peak mid-wall temperatures order as

$$ \text{Fourier } 0.950 \;<\; \text{DPL } 0.956 \;<\; \text{Lord–Shulman } 0.962 \;\ll\; \text{Green–Naghdi III } 1.581 $$

Two observations follow.

**The three dissipative theories nearly coincide.** At the mild reference relaxation time
the spread between Fourier and Lord–Shulman is about 1.3 %, and the dual-phase-lag result
sits between them, as the structure of its energy equation requires. As an internal check,
setting $\tau_T = \tau_q$ reproduces the Fourier solution to nine digits — the known
collapse, recovered here as a verification of the implementation rather than as a new
result.

**Green–Naghdi III stands apart, and qualitatively so.** Its peak of 1.581 arrives early,
at $Fo \approx 0.33$, and the field then relaxes only slowly, still at 0.870 at the end of
the window where the other three have settled. The cause is structural: the GN-III energy
equation, with the wave speed matched to Lord–Shulman's, lacks the dissipative term that
damps the propagating disturbance in the other theories, so the energy injected at the
inner surface continues to slosh through the wall instead of decaying. The difference is
therefore not a matter of degree that could be absorbed by re-tuning a parameter — it is a
difference in long-time character, and it means a GN-III model of this structure will
predict persistent thermal cycling that the other three theories do not.

*[Figure 5: `figures_ch4_color/T3_theories.png`.]*

### 4.3 Impulsive loading separates the theories

The ramp is replaced by a short Gaussian pulse of the inner-surface temperature, and the
Fourier and Lord–Shulman responses are compared at mid-thickness:

| theory | peak $T^*$ | $Fo$ at peak | $T^*$ at end of window |
|---|---|---|---|
| Fourier | 0.195 | 0.176 | 0.019 |
| Lord–Shulman | 0.478 | 0.306 | 0.001 |

Under Fourier conduction the pulse reaches mid-thickness early, smeared and weak, and has
practically disappeared by the end of the interval — the signature of diffusion, which
spreads a disturbance in time as it transports it. Under Lord–Shulman the pulse arrives
later, because it travels at a finite speed, roughly two and a half times stronger, because
it travels as a coherent packet rather than spreading, and leaves persistent oscillations
behind it as the packet reflects within the wall. A sharp second-sound front is visible
marching through the thickness.

This is the paper's most practically consequential result. For impulsive thermal loading
the classical theory does not merely shift the timing — it under-predicts the peak
transient temperature at mid-wall by a factor of about 2.5, and therefore under-predicts
the associated transient thermal stress. A design screened with a Fourier model against an
impulsive event is non-conservative.

*[Figure 6: `figures_ch4_color/M_gauss_shock.png`.]*

### 4.4 Thermoelastic damping of the wave

Comparing the fully coupled model with the uncoupled one (dilatation-rate term removed from
the energy equation) isolates the mechanical feedback on the thermal field. The uncoupled
model overestimates the peak mid-point temperature by about 1.2 % (0.937 against 0.926) at
the reference conditions, with the largest discrepancy occurring exactly at the wave
fronts. Part of the thermal energy is continuously converted into mechanical work — a
thermoelastic damping of the thermal wave — so the uncoupled model is non-conservative
where the wave is sharpest. The effect is modest at the mild reference relaxation time but
grows with the strength of the wave, which means that the loading regime where the
generalized theory matters most is also the regime where dropping the coupling is least
acceptable.

*[Figure 7: `figures_ch4_color/I_coupling.png`.]*

---

## 5. Conclusions

1. For a multilayer porous GPL-reinforced cylinder under *slow* thermal loading at a
   physically plausible relaxation time, the classical Fourier, dual-phase-lag and
   Lord–Shulman theories give nearly the same answer (0.950, 0.956, 0.962). The choice
   between them is not the leading source of uncertainty.
2. Under *impulsive* loading the same theories diverge decisively: the Lord–Shulman pulse
   reaches mid-wall about 2.5 times stronger than the Fourier one and persists, while the
   classical pulse smears and vanishes. The answer to "does the theory matter?" is
   therefore a property of the loading, not of the material alone.
3. Green–Naghdi type III is qualitatively different from the other three even at matched
   wave speed, overshooting to 1.581 and relaxing only slowly, because its energy equation
   has no dissipative mechanism. It should not be treated as interchangeable with
   Lord–Shulman.
4. Dual-phase-lag interpolates between Fourier and Lord–Shulman and collapses onto Fourier
   at equal lags, recovered here to nine digits as an implementation check.
5. Full field coupling damps the thermal wave; the uncoupled approximation is
   non-conservative at the wave fronts, and increasingly so as the wave strengthens.

---

## References

*[Minimum set; renumber to journal style.]*

1. Lord HW, Shulman Y. A generalized dynamical theory of thermoelasticity. *J Mech Phys Solids* 1967;15(5):299–309.
2. Green AE, Naghdi PM. Thermoelasticity without energy dissipation. *J Elasticity* 1993;31(3):189–208.
3. Green AE, Naghdi PM. On undamped heat waves in an elastic solid. *J Thermal Stresses* 1992;15(2):253–64.
4. Tzou DY. A unified field approach for heat conduction from macro- to micro-scales. *J Heat Transfer* 1995;117(1):8–16.
5. Cattaneo C. Sur une forme de l'équation de la chaleur… *C R Acad Sci* 1958;247:431–3.
6. Vernotte P. Les paradoxes de la théorie continue de l'équation de la chaleur. *C R Acad Sci* 1958;246:3154–5.
7. Bagri A, Eslami MR. A unified generalized thermoelasticity; solution for cylinders and spheres. *Int J Mech Sci* 2007;49(12):1325–35.
8. Ignaczak J, Ostoja-Starzewski M. *Thermoelasticity with Finite Wave Speeds*. Oxford University Press; 2010.
9. Hosseini SM, Abolbashari MH. Analytical solution for thermoelastic waves propagation in functionally graded cylinders without energy dissipation. *J Thermal Stresses* 2012.
10. Heydarpour Y, et al. Thermoelastic analysis of FG-GPLRC spherical shells based on Lord–Shulman theory. *Compos Part B* 2019;164:400–24.
11. Hosseini SM. Thermal shock response of graphene/CNT-reinforced structures under Gaussian heat source. *Thin-Walled Struct* 2021;166:108108.
12. Sherief HH, Elmisiery AEM, Elhagary MA. Generalized thermoelastic problem for an infinitely long hollow cylinder for short times. *J Thermal Stresses* 2004;27(10).
13. *[Paper 1 of this series — cite as submitted / in press.]*

---

## Submission checklist

- [ ] Confirm the GN-III boundary-condition approximation is stated explicitly (documented in the thesis as an approximation — a referee will look for it)
- [ ] State the parametric status of the large τ₀ values up front, not in response to review
- [ ] Keep §3 short; the full formulation belongs to Paper 1 and must not be reproduced verbatim
- [ ] Verify no figure here is also used in Paper 1 (allocation is in the portfolio note)
- [ ] Author order and thesis footnote
