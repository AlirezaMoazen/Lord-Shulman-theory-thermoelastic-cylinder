# REVISIONS — master index to follow every change & the progress
<!-- Author directive 2026-07-28: apply the revision-number rule to ALL files so
     the changes and progress are followable. THIS file is the single place to
     track it. Rule: every deliverable carries _R<n>; the first version is R1;
     any change = a NEW revision file (never edit a working file in place).
     Author directive 2026-08-03: MINOR change = _R<n>.<m> (e.g. R4.1, R4.2); MAJOR change = _R<n+1>.
     git commits are the dated timeline (bottom). -->

## How to read this
- **Current** = the revision you should use now. Older revisions are kept (frozen) for provenance.
- When something changes, a new `_R<n>` file appears here with a one-line note.
- One-off snapshots (a review transcription, an audit) are dated records, not evolving deliverables — listed under §6.

---

## 1. Solver (MATLAB)
| Artifact | Current | History |
|---|---|---|
| `claude_R#.m` (main solver) | **R7** | R1 fixed the broken dynamic solver (frozen) → R2 cfg engine + full-history + sine pressure → R2_1 audit fix → R3 BC options → R3_1 final porosity → R4 Gaussian shock → R5 theory switch (Fourier/LS/DPL/GN3) → R6 per-end BC + cfg-overridable GPL dims → **R7 explicit DOF numbering/mapping matrix (NodeMap + DOFmap + GridDOF + CSV export); physics digit-identical to R6 (Prom.2 p.4)** |

## 2. Parametric-campaign figure scripts
| Artifact | Current | History |
|---|---|---|
| `claude_param_figures*.m` | **R4** (+ `_R4_color`) | base → R2 → R3 → **R4** (adds pressure sweep, weight-fill, aspect, infinite, matrix; legend fix) + `R4_color` |

## 3. Quantity CATALOG (figure-selection tool)
| Artifact | Current | History |
|---|---|---|
| `claude_catalog_R#.m` | **R6** (`_R6` 4-panel · `_R6_full` · `_R6_extras` · `_conv`) | R1 = frozen (one 9-panel image) → R2 = two-part (hist+prof) + makima-smoothed → R3 = adds ε_rr and ε_zz strain profiles to Part 2 (8 panels; ε_zz then from last snapshot) → R4 = weight-fraction zoom study (D2) swapped to low range W = 0.1/0.3/0.5/0.9/1.5% → R5 = ε_zz recomputed from saved final-time stresses via Hooke's law (exact; 2μ per case) → **R6 = full rebuild for the NEW geometry (R_i 1 / R_o 1.5 / l 2.1, mesh N_r 15 / N_z 11) and the app10041397 (Heydarpour) dimensionless convention (Fo=α̂t/h², h=wall); split into `claude_catalog_R6.m` (4-panel selection: T*,u* vs Fo + T*,Σ_θθ vs ξ), `claude_catalog_R6_full.m` (8-panel hist+prof, all strains+stresses, Hooke ε_zz), `claude_catalog_R6_extras.m` (second-sound wave-fronts + 5×5 GPL×porosity matrix) and `claude_catalog_conv.m` (N_r/N_z/N_L/Δt convergence + min-nodes master). Prom.3 applied: 25-case matrix, a/b & b/t legends, sine-pressure study dropped.** |
| `FIGURE_CATALOG_R6_FA.docx` (+ `_R6.md`) | built from catalog **R6** (44 figures; color variant + EN pending author's selections) | on each catalog Rn the deliverables are renamed `_R<n>` too |

## 4. Results chapter 4
| Artifact | Current | History |
|---|---|---|
| `RESULTS_CHAPTER_FA/EN*_R#.md` (+ docx) | **R4.2** | base → R2 (authored FA+EN) → R3 (old geometry: split convergence/validation, aspect+infinite, 4×4 matrix, pressure 0–100 MPa, peak-trough/mirror) → **R4 = full rebuild for the NEW geometry (R_i 1 / R_o 1.5 / l 2.1), Heydarpour dimensionless convention (Fo=α̂t/h²), notation l=length/h=thickness; all 21 sections' numbers re-extracted from `param_studies_ch4`; Prom.3 applied (25-case matrix, a/b & b/t legends, sine study dropped); delivered as 4 docx (EN/FA × bw/color, 23 inlined figures each) built from `figures_ch4_bw` / `figures_ch4_color`. Heydarpour citation resolved to [69].** → **R4.1 (minor, Prom.5)** = removed the descriptive top-title from every figure (4-panel study, convergence, benchmarks — axis labels + legends kept, per author's "delete the title on top, keep the legend"); dropped Fig 4-6 (bench3: only the present solution was plotted, no Bagri & Eslami data overlaid → not a real comparison) and renumbered figures to **4-6…4-23** in both EN & FA (also fixed a stale pressure-figure cross-reference, 4-11→4-15); cropped benchmark 1 (Fig 4-4) to t*∈[0,0.5] to zoom the three-point match; benchmark 2 (Fig 4-5) title removed, legend upper-right. 4 docx rebuilt (23 figures each). **R4 kept frozen.** → **R4.2 (minor)** = added a new per-porosity figure set (author request): 5 figures at **4-19…4-23**, one per porosity pattern (UD/O/X/V/A), each overlaying the five GPL patterns in the 4-panel format — the 25-matrix unpacked pattern-by-pattern (matrix kept alongside). Previous 4-19…4-23 (coupling → theories) shifted to **4-24…4-28** in EN & FA. New script `claude_catalog_gplpor.m`; 4 docx rebuilt (28 figures each). **R4.1 kept frozen.** Open: optional §4-17 wave-front; final animation.** |
| `FIGURE_CAPTIONS*.md` | **R3** | base → R2 → **R3** (22 figs, new numbering) |

