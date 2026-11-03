%% pattern_gradient_schematics_R9.m — GPL pattern gradient figure, teal-green colour variant
%  R9 (2026-11-03, author request): same figure as R8 in another colour (white -> dark teal-green instead of white -> dark blue).
%  Layout, margins, formulas, titles identical to R8. Output: GPL_pattern_gradient_R7.png/.fig (R6 blue figure and scripts R1-R8 stay frozen).
%  ----- R8 header follows -----
%  R8 (2026-11-03, author request): R7 margins were too tight; column gap 0.10 -> 0.30 in, export padding 6 -> 70 px.
%  Everything else identical to R7. Output: GPL_pattern_gradient_R7.png/.fig (R1-R5 figures and scripts R1-R7 stay frozen).
%  ----- R7 header follows -----
%  R7 (2026-11-03, author request): outer margins and the gaps between panels are cut to a minimum.
%  Canvas shrunk from 13x8 in to 9.6x6.8 in with square panels placed by hand (no subplot grid);
%  bottom row (V, A) still centred under the top row. Panels, colours, formulas, titles unchanged from R6.
%  Output: GPL_pattern_gradient_R5.png/.fig (R1-R4 files and scripts R1-R6 stay frozen).
%  ----- R6 header follows -----
%% pattern_gradient_schematics_R6.m — GPL pattern gradient figure, bottom row centred
%  R6 (2026-11-03, author request): the two bottom panels (V and A) are moved from the left to the
%  centre of the figure (shifted right by half a column pitch, so they sit between the columns of
%  the top row). Panels, colours, formulas and canvas unchanged from R5. Output: GPL_pattern_gradient_R4.png/.fig
%  (R1-R3 files and scripts R1-R5 stay frozen).
%  ----- R5 header follows -----
%% pattern_gradient_schematics_R5.m — GPL pattern gradient figure, V and A swapped
%  R5 (2026-10-13, author request) revises R4: the V and A patterns are swapped.
%  The old A pattern (most graphene at the INNER surface) is now drawn as V, and the
%  old V pattern (most graphene at the OUTER surface) is now drawn as A, so that V =
%  graphene concentrated at the inner surface and A = at the outer surface, as the
%  thesis text and results describe them. UD, O and X are unchanged.
%  Like R4: no colour bar (legend deleted), same colour scale.
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
colLo = [1 1 1]; colHi = [0.00 0.30 0.26];   % R9: teal-green (R8: blue [0.03 0.19 0.42])
allv = [Wg.UD; Wg.O; Wg.X; Wg.V; Wg.A];
vlo = min(allv); vhi = max(allv);
% R7: panels placed by hand (inches) so margins and gaps are minimal
sd = 3.0; gx = 0.30; ty = 0.30; m = 0.05;            % panel side, column gap, title room, outer margin
Wf = 3*sd + 2*gx + 2*m; Hf = 2*(sd+ty) + 2*m;
fig = figure('Units','inches','Position',[1 1 Wf Hf],'Color','w');
x0 = [m, m+sd+gx, m+2*(sd+gx), m+(sd+gx)/2, m+1.5*(sd+gx)];   % bottom row = half-pitch shift (centred)
y0 = [m+sd+ty, m+sd+ty, m+sd+ty, m, m];
for pi_ = 1:5
    ax = axes('Units','inches','Position',[x0(pi_) y0(pi_) sd sd]); %#ok<LAXES>
    draw_wedge(Rb, NL, Wg.(pat{pi_}), vlo, vhi, colLo, colHi);
    title(pat{pi_},'FontSize',13,'FontWeight','bold','FontName','Times New Roman');
end
exportgraphics(fig, fullfile(outdir,'GPL_pattern_gradient_R7.png'), 'Resolution',300, 'Padding',70);
savefig(fig, fullfile(outdir,'GPL_pattern_gradient_R7.fig'));
close(fig);
disp('DONE: GPL_pattern_gradient_R7.png (R1-R6 files kept frozen)');

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
