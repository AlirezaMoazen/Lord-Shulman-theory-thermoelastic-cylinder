# Results Chapter — English original
<!-- Companion Persian text: RESULTS_CHAPTER_FA.md (same section numbers).
     Figures: results_campaign\figures_print\ and results_extensions\figures_print\
     (vector PDF for insertion into Word; PNG for preview; FIG editable).
     Section numbers are written 4.x — renumber to the chapter number of the
     final thesis. Every quoted number comes from thesis_chapter\chapter_stats.csv,
     results_extensions\T1_integrators_table.csv and T2_spatial_table.csv. -->

## 4.1 Problem definition of the reference case and dimensionless presentation

The results of this chapter concern the multilayer porous GPL-reinforced hollow
cylinder described in Chapters 2–3, with inner radius R_i = 0.1 m, outer radius
R_o = 0.2 m (thick-walled, R_o/R_i = 2), length L = 0.5 m and N_L = 5 layers.
The reference (base) case is: uniform GPL distribution (UD) with total weight
fraction W_GPL = 4 %, uniform porosity (UD) with mass coefficient e_m3 = 0.8980,
Lord–Shulman theory with relaxation time τ0 = 50 s, full thermo-mechanical
coupling, simply supported ends, and the following loading: the inner surface
temperature rises smoothly from 300 K to 600 K (ramp time constant t0 = 0.5 s)
together with an internal pressure P_i = 1 MPa; the outer surface exchanges heat
by convection (h_c = 10 W/m²K) with the 300 K environment. The grid is
N_r = 9 points per layer and N_z = 11 axial points; the time step is Δt = 0.1 s
up to t_end = 100 s. The Newmark parameters are δ = 1/2, β = 1/4 (no numerical
damping); the small oscillations visible behind sharp wave fronts are the
expected Gibbs effect of the spectral discretization and are left unfiltered.

All results are reported in dimensionless form (Table 4.1). The reference
diffusivity ᾱ = k̄/(ρ̄c̄) = 3.50×10⁻⁴ m²/s is that of the homogenized base
material.

**Table 4.1 — Dimensionless quantities used in this chapter.**

| quantity | definition | value/range |
|---|---|---|
| Fourier number (time) | Fo = ᾱ t / R_o² | Fo(100 s) = 0.875 |
| dimensionless relaxation | τ* = ᾱ τ0 / R_o² | 0.44 (base) |
| temperature | T* = (T − T∞)/(T_in − T∞) | 0 → ~1.4 |
| radial coordinate | ξ = (r − R_i)/(R_o − R_i) | 0 … 1 |
| radial displacement | u* = u(λ̄+2μ̄)/(β̄ ΔT h) | O(1) |
| stress | σ* = σ/(β̄ ΔT) | O(0.1) |

The Lord–Shulman thermal wave speed of the base material is
v = √(ᾱ/τ0) = 2.65×10⁻³ m/s; crossing half the wall takes ≈19 s (Fo ≈ 0.17),
which is exactly where the first wave arrival appears in the histories below.

## 4.2 Validation (صحت‌سنجی)

Six independent verifications support the solver (details and figures in the
Validation section/appendix):

**Table 4.2 — Validation summary.**

| # | test | reference | result |
|---|---|---|---|
| 1 | static spatial assembly | independent static solver | agree to 2×10⁻¹¹ |
| 2 | dynamic mechanics | Malekzadeh & Heydarpour, IJPVP 98 (2012), Table 6 + ANSYS | U* within 0.1–0.2 %; σ_rr = −1.000 exact |
| 3 | transient conduction | exact Bessel-series solution | rel. error 10⁻⁵–10⁻⁷ |
| 4 | time integration | MATLAB ode15s (independent scheme) | max diff. 0.003 K |
| 5 | LS coupled wave propagation | Bagri & Eslami, IJMS 49 (2007) | both wave speeds and reflection times reproduced |
| 6 | layer convergence | N_L = 5/10/20 refinement | monotone, extrapolates onto published values |

## 4.3 Effect of the GPL distribution pattern (study A)

[Figure: A_GPL_patterns] With the porosity fixed (UD), the five GPL patterns
change both how fast heat crosses the wall and how the wall carries the thermal
stress. The peak mid-thickness temperature reads T*_max = 1.41 (UD), 1.37 (O),
1.34 (X), 1.19 (V) and 1.46 (A). Pattern V — GPL-rich at the inner surface —
is the most favorable: the highly conductive inner region spreads the incoming
heat and its peak temperature is 16 % below UD; simultaneously its final inner
hoop stress is σ*_θθ = 0.036, i.e. 5.5 times smaller than UD (0.196) and
8.8 times smaller than pattern A (0.313). Pattern A (GPL-rich at the outer,
insulating epoxy-rich material facing the cavity) is the worst on both counts.
The radial displacement follows the same ordering (u*_max = 0.95 V … 1.11 A).
Physically, placing the stiff, conductive phase where the temperature gradient
is steepest (the heated inner wall) both relieves the gradient and reinforces
the region of largest hoop stress.

