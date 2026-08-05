<!-- BACKGROUND_EN — English "Background" section derived from Chapter 1
     (CHAPTER1_framework_FA_R1). Self-contained academic prose, not a
     word-for-word translation. Reference anchors mirror the Persian chapter
     (Pandoc-style [[n](#_ENREF_n)]); claims with no source in Chapter 1 are
     tagged [[needs citation]]. NOTE: quantitative method and reference-loading
     details (Newmark, N_r=15/N_z=11, 300->600 K, t0=2 s, P_i=50 MPa, h_c=10)
     come from Chapters 3-4, not Chapter 1 prose. Task B5 / Prom 5 #8. -->

# Background

## The engineering problem

Hollow cylinders with thick walls are among the most widely used structural
elements in engineering. They are able to carry axial, shear, torsional,
bending, hydrostatic and hydrodynamic loads, and they appear either as
components of a larger assembly or as independent structures in their own right.
Pressure vessels, pipelines and fluid-transport systems, spacecraft, nuclear
reactor components and heat exchangers all rely on this geometry. Because their
range of application spans so many industries, thick-walled cylinders have
remained a persistent focus of engineering research.

Many of these components operate under fast and severe thermal loading. In such
service the accurate prediction of the transient temperature field and of the
thermal stresses it induces is critical to guaranteeing the safety and service
life of the structure. This is the practical problem the present work addresses:
the coupled thermoelastic response of a thick, multilayer hollow cylinder
subjected to a combined thermal and mechanical (thermo-mechanical) load.

The cylinder studied here is a thick-walled, multilayer tube with an inner
radius of R_i = 1.0 m and an outer radius of R_o = 1.5 m, giving a wall
thickness of h = R_o − R_i = 0.5 m and a radial ratio R_o/R_i = 1.5. Its length
is L = 2.1 m and it is built from N_L = 7 layers, with material properties
graded layer by layer through the wall thickness.

## Why classical Fourier conduction is not enough

Classical coupled thermoelasticity, in which the Fourier heat-conduction
equation is coupled to the equations of elasticity, has been broadly successful
in analysing steady and slowly varying transient thermal stresses. It carries,
however, one fundamental defect. The Fourier conduction equation is parabolic,
and a parabolic equation implies an infinite speed of propagation for any
thermal disturbance: a temperature change at one point is felt instantaneously
throughout the entire body. For very rapid thermal loading — thermal shock,
laser pulses, explosive or blast loading — this is physically inconsistent with
the finite speed at which heat actually propagates
[[3](#_ENREF_3)]. When the thermoelastic response of a solid under such loads is
computed with theories that neglect this effect, the results lack the required
accuracy.

To remove this inconsistency, generalized theories of thermoelasticity were
introduced. In these theories the conduction equation becomes hyperbolic and
carries a finite thermal-wave speed, a phenomenon known as "second sound." The
first and best known of them was proposed by Lord and Shulman in 1967
[[4](#_ENREF_4)]. By adding a single relaxation time τ0 to the heat flux — on the
basis of the Cattaneo–Vernotte conduction law — they rendered the conduction
equation hyperbolic, in such a way that letting τ0 → 0 recovers the classical
Fourier model exactly. In the Lord–Shulman theory the thermal-wave speed is
finite and the displacement and temperature fields are mutually coupled, which
is precisely what makes it a generalized, coupled theory. Later theories
followed — Green–Lindsay, with two relaxation times, and Green–Naghdi, based on
the temperature gradient and its rate (in energy-dissipative and
dissipation-free forms), together with the dual-phase-lag model; comprehensive
reviews of these and related refined models are available
[[78](#_ENREF_78)]. Among them, the Lord–Shulman theory has been used more than
any other in the analysis of structures under thermal shock, owing to its
relative simplicity — a single relaxation time — and its thermodynamic
consistency.

The engineering consequence is direct. Because it assumes an infinite
propagation speed, classical Fourier-based analysis under-predicts the peak
transient stresses that build up at thermal-wave fronts, and it does so
non-conservatively. Under impulsive loading this under-estimate can be very
large. Adopting the Lord–Shulman theory, which accounts for the finite
thermal-wave speed, therefore has immediate importance for the safe design of
such components.

## GPL-reinforced porous functionally graded materials

In parallel with these developments, carbon-based nanomaterials have shown
exceptional promise as reinforcing fillers for advanced nanocomposites. Since
their discovery in 1991, carbon nanotubes have attracted attention for their
very high mechanical strength (roughly a hundred times that of steel), large
elastic modulus and excellent electrical and thermal conductivity. Graphene — a
single-atom-thick sheet of carbon atoms arranged in a honeycomb lattice, with an
extremely high elastic modulus, high tensile strength and a very large specific
surface area — has since drawn intense interest from researchers and industry
alike. Since graphene was isolated in 2004, many experimental studies have
reported that graphene-reinforced nanocomposites show a marked improvement in
mechanical properties compared with carbon-nanotube and nanographite composites
[[1](#_ENREF_1)]. The large contact area between graphene sheets and the matrix
also improves the ability of graphene composites to transfer load relative to
other carbon composites.

At the same time, porous materials have emerged as a distinct class of advanced
materials. Their unique combination of low weight, high energy absorption, large
specific surface area (owing to the internal pores) and thermal resistance has
made them attractive for lightweight, thermally insulating applications. The
drawback is that porosity reduces the strength of the material. One remedy is to
add graphene platelets to the porous matrix, restoring stiffness and strength
while retaining the benefits of the pores [[2](#_ENREF_2)].

Combining graphene — as a strong, conductive reinforcement — with porosity — as
an agent for weight reduction and thermal insulation — inside a single,
layer-wise functionally graded material makes it possible to reduce structural
weight and improve thermal and mechanical resistance at the same time, provided
the two distribution patterns are aligned appropriately. In the present model
both the graphene-platelet content and the porosity are graded through the wall
thickness, and each may follow one of five distinct patterns. The effective
properties of the reinforced, porous material are obtained from the Halpin–Tsai
model together with the rule of mixtures, with the pores treated by an open-cell
formulation. The reference configuration uses a total graphene weight fraction
of W_GPL = 0.3% and a porosity mass coefficient of e_m3 = 0.8604. Understanding
how these patterns act and how they interact allows the designer to tailor the
material distribution to the loading conditions, so that the results are useful
both scientifically — in clarifying the wave-like nature of heat conduction in
these novel structures — and practically, in providing design guidance for
thermal protection.

## Prior work and the research gap

The analysis of thick-walled cylinders and spheres under thermal and mechanical
loads has itself become an active field alongside the development of generalized
thermoelasticity. Bagri and Eslami presented a unified solution for the
generalized thermoelasticity of cylinders and spheres
[[7](#_ENREF_7)], and numerous studies have examined the response of functionally
graded cylinders under thermo-mechanical loading. With the advent of
graphene-platelet-reinforced composites and porous composite materials,
attention turned to newer structures whose effective properties are graded
deliberately through the thickness; Heydarpour and co-workers developed the
thermoelastic analysis of graphene-reinforced spherical and cylindrical shells
on the basis of the Lord–Shulman theory using the differential quadrature method
[[3](#_ENREF_3), [68](#_ENREF_68)]. Despite this rich background, a fully coupled
Lord–Shulman solution for a multilayer, porous, graphene-reinforced hollow
cylinder — one that accounts for the full interaction between the graphene and
porosity distribution patterns in the two-dimensional (r, z) domain — had not yet
been fully investigated. Closing this gap is the central motivation of the
present study.

## Objectives, questions and scope

The principal objective of this research is to analyse the thermoelastic
behaviour of porous, graphene-platelet-reinforced cylinders under
thermo-mechanical loading using the Lord–Shulman theory, examining the response
for the full set of graphene distribution patterns and porosity distribution
patterns graded through the wall thickness. The governing equations, boundary
conditions and compatibility conditions are derived from the equations of motion
and the Lord–Shulman energy-conservation equation, and are then discretized by a
layer-wise differential quadrature method (using Chebyshev–Gauss–Lobatto points)
in space and by the Newmark method (δ = 1/2, β = 1/4) in time, on a mesh of
N_r = 15 radial points per layer and N_z = 11 axial points. The reference load
consists of an inner-surface temperature ramp from 300 K to 600 K with time
constant t0 = 2 s, an internal pressure P_i = 50 MPa, and convective exchange at
the outer surface with coefficient h_c = 10.

The study is organized around four questions:

- How does the finite thermal-wave speed of the Lord–Shulman theory alter the
  temperature, stress and displacement response compared with classical Fourier
  conduction?
- How do the graphene distribution pattern and the pattern and intensity of
  porosity each affect the peak temperature, the thermal stresses and the
  displacements?
- Can the simultaneous interaction of the graphene and porosity patterns produce
  synergistic or cancelling behaviour that can be optimized for thermal
  protection?
- How do parameters such as the graphene weight fraction, the platelet aspect
  ratios, the relaxation time, the support (boundary) conditions, the internal
  pressure and the wall thickness influence the transient response?

Within this scope, several simplifying assumptions are made so that the analysis
remains tractable and focused on the principal phenomena. The material behaviour
is taken to be fully linear elastic, so damage, fracture and plasticity are not
modelled; the material properties (Young's modulus, thermal conductivity and
thermal-expansion coefficient) are assumed constant and temperature-independent
over the 300–600 K range; the two ends of the cylinder are taken to be thermally
insulated, with heat exchange to the environment only through linear convection
at the outer surface (nonlinear radiative exchange is neglected); the problem is
axisymmetric, with all field dependence on the circumferential coordinate θ
removed and the cylinder assumed stationary (non-rotating); and the porosity
distribution patterns used are exactly those implemented in the solver, with any
update to new patterns and the re-running of the associated studies left to
future work.

<!-- References cited above appear in Chapter 1 (CHAPTER1_framework_FA_R1):
     [1] graphene-nanocomposite mechanical improvement; [2] graphene added to
     porous matrix; [3] generalized thermoelasticity / Heydarpour LS-DQM;
     [4] Lord & Shulman (1967); [7] Bagri & Eslami unified solution;
     [68] Heydarpour et al. GPL shells; [78] review of generalized theories.
     Anchor numbering to be globally unified in a later pass, consistent with
     the note in the Persian source. -->
