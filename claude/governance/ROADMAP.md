# ROADMAP — project path from start to thesis

Status date: 2026-07-21. **All computation is complete**; next milestone is
writing the results chapter.

---

## Part 1 — The path so far

### Phase 0 · Starting point
A long-standing blocker: the legacy dynamic solver (`Main_Dyn` R1–R4) never
worked — results frozen/diverging for months. Static solver (`Main-EN`) OK.

### Phase 1 · Diagnosis & rescue → `claude_R1`
Read the whole repo + thesis spec (MZ-R 0.docx) + Rezaei twin thesis.
Found four fatal bug families: Newmark displacement/acceleration mix-up,
flipped operator sign, fake volume factors, corrupted BC rows.
`claude_R1` = corrected solver (frozen since).

### Phase 2 · Validation (6 independent checks → `Validation/`)
1. Static cross-check (independent assembly): agreement 2×10⁻¹¹
2. IJPVP-2012 Table 6 dynamic benchmark: U* within 0.1–0.2 %, σ_rr exact
3. Exact Bessel transient conduction: rel. error 10⁻⁵–10⁻⁷
4. Newmark vs ode15s: 0.003 K
5. Bagri–Eslami LS wave benchmark: both wave speeds + reflections correct
6. Layer-refinement convergence: extrapolates onto published values

### Phase 3 · Feature revisions (no-rewrite protocol, PROTOCOL.md)
- `R2` cfg-driven geometry/loads/history · `R2_1` audit
- `R3` BC options (flux, dirichlet0, fixed inner, rollers) · `R3_1` **final
  porosity patterns** (author's document = authority; verified ≤5×10⁻⁵)
- `R4` Gaussian thermal shock (campaign solver)
- `R5` **theory switch** FOURIER / LS / DPL / GN-III (regression exact)

### Phase 4 · Knowledge base
169-item library read & triaged → `ANNOTATED_BIBLIOGRAPHY.md` (tiered).
**Novelty confirmed**: no published multilayer + porous + GPL + LS cylinder.

### Phase 5 · Decisions closed with the author
Loading (600 K ramp / 300 K ambient / h_c=10 / P=1 MPa), porosity patterns
final, W_GPL=0.04, geometry **R_i=0.1, R_o=0.2 m (thick-walled, R_o/R_i=2)**,
dimensionless set (Fo, τ̄, T*, ξ, u*, σ*), end BCs **S base + C comparison**
(F/R: solver-only; excluded from the thesis text by author decision).

### Phase 6 · Parametric campaign — 33 cases, 0 failures
Studies A–N: GPL patterns, porosity patterns & levels, τ0, W_GPL, S vs C,
pressure, **and beyond-Rezaei studies**: GPL×porosity interaction, coupling
on/off, Biot sweep, thickness, layer count, Gaussian shock, sine pressure.
Headlines: LS wave arrivals at Fo≈0.17/0.55 with cavity overshoot T*≈1.4;
A-porosity thermal-barrier effect (~9× outer temperature reduction;
V-GPL + A-porosity best); layered σ_θθ staircase.

### Phase 7 · Extensions (uniqueness beyond the template thesis)
- **T1** six time integrators (Newmark, Wilson-θ, Houbolt, HHT-α, ode15s,
  Laplace-Durbin) — accuracy/cost table
- **T2.1** spatial convergence: DQM needs N≈9–11; FEM-quadratic N≈21;
  FEM-linear ≈ FDM N≈161 (Bubnov-Galerkin, consistent matrices)
- **T3** four thermoelasticity theories compared on the same cylinder
  (Fourier / LS / DPL ×2 / GN-III)

### Phase 8 · Organization (this repo)
`claude/` = verified code line + README/ARCHITECTURE/PROTOCOL/ROADMAP;
`param_studies/` raw data; `results_campaign/` chapter part 1 figures;
`results_extensions/` chapter part 2 figures/tables; `Validation/` benchmarks.
All pushed to GitHub.

---

## Part 2 — The future path

### Milestone 1 · RESULTS CHAPTER  ← next
1. Chapter outline mapped section-by-section against Rezaei's (show where we
   exceed it) → author approval
2. Decide γ_N smoothing per wave figure (C, M, T3)
3. `claude_param_figures_R3`: production figures — black-&-white-safe
   (line styles + markers + grayscale), serif fonts, vector PDF export
4. Write the chapter: campaign part (A–N), then extensions part (T1/T2.1/T3),
   with captions and physical discussion

### Milestone 2 · Supporting chapters
- Formulation & method chapter: math = exactly the implemented scheme;
  Newmark parameter written δ (γ is taken by the percolation exponent)
- Validation chapter: the six benchmarks (figures/tables ready)
- Introduction & literature review: from the annotated bibliography
- Conclusions + future work (F/R end treatment, vectorized assembly,
  temperature-dependent properties, radiation BC)

### Milestone 3 · Final assembly
Persian text editing (delete F/R BCs from the text — author directive),
citation list fixes (#71 DOI), front matter, defense slides.

### Open items (small)
- Author to obtain via university access: TWS 2022 spinning FG-GPLRC LS
  cylinder (must-cite), Sherief 2004 exact LS cylinder, Karimi Zeverdejani &
  Kiani 2022
- Citation #71 DOI correction
- ~20 image-based T&F papers (OCR only if ever needed)
