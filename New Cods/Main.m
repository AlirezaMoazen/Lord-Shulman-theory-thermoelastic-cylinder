%% ========================================================================
%  STATIC THERMOELASTIC ANALYSIS OF MULTI-LAYER POROUS GPL CYLINDER
%  Using Differential Quadrature Method (DQM) with per-layer meshing
%  ========================================================================
%  LEGEND (اصلی‌ترین پارامترها و متغیرها)
%  NL       : تعداد لایه‌ها
%  N_r      : تعداد نقاط DQ در راستای شعاعی در هر لایه (شامل مرزها)
%  N_z      : تعداد نقاط DQ در راستای محوری (مشترک بین لایه‌ها)
%  R_i, R_o : شعاع داخلی و خارجی استوانه (متر)
%  L        : طول استوانه (متر)
%  r_nodes{e} : بردار نقاط شعاعی لایه e (توزیع چبیش�?)
%  z_nodes    : بردار نقاط محوری (چبیش�?)
%  A_r{e}, B_r{e} : ماتریس‌های وزن مرتبه اول و دوم در راستای r برای لایه e
%  A_z, B_z      : ماتریس‌های وزن مرتبه اول و دوم در راستای z (یکسان برای همه)
%  خواص پایه: ماتریس (m) و GPL با پارامترهای مشخص
%  خواص موثر هر لایه در نقاط گره: E_node, nu_node, rho_node, c_node, k_node, alpha_node
%  اندیس‌گذاری سراسری: idx_T(e,ir,iz) , idx_U(e,ir,iz) , idx_W(e,ir,iz)
%  ========================================================================

clear; clc; close all;

%% ========================= 1. هندسه و گسسته‌سازی =========================
NL = 5;                     % تعداد لایه‌ها (قابل تغییر)
R_i = 0.1;                  % شعاع داخلی (m)
R_o = 0.2;                  % شعاع خارجی (m)
L = 0.5;                    % طول استوانه (m)
N_r = 7;                   % تعداد نقاط شعاعی در هر لایه (توصیه میانی 11 تا 15)
N_z = 13;                   % تعداد نقاط محوری

% ضخامت هر لایه (�?رض مساوی)
t_layer = (R_o - R_i) / NL;
R_boundaries = linspace(R_i, R_o, NL+1);   % مرزهای بین لایه‌ها

% نقاط محوری با توزیع چبیش�? در بازه [0, L]
z_nodes = chebyshev_grid(0, L, N_z);

% نقاط شعاعی در هر لایه (چبیش�? در بازه هر لایه)
r_nodes = cell(NL, 1);
for e = 1:NL
    r_nodes{e} = chebyshev_grid(R_boundaries(e), R_boundaries(e+1), N_r);
end

% محاسبه ماتریس‌های وزن DQ در راستای z (مرتبه اول و دوم)
[A_z, B_z] = DQ_weights(z_nodes);

% محاسبه ماتریس‌های وزن DQ در راستای r برای هر لایه (مستقل)
A_r = cell(NL, 1);
B_r = cell(NL, 1);
for e = 1:NL
    [A_r{e}, B_r{e}] = DQ_weights(r_nodes{e});
end

%% ========================= 2. خواص مواد پایه و پارامترها =========================
% ---------- خواص GPL ----------
a_GPL = 2.5e-6;     % طول (m)
b_GPL = 1.5e-6;     % عرض (m)
t_GPL = 1.5e-9;     % ضخامت (m)
E_GPL = 1.01e12;    % مدول یانگ (Pa)
rho_GPL = 1060;     % چگالی (kg/m^3)
c_GPL = 710;        % ظر�?یت گرمایی ویژه (J/(kg·K))
alpha_GPL = 5e-6;   % ضریب انبساط حرارتی (1/K)
k_GPL = 5000;       % هدایت حرارتی (W/(m·K))

% ---------- خواص ماتریس ----------
E_m = 3.0e9;        % مدول یانگ (Pa)
nu_m = 0.34;        % نسبت پواسون
rho_m = 1200;       % چگالی (kg/m^3)
c_m = 800;          % ظر�?یت گرمایی (J/(kg·K))
alpha_m = 45e-6;    % ضریب انبساط حرارتی (1/K)
k_m = 0.4;          % هدایت حرارتی (W/(m·K))

% ---------- الگوهای توزیع و تخلخل ----------
GPL_pattern = 'UD';          % 'UD', 'O', 'X', 'V', 'A'
porosity_pattern = 'UD';     % 'UD', 'O', 'X', 'V', 'A'
W_GPL_total = 0;         % کسر جرمی کل GPL (متوسط)
% ضرایب تخلخل برای الگوهای UD, O, X (داده می‌شوند)
e1 = 0.3;   % برای O-type
e2 = 0.3;   % برای X-type
e3 = 0.7;   % برای UD-type (نسبت مدول موثر به مدول پایه)
% برای الگوهای V و A ، e4 و e5 از شرط جرم ثابت (معادله 46-3) محاسبه می‌شوند.
% در ادامه در زمان محاسبه خواص، این ضرایب تعیین می‌گردند.

% ---------- پارامترهای هالپین-تسای ----------
xi_L = 2 * (a_GPL / t_GPL);
xi_T = 2 * (b_GPL / t_GPL);
eta_L = (E_GPL/E_m - 1) / (E_GPL/E_m + xi_L);
eta_T = (E_GPL/E_m - 1) / (E_GPL/E_m + xi_T);

