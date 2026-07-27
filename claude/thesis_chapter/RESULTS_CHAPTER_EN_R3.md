# Chapter 4: Research Findings
<!-- RESULTS_CHAPTER_EN_R3 — English mirror of RESULTS_CHAPTER_FA_R3.
     Revision 3 (supervisor review Prom 3-7 and Prom.2): convergence and
     verification split into two sections; new sections on GPL aspect ratio and
     the infinite-length limit; full 4x4 GPL x porosity interaction matrix with
     mirror-pattern interpretation; pressure sweep to 100 MPa and mixed support;
     peak-trough interpretation added; figures renumbered 4-1 … 4-22.
     Nomenclature: h = cylinder length, l = wall thickness (pending final
     confirmation per Prom.2 item h). Porosity patterns are to be replaced by
     the new patterns of the MZ file (Prom.2 item g) once confirmed. -->

## 4-1. Introduction

This chapter presents and discusses the numerical findings of the research for
the multilayer porous GPL-reinforced hollow cylinder under thermo-mechanical
loading, based on the governing equations and solution method described in
Chapter 3. First, the reference problem and the dimensionless quantities are
introduced; then the numerical convergence of the solution and its
verification — treated as two independent topics — are established through
separate tests. The main parametric studies follow: the GPL distribution
pattern, the porosity pattern and level, the GPL weight fraction, the platelet
aspect ratio, the relaxation time, the end supports, the internal pressure, the
cylinder length, the interaction of the distribution patterns, the coupling of
the equations, the convection coefficient, the wall thickness, and a Gaussian
thermal shock. Finally, three extension studies that go beyond comparable
previous works [6] — a comparison of time-integration methods, a comparison of
spatial discretization methods, and a comparison of generalized thermoelasticity
theories — are reported, and the chapter is summarized.

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

## 4-3. Numerical convergence

Before validating the results, the numerical convergence of the solution must
be examined at two independent levels: first, convergence with respect to the
number of layers used in the layerwise discretization through the wall
thickness, and second, convergence with respect to the spatial discretization
method and the number of points it employs. Only after both levels are
established can one be confident that any discrepancy with the reference results
stems from physical differences rather than residual numerical error.

[شکل: L_layers]

To assess layer convergence, the peak dimensionless temperature at the
mid-point of the wall was computed for different numbers of layers and is shown
in Figure 4-1. With three layers the peak dimensionless temperature is 1.435,
and as the number of layers is increased to five, eight, nine, and fifteen it
tends to 1.412, 1.428, 1.416, and 1.416, respectively. From nine layers onward
the dimensionless temperature remains essentially unchanged and convergence has
been achieved. Since five layers differ only negligibly (below 1 %) from the
converged state while imposing a considerably lower computational cost, five
layers are adopted in what follows as a compromise between accuracy and cost;
the main effect of a larger layer count is a refinement of the staircase
pattern of the hoop-stress profile at the layer interfaces, which is the
natural signature of the layerwise property model. Within each layer a mesh of
nine radial and eleven axial points is used, with a time step of 0.1 s.

[شکل: T2_spatial_convergence]

The superiority of the layerwise differential quadrature method for spatial
discretization is also evaluated against the finite difference and finite
element methods. A transient heat conduction problem with an exact
Bessel-function solution is taken as the benchmark, and the number of points
required for the error of each method to reach the time-step error floor is
compared; the results are presented in Figure 4-2, whose legend is now located
at the top-right corner. The differential quadrature method with a Chebyshev or
uniform distribution reaches the error floor with only about nine to eleven
points, whereas quadratic finite elements require about twenty-one points, and
linear finite elements and the second-order finite difference method require
about one hundred and sixty-one points. The differential quadrature system is
therefore, per direction, about fifteen times smaller than the corresponding
finite difference or linear finite element system. The full methodological
comparison, together with the Galerkin finite-element formulation, is reported
as an extension study in Section 4-19. In this way the numerical convergence of
the solution — both in the number of layers and in the spatial discretization —
is fully established before proceeding to the verification of the results.

## 4-4. Verification

