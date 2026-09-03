# THESIS MASTER TO-DO — start → defense

Legend: ✅ done · 🔄 in progress · ⬜ remaining · ⏸ blocked on author
Last updated: 2026-08-06. Rewritten from scratch — the previous version (dated
2026-07-27) predated the geometry change, the full Ch1–3 draft, Ch4 R4.4, and
everything else below; it was actively misleading rather than just outdated.
For open author-facing questions in detail, see `DECISIONS_NEEDED.md`.

## PHASE 0 — Understanding, solver correctness ✅ DONE
1. ✅ Understood the problem; read the repo, MZ spec, Rezaei twin thesis, 169-paper library.
2. ✅ Diagnosed the original broken dynamic solver (4 fatal bugs) — see `code_docs/CODE_FIX_HISTORY_EN/FA.md`.
3. ✅ Rewrote it as `LSTE_solver_R1.m` (frozen, verified against the static solver).

## PHASE 1 — Solver line ✅ DONE (R1 → R9)
4. ✅ R1 (fixed, frozen) → R2 (cfg engine) → R3/R3_1 (BC options, final porosity) →
   R4 (Gaussian shock) → R5 (theory switch FOURIER/LS/DPL/GN3) → R6 (per-end BC) →
   R7 (explicit DOF-numbering matrices) → **R8 (FINAL/DEFINITIVE, thesis-of-record
   — default config = thesis reference case)** → R9 (2026-08-06, performance-only,
   vectorized assembly, ~2.1× faster, validated digit-identical to R8 — not
   adopted as thesis-of-record, available on request). Full history in
   `REVISIONS.md` §1.
5. ✅ Six-benchmark validation suite (static-limit 2e-11; IJPVP Table 6 + ANSYS;
   exact Bessel conduction; Newmark vs `ode15s`; Bagri-Eslami LS waves;
   spatial/time-integrator convergence).

## PHASE 2 — Geometry, loading, mesh: all locked ✅ DONE
6. ✅ Thesis reference case: R_i=1.0 m, R_o=1.5 m, L=2.1 m, N_L=7, N_r=15, N_z=11
   (mesh locked 2026-08-01 after an independent convergence study —
   see `REVIEW3_PROM3.md` item 4). W_GPL=0.3%, e_m3=0.8604, T 300→600 K,
   h_c=10, P_i=50 MPa, τ*=0.15 (τ₀=418 s), total_time=3000 s, dt=1 s.
7. ⏸ Porosity pattern formulas — author finalizing against the MZ file
   personally (see `DECISIONS_NEEDED.md` item 5). Current code porosity is
   frozen/correct as-is until then; nothing else waits on this.

## PHASE 3 — Parametric campaign (new geometry) ✅ DONE
8. ✅ 86-case campaign (`param_studies_ch4/`, via `campaign/run_ch4_campaign.ps1` +
   `run_nz_sweep.ps1`), including the full 25-case GPL×porosity matrix (Prom.3).
9. ✅ Figure catalog rebuilt for the new geometry: `catalog_R6*` family
   (4-panel selection, full-component, wave-fronts, 25-matrix, convergence),
   `catalog_gplpor.m`, `catalog_bestworst.m`.
10. ✅ `chapter_stats.csv` regenerated correctly (2026-08-05 fix — the old
    generator was reading a stale old-geometry folder; new one is
    `code/misc/chapter_stats_ch4.m`).

## PHASE 4 — Chapter 4 (Results) ✅ DONE — currently R4.4
11. ✅ Full chapter built and iterated through supervisor review rounds
    Prom.2/3/4/5 (see `REVISIONS.md` §4 for the complete R4→R4.4 history):
    30 figures, 4 docx (EN/FA × bw/color), convergence/validation split into
    dedicated sections, jump/anomaly explanations added (incl. the LS
    second-sound spike at ξ≈0.75, §4-5), best/worst summary figure,
    spatial-convergence table. Project-wide plotting-rule sweep applied
    2026-08-06 (no titles/floating text, solid color lines).
12. ⏸ Ch4-frozen examiner-flagged inconsistencies (hoop-stress double value,
    Newmark-best claim vs its own table, GN3 dissipation wording) — need
    author decision since Ch4 is frozen (`DECISIONS_NEEDED.md` item 7).
13. ⏸ §4-17 wave-front animation — author-blocked on view/case/format choice.

## PHASE 5 — Remaining thesis chapters ✅ DONE
14. ✅ Chapter 1 (framework), Chapter 2 (literature review), Chapter 3
    (formulation — governing equations as native Word/OMML equations via
    pandoc, DQM+Newmark derivation, all 5 schematic figures embedded,
    porosity schematic corrected 2026-08-06 to plot the actual porosity
    coefficient rather than the mass factor).
15. ✅ Chapter 5 (conclusions + future work) — kept in sync with Ch4 R4.4's
    real numbers through the `chapter_stats.csv` fix.
16. ✅ Appendix A (Newmark + comparison methods) and Appendix B (validation
    diagrams, 6 figures, ANSYS framing corrected).
17. ✅ Both abstracts (FA + EN), Master TOC, Master Figure List, Figures
    Flipbook (36 figures).

## PHASE 6 — Code documentation & governance ✅ DONE
18. ✅ `CODE_DOC_usage_FA` / `CODE_DOC_technical_FA` — kept current through
    every pipeline change, now mention R9.
19. ✅ `CODE_FIX_HISTORY_EN/FA` — evidence-based writeup of the original
    solver's bugs vs. `LSTE_solver_R1.m`'s fixes.
20. ✅ `CODE_WRITING_GUIDE_EN/FA` — teaches the codebase's recurring patterns.
21. ✅ `EXAMINER_REVIEW_FA` (strict critique), `IMPROVEMENT_SUGGESTIONS_FA`
    (27 items), `DEFENSE_QA_FA` (37 Q&A pairs), `BACKGROUND_EN`.
22. ✅ Code audit/reorg (2026-08-05): 24 stale files archived to `_archive/`
    folders (not deleted), old `param_studies/` folder deleted, both
    code_docs corrected, matrix documented as epoxy.
23. ✅ 13+ editable Word (.docx) versions of every chapter/report so they can
    be read/edited outside Markdown.

## PHASE 7 — Finalization & defense
24. ⏸ Citation fixes: entry #71 DOI, add Tzou 1995 as [74] (needs author).
25. ⏸ Obtain 3 must-cite paywalled papers (needs author, see `DECISIONS_NEEDED.md`).
26. ⬜ Full thesis assembly: front matter, final TOC, nomenclature, reference
    list. **Deliberately held** until the thesis is otherwise final — assembling
    early just means redoing it after every chapter edit.
27. ⏸ Re-run porosity-dependent studies + figures once the author delivers the
    MZ-corrected porosity formulas (Phase 2, item 7).
28. ⬜ Defense slides — premature until the defense date is closer.
29. ⏸ Thesis defense (final milestone).

## Currently no blocking work in the main loop
Everything not marked ⏸/⬜ above is complete and pushed. The active blockers
are all on the author's side (see `DECISIONS_NEEDED.md`); until one of those
resolves, the codebase/thesis text are in a stable, complete, defensible state.
