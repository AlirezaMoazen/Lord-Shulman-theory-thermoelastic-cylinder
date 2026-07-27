# DECISIONS & ACTIONS NEEDED FROM THE AUTHOR

Things I cannot do myself, or questions whose answers change the work.
Status: OPEN unless marked. Please answer inline or tell me and I'll update.

## A. Actions only you can do
1. **Obtain 3 must-cite papers** via university access (I cannot access paywalls):
   - TWS 2022 spinning FG-GPLRC LS cylinder — DOI 10.1016/j.tws.2022.109367
   - Sherief et al. 2004 exact LS hollow cylinder — DOI 10.1080/01495730490498331
   - Karimi Zeverdejani & Kiani 2022 — DOI 10.1080/17455030.2020.1788746
2. **Citation list fix #71**: the DOI there (10.1016/j.tws.2021.108108) is Hosseini's
   GPL+CNT paper, not the intended Omidi Bidgoli. Tell me the correct entry, or
   confirm you want Hosseini kept (it IS a good cite for the Gaussian-shock study).
3. **Add reference [74] = Tzou 1995** (DPL theory) to the فهرست مقالات — it is used
   in the theory-comparison section but is not yet in your 73-item list. Confirm
   the number or give me its place.
4. **Send more of your own Persian writing** if you want the chapter tuned even
   closer to your voice (optional — current style is learned from پیش نویس R 0.1).

## B. Questions that affect the results chapter
5. **Layers section placement**: the layer-count study (N_L=3/5/9/15) now lives in
   the new CONVERGENCE section (it is a numerical/modeling choice). The review
   outline listed it as parametric study 3-12. Keep it in convergence (my choice),
   or also repeat it as a parametric section? — DEFAULT: convergence only.
6. **Pressure magnitudes**: the sweep 0–100 MPa is linear and shows no گسست
   (the model is linear thermoelastic, so no material rupture is modelled).
   Do you want a note that "گسست" (physical rupture) would require a failure/
   damage model beyond the present linear analysis? — DEFAULT: add that note.
7. **Dictionary source**: you wrote «واژه‌یاب/برساد». Confirm which dictionary
   site you prefer for Persian technical terms so I standardize terminology.
8. **Infinite-length**: I demonstrated it with L = 1, 2, 4 m (mid-span converges
   to the plane-strain limit). Is showing convergence to the asymptote enough,
   or do you also want a true plane-strain (roller-end) reference curve? —
   DEFAULT: convergence-to-asymptote is enough.

## C. Confirmations (proceeding on the default unless you object)
9. Chapter numbered as **Chapter 4** (فصل چهارم: یافته‌های پژوهش). ✅ assumed.
10. γ_N = 0.5 kept (no numerical damping); wave wiggles noted, not filtered. ✅ set.
11. Two Persian docx (B&W + color) + one English docx as the deliverable. ✅ set.

## E. NEW — from supervisor review Prom.2 (2026-07-27)
See full transcription in `claude/REVIEW2_PROM2.docx`. Items needing you:
12. **Porosity patterns (Prom.2 بند ز):** the review says replace the porosity
    patterns with the NEW patterns in the MZ file. I need the exact new formulas
    from `MZ-R 0.docx`. Confirm and I will put them in a new solver revision and
    re-run the porosity cases (§4-6, §4-13). Until then the chapter carries the
    current results with a note. — **BLOCKING for porosity sections.**
13. **Length/thickness notation (Prom.2 بند ح):** the review says length must not
    be shown as L and thickness not as h. What symbols do you want? (e.g. length
    = h, thickness = ℓ, or your preference). I will apply globally.
14. **GPL weight-fraction question (Prom.2 p.2):** the review asks why our GPL %
    is higher than the literature (mostly 0.1–2 %). I added a justification to
    §4-7 (we go to 4 % / 8 % to show the upper reinforcement limit and the
    saturation past the percolation threshold). Confirm this is acceptable.
15. **Color-coded editing (Prom.2 بند الف):** for chapters 1–3 the review wants
    deletions in RED, additions in GREEN, a second version with deletions marked
    not removed. This applies to the OLDER chapters; confirm when you want me to
    start that pass (needs the current chapter-1..3 text).
16. **Code documentation (Prom.2 pages 3–4):** two .doc files requested — a short
    usage manual and a full technical description of the solver. I can draft both
    from the code; confirm priority vs finishing the thesis chapters first.

## D. Session/limit note
- The Claude usage limit was hit on 2026-07-27 (resets 6pm America/New_York).
  Heavy multi-agent work is paused until reset; I continue single-thread work and
  resume the rest automatically (per your autonomous-loop directive).