The present numerical solution is verified through five independent checks,
based on comparison with exact analytical solutions, published results from the
literature, and a commercial finite-element solution. In each check, in
addition to the quantitative error, the present result is plotted as a
comparison diagram against the corresponding reference so that the coincidence
of the curves is demonstrated visually; these diagrams are collected in the
verification appendix. First, the assembly of the static matrices is checked
against an independent static solver, with a maximum displacement-field
difference of order 2×10⁻¹¹, confirming the numerical equivalence of the two
implementations and the correctness of the system assembly.

In the second check, the dynamic-mechanics part of the problem is compared with
the results of Malekzadeh (Table 6 of reference [31], IJPVP 2012) and with an
independent ANSYS finite-element solution. The dimensionless radial
displacement is reproduced with a relative difference of 0.1 to 0.2 percent,
and the dimensionless inner-surface radial stress is obtained exactly as
−1.000, in full agreement with the unit-pressure loading boundary condition.

In the third check, the transient heat-conduction problem is compared with the
exact Bessel-series solution; the dimensionless temperature distribution at
various time steps lies on the exact curve, with a relative error of 10⁻⁵ to
10⁻⁷. In the fourth check, the Newmark time integration is validated against
MATLAB's reference solver ode15s, and the maximum temperature difference over
the whole interval is 0.003 K, confirming the stability and accuracy of the
adopted time-integration scheme.

Finally, in the fifth check, the wave-propagation behavior of the coupled
Lord-Shulman theory is compared with the results of Bagri and Eslami (2007,
reference [7]); both wave speeds (elastic and thermal) and the reflection times
within the cylinder wall are correctly reproduced, and the present wave fronts
coincide with those of the reference. Taken together, these five checks confirm
the validity of the present numerical solution in both the static and transient
regimes and in the coupled and uncoupled cases. A summary is given in Table
4-2.

**Table 4-2: Summary of the solver verification tests.**

| # | test | reference | result |
|---|---|---|---|
| 1 | static spatial assembly | independent static solver | agreement 2×10⁻¹¹ |
| 2 | dynamic mechanical response | reference [31] + ANSYS | error 0.1–0.2 %; σ_rr exact |
| 3 | transient conduction | exact Bessel-series solution | rel. error 10⁻⁵–10⁻⁷ |
| 4 | time integration | ode15s (independent) | max difference 0.003 K |
| 5 | coupled Lord-Shulman waves | Bagri & Eslami [7] | speeds and reflections matched |

## 4-5. Effect of the GPL distribution pattern

In the first parametric study, the effect of five GPL distribution patterns
across the thickness (UD, O, X, V and A) is examined with all other parameters
held at their reference values. Figure 4-3 shows the time histories of the
dimensionless temperature and radial displacement of the mid-thickness point at
the mid-length section (panels a and b) and the radial profiles of the
dimensionless temperature and hoop stress at the final time (panels c and d).

[شکل: A_GPL_patterns]

As observed, the peak mid-point temperature for patterns UD, O, X, V and A is
1.41, 1.37, 1.34, 1.19 and 1.46, respectively. Pattern V, in which the GPLs are
concentrated at the inner surface, shows the most favorable behavior, because
the highly conductive inner region spreads the incoming heat rapidly through
the thickness, so its peak temperature is about 16 percent lower than UD.
Physically, placing the stiff, conductive phase where the temperature gradient
is steepest — the heated inner wall — both moderates the thermal gradient and
reinforces the critical hoop-stress region.

The key feature of this study is the peak-trough shape of the dimensionless
temperature histories, which stems directly from the wave-like nature of heat
conduction in the Lord-Shulman theory: as the thermal wave front reaches the
mid-point, the temperature rises rapidly to a peak and then, after the front
passes and before the reflected wave returns from the outer surface, drops into
a transient trough. The depth of this peak and trough depends strongly on the
distribution pattern. Against this background, a mirror and inverse behavior
emerges between the two asymmetric patterns V and A: geometrically they are
mirror images about the mid-thickness (V is GPL-rich at the inner surface while
A is GPL-rich at the outer surface), and they behave in exactly opposite ways.
Pattern V, placing the conductive phase facing the heat source, produces a low,
mild peak (1.19) with the smallest oscillation amplitude, whereas pattern A, by
placing the low-conductivity epoxy matrix at the inner surface, traps heat
within the inner band and experiences the sharpest and highest peak (1.46). The
symmetric patterns UD, O and X fall between these extremes, and this mirror
ordering clearly explains why V is the best and A the worst.