## 5. Other thesis deliverables (each is at R1 unless noted; next change → R2)
| Artifact | Current | Note |
|---|---|---|
| `APPENDIX_A_methods_FA/EN` (+ docx) | **R1** | Newmark + comparison methods (Prom.2 و) |
| `CHAPTER5_conclusions_FA/EN` (+ docx) | **R1** | conclusions + future work |
| `CODE_DOC_usage_FA` / `CODE_DOC_technical_FA` (+ docx) | **R1** | code documentation (Prom.2 p.3–4) |
| Appendix B (validation diagrams) | **not built yet** | figures exist in `claude/Validation/`; see PROJECT_AUDIT gap #1 |
| Chapter 3 (formulation) | **not started** | HELD pending notation (ح) + porosity (ز) |
| Chapters 1 & 2 (intro / lit-review) | **not started** | need author framing |

## 6. Records & governance (dated snapshots / living docs — tracked by git, not _R<n>)
| File | Role |
|---|---|
| `REVIEW_NOTES_final_author.docx` | round-1 supervisor review (authoritative) |
| `REVIEW2_PROM2.docx` | round-2 supervisor review (Prom.2) transcription |
| `PROJECT_AUDIT.md` | 2026-07-28 protocol/review/gap audit |
| `THESIS_TODO.md`, `WORK_PROTOCOL.md`, `DECISIONS_NEEDED.md`, `ROADMAP.md` | living governance (git history is the change log) |

---

## 7. Commit timeline (newest first — the dated progress trail)
| Commit | What |
|---|---|
| _(Prom.4b)_ | **Ch4 R4 — Prom.4 round 2 (Rezaei format + fixes):** figure captions rewritten in **Bahram Rezaei's thesis format** — bare figure number above (`۴-N`) + full caption below `شکل ۴-N: ‹توضیح› [‹پارامترها›]` with the case parameters in brackets (EN+FA). Fixes: bench1 legend `Present (claude_R2)` → `Present`; **τ\*=0.87 removed** from the relaxation figure 4-14 and its text (EN+FA); **25-matrix top title removed**. Figures re-rendered; 4 docx rebuilt. |
| _(Prom.4)_ | **Ch4 R4 — Prom.4 figure/format corrections:** colour plots solid-only + `sgtitle` removed (4-panel); **academic figure numbering** (Figure 4-N above each figure, caption below) with in-text refs renumbered (EN+FA); **length symbol l → L** throughout; 25-matrix axis labels on every subplot; **convergence §4-3 restructured into 3 subparts (N_r/N_z/N_L) with the (c)/(d) panels replaced by tables** (2-panel `conv2` figures); jump/severe-change explanations added; verification diagrams kept. New render script `code/catalog/claude_catalog_conv2.m`; 4 docx rebuilt (24 figs each). See [[supervisor-prom4-review]] / `reviews/REVIEW4_PROM4.md`. |
| _(R4+tidy)_ | **Ch4 R4 finished + repo tidy:** figure **captions** (descriptive, FA+EN) on all four docx (Prom.1); **3 verification comparison figures** inlined in §4-4 (present vs Malekzadeh/ANSYS, exact Bessel, Bagri&Eslami — Prom.1 "diagrams not tables only"); `FIGURE_CAPTIONS_R4`; **folder tidy** (Prom.3 #1) — `.m`→`code/{solver,catalog,validation,extensions,misc}`, runners→`campaign/`, docs→`governance/`+`reviews/`; data/figures/thesis_chapter kept at root so relative paths still resolve (run scripts from `claude/` via `run('code/.../x.m')`). |
| _(Ch4 R4)_ | Chapter 4 R4 EN draft (53283b1) + FA mirror & 4 docx EN/FA×bw/color (5b021be) — see §4. |
| ecd8d24 | **Ch4 catalog R6 + campaign at new geometry (N_r=15):** 81-case campaign + N_z axial sweep + convergence/min-nodes study (mesh locked N_r=15/N_z=11); 4-panel + full-component + wave-front + 25-matrix + convergence figures; `FIGURE_CATALOG_R6_FA.docx` (44 figs); `run_ch4_campaign.ps1` + `run_nz_sweep.ps1`; raw solver `.mat` gitignored (>100 MB, regenerable) |
| caf505b | Catalog: observe the revision-number rule (R1 frozen, R2 = current) |
| 980e496 | Project audit: protocols + review-item status + gaps |
| 64806ea | Figure catalog: color + two-part split + smoother curves |
| 770d10b | Quantity catalog for choosing ch4 figures ("more graphs" feedback) |
| ce61453 | Chapter 5: conclusions and future work |
| 385eac2 | Code documentation (Prom.2 pages 3-4) |
| 47b8cc9 | Appendix A: Newmark method + comparison methods |
| aca4a20 | Chapter R3: referee number-check fixes |
| b68c337 | Results chapter R3 + Prom.2 review transcription |
| c0c132a | Chapter R3: 4 sections the workflow could not finish |
| 6d02617 | Governance files + complete revision figures (B&W + color) |
| 2109b01 | claude_R6: per-end mechanical BC + cfg-overridable GPL dims |
| 99209bd | Revision runs (v4): pressure sweep, layers 9/15, weight-fill |
| 6235611 | Authoritative (author-corrected) chapter-4 review notes |
| 19b9ddf | Typed transcription of handwritten chapter-4 review notes |
| ec2e02a | Final results chapter R2 (FA+EN docx) |
| 82f38ac | Results chapter as Word documents (FA RTL + EN) |
| cf7650e | Results chapter: EN+FA text, B&W figures, captions, stats |
| 6858872 | ROADMAP.md: project path map |

*(full history: `git log --oneline` in the repo)*
