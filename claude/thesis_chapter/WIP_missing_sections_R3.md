# WIP — the 4 chapter-4 sections the workflow could not finish (session limit)
<!-- Written by the main loop from chapter_stats.csv data, same style as the
     6 workflow-drafted sections. To be merged into FA_R3 + EN_R3 during
     assembly. Each section: body_fa then body_en. -->

## pressure — اثر فشار داخلی / Effect of the internal pressure

**FA.**
اثر فشار داخلی با یک جاروب کامل از فشار برای شش مقدار صفر، ۱۰، ۳۰، ۵۰، ۷۰ و
۱۰۰ مگاپاسکال بررسی شده است تا رفتار سازه از فشارهای کم تا فشارهای بسیار زیاد
پوشش داده شود. مطابق شکل 4-N، میدان دما عملاً مستقل از فشار داخلی باقی می‌ماند،
زیرا بارگذاری حرارتی و مکانیکی در معادلهٔ انرژی تنها از طریق جملهٔ ممزوج ضعیف
به هم مرتبط‌اند و فشار، محرک مستقیم دما نیست. در مقابل، پاسخ مکانیکی به‌صورت
خطی با فشار رشد می‌کند: بیشینهٔ جابجایی شعاعی بی‌بعد از مقدار ۱٫۰۷۳ در نبود
فشار به ترتیب به ۱٫۰۸۶، ۱٫۱۱۵، ۱٫۱۴۳، ۱٫۱۷۱ و ۱٫۲۱۴ می‌رسد و افزایش آن به
ازای هر ۲۰ مگاپاسکال دقیقاً برابر ۰٫۰۲۸۳ است؛ این خطی بودن کامل، بازتاب ماهیت
خطی مدل ترموالاستیک به‌کاررفته است.

نکتهٔ مهم آن است که حتی در فشار ۱۰۰ مگاپاسکال نیز هیچ گسستی در پاسخ عددی رخ
نمی‌دهد و حل، هموار و همگرا باقی می‌ماند؛ چرا که مدل حاضر یک مدل ترموالاستیک
خطی است و گسست فیزیکی (شکست یا جدایش ماده) در آن لحاظ نشده است و بررسی آن
نیازمند یک مدل آسیب یا شکست فراتر از تحلیل خطی کنونی است. تنش محیطی بی‌بعد در
سطح داخلی از ۰٫۱۹۵ در نبود فشار به ۰٫۲۹۵ در فشار ۱۰۰ مگاپاسکال می‌رسد، یعنی
حدود ۵۱ درصد افزایش. توزیع تنش شعاعی بی‌بعد نیز مطابق شکل 4-N از مقدار منفی
فشار اعمالی در سطح داخلی به صفر در سطح خارجی میل می‌کند که با شرط مرزی بارگذاری
هم‌خوانی دارد.

جمع‌بندی این مطالعه، نتیجهٔ فصل پیشین را با دقت بیشتری بازتعریف می‌کند: در فشار
پایهٔ ۱ مگاپاسکال، سهم فشار در پاسخ کمتر از یک درصد و در نتیجه از مرتبهٔ دوم
است؛ اما با افزایش فشار به محدودهٔ ۷۰ تا ۱۰۰ مگاپاسکال، فشار به یک اثر ثانویهٔ
واقعی تبدیل می‌شود که تا حدود ۵۰ درصد تنش محیطی داخلی و حدود ۱۳ درصد جابجایی
را در بر می‌گیرد، هرچند پاسخ همچنان حرارت‌غالب است. افزون بر این، اعمال یک فشار
داخلی هارمونیک با دامنهٔ ۵ مگاپاسکال تنها یک نوسان کوچک بر تاریخچهٔ جابجایی
سوار می‌کند و میدان دما را تغییر نمی‌دهد (شکل 4-N).

**EN.**
The effect of the internal pressure is examined with a full pressure sweep at
six values 0, 10, 30, 50, 70, and 100 MPa, so that the behaviour is covered
from low pressures to very high pressures. As shown in Figure 4-N, the
temperature field remains practically independent of the internal pressure,
because thermal and mechanical loading are linked only through the weak
coupling term in the energy equation, and pressure is not a direct driver of
temperature. By contrast, the mechanical response grows linearly with
pressure: the peak dimensionless radial displacement rises from 1.073 with no
pressure to 1.086, 1.115, 1.143, 1.171, and 1.214, respectively, with an
increment of exactly 0.0283 per 20 MPa; this perfect linearity reflects the
linear nature of the thermoelastic model employed.

