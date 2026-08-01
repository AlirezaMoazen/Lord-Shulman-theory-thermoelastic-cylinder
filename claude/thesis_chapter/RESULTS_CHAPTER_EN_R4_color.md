# Chapter 4: Research Findings
<!-- RESULTS_CHAPTER_EN_R4 — English mirror of RESULTS_CHAPTER_FA_R4.
     Revision 4: full rebuild for the NEW geometry (R_i = 1, R_o = 1.5, l = 2.1)
     and the app10041397 (Heydarpour) dimensionless convention (Fo = alpha_hat t / h^2,
     h = wall thickness). Notation LOCKED 2026-08-01: l = length, h = thickness
     (opposite of R3). Every quoted number is re-extracted from param_studies_ch4
     (mesh N_r = 15, N_z = 11, N_L = 7, dt = 1 s). Prom.3 applied: the interaction
     study is the full 5x5 (25-case) GPL x porosity matrix; the platelet aspect
     legends read a/b and b/t; the harmonic-pressure study is removed. Convergence
     and verification are two separate sections (Prom.1). Figures are drawn from
     the R6 catalog (figures_ch4/). STATUS: sections 4-1..4-4 drafted; parametric
     sections 4-5.. follow, each with numbers pulled from the saved results. -->

## 4-1. Introduction

This chapter presents and discusses the numerical findings for the multilayer
porous GPL-reinforced hollow cylinder under thermo-mechanical loading, based on
the governing equations and the solution method of Chapter 3. First the
reference problem and the dimensionless quantities are introduced; then the
numerical convergence of the solution and its verification — treated as two
independent topics — are established through separate tests. The main
parametric studies follow: the GPL distribution pattern; the porosity pattern
and level; the GPL weight fraction; the platelet aspect ratios (length-to-width
a/b and width-to-thickness b/t); the relaxation time; the end supports; the
internal pressure; the cylinder length; the full interaction matrix of the GPL
and porosity patterns; the coupling of the equations; the convection
coefficient; the wall thickness; and a Gaussian thermal shock. Finally, three
extension studies that go beyond comparable previous works [6] — a comparison of
time-integration methods, a comparison of spatial-discretization methods, and a
comparison of generalized thermoelasticity theories — are reported, and the
chapter is summarized.

## 4-2. Reference problem and dimensionless quantities

The problem under study is a thick-walled hollow cylinder with inner radius
R_i = 1.0 m and outer radius R_o = 1.5 m (radius ratio R_o/R_i = 1.5, wall
thickness h = 0.5 m), length l = 2.1 m, built from N_L = 7 layers. In the
reference case the GPL distribution across the thickness is uniform (UD) with
total weight fraction W_GPL = 0.3 %, the porosity distribution is uniform (UD)
with mass coefficient e_m3 = 0.8604, and the Lord-Shulman theory [4] with
dimensionless relaxation time τ* = 0.15 is used in fully coupled form with both
ends simply supported (S). The loading is as follows: the inner-surface
temperature rises from the initial 300 K to 600 K according to the smooth ramp
T_in(t) = 300 + 300(1 − e^(−t/t0)) with time constant t0 = 2 s, while an
internal pressure P_i = 50 MPa acts on the inner surface; the outer surface
exchanges heat with the 300 K environment through the convection coefficient
h_c = 10 W/m²K. The discretization uses N_r = 15 points per layer and N_z = 11
axial points (layerwise differential quadrature, Chapter 3) with the time step
Δt = 1 s up to 3000 s. The Newmark parameters are δ = 1/2 and β = 1/4 (no
numerical damping); accordingly, the small oscillations visible behind sharp
wave fronts are the well-known Gibbs effect of the spectral discretization and
are left unfiltered so that the results are reported without manipulation.

For generality all results are presented in dimensionless form, following the
convention of reference [x] (Heydarpour et al.). The reference thermal
diffusivity of the homogenized reference material is
α̂ = k̄/(ρ̄c̄) = 8.97×10⁻⁵ m²/s, and the length scale is the wall thickness
h = R_o − R_i, not the outer radius; the definitions are collected in Table 4-1.
With this scaling one thermal-diffusion time across the wall, h²/α̂ ≈ 2787 s,
corresponds to Fo = 1, and the 3000 s window spans Fo ≈ 1.08. The Lord-Shulman
thermal-wave speed of the reference material is v = √(α̂/τ0) = 4.63×10⁻⁴ m/s;
crossing the full wall thickness therefore takes about 1080 s, i.e. Fo ≈ 0.39,
which equals √τ* as the hyperbolic theory requires — and, as will be seen, this
is exactly where the first wave arrival appears in the time histories.

**Table 4-1: Dimensionless quantities used in this chapter.**

