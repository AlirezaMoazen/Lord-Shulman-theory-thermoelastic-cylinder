---
dir: ltr
lang: en-US
---

<!-- CODE_WRITING_GUIDE_EN — a teaching document: how this codebase (solver,
     validation, catalog/figure scripts) is built, so the patterns can be
     reused/extended by hand. Companion to CODE_DOC_usage_FA/technical_FA
     (which document what the current code DOES) and CODE_FIX_HISTORY_EN/FA
     (which document the original bugs vs. claude_R1.m). This one explains
     HOW to write code in the same style. -->

# How this codebase is built — a guide to the patterns

This is not a reference for what each file does (see `CODE_DOC_usage_FA.md` /
`CODE_DOC_technical_FA.md` for that). It's a guide to the *recurring patterns*
used across the solver, the validation scripts, and the figure/catalog
scripts, so you can extend them yourself, or write new scripts that fit the
same conventions.

## 1. The big organizing idea: revision files, never in-place edits

Every solver file is named `claude_R<n>.m` (`claude_R1.m` … `claude_R8.m`).
When a bug is fixed or a feature is added, a **new file** is created —
`claude_R1.m` is never edited once it's verified. `claude_R8.m`'s own header
comment is the clearest example of why:

```matlab
%  REVISION R8 — FINAL / DEFINITIVE REVISION ...
%   * PHYSICS DIGIT-IDENTICAL to R7 (hence to R6): solver logic, matrix
%     assembly and the Newmark march are byte-for-byte unchanged. ONLY the
%     default model configuration was changed ...
%  ------------------------------------------------------------------------
%  REVISION R7 (additive, on frozen R6 -- supervisor review Prom.2 page 4):
%   EXPLICIT DOF NUMBERING / MAPPING MATRICES. ... they add NO physics and
%   change no result (K, C, M, the solve and every output are identical to
%   claude_R6).
```

