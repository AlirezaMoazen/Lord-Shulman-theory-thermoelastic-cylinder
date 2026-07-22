# claude/ — Verified Dynamic Solver & Validation Suite

MATLAB codes written by Claude (AI assistant) for the MSc thesis:
**Transient coupled Lord-Shulman thermoelastic analysis of multilayer porous
GPL-reinforced hollow cylinders** (layerwise DQM + Newmark).

> The original (legacy) codes of the project live in the repository root and
> `New Cods/`. This folder contains only the new, verified solver line.

## Quick start

Open MATLAB in this folder and run the current solver revision:

```matlab
claude_R5          % runs with default configuration (UD/UD patterns, LS on)
```

To run a custom case, set a `cfg` struct first (any config variable can be
overridden — misspelled fields produce a warning):

```matlab
cfg = struct('theory','LS', 'tau0',50, 'BC_z','S', ...
             'NL',5, 'N_r',9, 'N_z',11, ...
             'T_in_val',600, 'h_c',10, 'P_i',1e6, ...
             'total_time',100, 'dt',0.1);
claude_R5
```

`theory` accepts `'FOURIER' | 'LS' | 'DPL' | 'GN3'` (with `tau_T` for DPL and
`k_star` for GN-III).

## Files

| file | purpose |
|---|---|
| `claude_R5.m` | **current verified solver** (theory switch FOURIER/LS/DPL/GN3, all BC options, final porosity patterns) |
| `claude_R4.m` | campaign solver (adds Gaussian thermal-pulse loading) |
| `claude_R1.m` / `claude_R2.m` / `claude_R2_1.m` / `claude_R3.m` / `claude_R3_1.m` | frozen revision history (see PROTOCOL.md) |
| `run_param_studies_v3.ps1` | parallel campaign orchestrator (3 MATLAB jobs, skip-existing resume) |
| `claude_param_figures_R2.m` | campaign/extension figure generator (dimensionless); R1 frozen |
| `claude_T1_time_integrators.m` | T1: six time-integration methods compared (table) |
| `claude_T2_1_spatial_methods.m` | T2.1: spatial convergence DQM vs FDM vs FEM (lin+quad); T2 frozen |
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
| `param_studies/` | **raw data store**: one .mat + .log per campaign/extension case (33 campaign + T1/T2/T3) |
| `results_campaign/` | results-chapter figures of the **parametric campaign** (studies A–N); `figures_print/` = production B&W (PDF vector + PNG + FIG) |
| `results_extensions/` | results-chapter figures/tables of the **method & theory extensions** (T1 integrators, T2 spatial DQM/FDM/FEM, T3 theories); `figures_print/` = production B&W |
| `thesis_chapter/` | **results-chapter text**: RESULTS_CHAPTER_EN.md + RESULTS_CHAPTER_FA.md (English + Persian, 18 sections), FIGURE_CAPTIONS.md (EN+FA), chapter_stats.csv (all quoted numbers) |
| `claude_param_figures_R3.m` | production B&W figure generator (line styles + markers + grayscale, Times, vector PDF) |
| `claude_chapter_stats.m` | extracts the dimensionless numbers cited in the chapter text |

## Results-chapter organization

The thesis results chapter has two separated parts, mirrored by the folders:

1. **Parametric campaign** (`results_campaign/`) — physics of the cylinder:
   GPL patterns, porosity patterns/levels, relaxation time, coupling,
   pressure, convection, thickness, layers, shock loading (studies A–N).
2. **Extensions** (`results_extensions/`) — numerical-methods and theory
   comparisons that go beyond the reference theses: T1 time integrators,
   T2 spatial discretizations (DQM vs FDM vs FEM), T3 thermoelasticity
   theories (Fourier / LS / DPL / GN-III).

Raw case data for both parts stays in `param_studies/` (the figure scripts
read from there).

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