This inverse behavior is also reflected in the mechanical response, all three
quantities following the same ordering. The final inner-surface hoop stress for
pattern V is 0.036, about 5.5 times smaller than UD (0.196) and 8.8 times
smaller than pattern A (0.313); that is, the two ends of the mirror spectrum
record the lowest and highest stress. The radial displacement follows the same
trend, its maximum ranging from 0.95 for V to 1.11 for A. Pattern V therefore
simultaneously delivers the lowest temperature, the lowest hoop stress and the
smallest displacement, while its mirror pattern A is the worst case in all
three; pattern V is therefore recommended for the GPL distribution in cylinders
under internal thermal shock.

## 4-6. Effect of the porosity pattern and porosity level

This section examines the effect of the porosity distribution pattern across
the wall thickness for the five patterns UD, O, X, V and A; in all cases the
GPL distribution is kept uniform (UD) and the remaining parameters are held at
their reference values. Figure 4-4 shows the time histories of the
dimensionless temperature and radial displacement of the mid-point together
with the radial profiles of the temperature and hoop stress at the final time.
The porosity pattern acts essentially by reshaping the heat-conduction path,
since a porous band of negligible conductivity behaves as a localized thermal
resistance. The three symmetric patterns UD, O and X behave similarly, with
mid-point peak temperatures of 1.41, 1.42 and 1.37; in these patterns the
porous phase is either uniformly spread or placed symmetrically about the
mid-thickness and therefore does not render the conduction path fundamentally
asymmetric.

[شکل: B_porosity_patterns]

The key result lies in the two asymmetric patterns V and A, which are mirror
images of each other yet produce completely opposite thermal responses. In
pattern V the pores are concentrated at the heated inner surface; this
insulating band traps the incoming heat near the inner surface at the very
outset and prevents its rapid spread through the thickness. As a result the
mid-point temperature history displays a pronounced transient peak — the
largest overshoot of this group — reaching 1.61 at a Fourier number of 0.51;
the same inner porous band then acts as a barrier against further heat inflow,
and the curve falls until the mid-point temperature returns to 1.04 by the end
of the interval. At the opposite extreme, pattern A concentrates the pores at
the cooled outer surface, so that instead of trapping the heat it blocks the
heat-exit path toward the environment and thus behaves as a genuine **thermal
barrier**. In this pattern the mid-point temperature never exceeds 0.28 and the
outer-surface temperature remains at 0.25 — a 5.6-fold reduction with respect
to the value 1.37 of pattern UD. Shifting the porous band from the inner to the
outer surface therefore transforms the thermal response from a tall, deeply
relaxing transient peak (pattern V) into a smooth, suppressed curve (pattern
A); the mirror symmetry of the geometry leads to a mirror contrast of
performance.

The favorable thermal performance of pattern A is paid for on the mechanical
side. Because the heat never penetrates deep into the wall, the thermal
expansion and hence the radial displacement drop sharply, and the peak
dimensionless displacement collapses to 0.24. Moreover, the unusual resulting
temperature distribution reverses the sign of the inner-surface dimensionless
hoop stress, which reaches a negative value of 0.025; that is, the inner
region, normally under hoop tension, turns compressive in this pattern. This
sign reversal must be carefully accounted for in the design of cylinders under
internal thermal shock.

[شکل: E_porosity_level]

Finally, the effect of the overall porosity level is shown in Figure 4-5 for
the three mass coefficients e_m3 = 0.9675, 0.8980 and 0.7776 (light, moderate
and heavy porosity). Increasing the porosity reduces the conductivity and the
stiffness simultaneously; consequently the peak temperature grows mildly (from
1.38 to 1.41 and 1.51) while the diffusion process slows down, so that the
final mid-point value for the heavy porosity drops to 1.21 — at the end of the
time window the wall is still filling with heat.

## 4-7. Effect of the GPL weight fraction

[شکل: D_GPL_fraction]

[شکل: D2_GPL_fill]

The percolation character of the thermal-conductivity model (Chapter 3) makes
the GPL weight fraction the strongest material lever of the problem. According
to Figure 4-6, without GPLs (zero weight fraction) the wall consists of pure
porous epoxy with a thermal conductivity of about 0.25 W/mK and a thermal
diffusivity of about 1.9×10⁻⁷ m²/s; within the whole 100-second window the
thermal wave does not even reach the mid-thickness and the dimensionless
temperature remains close to zero throughout, while the small observed radial
displacement of about 0.075 is merely the response to the internal pressure.

