# Chapter 4: Research Findings
<!-- RESULTS_CHAPTER_EN_R2 — English mirror of RESULTS_CHAPTER_FA_R2 (final).
     Same section numbers (4-1 … 4-19), figures 4-1 … 4-16, tables 4-1 … 4-3.
     Thesis nomenclature: h = cylinder length, l = wall thickness.
     Citation numbers follow the thesis reference list (1–73): [4] Lord-Shulman
     1967, [3] Heydarpour et al. 2019, [31] Malekzadeh et al. IJPVP 2012,
     [7] Bagri & Eslami 2007, [67] Hosseini & Abolbashari 2012, [6] Rezaei 1402.
     [74] = proposed NEW entry: Tzou 1995 (DPL theory) — must be added. -->

## 4-1. Introduction

This chapter presents and discusses the numerical findings of the research for
the multilayer porous GPL-reinforced hollow cylinder under thermo-mechanical
loading, based on the governing equations and solution method described in
Chapter 3. First, the reference problem and the dimensionless quantities are
introduced and the numerical solver is verified against six independent tests.
The main parametric studies follow: the GPL distribution pattern, the porosity
pattern and level, the GPL weight fraction, the relaxation time, the end
supports, the internal pressure, the interaction of the distribution patterns,
the coupling of the equations, the convection coefficient, the wall thickness,
the number of layers, and a Gaussian thermal shock. Finally, three extension
studies that go beyond comparable previous works [6] — a comparison of time-
integration methods, a comparison of spatial discretization methods, and a
comparison of generalized thermoelasticity theories — are reported, and the
chapter is summarized.

## 4-2. Reference problem and dimensionless quantities

The problem under study is a thick-walled hollow cylinder with inner radius
R_i = 0.1 m, outer radius R_o = 0.2 m (R_o/R_i = 2, wall thickness l = 0.1 m),
length h = 0.5 m and N_L = 5 layers. In the reference case the GPL
distribution across the thickness is uniform (UD) with total weight fraction
W_GPL = 4 %, the porosity distribution is uniform (UD) with mass coefficient
e_m3 = 0.8980, the Lord-Shulman theory [4] with relaxation time τ0 = 50 s is
used in fully coupled form, and both ends are simply supported (S). The
loading is as follows: the inner-surface temperature rises from the initial
300 K to 600 K according to the smooth ramp T_in(t) = 300 + 300(1 − e^(−t/t0))
with time constant t0 = 0.5 s, while an internal pressure P_i = 1 MPa acts on
the inner surface; the outer surface exchanges heat with the 300 K environment
through the convection coefficient h_c = 10 W/m²K. The discretization uses
N_r = 9 points per layer and N_z = 11 axial points (layerwise differential
quadrature, Chapter 3) with the time step Δt = 0.1 s up to 100 s. The Newmark
parameters are δ = 1/2 and β = 1/4 (no numerical damping); accordingly, the
small oscillations visible behind sharp wave fronts are the well-known Gibbs
effect of the spectral discretization and are deliberately left unfiltered so
that the results are reported without manipulation.

For generality, all results are presented in dimensionless form. The reference
thermal diffusivity ᾱ = k̄/(ρ̄c̄) = 3.50×10⁻⁴ m²/s belongs to the homogenized
reference material, and the definitions are collected in Table 4-1. The
Lord-Shulman thermal wave speed of the reference material is
v = √(ᾱ/τ0) = 2.65×10⁻³ m/s; crossing half the wall thickness therefore takes
about 19 s (Fo ≈ 0.17), which — as will be seen — is exactly where the first
wave arrival appears in the time histories.

**Table 4-1: Dimensionless quantities used in this chapter.**

| quantity | definition | value/range |
|---|---|---|
| Fourier number (dimensionless time) | Fo = ᾱ t / R_o² | Fo(100 s) = 0.875 |
| dimensionless relaxation time | τ* = ᾱ τ0 / R_o² | 0.44 (reference) |
| dimensionless temperature | T* = (T − T∞)/(T_in − T∞) | 0 … ≈1.4 |
| dimensionless radial coordinate | ξ = (r − R_i)/l | 0 … 1 |
| dimensionless radial displacement | u* = u(λ̄+2μ̄)/(β̄ ΔT l) | O(1) |
| dimensionless stress | σ* = σ/(β̄ ΔT) | O(0.1) |

