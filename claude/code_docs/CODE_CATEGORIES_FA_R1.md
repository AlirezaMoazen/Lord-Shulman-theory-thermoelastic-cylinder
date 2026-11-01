---
title: "دسته‌بندی کدهای پروژه"
lang: fa
dir: rtl
---

# دسته‌بندی کدهای پروژه (R1 — ۱۴۰۵/۰۸/۱۰ برابر ۲۰۲۶-۱۱-۰۱)

همهٔ کدها در پوشهٔ `claude/code/` هستند. ستون «نسخهٔ فعلی» بالاترین شمارهٔ `_R<n>` موجود در پوشه است؛
نسخه‌های قدیمی‌تر طبق قاعدهٔ پروژه منجمد (frozen) هستند و حذف نشده‌اند. جزئیات هر نسخه در `REVISIONS.md` آمده است.

## ۱. حل‌گر (Solver) — هستهٔ محاسبات
پوشه: `code/solver/`

| فایل | وظیفه | نسخهٔ فعلی |
|---|---|---|
| `LSTE_solver_R<n>.m` | حل‌گر کوپل ترموالاستیک لُرد–شولمن: DQM لایه‌ای در فضا + نیومارک در زمان. با ساختار `cfg` تنظیم می‌شود (هیچ‌وقت خود حل‌گر ویرایش نمی‌شود) | **R11** |
| `Static_Baseline_R<n>.m` | حل‌گر مستقل استاتیکی ترموالاستیک (DQM لایه‌ای) به‌عنوان مبنای صحت‌سنجی | R3 |
| `Compare_R<n>.m` | اعتبارسنجی متقابل: حد استاتیکی حل‌گر دینامیک در برابر `Static_Baseline` | R2 |
| `LSTE_solver_R9_check_benchmark1*.m`، `LSTE_solver_R9_compare*.m` | بررسی هم‌ارزی R9 با R8 (رقم‌به‌رقم) | — |

## ۲. صحت‌سنجی (Validation)
پوشه: `code/validation/`

| فایل | وظیفه |
|---|---|
| `LSTE_solver_R2_run_benchmark1/2*.m`، `LSTE_solver_R3_run_benchmark3*.m`، `LSTE_solver_R2_run_LSdemo*.m` | اجرای مسائل مرجع (بنچمارک ۱ تا ۳ و نمونهٔ LS) |
| `ls_wave_exact_R<n>.m`، `ls_wave_benchmark_R1.m` | جواب دقیق موج حرارتی لُرد–شولمن (بدون کوپلینگ) در استوانهٔ توخالی، بسط فوریه–بسل |
| `validation_figs_R<n>.m`، `validation_fig_bench2_R<n>.m` | رسم نمودارهای صحت‌سنجی (پیوست ب) |
| `run_solver_case.m` | اجرای `LSTE_solver_R11` با یک `cfg` بدون پاک‌شدن workspace فراخواننده |

## ۳. تولید نمودارهای فصل ۴ (کاتالوگ)
پوشه: `code/catalog/` — هر اسکریپت داده را از `param_studies_ch4/` می‌خواند و در `figures_ch4_master/` می‌نویسد.

| گروه | فایل‌ها | نسخهٔ فعلی |
|---|---|---|
| مطالعات پارامتری اصلی (۱۶–۱۸ مطالعه؛ سیاه‌وسفید + رنگی) | `catalog_R<n>.m` و `catalog_R<n>_color.m` | **R18** |
| ماتریس ۲۵تایی (۵ الگوی GPL × ۵ الگوی تخلخل) | `catalog_R18/19/20_matrix25.m`، `catalog_matrix25_4panel*.m`، `catalog_matrix25_4figs*.m` | R20 / R3 / R2 |
| نمودارهای به‌ازای هر الگوی تخلخل | `catalog_gplpor*.m` | R4 |
| بهترین/بدترین حالت | `catalog_bestworst*.m` | R4 |
| همگرایی | `catalog_conv*.m`، `catalog_conv2*.m`، `catalog_conv_explore*.m` | conv2 R5.1 |
| نمودارهای تکمیلی | `catalog_R12_extras*.m`، `catalog_ch4_variants*.m`، `run_smooth_T3.m` | R2 |
| نسخه‌های مخصوص MATLAB 2016b | `*_2016b.m` | — |

