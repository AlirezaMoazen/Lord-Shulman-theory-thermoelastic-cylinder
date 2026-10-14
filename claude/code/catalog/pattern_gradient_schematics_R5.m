%% pattern_gradient_schematics_R5.m — GPL pattern gradient figure, V and A swapped
%  R5 (2026-10-13, author request) revises R4: the V and A patterns are swapped.
%  The old A pattern (most graphene at the INNER surface) is now drawn as V, and the
%  old V pattern (most graphene at the OUTER surface) is now drawn as A, so that V =
%  graphene concentrated at the inner surface and A = at the outer surface, as the
%  thesis text and results describe them. UD, O and X are unchanged.
%  Like R4: no colour bar (legend deleted), same colour scale, 13x8 in canvas, 2x3 grid.
%  Output goes to NEW files GPL_pattern_gradient_R3.png/.fig; GPL_pattern_gradient.png (R1)
%  and GPL_pattern_gradient_R2.png (R4 script) and scripts R1-R4 are kept frozen.
%  Same reference geometry: Ri=1.0, Ro=1.5, NL=7, W=0.3%.
clearvars; clc; close all;
outdir = 'C:/Users/InfosaicUser/Desktop/MSc/Lord-Shulman-theory-thermoelastic-cylinder/claude/figures_ch123';
if ~exist(outdir,'dir'), mkdir(outdir); end
try
    set(groot,'defaultAxesFontName','Times New Roman');
    set(groot,'defaultTextFontName','Times New Roman');
catch
end

%% ---- reference geometry (frozen) ----
Ri = 1.0; Ro = 1.5; hth = 0.5; NL = 7;
Rb = Ri + (0:NL)*(hth/NL);                 % 8 interface radii, layer e spans Rb(e):Rb(e+1)
pat = {'UD','O','X','V','A'};

%% ---- GPL weight fraction per layer (frozen formulas) ----
W = 0.003; e = (1:NL)'; hlf = (NL+1)/2;
Wg.UD = W*ones(NL,1);
Wg.O  = 4*W*((hlf) - abs(e-hlf))/(NL+2);
Wg.X  = 4*W*(0.5 + abs(e-hlf))/(NL+2);
Wg.V  = 2*W*(NL+1-e)/(NL+1);   % R5: was the old A formula
Wg.A  = 2*W*e/(NL+1);               % R5: was the old V formula

%% ---- draw: same colour scale as R1, no colour bar ----
colLo = [1 1 1]; colHi = [0.03 0.19 0.42];
allv = [Wg.UD; Wg.O; Wg.X; Wg.V; Wg.A];
vlo = min(allv); vhi = max(allv);
fig = figure('Units','inches','Position',[1 1 13 8],'Color','w');
for pi_ = 1:5
    subplot(2,3,pi_);
    draw_wedge(Rb, NL, Wg.(pat{pi_}), vlo, vhi, colLo, colHi);
    title(pat{pi_},'FontSize',13,'FontWeight','bold','FontName','Times New Roman');
end
print(fig, fullfile(outdir,'GPL_pattern_gradient_R3.png'), '-dpng', '-r300');
savefig(fig, fullfile(outdir,'GPL_pattern_gradient_R3.fig'));
close(fig);
disp('DONE: GPL_pattern_gradient_R3.png (R1 and R2 files kept frozen)');

%% ---- helper (unchanged from R1-R3) ----
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