% پارامتر هدایت حرارتی (مطابق رابطه 14-3)
p = a_GPL / t_GPL;          % نسبت طول به ضخامت
if p > 1
    Hp = log(p + sqrt(p^2-1)) * p / sqrt((p^2-1)^3) - 1/(p^2-1);
else
    Hp = 0;
end
gamma_conn = 1;              % مول�?ه اتصال (�?رض 1)

% ---------- شرایط مرزی و بارگذاری ----------
% حرارتی
T_inf = 400;                % دمای محیط (K)
h_c = 100;                  % ضریب انتقال حرارت (W/(m^2·K))
T_ref = 300;                % دمای مرجع برای کرنش حرارتی
T_i_val = T_ref;              % دمای سطح داخلی در حالت استاتیک (K)

% مکانیکی
P_i = 1.2*10e6;                 % �?شار داخلی (Pa) (10 MPa)
% نوع تکیه‌گاه در z=0 و z=L: 'simply' (ساده)، 'clamped' (گیردار)، 'free' (آزاد)
support_type = 'clamped';

%% ========================= 3. پیش‌محاسبه برای الگوهای تخلخل V و A (اصلاحی) =========================
l_total = R_o - R_i;
% انتگرال مرجع از الگوی O-type
int_ref = integral(@(r) sqrt(1 - e1 * cos(pi * r / l_total)), R_i, R_o);

if strcmpi(porosity_pattern, 'V')
    % تعری�? تابع با قدر مطلق کسینوس (برای جلوگیری از من�?ی)
    fun_V = @(r, e4) sqrt(e4 * abs(cos(pi * r / (2*l_total) + pi/4)));
    e4_sol = fzero(@(e4) integral(@(r) fun_V(r, e4), R_i, R_o) - int_ref, 0.5);
    e5_sol = NaN;
elseif strcmpi(porosity_pattern, 'A')
    fun_A = @(r, e5) sqrt(e5 * abs(cos(pi * r / (2*l_total) + 5*pi/4)));
    e5_sol = fzero(@(e5) integral(@(r) fun_A(r, e5), R_i, R_o) - int_ref, 0.5);
    e4_sol = NaN;
else
    e4_sol = NaN; e5_sol = NaN;
end

%% ========================= 4. محاسبه خواص موثر (اصلاحی) =========================
E_node = cell(NL, 1);
nu_node = cell(NL, 1);
rho_node = cell(NL, 1);
c_node = cell(NL, 1);
k_node = cell(NL, 1);
alpha_node = cell(NL, 1);

for e = 1:NL
    % ---- کسر جرمی GPL با جلوگیری از من�?ی و بیشتر از 1 ----
    switch upper(GPL_pattern)
        case 'UD'
            W_GPL_e = W_GPL_total;
        case 'O'
            mid = (NL+1)/2;
            W_GPL_e = 4 * W_GPL_total * (0.5 - abs(e - mid)) / (NL + 2);
            W_GPL_e = max(0, min(1, W_GPL_e));   % اصلاح
        case 'X'
            W_GPL_e = W_GPL_total * (2*e / (NL+1));
            W_GPL_e = min(1, W_GPL_e);           % اصلاح
        case 'V'
            W_GPL_e = W_GPL_total * (2*(NL+1-e) / (NL+1));
            W_GPL_e = min(1, W_GPL_e);
        case 'A'
            W_GPL_e = W_GPL_total * (2*e / (NL+1));
            W_GPL_e = min(1, W_GPL_e);
        otherwise
            error('الگوی GPL نامعتبر است.');
    end
    
    % تبدیل کسر جرمی به حجمی
    V_GPL = W_GPL_e / (W_GPL_e + (rho_GPL/rho_m)*(1 - W_GPL_e));
    
    % ---- خواص بدون تخلخل ----
    E_L = (1 + xi_L * eta_L * V_GPL) / (1 - eta_L * V_GPL) * E_m;
    E_T = (1 + xi_T * eta_T * V_GPL) / (1 - eta_T * V_GPL) * E_m;
    E_base = 3/8 * E_L + 5/8 * E_T;
    rho_base = V_GPL * rho_GPL + (1-V_GPL) * rho_m;
    c_base   = V_GPL * c_GPL   + (1-V_GPL) * c_m;
    alpha_base= V_GPL * alpha_GPL + (1-V_GPL) * alpha_m;
    k_base = (2/3 * (V_GPL - 1/p)^gamma_conn) / (Hp + 1/(k_GPL/k_m - 1)) * k_m + k_m;
    nu_base = nu_m;
    
    % ---- اعمال تخلخل وابسته به مکان ----
    r_local = r_nodes{e};
    r_rel = r_local - R_i;
    
    switch lower(porosity_pattern)
        case 'ud'
            Factor_E = e3 * ones(size(r_local));
        case 'o'
            Factor_E = 1 - e1 * cos(pi * r_rel / l_total);
            Factor_E = min(1, Factor_E);   % جلوگیری از ا�?زایش مدول
        case 'x'
            Factor_E = 1 - e2 * (1 - cos(pi * r_rel / l_total));
            Factor_E = min(1, Factor_E);
        case 'v'
            if isnan(e4_sol)
                error('e4_sol محاسبه نشده است. ابتدا الگوی تخلخل V را در بخش 3 �?عال کنید.');
            end
            Factor_E = e4_sol * cos(pi * r_rel / (2*l_total) + pi/4);
            Factor_E = max(0, min(1, Factor_E));   % محدودیت �?یزیکی
        case 'a'
            if isnan(e5_sol)
                error('e5_sol محاسبه نشده است. ابتدا الگوی تخلخل A را در بخش 3 �?عال کنید.');
            end
            Factor_E = e5_sol * cos(pi * r_rel / (2*l_total) + 5*pi/4);
            Factor_E = max(0, min(1, Factor_E));
        otherwise
            error('الگوی تخلخل نامعتبر است.');
    end
    
    Factor_rho = sqrt(Factor_E);
    Factor_k = Factor_E;
    Factor_c = Factor_E;
    
    E_node{e} = E_base * Factor_E;
    nu_node{e} = nu_base * ones(size(r_local));
    rho_node{e} = rho_base * Factor_rho;
    c_node{e} = c_base * Factor_c;
    k_node{e} = k_base * Factor_k;
    alpha_node{e} = alpha_base * ones(size(r_local));