## 4-3. Verification

Before presenting the findings, the correctness of the developed solver was
established by six independent tests, summarized in Table 4-2. First, the
assembled spatial operator was compared with an independent static solver,
agreeing to machine level (2×10⁻¹¹). Second, the dynamic mechanical response
was compared with Table 6 of reference [31] (Malekzadeh et al.) and with ANSYS
finite-element results: the dimensionless displacement error is 0.1–0.2 % and
the inner-surface radial stress equals the analytical value −1.000 exactly.
Third, the transient conduction solution was compared with the exact
Bessel-series solution (relative error 10⁻⁵–10⁻⁷). Fourth, the Newmark time
integration was compared with MATLAB's independent ode15s solver (maximum
difference 0.003 K). Fifth, the coupled Lord-Shulman wave propagation was
verified against the benchmark of Bagri and Eslami [7], reproducing both wave
speeds and the reflection times. Sixth, layer-refinement convergence
(N_L = 5/10/20) was examined, showing monotone convergence onto published
values. Together these six tests support the validity of all results reported
in this chapter.

**Table 4-2: Summary of the solver verification tests.**

| # | test | reference | result |
|---|---|---|---|
| 1 | static spatial assembly | independent static solver | agreement 2×10⁻¹¹ |
| 2 | dynamic mechanical response | reference [31] + ANSYS | error 0.1–0.2 %; σ_rr exact |
| 3 | transient conduction | exact Bessel-series solution | rel. error 10⁻⁵–10⁻⁷ |
| 4 | time integration | ode15s (independent) | max difference 0.003 K |
| 5 | coupled Lord-Shulman waves | Bagri & Eslami [7] | speeds and reflections matched |
| 6 | layer convergence | N_L = 5/10/20 | monotone convergence |

## 4-4. Effect of the GPL distribution pattern

In the first parametric study, the effect of five GPL distribution patterns
across the thickness (UD, O, X, V and A) is examined with all other parameters
held at their reference values. Figure 4-1 shows the time histories of the
dimensionless temperature and radial displacement of the mid-thickness point
at the mid-length section (panels a and b) and the radial profiles of the
temperature and hoop stress at the final time (panels c and d).

[شکل: A_GPL_patterns]

As observed, the peak mid-point temperature for patterns UD, O, X, V and A is
1.41, 1.37, 1.34, 1.19 and 1.46, respectively. Pattern V, in which the GPLs
are concentrated at the inner surface, shows the most favorable behavior: the
highly conductive inner region spreads the incoming heat rapidly through the
thickness, so its peak temperature is about 16 % lower than UD. At the same
time its final inner-surface hoop stress is σ*_θθ = 0.036, which is about 5.5
times smaller than UD (0.196) and 8.8 times smaller than pattern A (0.313).
Conversely, pattern A — whose inner surface consists of the low-conductivity
epoxy-rich material — experiences both the highest temperature and the highest
stress. The radial displacement follows the same ordering (u*_max from 0.95
for V to 1.11 for A). Physically, placing the stiff, conductive phase where
the temperature gradient is steepest — the heated inner wall — both moderates
the thermal gradient and reinforces the critical hoop-stress region; pattern V
is therefore recommended for cylinders under internal thermal shock.

## 4-5. Effect of the porosity pattern and porosity level

This section examines the effect of the porosity distribution pattern
(Figure 4-2) and of the overall porosity level (Figure 4-3); in both cases the
GPL distribution is kept uniform (UD).

[شکل: B_porosity_patterns]