Each revision states, explicitly, in its own header:
1. What is new.
2. What is guaranteed unchanged (usually: "digit-identical to R<n-1> when the
   new feature is left at its default").
3. Which real-world review or bug prompted it (a supervisor comment, an
   audit finding, a benchmark mismatch).

**Why this matters**: once a revision has been checked against a benchmark
(see §4), that check is permanent — nobody has to re-derive "does this still
match the exact static-limit test" every time a new feature is added,
because the new feature is proven not to touch the old code path. If you
ever need to change something in a *verified* file, the answer is: copy it
to a new revision number first, then edit the copy. This is why you now also
have `claude_ch123_figs_2016b.m` sitting next to `claude_ch123_figs.m`
instead of a modified original — same idea, different reason (compatibility
instead of a new feature), same rule.

## 2. The solver's structure (`claude_R8.m`), section by section

Every solver revision follows the same skeleton, marked with `%% ===` banner
comments so you can jump between sections in the MATLAB editor:

```
0. Model configuration     — every tunable knob, as plain variables
1. Geometry & discretization — layer radii, Chebyshev node grids, DQ weights
2. Loading & time parameters — temperatures, pressure, dt, total_time
   (cfg-override block lives here — see §3)
3. Material properties      — per-layer effective properties (GPL + porosity)
4. Global assembly           — build sparse K, C, M row by row
5. Row equilibration + diagnostics — condition the system, factorize once
6. Newmark time integration  — the actual time-marching loop
7. Post-processing            — profiles, stresses, save to .mat
   helper functions           — local functions, must be at the END of the file
```

This ordering is deliberate: **everything that can be computed once, is
computed once, before the time loop.** By the time you reach section 6, `K`,
`C`, `M` are final and already LU-factored (`[Lf,Uf,Pf_,Qf] = lu(K_eff)`);
the loop itself does only a forward/back substitution per step — no matrix
rebuilding, no re-factorization. This single design choice is *the* reason
3000 time steps run in seconds rather than minutes.

### DOF indexing: three small anonymous functions instead of bookkeeping arrays

Instead of maintaining an explicit lookup table for "which row of K
corresponds to node (layer e, radial ir, axial iz), field theta/u/w", the
solver defines three **anonymous functions** once, and calls them everywhere:

```matlab
Nn     = NL*N_r*N_z;             % nodes per field
Ndof   = 3*Nn;                   % theta, u, w
idx_Th = @(e,ir,iz)        (e-1)*N_r*N_z + (ir-1)*N_z + iz;
idx_U  = @(e,ir,iz)   Nn + (e-1)*N_r*N_z + (ir-1)*N_z + iz;
idx_W  = @(e,ir,iz) 2*Nn + (e-1)*N_r*N_z + (ir-1)*N_z + iz;
```

Every single assembly line reads as physics, not index arithmetic:
`K(idx_Th(e,ir,iz), idx_U(e,jr,iz)) = ...`. This is a much better pattern
than writing the index formula out by hand at every call site (easy to typo)
or building a giant lookup array up front (wastes memory, adds a layer of
indirection). Use this pattern any time you have a structured (field ×
layer × node) unknown vector.

### Differential-quadrature weight matrices: build once per direction

```matlab
z_nodes = chebyshev_grid(0, L, N_z);
[A_z, B_z] = DQ_weights(z_nodes);          % first & second derivative operators
r_nodes = cell(NL,1); A_r = cell(NL,1); B_r = cell(NL,1);
for e = 1:NL
    r_nodes{e} = chebyshev_grid(R_bound(e), R_bound(e+1), N_r);
    [A_r{e}, B_r{e}] = DQ_weights(r_nodes{e});
end
```

`chebyshev_grid` and `DQ_weights` are the two **local helper functions**
defined at the very bottom of the file (MATLAB requires local functions in a
*script* — as opposed to a function file — to come after all script code;
this needs R2016b or later, see `CODE_FIX_HISTORY_EN.md` for why that
matters for older MATLAB). `A_r{e}` is the first-derivative matrix for layer
`e`'s radial grid: `dT/dr` at every node is just `A_r{e} * T_layer_e`, a
matrix-vector product, no finite-difference stencils to hand-derive. This is
the entire payoff of differential quadrature: turn "write a derivative" into
"multiply by a precomputed matrix."

### Per-layer effective properties: one loop, one set of formulas, called once

Section 3 computes seven effective properties (`E_L_, nu_L_, rho_L, c_L,
k_L, al_L`, `NL`-vectors) with a single `for e = 1:NL` loop that applies
Halpin-Tsai + rule-of-mixtures + the open-cell porosity factor. This is
**not** repeated inside the assembly loop — assembly (section 4) only ever
*reads* `C11(e)`, `k_L(e)`, etc., it never recomputes them. Keeping
"compute material properties" and "use material properties" as two separate,
sequential phases (rather than interleaving them) is what makes it possible
to unit-test material properties independently (see
`claude_porosity_check_R3_1.m`-style scripts) and what makes the assembly
loop itself easy to read.

### Global assembly: constraint rows are just "zero the row, write a new equation"

Every boundary condition or interface-continuity condition follows the same
three-line idiom:

```matlab
K(n,:)=0; C(n,:)=0; M(n,:)=0;      % erase whatever the interior-PDE loop wrote here
K(n,n) = 1;                        % ... then write the real constraint equation
```

Because the interior-PDE loop (section 4.1) writes an equation into *every*
row first (including rows that are actually boundary nodes), section 4.2
runs strictly afterward and **overwrites** those rows with the true boundary
equation. This ordering — "assemble everything as if there were no boundary,
then stamp the boundary equations on top" — is simpler than trying to special
-case boundary nodes inside the interior loop, and it generalizes cleanly:
adding a new boundary-condition type (`claude_R3`'s `T_BC_in='flux'`, for
example) means adding one more `if`/`switch` branch in section 4.2, with zero
changes to section 4.1.

### The `cfg` struct: run 100 variants without editing the file 100 times

```matlab
if exist('cfg','var') && isstruct(cfg)
    fn = fieldnames(cfg);
    for iov = 1:numel(fn)
        if ~exist(fn{iov}, 'var')
            warning('cfg field "%s" does not match any configuration variable...', fn{iov});
        end
        eval([fn{iov} ' = cfg.(fn{iov});']);
    end
end
```

Any script variable declared in section 0–2 (e.g. `tau0`, `NL`, `R_i`,
`GPL_pattern`) can be overridden from *outside* the file, without touching
it, by building a struct and running the solver as a script:

```matlab
cfg = struct('NL', 5, 'porosity_pattern', 'V', 'tau0', 111);
claude_R8;   % note: no parentheses, no output args — this RUNS the script
```

This is how the whole 86-case parametric campaign (`param_studies_ch4/`)
works — one script (`run_ch4_campaign.ps1`) loops over case definitions and
calls the solver once per case with a different `cfg`, never editing
`claude_R8.m` itself. The `warning` on unknown field names exists because
this pattern has a sharp edge: `eval` will silently do nothing useful if you
typo a field name (`cfg.N_L` instead of `cfg.NL`, say) — the warning is
what catches that instead of a silently-wrong run.

**Important gotcha reused everywhere in this project**: `claude_R8;` runs
with `clearvars -except cfg` at the top, so it inherits nothing from your
workspace except `cfg` — and if you call it via MATLAB's `run('full/path/to/
claude_R8.m')` (rather than having it on the MATLAB path and calling it by
name), **MATLAB changes the current directory to the script's own folder**
before running. Any relative path inside the script (`outdir =
'figures_ch4'`) then resolves against the *script's* folder, not wherever
you started from. Every script in this project that writes output uses an
absolute path for exactly this reason — see §5.