end

%% ========================= 5. حل معادله حرارتی استاتیک (�?وریه) با در نظر گر�?تن گرادیان k =========================
Ndof_T = NL * N_r * N_z;
K_T = sparse(Ndof_T, Ndof_T);
F_T = sparse(Ndof_T, 1);
idx_T = @(e, ir, iz) (e-1)*N_r*N_z + (ir-1)*N_z + iz;

for e = 1:NL
    r_vec = r_nodes{e};
    k_vec = k_node{e};
    
    % محاسبه مشتق k نسبت به r در نقاط لایه با است�?اده از A_r
    dk_dr = A_r{e} .* k_vec;   % dk/dr در هر گره
    
    for ir = 1:N_r
        r_val = r_vec(ir);
        k_val = k_vec(ir);
        dk = dk_dr(ir);
        for iz = 1:N_z
            eq = idx_T(e, ir, iz);
            
            % جمله (k/r) * dT/dr
            for jr = 1:N_r
                col = idx_T(e, jr, iz);
                K_T(eq, col) = K_T(eq, col) + (k_val / r_val) * A_r{e}(ir, jr);
            end
            % جمله k * d2T/dr2
            for jr = 1:N_r
                col = idx_T(e, jr, iz);
                K_T(eq, col) = K_T(eq, col) + k_val * B_r{e}(ir, jr);
            end
            % جمله (dk/dr) * dT/dr  (جمله جدید)
            for jr = 1:N_r
                col = idx_T(e, jr, iz);
                K_T(eq, col) = K_T(eq, col) + dk * A_r{e}(ir, jr);
            end
            % جمله k * d2T/dz2
            for jz = 1:N_z
                col = idx_T(e, ir, jz);
                K_T(eq, col) = K_T(eq, col) + k_val * B_z(iz, jz);
            end
        end
    end
end

% اعمال شرایط مرزی حرارتی
% ال�?) شرط دما در سطح داخلی (r = R_i, e=1, ir=1)
for iz = 1:N_z
    node = idx_T(1, 1, iz);
    K_T(node, :) = 0;
    K_T(node, node) = 1;
    F_T(node) = T_i_val;
end

% ب) شرط همر�?ت در سطح خارجی (r = R_o, e=NL, ir=N_r)
e_last = NL;
for iz = 1:N_z
    node = idx_T(e_last, N_r, iz);
    r_out = r_nodes{e_last}(N_r);
    k_out = k_node{e_last}(N_r);
    % معادله: -k dT/dr = h_c (T - T_inf)  ->  k * (A_r * T) + h_c T = h_c T_inf
    K_T(node, :) = 0;
    for jr = 1:N_r
        col = idx_T(e_last, jr, iz);
        K_T(node, col) = k_out * A_r{e_last}(N_r, jr);
    end
    K_T(node, node) = K_T(node, node) + h_c;
    F_T(node) = h_c * T_inf;
end

% ج) شرط عایق در z=0 و z=L (∂T/∂z = 0)
% برای z=0 (iz=1)
for e = 1:NL
    for ir = 1:N_r
        node = idx_T(e, ir, 1);
        K_T(node, :) = 0;
        for jz = 1:N_z
            col = idx_T(e, ir, jz);
            K_T(node, col) = A_z(1, jz);
        end
        F_T(node) = 0;
    end
end
% برای z=L (iz=N_z)
for e = 1:NL
    for ir = 1:N_r
        node = idx_T(e, ir, N_z);
        K_T(node, :) = 0;
        for jz = 1:N_z
            col = idx_T(e, ir, jz);
            K_T(node, col) = A_z(N_z, jz);
        end
        F_T(node) = 0;
    end
end

