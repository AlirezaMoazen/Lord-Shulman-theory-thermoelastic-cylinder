---
dir: rtl
lang: fa-IR
---

# دستورالعمل کاربری بستهٔ LSTE_package_R1 (راهنمای اجرا)

این سند راهنمای کوتاه و کاربردی اجرای **بستهٔ مستقل** `LSTE_package_R1` است: حل گذرای ترموالاستیک
لرد–شولمن استوانهٔ توخالیِ چندلایهٔ متخلخلِ تقویت‌شده با گرافن (DQM لایه‌ای + نیومارک). برای شرح کامل ساختار
درونی و مراحل کار کد به سند «شرح فنی و مراحل کار بستهٔ LSTE_package_R1» مراجعه شود. سند مشابه برای حل‌گر
قدیمی در `CODE_DOC_usage_FA.md` است و این بسته جایگزین آن نمی‌شود (R11 و پوشهٔ `code/solver/` دست‌نخورده‌اند).

## ۱. پیش‌نیازها

- **MATLAB** (آزمون‌شده با R2026a). هیچ جعبه‌ابزار خاصی لازم نیست؛ فقط توابع پایه (`sparse`، `lu`، `condest`،
  `fzero`، `integral`، `writetable`).
- هیچ مسیر مطلقی در کد نیست. پوشهٔ `LSTE_package_R1` را به هر جا یا هر سیستمی (حتی با فاصله در نام مسیر) کپی کنید.
- پس از کپی روی سیستم جدید، یک‌بار آزمون نصب را اجرا کنید (بخش ۲).

## ۲. آزمون نصب

```matlab
cd LSTE_package_R1
addpath('tests');
selftest_LSTE
```

خروجی درست:

```
max |new - reference| = 0.000e+00  -> PASS
SELFTEST PASSED
```

این آزمون حالت کوچک `quick` را حل و با مقادیر مرجعِ حل‌گر R11 (`tests/reference_quick.mat`) مقایسه می‌کند و
وجود جدول‌های خروجی را بررسی می‌کند. ذخیرهٔ شکل در آن آزمون نمی‌شود (به نمایشگر گرافیکی نیاز دارد).

## ۳. اجرای سریع

```matlab
cd LSTE_package_R1            % یا addpath('<مسیر پوشه>')
res = run_LSTE();             % مورد مرجع رساله، ۳۰۰۰ گام  -> results/reference/
res = run_LSTE('fourier');    % نظریهٔ فوریه با همان داده‌ها
res = run_LSTE('quick');      % شبکهٔ ریز و ۶۰ ثانیه، برای آزمون سریع
```

`run_LSTE` چهار کار را پشت‌سرهم انجام می‌دهد: ساختن ورودی ← حل ← پس‌پردازش ← ذخیرهٔ نتایج در
`results/<نام اجرا>/`.

## ۴. تغییر داده‌های ورودی

حل‌گر هیچ‌وقت ویرایش نمی‌شود؛ فقط ورودی تغییر می‌کند. دو راه:

**الف) تغییر مستقیم با `default_input`**

```matlab
cfg = default_input(struct( ...
        'GPL_pattern','X', 'porosity_pattern','V', ...   % الگوها: UD | O | X | V | A
        'NL',5, 'P_i',30e6, 'total_time',1500));
res = run_LSTE(cfg, 'X_V_30MPa');
```

**ب) افزودن یک حالت نام‌دار** در `input/case_library.m` (یک شاخهٔ `case` جدید) و سپس `run_LSTE('نام_حالت')`.

نام فیلد نادرست خطا می‌دهد (محافظت در برابر غلط املایی). اگر فقط `gam` تغییر کند، `bet=(gam+0.5)^2/4` خودکار
تنظیم می‌شود.

### فهرست مهم‌ترین ورودی‌ها (همه در `input/default_input.m` با واحد)

