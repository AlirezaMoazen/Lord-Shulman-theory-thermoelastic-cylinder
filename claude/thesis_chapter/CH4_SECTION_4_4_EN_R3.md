---
dir: ltr
lang: en-US
---

<!-- CH4_SECTION_4_4_EN_R3 — Figure 4-5 revision (2026-10-07, author request).
     Mirrors CH4_SECTION_4_4_FA_R4: the right-hand (difference) panel of Figure
     4-5 is DELETED, leaving the displacement panel alone (the maximum absolute
     and relative differences are already in Table 4-7, so that panel duplicated
     the table). The Test 1 text and the caption are reworded for a single panel
     (the reference to the difference panel is dropped and pointed at Table 4-7).
     Figure width 16 -> 12 cm, matching Figure 4-8. Figure file:
     verif_test1_static_R3. Rest of the section unchanged. R2 frozen. -->

<!-- CH4_SECTION_4_4_EN_R2 — figure revision (2026-10-07, author request).
     Mirrors CH4_SECTION_4_4_FA_R3: Figure 4-5 now carries a legend on BOTH
     panels, both panels share the Chapter-4 colour set, and tight
     TileSpacing/Padding removes the margin between the side panel and the
     figure border; Figure 4-8 has its error panel DELETED, leaving the
     temperature-history panel alone (both maximum errors are already in Table
     4-8, so that panel duplicated the table); both figures now follow the
     catalog_R11 house style. Panel references changed from left/right to
     content names. Figure files: verif_test1_static_R2 and
     verif_test4_integrator_R2. R1 frozen. -->

<!-- CH4_SECTION_4_4_EN_R1 — English mirror of CH4_SECTION_4_4_FA_R2.
     Author request (2026-10-07): translate section 4-4.
     Same structure as the Persian R2: clean section text with the summary
     Table 4-6 first, then one numbered subsection per test (4-4-1 … 4-4-5)
     each in a fixed text → figure → caption → table order, a 4-4-6 summary,
     and all implementation notes moved below a separator at the end.
     All five figures are embedded; image paths are relative to the claude/
     folder (CHAPTER3_formulation convention), so pandoc must be run from
     claude/ or the images are silently dropped. -->

## 4-4. Verification

The present numerical solution is verified through five independent checks, each
against either an exact analytical solution, published results, or a commercial
finite-element solution. In every check, besides the quantitative error, the
present result is plotted against the corresponding reference so that the
coincidence of the curves can be seen. Table 4-6 gives the overview of all five
checks, and the subsections that follow treat each one separately.

**Table 4-6. Summary of the solver verification tests.**

| # | test | reference | result |
|---|---|---|---|
| 1 | static spatial assembly | independent static solver | agreement 2.20×10⁻¹¹ |
| 2 | dynamic mechanical response | reference [31] + ANSYS | error 0.1–0.2 %; σ_rr exact |
| 3 | transient heat conduction | exact Bessel-series solution | relative error 10⁻⁵–10⁻⁷ |
| 4 | time integration | adaptive stiff solver (independent) | max difference 0.0034 K |
| 5 | coupled Lord–Shulman waves | exact Fourier–Bessel solution | pointwise error 0.32 %; L₂ 0.065 % |

### 4-4-1. Test 1 — assembly of the static matrices

The static limit of the dynamic solver is checked against an independent static
solver. That independent solver is a separate code with its own assembly, which
carries no time term at all and solves the two algebraic systems of steady
conduction and elastostatic equilibrium directly; the loading is internal
pressure only and the ends are free. Figure 4-5 shows the two
mid-span radial-displacement curves lying on top of one another, and their maximum
difference across the whole wall thickness, given in Table 4-7, is at
machine-precision level. The test confirms both the numerical equivalence of the two
implementations and the correctness of the system assembly.

![**Figure 4-5.** Test 1 — mid-span radial displacement from the independent static solver against the static limit of the dynamic solver.](figures_validation/verif_test1_static_R3.png){width=12cm}

**Table 4-7. Test 1 — static limit against the independent static solver.**

| quantity | value |
|---|---|
| radial points compared | 45 |
| max u, independent static solver | 9.555556×10⁻⁴ m |
| max u, static limit of the dynamic solver | 9.555556×10⁻⁴ m |
| maximum absolute difference | 2.103667×10⁻¹⁴ m |
| maximum relative difference | 2.201512×10⁻¹¹ |

### 4-4-2. Test 2 — dynamic mechanical response

The mechanical part of the problem is compared with the results of Malekzadeh
(Table 6 of reference [31]) and with an independent ANSYS finite-element
solution. The dimensionless radial displacement is reproduced with a relative
difference of 0.1 to 0.2 percent, and the dimensionless inner-surface radial
stress is obtained exactly as the negative of the applied pressure, in full
agreement with the loading boundary condition.

![**Figure 4-6.** Test 2 — dimensionless inner-surface radial displacement at mid-span against dimensionless time: the present solution compared with the published values of reference [31] and the ANSYS solution.](Validation/bench1_U.png){width=14cm}

