# بازخورد دوم استاد راهنما — «Prom.2»

*رونویسیِ تایپ‌شده از یادداشت دست‌نویس (۴ صفحه، اسکن CamScanner). متن فارسی اصل، ترجمهٔ انگلیسی زیر هر بند.*
*Typed transcription of the handwritten note (4 scanned pages). Persian original with English translation under each item.*

---

## صفحهٔ ۱ — بخش‌های ابتدایی پایان‌نامه  ·  Page 1 — Opening sections of the thesis

**فصل اول تا سوم مرور شود.**
*Chapters 1 to 3 must be reviewed/revised.*

**الف)** مشکلات نگارشی، دستوری یا تایپی برطرف شود.
*(a) Fix writing, grammar and typing problems.*
> هر جا را می‌خواهم حذف کنی، به **رنگ قرمز** در بیاور؛ و هر جا **اضافه** کردی با **رنگ سبز** نمایش بده. رنگ پیش‌فرض مشکی است. یک نسخهٔ دیگر هم بساز که در آن حذفیات حذف نشده باشند (فقط علامت‌گذاری شده باشند).
> *Wherever I want you to delete, mark it in **red**; wherever you **add** text, show it in **green**; default text stays black. Also produce a second version in which the deletions are not actually removed (only marked).*

**ب)** بخش‌هایی که به **رنگ آبی** هستند نیازمند تحلیل‌اند. فصل‌ها/بخش‌های تحلیل‌نشده را کامل کن (روش رنگی سبز/قرمز را رعایت کن).
*(b) The parts shown in **blue** need analysis; complete the un-analyzed chapters/sections (follow the green/red colour convention).*

**ج)** هر جا به شکل (نمودار) نیاز است، آن را رسم کن و متن تحلیلی اضافه کن.
*(c) Wherever a figure/plot is needed, draw it and add explanatory text.*

**د)** عناوین فهرست را به هر بخش متصل کن (inner link / لینک داخلی).
*(d) Hyperlink the table-of-contents entries to their sections (inner links).*

**ه)** بخش انتهایی پایان‌نامه که به انگلیسی است (چکیدهٔ انگلیسی) را کامل کن (روش رنگی سبز/قرمز).
*(e) Complete the English section at the end of the thesis (English abstract), using the green/red convention.*

**و)** یک **پیوست** بساز و روش نیومارک را در آن توضیح بده. مناسب است روش‌های دیگری هم که برای بخش مقایسه استفاده کردیم به‌اختصار در پیوست بیاوریم.
*(f) Create an **appendix** explaining the Newmark method; it is appropriate to also briefly describe the other methods used in the comparison section there.*

**ز)** الگوهای تخلخل را با **الگوهای جدیدِ موجود در فایل MZ** جایگزین کن.
*(g) Replace the porosity patterns with the **new patterns given in the MZ file**.*

**ح)** نمادگذاری طول/ضخامت اصلاح شود: طول با L و ضخامت با h نمایش داده نشود.
*(h) Fix the length/thickness notation: length should not be denoted by L and thickness by h.*

---

## صفحهٔ ۲  ·  Page 2

**برای هر فصل از چند «agent» استفاده کن:** چند تا از آن‌ها کارهای لازم را انجام دهند و یکی از آن‌ها مانند یک استاد/داور خروجیِ بقیه را بررسی کند تا نتیجه دقیق و سنجیده باشد.
*Use several "agents" per chapter: some do the work, and one — acting like a professor/referee — reviews the others' output so the result is precise and well-judged.*

**برای قسمت انگلیسی و بخش‌های ابتدایی پایان‌نامه هم همین روش انجام شود.**
*Apply the same method to the English part and to the opening sections of the thesis.*

**نکتهٔ غیرمرتبط:** چرا در کارِ ما مقدار گرافن بیشتر از مقالات است؟ چون آن‌ها عمدتاً بین **۰٫۱ تا ۲ درصد** بررسی کرده‌اند. آیا این اطلاع درست است؟ اگر بله، چرا در کار ما بیشتر است؟
*Side note: Why is the graphene content in our work higher than in the literature? They mostly studied between **0.1 % and 2 %**. Is that information correct? If so, why is ours higher?*

---

## صفحهٔ ۳ — مستندسازی کد (code / doc)  ·  Page 3 — Code documentation

**نوشتن یک دستورالعمل کاربردی، کوتاه و جامع برای کار کردن با کد، به‌صورت فایل doc.**
*Write a practical, short, comprehensive user-guide for running the code, as a .doc file.*

**نوشتن یک شرح کامل پیرامون بخش‌ها، نحوهٔ کار و عملکرد، و توضیح جامع و کامل دربارهٔ هر آنچه در کد هست؛** طوری که این فایل برای استفاده‌ها و تغییرات آینده به‌کار آید و کسی بدون پیش‌زمینه هم بتواند از آن استفاده کند — به‌صورت فایل doc.
*Write a complete description of the code's parts, how each works and what it does, so this document serves future use and modification and is usable by someone with no prior background — as a .doc file.*

---

## صفحهٔ ۴ — یادداشت کد (code 1)  ·  Page 4 — Code note