Adding only 1 % of GPLs by weight, the percolated graphene network raises the
thermal conductivity by about three orders of magnitude and the familiar
transient behavior is established; at this point the peak dimensionless
mid-point temperature reaches 1.09. This jump reveals the percolation threshold
of the graphene network at a weight fraction of about 1 %: below this level the
wall stays effectively an insulator, and slightly above it a continuous
conductive heat path is opened. To resolve the behavior just above the
threshold, the transition range of 2 to 4 % is scanned finely in Figure 4-7 (a
zoom of the same range): the peak mid-point temperature for the weight
fractions 2, 2.2, 2.6, 3.5 and 4 % is 1.254, 1.262, 1.303, 1.386 and 1.412,
respectively. Once the percolated network is active the temperature rises
smoothly and monotonically with increasing weight fraction and no further
abrupt jump occurs; the main transition is concentrated only near the 1 %
threshold, and the subsequent increases are gradual corrections interpolating
between the reference values.

Increasing the weight fraction further to 8 % raises the peak mid-point
temperature to 1.535; at the same time, however, the wall stiffness increases
strongly and the final inner-surface hoop stress doubles relative to the
reference case (0.397 versus 0.196). The practical conclusion is that a small
GPL weight fraction — around the same 1 % threshold — suffices to switch the
structure from a "thermal insulator" to a "thermal conductor", and adding
graphene beyond that, while producing only a mild and smooth improvement in
heat diffusion, mainly raises the thermal stresses. It is worth noting that
most previous works examined GPL weight fractions in the range 0.1 to 2 %; in
this work the range is extended up to 4 % (reference) and 8 % in order to fully
expose the upper reinforcement limit and the saturation behavior beyond the
percolation threshold.

## 4-8. Effect of the GPL aspect ratio

The Halpin–Tsai model employed in Chapter 3 to estimate the effective modulus
and thermal conductivity of the nanocomposite makes the reinforced properties
depend not only on the volume fraction but also on the geometry of the graphene
platelets. This geometry is described by two independent aspect ratios: the
length-to-width ratio, entering through the characteristic length a_GPL, and
the width-to-thickness ratio, appearing through the characteristic thickness
t_GPL. In this section the effect of each ratio is examined separately while
all other parameters are held at their reference-case values.

[شکل: O_aspect_length]

The effect of the length-to-width ratio is shown in Figure 4-8. As this ratio
increases from unity to 1.67 (reference) and then to 2.67, the maximum
dimensionless temperature rises from 1.384 to 1.412 and 1.416, while the
inner-surface hoop stress increases from 0.187 to 0.196 and 0.202. The
structural response is only weakly sensitive to this ratio: a substantial
increase produces a change of only about three percent in the peak temperature,
because in the Halpin–Tsai coefficients the geometric factor associated with
the platelet length plays a subordinate role relative to that of the thickness.

[شکل: P_aspect_thick]

By contrast, the effect of the width-to-thickness ratio (Figure 4-9) is far
more pronounced. As this ratio increases from 500 to 1000 (reference) and then
to 2000, the maximum dimensionless temperature rises from 1.378 to 1.412 and
1.415; however, the inner-surface hoop stress increases from 0.170 to 0.196 and
0.210, a change of about twenty percent. The factor ξ_T, which sets the
reinforcement weight along the platelet width, scales with the width-to-thickness
ratio, so this ratio becomes the dominant reinforcement lever. Thinner platelets
with a higher aspect ratio impart a greater effective modulus and thermal
conductivity to the wall, thereby raising both the thermal penetration and the
thermal stress.

The overall conclusion is that, among the two aspect ratios, the
width-to-thickness ratio is the governing reinforcement lever, whereas the
length-to-width ratio plays a second-order role. From a design standpoint,
thinner platelets provide more effective reinforcement, but this is accompanied
by a comparatively larger increase in thermal stresses (about twenty percent)
against a modest rise in the peak temperature (about three percent), a
trade-off that must be accounted for when selecting the platelet geometry.

## 4-9. Effect of the relaxation time; Lord-Shulman versus Fourier

[شکل: C_relaxation]

