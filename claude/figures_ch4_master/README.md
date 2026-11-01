# figures_ch4_master

Master folder holding every Chapter 4 figure-revision folder (moved here 2026-11-01, author request).
Contents are unchanged; only the parent folder changed (`git mv`, history kept).

Old location `claude/figures_ch4*/` -> new location `claude/figures_ch4_master/figures_ch4*/`

| Group | Folders |
|---|---|
| Staging / embedded sets | `figures_ch4`, `figures_ch4_bw`, `figures_ch4_color` |
| B&W revisions | `figures_ch4_R8` ... `figures_ch4_R20`, `figures_ch4_R12_extras_R2`, `figures_ch4_bw_R9`, `_bw_R10`, `_bw_R21` |
| Colour revisions | `figures_ch4_color_R8` ... `figures_ch4_color_R21` |

**Not moved:** `figures_catalog*`, `figures_ch123`, `figures_conv_explore`, `figures_validation`.

**Paths in older files are NOT rewritten** (no-rewrite rule). Scripts in `code/catalog/` and `.md` files
(e.g. `defense/DEFENSE_SLIDES_FA_R*.md`) still say `figures_ch4_*`; resolve them by inserting
`figures_ch4_master/`. Re-running an old script would recreate the old-name folder at `claude/`.
New revisions should write to `figures_ch4_master/<folder>`.