% د) شرایط سازگاری حرارتی بین لایه‌ها (در مرز مشترک r = R_boundaries(e+1))
for e = 1:NL-1
    for iz = 1:N_z
        idx_left = idx_T(e, N_r, iz);
        idx_right = idx_T(e+1, 1, iz);
        % شرط 1: دما پیوسته -> T_left = T_right
        K_T(idx_left, :) = 0;
        K_T(idx_left, idx_left) = 1;
        K_T(idx_left, idx_right) = -1;
        F_T(idx_left) = 0;
        
        % شرط 2: شار حرارتی پیوسته -> k_left * dT/dr|left = k_right * dT/dr|right
        idx_flux = idx_right;   % جایگزینی معادله سمت راست با شرط شار
        k_left = k_node{e}(N_r);
        k_right = k_node{e+1}(1);
        K_T(idx_flux, :) = 0;
        for jr = 1:N_r
            col_left = idx_T(e, jr, iz);
            K_T(idx_flux, col_left) = k_left * A_r{e}(N_r, jr);
            col_right = idx_T(e+1, jr, iz);
            K_T(idx_flux, col_right) = -k_right * A_r{e+1}(1, jr);
        end
        F_T(idx_flux) = 0;
    end
end

% حل دستگاه حرارتی
T_global = K_T \ F_T
% بازآرایی دما در هر لایه (ماتریس N_r × N_z)
T_layer = cell(NL, 1);
for e = 1:NL
    T_layer{e} = zeros(N_r, N_z);
    for ir = 1:N_r
        for iz = 1:N_z
            T_layer{e}(ir, iz) = T_global(idx_T(e, ir, iz));
        end
    end
end

%% ========================= 6. حل معادله الاستیک استاتیک (کوپل با دما) با اعمال کامل شرایط =========================
% تعداد کل درجات آزادی مکانیکی (U و W)
Ndof_M = 2 * NL * N_r * N_z;
K_M = sparse(Ndof_M, Ndof_M);
F_M = sparse(Ndof_M, 1);

% اندیس‌گذاری برای U و W
idx_U = @(e, ir, iz) (e-1)*N_r*N_z*2 + (ir-1)*N_z*2 + (iz-1)*2 + 1;
idx_W = @(e, ir, iz) idx_U(e, ir, iz) + 1;

% =======================  مونتاژ معادلات تعادل درون هر لایه =======================
for e = 1:NL
    r_vec = r_nodes{e};
    for ir = 1:N_r
        r_val = r_vec(ir);
        E_val = E_node{e}(ir);
        nu_val = nu_node{e}(ir);
        % ضرایب الاستیک (ایزوتروپیک)
        C11 = (1-nu_val)*E_val / ((1+nu_val)*(1-2*nu_val));
        C12 = nu_val*E_val / ((1+nu_val)*(1-2*nu_val));
        C13 = C12;
        C22 = C11;
        C23 = C12;
        C33 = C11;
        C55 = E_val / (2*(1+nu_val));
        
        for iz = 1:N_z
            % ---- معادله در راستای r (66-3) ----
            eq_r = idx_U(e, ir, iz);
            % عبارات u
            for jr = 1:N_r
                col_u = idx_U(e, jr, iz);
                K_M(eq_r, col_u) = K_M(eq_r, col_u) + C11 * B_r{e}(ir, jr) ...
                                    + (C11 / r_val) * A_r{e}(ir, jr);
                if ir == jr
                    K_M(eq_r, col_u) = K_M(eq_r, col_u) - C22 / (r_val^2);
                end
            end
            for jz = 1:N_z
                col_u = idx_U(e, ir, jz);
                K_M(eq_r, col_u) = K_M(eq_r, col_u) + C55 * B_z(iz, jz);
            end
            % عبارات w
            for jz = 1:N_z
                col_w = idx_W(e, ir, jz);
                K_M(eq_r, col_w) = K_M(eq_r, col_w) + (C13 - C23)/r_val * A_z(iz, jz);
            end
            for jr = 1:N_r
                for jz = 1:N_z
                    col_w = idx_W(e, jr, jz);
                    K_M(eq_r, col_w) = K_M(eq_r, col_w) + (C13 + C55) * A_r{e}(ir, jr) * A_z(iz, jz);
                end
            end
            % سمت راست حرارتی (r)
            DeltaT = T_layer{e}(ir, iz) - T_ref;
            dTdr = 0;
            for jr = 1:N_r
                dTdr = dTdr + A_r{e}(ir, jr) * T_layer{e}(jr, iz);
            end
            F_M(eq_r) = (C11 + C12 + C13) * alpha_node{e}(ir) * dTdr;
            
            % ---- معادله در راستای z (67-3) ----
            eq_z = idx_W(e, ir, iz);
            % عبارات w
            for jr = 1:N_r
                col_w = idx_W(e, jr, iz);
                K_M(eq_z, col_w) = K_M(eq_z, col_w) + C55 * B_r{e}(ir, jr) ...
                                    + (C55 / r_val) * A_r{e}(ir, jr);
            end
            for jz = 1:N_z
                col_w = idx_W(e, ir, jz);
                K_M(eq_z, col_w) = K_M(eq_z, col_w) + C33 * B_z(iz, jz);
            end
            % عبارات u
            for jz = 1:N_z
                col_u = idx_U(e, ir, jz);
                K_M(eq_z, col_u) = K_M(eq_z, col_u) + (C23 + C55)/r_val * A_z(iz, jz);
            end
            for jr = 1:N_r
                for jz = 1:N_z
                    col_u = idx_U(e, jr, jz);
                    K_M(eq_z, col_u) = K_M(eq_z, col_u) + (C13 + C55) * A_r{e}(ir, jr) * A_z(iz, jz);
                end
            end
            % سمت راست حرارتی (z)
            dTdz = 0;
            for jz = 1:N_z
                dTdz = dTdz + A_z(iz, jz) * T_layer{e}(ir, jz);
            end
            F_M(eq_z) = (C13 + C23 + C33) * alpha_node{e}(ir) * dTdz;
        end
    end
