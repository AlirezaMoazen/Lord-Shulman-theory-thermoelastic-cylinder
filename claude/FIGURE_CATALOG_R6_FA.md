---
dir: rtl
lang: fa-IR
---

# کاتالوگ کامل نمودارها برای انتخاب شکل‌های فصل چهارم (هندسهٔ جدید، سیاه‌وسفید)

این سند برای **مرور و انتخاب** شکل‌های فصل چهارم است. تمام مطالعات در **هندسهٔ نهایی**
(شعاع داخلی $R_i=1$، شعاع خارجی $R_o=1.5$، ضخامت جداره $h=0.5$، طول $l=2.1$ متر،
$N_L=7$ لایه) و با **شبکهٔ نهایی $N_r=15$، $N_z=11$، $\Delta t=1$ ثانیه** اجرا شده‌اند.
بی‌بعدسازی مطابق مقالهٔ حیدرپور (app10041397) است:
$\mathrm{Fo}=\hat\alpha\,t/h^2$، $\ T^*=(T-T_\infty)/T_\infty$،
$\ U^*=u/[(1-\nu)\,\alpha\,T_\infty\,h]$،
$\ \Sigma^*=(1+\nu)\,\sigma/(E\,\alpha\,T_\infty)$، $\ \xi=(r-R_i)/(R_o-R_i)$
(با $h=R_o-R_i$؛ نماد $l$ برای طول و $h$ برای ضخامت).

برای هر مطالعه دو شکل آورده شده تا هر نمودار خواناتر باشد:

- **بخش ۱ — تاریخچه‌های زمانی (نقطهٔ میانی):** (۱) دمای $T^*$ · (۲) جابجایی شعاعی
  $u^*$ · (۳) جابجایی محوری $w^*$، همگی برحسب $\mathrm{Fo}$.
- **بخش ۲ — پروفیل‌های شعاعی در زمان نهایی (۸ پنل):** $T^*(\xi)$ · کرنش شعاعی
  $\epsilon_{rr}$ · کرنش محیطی $\epsilon_{\theta\theta}$ · کرنش محوری $\epsilon_{zz}$ ·
  جابجایی $u^*$ · تنش شعاعی $\Sigma_{rr}$ · تنش محیطی $\Sigma_{\theta\theta}$ · تنش
  محوری $\Sigma_{zz}$. (سه کرنش در زمان نهایی دقیق‌اند: $\epsilon_{rr}$ و
  $\epsilon_{\theta\theta}$ از میدان جابجایی، و $\epsilon_{zz}$ از تنش‌های
  ذخیره‌شده به کمک قانون هوک — بدون اجرای مجدد.)

لطفاً پنل‌های موردنظر هر بخش را علامت بزنید تا همان‌ها را با کیفیت چاپی نهایی کنم.
نسخهٔ رنگی در `FIGURE_CATALOG_R6_color_FA.docx` و نسخهٔ فشردهٔ چهارپنلی نیز موجود است.

> **توجه:** تاریخچهٔ زمانیِ **تنش و کرنش** فقط برای مطالعات شوک (پایه، زمان تخفیف،
> تئوری‌ها، گاوسی) با تاریخچهٔ کامل ذخیره شده است؛ برای بقیه فقط تاریخچهٔ دما و
> جابجایی نقطهٔ میانی موجود است.

---

# الف) مطالعات ماده و تقویت‌کننده

## اثر الگوی توزیع پلاکت‌های گرافنی (UD, O, X, V, A)
![A_hist](figures_ch4/A_GPL_patterns_hist.png){width=6.5in}
![A_prof](figures_ch4/A_GPL_patterns_prof.png){width=6.5in}

## اثر الگوی توزیع تخلخل (UD, O, X, V, A)
![B_hist](figures_ch4/B_porosity_patterns_hist.png){width=6.5in}
![B_prof](figures_ch4/B_porosity_patterns_prof.png){width=6.5in}

## اثر سطح تخلخل ($e_{m3}=0.9675 / 0.8604 / 0.7776$)
![E_hist](figures_ch4/E_porosity_level_hist.png){width=6.5in}
![E_prof](figures_ch4/E_porosity_level_prof.png){width=6.5in}

## کسر وزنی کمِ گرافن ($W=0.1 / 0.3 / 0.5 / 0.9 / 1.5\%$)
![D_hist](figures_ch4/D_wt_low_hist.png){width=6.5in}
![D_prof](figures_ch4/D_wt_low_prof.png){width=6.5in}

## کسر وزنی بالای گرافن ($W=1 / 2 / 4 / 8\%$)
![D2_hist](figures_ch4/D2_wt_high_hist.png){width=6.5in}
![D2_prof](figures_ch4/D2_wt_high_prof.png){width=6.5in}

## نسبت ابعادی پلاکت: طول به عرض $a/b$ ($1.0 / 1.67 / 2.67$)
![O_hist](figures_ch4/O_aspect_ab_hist.png){width=6.5in}
![O_prof](figures_ch4/O_aspect_ab_prof.png){width=6.5in}

