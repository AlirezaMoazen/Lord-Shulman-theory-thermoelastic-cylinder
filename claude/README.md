# claude/ — Verified Dynamic Solver & Validation Suite

MATLAB codes written by Claude (AI assistant) for the MSc thesis:
**Transient coupled Lord-Shulman thermoelastic analysis of multilayer porous
GPL-reinforced hollow cylinders** (layerwise DQM + Newmark).

> The original (legacy) codes of the project live in the repository root and
> `New Cods/`. This folder contains only the new, verified solver line.

## Quick start

Open MATLAB in this folder and run the current solver revision:

```matlab
claude_R3_1        % runs with default configuration (UD/UD patterns, LS on)
```

To run a custom case, set a `cfg` struct first (any config variable can be
overridden — misspelled fields produce a warning):

```matlab
cfg = struct('LS_enabled',true, 'tau0',1e-5, 'BC_z','S', ...
             'NL',5, 'N_r',9, 'N_z',11, ...
             'T_in_val',600, 'h_c',10, 'P_i',1e6, ...
             'total_time',0.05, 'dt',5e-4);
claude_R3_1
```

## Files

| file | purpose |
|---|---|
| `claude_R3_1.m` | **current verified solver** (LS/Fourier, all BC options, final porosity patterns) |
| `claude_R1.m` / `claude_R2.m` / `claude_R2_1.m` / `claude_R3.m` | frozen revision history (see PROTOCOL.md) |
| `Static_Baseline_R1.m` | independent static solver (legacy Main-EN + one bug fix) used for cross-validation |
| `Compare_R1.m` | static-vs-dynamic cross-validation script |
| `claude_R2_run_benchmark1.m` | Benchmark 1: IJPVP-2012 Table 6 (dynamic pressure vs paper + ANSYS) |
| `claude_R2_run_benchmark2.m` | Benchmark 2: exact Bessel transient conduction + Newmark-vs-ode15s table |
| `claude_R3_run_benchmark3.m` | Benchmark 3: Bagri-Eslami LS wave benchmark (self-contained 1-D radial solver) |
| `claude_R2_run_LSdemo.m` | Lord-Shulman wave-propagation demonstration figures |
| `claude_porosity_check_R3_1.m` | proves the porosity-pattern implementation reproduces the author's tables |
| `claude_porosity_variant_test.m` | the investigation script that identified the pattern conventions |
| `Validation/` | all benchmark figures (PNG 300 dpi + editable .fig) and CSV tables |
| `results/` | saved .mat results of the verification runs |

## Validation status (all figures/tables in `Validation/`)

| test | reference | result |
|---|---|---|
| spatial assembly | independent static solver | agree to 2×10⁻¹¹ |
| dynamic mechanics | Malekzadeh & Heydarpour IJPVP 98 (2012) Table 6 + ANSYS | U* within 0.1–0.2 %, σ_rr exact |
| transient conduction | exact Bessel-series solution | rel. error 10⁻⁵ → 10⁻⁷ |
| time integration | MATLAB ode15s (independent) | agree to 0.003 K, Newmark ~10× faster |
| LS coupled waves | Bagri & Eslami IJMS 49 (2007) | both wave speeds + reflections exact |
| convergence | layer refinement NL = 5/10/20 | first-order, extrapolates onto paper values |

See `ARCHITECTURE.md` for the solver design and `PROTOCOL.md` for the
working rules (revision naming, no-rewrite policy, verification workflow).