Figure 4-10 compares the response for Fourier conduction (τ* = 0) and for three
values of the dimensionless relaxation time, τ* = 0.15, 0.44 and 0.87. Under
Fourier conduction the mid-point temperature increases monotonically and never
exceeds the driving value (T*_max = 0.99), since classical diffusion, with its
unbounded propagation speed, cannot produce any overshoot. With the relaxation
time active in the Lord-Shulman theory, the heat propagates as a wave with the
finite speed √(ᾱ/τ0): the first wave arrival at the mid-thickness for τ* = 0.44
is clearly visible at Fo ≈ 0.17, followed by a second front — the reflection
from the outer surface — at Fo ≈ 0.55. Remarkably, owing to the cylindrical
geometry and the superposition of the reflected wave, the temperature
**overshoots** even the inner-surface value; a purely hyperbolic phenomenon
impossible in the parabolic Fourier theory. The peak temperatures are 1.17 for
τ* = 0.15, 1.41 for τ* = 0.44 and 1.30 for τ* = 0.87 (at the end of the interval
and still rising — the slower wave completes fewer passes within the window).
The relaxation time thus controls both the wave arrival times and the overshoot
amplitude, and its clear signature in the temperature histories is the central
physical argument for employing generalized thermoelasticity in short-time
analyses of such structures [3].

## 4-10. Effect of the end supports

[شکل: F_end_BC]

The effect of the end supports is examined for three cases: simply supported at
both ends (S-S), one end simply supported and the other clamped (S-C) as a
mixed case, and clamped at both ends (C-C). As shown in Figure 4-11, the
temperature field is nearly independent of the support type, and the peak
dimensionless temperature for all three cases lies in the narrow range 1.412 to
1.423; this is natural, since the mechanical support does not directly alter the
thermal problem.

The mechanical response, however, depends strongly on the support. With both
ends clamped, the axial thermal expansion of the wall is blocked and, by the
Poisson effect, redirected radially; consequently the peak dimensionless radial
displacement rises from 1.073 in the simply supported case to 1.451 in the
clamped case, an increase of about 35 %. The mixed case shows intermediate
behavior for the inner hoop stress: the dimensionless inner-surface hoop stress
for the S-S, mixed, and C-C cases is 0.196, 0.170, and 0.146, respectively, and
the mixed value lies correctly between the two limiting cases.

It is noteworthy that the peak displacement of the mixed case (1.054) is close
to the simply supported case rather than the clamped case, because at the
mid-length section the simply supported end governs the radial freedom and the
effect of the clamped end remains confined to the half nearer to it.
Furthermore, the disturbances caused by either support decay within a distance
of roughly one wall thickness from the ends; reporting mid-length quantities as
the characteristic response of the structure is therefore justified.

## 4-11. Effect of the internal pressure

The effect of the internal pressure is examined with a full pressure sweep at
six values 0, 10, 30, 50, 70, and 100 MPa, so that the behavior is covered from
low pressures to very high pressures. As shown in Figure 4-12, the temperature
field remains practically independent of the internal pressure, because thermal
and mechanical loading are linked only through the weak coupling term in the
energy equation, and pressure is not a direct driver of temperature. By
contrast, the mechanical response grows linearly with pressure: the peak
dimensionless radial displacement rises from 1.073 with no pressure to 1.086,
1.115, 1.143, 1.171, and 1.214, respectively, with an increment of exactly
0.0283 per 20 MPa; this perfect linearity reflects the linear nature of the
thermoelastic model employed.

[شکل: G_pressure]

[شکل: G2_pressure_components]

Importantly, even at 100 MPa no discontinuity occurs in the numerical response,
and the solution remains smooth and convergent, because the present model is a
linear thermoelastic model in which physical rupture (material failure or
separation) is not included; assessing that would require a damage or failure
model beyond the present linear analysis. The dimensionless inner-surface hoop
stress rises from 0.195 with no pressure to 0.295 at 100 MPa, an increase of
about 51 %. The dimensionless radial-stress profile (Figure 4-13) runs from the
negative of the applied pressure at the inner surface to zero at the outer
surface, consistent with the loading boundary condition.

[شکل: N_sine_pressure]

This study refines the common literature result more precisely: at the base
pressure of 1 MPa the pressure contribution is below one percent and hence
second-order; but as the pressure rises into the 70–100 MPa range, pressure
becomes a genuine secondary effect that accounts for up to about 50 % of the
inner hoop stress and about 13 % of the displacement, although the response is
still thermally dominated. In addition, a harmonic internal pressure of 5 MPa
amplitude superposes only a small ripple on the displacement history and leaves
the temperature field unchanged (Figure 4-14).

