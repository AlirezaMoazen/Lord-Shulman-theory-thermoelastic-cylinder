# REVISIONS — master index to follow every change & the progress
<!-- Author directive 2026-07-28: apply the revision-number rule to ALL files so
     the changes and progress are followable. THIS file is the single place to
     track it. Rule: every deliverable carries _R<n>; the first version is R1;
     any change = a NEW revision file (never edit a working file in place);
     audit fixes = _R<n>_<m>. git commits are the dated timeline (bottom). -->

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
| `claude_catalog_R#.m` | **R5** (+ `_R5_color`) | R1 = frozen (one 9-panel image) → R2 = two-part (hist+prof) + makima-smoothed → R3 = adds ε_rr and ε_zz strain profiles to Part 2 (8 panels; ε_zz then from last snapshot) → R4 = weight-fraction zoom study (D2) swapped from 2–4% to the low range W = 0.1/0.3/0.5/0.9/1.5% (cases D3_W_001..015) → **R5 = ε_zz recomputed from the saved final-time stresses via Hooke's law (exact final; 2μ recovered per case from σ_rr−σ_θθ)**, B&W + color |
| `FIGURE_CATALOG_R5_FA.docx` / `_R5_color_FA.docx` | built from catalog **R5** (docx + md filenames now carry the revision number) | on each catalog Rn the deliverables are renamed `_R<n>` too |

## 4. Results chapter 4
| Artifact | Current | History |
|---|---|---|
| `RESULTS_CHAPTER_FA/EN*.md` (+ docx) | **R3** | base → R2 (authored thesis style, FA+EN) → **R3** (split convergence/validation, aspect+infinite sections, 4×4 matrix, pressure 0–100 MPa, peak-trough/mirror interpretations, figs 4-1…4-22) |
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
