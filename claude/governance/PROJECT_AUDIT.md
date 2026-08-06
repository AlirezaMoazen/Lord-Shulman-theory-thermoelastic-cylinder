# PROJECT AUDIT — protocols, review items, and gaps
<!-- Full review requested by the author 2026-07-28: re-check every rule the
     author has set, and audit the whole project for anything missed. Verified
     against the current repo (HEAD 64806ea), not from memory alone. -->

> **⚠️ STALE SNAPSHOT (2026-07-28) — do not trust for current status.**
> This audit was written against the OLD geometry and the R3 results chapter,
> both long since superseded (new geometry + Results Chapter R4.4, see
> `REVISIONS.md`). At least one item below is now actively **wrong** (item 5,
> Part 1 — the V/A porosity runtime warning was intentionally removed in
> R3_1/later and no longer exists; see `code_docs/CODE_DOC_usage_FA.md`).
> Kept as a historical record only. For current status use:
> - `REVISIONS.md` — what's current for every artifact
> - `THESIS_TODO.md` — what's done / remaining, refreshed 2026-08-06
> - `DECISIONS_NEEDED.md` — genuinely open author-facing questions

## Part 1 — Protocols & frameworks you have set (adherence)

| # | Rule | Status |
|---|------|--------|
| 1 | **No-rewrite**: never edit verified code; features → new revision files | ✅ solver line R1–R6 frozen; catalog/figure scripts are new files |
| 2 | Revision naming (claude_R\<n\>; audit fixes R\<n\>_\<m\>) | ✅ |
| 3 | **Config-not-editing**: param studies via `cfg`, not editing the solver | ✅ v4/v5 orchestrators |
| 4 | **Verify before trust**: every quoted number extracted from saved results | ✅ referee agent number-checked R3 vs chapter_stats.csv |
| 5 | Mark uncertainty (unconfirmed formulas carry warnings) | ✅ porosity V/A carry a runtime warning |
| 6 | Two languages (FA author-style + EN) + two Persian figure variants (B&W + color) | ✅ chapter FA/EN; figures B&W + color; catalog B&W + color |
| 7 | Newmark parameter written **δ** (γ reserved for percolation exponent) | ✅ chapter uses δ = 1/2 |
| 8 | **DELETE free/roller (F/R) BC** from the thesis text | ✅ verified: no F/R in RESULTS_CHAPTER_FA_R3 |
| 9 | Rezaei is a frame only — be more complete/unique, no copying | ✅ 6 extra study families + 4×4 matrix |
| 10 | Autonomous loop (hourly; pick highest-priority; resume after limit) | ✅ running |
| 11 | Separate method-comparison (extensions) from the parametric campaign | ✅ T1/T2/T3 are extension sections |
| 12 | Ask when unsure (don't silently assume) | ✅ blocked items flagged, not guessed |
| 13 | Prom.2 method: several agents per chapter + one as referee | ✅ workflow drafting + referee number-check |
| 14 | Figures must be black-and-white printable | ✅ figures_print + B&W catalog |
| 15 | Use the author's section-numbering method (4-x) | ✅ |

## Part 2 — Round-1 review (supervisor ch4, REVIEW_NOTES_final_author) — item status

| Item | Status |
|------|--------|
| Separate convergence (4-3) & validation (4-4) into two sections | ✅ done |
| Validation/convergence must have **comparison DIAGRAMS vs papers**, not tables only | ⚠️ **GAP** — 11 comparison figures exist in `claude/Validation/` but are NOT assembled into an appendix or referenced in the chapter (§4-4 promises them) |
| No "component = value" with equals sign in running prose | ⚠️ **PARTIAL** — ~10 instances remain in FA (e.g. `T*_max = 1.61`) |
| Every dimensional number needs a unit | ✅ mostly (spot-checked); worth one more proofread pass |
| Increase number of figures per section | 🔄 catalog delivered for selection; chapter still shows the 2×2 panel until you pick |
| Keep fixed T*/u*/σ* across cases AND add other components per study | 🔄 catalog now shows all 9 quantities; chapter selection pending |
| Interpretations for severe changes, peak-trough (قله-قعر), mirror/non-mirror pairs | ✅ added to §4-5/4-6/4-13 |
| Make curve changes smoother | ⚠️ catalog smoothed (makima); the **chapter figures (figures_print/color) are NOT yet smoothed** |
| Fig 4-15 (spatial) legend → top-right (northeast) | ✅ done (T2 script line 170) |
| Avoid inventing Persian terms | ✅ standard terms used |
| Word 2010-compatible files | ⚠️ pandoc/DocxBuilder produce OOXML .docx (should open in 2010); **not explicitly verified** |
| NEW runs: pressure 0–100 MPa; NL 3/5/9/15; W 2–4%; GPL aspect ratios; mixed BC; infinite-length; more GPL×porosity | ✅ all done + 4×4 matrix |
| Outline order matches page-4 draft exactly | ⚠️ **minor** — porosity level merged into 4-6 (outline lists it as 3-3); aspect-ratio made a standalone 4-8 |

## Part 3 — Round-2 review (Prom.2) — item status

| Item | Status |
|------|--------|
| و — appendix explaining Newmark + comparison methods | ✅ Appendix A (FA/EN) |
| pages 3–4 — code documentation (usage + technical) | ✅ CODE_DOC_usage/technical_FA |
| الف — color-coded editing of ch.1–3 (red delete / green add) + a 2nd version | ⬜ needs the existing ch.1–3 files (not in repo) |
| ب — complete the "blue"/un-analyzed sections | ⬜ needs ch.1–3 files |
| د/ه — ToC hyperlinks + English abstract | ⬜ final-assembly / needs files |
| ز — replace porosity patterns with the new MZ patterns + re-run | ⏸ **BLOCKED** — need the formulas |
| ح — fix length/thickness notation (not L / h) | ⏸ **BLOCKED** — need the symbols |
| GPL wt% question (0.1–2 % lit vs 4–8 % here) | 🔄 justification drafted in §4-7; confirm |

## Part 4 — GAPS at risk of being missed (prioritized)

1. **Validation appendix (comparison diagrams)** — *unblocked, required by round-1.*
   The 11 figures (`bench1_S/U` + NL5/NL20, `bench2_T_history/profiles`, `bench3_srr/stt/theta`)
   exist and are genuine present-vs-reference plots, but are orphaned. → Build an
   **Appendix B (validation)** assembling them with captions, and cite them from §4-4.
2. **"component = value" prose style** — *unblocked.* Reword the ~10 symbolic
   equalities in the FA chapter (and mirror in EN) per the review style rule.
3. **Chapter figures not smoothed** — the review's "smoother curves" was applied
   to the catalog only; the actual chapter figures need the same makima treatment
   (do this when finalizing the selected figures).
4. **Exact outline order** — small reorder to match the page-4 outline (optional).
5. **Word 2010 compatibility** — open one .docx in Word 2010 (or confirm target) to be safe.

## Part 5 — Open items that need YOU

- **ز** porosity MZ formulas → porosity re-run (§4-6, §4-13) + Chapter 3 material section.
- **ح** length/thickness symbols → all of Chapter 3 + a global notation pass.
- **GPL %** confirm the §4-7 justification.
- Catalog: **which panels** to finalize into ch4; and whether you want **stress/strain-vs-time** curves (needs a full-history re-run).
- Citations: fix list entry **#71** (points to Hosseini, not Omidi Bidgoli); add **Tzou 1995 [74]**; obtain the **3 must-cite papers** (paywalled).
- Chapters **1 (intro)** & **2 (lit review)** need your novelty framing / which papers to emphasize.

## Summary
Nothing in the *finished* deliverables is wrong (R3 chapter is referee-verified). The
main thing genuinely at risk of being missed is the **validation comparison appendix**
(figures exist, not assembled) plus the **"component = value" style** cleanup — both
unblocked. Everything else is either pending your selection/answers or correctly tracked.