## 4-12. Effect of the cylinder length and the infinite-length limit

[شکل: Q_infinite_len]

To examine the limiting behavior of a long cylinder, the length is gradually
increased from the base value of 0.5 m to 1, 2, and 4 m so that the effect of
the two ends on the mid-length section vanishes. As shown in Figure 4-15, the
peak dimensionless temperature at the mid-length section is practically
constant, remaining in the range 1.412 to 1.414; the temperature field is
length-independent.

By contrast, the mechanical response of the mid-length section tends to a
limiting value as the length increases. The final dimensionless radial
displacement decreases from 1.019 for a length of 0.5 m to 0.904, 0.879, and
0.858 for lengths of 1, 2, and 4 m, respectively, approaching an asymptote of
about 0.85. Likewise the dimensionless inner-surface hoop stress decreases from
0.196 to 0.147, 0.143, and 0.138, approaching an asymptote of about 0.138.

This behavior shows that as the cylinder becomes longer, the mid-length
response converges to the infinite-length (plane-strain-like) limit, in which
the mechanical and thermal effects of the two ends are not felt. The base
cylinder of length 0.5 m, owing to the proximity of the two ends, experiences a
slightly larger displacement and stress than the limiting case, and this
boundary effect is progressively removed as the length increases.

## 4-13. Interaction of the GPL and porosity distribution patterns

[شکل: H_interaction]

The studies of Sections 4-5 and 4-6 showed that pattern V for the GPLs and
pattern A for the porosity are individually the most favorable thermally. This
section first examines their interaction for the four combinations
X-GPL+O-por, X-GPL+A-por, V-GPL+O-por and V-GPL+A-por alongside the UD/UD
reference (Figure 4-16). The two mechanisms are synergetic, with the porosity
barrier dominant: with the X distribution of graphene, switching the porosity
pattern from O to A lowers the mid-point peak from 1.30 to 0.35, and with the V
distribution from 1.23 to 0.17.

[شکل: S_interaction_matrix]

To examine this interaction fully, all sixteen combinations formed by the four
GPL patterns (O, X, V, A) and the four porosity patterns (O, X, V, A) are
computed, and the dimensionless outer-surface temperature for each combination
is presented as a heatmap (Figure 4-17). The first key observation is that
porosity pattern A (pores concentrated at the outer surface) acts as a
universal thermal barrier and, regardless of the GPL pattern, gives the lowest
outer-surface temperature; the values for this column are 0.19, 0.29, 0.15, and
0.32. The best combination, GPL-V together with porosity-A, holds the
outer-surface temperature at T* = 0.15 — a roughly **ninefold** reduction with
respect to the reference case (about 1.37) — confirming this work's design
recommendation for thermal protection, while its stress state remains benign
(|σ*_θθ| ≤ 0.024).

The second observation is the mirror-pattern interaction. Patterns V and A are
geometric mirror images (inner-surface versus outer-surface concentration).
When GPL-V (conductive at the inner surface) is combined with porosity-A
(insulating at the outer surface), the two mechanisms act synergetically and
the outer-surface temperature reaches 0.15; but when the same GPL-V is combined
with porosity-V (both concentrated at the inner surface), the two effects weaken
each other and the outer-surface temperature rises to 1.24. At the other
extreme, the worst cases belong to GPL-A (conductive at the outer surface)
combined with porosity-O or X, which raise the outer-surface temperature to as
high as 1.42 and 1.40. Thus not only the individual pattern but also the
alignment or opposition of the two patterns is decisive. This interaction study
has no counterpart in comparable previous research [6] and is one of the
contributions of this work.

## 4-14. Effect of the coupling of the equations

[شکل: I_coupling]

Figure 4-18 compares the fully coupled model with the uncoupled one (the
dilatation-rate term removed from the energy conservation equation). The
uncoupled model overestimates the peak temperature by 8.4 % (1.53 versus 1.41)
and the peak displacement by 5.5 %. The reason is that in the coupled model a
part of the thermal energy is continuously converted into mechanical work — a
mechanism that may be called the thermoelastic damping of the thermal wave. The
largest difference between the two models occurs exactly at the wave fronts,
i.e. in the very quantities that matter in short-time analyses. This result
demonstrates the necessity of solving the fully coupled system despite its
higher computational cost.

