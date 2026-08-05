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

**Findings:** Owing to the finite propagation speed of the thermal wave in the
Lord-Shulman theory, the dimensionless mid-point temperature can overshoot (exceed unity); in the
reference case it reaches about 0.926 without exceeding unity, whereas a genuine
overshoot appears in specific cases — for example V-type porosity (1.109) and high
graphene loading (up to 1.115) — and the temperature
history exhibits a "peak-trough" pattern arising from the back-and-forth travel and
reflection of the wave. Placing the conductive graphene platelets at the hot inner
surface (pattern V) reduced the peak temperature by about 29 percent and the
inner-surface circumferential (hoop) stress by a factor of about 3, whereas
pattern A exhibited the worst behavior in all three quantities of temperature,
stress, and displacement. Concentrating the porosity at the outer surface (pattern
A) acted as a thermal barrier and reduced the outer-surface temperature by a factor of
about 8. Combining V graphene with A porosity synergistically reduced the
outer-surface temperature by a factor of about 26. The percolation threshold occurred
at a weight fraction of about 1 percent, and increasing the graphene up to 8 percent
roughly doubled the thermal stresses. At the reference weight fraction both platelet aspect ratios have a second-order
effect (the width-to-thickness ratio being the weakest); the width-to-thickness
ratio becomes the dominant reinforcement lever only at high graphene loading. The fully coupled solution damped the thermal wave by about
1 percent, and under Gaussian-pulse loading the classical theory underestimated the
peak temperature by about 2.5 times. Methodologically, the Newmark method offered the
best accuracy-to-cost ratio among the six integrators tested, and the differential
quadrature method reached the desired accuracy with about one-fifteenth of the nodes
of the finite-difference and linear finite-element methods.

**Conclusion:** The results show that, for an accurate analysis of the transient
thermal shock in these cylinders, applying the generalized Lord-Shulman theory is
essential, because the classical Fourier theory severely underestimates the
transient stresses, particularly under impulsive loading. From a design standpoint,
aligning the conductive graphene pattern with the hot surface (V) and the insulating
porosity pattern with the cold surface (A) provides the most favorable thermal
behavior with the least stress penalty, and it is introduced as the recommended
configuration for thermal-protection applications. Nevertheless, because the pairing
of the two patterns can be either synergistic or neutralizing, and combinations such
as X graphene with V porosity produce the maximum stress, the selection of patterns
must be assessed simultaneously from the standpoints of both temperature and stress.
Adding graphene beyond the percolation threshold yields a limited thermal benefit but
an increasing stress penalty and must be undertaken with caution. Overall, the
layerwise differential quadrature method together with Newmark integration provides
an efficient, convergent, and verified tool for such coupled thermoelastic analyses.

**Keywords:** thermoelastic analysis, porous cylinder, graphene platelets,
thermo-mechanical loading, Lord-Shulman theory, differential quadrature method,
Newmark method.