end

%% ============================================================
%  Mechanical Interface Continuity (Between Layers)
%  Added at: After internal mechanical assembly, Before BCs
%% ============================================================
disp('Applying mechanical interface continuity conditions...');

for e = 1:NL-1
    % مرز مشترک بین لایه e و e+1
    % برای تمام نقاط محوری iz
    for iz = 1:N_z
        % تعری�? سطرهای معادله (است�?اده از معادلات لایه e در مرز r=Ro)
        row_u = idx_U(e, N_r, iz);
        row_w = idx_W(e, N_r, iz);
        row_s = idx_U(e+1, 1, iz); % شرط تنش شعاعی (برای لایه e+1 در Ri)
        row_t = idx_W(e+1, 1, iz); % شرط تنش برشی (برای لایه e+1 در Ri)
        
        % 1. پیوستگی جابجایی شعاعی: U_e = U_{e+1}
        K_M(row_u, :) = 0; F_M(row_u) = 0;
        K_M(row_u, idx_U(e, N_r, iz)) = 1;
        K_M(row_u, idx_U(e+1, 1, iz)) = -1;
        
        % 2. پیوستگی جابجایی محوری: W_e = W_{e+1}
        K_M(row_w, :) = 0; F_M(row_w) = 0;
        K_M(row_w, idx_W(e, N_r, iz)) = 1;
        K_M(row_w, idx_W(e+1, 1, iz)) = -1;
        
        % استخراج ضرایب برای تنش (در دو سمت مرز)
        E_l = E_node{e}(N_r); nu_l = nu_node{e}(N_r);
        C11_l = (1-nu_l)*E_l/((1+nu_l)*(1-2*nu_l)); C12_l = nu_l*E_l/((1+nu_l)*(1-2*nu_l)); C13_l = C12_l; C55_l = E_l/(2*(1+nu_l));
        
        E_r = E_node{e+1}(1); nu_r = nu_node{e+1}(1);
        C11_r = (1-nu_r)*E_r/((1+nu_r)*(1-2*nu_r)); C12_r = nu_r*E_r/((1+nu_r)*(1-2*nu_r)); C13_r = C12_r; C55_r = E_r/(2*(1+nu_r));
        
        r_b = R_boundaries(e+1);
        
        % 3. پیوستگی تنش شعاعی: Sigma_rr_l = Sigma_rr_r
        K_M(row_s, :) = 0; F_M(row_s) = 0;
        for jr = 1:N_r
            K_M(row_s, idx_U(e, jr, iz)) = C11_l * A_r{e}(N_r, jr);
            K_M(row_s, idx_U(e+1, jr, iz)) = -C11_r * A_r{e+1}(1, jr);
        end
        K_M(row_s, idx_U(e, N_r, iz)) = K_M(row_s, idx_U(e, N_r, iz)) + C12_l / r_b;
        K_M(row_s, idx_U(e+1, 1, iz)) = K_M(row_s, idx_U(e+1, 1, iz)) - C12_r / r_b;
        for jz = 1:N_z
            K_M(row_s, idx_W(e, N_r, jz)) = C13_l * A_z(iz, jz);
            K_M(row_s, idx_W(e+1, 1, jz)) = -C13_r * A_z(iz, jz);
        end
        
        % 4. پیوستگی تنش برشی: Tau_rz_l = Tau_rz_r
        K_M(row_t, :) = 0; F_M(row_t) = 0;
        for jz = 1:N_z
            K_M(row_t, idx_U(e, N_r, jz)) = C55_l * A_z(iz, jz);
            K_M(row_t, idx_U(e+1, 1, jz)) = -C55_r * A_z(iz, jz);
        end
        for jr = 1:N_r
            K_M(row_t, idx_W(e, jr, iz)) = C55_l * A_r{e}(N_r, jr);
            K_M(row_t, idx_W(e+1, jr, iz)) = -C55_r * A_r{e+1}(1, jr);
        end
    end
end

%% ============================================================
%  Mechanical Boundary Conditions - Corrected Version
%  Apply after assembling internal mechanical equations
%% ============================================================

% ------------------------------------------------------------
% 1) z = 0 and z = L
% For free axial ends:
% tau_rz = 0
% sigma_zz = 0
%
% Important:
% Apply only for internal radial points:
% ir = 2 : N_r-1
% Do not apply at radial corners.
% ------------------------------------------------------------

