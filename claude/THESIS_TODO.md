# THESIS MASTER TO-DO — start → defense

Legend: ✅ done · 🔄 in progress · ⬜ remaining · ⏸ blocked on user
Last updated: 2026-07-27. Priority for autonomous work = topmost 🔄/⬜ item.

## PHASE 0 — Understanding & setup
1. ✅ Understand the problem: transient coupled Lord-Shulman thermoelasticity of a multilayer porous GPL-reinforced hollow cylinder; layerwise DQM (r,z) + Newmark (t), MATLAB.
2. ✅ Read the repository, the math spec (MZ-R 0.docx), the Rezaei twin thesis, and the 169-paper library (annotated bibliography).
3. ✅ Diagnose the long-broken dynamic solver (4 fatal bug families).

## PHASE 1 — Solver line (claude/)
4. ✅ Fix solver → claude_R1 (frozen, verified).
5. ✅ Feature revisions: R2 (cfg engine), R3 (BC options), R3_1 (final porosity), R4 (Gaussian shock), R5 (theory switch FOURIER/LS/DPL/GN3), R6 (per-end BC + cfg-overridable GPL dims).
6. ✅ Six-benchmark validation (static 2e-11; IJPVP table; exact Bessel; ode15s; Bagri-Eslami waves; layer convergence).

## PHASE 2 — Decisions closed
7. ✅ Physics/spec decisions: porosity patterns final; loading (600/300 K, h_c=10, P=1 MPa base); geometry R_i=0.1, R_o=0.2 (thick wall); dimensionless set; end-BC S base + C compare (F/R excluded from thesis).

## PHASE 3 — Base campaign & extensions
8. ✅ 33-case base campaign (studies A–N), 0 failures.
9. ✅ Extensions T1 (6 time integrators), T2 (DQM vs FDM vs FEM), T3 (4 theories).
10. ✅ Dimensionless production figures (R2/R3 scripts).

## PHASE 4 — Supervisor review round 1 (Prom 3-7) → results chapter R3
11. ✅ Receive, transcribe, and confirm the handwritten review (authoritative Google-Doc version).
12. ✅ Categorize review into delete / correct / add lists.
13. ✅ Run v4 cases: pressure sweep 0–100 MPa (no گسست), layers N_L=9/15, weight fraction W=2–3.5%.
14. ✅ Build & verify claude_R6 (regression vs R5 = 0) for mixed BC + GPL aspect ratios.
15. ✅ Run v5 cases: infinite-length (L=1/2/4), mixed support (S-C), GPL aspect ratios, full 4×4 GPL×porosity matrix.
16. ✅ Generate B&W (figures_print) and COLOR (figures_color) figure sets.
17. ✅ Draft the 10 new/revised chapter-4 sections bilingually (6 via workflow + 4 in main loop). All recovered from journal + WIP.
18. ✅ Assemble the full R3 chapter FA + EN (21 sections): convergence (4-3) and validation (4-4) split; new sections aspect-ratio (4-8) + infinite-length (4-12); full 4×4 interaction matrix (4-13); pressure sweep 0–100 MPa (4-11); mixed support (4-10); peak-trough + mirror-pattern interpretations added; figures renumbered 4-1…4-22; captions → FIGURE_CAPTIONS_R3.md.
19. ✅ Build the TWO Persian Word docs (RESULTS_CHAPTER_FA_R3_bw.docx via figures_print + RESULTS_CHAPTER_FA_R3_color.docx via figures_color) and the English doc (RESULTS_CHAPTER_EN_R3.docx); 22 figures embedded; fig-4-2 legend now top-right.
20. 🔄 Referee number-check (per Prom.2 method) → commit & push the R3 chapter package.