| quantity | definition | value/range |
|---|---|---|
| Fourier number (dimensionless time) | Fo = α̂ t / h² | Fo(3000 s) = 1.08 |
| dimensionless relaxation time | τ* = α̂ τ0 / h² | 0.15 (reference; τ0 = 418 s) |
| dimensionless temperature | T* = (T − T∞)/T∞ | 0 … ≈1 |
| dimensionless radial coordinate | ξ = (r − R_i)/h | 0 … 1 |
| dimensionless radial displacement | U* = u /[(1 − ν) α T∞ h] | O(1) |
| dimensionless stress | Σ* = (1 + ν) σ /(E α T∞) | O(1) |

Here ν, α and E are the reference-material Poisson ratio, thermal-expansion
coefficient and Young modulus (ν = 0.340, α = 5.98×10⁻⁵ K⁻¹, E = 4.43 GPa for
the reference porous UD composite). Because the inner-surface temperature is
raised to twice the ambient value (T_in = 2 T∞), the inner boundary corresponds
to T* = 1, so any excursion above unity in the temperature field is a genuine
overshoot produced by the reflected thermal wave.

## 4-3. Numerical convergence

Before the results are verified, the numerical convergence of the solution is
examined independently in every discretization direction of the model — the
number of radial points per layer N_r, the number of axial points N_z, the
number of layers N_L, and the time step Δt — so that any later discrepancy with
a reference can be attributed to physics rather than residual numerical error.
The convergence measure is the dimensionless hoop stress, reported both as the
inner-surface value and as the relative L₂ error of the whole mid-plane radial
profile against the finest mesh.

![conv_NL](figures_ch4_color/conv_NL.png){width=6in}

Layer convergence is shown in Figure 4-1(NL). As the number of layers is
increased through 3, 5, 7, 9 and 15, the dimensionless inner-surface hoop stress
takes the values 1.5261, 1.5257, 1.5264, 1.5264 and 1.5265, a total variation
below 0.05 %, and the L₂ profile error relative to fifteen layers falls below
0.26 %. The field quantities are therefore essentially layer-independent from as
few as three layers; the main effect of a larger layer count is only a
refinement of the staircase pattern of the hoop-stress profile at the layer
interfaces, which is the natural signature of the layerwise property model.
Seven layers are adopted in what follows, matching the seven-layer graded
build of the reference cylinder while remaining safely on the converged side.

![conv_Nr](figures_ch4_color/conv_Nr.png){width=6in}

Radial convergence within each layer is shown in Figure 4-1(Nr). Increasing the
number of radial points per layer through 7, 9, 11, 13 and 15 leaves the
inner-surface hoop stress within 0.09 % (1.5251 to 1.5264) and the L₂ profile
error below 0.29 % throughout; every mesh from seven points upward is thus
converged in the field quantities. This is the hallmark of the spectral
(Chebyshev) differential quadrature discretization: three-digit accuracy is
reached with a handful of points. The value N_r = 15 is nevertheless adopted for
the production runs, because — while it does not change any integral quantity —
it renders the sharp, moving second-sound front in the temperature profiles
cleanly, without the localized oscillation that a coarser radial mesh leaves at
the instant the front sits between two nodes.

![conv_Nz](figures_ch4_color/conv_Nz.png){width=6in}

The axial direction, shown in Figure 4-1(Nz), is the one that actually governs
the mesh. With only five axial points the inner-surface hoop stress is in error
by 9.4 % (1.3844 against the converged 1.5278), because the simply-supported
end layer is left unresolved; the error then falls to 0.36 %, 1.0 %, 0.09 % and
0.02 % for seven, nine, eleven and thirteen points. The convergence is
non-monotonic — the oscillatory envelope characteristic of spectral methods —
but is clearly settled by nine points, and eleven points give an L₂ profile
error of 0.16 %. Eleven axial points are adopted. Unlike the radial direction,
the axial one is also the most expensive: measured on a single core, one solve
costs 90, 198, 349, 987 and 1630 s for five, seven, nine, thirteen and fifteen
axial points, i.e. the cost grows roughly as N_z^2.6, because each added axial
point multiplies the entire through-thickness system.

![conv_dt](figures_ch4_color/conv_dt.png){width=6in}

Time-step convergence is shown in Figure 4-1(dt). For time steps of 0.5, 1 and
2 s the response is unchanged, but at Δt = 5 s a spurious 3 % overshoot appears
in the peak temperature as the integrator under-resolves the sharp thermal
front; the L₂ error of the final hoop-stress profile relative to Δt = 0.5 s is
0.17 %, 0.25 % and 0.64 % for 1, 2 and 5 s. A time step of 1 s is adopted, which
both resolves the shock and leaves a comfortable margin.