for e = 1:NL

    for ir = 2:N_r-1

        r_val = r_nodes{e}(ir);

        E_val  = E_node{e}(ir);
        nu_val = nu_node{e}(ir);

        C11 = (1-nu_val)*E_val / ((1+nu_val)*(1-2*nu_val));
        C12 = nu_val*E_val     / ((1+nu_val)*(1-2*nu_val));
        C13 = C12;
        C22 = C11;
        C23 = C12;
        C33 = C11;
        C55 = E_val / (2*(1+nu_val));

        for iz = [1, N_z]

            % =================================================
            % tau_rz = C55 * (du/dz + dw/dr) = 0
            % Use U-row
            % =================================================

            row_tau = idx_U(e, ir, iz);

            K_M(row_tau, :) = 0;
            F_M(row_tau) = 0;

            % du/dz term
            for jz = 1:N_z
                col_u = idx_U(e, ir, jz);
                K_M(row_tau, col_u) = K_M(row_tau, col_u) + C55 * A_z(iz, jz);
            end

            % dw/dr term
            for jr = 1:N_r
                col_w = idx_W(e, jr, iz);
                K_M(row_tau, col_w) = K_M(row_tau, col_w) + C55 * A_r{e}(ir, jr);
            end


            % =================================================
            % sigma_zz = C13 du/dr + C23 u/r + C33 dw/dz
            %            - thermal_part = 0
            % Use W-row
            % =================================================

            row_sig = idx_W(e, ir, iz);

            K_M(row_sig, :) = 0;

            % C13 du/dr
            for jr = 1:N_r
                col_u = idx_U(e, jr, iz);
                K_M(row_sig, col_u) = K_M(row_sig, col_u) + C13 * A_r{e}(ir, jr);
            end

            % C23 u/r
            col_u_center = idx_U(e, ir, iz);
            K_M(row_sig, col_u_center) = K_M(row_sig, col_u_center) + C23 / r_val;

            % C33 dw/dz
            for jz = 1:N_z
                col_w = idx_W(e, ir, jz);
                K_M(row_sig, col_w) = K_M(row_sig, col_w) + C33 * A_z(iz, jz);
            end

            % thermal term
            DeltaT = T_layer{e}(ir, iz) - T_ref;
            alpha_val = alpha_node{e}(ir);

            F_M(row_sig) = (C13 + C23 + C33) * alpha_val * DeltaT;

        end
    end
end


% ------------------------------------------------------------
% 2) Inner radial surface r = Ri
% sigma_rr = -P_i
%
% Apply on U-row for all z-points.
% ------------------------------------------------------------

e  = 1;
ir = 1;

r_val = r_nodes{e}(ir);

E_val  = E_node{e}(ir);
nu_val = nu_node{e}(ir);

C11 = (1-nu_val)*E_val / ((1+nu_val)*(1-2*nu_val));
C12 = nu_val*E_val     / ((1+nu_val)*(1-2*nu_val));
C13 = C12;

for iz = 1:N_z

    row_sig = idx_U(e, ir, iz);

    K_M(row_sig, :) = 0;

    % sigma_rr = C11 du/dr + C12 u/r + C13 dw/dz - thermal
    % C11 du/dr
    for jr = 1:N_r
        col_u = idx_U(e, jr, iz);
        K_M(row_sig, col_u) = K_M(row_sig, col_u) + C11 * A_r{e}(ir, jr);
    end

    % C12 u/r
    col_u_center = idx_U(e, ir, iz);
    K_M(row_sig, col_u_center) = K_M(row_sig, col_u_center) + C12 / r_val;

    % C13 dw/dz
    for jz = 1:N_z
        col_w = idx_W(e, ir, jz);
        K_M(row_sig, col_w) = K_M(row_sig, col_w) + C13 * A_z(iz, jz);
    end

    DeltaT = T_layer{e}(ir, iz) - T_ref;
    alpha_val = alpha_node{e}(ir);

    % sigma_rr = -P_i
    F_M(row_sig) = -P_i + (C11 + C12 + C13) * alpha_val * DeltaT;

end


% ------------------------------------------------------------
% 3) Outer radial surface r = Ro
% sigma_rr = 0
%
% Apply on U-row for all z-points.
% ------------------------------------------------------------

e  = NL;
ir = N_r;

r_val = r_nodes{e}(ir);

E_val  = E_node{e}(ir);
nu_val = nu_node{e}(ir);

C11 = (1-nu_val)*E_val / ((1+nu_val)*(1-2*nu_val));
C12 = nu_val*E_val     / ((1+nu_val)*(1-2*nu_val));
C13 = C12;

for iz = 1:N_z

    row_sig = idx_U(e, ir, iz);

    K_M(row_sig, :) = 0;

    % sigma_rr = C11 du/dr + C12 u/r + C13 dw/dz - thermal
    % C11 du/dr
    for jr = 1:N_r
        col_u = idx_U(e, jr, iz);
        K_M(row_sig, col_u) = K_M(row_sig, col_u) + C11 * A_r{e}(ir, jr);
    end

    % C12 u/r
    col_u_center = idx_U(e, ir, iz);
    K_M(row_sig, col_u_center) = K_M(row_sig, col_u_center) + C12 / r_val;

    % C13 dw/dz
    for jz = 1:N_z
        col_w = idx_W(e, ir, jz);
        K_M(row_sig, col_w) = K_M(row_sig, col_w) + C13 * A_z(iz, jz);
    end

    DeltaT = T_layer{e}(ir, iz) - T_ref;
    alpha_val = alpha_node{e}(ir);

    % sigma_rr = 0
    F_M(row_sig) = (C11 + C12 + C13) * alpha_val * DeltaT;

end


% ------------------------------------------------------------
% 4) Inner and outer radial surfaces
% tau_rz = 0
%
% Apply only for internal z-points:
% iz = 2 : N_z-1
%
% Use W-row.
% ------------------------------------------------------------