## 3. Validation scripts (`code/validation/*.m`)

The pattern for a benchmark script is always: **compute an independent
reference answer, run the solver via `cfg`, compare, report a relative
error** — never "eyeball a plot and decide it looks right."

```matlab
cfg = struct('NL', 5, 'N_r', 9, ..., 'theory', 'FOURIER', ...);   % match the paper's case
claude_R2;                                    % run the solver with this cfg
% ... independent reference values, either analytic or digitized from a paper's table ...
err_pct = 100*abs(U_solver - U_paper)/abs(U_paper);
fprintf('U error vs paper: %.3f%%\n', err_pct);
```

The solver is never modified to "pass" a benchmark — if a benchmark
disagrees, the fix goes into the *next* solver revision (with the
benchmark re-run to confirm), and the disagreement plus fix are documented
in that revision's header, the same way `claude_R1.m`'s header documents
the four bugs found in the original `Main_Dyn.m` (see
`CODE_FIX_HISTORY_EN.md`). Six independent benchmarks currently exist,
each stressing a different part of the physics: a pure-static limit, two
literature comparisons (with a reported ANSYS column), an exact
Bessel-series transient-conduction solution, a Newmark-vs-`ode15s` check,
and a published Lord-Shulman wave benchmark. New features should, where
possible, get a new benchmark rather than relying on the old ones (a new
boundary-condition type isn't exercised by a benchmark that never uses it).

## 4. Catalog / figure-generation scripts (`code/catalog/*.m`)

These scripts never compute physics — they only **read** the `.mat` files
the solver already saved (into `param_studies_ch4/`) and turn saved numbers
into dimensionless plots. The recurring skeleton:

```matlab
CLROOT = 'c:/.../claude';                       % absolute — see the run() gotcha above
pdir = fullfile(CLROOT,'param_studies_ch4');    % where to read cases from
cdir = fullfile(CLROOT,'figures_ch4');          % where to write PNGs to

ahat = 8.9708e-5; E_ref = 4.433e9; ...          % FIXED reference material props,
Fo  = @(t,h) ahat.*t./h.^2;                     % used for EVERY case so curves
Tst = @(T)   (T - T_inf)./T_inf;                % are directly comparable — never
Ust = @(u,h) u./((1-nu_ref).*alp_ref.*T_inf.*h);% re-derived per case
Sst = @(s)   (1+nu_ref).*s./(E_ref.*alp_ref.*T_inf);

for ci = 1:numel(cases)
    d = load(fullfile(pdir,[cases{ci} '.mat']));
    plot(Fo(d.tv, h), Tst(d.hist_T), 'Color', CO{ci}, 'LineWidth', 1.4);
end
```

Two style rules, applied uniformly across every catalog script this session:
1. **No `title()`/`sgtitle()`/floating `text()` annotations** — only axis
   labels, tick labels, and legends. Figure numbers and captions belong in
   the thesis text, not baked into the image. (Two narrow, deliberate
   exceptions: box-and-arrow diagrams where the text *is* the content — see
   `claude_ch123_figs.m`'s flowchart/taxonomy figures — and per-cell
   identity labels in the 25-panel GPL×porosity matrix, where the label is
   structural, not decorative.)
2. **Color figures use solid lines only** (`'-'`); curves are told apart by
   color and marker shape. **B&W/print figures** (recognizable by a
   grayscale `STY.co`/`CO` palette) are the one place varied line styles
   (`'--'`, `':'`, `'-.'`) are legitimate, because color isn't available to
   distinguish curves there.

A `STY` (or `BW`) struct bundling `co` (colors), `ls` (line styles), `mk`
(markers), `lw` (line widths) as parallel cell arrays, indexed by
`mod(ci-1,N)+1`, is the standard way to keep five-curve comparison plots
visually consistent across dozens of figures without repeating the same
five `plot(...)` calls everywhere — write a small `curve(x,y,ci,STY)` helper
once, call it from every figure.

## 5. Cross-cutting conventions worth copying into your own scripts

- **Absolute paths for anything invoked via `run()`.** Never write
  `pdir = 'param_studies_ch4'`; write
  `pdir = fullfile(CLROOT, 'param_studies_ch4')` with `CLROOT` a full,
  absolute path defined at the top of the script. This one habit prevents
  an entire class of "my script silently wrote to the wrong folder" bugs —
  it happened twice this session (`claude_chapter_stats_ch4.m` and four
  catalog scripts) before becoming a hard rule.
- **Local helper functions at the end of the file**, with a comment marking
  the boundary (`%% ---- local helper functions (must be at end of a
  script) ----`). Keeps the "what does this script actually do" narrative at
  the top, implementation details at the bottom.
- **Header comments as a running changelog**, not just a one-line
  description — every solver revision's header lists what changed and what
  is guaranteed unchanged. Six months from now, `git log` tells you *when*
  something changed; the header tells you *why*, in the same place you're
  already reading.
- **`fprintf` diagnostics at natural checkpoints**, not scattered debug
  prints: `Ndof`, the estimated reciprocal condition number, the static
  -limit self-check, per-step progress every 5% of the run, final-state
  values compared against their expected targets. Every one of these is a
  place where a bug would visibly show up as a wrong or `NaN`/`Inf` number —
  cheap insurance, printed by default, no flag needed to turn it on.
- **English comments only.** MATLAB's editor and console don't render
  Persian reliably, so every comment in every `.m` file in this project is
  English, even though the thesis text and most documentation are Persian.
- **Don't invent physics to make code shorter.** `claude_R8.m` runs a
  `NL=7, N_r=15, N_z=11` case in a few seconds mainly *because* nothing is
  approximated for convenience — matrices are exact DQM operators, the
  Newmark scheme is unconditionally stable at $\delta=1/2$, the LU
  factorization is reused. Efficiency in this codebase comes from
  algorithmic choices (factor once, substitute per step; vectorize where
  it's easy), not from cutting numerical corners.

## 6. Where this document stops

This explains *patterns*, not every line of `claude_R8.m` — for the exact
current configuration defaults and how to run a case, see
`CODE_DOC_usage_FA.md`; for the mathematical formulation itself (governing
equations, DQM/Newmark derivation), see `CODE_DOC_technical_FA.md` and
Chapter 3 of the thesis. For a live discussion of where `claude_R8.m` itself
could be made faster without changing any result, see the companion note in
this session about assembly-loop vectorization — that is a *performance*
change, larger in scope than anything above, and (per §1) would need to ship
as a new, separately-validated revision rather than an edit to `claude_R8.m`.
