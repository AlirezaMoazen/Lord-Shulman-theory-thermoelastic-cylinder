---
dir: ltr
lang: en-US
---
<!-- ABSTRACT_EN — English abstract (R1). A faithful mirror of ABSTRACT_FA.md:
     same title, same three introductory paragraphs (problem; governing equations +
     DQM/Newmark; Halpin-Tsai / rule of mixtures / open-cell porosity), a Findings
     paragraph and a Conclusion paragraph carrying the same numbers as the Persian
     version, and a Keywords line (A10 / Prom.2 item "e", English version). Numbers
     cited from Chapters 4 and 5. As in the Persian file, the "by / author name" line
     is deliberately omitted here and added at final assembly. This abstract is placed
     at the end of the thesis. -->

# Abstract

**Thermoelastic Analysis of Porous Graphene-Platelet-Reinforced Cylinders under Thermo-Mechanical Loading Using the Lord-Shulman Theory**

In this thesis, the thermoelastic analysis of porous graphene-platelet-reinforced
cylinders under thermo-mechanical loading is investigated using the Lord-Shulman
theory. The hollow cylinders studied here are composed of layers whose properties
vary through the thickness, this variation arising from the change in the volume
fraction of the graphene platelets and the change in the porosity percentage in
each layer.

In these hollow cylinders, the distributions of temperature, stresses, strains, and
displacements are examined. To this end, the equations of motion and the
Lord-Shulman energy-conservation equation are employed to derive the governing
equations, boundary conditions, and compatibility conditions. Then, to discretize
the governing equations together with the boundary and compatibility conditions,
the efficient differential quadrature method is used in the spatial dimension and
the Newmark method in the temporal dimension.

The elastic properties of the layers are computed by means of the Halpin-Tsai
theory and the rule of mixtures, and to account for the change in properties due to
porosity the open-cell (open-pore) theory is used.

**Findings:** Owing to the finite thermal-wave speed in the Lord-Shulman theory, the
mid-wall temperature can overshoot the driving value (up to 1.115 at high graphene
loading), and the temperature history shows the characteristic "peak-trough" pattern
produced by wave reflection. Placing conductive graphene at the hot inner surface
(pattern V) together with insulating porosity at the cold outer surface (pattern A)
acts synergistically, reducing the outer-surface temperature by about 26-fold — the
design configuration recommended by this work for thermal-protection applications.
Under a Gaussian shock pulse, classical Fourier theory underestimates the peak
temperature by about 2.5 times, a strong argument for the generalized theory.
Methodologically, the differential-quadrature/Newmark combination reaches the desired
accuracy at low computational cost, needing about one-fifteenth of the nodes required
by competing methods.

**Conclusion:** The results show that accurately analyzing transient thermal shock in
these cylinders requires the generalized Lord-Shulman theory, since the classical
theory severely underestimates transient stresses. From a design standpoint, aligning
the graphene and porosity patterns (the V-A combination) gives the most favorable
thermal behavior at the lowest stress penalty, though pattern selection must weigh
both temperature and stress together. The layerwise differential quadrature method
with Newmark integration provides an efficient, verified tool for such coupled
thermoelastic analyses.

**Keywords:** thermoelastic analysis, porous cylinder, graphene platelets,
thermo-mechanical loading, Lord-Shulman theory, differential quadrature method,
Newmark method.