for iz = 2:N_z-1

    % ========================================================
    % Inner surface r = Ri
    % ========================================================

    e  = 1;
    ir = 1;

    E_val  = E_node{e}(ir);
    nu_val = nu_node{e}(ir);
    C55 = E_val / (2*(1+nu_val));

    row_tau = idx_W(e, ir, iz);

    K_M(row_tau, :) = 0;
    F_M(row_tau) = 0;

    % tau_rz = C55 * (du/dz + dw/dr)

    % du/dz
    for jz = 1:N_z
        col_u = idx_U(e, ir, jz);
        K_M(row_tau, col_u) = K_M(row_tau, col_u) + C55 * A_z(iz, jz);
    end

    % dw/dr
    for jr = 1:N_r
        col_w = idx_W(e, jr, iz);
        K_M(row_tau, col_w) = K_M(row_tau, col_w) + C55 * A_r{e}(ir, jr);
    end


    % ========================================================
    % Outer surface r = Ro
    % ========================================================

    e  = NL;
    ir = N_r;

    E_val  = E_node{e}(ir);
    nu_val = nu_node{e}(ir);
    C55 = E_val / (2*(1+nu_val));

    row_tau = idx_W(e, ir, iz);

    K_M(row_tau, :) = 0;
    F_M(row_tau) = 0;

    % du/dz
    for jz = 1:N_z
        col_u = idx_U(e, ir, jz);
        K_M(row_tau, col_u) = K_M(row_tau, col_u) + C55 * A_z(iz, jz);
    end

    % dw/dr
    for jr = 1:N_r
        col_w = idx_W(e, jr, iz);
        K_M(row_tau, col_w) = K_M(row_tau, col_w) + C55 * A_r{e}(ir, jr);
    end

end


% ------------------------------------------------------------
% 5) Remove rigid body axial motion
%
% Important:
% Do NOT fix radial displacement u.
% Only fix one axial displacement w.
% ------------------------------------------------------------

e_fix  = 1;
ir_fix = round(N_r/2);
iz_fix = round(N_z/2);

row_fix = idx_W(e_fix, ir_fix, iz_fix);

K_M(row_fix, :) = 0;
K_M(row_fix, row_fix) = 1;
F_M(row_fix) = 0;

%% ============================================================
%  Scaling and solving mechanical system
%% ============================================================

disp('---------------------------------------------');
disp('Mechanical matrix check before scaling');

rank_K = rank(full(K_M));
size_K = size(K_M,1);
zero_rows = find(all(abs(K_M) < 1e-14, 2));

disp(['Rank of full(K_M): ', num2str(rank_K)]);
disp(['Size of K_M: ', num2str(size_K)]);
disp(['Number of zero rows: ', num2str(length(zero_rows))]);

try
    cond_K = condest(K_M);
    disp(['Condition number estimate of K_M: ', num2str(cond_K)]);
catch
    disp('condest failed for K_M.');
end

% Row scaling
rowNorm = full(max(abs(K_M), [], 2));
rowNorm(rowNorm == 0) = 1;

S = spdiags(1 ./ rowNorm, 0, size(K_M,1), size(K_M,1));

K_scaled = S * K_M;
F_scaled = S * F_M;

disp('---------------------------------------------');
disp('Mechanical matrix check after scaling');

rank_Ks = rank(full(K_scaled));
zero_rows_s = find(all(abs(K_scaled) < 1e-14, 2));

disp(['Rank of full(K_scaled): ', num2str(rank_Ks)]);
disp(['Size of K_scaled: ', num2str(size(K_scaled,1))]);
disp(['Number of zero rows scaled: ', num2str(length(zero_rows_s))]);

try
    cond_Ks = condest(K_scaled);
    disp(['Condition number estimate of K_scaled: ', num2str(cond_Ks)]);
catch
    disp('condest failed for K_scaled.');
end

disp('---------------------------------------------');

if rank_Ks < size(K_scaled,1)
    warning('K_scaled is still rank deficient. Check boundary conditions.');
end

% Solve
U_global = K_scaled \ F_scaled;

%% ========================= 7. محاسبه تنش‌ها =========================
% تنش‌های شعاعی (rr)، محیطی (θθ)، محوری (zz) و برشی (rz)
Stress_rr = cell(NL,1);
Stress_tt = cell(NL,1);
Stress_zz = cell(NL,1);
Tau_rz = cell(NL,1);

%% ============================================================
%  Extract U and W fields from global solution vector
%% ============================================================

U_layer = cell(NL,1);
W_layer = cell(NL,1);

for e = 1:NL

    Ue = zeros(N_r, N_z);
    We = zeros(N_r, N_z);

    for ir = 1:N_r
        for iz = 1:N_z

            Ue(ir, iz) = U_global(idx_U(e, ir, iz));
            We(ir, iz) = U_global(idx_W(e, ir, iz));

        end
    end

    U_layer{e} = Ue;
    W_layer{e} = We;

end

