%% claude_pattern_gradient_schematics_R2.m — GPL & porosity patterns as gradient-shaded layer wedges (R2)
%  Revision of claude_pattern_gradient_schematics.m (kept frozen). Author
%  request (2026-08-29): in the porosity V/A pattern formulas, leading
%  coefficient 2 -> 1 (Pm.V, Pm.A); denominator inside cos(...) kept at 2
%  (unchanged). Per the project's revision-number rule, output saved as a
%  NEW file (porosity_pattern_gradient_R2.png) alongside R1's original
%  (porosity_pattern_gradient.png, coefficient=2) — not overwriting it.
%  The GPL gradient figure is unaffected by this change and still writes
%  to its original filename.
%  ------------------------------------------------------------------------
%  Shows the five GPL and five porosity distribution patterns as a
%  GRADIENT — a quarter-annulus divided into the 7 concentric layer bands,
%  each band shaded by its actual intensity, darkest = most graphene / most
%  porous, lightest = least. Style matches the convention in Rezaei's MSc
%  thesis (same university, same UD/X/O/V pattern family; Fig. 2-3, p.17)
%  and the cited FGM literature, extended here to all 5 patterns (UD/O/X/V/A)
%  used in this thesis. No curves/axes-plots.
%  Same reference geometry/formulas as claude_ch123_figs.m (frozen source):
%  Ri=1.0, Ro=1.5, NL=7, W=0.3%, em3=0.8980. Evaluated at the 7 LAYER
%  MIDPOINTS (discrete bands) rather than the continuous curve used for the
%  line-plot schematics.
clearvars; clc; close all;
outdir = 'C:/Users/InfosaicUser/Desktop/MSc/Lord-Shulman-theory-thermoelastic-cylinder/claude/figures_ch123';
if ~exist(outdir,'dir'), mkdir(outdir); end
try
    set(groot,'defaultAxesFontName','Times New Roman');
    set(groot,'defaultTextFontName','Times New Roman');
catch
end

%% ---- reference geometry (frozen, matches claude_ch123_figs.m) ----
Ri = 1.0; Ro = 1.5; hth = 0.5; NL = 7;
Rb = Ri + (0:NL)*(hth/NL);                 % 8 interface radii, layer e spans Rb(e):Rb(e+1)
pat = {'UD','O','X','V','A'};

%% ---- GPL weight fraction per layer (frozen formulas) ----
W = 0.003; e = (1:NL)'; hlf = (NL+1)/2;
Wg.UD = W*ones(NL,1);
Wg.O  = 4*W*((hlf) - abs(e-hlf))/(NL+2);
Wg.X  = 4*W*(0.5 + abs(e-hlf))/(NL+2);
Wg.V  = 2*W*e/(NL+1);
Wg.A  = 2*W*(NL+1-e)/(NL+1);

%% ---- porosity coefficient per layer (frozen formulas, evaluated at layer MIDPOINTS) ----
em3 = 0.8980; em1 = (pi/2)*(1-em3); em2 = (1-em3)/(1-2/pi); em4 = (pi/4)*em3; em5 = em4;
zlay = ((1:NL)'-4)/NL;                      % 7 layer-centre coords, same convention as claude_ch123_figs.m
Pm.UD = em3*ones(NL,1);
Pm.O  = 1 - em1*cos(pi*zlay);
Pm.X  = 1 - em2*(1 - cos(pi*zlay));
Pm.V  = 1*em4*cos(pi*zlay/2 + pi/4);
Pm.A  = 1*em5*cos(pi*zlay/2 - pi/4);
Pf.UD = Pm.UD.^2; Pf.O = Pm.O.^2; Pf.X = Pm.X.^2; Pf.V = Pm.V.^2; Pf.A = Pm.A.^2;

%% ---- draw porosity figure only (R2 change is porosity-only; GPL unaffected) ----
draw_gradient_set(Pf, pat, Rb, NL, [1 1 1], [0.15 0.15 0.15], ...
    'e^{(e)} = (P_m^{(e)})^2  (porosity coefficient)', 'porosity_pattern_gradient_R2.png', outdir);
disp('DONE: porosity_pattern_gradient_R2.png (R1''s porosity_pattern_gradient.png and GPL_pattern_gradient.png kept frozen/untouched)');

%% ---- helpers ----
function draw_gradient_set(Vals, pat, Rb, NL, colLo, colHi, cbarLabel, fname, outdir)
    % common color scale across all 5 panels so patterns are visually comparable
    allv = [Vals.UD; Vals.O; Vals.X; Vals.V; Vals.A];
    vlo = min(allv); vhi = max(allv);
    fig = figure('Units','inches','Position',[1 1 13 8],'Color','w');
    for pi_ = 1:5
        subplot(2,3,pi_);
        v = Vals.(pat{pi_});
        draw_wedge(Rb, NL, v, vlo, vhi, colLo, colHi);
        title(pat{pi_},'FontSize',13,'FontWeight','bold','FontName','Times New Roman');
    end
    % shared colorbar in the 6th grid slot
    subplot(2,3,6); axis off;
    cm = interp1([0 1], [colLo; colHi], linspace(0,1,256));
    colormap(gca, cm);
    cb = colorbar('Location','west'); clim([vlo vhi]);
    cb.Label.String = cbarLabel; cb.Label.FontSize = 11; cb.FontName = 'Times New Roman';
    print(fig, fullfile(outdir, fname), '-dpng', '-r300');
    savefig(fig, fullfile(outdir, strrep(fname,'.png','.fig')));
    close(fig);
    fprintf('done: %s\n', fname);
end

function draw_wedge(Rb, NL, v, vlo, vhi, colLo, colHi)
    hold on; axis equal off;
    th = linspace(0, pi/2, 60);                     % quarter-annulus, like Rezaei Fig. 2-3
    for e = 1:NL
        r1 = Rb(e); r2 = Rb(e+1);
        t = (v(e) - vlo) / max(vhi - vlo, eps);      % 0..1
        col = colLo + t*(colHi - colLo);
        xo = r2*cos(th); yo = r2*sin(th);
        xi_ = r1*cos(fliplr(th)); yi_ = r1*sin(fliplr(th));
        patch([xo xi_], [yo yi_], col, 'EdgeColor',[1 1 1], 'LineWidth', 0.75);
    end
    % thin outer/inner boundary for clarity
    plot(Rb(end)*cos(th), Rb(end)*sin(th), 'k-', 'LineWidth', 1.1);
    plot(Rb(1)*cos(th), Rb(1)*sin(th), 'k-', 'LineWidth', 1.1);
    plot([0 0], [Rb(1) Rb(end)], 'k-', 'LineWidth', 1.1);
    plot([Rb(1) Rb(end)], [0 0], 'k-', 'LineWidth', 1.1);
    xlim([-0.05*Rb(end), Rb(end)*1.05]); ylim([-0.05*Rb(end), Rb(end)*1.05]);
end