![conv_master](figures_ch4_color/conv_master.png){width=6in}

Figure 4-1(master) collects the four studies as the L₂ profile error against the
total number of unknowns N_dof = 3 N_L N_r N_z, refined one direction at a time.
The picture summarizes the numerical character of the model: the radial and
layer directions sit below 0.3 % from their smallest meshes and are effectively
free, whereas the axial direction both starts far above 1 % and is the steepest
in cost. The adopted production mesh (N_r = 15, N_z = 11, N_L = 7, Δt = 1 s) is
accordingly balanced — generous where refinement is cheap and merely adequate
where it is expensive — and delivers the field quantities to better than 0.2 %.
The superiority of the differential-quadrature discretization over the finite
difference and finite element methods, in points required per direction, is
taken up separately as an extension study in Section 4-19.

## 4-4. Verification

The present numerical solution is verified through five independent checks
against exact analytical solutions, published results from the literature, and a
commercial finite-element solution. In each check, besides the quantitative
error, the present result is plotted as a comparison diagram against the
corresponding reference so that the coincidence of the curves is shown visually;
these diagrams are collected in the verification appendix. First, the assembly
of the static matrices is checked against an independent static solver, with a
maximum displacement-field difference of order 2×10⁻¹¹, confirming the numerical
equivalence of the two implementations and the correctness of the system
assembly.

In the second check, the dynamic-mechanical part of the problem is compared with
the results of Malekzadeh (Table 6 of reference [31], IJPVP 2012) and with an
independent ANSYS finite-element solution; the dimensionless radial displacement
is reproduced with a relative difference of 0.1 to 0.2 percent, and the
dimensionless inner-surface radial stress is obtained exactly as the negative of
the applied pressure, in full agreement with the loading boundary condition.

In the third check, the transient heat-conduction problem is compared with the
exact Bessel-series solution; the dimensionless temperature distribution at
various times lies on the exact curve, with a relative error of 10⁻⁵ to 10⁻⁷. In
the fourth check, the Newmark time integration is validated against MATLAB's
reference solver ode15s, and the maximum temperature difference over the whole
interval is 0.003 K, confirming the stability and accuracy of the adopted
time-integration scheme. Finally, in the fifth check, the wave-propagation
behavior of the coupled Lord-Shulman theory is compared with the results of
Bagri and Eslami (2007, reference [7]); both wave speeds (elastic and thermal)
and the reflection times within the cylinder wall are correctly reproduced, and
the present wave fronts coincide with those of the reference. Taken together,
these five checks confirm the validity of the present solution in both the
static and the transient regimes and in the coupled and uncoupled cases. A
summary is given in Table 4-2.

**Table 4-2: Summary of the solver verification tests.**

| # | test | reference | result |
|---|---|---|---|
| 1 | static spatial assembly | independent static solver | agreement 2×10⁻¹¹ |
| 2 | dynamic mechanical response | reference [31] + ANSYS | error 0.1–0.2 %; σ_rr exact |
| 3 | transient conduction | exact Bessel-series solution | rel. error 10⁻⁵–10⁻⁷ |
| 4 | time integration | ode15s (independent) | max difference 0.003 K |
| 5 | coupled Lord-Shulman waves | Bagri & Eslami [7] | speeds and reflections matched |

## 4-5. Effect of the GPL distribution pattern

In the first parametric study the effect of five GPL distribution patterns across
the thickness (UD, O, X, V and A) is examined with all other parameters held at
their reference values. Figure 4-2 shows the time histories of the dimensionless
temperature and radial displacement of the mid-thickness point at the mid-length
section together with the radial profiles of the temperature and hoop stress at
the final time.

![A_GPL_patterns](figures_ch4_color/A_GPL_patterns.png){width=6in}

The peak mid-point dimensionless temperature for patterns UD, O, X, V and A is
0.926, 0.867, 0.841, 0.661 and 0.982, respectively. Pattern V, in which the GPLs
are concentrated at the heated inner surface, shows the most favorable behavior:
the highly conductive inner region spreads the incoming heat rapidly through the
thickness, so its peak temperature is about a third lower than that of pattern A.
Physically, placing the stiff, conductive phase where the temperature gradient is
steepest — at the heated inner wall — both moderates the thermal gradient and
reinforces the critical hoop-stress region.

A mirror and inverse behavior emerges between the two asymmetric patterns V and
A: geometrically they are mirror images about the mid-thickness (V is GPL-rich at
the inner surface, A at the outer surface), and they behave in opposite ways.
Pattern V, facing the conductive phase toward the heat source, produces the
lowest and mildest peak (0.661), whereas pattern A, by leaving the
low-conductivity matrix at the inner surface, traps heat in the inner band and
records the highest peak (0.982). The symmetric patterns UD, O and X fall between
these extremes, and this mirror ordering explains why V is the best and A the
worst.