## 4.4 Effect of the porosity pattern and porosity level (studies B and E)

[Figure: B_porosity_patterns] The porosity pattern acts primarily on the
conduction path. Patterns UD, O and X behave similarly (T*_max = 1.41, 1.42,
1.37). The two asymmetric patterns are extreme opposites:

* **Pattern V** (pores concentrated at the inner surface) initially traps the
  heat next to the cavity — the mid-point shows the largest transient peak of
  the whole campaign group, T*_max = 1.61 at Fo = 0.51 — but the porous inner
  band then throttles further inflow, so by the end of the process the
  mid-point has fallen back to T* = 1.04 and the outer surface to 0.57.
* **Pattern A** (pores concentrated at the outer surface) is a genuine
  **thermal barrier**: the porous outer band blocks conduction outward, and the
  mid-point never exceeds T* = 0.28 while the outer surface stays at 0.25 —
  a 5.6-fold reduction of the outer temperature compared with UD (1.37).
  The price is paid elsewhere: with the load carried by the low-temperature
  region, displacements collapse (u*_max = 0.24) and the final hoop stress at
  the inner surface even changes sign (−0.025).

[Figure: E_porosity_level] Raising the overall porosity (e_m3 = 0.9675 → 0.8980
→ 0.7776, i.e. light → heavy porosity) lowers conductivity and stiffness
together: the peak temperature grows mildly (1.38 → 1.41 → 1.51) while the
process slows (final mid-point value drops from 1.38 to 1.21 because the wall
is still filling with heat at t_end).

## 4.5 Effect of the GPL weight fraction (study D)

[Figure: D_GPL_fraction] The percolation character of the conductivity model
makes W_GPL the strongest material lever in the problem. With no GPLs (W = 0)
the wall is pure porous epoxy (k ≈ 0.25 W/mK, ᾱ ≈ 1.9×10⁻⁷ m²/s): within the
whole 100 s window the heat wave does not even reach mid-thickness
(T* ≈ 0 throughout; the small displacement u* = 0.075 is the pressure
response). Already at W = 1 % the percolated GPL network raises the
conductivity by three orders of magnitude and the familiar transient
establishes itself (T*_max = 1.09); W = 4 % (base) gives 1.41 and W = 8 %
gives 1.54 with a much stiffer wall — the final inner hoop stress doubles
(0.397 vs 0.196). The practical reading: a small GPL fraction is enough to
switch the structure from "thermal insulator" to "thermal conductor", after
which additional GPLs mainly raise the thermally induced stresses.

## 4.6 Effect of the relaxation time — Lord–Shulman vs Fourier (study C)

[Figure: C_relaxation] Under Fourier conduction (τ* = 0) the mid-point
temperature rises monotonically and never exceeds the driving value
(T*_max = 0.99): classical diffusion cannot overshoot. With the Lord–Shulman
relaxation active, heat propagates as a wave of speed √(ᾱ/τ0): the first
arrival at mid-thickness appears at Fo ≈ 0.17 for τ* = 0.44, followed by a
second front (reflection from the outer surface) at Fo ≈ 0.55. Because the
cylindrical geometry focuses the reflected wave, the temperature **overshoots**
the cavity value — a purely hyperbolic effect impossible in the parabolic
theory: T*_max = 1.17 (τ* = 0.15), 1.41 (τ* = 0.44), 1.30 at t_end and still
rising (τ* = 0.87; the slower wave has completed fewer passes within the
window). The relaxation time thus controls both the arrival times (∝ 1/√τ0 in
speed) and the overshoot amplitude, and its clear signature in the histories
is the central physical argument for using generalized thermoelasticity in
short-time analyses of this structure.

## 4.7 Effect of the end supports (study F)

[Figure: F_end_BC] Changing the ends from simply supported to clamped leaves
the temperature field essentially untouched (T*_max changes by 0.8 %) — the
thermal problem does not see the mechanical supports. The mechanical response,
however, changes character: with clamped ends the axial thermal expansion of
the wall is blocked, and by the Poisson effect the blocked axial strain is
diverted into the radial direction — the mid-span radial displacement rises by
35 % (u*_max = 1.45 vs 1.07), while the final inner hoop stress *decreases*
from 0.196 to 0.146 as part of the load is transferred to the end restraints.
Both supports produce end-localized disturbances that decay within roughly one
wall thickness of the ends, so mid-span histories are support-independent to
within a few percent — the justification for reporting mid-span quantities as
the characteristic response.

## 4.8 Effect of the internal pressure — step and harmonic (studies G and N)

