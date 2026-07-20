# PROTOCOL — working rules of this code line

These rules were agreed between the author (Alireza) and Claude and apply to
every change in this folder.

## 1. Revision naming
- New **features** → next major revision: `claude_R1` → `claude_R2` → `claude_R3` → …
- **Audit / correction** changes → sub-revision: `claude_R2_1`, `claude_R3_1`, …
  (MATLAB forbids dots in script names, so "R x.1" is written `_R x _1`.)
- Old revisions are **frozen** — they are the verified history.

## 2. No-rewrite rule
Never rewrite or restructure code that works and is verified.
A new revision starts as a **copy** of the previous verified revision and
receives **surgical, additive** changes only, each marked with a comment
(`(R3 addition)`, `(R3_1 fix)`, …). Performance rewrites (e.g. vectorized
assembly) get their own revision and must reproduce the previous revision's
results before being used.

## 3. Verification workflow (every revision)
1. **Regression**: run with default configuration — results must match the
   previous verified revision **digit-for-digit** (default behavior may
   never change silently).
2. New features are exercised by a dedicated driver/benchmark script.
3. Physics changes are verified against an independent source (exact
   solution, published table, or the independent static solver).
4. Uncertain formulas are implemented behind **warnings** until confirmed
   by the author/supervisor, then finalized in a sub-revision.

## 4. Configuration, not editing
Parameter studies run through the `cfg` override struct — the solver file
is not edited per run. Drivers live in separate `*_run_*.m` scripts.

## 5. Outputs
Each solver run saves `Results_claude_R<rev>.mat` (overridable via
`cfg.out_name`). Benchmarks write publication figures (PNG 300 dpi + .fig)
and CSV tables into `Validation/`.

## 6. Decisions log
Open physics/spec decisions are tracked in the thesis notes and closed by
the author/supervisor; the code carries explicit warnings for anything not
yet decided. Current status: porosity patterns FINAL (R3_1); base geometry
FINAL (R_i = 0.1 m, R_o = 0.2 m — thick-walled, R_o/R_i = 2); dimensionless
presentation FINAL (Fo, τ̄, T*, ξ, u*, σ*); pending: end-BC choice for the
thesis results (S vs C — study F data available), γ smoothing for figures.