Importantly, even at 100 MPa no discontinuity (گسست) occurs in the numerical
response, and the solution remains smooth and convergent, because the present
model is a linear thermoelastic model in which physical rupture (material
failure or separation) is not included; assessing that would require a damage
or failure model beyond the present linear analysis. The dimensionless hoop
stress at the inner surface rises from 0.195 with no pressure to 0.295 at
100 MPa, an increase of about 51%. The dimensionless radial stress profile
(Figure 4-N) runs from the negative of the applied pressure at the inner
surface to zero at the outer surface, consistent with the loading boundary
condition.

The conclusion refines the previous chapter's result more precisely: at the
base pressure of 1 MPa the pressure contribution is below one percent and
hence second-order; but as the pressure rises into the 70–100 MPa range,
pressure becomes a genuine secondary effect that accounts for up to about 50%
of the inner hoop stress and about 13% of the displacement, although the
response is still thermally dominated. In addition, a harmonic internal
pressure of 5 MPa amplitude superposes only a small ripple on the displacement
history and leaves the temperature field unchanged (Figure 4-N).

## supports — اثر شرایط تکیه‌گاهی دو انتها / Effect of the end supports

**FA.**
اثر شرایط تکیه‌گاهی دو انتها برای سه حالت بررسی شده است: دو سر سادهٔ (S-S)، یک
سر ساده و یک سر گیردار (S-C) به‌عنوان حالت ترکیبی، و دو سر گیردار (C-C). مطابق
شکل 4-N، میدان دما تقریباً مستقل از نوع تکیه‌گاه است و بیشینهٔ دمای بی‌بعد در
هر سه حالت در بازهٔ باریک ۱٫۴۱۲ تا ۱٫۴۲۳ قرار می‌گیرد؛ این نتیجه طبیعی است،
زیرا شرط تکیه‌گاهی مکانیکی مسئلهٔ حرارتی را به‌طور مستقیم تغییر نمی‌دهد.

پاسخ مکانیکی اما به‌شدت به تکیه‌گاه وابسته است. در حالت دو سر گیردار، انبساط
حرارتی محوری جداره مسدود می‌شود و به‌واسطهٔ اثر پواسون به راستای شعاعی هدایت
می‌گردد؛ در نتیجه بیشینهٔ جابجایی شعاعی بی‌بعد از ۱٫۰۷۳ در حالت دو سر ساده به
۱٫۴۵۱ در حالت دو سر گیردار می‌رسد که حدود ۳۵ درصد افزایش است. حالت ترکیبی
(یک سر ساده و یک سر گیردار) برای تنش محیطی داخلی رفتاری میانی نشان می‌دهد:
تنش محیطی بی‌بعد در سطح داخلی برای سه حالت دو سر ساده، ترکیبی و دو سر گیردار
به ترتیب برابر ۰٫۱۹۶، ۰٫۱۷۰ و ۰٫۱۴۶ است و مقدار حالت ترکیبی به‌درستی میان دو
حالت حدی قرار می‌گیرد.

نکتهٔ درخور توجه آن است که بیشینهٔ جابجایی حالت ترکیبی (۱٫۰۵۴) به حالت دو سر
ساده نزدیک است نه به حالت دو سر گیردار؛ زیرا در مقطع میانی طول، انتهای سادهٔ
آزادی شعاعی را تعیین می‌کند و اثر انتهای گیردار به نیمهٔ نزدیک به آن محدود
می‌ماند. بدین ترتیب حالت ترکیبی از نظر تنش رفتاری میانی و از نظر جابجایی مقطع
میانی رفتاری نزدیک به حالت دو سر ساده دارد.

**EN.**
The effect of the end supports is examined for three cases: simply supported
at both ends (S-S), one end simply supported and the other clamped (S-C) as a
mixed case, and clamped at both ends (C-C). As shown in Figure 4-N, the
temperature field is nearly independent of the support type, and the peak
dimensionless temperature for all three cases lies in the narrow range 1.412
to 1.423; this is natural, since the mechanical support does not directly
alter the thermal problem.

