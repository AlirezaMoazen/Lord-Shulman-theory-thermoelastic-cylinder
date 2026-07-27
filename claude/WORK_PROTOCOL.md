# WORK PROTOCOL — decisions, actions, and their reasons

This file records HOW the work is done and WHY each significant decision was
made, so the reasoning is auditable and reproducible. It complements
PROTOCOL.md (code rules) and THESIS_TODO.md (task plan). Newest first.

## Standing operating rules (agreed with the author)
1. **Revision naming**: features → next integer (claude_R6); audit fixes →
   sub-revision (claude_R6_1). Old revisions are frozen.
2. **No-rewrite**: never edit verified code in place; a new revision is a copy
   with surgical, marked additions. Every revision must reproduce the previous
   one's default results digit-for-digit before use.
3. **Config not editing**: parameter studies run through the `cfg` override
   struct via orchestrator scripts; the solver file is not edited per run.
4. **Mark uncertainty**: unconfirmed formulas carry warnings until the author
   confirms, then are finalized in a sub-revision.
5. **Verify before trust**: every number quoted in the thesis is extracted from
   the saved results (chapter_stats.csv), never invented.
6. **Two languages**: chapter text is produced in Persian (author's style) and
   English (translation reference). Two Persian figure variants: B&W + color.
7. **Autonomous loop** (author directive 2026-07-27): if idle or limit-reset,
   resume automatically; pick the highest-priority THESIS_TODO item; check ~hourly.

## Key decisions & reasons (log)

### 2026-07-27 — Chapter-4 revision (supervisor review)
- **Split convergence & validation** into two sections — the review explicitly
  requires it; convergence = numerical (layers, grid, DQM-vs-FDM-vs-FEM),
  validation = physical agreement with papers/exact solutions.
- **claude_R6 built (not editing R5)** — the GPL dimensions were assigned AFTER
  the cfg override and BC_z was a single both-ends selector, so the aspect-ratio
  and mixed-BC studies were impossible via cfg. Reason for a new revision:
  no-rewrite rule; verified regression = 0 vs R5, so nothing broke.
- **Pressure sweep to 100 MPa, linear** — the base 1 MPa made pressure look
  negligible; the review asked to test high pressures. Finding: no گسست
  (linear thermoelastic model → linear scaling), but at 100 MPa pressure is a
  real ~50%-of-hoop-stress effect. The old "second-order" conclusion is now
  qualified by magnitude.
- **Full 4×4 GPL×porosity matrix** (not just the 4 previous combos) — the review
  asked for "more combinations"; a complete grid is the defensible scientific
  answer and reveals the mirror-pattern interaction (V-GPL cooperates with
  A-porosity but cancels with V-porosity).
- **Figure legend (fig 4-15) → top-right** — review says the current position
  blocks the plot; the empty corner of a log-log convergence plot is top-right.
- **γ_N = 0.5 kept everywhere** (author decision) — honest, unfiltered results;
  Gibbs wiggles noted in captions rather than damped.
- **Workflow used for drafting** — 10 sections drafted in parallel by subagents
  with the exact data + style guide, then adversarially number-checked; chosen
  because the chapter revision is large and the sections are independent.
  Session limit interrupted it: 6/10 drafts completed and are saved in the
  workflow journal; the remaining 4 are written by the main loop next cycle.

### Earlier (condensed — see git history + memory files)
- Geometry R_o = 0.2 m (thick wall, R_o/R_i = 2) — author choice.
- End BCs S (base) + C (compare); F/R excluded from the thesis (unstable +
  author directive) though kept as solver capability.
- Porosity patterns finalized from the author's document (verified ≤5e-5).
- Dimensionless presentation (Fo, τ*, T*, ξ, u*, σ*) for generality.
- Newmark parameter written δ in the thesis to avoid clashing with the
  percolation exponent γ.

## Tooling decisions
- **Docx generation**: no MS Word/Office on the machine → (a) custom C# OOXML
  writer (scratchpad DocxBuilder.cs) for full control, and (b) pandoc 3.10
  (installed) with `--reference-doc` = the author's draft for university styles
  and LaTeX→Word equations (for Chapter 3).
- **PDF/scan reading**: poppler installed; scanned review pages read by
  extracting embedded JPEGs and viewing them.
- **MATLAB concurrency**: max 3 parallel `-batch` jobs. A 4th instance triggers
  the transient MathWorks license error 5001 → run figure/stat jobs SERIALLY
  with the campaign, never as a 4th concurrent MATLAB.
- **Logging race**: parallel jobs writing one log can drop a DONE line; verify
  completion by checking the .mat files, not only the log count.