## 4-15. Effect of the outer-surface convection coefficient

[شکل: J_convection]

Figure 4-19 examines the effect of the outer-surface convection coefficient for
h_c = 10, 100 and 1000 W/m²K, corresponding to Biot numbers Bi = h_c l/k̄ ≈
0.004 to 0.4. With increasing h_c the outer surface turns from nearly adiabatic
into an effective heat sink: the final outer-surface temperature drops from
T* = 1.37 to 1.34 and 1.03, the mid-point peak from 1.41 to 1.39 and 1.21, and
the final inner-surface hoop stress relaxes from 0.196 to 0.078 — because what
determines the thermal stress is the through-wall temperature difference, not
the absolute temperature level. The response is insensitive to convection for
Bi below about 10⁻² and strongly convection-controlled for Bi above about 0.1 —
two regimes that must be distinguished in design.

## 4-16. Effect of the wall thickness

[شکل: K_thickness]

Figure 4-20 compares three cylinders with wall thicknesses l = 0.05, 0.10 and
0.20 m (R_i = 0.1 m fixed); for comparability the time scale of all cases is
nondimensionalized with the reference R_o = 0.2 m. The thin wall is crossed
quickly and repeatedly by the thermal wave, and its mid-point experiences the
largest overshoot of all studies in this chapter (T*_max = 1.78 at Fo = 0.45);
equally quickly, however, it drains (final temperature 0.77). The thick wall
behaves oppositely: within the examined window the wave does not even complete
one full crossing (T*_max = 0.51) and the outer region stays cold; instead the
inner-surface hoop stress becomes strongly compressive (σ*_θθ,min = −0.28),
since the heated inner band pushes against the cold, stiff outer mass. The wall
thickness is therefore the geometric lever trading "temperature overshoot in
thin walls" against "stress severity in thick walls".

## 4-17. Response to a Gaussian thermal shock

[شکل: M_gauss_shock]

In this study the sustained ramp is replaced by a short Gaussian pulse of the
inner-surface temperature, and the response is compared under the Lord-Shulman
and Fourier theories (Figure 4-21). This loading exposes the essential
difference between wave-like and diffusive transport: under Fourier conduction
the pulse arrives at the mid-thickness smeared and weak (T*_max = 0.33 at
Fo = 0.12) and has practically vanished by the end of the interval (T* = 0.004).
Under the Lord-Shulman theory the pulse travels as a coherent wave packet: it
arrives later (Fo = 0.27), about twice as strong (T*_max = 0.66), and leaves
persistent oscillations behind (final temperature 0.070). The difference in the
stress response is even more striking: the hoop-stress excursion under
Lord-Shulman (from −0.040 to +0.172) is about **50 times** that of Fourier
conduction. In other words, under impulsive loads the classical theory
underestimates the mechanical consequences of the shock by more than an order
of magnitude — the strongest single argument of this thesis in favor of the
generalized theory.

## 4-18. Comparison of time-integration methods

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

Newmark, Houbolt and HHT-α are practically equally accurate at equal time step;
Wilson-θ accepts a roughly 5-fold larger error due to its extra numerical
dissipation; the adaptive stiff solver ode15s is about 10 times more accurate
but 8 times more expensive; and the Laplace-transform route with Durbin's
numerical inversion is three orders of magnitude slower. In addition, a
methodological result emerged: the Laplace transform cannot be applied to the
full coupled system of this problem, because the undamped elastic poles of the
coupled operator lie exactly on the inversion contour — which is why transform
methods are applied in the literature to thermal subsystems only. This measured
comparison justifies the choice of the Newmark method for all production runs of
this thesis.

## 4-19. Comparison of spatial discretization methods