## نسبت ابعادی پلاکت: عرض به ضخامت $b/t$ ($500 / 1000 / 2000$)
![P_hist](figures_ch4/P_aspect_bt_hist.png){width=6.5in}
![P_prof](figures_ch4/P_aspect_bt_prof.png){width=6.5in}

## ماتریس ۲۵حالتهٔ الگوی گرافن × الگوی تخلخل (۵×۵)
![M25_S](figures_ch4/matrix25_Sigma_thth.png){width=7in}
![M25_T](figures_ch4/matrix25_Tstar.png){width=7in}

---

# ب) مطالعات حرارتی و تئوری‌ها

## اثر زمان تخفیف (فوریه و $\tau^*=0.04 / 0.15 / 0.44 / 0.87$)
![C_hist](figures_ch4/C_relaxation_hist.png){width=6.5in}
![C_prof](figures_ch4/C_relaxation_prof.png){width=6.5in}

## پاسخ به شوک حرارتی گاوسی (لرد–شولمن در برابر فوریه)
![M_hist](figures_ch4/M_gauss_shock_hist.png){width=6.5in}
![M_prof](figures_ch4/M_gauss_shock_prof.png){width=6.5in}

## مقایسهٔ تئوری‌های ترموالاستیسیته (فوریه / LS / DPL / GN-III)
![T3_hist](figures_ch4/T3_theories_hist.png){width=6.5in}
![T3_prof](figures_ch4/T3_theories_prof.png){width=6.5in}

## اثر ممزوج بودن معادلات (ممزوج / غیرممزوج)
![I_hist](figures_ch4/I_coupling_hist.png){width=6.5in}
![I_prof](figures_ch4/I_coupling_prof.png){width=6.5in}

## اثر ضریب همرفت سطح خارجی ($h_c=10 / 100 / 1000$)
![J_hist](figures_ch4/J_convection_hist.png){width=6.5in}
![J_prof](figures_ch4/J_convection_prof.png){width=6.5in}

## پیشانی موج حرارتی (صوت دوم) در ضخامت جداره
![WF_BASE](figures_ch4/BASE_wavefront.png){width=5in}
![WF_TAU](figures_ch4/C_TAU_087_wavefront.png){width=5in}
![WF_GAUSS](figures_ch4/M_GAUSS_LS_wavefront.png){width=5in}

---

# ج) مطالعات هندسه و شرایط مرزی

## اثر شرایط تکیه‌گاهی دو سر ($S\text{-}S / S\text{-}C / C\text{-}C$)
![F_hist](figures_ch4/F_end_BC_hist.png){width=6.5in}
![F_prof](figures_ch4/F_end_BC_prof.png){width=6.5in}

## جاروب فشار داخلی ($P_i=0 / 10 / 50 / 100$ مگاپاسکال)
![G_hist](figures_ch4/G_pressure_hist.png){width=6.5in}
![G_prof](figures_ch4/G_pressure_prof.png){width=6.5in}

## اثر ضخامت جداره ($R_o/R_i=1.25 / 1.5 / 2.0$)
![K_hist](figures_ch4/K_thickness_hist.png){width=6.5in}
![K_prof](figures_ch4/K_thickness_prof.png){width=6.5in}

## اثر طول استوانه ($l=1 / 2.1 / 5 / 10$ متر)
![Q_hist](figures_ch4/Q_length_hist.png){width=6.5in}
![Q_prof](figures_ch4/Q_length_prof.png){width=6.5in}

## اثر تعداد لایه ($N_L=3 / 5 / 7 / 9 / 15$)
![L_hist](figures_ch4/L_layers_hist.png){width=6.5in}
![L_prof](figures_ch4/L_layers_prof.png){width=6.5in}

---

# د) همگرایی و حداقل تعداد نقاط (روش مکانی و انتگرال‌گیری زمانی) — پرومپت ۳ بند ۴

هر شکل چهار پنل دارد: (الف) پروفیل تنش محیطی، (ب) پروفیل دما، (ج) خطای نسبی نسبت به
ریزترین شبکه (محور لگاریتمی)، (د) هزینه. **جمع‌بندی:** جهت محوری ($N_z$) قید تعیین‌کننده
است ($N_z=5$ خطای ۹٪)، حال آن‌که جهت شعاعی ($N_r$) از $N_r=7$ همگرا است.

## همگرایی نقاط شعاعی $N_r$ (۷ / ۹ / ۱۱ / ۱۳ / ۱۵)
![conv_Nr](figures_ch4/conv_Nr.png){width=6.5in}

## همگرایی نقاط محوری $N_z$ (۵ / ۷ / ۹ / ۱۱ / ۱۳ / ۱۵)
![conv_Nz](figures_ch4/conv_Nz.png){width=6.5in}

## همگرایی تعداد لایه‌ها $N_L$ (۳ / ۵ / ۷ / ۹ / ۱۵)
![conv_NL](figures_ch4/conv_NL.png){width=6.5in}

## همگرایی گام زمانی $\Delta t$ (۰٫۵ / ۱ / ۲ / ۵ ثانیه)
![conv_dt](figures_ch4/conv_dt.png){width=6.5in}

## نمودار جامع: خطا برحسب اندازهٔ مسئله به تفکیک جهت
![conv_master](figures_ch4/conv_master.png){width=6in}
