---
dir: rtl
lang: fa-IR
---

# بازخورد سوم استاد راهنما — «Prom.3»

*رونویسیِ تایپ‌شده از یک صفحهٔ دست‌نویس (صفحهٔ ۳، اسکن CamScanner از گوگل‌درایو، ۱۴۰۵/۰۵/۰۹).*
*Typed transcription of a one-page handwritten note (page 3). Persian original with English translation under each item.*

---

**۱)** پوشه‌بندی را مرتب‌تر کن. هر کد یا فایلی که یک موضوع دارد، یا نسخه‌های یک عملکرد است، یا فایل‌هایی که یک هدف دارند — با نام‌های مناسب و با دقت پوشه‌بندی شوند. (بعضی از پوشه‌هایی که الان هم داریم مرتب شوند.)
*(1) Tidy up the folder structure. Each code or file that concerns one topic, or is a set of versions of one function, or files sharing one purpose, should be carefully organized into well-named folders. (Also reorganize some of the current folders.)*

**۲)** تمام اثرات تخلخل و پلاکت گرافنی به‌صورت **همزمان** بررسی شوند و مشخص شود هر حالت مربوط به کدام ترکیب است — مثلاً `O-GPL + X-Por` — برای **هر ۲۵ حالت** (۵ الگوی گرافن × ۵ الگوی تخلخل).
*(2) Study the effects of porosity and GPL patterns **simultaneously**, and label which combination each case is — e.g. `O-GPL + X-Por` — for **all 25 cases** (5 GPL patterns × 5 porosity patterns).*

**۳)** در بخش نسبت طول‌به‌عرض و عرض‌به‌ضخامت پلاکت، عدد ۲ حذف شود؛ در **legend** به‌صورت `a/b` و `b/t` نوشته شود (نه `2a/2b` و `2b/t`).
*(3) In the platelet length-to-width and width-to-thickness aspect-ratio section, remove the factor 2; write them in the **legend** as `a/b` and `b/t` (not `2a/2b`, `2b/t`).*
> **تأیید کاربر (۱۴۰۵/۰۵/۰۹):** فقط اصلاح برچسبِ legend است، نه تغییر مدل — تعریف هالپین-تسای (ξ_L=2a/t، ξ_T=2b/t) در کد بدون تغییر می‌ماند و اجرای مجدد لازم ندارد.
> *User confirmed: LEGEND-LABEL fix only, NOT a model change — the Halpin–Tsai ξ definitions stay in the code; no re-run for this.*

**۴)** در فایل `catalog`، بخش‌های مقایسهٔ **روش‌های زمانی** (انتگرال‌گیرها) و **روش‌های مکانی** (گسسته‌سازی مکانی) نیامده است — دقت شود در فرم نهایی نمایش داده شوند.
*(4) In the catalog file, the comparison sections for the **temporal methods** (time integrators) and **spatial methods** (spatial discretization) are missing — make sure they appear in the final form.*

**۵)** بخش «فشار هارمونیک در برابر پله‌ای» حذف شود.
*(5) Delete the "harmonic (sine) vs step pressure" section.*

---

# فهرست اقدامات (تحلیل من) · Action list

| # | خواسته | نوع | اثر بر برنامه |
|---|--------|-----|--------------|
| ۱ | مرتب‌سازی پوشه‌ها | خانه‌داری | بازچینش ساختار پوشه‌ها (طبق قاعدهٔ شمارهٔ نسخه) |
| ۲ | ماتریس کامل ۲۵-حالتهٔ گرافن×تخلخل | **مطالعهٔ جدید** | افزودن ۲۵ اجرا (۵×۵)؛ جایگزین مطالعهٔ فعلیِ ۵-ترکیبی (H) |
| ۳ | حذف عدد ۲ از نسبت‌های ابعادی در legend | **ارائه (نه مدل)** | فقط برچسب → `a/b` و `b/t`؛ بدون اجرای مجدد |
| ۴ | افزودن مقایسهٔ روش‌های زمانی/مکانی به catalog | **افزودن بخش** | بخش‌های ۳-۱۴ و ۳-۱۵ به catalog اضافه شوند |
| ۵ | حذف بخش فشار هارمونیک/پله‌ای | **حذف** | حذف مطالعهٔ `N_sine_pressure` |

*یک صفحه (صفحهٔ ۳)؛ کاربر تأیید کرد تنها همین صفحه است. دنبالهٔ Prom.1 و Prom.2.*
*One page (page 3); user confirmed this is the only page. Follows Prom.1 and Prom.2.*