## ۴. نمودارها و شماتیک‌های فصل‌های ۱ تا ۳
پوشه: `code/catalog/` — خروجی در `figures_ch123/`

| فایل | وظیفه | نسخهٔ فعلی |
|---|---|---|
| `ch123_figs_R<n>.m` | نمودارهای فصل‌های ۱–۳ (فلوچارت، دسته‌بندی، الگوها) | R10 |
| `geometry_schematic_R<n>.m` | شماتیک هندسهٔ استوانه + مختصات | R3 |
| `pattern_gradient_schematics_R<n>.m` | شماتیک الگوهای GPL | R5 |
| `porosity_schematic_newVA_R1.m`، `porosity_schematic_R5_zeta_R1.m`، `porosity_level_comparison_R1.m` | شماتیک الگوهای تخلخل (از جمله V/A جدید) | R1 |
| `ch3_gpl_porosity_stacked_R<n>.m` | شکل ترکیبی GPL + تخلخل | R2 |
| `AUTHOR_Pm_*_VA_R1.m` | بررسی بریدگی (clipping) تابع P_m برای الگوی V/A | R1 |

## ۵. مقایسهٔ روش‌ها (توسعه‌ها)
پوشه: `code/extensions/` — خروجی در `results_extensions/`

| فایل | وظیفه |
|---|---|
| `T1_*_time_integrators.m` | مقایسهٔ ۶ روش انتگرال‌گیری زمانی |
| `T2_*_spatial_methods.m` | مقایسهٔ روش‌های گسسته‌سازی فضایی (شعاعی) |
| `T4_*_axial_methods.m` | مقایسهٔ روش‌های گسسته‌سازی محوری |
| `catalog_relax_finer_N35*.m` | بررسی شبکهٔ ریزتر برای فرورفتگی منفی T* (اکتشافی، رسمی نیست) |

## ۶. انیمیشن
پوشه: `code/anim/` — `anim_preview_R2.m`، `anim_ring_R2.m` (انیمیشن نهایی هنوز در انتظار تصمیم نویسنده است).

## ۷. آمار، تخلخل و ابزارهای کمکی
پوشه: `code/misc/`

| فایل | وظیفه |
|---|---|
| `chapter_stats_ch4_R2.m` | استخراج اعداد فصل ۴ از نتایج ذخیره‌شده |
| `porosity_check_*`، `porosity_variant_test*`، `porosity_tables_newVA_R1.m/.csv` | بررسی و جدول‌های ضرایب تخلخل |
| `test_LSTE_solver_R7_regression*.m` | آزمون رگرسیون حل‌گر |
| `strip_image_alttext_R1.ps1` | حذف متن جایگزین تصاویر در md |

## ۸. اجرای انبوه (کمپین)
پوشه: `campaign/` (خارج از `code/`) — اسکریپت‌های PowerShell که حل‌گر را برای همهٔ حالت‌ها اجرا می‌کنند:
`run_ch4_campaign.ps1` (کمپین اصلی)، `run_nz_sweep.ps1`، `run_aspect_sweep_R*.ps1`، `run_thickness_sweep_R1.ps1`،
`run_conv_explore.ps1`. حداکثر ۳ کار `-batch` همزمان.

## ۹. بایگانی
پوشه: `code/_archive/` — کدهای قدیمی با هندسهٔ قدیم (`claude_catalog_R1–R5`، `claude_param_figures*`)؛ فقط برای مرجع، اجرا نمی‌شوند.

## جریان کار
`campaign/*.ps1` ← حل‌گر `LSTE_solver_R11` ← `param_studies_ch4/` (داده‌های خام، خارج از git)
← `code/catalog/catalog_R18*.m` ← `figures_ch4_master/` ← فصل ۴.