The mechanical response, however, depends strongly on the support. With both
ends clamped, the axial thermal expansion of the wall is blocked and, by the
Poisson effect, is redirected radially; consequently the peak dimensionless
radial displacement rises from 1.073 in the simply supported case to 1.451 in
the clamped case, an increase of about 35%. The mixed case (one end simply
supported, the other clamped) shows intermediate behaviour for the inner hoop
stress: the dimensionless inner-surface hoop stress for the S-S, mixed, and
C-C cases is 0.196, 0.170, and 0.146, respectively, and the mixed value lies
correctly between the two limiting cases.

It is noteworthy that the peak displacement of the mixed case (1.054) is close
to the simply supported case rather than the clamped case, because at the
mid-length section the simply supported end governs the radial freedom and the
effect of the clamped end remains confined to the half nearer to it. The mixed
case is therefore intermediate in stress and, at mid-length, close to the
simply supported case in displacement.

## infinite — استوانه با طول نامحدود / The infinite-length cylinder limit

**FA.**
برای بررسی رفتار حدی استوانهٔ بلند، طول استوانه به‌تدریج از مقدار پایهٔ ۰٫۵
متر به ۱، ۲ و ۴ متر افزایش داده شده است تا اثر دو انتها بر مقطع میانی محو
شود. مطابق شکل 4-N، بیشینهٔ دمای بی‌بعد در مقطع میانی عملاً ثابت و در بازهٔ
۱٫۴۱۲ تا ۱٫۴۱۴ باقی می‌ماند، یعنی میدان دما مستقل از طول است.

در مقابل، پاسخ مکانیکی مقطع میانی با افزایش طول به یک مقدار حدی میل می‌کند.
جابجایی شعاعی بی‌بعد نهایی از ۱٫۰۱۹ برای طول ۰٫۵ متر به ترتیب به ۰٫۹۰۴، ۰٫۸۷۹
و ۰٫۸۵۸ برای طول‌های ۱، ۲ و ۴ متر کاهش می‌یابد و به مجانب حدود ۰٫۸۵ نزدیک
می‌شود. به همین ترتیب تنش محیطی بی‌بعد در سطح داخلی از ۰٫۱۹۶ به ۰٫۱۴۷، ۰٫۱۴۳
و ۰٫۱۳۸ کاهش یافته و به مجانب حدود ۰٫۱۳۸ می‌رسد.

این رفتار نشان می‌دهد که با بلندتر شدن استوانه، پاسخ مقطع میانی به حالت حدی
استوانهٔ نامحدود (شبه کرنش‌صفحه‌ای) همگرا می‌شود که در آن اثرهای مکانیکی و
حرارتی دو انتها دیده نمی‌شوند. استوانهٔ پایه با طول ۰٫۵ متر به دلیل نزدیکی دو
انتها، جابجایی و تنش اندکی بزرگ‌تر از حالت حدی را تجربه می‌کند و با افزایش طول
این اثر مرزی به‌تدریج رفع می‌گردد.

**EN.**
To examine the limiting behaviour of a long cylinder, the length is gradually
increased from the base value of 0.5 m to 1, 2, and 4 m so that the effect of
the two ends on the mid-length section vanishes. As shown in Figure 4-N, the
peak dimensionless temperature at the mid-length section is practically
constant, remaining in the range 1.412 to 1.414; that is, the temperature
field is length-independent.

By contrast, the mechanical response of the mid-length section tends to a
limiting value as the length increases. The final dimensionless radial
displacement decreases from 1.019 for a length of 0.5 m to 0.904, 0.879, and
0.858 for lengths of 1, 2, and 4 m, respectively, approaching an asymptote of
about 0.85. Likewise the dimensionless inner-surface hoop stress decreases
from 0.196 to 0.147, 0.143, and 0.138, approaching an asymptote of about
0.138.

This behaviour shows that as the cylinder becomes longer, the mid-length
response converges to the infinite-length (plane-strain-like) limit, in which
the mechanical and thermal effects of the two ends are not felt. The base
cylinder of length 0.5 m, owing to the proximity of the two ends, experiences
a slightly larger displacement and stress than the limiting case, and this
boundary effect is progressively removed as the length increases.

## matrix — برهم‌کنش الگوهای توزیع گرافن و تخلخل / GPL-porosity interaction matrix

