# CLAUDE.md — start here

MSc thesis project (author: Alireza Moazen): transient coupled **Lord-Shulman** thermoelastic
analysis of **multilayer porous GPL-reinforced hollow cylinders** — layerwise DQM in space,
Newmark in time, MATLAB. All current work is in `claude/`; the repo root holds legacy code,
reference papers, and the authoritative spec documents (`MZ-R 0.docx`,
`Porosity_patterns_doc.docx`, thesis draft `پیش نویس پایان نامه (R 0.1).docx`).

## Read first (in this order)
1. `claude/HANDOFF_R1.md` — current state, what is stale, what is open, how to resume.
2. `claude/governance/WORK_PROTOCOL.md` — standing rules agreed with the author + decision log.
3. `claude/governance/PROTOCOL.md` — code rules (revision naming, no-rewrite, verification).
4. `claude/REVISIONS.md` — master index: the current revision of every artifact + commit timeline.
5. `claude/governance/THESIS_TODO.md`, `DECISIONS_NEEDED.md` — task plan / open questions
   (both last updated 2026-08-06; see the HANDOFF for what changed since).

## Rules that must not be broken
- **Revision naming for ALL files**: `_R<n>`; first version R1; a change = a NEW file (`_R<n+1>`,
  or `_R<n>.<m>` for a minor change). Never edit a working file in place; old revisions stay frozen.
- Log every new revision in `claude/REVISIONS.md` (same task, not a follow-up).
- **No-rewrite** for verified code: new revision = copy + surgical marked changes; must reproduce
  the previous revision's default results digit-for-digit.
- Studies run through the `cfg` struct, never by editing the solver.
- **`.md` and `.docx` must not drift**: before editing an `.md`, check for a same-name `.docx`;
  if present, regenerate it in the same task and verify the text landed (pandoc exits 0 even when
  it drops content). Exceptions: `*_R1.1_tracked` chapters (use themselves as `--reference-doc`)
  and `CHAPTER3_formulation_*` (embedded figures + numbered equations; do not regenerate naively).
- Every number quoted in the thesis comes from saved results, never invented.
- Single-branch repo, direct to `main`; commit + push finished work the same session; no scratch
  scripts left untracked in the tree.
- Persian + English chapter text; B&W and color figure variants exist for Ch4.

## Commands
- MATLAB R2026a: `"C:\Program Files\MATLAB\R2026a\bin\matlab.exe" -batch "addpath('code/catalog'); <script>; exit(0)"`
  (run from `claude/`). **Max 3 concurrent `-batch` jobs** (a 4th gives license error 5001).
- Current solver: `code/solver/LSTE_solver_R11.m` (override with a `cfg` struct, then run the script).
- Pandoc is installed: `pandoc "<f>.md" -o "<f>.docx" --reference-doc="<repo-root>/پیش نویس پایان نامه (R 0.1).docx"`
- Campaign orchestrators: `claude/campaign/run_ch4_campaign.ps1`, `run_nz_sweep.ps1`.

## Not in git
`claude/param_studies_ch4/` (~1.1 GB raw campaign results) and `*.log` are git-ignored. If the
folder is missing, regenerate with the two campaign scripts above (long run).