In this extension study four spatial discretizations — the differential
quadrature method with Chebyshev and with uniform grids, the second-order
finite difference method, and the finite element method with linear and
quadratic elements (Galerkin formulation with consistent matrices) — are
compared on the transient-conduction problem with the exact Bessel-series
solution, using the identical Newmark time march. The error convergence versus
the number of radial points was presented earlier in Figure 4-2 (Section 4-3).
The number of points required to reach the time-step error floor is: **N ≈ 9–11
for differential quadrature, N ≈ 21 for quadratic finite elements, and N ≈ 161
for linear finite elements and finite differences**. The linear-FEM and FDM
curves coincide at slope −2; quadratic FEM gains roughly one order of magnitude
per refinement step; and the DQM error falls quasi-exponentially until the
temporal floor. At equal accuracy the DQM equation system is about 15 times
smaller per direction — squared in the (r,z) plane — which is the quantitative
justification for the layerwise differential quadrature choice of this thesis.
Adding the two Galerkin finite-element formulations (linear and quadratic) to
this comparison is one of the extensions of this work over comparable previous
studies.

## 4-20. Comparison of the generalized thermoelasticity theories

[شکل: T3_theories]

In the final extension study the reference problem is solved under four
thermoelasticity theories with matched parameters: the classical coupled
Fourier theory, the Lord-Shulman theory [4], the dual-phase-lag (DPL)
theory [74] with τ_q = τ0 and the two values τ_T = τ_q/2 and τ_T = τ_q, and the
Green-Naghdi type-III theory [67] with k* = k/τ0 (so that its wave speed equals
the Lord-Shulman one). According to Figure 4-22, the peak mid-point temperatures
order as: Fourier 0.991 = DPL(τ_T=τ_q) 0.991 < DPL(τ_T=τ_q/2) 1.065 <
Green-Naghdi 1.151 < Lord-Shulman 1.412. Two main observations follow. First,
for τ_T = τ_q the DPL solution collapses onto the Fourier solution to nine
significant digits — the numerical confirmation of the known analytical
degeneracy of this theory — showing that DPL is meaningful only for τ_T < τ_q,
in which case it interpolates between Fourier and Lord-Shulman. Second, the
Green-Naghdi theory exhibits an earlier but weaker front (peak at Fo ≈ 0.64)
and a **persistent** overshoot (T* = 1.12 at the end of the interval), because
its energy equation lacks a dissipative mechanism to damp the thermal wave; its
long-time behavior is therefore qualitatively different. Such a four-theory map
for porous GPL-reinforced cylinders does not exist in the literature and
constitutes one of the contributions of this research.

## 4-21. Chapter summary

The main findings of this chapter can be summarized as follows:

1. The numerical convergence of the solution was established — in the number of
   layers (converged from N_L = 9) and in the spatial discretization (DQM with
   9–11 points) — before verification, and the solver was validated in five
   independent tests against exact solutions and references.
2. The Lord-Shulman thermal wave produces mid-wall temperature overshoot up to
   T* = 1.41 (reference case) and 1.78 (thin wall) — impossible under Fourier
   conduction — and the temperature histories show the characteristic
   peak-trough shape of the reflecting wave.
3. Placing the GPLs at the heated surface (pattern V) and the pores at the
   cooled surface (pattern A) is synergetic: a 9-fold reduction of the
   outer-surface temperature at benign stress levels — the design recommendation
   of this thesis. Patterns V and A are mirror images, and the full 4×4 matrix
   shows that the alignment or opposition of the two patterns governs the
   thermal performance.
4. A percolation threshold near 1 % weight fraction switches the wall from an
   insulator to a conductor; graphene beyond that mainly raises the thermal
   stresses. Of the two platelet aspect ratios, the width-to-thickness ratio is
   the dominant reinforcement lever.
5. Full coupling damps the thermal wave (about 8 % peak reduction); uncoupled
   models are non-conservative exactly at the wave fronts.
6. Internal pressure is a second-order effect at the base pressure, but in the
   70–100 MPa range it becomes a genuine secondary effect (up to about 50 % of
   the inner hoop stress); the response nonetheless remains thermally dominated
   and no discontinuity occurs up to 100 MPa.
7. Clamped ends convert the blocked axial expansion into a ~35 % increase of the
   mid-length radial displacement; support effects are localized at the ends,
   and as the cylinder lengthens the mid-length response converges to the
   infinite-length limit.
8. Under impulsive (Gaussian) heating the classical theory underestimates the
   stress response by a factor of about 50.
9. Methodologically: Newmark offers the best accuracy-to-cost ratio of the six
   tested integrators; differential quadrature needs about 15 times fewer points
   per direction than finite differences or linear finite elements; and the
   four-theory map (Fourier / Lord-Shulman / DPL / Green-Naghdi) charts where
   the theories diverge for this class of structures.