**FA.**
برای بررسی کامل برهم‌کنش الگوهای توزیع پلاکت‌های گرافنی و تخلخل، تمام شانزده
ترکیب حاصل از چهار الگوی توزیع گرافن (O، X، V، A) و چهار الگوی توزیع تخلخل
(O، X، V، A) محاسبه و دمای بی‌بعد سطح خارجی برای هر ترکیب در قالب یک نمودار
حرارتی (شکل 4-N، S_interaction_matrix) ارائه شده است. این نمایش کامل، تصویری
جامع از عملکرد حرارتی سازه به‌دست می‌دهد.

نخستین مشاهدهٔ کلیدی آن است که الگوی تخلخل A (تمرکز حفره‌ها در سطح خارجی) به‌عنوان
یک سد حرارتی فراگیر عمل می‌کند و صرف‌نظر از الگوی توزیع گرافن، کمترین دمای سطح
خارجی را به‌همراه دارد؛ مقادیر دمای بی‌بعد سطح خارجی برای این ستون به ترتیب
برابر ۰٫۱۹، ۰٫۲۹، ۰٫۱۵ و ۰٫۳۲ است. بهترین ترکیب، یعنی گرافن V به‌همراه تخلخل A،
دمای سطح خارجی را در ۰٫۱۵ نگه می‌دارد که نسبت به حالت مرجع (حدود ۱٫۳۷) کاهشی
حدود ۹ برابری است و توصیهٔ طراحی این پژوهش برای حفاظت حرارتی را تأیید می‌کند.

دومین مشاهده، برهم‌کنش الگوهای آیینه‌ای است که در بازخورد داوری نیز بر آن تأکید
شده بود. الگوهای V و A از نظر هندسی آیینهٔ یکدیگرند (تمرکز در سطح داخلی در
برابر سطح خارجی). هنگامی که گرافن V (رسانا در سطح داخلی) با تخلخل A (عایق در
سطح خارجی) ترکیب می‌شود، دو سازوکار هم‌افزا عمل کرده و دمای سطح خارجی به ۰٫۱۵
می‌رسد؛ اما هنگامی که همان گرافن V با تخلخل V (هر دو متمرکز در سطح داخلی) ترکیب
می‌شود، دو اثر یکدیگر را تضعیف کرده و دمای سطح خارجی به ۱٫۲۴ افزایش می‌یابد.
در سوی دیگر، بدترین حالت‌ها به ترکیب گرافن A (رسانا در سطح خارجی) با تخلخل O یا
X مربوط است که دمای سطح خارجی را تا ۱٫۴۲ و ۱٫۴۰ بالا می‌برد. بدین ترتیب نه
تنها الگوی منفرد بلکه هم‌راستایی یا تقابل دو الگو در تعیین عملکرد حرارتی
نقش تعیین‌کننده دارد.

**EN.**
To fully examine the interaction of the GPL and porosity distribution
patterns, all sixteen combinations formed by the four GPL patterns (O, X, V,
A) and the four porosity patterns (O, X, V, A) are computed, and the
dimensionless outer-surface temperature for each combination is presented as a
heatmap (Figure 4-N, S_interaction_matrix). This complete map gives a
comprehensive picture of the thermal performance of the structure.

The first key observation is that porosity pattern A (pores concentrated at
the outer surface) acts as a universal thermal barrier and, regardless of the
GPL pattern, gives the lowest outer-surface temperature; the dimensionless
outer-surface temperatures for this column are 0.19, 0.29, 0.15, and 0.32,
respectively. The best combination, GPL-V together with porosity-A, holds the
outer-surface temperature at 0.15, a roughly ninefold reduction with respect
to the reference case (about 1.37), confirming this work's design
recommendation for thermal protection.

The second observation is the mirror-pattern interaction emphasized in the
review. Patterns V and A are geometric mirror images (inner-surface versus
outer-surface concentration). When GPL-V (conductive at the inner surface) is
combined with porosity-A (insulating at the outer surface), the two mechanisms
act synergetically and the outer-surface temperature reaches 0.15; but when
the same GPL-V is combined with porosity-V (both concentrated at the inner
surface), the two effects weaken each other and the outer-surface temperature
rises to 1.24. At the other extreme, the worst cases belong to GPL-A
(conductive at the outer surface) combined with porosity-O or X, which raise
the outer-surface temperature to as high as 1.42 and 1.40. Thus not only the
individual pattern but also the alignment or opposition of the two patterns is
decisive in determining the thermal performance.