The porosity pattern acts essentially through the conduction path. Patterns
UD, O and X behave similarly (peak temperatures 1.41, 1.42 and 1.37), whereas
the two asymmetric patterns V and A represent complete opposites. In pattern
V, with the pores concentrated at the inner surface, the heat is initially
trapped next to the cylinder cavity and the mid-point experiences the largest
transient peak of this group (T*_max = 1.61 at Fo = 0.51); subsequently the
same porous inner band throttles further heat inflow, so that by the end of
the interval the mid-point temperature returns to 1.04 and the outer surface
to 0.57. Pattern A, concentrating the pores at the outer surface, acts as a
genuine **thermal barrier**: the outer porous band with its negligible
conductivity blocks the heat path to the environment, so that the mid-point
temperature never exceeds T* = 0.28 and the outer surface remains at 0.25 — a
5.6-fold reduction with respect to the value 1.37 of pattern UD. The price of
this thermal performance is paid on the mechanical side: the displacements
collapse to u*_max = 0.24 and the final inner-surface hoop stress even changes
sign (−0.025), a behavior that must be accounted for in design.

[شکل: E_porosity_level]

Figure 4-3 shows the effect of the overall porosity level for the three mass
coefficients e_m3 = 0.9675, 0.8980 and 0.7776 (light, moderate and heavy
porosity, respectively). Increasing the porosity reduces the conductivity and
the stiffness simultaneously; consequently the peak temperature grows mildly
(from 1.38 to 1.41 and 1.51) while the diffusion process slows down, so that
the final mid-point value for the heavy porosity drops to 1.21 — at the end of
the time window the wall is still filling with heat.

## 4-6. Effect of the GPL weight fraction

[شکل: D_GPL_fraction]

The percolation character of the thermal-conductivity model (Chapter 3) makes
the GPL weight fraction the strongest material lever of the problem. According
to Figure 4-4, without GPLs (W = 0) the wall is pure porous epoxy with
k ≈ 0.25 W/mK and ᾱ ≈ 1.9×10⁻⁷ m²/s: within the whole 100-second window the
thermal wave does not even reach the mid-thickness (T* ≈ 0 throughout), and
the small observed displacement (u* = 0.075) is merely the response to the
internal pressure. Adding only 1 % of GPLs by weight, the percolated graphene
network raises the thermal conductivity by about three orders of magnitude and
the familiar transient behavior is established (T*_max = 1.09). Increasing the
weight fraction to 4 % (reference) and 8 % raises the peak temperature to 1.41
and 1.54, respectively; at the same time, however, the wall stiffness
increases strongly and the final inner-surface hoop stress doubles (0.397
versus 0.196). The practical conclusion of this study is that a small GPL
weight fraction suffices to switch the structure from a "thermal insulator"
to a "thermal conductor", and adding graphene beyond that mainly raises the
thermal stresses.

## 4-7. Effect of the relaxation time; Lord-Shulman versus Fourier

[شکل: C_relaxation]

Figure 4-5 compares the response for Fourier conduction (τ* = 0) and for three
values of the dimensionless relaxation time, τ* = 0.15, 0.44 and 0.87. Under
Fourier conduction the mid-point temperature increases monotonically and never
exceeds the driving value (T*_max = 0.99), since classical diffusion, with its
unbounded propagation speed, cannot produce any overshoot. With the relaxation
time active in the Lord-Shulman theory, the heat propagates as a wave with the
finite speed √(ᾱ/τ0): the first wave arrival at the mid-thickness for
τ* = 0.44 is clearly visible at Fo ≈ 0.17, followed by a second front — the
reflection from the outer surface — at Fo ≈ 0.55. Remarkably, owing to the
cylindrical geometry and the superposition of the reflected wave, the
temperature **overshoots** even the inner-surface value; a purely hyperbolic
phenomenon impossible in the parabolic Fourier theory. The peak temperatures
are 1.17 for τ* = 0.15, 1.41 for τ* = 0.44 and 1.30 for τ* = 0.87 (at the end
of the interval and still rising — the slower wave has completed fewer passes
within the window). The relaxation time thus controls both the wave arrival
times and the overshoot amplitude, and its clear signature in the temperature
histories is the central physical argument for employing generalized
thermoelasticity in short-time analyses of such structures [3].

## 4-8. Effect of the end supports

[شکل: F_end_BC]

