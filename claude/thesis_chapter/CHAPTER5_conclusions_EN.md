<!-- CHAPTER5_conclusions_EN — English mirror of CHAPTER5_conclusions_FA.
     Drawn from Chapter 4 findings (RESULTS_CHAPTER_FA/EN_R4.4). §5-2/5-3
     numbers re-aligned 2026-08-22 to match the FA chapter exactly (were
     stale pre-R4.4 figures until then — see DECISIONS_NEEDED.md item 10).
     Length/thickness symbols: L = length, h = thickness, applied throughout.
     All figures are taken from chapter_stats.csv. -->

# Chapter 5: Conclusions and Recommendations

## 5-1. Introduction

In this thesis, the transient thermoelastic behavior of a multilayer porous
GPL-reinforced hollow cylinder under thermo-mechanical loading was solved in
fully coupled form, based on the generalized Lord-Shulman theory, using the
layerwise differential quadrature method in space and Newmark integration in
time. The developed solver was verified through five independent tests and its
convergence with respect to the number of layers and the spatial discretization
was established; an extensive set of parametric studies and three extension
studies were then carried out. This chapter summarizes the main findings, the
contributions, and the recommendations for future work.

## 5-2. Main findings

1. **Thermal wave and temperature overshoot.** Unlike classical Fourier
   conduction, in which the mid-wall temperature never exceeds the driving
   value, the Lord-Shulman theory permits a temperature overshoot (above unity)
   because of its finite wave-propagation speed. In the reference case the peak
   mid-wall temperature is 0.926 and does not exceed unity, but a genuine
   overshoot appears in cases such as porosity pattern V (1.109) and a high GPL
   weight fraction (up to 1.115). The temperature histories show the
   characteristic "peak-trough" shape produced by the wave travelling back and
   forth and reflecting from the outer surface, a phenomenon decisive in
   short-time analyses.

2. **GPL distribution pattern.** Placing the conductive platelets at the heated
   inner surface (pattern V) gives the most favorable behavior, lowering the
   peak temperature by about 29 % relative to the uniform case and the
   inner-surface hoop stress by about 3 times. Pattern A is the mirror image
   of V and the worst case in all three quantities (temperature, stress and
   displacement).

3. **Porosity pattern and level.** Porosity pattern A, concentrating the pores
   at the outer surface, acts as a "thermal barrier" and reduces the
   outer-surface temperature by about 8 times, but it also reverses the sign
   of the inner-surface hoop stress. Pattern V concentrates the pores at the
   inner surface and produces the largest transient peak of the group (1.11).

4. **Synergetic GPL-porosity interaction.** Combining GPL-V (conductive facing
   the heat source) with porosity-A (insulating facing the environment) is
   synergetic and reduces the outer-surface temperature by about **26-fold**
   at a benign stress level; this combination is the design recommendation of
   this work for thermal-protection applications. The complete 5×5 matrix showed
   that the mirror patterns V and A can be synergetic (GPL-V with porosity-A →
   0.034) or cancelling (GPL-V with porosity-V → 0.692), so the alignment or
   opposition of the two patterns is decisive.

5. **Weight fraction and percolation threshold.** A percolation threshold near a
   1 % weight fraction switches the wall from a "thermal insulator" to a
   "thermal conductor"; adding graphene beyond that improves the thermal
   penetration only smoothly but mainly raises the thermal stresses (the stress
   doubles at 8 %).

6. **Platelet aspect ratio.** At the (low) reference weight fraction, both
   aspect ratios have only a second-order effect, and the width-to-thickness
   ratio is the least influential of the two (under 2 % change in stress,
   negligible change in temperature); only at high GPL weight fractions does
   the width-to-thickness ratio become the dominant reinforcement lever.

7. **Coupling of the equations.** The fully coupled solution damps the thermal
   wave by about 1 % (thermoelastic damping); uncoupled models are
   non-conservative exactly at the wave fronts.

8. **Internal pressure and supports.** The internal pressure is a second-order
   effect at small engineering magnitude, but in the 70–100 MPa range it becomes
   a genuine secondary effect (up to about 50 % of the inner hoop stress); the
   response nonetheless remains thermally dominated and, in the present linear
   model, no discontinuity occurs up to 100 MPa. Clamped supports, by blocking
   axial expansion, reduce the peak mid-length radial displacement by about
   9 %; support effects are localized at the ends, and as the cylinder
   lengthens the mid-length response converges to the infinite-length limit.

