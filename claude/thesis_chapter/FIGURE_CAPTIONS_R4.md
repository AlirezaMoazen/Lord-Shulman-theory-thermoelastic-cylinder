# Figure captions - Chapter 4 (R4)

**conv_NL**

- EN: Layer-count convergence: hoop-stress and temperature profiles, L2 error and cost vs number of layers N_L (N_r=15, N_z=11).
- FA: همگرایی تعداد لایه: پروفیل تنش محیطی و دما، خطای L2 و هزینه برحسب تعداد لایه N_L (با N_r=15 و N_z=11).

**conv_Nr**

- EN: Radial-node convergence per layer (N_z=11, N_L=7); the field quantities are converged from N_r=7.
- FA: همگرایی نقاط شعاعیِ هر لایه (با N_z=11 و N_L=7)؛ کمیت‌های میدانی از N_r=7 همگرایند.

**conv_Nz**

- EN: Axial-node convergence, the binding direction (N_r=15, N_L=7); N_z=5 gives a 9.4% error, with the clean serial cost.
- FA: همگرایی نقاط محوری، راستای تعیین‌کننده (با N_r=15 و N_L=7)؛ N_z=5 خطای ۹٫۴٪ می‌دهد؛ همراه با هزینهٔ سریِ خالص.

**conv_dt**

- EN: Time-step convergence; steps up to 2 s are converged while 5 s produces a spurious overshoot.
- FA: همگرایی گام زمانی؛ گام‌های تا ۲ ثانیه همگرایند و گام ۵ ثانیه فراجهش کاذب می‌سازد.

**conv_master**

- EN: L2 hoop-profile error versus problem size N_dof, refined one direction at a time; the axial direction is binding.
- FA: خطای L2 پروفیل محیطی برحسب اندازهٔ مسئله N_dof، با ریزسازیِ هر بار یک راستا؛ راستای محوری تعیین‌کننده است.

**bench1_U**

- EN: Verification (mechanical): dimensionless inner-surface radial displacement of the present solver against Malekzadeh & Heydarpour (2012) and an independent ANSYS solution.
- FA: صحت‌سنجی (مکانیکی): جابجایی شعاعیِ بی‌بعدِ سطح داخلیِ حل‌گر حاضر در برابر ملک‌زاده و حیدرپور (۲۰۱۲) و حل مستقل انسیس.

**bench2_T_profiles**

- EN: Verification (thermal): transient temperature profiles from the present DQM+Newmark solver against the exact Bessel-series solution at t = 2, 10 and 40 s.
- FA: صحت‌سنجی (حرارتی): پروفیل‌های دمای گذرا از حل‌گر مربعات‌تفاضلی+نیومارکِ حاضر در برابر حل دقیق سریِ بسل در t = ۲، ۱۰ و ۴۰ ثانیه.

**bench3_theta**

- EN: Verification (Lord-Shulman waves): second-sound temperature fronts through the wall against Bagri & Eslami (2007), Fig. 2.
- FA: صحت‌سنجی (امواج لرد–شولمن): پیشانی‌های دمای صوت دوم در عرض جداره در برابر باقری و اسلامی (۲۰۰۷)، شکل ۲.

**A_GPL_patterns**

- EN: Effect of the GPL distribution pattern (UD, O, X, V, A): mid-point T* and U* histories vs Fo and the final T*, hoop-stress profiles vs xi.
- FA: اثر الگوی توزیع گرافن (UD, O, X, V, A): تاریخچه‌های T* و U* نقطهٔ میانی برحسب Fo و پروفیل‌های نهاییِ T* و تنش محیطی برحسب xi.

**B_porosity_patterns**

- EN: Effect of the porosity distribution pattern (UD, O, X, V, A), GPL kept uniform; pattern A acts as a thermal barrier.
- FA: اثر الگوی توزیع تخلخل (UD, O, X, V, A) با گرافن یکنواخت؛ الگوی A همچون سد حرارتی عمل می‌کند.

**E_porosity_level**

- EN: Effect of the porosity level e_m3 = 0.9675 / 0.8604 / 0.7776 (light / moderate / heavy).
- FA: اثر شدت تخلخل e_m3 = ۰٫۹۶۷۵ / ۰٫۸۶۰۴ / ۰٫۷۷۷۶ (سبک / متوسط / سنگین).

**D_wt_low**

- EN: Effect of the GPL weight fraction, low range W = 0.1 / 0.3 / 0.5 / 0.9 / 1.5 %.
- FA: اثر کسر وزنی گرافن، گسترهٔ پایین W = ۰٫۱ / ۰٫۳ / ۰٫۵ / ۰٫۹ / ۱٫۵ درصد.

**D2_wt_high**

