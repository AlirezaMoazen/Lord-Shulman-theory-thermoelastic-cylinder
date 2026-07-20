# Lord-Shulman Thermoelasticity of a Multilayer Porous GPL Cylinder

MSc thesis project (Alireza Moazen): transient coupled **Lord-Shulman**
thermoelastic analysis of **multilayer porous graphene-platelet-reinforced
hollow cylinders** under thermo-mechanical loading — **layerwise DQM** in
space, **Newmark** in time, MATLAB.

## Repository map

| folder | content |
|---|---|
| **`claude/`** | ✅ **current verified solver line + full validation suite** — start here (see `claude/README.md`) |
| `New Cods/` | legacy development: `Main-EN.m` (working static solver), `Main_Dyn*` (historical dynamic attempts, superseded) |
| `M/` | old reference Newmark code (FGM cylinder) + DQ weight function |
| `Dibag/`, `saved/`, `gp/`, root `Untitled*` | historical hand-built development files |
| `Graphs and Figure/` | thesis illustration scripts (GPL/porosity pattern figures) |
| `MZ-R 0.docx` | **mathematical specification** of the thesis problem (authoritative) |
| `Porosity_patterns_doc.docx` | porosity-pattern definitions + coefficient tables (authoritative) |
| `پیش نویس پایان نامه (R 0.1).docx` | thesis draft |
| `پایان نامه بهرام رضایی….pdf` | related thesis (conical shells, same research group) |
| `*.pdf` (root) | key reference papers |

## Status (2026-07)
- Dynamic Lord-Shulman solver: **working and verified** (`claude/claude_R3_1.m`)
- Validation: 3 independent benchmarks + convergence + method-comparison —
  all passed (figures in `claude/Validation/`)
- Porosity patterns (UD/O/X/V/A): finalized and proven against the
  coefficient tables
- Next: parametric studies for the results chapter

## Requirements
MATLAB R2020a+ (developed on R2026a). No toolboxes required.