**ایجاد ماتریس سختی/جرم به‌صورت مستطیلی:** یک آرایهٔ ساده با ابعاد (N_r × N_z) ستون × (N_r × N_z) سطر، به‌همراه ماتریس نگاشت. ماتریس مستطیلیِ اولیه ساخته نشود؛ بلکه این کار برای تمام درجات آزادی انجام شود، یعنی هر درایه نمایندهٔ یک مؤلفه در همان نقطه در کل گام زمانی باشد.
*Assemble the stiffness/mass matrix in a rectangular form: a plain array of size (N_r × N_z) columns × (N_r × N_z) rows, together with a mapping matrix. Do not build an initial rectangular matrix; instead do it for all degrees of freedom, so each entry represents one component at the same point over the whole time step.*

**ایجاد ماتریس شماره‌دهی (نگاشت درجات آزادی):** دقیقاً با همان ترتیبِ قرارگیری در دستگاه معادلات.
*Create a numbering/mapping matrix (DOF numbering) with exactly the same ordering as in the system of equations.*

---

# جمع‌بندی و فهرست اقدامات (تحلیل من)  ·  Action list (my analysis)

## ۱) اقدامات مربوط به متنِ پایان‌نامه  ·  Thesis-text actions
| # | خواسته | ارتباط با کار فعلی |
|---|--------|---------------------|
| الف | ویرایش با کدرنگ: حذف=قرمز، افزوده=سبز، پیش‌فرض=مشکی؛ + یک نسخه با حذفیاتِ علامت‌خورده (نه پاک‌شده) | **روی خروجی‌های docx فصل ۴ اعمال می‌شود** — دو نسخهٔ ردگیری‌تغییرات می‌سازم |
| ب | کامل‌کردن بخش‌های آبی (تحلیل‌نشده) | بخش‌های تازه‌ی فصل ۴ همین الان تحلیل دارند؛ فصل‌های ۱–۳ باید بازبینی شوند |
| ج | افزودن نمودار + متن تحلیلی هرجا لازم است | ۴۴ شکل آماده است؛ جاهای خالی را پر می‌کنم |
| د | لینک داخلی فهرست به بخش‌ها | در مرحلهٔ مونتاژ نهاییِ کل پایان‌نامه انجام می‌شود |
| ه | کامل‌کردن چکیدهٔ انگلیسی | با نسخهٔ EN هماهنگ می‌شود |
| و | پیوست: توضیح روش نیومارک + روش‌های مقایسه (DQM/FDM/FEM/انتگرال‌گیرها) | داده‌ها و متن T1/T2/T3 موجود است → پیوست می‌نویسم |
| ح | اصلاح نماد طول/ضخامت (L و h نباشد) | **نیاز به تأیید شما** (پایین) |

## ۲) اقدام مربوط به داده/حل‌گر  ·  Solver/data action
| ز | جایگزینی الگوهای تخلخل با الگوهای جدیدِ فایل MZ | **مهم:** این همان تصمیم بازِ V/A است. الگوهای جدید را از `MZ-R 0.docx` استخراج و در حل‌گر (revision تازه) می‌گذارم و کیس‌های تخلخل را دوباره اجرا می‌کنم. **نیاز به تأیید فرمول‌ها** |

## ۳) روشِ کار (workflow)  ·  Working method
- استفاده از چند agent (چند نویسنده + یک داور) برای هر فصل — دقیقاً همان الگوی «چند عاملی + راستی‌آزماییِ خصمانه» که هم‌اکنون با ابزار Workflow استفاده می‌کنم. ✅ مطابقت دارد.

## ۴) مستندسازی کد  ·  Code documentation (pages 3–4)
- (۱) راهنمای کاربریِ کوتاه برای اجرای کد → فایل doc.
- (۲) شرح فنیِ کامل همهٔ بخش‌های کد برای نگه‌داری/توسعهٔ آینده → فایل doc.
- (۳) یادداشت پیاده‌سازی: مونتاژ ماتریس سختی/جرم مستطیلی + ماتریس شماره‌دهی درجات آزادی (پیشنهاد استاد برای ساختار داده).

## ⚠️ مواردی که پاسخ شما را می‌خواهد  ·  Needs your answer
1. **بند ز (الگوهای تخلخل):** فرمول‌های جدید تخلخل در `MZ-R 0.docx` کدام‌اند؟ آیا اجرای دوبارهٔ کیس‌های تخلخل با الگوهای جدید را تأیید می‌کنید؟
   *Which new porosity formulas in MZ-R 0.docx? Confirm re-running the porosity cases with them.*
2. **بند ح (نماد طول/ضخامت):** نماد جدید طول و ضخامت چه باشد؟ (مثلاً طول = h و ضخامت = ℓ، یا برعکس؟) لطفاً نماد دقیق را بگویید.
   *What symbols should length and thickness use instead of L / h?*
3. **پرسش گرافن (۰٫۱–۲٪):** پاسخِ پیشنهادی من: بله، در ادبیات معمولاً ۰٫۱–۲٪ است؛ ما تا ۴٪ رفتیم تا **حدِ بالای تقویت** و اثر اشباع/آستانهٔ نفوذ (percolation) را نشان دهیم و مطالعهٔ پارامتری کامل باشد. آیا این توجیه را در متن بیاورم؟
   *My proposed answer: yes, literature is 0.1–2 %; we go to 4 % to show the upper reinforcement limit and the percolation/saturation behaviour. Add this justification to the text?*