- EN: Effect of the GPL weight fraction, high range W = 1 / 2 / 4 / 8 %; the thermal gain saturates while the stresses grow.
- FA: اثر کسر وزنی گرافن، گسترهٔ بالا W = ۱ / ۲ / ۴ / ۸ درصد؛ بهرهٔ حرارتی اشباع می‌شود و تنش‌ها رشد می‌کنند.

**O_aspect_ab**

- EN: Effect of the platelet length-to-width aspect ratio a/b = 1.0 / 1.67 / 2.67.
- FA: اثر نسبت ابعادیِ طول‌به‌عرضِ پلاکت a/b = ۱٫۰ / ۱٫۶۷ / ۲٫۶۷.

**P_aspect_bt**

- EN: Effect of the platelet width-to-thickness aspect ratio b/t = 500 / 1000 / 2000.
- FA: اثر نسبت ابعادیِ عرض‌به‌ضخامتِ پلاکت b/t = ۵۰۰ / ۱۰۰۰ / ۲۰۰۰.

**C_relaxation**

- EN: Effect of the relaxation time: Fourier (tau*=0) and Lord-Shulman tau* = 0.04 / 0.15 / 0.44 / 0.87; overshoot grows with tau*.
- FA: اثر زمان تخفیف: فوریه (tau*=0) و لرد–شولمن tau* = ۰٫۰۴ / ۰٫۱۵ / ۰٫۴۴ / ۰٫۸۷؛ فراجهش با tau* رشد می‌کند.

**F_end_BC**

- EN: Effect of the end supports: simply supported (S-S), mixed (S-C) and clamped (C-C).
- FA: اثر شرایط تکیه‌گاهیِ دو سر: ساده (S-S)، مخلوط (S-C) و گیردار (C-C).

**G_pressure**

- EN: Effect of the internal pressure P_i = 0 / 10 / 50 / 100 MPa; the mechanical response grows linearly.
- FA: اثر فشار داخلی P_i = ۰ / ۱۰ / ۵۰ / ۱۰۰ مگاپاسکال؛ پاسخ مکانیکی خطی رشد می‌کند.

**Q_length**

- EN: Effect of the cylinder length l = 1 / 2.1 / 5 / 10 m and the approach to the long-cylinder limit.
- FA: اثر طول استوانه l = ۱ / ۲٫۱ / ۵ / ۱۰ متر و نزدیک‌شدن به حدِ استوانهٔ بلند.

**matrix25_Tstar**

- EN: Full 25-case GPL x porosity matrix: through-wall dimensionless temperature T*(xi) for every pattern pair; porosity A is a universal thermal barrier.
- FA: ماتریس کاملِ ۲۵حالتهٔ گرافن × تخلخل: دمای بی‌بعدِ عرضِ‌جدارهٔ T*(xi) برای هر جفت الگو؛ تخلخل A سد حرارتیِ سراسری است.

**matrix25_Sigma_thth**

- EN: Full 25-case GPL x porosity matrix: hoop-stress profile Sigma_thth(xi) for every pattern pair.
- FA: ماتریس کاملِ ۲۵حالتهٔ گرافن × تخلخل: پروفیل تنش محیطیِ Sigma_thth(xi) برای هر جفت الگو.

**I_coupling**

- EN: Effect of thermo-mechanical coupling: fully coupled versus uncoupled energy equation.
- FA: اثر ممزوج بودن معادلات: مدل کاملاً ممزوج در برابر معادلهٔ انرژیِ غیرممزوج.

**J_convection**

- EN: Effect of the outer-surface convection coefficient h_c = 10 / 100 / 1000 W/m2K.
- FA: اثر ضریب همرفتِ سطح خارجی h_c = ۱۰ / ۱۰۰ / ۱۰۰۰ وات بر مترمربع‌کلوین.

**K_thickness**

- EN: Effect of the wall thickness, radius ratio R_o/R_i = 1.25 / 1.5 / 2.0 (inner radius fixed).
- FA: اثر ضخامت جداره، نسبت شعاعی R_o/R_i = ۱٫۲۵ / ۱٫۵ / ۲٫۰ (شعاع داخلی ثابت).

**M_gauss_shock**

- EN: Response to a Gaussian thermal shock: Lord-Shulman versus Fourier; the LS pulse arrives later, stronger and persists.
- FA: پاسخ به شوک حرارتیِ گاوسی: لرد–شولمن در برابر فوریه؛ تپِ LS دیرتر، قوی‌تر و ماندگارتر می‌رسد.

**T3_theories**

- EN: Comparison of the generalized thermoelasticity theories: Fourier / Lord-Shulman / dual-phase-lag / Green-Naghdi III.
- FA: مقایسهٔ نظریه‌های ترموالاستیسیتهٔ تعمیم‌یافته: فوریه / لرد–شولمن / تأخیر دوفازی / گرین–نگدی نوع سوم.