Figure 4-6 compares the response for simply supported (S) and clamped (C)
conditions at the two ends z = 0 and z = h. The temperature field is observed
to be practically independent of the mechanical support (the peak temperature
changes by only 0.8 %). The mechanical response, however, changes character:
with clamped ends the axial thermal expansion of the wall is blocked and, by
the Poisson effect, the blocked axial strain is redirected radially — the
mid-length radial displacement increases by about 35 % (u*_max = 1.45 versus
1.07). Conversely, the final inner-surface hoop stress *decreases* from 0.196
to 0.146, since part of the load is transferred to the end constraints. It is
worth noting that the disturbances caused by either support decay within a
distance of roughly one wall thickness from the ends; the mid-length responses
are therefore support-independent to within a few percent, which justifies
reporting mid-length quantities as the characteristic response of the
structure.

## 4-9. Effect of the step and harmonic internal pressure

[شکل: G_pressure]

[شکل: N_sine_pressure]

Figures 4-7 and 4-8 examine the effect of the internal pressure. According to
Figure 4-7, removing the 1 MPa internal pressure entirely changes the
displacement and stress histories by far less than 1 % (for instance u*_max
from 1.0735 to 1.0721); the reason is that the thermal stress scale β̄ΔT in
this problem is about two orders of magnitude larger than the applied
pressure, so the response is thermally dominated. According to Figure 4-8,
even a harmonic pressure with 5 MPa amplitude merely superposes a small ripple
on the displacement history without any change of the thermal solution (the
peak-temperature difference from the reference case is of order 10⁻⁵). The
engineering conclusion is that in rapid heating events of this magnitude the
pressure term is a second-order correction — a result that also justifies the
common literature practice of studying the thermal shock alone.

## 4-10. Interaction of the GPL and porosity distribution patterns

[شکل: H_interaction]

The studies of Sections 4-4 and 4-5 showed that pattern V for the GPLs and
pattern A for the porosity are individually the most favorable thermally. In
this section their interaction is examined for the four combinations
X-GPL+O-por, X-GPL+A-por, V-GPL+O-por and V-GPL+A-por alongside the UD/UD
reference (Figure 4-9). The results show that the two mechanisms are
synergetic, with the porosity barrier playing the dominant role: with the X
distribution of graphene, switching the porosity pattern from O to A lowers
the mid-point peak from 1.30 to 0.35, and with the V distribution from 1.23
to 0.17. The best combination, **V-GPL together with A-porosity**, holds the
outer-surface temperature at T* = 0.15 — a **9.0-fold** reduction with respect
to the reference case (1.37) — while its stress state remains benign
(|σ*_θθ| ≤ 0.024). This combination — conductive GPLs facing the heat source
and insulating pores facing the environment — is the design recommendation of
this thesis for thermal-protection applications, and the interaction study
that identified it has no counterpart in comparable previous research [6].

## 4-11. Effect of the coupling of the equations

[شکل: I_coupling]

Figure 4-10 compares the fully coupled model with the uncoupled one (the
dilatation-rate term removed from the energy conservation equation). The
uncoupled model overestimates the peak temperature by 8.4 % (1.53 versus 1.41)
and the peak displacement by 5.5 %. The reason is that in the coupled model a
part of the thermal energy is continuously converted into mechanical work — a
mechanism that may be called the thermoelastic damping of the thermal wave.
The largest difference between the two models occurs exactly at the wave
fronts, i.e. in the very quantities that matter in short-time analyses. This
result demonstrates the necessity of solving the fully coupled system despite
its higher computational cost.

## 4-12. Effect of the outer-surface convection coefficient

[شکل: J_convection]

Figure 4-11 examines the effect of the outer-surface convection coefficient
for h_c = 10, 100 and 1000 W/m²K, corresponding to Biot numbers
Bi = h_c l/k̄ ≈ 0.004 to 0.4. With increasing h_c the outer surface turns from
nearly adiabatic into an effective heat sink: the final outer-surface
temperature drops from T* = 1.37 to 1.34 and 1.03, the mid-point peak from
1.41 to 1.39 and 1.21, and the final inner-surface hoop stress relaxes from
0.196 to 0.078 — because what determines the thermal stress is the
through-wall temperature difference, not the absolute temperature level. The
results show that the response is insensitive to convection for Bi below about
10⁻² and strongly convection-controlled for Bi above about 0.1 — two regimes
that must be distinguished in design.