### 4-4-3. Test 3 — transient heat conduction

The transient conduction problem is checked against the exact Bessel-series
solution. The dimensionless temperature distribution at several times lies on the
exact curve, with a relative error between 10⁻⁵ and 10⁻⁷; that is, the
differential quadrature spatial discretization reproduces the transient thermal
field to several significant digits.

![**Figure 4-7.** Test 3 — radial temperature profiles at several times: the present solution (markers) against the exact Bessel-series solution (solid line).](Validation/bench2_T_profiles.png){width=14cm}

### 4-4-4. Test 4 — time-integration scheme

The Newmark scheme is checked against MATLAB's adaptive stiff solver on the same
spatial system. Figure 4-8 shows all three curves — the exact solution, Newmark,
and the adaptive solver — coinciding over the whole time interval. The
quantitative size of the difference between the two schemes is given in Table
4-8: the maximum Newmark error is about one order of magnitude larger than that
of the adaptive solver, but its computational cost is roughly one tenth. It is
this accuracy-to-cost ratio that justifies the choice of Newmark for all
production runs.

![**Figure 4-8.** Test 4 — mid-point temperature history for the exact solution, the Newmark scheme and the adaptive stiff solver; all three curves coincide.](figures_validation/verif_test4_integrator_R2.png){width=12cm}

**Table 4-8. Test 4 — comparison of time integrators on the identical spatial system.**

| method | max error vs exact (K) | CPU time (s) |
|---|---|---|
| differential quadrature + Newmark | 0.00319 | 0.18 |
| differential quadrature + adaptive stiff solver | 0.00026 | 1.74 |
| difference between Newmark and the adaptive solver | 0.00337 | — |

### 4-4-5. Test 5 — the Lord–Shulman second-sound wave

The wave-propagation behaviour is checked against an exact Fourier–Bessel
solution derived for the solver's own geometry. That reference was itself
verified independently before use: the steady-state limit to 1.9×10⁻¹⁶, strict
hyperbolic causality ahead of the front to 4×10⁻⁶, and the front-jump ratios
against the analytic ray law to 0.16 percent. The present solver matches it with
a maximum pointwise error of 0.32 percent and an L₂ error of 0.065 percent on the
finest mesh, and according to Table 4-9 the error falls monotonically under mesh
refinement. That monotone decrease simultaneously establishes that the
oscillations trailing the sharp front are a Gibbs effect of the spectral
discretization and not a numerical instability.

![**Figure 4-9.** Test 5 — radial temperature profiles at several times: the present solver against the exact Fourier–Bessel second-sound solution, with the sharp wave front present in both.](figures_validation/ls_wave_validation_R1.png){width=16cm}

**Table 4-9. Test 5 — mesh convergence against the exact Fourier–Bessel solution.**

| N_r | radial points | L∞ relative error | L₂ relative error |
|---|---|---|---|
| 7 | 49 | 1.343×10⁻² | 4.881×10⁻³ |
| 11 | 77 | 6.204×10⁻³ | 1.876×10⁻³ |
| 15 | 105 | 3.756×10⁻³ | 1.207×10⁻³ |
| 21 | 147 | 3.230×10⁻³ | 6.507×10⁻⁴ |

### 4-4-6. Summary

Taken together, these five checks confirm the validity of the present solution in
both the static and the transient regimes and in the coupled and uncoupled cases:
test 1 covers the system assembly, tests 2 and 3 the mechanical and thermal parts
separately, test 4 the time-marching scheme, and test 5 the Lord–Shulman wave
phenomenon itself, which is the central novelty of this research.

---

## Implementation notes (not part of the thesis text)

1. **End condition in test 1.** The comparison uses **free** ends, as recorded in
the original documentation. Running the same comparison with **simply supported**
ends gives a relative difference of about 8.0×10⁻², because the two codes do not
impose the axial simple-support condition identically; that discrepancy is a
genuine physical difference, not an assembly error. The new data were produced
with `Static_Baseline_R3` (the free-end revision) and `LSTE_solver_R11`.

2. **Change relative to the previous summary table.** Row 5 previously cited
Bagri and Eslami as the reference and "wave speeds and reflections matched" as the
result, i.e. a qualitative comparison. Following the addition of the exact
Fourier–Bessel solution, that row is now quantitative. Row 4 has likewise been
updated to the measured difference between Newmark and the adaptive solver
(0.0034 K).

3. **Figure and table numbering.** The numbers 4-5 to 4-9 for figures and 4-7 to
4-9 for tables are provisional and must be reconciled with the chapter's global
numbering at final assembly; the summary table keeps its existing number 4-6.

4. **Image paths.** The image paths are written relative to the `claude/` folder
(the `CHAPTER3_formulation` convention), so pandoc must be run from that folder to
build the docx — running it elsewhere drops the images silently. Black-and-white
versions of the two new figures exist in the same folder with the `_bw` suffix.