| گروه | فیلدها | مقدار مرجع |
|---|---|---|
| نظریه | `theory` = `'FOURIER'`/`'LS'`/`'DPL'`/`'GN3'`، `tau0`، `tau_T`، `k_star`، `coupling_on` | LS، 418 s |
| هندسه و شبکه | `NL`، `R_i`، `R_o`، `L`، `N_r`، `N_z` | 7، 1، 1.5 m، 2.1 m، 15، 11 |
| گرافن/تخلخل | `GPL_pattern`، `porosity_pattern`، `W_GPL_total`، `em3`، `porosity_on`، `a_GPL`، `b_GPL`، `t_GPL` | UD، UD، 0.003، 0.898 |
| حالت ماده | `material_mode` = `'GPL'` یا `'FG_powerlaw'` (+ `FG_*`) | GPL |
| تکیه‌گاه انتهایی | `BC_z` = `'S'`/`'F'`/`'C'`/`'R'`، و برای هر انتها `BC_z0`، `BC_zL` | S |
| شرط حرارتی داخلی | `T_BC_in` = `'dirichlet'`/`'flux'`، `T_in_mode` = `'ramp'`/`'gauss'`، `q_in_fun`، `t_g0`، `sig_g` | dirichlet، ramp |
| شرط حرارتی خارجی | `T_BC_out` = `'convection'`/`'dirichlet0'`، `h_c`، `T_inf` | convection، 10 |
| شرط مکانیکی داخلی | `Mech_BC_in` = `'pressure'`/`'fixed'`، `P_i`، `P_time_mode` = `'step'`/`'sine'`، `t0_P` | pressure، 50 MPa، step |
| بار حرارتی | `T_ref`، `T_in_val`، `t0_ramp` | 300 K، 600 K، 2 s |
| زمان | `total_time`، `dt`، `gam`، `bet` | 3000 s، 1 s، 0.5، 0.25 |
| کنترل اجرا | `store_full_history`، `verbose` | false، true |

یکاها SI هستند (m، s، K، Pa، W).

## ۵. گزینه‌های اجرا و پس‌پردازش

```matlab
opts = struct('figures', true, 'show', false);
res  = run_LSTE(cfg, 'my_run', opts);
```

- `figures=false`: فقط جدول‌ها و `Results.mat` تولید می‌شود (برای سرور بدون نمایشگر).
- `show=true`: شکل روی صفحه هم نمایش داده می‌شود.
- پس‌پردازش جداگانه روی نتیجهٔ ذخیره‌شده:

```matlab
S = load('results/my_run/Results.mat');          % S.res
postprocess_LSTE(S.res, 'results/my_run_v2');    % بدون حل دوباره
```

## ۶. اجرا از خط فرمان (بدون رابط MATLAB)

از پوشهٔ بالاتر از بسته (PowerShell):

```powershell
& "C:\Program Files\MATLAB\R2026a\bin\matlab.exe" -batch "addpath('LSTE_package_R1'); run_LSTE('reference','ref',struct('figures',false)); exit(0)"
```

در لینوکس/مک: `matlab -batch "addpath('LSTE_package_R1'); run_LSTE('quick'); exit(0)"`.
حداکثر ۳ کار `-batch` همزمان (محدودیت مجوز در این پروژه).

حلقهٔ مطالعهٔ پارامتری (بدون ویرایش حل‌گر):

```matlab
for P = [0 25e6 50e6 75e6 100e6]
    cfg = default_input(struct('P_i',P,'verbose',false));
    run_LSTE(cfg, sprintf('P_%dMPa', P/1e6), struct('figures',false));
end
```

## ۷. خروجی‌ها (`results/<نام اجرا>/`)

| فایل | محتوا |
|---|---|
| `Results.mat` | ساختار `res` (جدول بخش ۸ سند فنی): تاریخچه‌ها، پروفیل شعاعی، تنش‌ها، `x_final`، `x_inf`، نگاشت درجات آزادی، `res.cfg` |
| `time_history.csv` | `t_s, T_mid_K, u_mid_m, w_mid_m, T_inner_K` |
| `radial_profile.csv` | `r_m, T_K, u_m, sigma_rr_Pa, sigma_tt_Pa, sigma_zz_Pa` در z = L/2 و زمان پایانی |
| `time_histories.png/.fig` | شش نمودار خلاصه (T، u، w بر حسب t؛ T، u، تنش‌ها بر حسب r) |
| `summary.txt` | مقادیر نهایی و بررسی شرط مرزی (σrr داخلی = −P، σrr خارجی = 0) |
| `DOFmap.csv` | شمارهٔ درجات آزادی ↔ (لایه، ir، iz، r، z) |