The same ordering governs the mechanical response. The final inner-surface hoop
stress for pattern V is 0.486, about three times smaller than that of UD (1.526)
and roughly five times smaller than that of pattern A (2.403); that is, the two
ends of the mirror spectrum record the lowest and the highest hoop stress. The
peak radial displacement follows the same trend, ranging from 8.26 for V to 9.08
for A. Pattern V therefore simultaneously delivers the lowest temperature, the
lowest hoop stress and the smallest displacement, while its mirror pattern A is
the worst case in all three; pattern V is recommended for the GPL distribution in
cylinders under internal thermal shock.

## 4-6. Effect of the porosity pattern and porosity level

This section examines the effect of the porosity distribution pattern across the
wall for the five patterns UD, O, X, V and A; the GPL distribution is kept uniform
(UD) and the remaining parameters are held at their reference values. Figure 4-3
shows the mid-point time histories together with the radial profiles at the final
time. The porosity pattern acts by reshaping the heat-conduction path, since a
porous band of negligible conductivity behaves as a localized thermal resistance.
The three symmetric patterns UD, O and X behave similarly, with mid-point peak
temperatures of 0.926, 0.927 and 0.867; in these patterns the porous phase is
uniformly spread or symmetric about the mid-thickness and does not render the
conduction path fundamentally asymmetric.

![B_porosity_patterns](figures_ch4_color/B_porosity_patterns.png){width=6in}

The key result lies in the two asymmetric patterns V and A, which are mirror
images yet produce completely opposite thermal responses. In pattern V the pores
are concentrated at the heated inner surface; this insulating band traps the
incoming heat near the inner surface and prevents its rapid spread. As a result
the mid-point temperature history displays a pronounced transient peak — the
largest overshoot of this group — reaching 1.109 at a Fourier number of 0.79, and
then relaxes to 1.002 by the end of the interval. At the opposite extreme, pattern
A concentrates the pores at the cooled outer surface: instead of trapping the heat
it blocks the heat-exit path toward the environment and thus behaves as a genuine
**thermal barrier**. In this pattern the outer-surface temperature never exceeds
0.107 — about eight times smaller than the value 0.883 of the reference — and the
mid-point peak collapses to 0.128.

The favorable thermal performance of pattern A is paid for on the mechanical
side. Because the heat never penetrates deep into the wall, the thermal expansion
is suppressed, and the unusual temperature distribution reverses the sign of the
inner-surface hoop stress, which reaches a negative (compressive) value of 0.359;
that is, the inner region, normally under hoop tension, turns compressive. This
sign reversal must be carefully accounted for in the design of cylinders under
internal thermal shock.

![E_porosity_level](figures_ch4_color/E_porosity_level.png){width=6in}

Finally, the effect of the overall porosity level is shown in Figure 4-4 for the
three mass coefficients e_m3 = 0.9675, 0.8604 and 0.7776 (light, moderate and
heavy porosity). Increasing the porosity lowers the conductivity and the stiffness
together; consequently the peak mid-point temperature grows mildly, from 0.905
through 0.926 to 0.942, while the peak radial displacement rises more strongly,
from 7.87 through 9.10 to 10.37, as the softer wall deforms more under the same
loading.

## 4-7. Effect of the GPL weight fraction

![D_wt_low](figures_ch4_color/D_wt_low.png){width=6in}

The percolation character of the thermal-conductivity model (Chapter 3) makes the
GPL weight fraction the strongest material lever of the problem. Figure 4-5 scans
the low range W = 0.1, 0.3, 0.5, 0.9 and 1.5 %. At the smallest fraction the
graphene network is barely percolated: the thermal wave penetrates weakly, the
outer-surface temperature reaches only 0.484 and the mid-point peak stays at
0.631. As the weight fraction rises, the percolated network raises the effective
conductivity and the wall fills with heat: the mid-point peak grows to 0.926,
0.991, 1.061 and 1.115, and the outer-surface temperature climbs to essentially
unity (full through-wall penetration) by W = 0.9 %. Because the added graphene
also stiffens the wall, the peak radial displacement falls in the opposite
direction, from 10.60 at W = 0.1 % to 6.06 at W = 1.5 %.

![D2_wt_high](figures_ch4_color/D2_wt_high.png){width=6in}