9. **Impulsive thermal shock.** Under a Gaussian pulse, the classical theory
   underestimates the peak temperature by about **2.5 times** — one of the
   strongest arguments of this work in favor of the generalized theory.

10. **Methodological findings.** Newmark offers the best accuracy-to-cost ratio
    of the six tested integrators; differential quadrature needs about 15 times
    fewer points per direction than finite differences or linear finite
    elements; and the four-theory map (Fourier / Lord-Shulman / DPL /
    Green-Naghdi) charts where the theories diverge (the DPL degeneracy at
    $\tau_T=\tau_q$ and the persistent Green-Naghdi overshoot).

## 5-3. Contributions

- A fully coupled Lord-Shulman thermoelastic solution for the multilayer porous
  GPL-reinforced cylinder by a two-dimensional $(r,z)$ layerwise differential
  quadrature method.
- Identification of the synergetic interaction of the GPL-V and porosity-A
  patterns and presentation of the complete 5×5 interaction matrix, which has no
  counterpart in previous references.
- Reporting the "peak-trough" and mirror behavior of the patterns and linking it
  to the wave-like nature of the conduction.
- Three methodological extension studies: a comparison of six time integrators,
  four spatial discretizations (including linear/quadratic Galerkin finite
  elements) and four thermoelasticity theories with matched parameters.

## 5-4. Limitations of the study

As with any numerical study, this work was carried out within a specific set of
assumptions and boundaries that should be kept in mind when interpreting or
generalizing the results:

1. **Linear elastic model, no damage/failure criterion.** Stresses and
   displacements throughout this work — including under large loads such as a
   100 MPa internal pressure or an impulsive thermal shock — are reported under
   the linear-elasticity assumption. The model has no yield, cracking, or
   interlayer-separation criterion; under very large loads, the results should
   therefore be read as the mathematical extrapolation of a linear model, not a
   prediction of actual material failure.
2. **Temperature-independent material properties.** Young's modulus, thermal
   conductivity, the thermal expansion coefficient, and specific heat are held
   constant throughout the solution, while the reference loading takes the
   inner-surface temperature from 300 to 600 K; over this range, the real
   temperature-dependence of the material properties is not negligible.
3. **Isotropic homogenization of the composite layer.** The elastic matrix of the
   GPL-matrix layer is reduced to a single effective isotropic modulus via the
   Halpin-Tsai average ($E_s=\tfrac38 E_L+\tfrac58 E_T$); a real nanocomposite
   sheet is inherently transversely isotropic, and this simplification can shift
   the axial response somewhat.
4. **Ideal layer-to-layer bonding.** Interfaces between layers enforce full
   continuity of temperature, flux, displacement, and traction; the thermal and
   mechanical contact resistance that is always present in a real layered
   structure is not included in the model.
5. **Qualitative validation of the wave-propagation core.** The central claim of
   this work — the second-sound wave overshoot — is validated only qualitatively
   (matching the trend of speed and reflection) against the Bagri and Eslami
   results; no quantitative error metric is reported for this specific test.
6. **Selected porosity patterns.** The porosity patterns used (UD, O, X, V, A)
   were chosen based on the standard open-cell metal-foam model; this is a
   deliberate modeling choice, not a complete representation of every possible
   porous microstructure.
7. **Geometric and loading scope.** The study is limited to a straight cylindrical
   shell with simple/clamped/mixed supports and axisymmetric thermo-mechanical
   loading; conical or rotating geometries, non-axisymmetric loading, and fully
   three-dimensional effects lie outside the scope of this work.

## 5-5. Recommendations for future work

1. **Free/roller (F/R) supports:** a stable implementation of these supports and
   the addition of a true plane-strain reference for a direct comparison with
   the infinite-length limit.
2. **Vectorized assembly:** rewriting the assembly loop in vectorized form to
   reduce the computation time for larger grids and broader parametric studies.
3. **Temperature-dependent material properties:** including the dependence of the
   modulus, conductivity and expansion coefficient on temperature, which is
   significant over the 300–600 K range.
4. **Radiation boundary condition:** adding nonlinear radiative heat exchange at
   the outer surface for high-temperature applications.
5. **Damage/failure model:** since the present linear thermoelastic model shows
   no discontinuity even at 100 MPa, adding a damage or failure model is
   necessary to predict rupture (material failure/separation) under very high
   loads.
6. **Updated porosity patterns:** replacing the porosity patterns with the new
   patterns of the reference file and re-running the porosity and interaction
   studies.
7. **Geometric and loading extensions:** functionally graded continuous
   distributions, other platelet geometries, a rotating cylinder, and
   three-dimensional effects.