پوشهٔ `results/` در git نادیده گرفته می‌شود (به‌جز `.gitkeep`).

## ۸. خواندن نتایج در MATLAB

```matlab
S = load('results/reference/Results.mat');  res = S.res;
plot(res.tv, res.hist_T);                   % دمای نقطهٔ میانی
plot(res.r_all, res.S_tt/1e6);              % تنش محیطی (MPa) در z=L/2
res.cfg.theory                              % ورودی استفاده‌شده برای این اجرا
```

برای میدان کامل در هر گام `store_full_history=true` بگذارید و از `res.X_hist` (ابعاد `Ndof × (Nt+1)`) با
`res.GridDOF`/`res.DOFmap` برای یافتن درجهٔ آزادیِ هر نقطه استفاده کنید.

## ۹. عیب‌یابی

| پیام / رفتار | علت و راه‌حل |
|---|---|
| `Unknown input field "..."` | غلط املایی در نام فیلد؛ نام را از `default_input.m` بردارید |
| `Undefined function 'run_LSTE'` | پوشهٔ بسته روی مسیر MATLAB نیست: `addpath('<مسیر بسته>')` |
| خطا در `fzero` (خط ضرایب e1/e2) | `em3` در بازهٔ مجاز نیست (مثلاً 0.7)؛ مقدارهای آزموده‌شده: 0.85 و 0.898. رفتار موروثی از R11؛ مقدار مرجع 0.898 |
| `K_eff has empty rows` | خطای حسابداری شرایط مرزی (ترکیب ناسازگار گزینه‌ها) |
| `Solution diverged at step ...` | واگرایی؛ `dt` را کوچک کنید یا `gam>0.5` بگذارید |
| اجرای بدون نمایشگر روی ذخیرهٔ شکل متوقف می‌شود | `struct('figures',false)` بدهید |
| `bet` با `gam` ناسازگار | فقط `gam` را بدهید تا `bet` خودکار شود |

## ۱۰. محدودیت‌ها

- ذخیرهٔ PNG/FIG در این بسته روی ماشین توسعه آزموده نشد (در `-batch` گرافیک متوقف می‌شد)؛ جدول‌ها و
  `Results.mat` آزموده شده‌اند. روی MATLAB دسکتاپ معمولاً مشکلی نیست؛ در غیر این صورت `figures=false`.
- بی‌بعدسازیِ فصل ۴ (Fo، T\*، …) در این بسته انجام نمی‌شود؛ خروجی ابعادی SI است. شکل‌های رساله با
  اسکریپت‌های `code/catalog/` از داده‌های کارزار ساخته می‌شوند.
- حل‌گر R12 هم‌ارزِ رقم‌به‌رقمِ R11 است (۱۳ حالت، ازجمله مورد مرجع ۳۰۰۰ گامی)؛ کارزار فصل ۴ همچنان R11 را
  فرا می‌خواند.

## ۱۱. نقشهٔ فایل‌ها

```
LSTE_package_R1/
  run_LSTE.m                  درگاه اجرا
  input/default_input.m       همهٔ ورودی‌ها
  input/case_library.m        حالت‌های نام‌دار
  core/LSTE_solver_R12.m      حل‌گر
  post/postprocess_LSTE.m     نمودار + CSV + خلاصه
  results/                    خروجی‌ها
  tests/selftest_LSTE.m       آزمون نصب
  tests/reference_quick.mat   مقادیر مرجع R11
  README.md  .gitignore
```

قاعدهٔ پروژه: هر تغییر در بسته = پوشهٔ جدید `LSTE_package_R2` (کد تأییدشده درجا ویرایش نمی‌شود).
