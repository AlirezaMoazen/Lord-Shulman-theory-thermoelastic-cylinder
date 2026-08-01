# Literature parameter survey — for finalizing Chapter‑4 numerical parameters

Purpose: representative values from the literature for **(1) GPL platelet dimensions, (2) cylinder
geometry, (3) internal pressure, (4) GPL weight fraction** (+ porosity), to justify the Chapter‑4
choices and answer the supervisor's "why is the GPL wt% higher than literature (0.1–2 %)?" question.
Extracted from the author's own paper library (`Desktop\MSc\papers\` + main folder). ⭐ = the
supervisor's group (Heydarpour / Malekzadeh) — the direct methodological lineage of this thesis.

## Master comparison table

| # | Paper | Structure / reinforcement | GPL a×b×t | Geometry (R_i,R_o / ratios, L) | Pressure / load | GPL wt% | Porosity |
|---|---|---|---|---|---|---|---|
| 1 | ⭐ Heydarpour, Malekzadeh & Gholipour 2019, *Compos. B* **164**, 400–424 | **GPLRC spherical shell, Lord‑Shulman** | 2.5 µm×1.5 µm×1.5 nm | R_i 0.8, R_o 1.0 m (R_o/R_i 1.25) | **30–50 MPa** internal + thermal shock 500 K | 0.3 % base → 1 % | — |
| 2 | ⭐ Heydarpour et al. 2020, *Compos. Struct.* **235**, 111707 | **GPLRC truncated cone, Lord‑Shulman** | 2.5×1.5×1.5 | R 1, h 0.2, L 2 (R/h 5, L/R 2) | **thermal ramp T_i(1−e^(−t/t₀)), T_i 500 K, t₀ 2 s, h_c 10**, Ω 400 rad/s | **0.3 %** | — |
| 3 | ⭐ Heydarpour et al. 2020, *Thin‑Walled Struct.* **155**, 106914 | FG‑GPLRC cylindrical shell | 2.5×1.5×1.5 | R 1, L 5 (R/h 50–100, thin) | impulse 50–100 kN, ΔT 0–10 K | 0.3–1 % | — |
| 4 | ⭐ Malekzadeh, Heydarpour et al. 2012, *IJPVP* **98**, 43–56 | FG cylindrical shell (ZrO₂/Ti) | — | R_i 0.08, R_o 0.1 m (1.25), L/R_o 10 | **internal 100 MPa (sine)**, thermal 300–1100 K, h_c 200 | — | — |
| 5 | ⭐ Heydarpour, Malekzadeh & Vaghefi 2011, *Acta Mech.* | FG cylindrical shell (LW‑DQM) | — | R_o 1, R_i/R_o 0.8 (1.25), L/R_o 1 | rotation ≤600 rad/s + thermal | — | — |
| 6 | ⭐ Heydarpour et al. 2021, *Thin‑Walled Struct.* **165**, 107958 | GRE cyl. shell (glass fibre, **no GPL**) | — | h/R 0.01, L/R 4 | impulse 200 kN | — | — |
| 7 | Hosseini 2021, *Thin‑Walled Struct.* **166**, 108108 | GPL+CNT hybrid **cylinder, Gaussian shock** | 2.5×1.5×1.5 | r_in 1, r_out 1.5 (**1.5, thick**) | Gaussian thermal shock (no mech.) | 0.1 % | — |
| 8 | Zhang et al. 2023, *Thin‑Walled Struct.* **192**, 111180 | **porous** GPL cylindrical panel | 2.5×1.5×1.5 | R 5, h 0.04 (R/h 125) | moving load ≤100 kN/m, ΔT 150 K | 1.0 % | **e₀ 0–0.6** |
| 9 | Eyvazian et al. 2021, *Compos. Struct.* **267**, 113879 | GPLRC sandwich cylinder | 2.5×1.5×1.5 | h/R 0.5, L/R 1–2 | free vibration (no pressure) | 1.5 % | — |
| 10 | Huang et al. 2023, *Arch. Appl. Mech.* | **porous** FG‑GPLRC truncated cone | 2.5×1.5×1.5 | R/h 100 | external/axial buckling + thermal | 0.5 % (swept **0–5 %**) | **e₀ 0.2–0.6** |
| 11 | Monajemi et al. 2024, *Acta Mech.* | GPL sandwich cylinder + MRE core | (E_GPL 1.01 TPa) | R_i 0.1, L 0.1 m | spinning + magnetic 0.2–1.2 T | 0.3 % | — |
| 12 | Nam et al. 2023, *Thin‑Walled Struct.* **193**, 111296 | GPLRC circular plate + spherical cap | ratios only | R_b/h 50 | external pressure + thermal | varied | — |
| 13 | Najibi & Talebitooti 2017, *Compos. B* | **2D‑FGM thick hollow cylinder** (no GPL) | — | **R_i 0.1, R_o 0.15, L 0.2 m (1.5)** | transient thermal ~1000 °C (no mech.) | — | — |
| 14 | Akbari Alashti & Khorsand 2011, *IJPVP* **88**, 167–180 | FG cyl. shell + piezoelectric | — | R_i 0.6–0.8, R_o 1.0 (1.25–1.67) | ref. 1 GPa scale, V 100 V | — | — |
| 15 | Ying & Wang 2010, *IJPVP* **87**, 714–720 | isotropic hollow cyl., thermal shock | — | R_i/R_o 0.5 (**2.0, thick**), L/R_o 100 | thermal shock (σ_θ ~600 MPa) | — | — |
| 16 | Chen et al. 2023, *Thin‑Walled Struct.* **191**, 111046 | FG porous structures — **review** | — | — | — | — | broad |