## 4-13. Effect of the wall thickness

[شکل: K_thickness]

Figure 4-12 compares three cylinders with wall thicknesses l = 0.05, 0.10 and
0.20 m (R_i = 0.1 m fixed); for comparability the time scale of all cases is
nondimensionalized with the reference R_o = 0.2 m. The thin wall is crossed
quickly and repeatedly by the thermal wave, and its mid-point experiences the
largest overshoot of all studies in this chapter (T*_max = 1.78 at Fo = 0.45);
equally quickly, however, it drains (final temperature 0.77). The thick wall
behaves oppositely: within the examined window the wave does not even complete
one full crossing (T*_max = 0.51) and the outer region stays cold; instead,
the inner-surface hoop stress becomes strongly compressive
(σ*_θθ,min = −0.28), since the heated inner band pushes against the cold,
stiff outer mass. The wall thickness is therefore the geometric lever trading
"temperature overshoot in thin walls" against "stress severity in thick
walls".

## 4-14. Effect of the number of layers

[شکل: L_layers]

Figure 4-13 shows the effect of the number of layers building up the wall
(N_L = 3, 5 and 8) while the global distribution functions are kept fixed. The
peak mid-point temperature changes by at most 1.6 % (1.435, 1.412 and 1.428)
and the time histories are practically indistinguishable; the main effect of
the layer count is a refinement of the staircase pattern of the hoop-stress
profile at the layer interfaces, which is the natural signature of the
layerwise property model. On this basis N_L = 5 is used throughout this
chapter as the standard compromise between fidelity to the continuous
distribution and computational cost — a choice consistent with the
convergence study of the verification section.

## 4-15. Response to a Gaussian thermal shock

[شکل: M_gauss_shock]

In this study the sustained ramp is replaced by a short Gaussian pulse of the
inner-surface temperature, and the response is compared under the Lord-Shulman
and Fourier theories (Figure 4-14). This loading exposes the essential
difference between wave-like and diffusive transport: under Fourier conduction
the pulse arrives at the mid-thickness smeared and weak (T*_max = 0.33 at
Fo = 0.12) and has practically vanished by the end of the interval
(T* = 0.004). Under the Lord-Shulman theory the pulse travels as a coherent
wave packet: it arrives later (Fo = 0.27), about twice as strong
(T*_max = 0.66), and leaves persistent oscillations behind (final temperature
0.070). The difference in the stress response is even more striking: the
hoop-stress excursion under Lord-Shulman (from −0.040 to +0.172) is about
**50 times** that of Fourier conduction. In other words, under impulsive
loads the classical theory underestimates the mechanical consequences of the
shock by more than an order of magnitude — the strongest single argument of
this thesis in favor of the generalized theory.

## 4-16. Comparison of time-integration methods

To position the Newmark scheme used in this thesis, five alternative time
integrators were run on the identical benchmark problem (transient conduction
with known exact solution; error measure: maximum temperature error at
t = 10 s). The results are summarized in Table 4-3.

**Table 4-3: Comparison of time-integration methods on the same spatial system.**

| method | max error (K) | CPU time (s) |
|---|---|---|
| Newmark (δ=½, β=¼) | 0.0032 | 0.33 |
| Wilson-θ (θ=1.4) | 0.0164 | 0.19 |
| Houbolt | 0.0025 | 0.24 |
| HHT-α (α=−0.1) | 0.0033 | 0.29 |
| ode15s (adaptive BDF) | 0.0003 | 2.57 |
| Laplace-Durbin (thermal subsystem) | 0.137 | 193 |

Newmark, Houbolt and HHT-α are practically equally accurate at equal time
step; Wilson-θ accepts a roughly 5-fold larger error due to its extra
numerical dissipation; the adaptive stiff solver ode15s is about 10 times more
accurate but 8 times more expensive; and the Laplace-transform route with
Durbin's numerical inversion is three orders of magnitude slower. In
addition, a methodological result emerged from this study: the Laplace
transform cannot be applied to the full coupled system of this problem,
because the undamped elastic poles of the coupled operator lie exactly on the
inversion contour — which is why transform methods are applied in the
literature to thermal subsystems only. This measured comparison justifies the
choice of the Newmark method for all production runs of this thesis.