[Figures: G_pressure, N_sine_pressure] At the load levels of interest the
response is thermally dominated: removing the 1 MPa internal pressure changes
the displacement and stress histories by well under 1 % (e.g. u*_max 1.0735 →
1.0721), because the thermal stress scale β̄ΔT is two orders of magnitude
larger than P_i. Even a harmonic pressure of amplitude 5 MPa (study N)
superposes only a small visible ripple on the displacement history without
altering the temperature solution (T*_max identical to base within 10⁻⁵).
The engineering conclusion — in rapid heating events of this magnitude the
pressure term is a second-order correction — also justifies the common
literature practice of studying the thermal shock alone.

## 4.9 Interaction of GPL and porosity patterns (study H)

[Figure: H_interaction] Combining the best GPL pattern (V, §4.3) with the
barrier porosity pattern (A, §4.4) tests whether the two mechanisms cooperate.
They do, and the porosity barrier dominates the pairing: with X-GPL the switch
of porosity from O to A drops the mid-point peak from 1.30 to 0.35; with V-GPL
from 1.23 to 0.17. The best combination, **V-GPL + A-porosity**, keeps the
outer surface at T* = 0.15 — a **9.0-fold** reduction with respect to the base
case (1.37) — while its stress state remains benign (|σ*_θθ| ≤ 0.024). This
combination — conductive GPLs facing the heat source, insulating pores facing
the environment — is the design recommendation of this thesis for thermal
protection, and the interaction study that identifies it has no counterpart in
the reference works.

## 4.10 Effect of the thermo-mechanical coupling (study I)

[Figure: I_coupling] Deactivating the coupling term (the dilatation-rate source
in the energy equation) leaves a pure conduction problem driving an elastic
one. The uncoupled model overestimates the temperature peak by 8.4 %
(T*_max = 1.53 vs 1.41) and the displacement peak by 5.5 %, because coupling
continuously converts part of the thermal energy into mechanical work —
thermoelastic damping of the thermal wave. The difference is largest exactly
at the wave fronts, i.e. in the quantities a short-time analysis cares about,
which justifies carrying the fully coupled system despite its cost.

## 4.11 Effect of the outer convection — Biot number (study J)

[Figure: J_convection] Increasing h_c from 10 to 100 to 1000 W/m²K (Biot
number Bi = h_c h/k̄ from 4×10⁻³ to 0.4) turns the outer surface from nearly
adiabatic into an efficient heat sink: the outer-surface final temperature
drops from T* = 1.37 to 1.34 to 1.03, the mid-point peak from 1.41 to 1.39 to
1.21, and the final inner hoop stress relaxes from 0.196 to 0.078 as the
through-wall temperature difference, not the absolute level, sets the thermal
stress. The response is insensitive below Bi ≈ 10⁻² and strongly convection-
controlled above Bi ≈ 0.1, bracketing the regimes a designer must distinguish.

## 4.12 Effect of the wall thickness (study K)

[Figure: K_thickness] With R_i fixed, walls of h = 0.05, 0.10 and 0.20 m are
compared (all times scaled with the base R_o = 0.2). The thin wall is crossed
quickly and repeatedly by the thermal wave: its mid-point sees the largest
overshoot of the whole campaign (T*_max = 1.78 at Fo = 0.45) but also drains
fastest (final mid-point 0.77). The thick wall is the opposite: within the
window the wave completes less than one crossing (T*_max = 0.51) and the
outer region stays cold, while the final inner hoop stress becomes strongly
compressive at the inner surface (σ*_θθ,min = −0.28) because the heated inner
band pushes against a cold, stiff outer mass. Thickness is thus the geometric
knob that trades peak overshoot (thin) against stress severity (thick).

## 4.13 Effect of the number of layers (study L)

[Figure: L_layers] Rebuilding the same graded wall with N_L = 3, 5 and 8
layers changes the mid-point peak by at most 1.6 % (1.435 / 1.412 / 1.428)
and leaves the histories visually indistinguishable; the layer count mainly
sharpens the staircase of the hoop-stress profile at the interfaces (§4.4
figure, lower right panels). N_L = 5 is retained as the standard compromise
between fidelity of the grading and cost, consistent with the convergence
study of the validation section.

## 4.14 Response to a Gaussian thermal shock (study M)

[Figure: M_gauss_shock] Replacing the sustained ramp by a short Gaussian pulse
of the inner temperature isolates the difference between wave-like and
diffusive transport. Under Fourier conduction the pulse arrives at mid-
thickness smeared and weak (T*_max = 0.33 at Fo = 0.12) and is essentially
gone by the end (T* = 0.004). Under Lord–Shulman the pulse travels as a
coherent wave packet: it arrives later (Fo = 0.27), twice as strong
(T*_max = 0.66), and leaves behind persistent oscillations (final T* = 0.070).
The stress response differs even more: the LS hoop-stress excursion
(σ*: −0.040 … +0.172) is roughly 50 times the Fourier one — under impulsive
loads the classical theory underestimates the mechanical consequences of the
shock by more than an order of magnitude, the strongest single argument in
this thesis for the generalized theory.

