# LSTE_package_R1 — بستهٔ مستقل تحلیل ترموالاستیک لُرد–شولمن

حل گذرای کوپل ترموالاستیک استوانهٔ توخالی چندلایهٔ متخلخل با تقویت GPL
(DQM لایه‌ای در فضا، نیومارک در زمان). فقط MATLAB پایه لازم است (بدون toolbox خاص).
همهٔ مسیرها از محل خود فایل‌ها محاسبه می‌شوند؛ پوشه را به هر مسیر یا سیستم دیگری ببرید و اجرا کنید.

## ساختار

```
LSTE_package_R1/
  run_LSTE.m              اجرای کامل: ورودی -> حل -> پس‌پردازش -> ذخیرهٔ نتایج
  input/
    default_input.m       همهٔ داده‌های ورودی (مورد مرجع پایان‌نامه) + اعمال تغییرات
    case_library.m        حالت‌های نام‌دار (reference, fourier, gpl_X_por_V, quick)
  core/
    LSTE_solver_R12.m     حل‌گر (تابع: cfg -> res)
  post/
    postprocess_LSTE.m    نمودار، جدول CSV و خلاصهٔ متنی
  results/<runName>/      خروجی هر اجرا (Results.mat, CSV, PNG/FIG, summary.txt)
  tests/
    selftest_LSTE.m       آزمون نصب (حدود ۱ ثانیه)
    reference_quick.mat   مقادیر مرجع از حل‌گر R11
```

## اجرا

```matlab
cd LSTE_package_R1            % یا addpath('<مسیر پوشه>')
selftest_LSTE                 % (addpath tests) آزمون نصب؛ باید SELFTEST PASSED بدهد
res = run_LSTE();             % مورد مرجع (۳۰۰۰ گام)، خروجی در results/reference/
res = run_LSTE('fourier');    % نظریهٔ فوریه
res = run_LSTE('quick');      % ریز و کوتاه
```

تغییر داده‌ها (بدون دست‌زدن به حل‌گر):

```matlab
cfg = default_input(struct('GPL_pattern','X', 'porosity_pattern','V', ...
                           'NL',5, 'P_i',30e6, 'total_time',1500));
res = run_LSTE(cfg, 'my_run');
```

نام فیلدهای معتبر و واحدها در `input/default_input.m` آمده‌اند؛ نام نادرست خطا می‌دهد.
حالت جدید را می‌توان در `input/case_library.m` اضافه کرد.

گزینه‌های پس‌پردازش: `run_LSTE(input, runName, struct('figures',true,'show',false))`.

## خروجی‌ها (`results/<runName>/`)

| فایل | محتوا |
|---|---|
| `Results.mat` | ساختار `res`: تاریخچه‌ها، پروفیل شعاعی و تنش‌ها، `x_final`، `x_inf` (حد استاتیکی)، نقشهٔ درجات آزادی، ورودی استفاده‌شده (`res.cfg`) |
| `time_history.csv` | t، دمای نقطهٔ میانی، u، w، دمای سطح داخلی |
| `radial_profile.csv` | r، T، u، σrr، σθθ، σzz در z = L/2 و زمان پایانی |
| `time_histories.png/.fig` | شش نمودار خلاصه |
| `summary.txt` | مقادیر نهایی و بررسی شرایط مرزی (σrr داخلی = −P، σrr خارجی = 0) |
| `DOFmap.csv` | شمارهٔ درجات آزادی ↔ (لایه، ir، iz، r، z) |

برای داده‌های زمانی کامل `store_full_history = true` بگذارید (`res.X_hist`).

## صحت‌سنجی

`LSTE_solver_R12` فقط نسخهٔ تمیز و تابعی `code/solver/LSTE_solver_R11.m` است (همان محاسبه، بدون توضیحات نسخه‌ها و
کدهای قدیمی). در ۱۲ حالت مختلف (نظریه‌های FOURIER/LS/DPL/GN3، همهٔ تکیه‌گاه‌ها، الگوهای GPL/تخلخل،
شار ورودی، پالس گاوسی، فشار سینوسی، حالت FG، گامای نیومارک، تاریخچهٔ کامل) خروجی R12 با R11 **رقم‌به‌رقم برابر** بود
(حداکثر تفاوت مطلق = 0).

## نکته‌ها

- فقط اعداد ورودی و فیزیک مسئله در `input/` تغییر می‌کنند؛ حل‌گر هیچ‌وقت ویرایش نمی‌شود.
- ذخیرهٔ نمودار (PNG/FIG) به محیط گرافیکی MATLAB نیاز دارد. روی سرور بدون نمایشگر از `struct('figures',false)` استفاده کنید؛ جدول‌ها و `Results.mat` بدون آن هم تولید می‌شوند.
- اگر `em3` طوری باشد که `fzero` برای ضرایب گزارشی e1/e2 جواب نیابد (مثلاً em3 = 0.7)، خطا می‌دهد؛ این رفتار از R11 به ارث رسیده است (em3 مرجع = 0.898).
- طبق قاعدهٔ پروژه، تغییر در بسته = پوشهٔ جدید (`LSTE_package_R2`).