for e = 1:NL
    N_r_local = N_r;
    Stress_rr{e} = zeros(N_r_local, N_z);
    Stress_tt{e} = zeros(N_r_local, N_z);
    Stress_zz{e} = zeros(N_r_local, N_z);
    Tau_rz{e} = zeros(N_r_local, N_z);
    for ir = 1:N_r_local
        r_val = r_nodes{e}(ir);
        E_val = E_node{e}(ir);
        nu_val = nu_node{e}(ir);
        C11 = (1-nu_val)*E_val / ((1+nu_val)*(1-2*nu_val));
        C12 = nu_val*E_val / ((1+nu_val)*(1-2*nu_val));
        C13 = C12;
        C33 = C11;
        C55 = E_val / (2*(1+nu_val));
        for iz = 1:N_z
            % مشتقات جابجایی
            du_dr = 0; dw_dr = 0; du_dz = 0; dw_dz = 0;
            for jr = 1:N_r_local
                du_dr = du_dr + A_r{e}(ir, jr) * U_layer{e}(jr, iz);
                dw_dr = dw_dr + A_r{e}(ir, jr) * W_layer{e}(jr, iz);
            end
            for jz = 1:N_z
                du_dz = du_dz + A_z(iz, jz) * U_layer{e}(ir, jz);
                dw_dz = dw_dz + A_z(iz, jz) * W_layer{e}(ir, jz);
            end
            eps_rr = du_dr;
            eps_tt = U_layer{e}(ir, iz) / r_val;
            eps_zz = dw_dz;
            gamma_rz = du_dz + dw_dr;
            eps_th = alpha_node{e}(ir) * (T_layer{e}(ir, iz) - T_ref);
            % تنش‌ها
            Stress_rr{e}(ir, iz) = C11*(eps_rr - eps_th) + C12*(eps_tt - eps_th) + C13*(eps_zz - eps_th);
            Stress_tt{e}(ir, iz) = C12*(eps_rr - eps_th) + C11*(eps_tt - eps_th) + C13*(eps_zz - eps_th);
            Stress_zz{e}(ir, iz) = C13*(eps_rr - eps_th) + C13*(eps_tt - eps_th) + C33*(eps_zz - eps_th);
            Tau_rz{e}(ir, iz) = C55 * gamma_rz;
        end
    end
end

%% ========================= 8. نمایش نتایج (در مقطع میانی طول) =========================
z_mid = round(N_z/2);
figure('Name', 'Results at mid-length (z = L/2)');

for e = 1:NL
    r_plot = r_nodes{e};
    subplot(2,3,1);
    plot(r_plot, T_layer{e}(:,z_mid), 'o-', 'LineWidth', 1.5); hold on;
    xlabel('r (m)'); ylabel('Temperature (K)'); title('Temperature');
    
    subplot(2,3,2);
    plot(r_plot, U_layer{e}(:,z_mid)*1e6, 'o-', 'LineWidth', 1.5); hold on;
    xlabel('r (m)'); ylabel('U (μm)'); title('Radial displacement');
    
    subplot(2,3,3);
    plot(r_plot, W_layer{e}(:,z_mid)*1e6, 'o-', 'LineWidth', 1.5); hold on;
    xlabel('r (m)'); ylabel('W (μm)'); title('Axial displacement');
    
    subplot(2,3,4);
    plot(r_plot, Stress_rr{e}(:,z_mid)/1e6, 'o-', 'LineWidth', 1.5); hold on;
    xlabel('r (m)'); ylabel('\sigma_{rr} (MPa)'); title('Radial stress');
    
    subplot(2,3,5);
    plot(r_plot, Stress_tt{e}(:,z_mid)/1e6, 'o-', 'LineWidth', 1.5); hold on;
    xlabel('r (m)'); ylabel('\sigma_{\theta\theta} (MPa)'); title('Hoop stress');
    
    subplot(2,3,6);
    plot(r_plot, Tau_rz{e}(:,z_mid)/1e6, 'o-', 'LineWidth', 1.5); hold on;
    xlabel('r (m)'); ylabel('\tau_{rz} (MPa)'); title('Shear stress');
end
legend(arrayfun(@(x) sprintf('Layer %d',x), 1:NL, 'UniformOutput', false), 'Location', 'best');

disp('=== Layer-wise effective properties ===');
for e = 1:NL
    fprintf('Layer %d:\n', e);
    fprintf('  E range      = [%g, %g] Pa\n', min(E_node{e}), max(E_node{e}));
    fprintf('  nu range     = [%g, %g]\n', min(nu_node{e}), max(nu_node{e}));
    fprintf('  rho range    = [%g, %g] kg/m^3\n', min(rho_node{e}), max(rho_node{e}));
    fprintf('  k range      = [%g, %g] W/mK\n', min(k_node{e}), max(k_node{e}));
    fprintf('  alpha range  = [%g, %g] 1/K\n', min(alpha_node{e}), max(alpha_node{e}));
end

%% =========================  توابع کمکی (در انتهای �?ایل) =========================

function x = chebyshev_grid(a, b, N)
% تولید نقاط چبیش�? در بازه [a, b]
    x = a + (b-a)/2 * (1 - cos(pi*(0:N-1)/(N-1)));
end

function [A, B] = DQ_weights(x)
    N = length(x);
    A = zeros(N,N);

    for i = 1:N
        for j = 1:N
            if i ~= j
                num = 1; 
                den = 1;
                for k = 1:N
                    if k ~= i && k ~= j
                        num = num * (x(i) - x(k));
                        den = den * (x(j) - x(k));
                    end
                end
                A(i,j) = num / (den * (x(j)-x(i)));
            end
        end
    end

    for i = 1:N
        A(i,i) = -sum(A(i,:));
    end

    % مشتق دوم پایدارتر
    B = A * A;
end