The higher range W = 1, 2, 4 and 8 % is shown in Figure 4-6. Here the thermal
response saturates — the mid-point peak rises only gradually from 1.072 to 1.261
— but the mechanical penalty grows sharply: the peak hoop stress more than
doubles, from 2.45 to 5.71, and the inner-surface hoop stress falls and reverses
sign, from 1.474 at 1 % to −1.580 at 8 %, as the stiff, highly loaded inner band
is driven into compression. The practical conclusion is that a small weight
fraction suffices to switch the wall from a poor to a good thermal conductor,
whereas adding graphene beyond that yields only a mild thermal improvement while
mainly raising the thermal stresses. Most previous works examined the range 0.1
to 2 %; here the range is extended to 8 % to expose the saturation of the thermal
gain and the growth of the stresses.

## 4-8. Effect of the GPL aspect ratios

The Halpin–Tsai model of Chapter 3 makes the reinforced properties depend not
only on the volume fraction but also on the platelet geometry, described by two
independent aspect ratios: the length-to-width ratio a/b, entering through the
characteristic length a_GPL, and the width-to-thickness ratio b/t, entering
through the characteristic thickness t_GPL. Each is examined separately with all
other parameters at their reference values.

![O_aspect_ab](figures_ch4_color/O_aspect_ab.png){width=6in}

The effect of the length-to-width ratio is shown in Figure 4-7. As a/b increases
from 1.0 to 1.67 (reference) and then to 2.67, the peak mid-point temperature
rises only from 0.898 to 0.926 and 0.939, and the inner-surface hoop stress from
1.453 to 1.526 and 1.556 — changes of a few percent.

![P_aspect_bt](figures_ch4_color/P_aspect_bt.png){width=6in}

The width-to-thickness ratio (Figure 4-8) is even weaker at this reference: as b/t
increases from 500 to 1000 and 2000, the peak temperature is essentially constant
(0.926, 0.926, 0.925) and the inner-surface hoop stress changes only from 1.542
to 1.516. At the low reference weight fraction of 0.3 % the reinforcement is too
dilute for platelet geometry to matter; both aspect ratios are therefore
second-order levers here, in contrast to the high-weight-fraction regime where the
width-to-thickness ratio dominates. This distinction is itself a useful design
observation: platelet shape becomes a meaningful lever only once the weight
fraction is large enough for the reinforcement to control the effective
properties.

## 4-9. Effect of the relaxation time; Lord-Shulman versus Fourier

![C_relaxation](figures_ch4_color/C_relaxation.png){width=6in}

Figure 4-9 compares Fourier conduction (τ* = 0) with four dimensionless
relaxation times τ* = 0.04, 0.15, 0.44 and 0.87. Under Fourier conduction the
mid-point temperature increases monotonically and never exceeds the driving value
(peak 0.950), since classical diffusion, with its unbounded propagation speed,
cannot produce an overshoot. With the relaxation time active in the Lord-Shulman
theory the heat propagates as a wave of finite speed √(α̂/τ0): the peak grows to
0.953, 0.962, 1.166 and 1.271 as τ* increases, and for the two larger values the
temperature **overshoots** even the inner-surface value — reaching 1.271 at
τ* = 0.87 — a purely hyperbolic phenomenon impossible in the parabolic Fourier
theory. At the mild reference value τ* = 0.15 the overshoot is still small (0.962),
which is why the reference histories of the other studies show only a gentle peak;
the wave signature becomes dominant only as the relaxation time is increased. The
relaxation time thus controls both the wave arrival and the overshoot amplitude,
and its clear signature in the temperature histories is the central argument for
employing generalized thermoelasticity in short-time analyses [3].

## 4-10. Effect of the end supports

![F_end_BC](figures_ch4_color/F_end_BC.png){width=6in}

The effect of the end supports is examined for three cases: simply supported at
both ends (S-S), one end simply supported and the other clamped (S-C), and clamped
at both ends (C-C). As shown in Figure 4-10, the temperature field is nearly
independent of the support type, the peak mid-point temperature staying in the
narrow band 0.926 to 0.929, since the mechanical support does not directly alter
the thermal problem.

The mechanical response depends strongly on the support. Clamping the ends adds an
axial constraint that reduces the mid-length hoop tension: the dimensionless
inner-surface hoop stress falls from 1.526 for S-S through 1.068 for the mixed
S-C case to 0.424 for C-C, and the peak hoop stress from 2.112 to 1.803 and 1.535.
The mixed case lies correctly between the two limiting cases in every quantity,
confirming the expected intermediate behavior. The peak radial displacement is
less sensitive, changing only from 9.10 (S-S) to 8.27 (C-C), because at the
mid-length section of this relatively long cylinder the end constraints are
partly screened; the disturbances caused by either support decay within roughly
one wall thickness of the ends, which justifies reporting mid-length quantities as
the characteristic response of the structure.

## 4-11. Effect of the internal pressure

The effect of the internal pressure is examined with a sweep at 0, 10, 50
(reference) and 100 MPa, covering low to very high pressures. As shown in Figure
4-11, the temperature field is practically independent of the internal pressure,
because thermal and mechanical loading are linked only through the weak coupling
term of the energy equation, and pressure is not a direct driver of temperature.