## 4.15 Extension — comparison of time-integration methods (T1)

To place the Newmark scheme of this thesis, five alternative integrators were
run on the identical semi-discrete conduction benchmark (exact solution known;
error = max temperature error at t = 10 s):

**Table 4.15 — Time integrators on the same spatial system.**

| method | max error (K) | CPU (s) |
|---|---|---|
| Newmark (δ=½, β=¼) | 0.0032 | 0.33 |
| Wilson-θ (θ=1.4) | 0.0164 | 0.19 |
| Houbolt | 0.0025 | 0.24 |
| HHT-α (α=−0.1) | 0.0033 | 0.29 |
| ode15s (adaptive BDF) | 0.0003 | 2.57 |
| Laplace–Durbin (thermal subsystem) | 0.137 | 193 |

Newmark, Houbolt and HHT-α are equivalent in accuracy at equal step; Wilson-θ
trades a 5× larger error for its extra dissipation; the adaptive stiff solver
is 10× more accurate but 8× more expensive; and the Laplace-transform route is
three orders of magnitude slower while being *inapplicable to the full coupled
system* — the undamped elastic poles of the coupled operator lie on the
inversion contour, which is why the literature applies transform methods to
thermal subsystems only. This measured comparison motivates the choice of
Newmark for all production runs.

## 4.16 Extension — comparison of spatial discretizations (T2)

[Figure: T2_spatial_convergence] On a transient conduction problem with exact
Bessel-series solution, four discretizations were driven to the time-step
error floor with identical Newmark marching. The number of radial points
needed to reach that floor is: **DQM (Chebyshev or uniform) N ≈ 9–11;
quadratic FEM N ≈ 21; linear FEM and 2nd-order FDM N ≈ 161**. The linear-FEM
and FDM curves coincide at slope −2, quadratic (Bubnov–Galerkin, consistent
matrices) FEM gains roughly one order per refinement step, and the DQM error
falls quasi-exponentially until the temporal floor. At equal accuracy the DQM
system is 15× smaller in one dimension — squared in the (r,z) plane — which is
the quantitative justification of the layerwise-DQM choice of this thesis.

## 4.17 Extension — comparison of thermoelasticity theories (T3)

[Figure: T3_theories] The same base problem was solved under four theories
with matched parameters (DPL with τ_q = τ0; GN-III with k* = k/τ0 so that its
wave speed equals the LS one). The peak mid-point temperatures order as:
Fourier 0.991 = DPL(τ_T=τ_q) 0.991 < DPL(τ_T=τ_q/2) 1.065 < GN-III 1.151
< LS 1.412. Two observations carry the section: (i) for τ_T = τ_q the DPL
solution collapses onto Fourier to nine significant digits — the numerical
confirmation of the known analytical degeneracy — so DPL is meaningful only
with τ_T < τ_q, interpolating between Fourier and LS; (ii) GN-III shows an
earlier, weaker front (arrival Fo ≈ 0.64 at the peak) and a *persistent*
overshoot (T* = 1.12 at t_end) because its energy equation lacks the damping
k∇²θ̇-term's dissipation of the wave — qualitatively different long-time
behavior. For the porous GPL-reinforced cylinder such a four-theory map does
not exist in the literature and constitutes one of the contributions of this
work.

## 4.18 Summary of the chapter

1. The LS thermal wave produces mid-wall temperature overshoot up to T* = 1.41
   (base) and 1.78 (thin wall) — impossible under Fourier conduction and
   decisive for short-time design.
2. Placing GPLs at the heated surface (V) and pores at the cooled surface (A)
   is synergetic: outer temperature reduced 9.0-fold at benign stress levels —
   the design recommendation of this thesis.
3. A percolation threshold near W_GPL ≈ 1 % switches the wall from insulator
   to conductor; further GPL mainly raises thermal stresses.
4. Full coupling damps the thermal wave (−8 % peak); uncoupled models are
   non-conservative exactly at the fronts.
5. Pressure of engineering magnitude is a second-order effect against β̄ΔT.
6. Clamped ends convert blocked axial expansion into +35 % mid-span radial
   displacement; support effects stay end-localized.
7. Under impulsive (Gaussian) heating the classical theory underestimates the
   stress response by a factor ≈ 50.
8. Methodological: Newmark is the best accuracy/cost integrator of the six
   tested; DQM needs ~15× fewer points per direction than FDM/linear FEM;
   the four-theory comparison (Fourier/LS/DPL/GN-III) maps where the theories
   diverge for this class of structures.
