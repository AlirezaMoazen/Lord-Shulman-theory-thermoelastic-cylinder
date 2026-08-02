# بازخورد چهارم استاد راهنما — «Prom.4»

*رونویسیِ یادداشت دست‌نویس (۱ صفحه، اسکن) + توضیحاتِ مؤلف (۱۴۰۵/۰۵/۱۱). دربارهٔ قالب شکل‌های فصل ۴.*
*Transcription of the handwritten note (1 page) + author's clarifications (2026-08-02). About Chapter-4 figure formatting.*

| # | خواسته (FA) | Item (EN) | وضعیت / اقدام |
|---|---|---|---|
| ۱ | در نمودارهای رنگی از خط‌چین استفاده نکن | In colour plots use **solid lines only** (no dashes) | color 4-panel `STY.ls` → all `-` |
| ۲ | بالای هر شکل فقط عدد بنویس | Above each figure write **only the number** | figure label = number; caption below |
| ۳ | بالای شکلِ ۴نموداری یک توضیح هست، حذفش کن | **Remove the `sgtitle`** on top of the 4-panel figures | drop `sgtitle` from R6 + R6_color |
| ۴ | اطلاعات و شمارهٔ فصل-شکل مثل مقالات/پایان‌نامه‌ها | **Figure numbering + caption info like published papers/theses** (Fig 4-N: …) | number all figs Fig 4-N; captions academic |
| ۵ | **مهم: در کل متن `l` را با `L` جایگزین کن** | **IMPORTANT: replace length symbol `l` → `L` throughout** | global change EN+FA+captions; update notation memory |
| ۶ | در نمودارهای ۲۵تایی، مؤلفه‌های سطر(عمودی) و ستون(افقی) برای همهٔ زیرشکل‌ها نوشته شود | 25-matrix: **row & column axis labels on EVERY subplot** | edit matrix25 render |
| ۷ | نمودارها را به‌دقت بررسی کن؛ جهش‌ها و تغییرات شدید/غیرعادی را بیاب و توضیح بده (با پارامترها) | Find **jumps / severe / abnormal changes** and explain them | add interpretations to chapter text |
| ۸ | همان **نوع شکل ۴پنلی** را به‌کار ببر | Use the **4-panel figure type** consistently | study sections already 4-panel; verify |
| ۹ | بخش همگرایی = **سه زیربخش (N_r, N_z, N_L)**؛ در هرکدام پنل‌های (c) و (d) را با **جدول** جایگزین کن | Convergence = **3 subparts**; replace panels (c)+(d) with a **table** (keep profiles a,b) | restructure §4-3: 2-panel fig + table per direction |
| ۱۰ | (Prom.1 گفته بودم، هنوز نشده) برای بخش صحت‌سنجی **نمودار رسم شود** | Verification section: **diagrams SHOULD be drawn** | **already done in #3 — keep** ✅ |

Follows [[supervisor-ch4-review]] (Prom.1), [[supervisor-prom2-review]] (Prom.2), [[supervisor-prom3-review]] (Prom.3). All items are Chapter-4 figure/formatting + one analysis task (#7).