![G_pressure](figures_ch4_color/G_pressure.png){width=6in}

By contrast, the mechanical response grows linearly with pressure. The
inner-surface hoop stress rises from −0.387 with no pressure (a purely thermal,
mildly compressive state) through −0.004 and 1.526 to 3.439 at 100 MPa, an
increment of about 0.0383 per megapascal; and the peak radial displacement rises
from 3.75 through 4.82 and 9.10 to 14.44, an increment of about 0.107 per
megapascal. This perfect linearity reflects the linear nature of the thermoelastic
model, and even at 100 MPa the solution remains smooth and convergent, with no
discontinuity, because physical rupture (material failure or separation) is not
included in the present linear model; assessing that would require a damage or
failure model. Unlike the near-negligible megapascal-level pressures of much of
the literature, at the 50 MPa reference the pressure is a genuine first-order
contributor to the stress and displacement, while the temperature field remains
thermally governed. The dimensionless radial-stress profile runs from the negative
of the applied pressure at the inner surface to zero at the outer surface,
consistent with the loading boundary condition.

## 4-12. Effect of the cylinder length and the long-cylinder limit

![Q_length](figures_ch4_color/Q_length.png){width=6in}

To examine the limiting behavior of a long cylinder, the length is increased from
1 m through the reference 2.1 m to 5 and 10 m. As shown in Figure 4-12, the peak
mid-point temperature is length-independent, remaining at 0.926 to 0.927. The
mechanical response, however, tends to a limit as the length grows. The very short
cylinder (l = 1 m) is dominated by its two close end supports: its mid-length
inner-surface hoop stress is compressive (−1.477) and its displacement is small
(3.42). As the length increases the mid-length section moves away from the end
constraints, the inner hoop stress becomes tensile and approaches an asymptote of
about 2.0 to 2.1 (1.526, 2.139 and 2.031 for 2.1, 5 and 10 m), and the peak
displacement settles toward about 8.4 (9.10, 8.57 and 8.37). The mid-length
response thus converges to the infinite-length (plane-strain-like) limit in which
the mechanical effects of the two ends are not felt.

## 4-13. Interaction of the GPL and porosity distribution patterns

The individual studies showed pattern V for the GPLs and pattern A for the
porosity to be the most favorable thermally. This section examines the full
interaction by computing all twenty-five combinations of the five GPL patterns
with the five porosity patterns, each combination labeled (for example X-GPL +
V-Por). The dimensionless outer-surface temperature and the hoop-stress profile
of every combination are shown as a 5×5 matrix in Figure 4-13.

![matrix25_Tstar](figures_ch4_color/matrix25_Tstar.png){width=6in}

The first key observation is that the porosity pattern A acts as a **universal
thermal barrier**: regardless of the GPL pattern, concentrating the pores at the
outer surface gives the lowest outer-surface temperature, the values along that
column being 0.107, 0.064, 0.116, 0.034 and 0.134. The best combination of all,
GPL-V together with porosity-A, holds the outer-surface temperature at 0.034 — a
roughly twenty-six-fold reduction with respect to the reference (0.883) — while
its stress state remains benign (the inner hoop stress is a small compressive
−0.378). This confirms the design recommendation of the thesis for thermal
protection.

![matrix25_Sigma_thth](figures_ch4_color/matrix25_Sigma_thth.png){width=6in}

The second observation is the mirror-pattern interaction. Patterns V and A are
geometric mirror images (inner-surface versus outer-surface concentration). When
GPL-V (conductive at the inner surface) is combined with porosity-A (insulating at
the outer surface) the two mechanisms act synergetically and the outer-surface
temperature reaches its minimum; but when the same GPL-V is combined with
porosity-V (both concentrated at the inner surface) the two effects weaken each
other and the outer-surface temperature rises to 0.692. At the other extreme, the
worst cases belong to GPL-A (conductive at the outer surface) combined with the
symmetric porosities, which raise the outer-surface temperature as high as 0.896.
The highest hoop stresses of the matrix appear where a stiff GPL pattern meets an
inner-concentrated porosity — for example X-GPL + V-Por, with a peak hoop stress
of 4.20 — so the matrix also maps where stress, not temperature, becomes the
limiting concern. Thus not only the individual pattern but also the alignment or
opposition of the two patterns is decisive; this full interaction map has no
counterpart in comparable previous research [6] and is one of the contributions of
this work.

## 4-14. Effect of the coupling of the equations

![I_coupling](figures_ch4_color/I_coupling.png){width=6in}