## Recommended values / ranges for Chapter 4

| Parameter | Literature (this table) | Recommendation | Author's current | Verdict |
|---|---|---|---|---|
| **GPL a×b×t** | 2.5 µm × 1.5 µm × 1.5 nm (universal; 9 papers) | keep 2.5/1.5/1.5; vary aspect ratios parametrically | 2.5/1.5/1.5 | ✅ standard — no change |
| **GPL props** | E 1.01 TPa, ρ 1062.5, ν 0.186 | keep | same | ✅ |
| **R_i** | 0.08–0.1 m (thick‑cylinder group) | **0.1 m** | 0.1 m | ✅ |
| **R_o/R_i** | 1.25 (⭐group), 1.5 (Najibi, Hosseini), 2.0 (Ying‑Wang thick benchmark) | **1.5–2.0** → R_o 0.15–0.20 m | 2.0 (R_o 0.2) — also 3.0 (R_o 0.3) | ✅ at 2.0; **3.0 = flag "very thick"** |
| **L / R_o** | 1–10 (mostly 1–5) | **2–5** | L 0.5, L/R_o 2.5 | ✅ |
| **Internal pressure** | mostly thermal‑only; where applied **30–100 MPa** (⭐30–50; ⭐100 sine) | sweep **0–100 MPa**, base **30–50 MPa** | base 1 MPa, sweep 0–100 | ✅ sweep; **raise base to 30–50 MPa** |
| **GPL wt%** | base **0.3 %**; typical 0.3–1.5 %; parametric to 5 % | base **0.3 % (or 1 %)**, study **0–1.5 %** | base 4 % (high); low‑W 0.1–1.5 % | ✅ low‑W; **use 4 % only as parametric upper limit** |
| **Porosity e₀** | 0–0.6 (Zhang, Huang) | 0–0.6 | e_m3 0.898 (≈ moderate) | ✅ comparable |
| **Thermal BC** | ⭐ ramp T_i(1−e^(−t/t₀)), T_i 500 K, h_c 10 (Heydarpour 2020) | ramp; h_c 10; T_i 500–600 K | ramp, T_in 600 K, h_c 10, t₀ 0.5 | ✅ matches ⭐; t₀ differs (ok) |

## Lord–Shulman relaxation time τ₀ (from the 3 LS papers in the library)
All three LS papers are by **Heydarpour & Malekzadeh** (the supervisors), so this is the house convention:
- τ₀ is used **DIMENSIONLESS**: `τ̃₀ = τ₀·ᾱ/R²` (thermal‑diffusivity / Fourier scaling). **Base ≈ 0.1**; `τ̃₀ = 0` = classical‑Fourier limit. **Never given in seconds.**
  - Heydarpour, Malekzadeh & Gholipour 2019 (Compos. B 164): `τ̃₀ = τ₀ᾱ/R_o²` for FG‑GPLRC results; a separate *acoustic* scaling `τ̃₀ = τ₀v̂/ℓ = 4` only in the Kiani–Eslami validation.
  - Heydarpour et al. 2020 (Compos. Struct. 235): `τ̃₀ = τ₀ᾱ/R_m²`, `τ̃₀ = 0` = classical.
  - Heydarpour & Malekzadeh 2019 (IJST‑ME, DOI 10.1007/s40997‑018‑0199‑0): base **s̄ = 0.1**.
- **Canonical FG‑cylinder LS references** (also in library): Bahtui & Eslami 2007 (`10.1002_nme.1782`), Bagri & Eslami (FG annular disk / thick cylinder, LS) — both use a dimensionless/parametric τ₀.
- **Physical τ₀** of real materials ≈ picoseconds (10⁻¹²–10⁻¹¹ s) — never used in these analyses (effect would be invisible).
- **⚠️ In these papers `t₀ = 2 s` is the thermal‑ramp time constant** in `T = T_i(1−e^(−t/t₀))` — i.e. `t0_ramp`, **NOT** the relaxation time.
- **Recommendation:** keep τ\* dimensionless (ᾱ/R² scaling); base **τ\* = 0.1** (match supervisor) or keep 0.44; study span 0.15/0.44/0.87 is fine. If the code needs seconds at R_o = 1.5 m: τ₀ = τ\*·R_o²/ᾱ → **~640 / 2800 / 5560 s** for τ\* = 0.1 / 0.44 / 0.87. Report vs Fo with τ\* labels.

## Answering the supervisor's wt% question
Literature keeps GPL wt% at **0.1–1.5 %** (baseline 0.3 %) because graphene is expensive; the group's own
Lord‑Shulman papers use **0.3 %**. The low‑W study (**0.1/0.3/0.5/0.9/1.5 %**) sits exactly in this band.
The earlier **4 %** case is retained only as a **parametric upper limit** to show the saturation / percolation
trend (cf. Huang 2023 sweeping to 5 %), not as a realistic manufacturing value.

*Extraction note: PDFs read via `pdftotext` (Git's poppler) as the Read renderer was unavailable; all numbers
taken from the papers' geometry / material / numerical‑results sections. Paper 12's absolute GPL size is given
only as ratios in its text.*