## 4-17. Comparison of spatial discretization methods

[شکل: T2_spatial_convergence]

In this extension study four spatial discretizations — the differential
quadrature method with Chebyshev and with uniform grids, the second-order
finite difference method, and the finite element method with linear and
quadratic elements (Galerkin formulation with consistent matrices) — are
compared on the transient-conduction problem with the exact Bessel-series
solution, using the identical Newmark time march. Figure 4-15 shows the error
convergence versus the number of radial points. The number of points required
to reach the time-step error floor is: **N ≈ 9–11 for differential
quadrature, N ≈ 21 for quadratic finite elements, and N ≈ 161 for linear
finite elements and finite differences**. The linear-FEM and FDM curves
coincide at slope −2; quadratic FEM gains roughly one order of magnitude per
refinement step; and the DQM error falls quasi-exponentially until the
temporal floor. At equal accuracy the DQM equation system is about 15 times
smaller per direction — squared in the (r,z) plane — which is the quantitative
justification for the layerwise differential quadrature choice of this
thesis.

## 4-18. Comparison of the generalized thermoelasticity theories

[شکل: T3_theories]

In the final extension study the reference problem is solved under four
thermoelasticity theories with matched parameters: the classical coupled
Fourier theory, the Lord-Shulman theory [4], the dual-phase-lag (DPL)
theory [74] with τ_q = τ0 and the two values τ_T = τ_q/2 and τ_T = τ_q, and
the Green-Naghdi type-III theory [67] with k* = k/τ0 (so that its wave speed
equals the Lord-Shulman one). According to Figure 4-16, the peak mid-point
temperatures order as: Fourier 0.991 = DPL(τ_T=τ_q) 0.991 <
DPL(τ_T=τ_q/2) 1.065 < Green-Naghdi 1.151 < Lord-Shulman 1.412. The two main
observations are the following. First, for τ_T = τ_q the DPL solution
collapses onto the Fourier solution to nine significant digits — the numerical
confirmation of the known analytical degeneracy of this theory — showing that
DPL is meaningful only for τ_T < τ_q, in which case it interpolates between
Fourier and Lord-Shulman. Second, the Green-Naghdi theory exhibits an earlier
but weaker front (peak at Fo ≈ 0.64) and a **persistent** overshoot
(T* = 1.12 at the end of the interval), because its energy equation lacks a
dissipative mechanism to damp the thermal wave; its long-time behavior is
therefore qualitatively different. Such a four-theory map for porous
GPL-reinforced cylinders does not exist in the literature and constitutes one
of the contributions of this research.

## 4-19. Chapter summary

The main findings of this chapter can be summarized as follows:

1. The Lord-Shulman thermal wave produces mid-wall temperature overshoot up to
   T* = 1.41 (reference case) and 1.78 (thin wall) — impossible under Fourier
   conduction and decisive for short-time design.
2. Placing the GPLs at the heated surface (pattern V) and the pores at the
   cooled surface (pattern A) is synergetic: a 9.0-fold reduction of the
   outer-surface temperature at benign stress levels — the design
   recommendation of this thesis.
3. A percolation threshold near 1 % weight fraction switches the wall from an
   insulator to a conductor; graphene beyond that mainly raises the thermal
   stresses.
4. Full coupling damps the thermal wave (about 8 % peak reduction); uncoupled
   models are non-conservative exactly at the wave fronts.
5. Internal pressure of engineering magnitude is a second-order effect
   compared with the thermal stress scale β̄ΔT.
6. Clamped ends convert the blocked axial expansion into a ~35 % increase of
   the mid-length radial displacement; support effects remain localized at
   the ends.
7. Under impulsive (Gaussian) heating the classical theory underestimates the
   stress response by a factor of about 50.
8. Methodologically: Newmark offers the best accuracy-to-cost ratio of the six
   tested integrators; differential quadrature needs about 15 times fewer
   points per direction than finite differences or linear finite elements;
   and the four-theory map (Fourier / Lord-Shulman / DPL / Green-Naghdi)
   charts where the theories diverge for this class of structures.