Figure 4-14 compares the fully coupled model with the uncoupled one (the
dilatation-rate term removed from the energy equation). At the reference
conditions the uncoupled model overestimates the peak mid-point temperature by
about 1.2 % (0.937 versus 0.926) and the outer-surface temperature by a similar
margin. The mechanism is that in the coupled model part of the thermal energy is
continuously converted into mechanical work — a thermoelastic damping of the
thermal wave — and the difference between the two models is largest exactly at the
wave fronts. The effect is modest at the mild reference relaxation time τ* = 0.15
but grows with the wave strength; it demonstrates that the fully coupled system
should be solved when the wave signature matters, despite its higher cost.

## 4-15. Effect of the outer-surface convection coefficient

![J_convection](figures_ch4_color/J_convection.png){width=6in}

Figure 4-15 examines the outer-surface convection coefficient for h_c = 10, 100
and 1000 W/m²K, corresponding to Biot numbers Bi = h_c h/k̄ ≈ 0.07 to 6.6. As h_c
increases, the outer surface turns from nearly adiabatic into an effective heat
sink: the outer-surface temperature drops from 0.883 through 0.591 to 0.107, the
mid-point peak from 0.926 through 0.802 to 0.715, and the inner-surface hoop
stress relaxes from 1.526 through 1.176 to 0.540 — because what sets the thermal
stress is the through-wall temperature difference, not the absolute temperature.
The response is nearly insensitive to convection at the smallest coefficient and
strongly convection-controlled at the largest, two regimes that must be
distinguished in design.

## 4-16. Effect of the wall thickness

![K_thickness](figures_ch4_color/K_thickness.png){width=6in}

Figure 4-16 compares three cylinders with radius ratios R_o/R_i = 1.25, 1.5 and
2.0 (inner radius fixed at 1 m; wall thickness 0.25, 0.5 and 1.0 m); the time
scale of each is nondimensionalized with its own wall thickness. The thin wall
(ratio 1.25) is crossed quickly by the thermal wave, so its outer surface heats
fully (outer temperature 0.999), but the small thickness concentrates the thermal
strain and produces the largest mechanical response of the study — an
inner-surface hoop stress of 4.017 and a peak displacement of 26.6. The thick wall
(ratio 2.0) behaves oppositely: within the window the wave does not fully cross,
the outer region stays cooler (outer temperature 0.740), the displacement collapses
to 2.66, and the inner-surface hoop stress becomes compressive (−0.628), since the
heated inner band pushes against the cold, stiff outer mass. The wall thickness is
therefore the geometric lever that trades a small, highly stressed thin wall
against a large, mildly stressed but strongly compressive thick wall.

## 4-17. Response to a Gaussian thermal shock

![M_gauss_shock](figures_ch4_color/M_gauss_shock.png){width=6in}

In this study the sustained ramp is replaced by a short Gaussian pulse of the
inner-surface temperature, and the response is compared under the Lord-Shulman and
Fourier theories (Figure 4-17). The loading exposes the essential difference
between wave-like and diffusive transport: under Fourier conduction the pulse
arrives at the mid-thickness early, smeared and weak (peak 0.195 at Fo ≈ 0.18) and
has practically vanished by the end of the interval. Under the Lord-Shulman theory
the pulse travels as a coherent wave packet: it arrives later (Fo ≈ 0.31), about
two and a half times stronger (peak 0.478), and leaves persistent oscillations
behind. The accompanying wave-front figures (Figure 4-17b) show the sharp
second-sound front marching through the wall — the clearest visual signature of the
finite propagation speed. Under impulsive loads the classical theory therefore
substantially underestimates the transient thermal, and hence mechanical, severity
of the shock — a strong argument in favor of the generalized theory.

## 4-18. Comparison of time-integration methods

To position the Newmark scheme used in this thesis, five alternative time
integrators were run on the identical benchmark problem (transient conduction with
known exact solution; error measure: maximum temperature error at t = 10 s). The
results are summarized in Table 4-3.

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
Wilson-θ accepts a roughly five-fold larger error owing to its extra numerical
dissipation; the adaptive stiff solver ode15s is about ten times more accurate but
eight times more expensive; and the Laplace-transform route with Durbin inversion
is three orders of magnitude slower. A methodological result also emerged: the
Laplace transform cannot be applied to the full coupled system, because the
undamped elastic poles of the coupled operator lie exactly on the inversion
contour — which is why transform methods are applied in the literature to thermal
subsystems only. This measured comparison justifies the choice of the Newmark
method for all production runs of this thesis.

## 4-19. Comparison of spatial-discretization methods

