# HANDOFF R1 — state of the project for a new AI session (written 2026-10-29)

A dated snapshot, not an evolving document: if the state changes materially, write `HANDOFF_R2.md`.
Read `../CLAUDE.md` first; this file adds the *current state* and the traps.

## 1. What the project is
Dynamic, coupled Lord-Shulman (also Fourier / DPL / GN-III) thermoelastic solver for a multilayer
porous GPL-reinforced hollow cylinder; thesis results chapter (Ch4), formulation (Ch3), literature
(Ch2), framework (Ch1), conclusions (Ch5), appendices, abstracts, defense materials, and three
journal-paper drafts. Author: Alireza Moazen (use they/them if pronouns are needed).

## 2. Where things stand (2026-10-29)
- **Solver**: `code/solver/LSTE_solver_R11.m` is current (R11 = comment/header cleanup only, zero
  logic change vs R10). Thesis reference case = its default config: R_i=1.0 m, R_o=1.5 m, L=2.1 m,
  N_L=7, N_r=15, N_z=11, W_GPL=0.3 %, e_m3=0.8604, T 300→600 K, h_c=10, P_i=50 MPa, tau0=418 s
  (tau*≈0.15), total_time=3000 s, dt=1 s. End BCs S (base) and C (compare).
- **Validation**: six benchmarks passed (static 2e-11; IJPVP-2012 Table 6 + ANSYS; exact Bessel
  conduction; Newmark vs ode15s; Bagri–Eslami LS waves; convergence). Figures in `Validation/`,
  `figures_validation/`.
- **Campaign**: 86 cases in `param_studies_ch4/` (git-ignored). Ch4 text is at **R4.4** (frozen),
  30+ figures, EN/FA × B&W/color. Later Ch4 work: §4-4 replacement text
  (`thesis_chapter/CH4_SECTION_4_4_FA_R1`), figures `figures_ch4_R8…R20`.
- **Other chapters**: Ch1–3 FA drafts (`*_R1`, `R1.1_tracked`), Ch5 FA/EN R2, abstracts, appendices,
  master TOC / figure list, acknowledgments R2, glossary R2.
- **Defense (Oct 2026)**: `defense/` — slides R4 (.pptx RTL), speech script, Q&A, jury/examiner
  reviews, speaker notes for Ch4 figures and literature, Bessel-method derivation/explanations,
  literature tables R2. Several files are `AUTHOR_`-prefixed = for the author only, not the thesis.
- **Papers**: `papers/` — portfolio + three journal drafts (R1, 2026-09-26).
- **Latest work (2026-10-14…17)**: new V and A porosity patterns
  P_m = 1 − e_m·cos(πζ/2 ± π/4), schematics + recomputed tables
  (`code/catalog/porosity_schematic_newVA_R1.m`, `code/misc/porosity_tables_newVA_R1.m/.csv`).
  **Solver and thesis equations were NOT changed** — the new patterns are not yet in the solver.

## 3. Documents that are STALE or contradict each other (do not trust blindly)
| document | problem |
|---|---|
| `README.md` (claude/) | says current solver is R5 and lists a flat file layout; real layout is `code/{solver,catalog,misc,validation,extensions}`, current solver R11 |
| `README.md` (repo root) | status "2026-07", mentions R3_1 as current |
| `governance/PROTOCOL.md` §6 and `WORK_PROTOCOL.md` "Earlier" | geometry R_i=0.1 / R_o=0.2 m is the **old** geometry; the thesis-of-record is R_i=1.0 / R_o=1.5 m (solver defaults) |
| `governance/THESIS_TODO.md`, `DECISIONS_NEEDED.md` | last updated 2026-08-06; they predate defense work, papers, the §4-4 rewrite, and the new V/A patterns |
| `thesis_chapter/chapter_stats.csv` | Σ* column ≈4× smaller than the Ch4 text — Ch4 is correct, the CSV uses a different normalisation (see the number-provenance comment in `REVISIONS.md` §5b). Reconcile or retire before quoting. |
| `governance/` mentions of defense files | the 9 defense docs moved to `defense/` on 2026-10-16; their `.docx` copies may still say `governance/` internally |
When you touch a stale doc, create a new revision (house rule), do not edit in place.

## 4. Open items (all need the author unless noted)
1. **Porosity formulas**: author is finalizing them against `MZ-R 0.docx`. The new V/A patterns exist only
   as schematics/tables; the MZ e1/e2 columns are *not* reproduced by the e = f(P_m) convention used
   (0–5 % off from level 2 up) — convention unidentified. Solver change + full re-run of
   porosity-dependent studies is blocked on this.
2. Ch4-frozen inconsistencies (`DECISIONS_NEEDED.md` item 7): hoop stress quoted as 4.20 and 4.15
   (inner-surface vs peak — a clarity issue), "Newmark best" vs its own Table, GN-III wording /
   GN-III k* run vs text; FEM/DQM wording in §4-19; two U*/Σ* normalisations.
3. Citations: DOI of entry #71, add Tzou 1995 as [74], three paywalled must-cite papers
   (TWS 2022 109367; Sherief 2004; Karimi Zeverdejani & Kiani 2022).
4. §4-17 wave-front animation: needs author's choice of field/case/format.
5. Whether to adopt `LSTE_solver_R9`+ (≈2.1× faster, digit-identical) as source-of-record
   (would mean re-running all 86 cases).
6. Full thesis assembly (front matter, TOC, nomenclature, reference list) deliberately held.
7. Two suggested extra Bessel figures (see `defense/DEFENSE_BESSEL_REFERENCES_AND_EXPLANATION_FA_R1`) not made.

## 5. How to resume
1. `git pull`; `git status` should be clean. Check `claude/param_studies_ch4/` exists (git-ignored,
   ~1.1 GB); if not and a task needs raw data, run `campaign/run_ch4_campaign.ps1` + `run_nz_sweep.ps1`
   (long) — or ask the author for a backup.
2. Ask the author what is next; the likely candidates are items 1–2 above or defense preparation.
3. For any new file: pick the next `_R<n>`, add a row to `REVISIONS.md`, update `.docx` twins,
   commit + push.
4. Quick solver smoke test (from `claude/`): run `LSTE_solver_R11` with a small cfg
   (e.g. `NL=3, N_r=7, N_z=7, total_time=100`) and confirm it finishes.

## 6. Working-style notes (from the protocol + history)
- The author reviews the **.docx** files; keep them in sync with the `.md` sources.
- Persian text must be pure-Persian prose with formulas on their own lines (RTL layout breaks on
  mixed Latin inline text); tables are set right-to-left.
- Plotting rules (project-wide sweep 2026-08-06): no titles / floating text in figures, solid colour lines.
- gamma_N = 0.5 kept everywhere (author decision); F/R end BCs excluded from the thesis.
- Mark uncertain formulas with warnings until the author confirms.
