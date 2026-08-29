---
dir: ltr
lang: en-US
---
<!-- APPENDIX_B_validation_EN_R2 — English translation of APPENDIX_B_validation_FA_R2.md.
     No prior English Appendix B existed in the repo (only APPENDIX_B_validation_FA
     R1 was Persian-only); this is the first English version, at the plain-language
     R2 register to match its Persian counterpart. -->

# Appendix B. Solver Validation

## Why This Appendix Is Needed

Before any numerical solver's results can be trusted, it has to be tested against something already known to be correct. In this appendix, the thesis's main solver is checked against five independent tests. In each test, without changing a single line of the solver's code, only the input settings are changed so that the problem matches a known case; the solver's output is then compared against an exact mathematical solution, results from a published paper, or a completely separate solver. If all these comparisons hold up, the results in Chapter 4 can be trusted. A numerical summary of these tests also appears in Table 4-6 of Chapter 4; here the same results are given with explanation and figures.

## Test 1: Are the Equations Assembled Correctly?

This is the simplest test, but also the most fundamental one. The static part of the solver (the case where time plays no role) was compared against a completely separate code that directly solves two algebraic equations: one for steady-state heat conduction and one for elastic equilibrium. This comparison code shares no code with the main solver. Result: the largest difference between the displacement computed by the two codes was on the order of 2×10⁻¹¹ — effectively zero. This shows the equations in the main solver are assembled correctly, with no simple programming error in how the system of equations is built.

## Test 2: Dynamic Mechanical Response Against a Published Paper

This test checks the solver's dynamic mechanical part — where both time and space are involved together. The reference problem is taken from a paper by Malekzadeh and Heydarpour: a hollow cylinder with both ends clamped, whose properties vary gradually along the radius (functionally graded), under an internal pressure that varies with time as a sine wave. The quantity compared was the dimensionless radial displacement at the inner surface, at the mid-length of the cylinder. The solver's answer differed from both the paper's result and the ANSYS results reported in the same paper by only about 0.1 to 0.2 percent. In addition, the radial stress at the inner surface came out exactly equal to the negative of the applied pressure, which is exactly what the boundary condition requires. The figure for this test plots radial displacement against time, placing the present solution's curve alongside the points reported by the paper and by ANSYS; the match between the curve and the points is striking.

## Test 3: Transient Heat Conduction Against an Exact Mathematical Solution

Here only the thermal part of the solver is checked, this time against an exact analytical solution (not another simulation). The problem: a homogeneous hollow cylinder whose inner surface is gradually heated, whose outer surface exchanges heat with the surrounding air, and whose two ends are insulated. For this problem, the exact solution can be obtained using series-based mathematical methods (a Bessel expansion). The quantity compared is the temperature profile along the radius at several different points in time. Result: the temperature curve from the solver essentially lies on top of the exact curve, with a relative error between 10⁻⁵ and 10⁻⁷ — a completely negligible difference. The figure for this test shows several radial temperature profiles at different times: the solver's points fall on the exact solution's continuous curve and are effectively indistinguishable from it.

## Test 4: Time-Stepping Method Against an Independent Solver

This test reuses the same heat-conduction problem as the previous one, but this time the goal is to check the Newmark time-integration method, not spatial accuracy. The solver's answer was compared against a completely independent numerical solver called ode15s (built for stiff, sensitive problems). The largest temperature difference over the entire time span was about 0.003 K — effectively nothing. This result shows the time-stepping method used in the solver is both stable and accurate. Since this test is a single number (not a curve), it has no separate figure; its value appears in Table 4-6.

## Test 5: Wave Propagation in the Coupled Lord-Shulman Theory

This is the hardest and most important test, because it checks the entire distinguishing feature of Lord-Shulman theory — that heat propagates at a finite speed, not infinitely fast as in the classical theory. The reference problem is taken from a paper by Bagri and Eslami: a one-dimensional hollow cylinder whose inner surface is suddenly subjected to a thermal shock. In this problem, two types of wave should be visible: a slower-moving thermal wave and a faster elastic wave. According to the problem setup, the elastic wave front should travel at position r=1+t and the thermal wave front at r=1+0.5t. The solver's result showed exactly these two speeds, and even the timing of the waves' reflection off the outer wall was correctly reproduced. The figure for this test shows several temperature profiles at successive times, in which the sharp thermal wave front can be seen advancing forward and reflecting off the wall.

## Convergence Check: Is the Mesh Fine Enough?

Beyond these five tests, it must also be shown that the number of computational grid points and the time-step size used in the thesis are sufficient — that is, if the mesh were made finer, the answer would no longer change meaningfully. In the radial direction, the answer becomes nearly constant from seven points (Nr=7) onward, with error below 0.3 percent; nevertheless, the final runs used 15 points so that the sharp wave front would be captured without extra oscillation. In the axial direction (the cylinder's length), the situation is more sensitive: with only five points, the stress error is close to 9.4 percent because the region near the support isn't resolved correctly; from nine points onward the error drops below 1 percent, and with 11 points (the final choice) it reaches 0.16 percent. Regarding time: a time step of one second (the final choice) is fully converged, while a five-second step produces a spurious jump of about 3 percent in the peak temperature. Finally, the spatial discretization method used in this thesis (differential quadrature) was also compared against other common methods: to reach the same level of accuracy, this method needs only about 9 to 11 points, while quadratic finite elements need about 21 points and linear finite elements or finite differences need about 161 points — meaning that, at equal accuracy, the mesh used here is about fifteen times smaller. Three figures are planned for this section: one for radial convergence, one for axial convergence, and one comparing the error of different discretization methods against the number of points.

## Summary

Altogether, the six pieces of evidence above show that the solver works correctly both in the static and dynamic cases, and both in the simple and the fully coupled Lord-Shulman case: static assembly matches a separate code to the order of 10⁻¹¹, the dynamic mechanical response agrees with a peer-reviewed paper to under 0.2 percent error, transient heat conduction sits on the exact solution with an error of 10⁻⁵ to 10⁻⁷, the time-stepping method agrees with an independent solver to within only 0.003 K, and the thermal-elastic waves of Lord-Shulman theory are reproduced with the correct speed and reflection timing. Together with the convergence evidence, these tests show that the numerical model used in this thesis is trustworthy, and that the results in Chapter 4 rest on a sound foundation.