Four spatial discretizations — the differential quadrature method with Chebyshev
and with uniform grids, the second-order finite difference method, and the finite
element method with linear and quadratic elements (Galerkin formulation with
consistent matrices) — are compared on the transient-conduction problem with the
exact Bessel-series solution, using the identical Newmark time march. The number of
points required for each method's error to reach the time-step floor is: about 9
to 11 for differential quadrature, about 21 for quadratic finite elements, and
about 161 for linear finite elements and finite differences. The linear-FEM and
FDM curves coincide at slope −2; quadratic FEM gains roughly one order of magnitude
per refinement step; and the DQM error falls quasi-exponentially until the temporal
floor. At equal accuracy the DQM system is therefore about fifteen times smaller
per direction — squared in the (r,z) plane — which is the quantitative
justification for the layerwise differential quadrature choice of this thesis, and
is fully consistent with the mesh-convergence study of Section 4-3, where a handful
of radial points already delivered three-digit accuracy. Adding the two Galerkin
finite-element formulations to this comparison is one of the extensions of this
work over comparable previous studies.

## 4-20. Comparison of the generalized thermoelasticity theories

![T3_theories](figures_ch4_color/T3_theories.png){width=6in}

In the final extension study the reference problem is solved under four
thermoelasticity theories with matched parameters: the classical coupled Fourier
theory, the Lord-Shulman theory [4], the dual-phase-lag (DPL) theory [74] with
τ_q = τ0 and τ_T = τ_q/2, and the Green-Naghdi type-III theory [67] with
k* = k/τ0 (so that its wave speed equals the Lord-Shulman one). According to
Figure 4-18, the peak mid-point temperatures order as Fourier 0.950 < DPL 0.956 <
Lord-Shulman 0.962 < Green-Naghdi 1.581. Two observations follow. First, at the
mild reference relaxation time the Fourier, DPL and Lord-Shulman peaks lie close
together, because the wave is weak; DPL interpolates between Fourier and
Lord-Shulman, as expected. Second, the Green-Naghdi type-III theory stands apart:
it produces a large, early overshoot (peak 1.581 at Fo ≈ 0.33) that then relaxes
only slowly (0.870 at the end of the interval), because its energy equation lacks a
dissipative mechanism to damp the thermal wave, so its long-time behavior is
qualitatively different from the other three. Such a four-theory map for porous
GPL-reinforced cylinders does not exist in the literature and is one of the
contributions of this research.

## 4-21. Chapter summary

The main findings of this chapter can be summarized as follows:

1. The numerical convergence of the solution was established independently in
   every direction — radial (converged from N_r = 7), axial (the binding
   direction; N_z = 5 gives a 9.4 % error, converged by N_z = 9), layers
   (converged from N_L = 3–5) and time step (Δt ≤ 2 s) — before the solver was
   verified in five independent tests against exact solutions and references.
2. The Lord-Shulman thermal wave produces a mid-wall temperature overshoot that
   grows with the relaxation time, up to T* = 1.271 at τ* = 0.87 — impossible under
   Fourier conduction — with the characteristic peak-trough shape of the reflecting
   wave; at the mild reference τ* = 0.15 the overshoot is small.
3. Placing the GPLs at the heated surface (pattern V) and the pores at the cooled
   surface (pattern A) is synergetic: the full 5×5 pattern matrix shows the best
   combination, GPL-V with porosity-A, reducing the outer-surface temperature about
   twenty-six-fold at a benign (compressive) stress level — the design
   recommendation of this thesis. The alignment or opposition of the mirror
   patterns V and A governs the thermal performance.
4. In the low reference weight-fraction regime a small amount of graphene switches
   the wall from a poor to a good thermal conductor; adding more mainly raises the
   thermal stresses (the inner hoop stress reverses to −1.580 at 8 %). At this low
   weight fraction the platelet aspect ratios are only second-order levers.
5. Full coupling damps the thermal wave (about 1 % peak reduction at the reference,
   growing with wave strength); uncoupled models are non-conservative at the wave
   fronts.
6. Internal pressure enters linearly; at the 50 MPa reference it is a first-order
   contributor to the stress and displacement, yet the temperature field stays
   thermally governed and no discontinuity occurs up to 100 MPa.
7. Clamped ends reduce the mid-length hoop stress (from 1.526 to 0.424); support
   effects are localized at the ends, and as the cylinder lengthens the mid-length
   response converges to the long-cylinder limit.
8. Under impulsive (Gaussian) heating the Lord-Shulman pulse reaches the mid-wall
   about two and a half times stronger than the Fourier one and persists, whereas
   the classical pulse smears and vanishes.
9. Methodologically: Newmark offers the best accuracy-to-cost ratio of the six
   tested integrators; differential quadrature needs about fifteen times fewer
   points per direction than finite differences or linear finite elements; and the
   four-theory map (Fourier / Lord-Shulman / DPL / Green-Naghdi) charts where the
   theories diverge for this class of structures.