## PHASE 4b — Supervisor review round 2 (Prom.2, received 2026-07-27)
R2a. ⬜ Color-coded editing of chapters 1–3: deletions RED, additions GREEN, default BLACK + a second version where deletions are marked but not removed (Prom.2 الف).
R2b. ⬜ Complete the "blue"/un-analyzed sections with analysis + figures (Prom.2 ب,ج).
R2c. ⬜ Hyperlink the table-of-contents entries to sections; complete English abstract (Prom.2 د,ه).
R2d. ✅ Write an appendix explaining the Newmark method + briefly the comparison methods (DQM/FDM/FEM, integrators) (Prom.2 و). Done bilingually: APPENDIX_A_methods_FA/EN.md + .docx via pandoc (93 native Word equations; FA is RTL with 49 bidi paragraphs). **Validates the pandoc LaTeX→Word equation pipeline for Chapter 3.**
R2e. ⏸ Replace porosity patterns with the NEW patterns in the MZ file, then re-run porosity cases (Prom.2 ز) — NEEDS user-confirmed formulas.
R2f. ⏸ Fix length/thickness notation (not L / h) (Prom.2 ح) — NEEDS user's chosen symbols.
R2g. ✅ Code documentation (Prom.2 pages 3–4): (1) short usage manual `code_docs/CODE_DOC_usage_FA.docx` (run modes, cfg mechanism, param studies, figures, outputs, revision map); (2) full technical description `code_docs/CODE_DOC_technical_FA.docx` (7-section architecture, governing eqs, DOF-numbering matrix idx_Th/U/W, M/C/K assembly, BCs, equilibration, Newmark, post-proc, helpers, verification). Both Persian RTL via pandoc.
R2h. ⬜ Answer the GPL wt% question (0.1–2 % in lit vs up to 4 % here) — draft justification in §4-7, confirm with user.
R2i. ✅ (Prom-1 follow-up "more graphs per part") Quantity CATALOG for figure selection: `claude_catalog_R1.m` → `figures_catalog/*_catalog.png` (19 studies, 9 panels each: T*/u*/w* histories + T*/u*/ε_θθ profiles + σ*rr/σ*θθ/σ*zz profiles), assembled into `FIGURE_CATALOG_FA.docx` for the author to pick which panels go in ch4. NOTE: stress/strain TIME-histories need a full-history re-run (only T/u/w histories were stored) — offered to the user.

## PHASE 5 — Remaining thesis chapters
21. ⬜ Chapter 3 (formulation & method): render the governing equations as editable Word equations via pandoc; use δ for the Newmark parameter (γ reserved for the percolation exponent); match the implemented scheme exactly.
22. ⬜ Chapter 1 (introduction / framework) and Chapter 2 (literature review) from the annotated bibliography; establish novelty.
23. ✅ Chapter 5 (conclusions + future work): CHAPTER5_conclusions_FA/EN.md + .docx (pandoc). 10 findings + contributions + 7 future-work items (F/R end treatment, vectorized assembly, temperature-dependent properties, radiation BC, damage/failure model for rupture, updated porosity patterns, geometric/loading extensions). Notation-light pending ح.
24. ⬜ Validation content: ensure each benchmark has a comparison-to-paper diagram (review requirement).

## PHASE 6 — Finalization & defense
25. ⏸ Citation fixes: correct list entry #71 DOI (currently points to Hosseini 108108, not Omidi Bidgoli); add Tzou 1995 as reference [74] for the DPL theory. (needs user)
26. ⏸ Obtain 3 must-cite papers via university access: TWS 2022 spinning FG-GPLRC LS cylinder (10.1016/j.tws.2022.109367), Sherief 2004 (10.1080/01495730490498331), Karimi Zeverdejani & Kiani 2022 (10.1080/17455030.2020.1788746). (needs user)
27. ⬜ Persian editing pass: DELETE the free/roller (F/R) boundary conditions from the text (author directive); enforce terminology; avoid invented Persian terms (use واژه‌یاب/برساد); proofread 2–3×.
28. ⬜ Full thesis assembly: front matter, table of contents, nomenclature, figure/table lists, reference list.
29. ⏸ Supervisor review round 2 → apply revisions. (needs user + supervisor)
30. ⬜ Prepare defense slides.
31. ⏸ Thesis defense (presentation). (final milestone)

## Immediate next actions (autonomous priority order)
- A. Recover the 6 workflow drafts from journal.jsonl and write the 4 remaining sections (pressure, supports, infinite, matrix) — main-loop, no subagents needed.
- B. Assemble FA_R3 + EN_R3 markdown (step 18).
- C. Build the two Persian docx + English docx (step 19) and push (step 20).
- D. Then advance to Phase 5 (step 21, Chapter 3 equations).
