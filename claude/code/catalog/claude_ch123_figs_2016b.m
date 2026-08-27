%% ========================================================================
%  claude_ch123_figs_2016b.m  —  SCHEMATIC FIGURES FOR CHAPTERS 2-3
%  ------------------------------------------------------------------------
%  MATLAB R2016b-COMPATIBLE VARIANT of claude_ch123_figs.m. Identical output
%  (same 6 PNGs, same data/formulas) — only two functions unavailable before
%  R2016b/R2020a were swapped for older equivalents:
%    * exportgraphics(fig,path,'Resolution',300)  ->  print(fig,path,'-dpng','-r300')
%    * yline(y,...)                                ->  plot(xlim,[y y],...)
%  Do not edit claude_ch123_figs.m to match this file or vice versa — keep
%  both in sync by hand if the figures change (no-rewrite rule).
%  ------------------------------------------------------------------------
%  Generates the 6 schematic PNGs referenced by the [شکل: ...] markers in the
%  Persian thesis chapters 2-3 (and one taxonomy figure for chapter 2).
%  All figure text is in ENGLISH (MATLAB renders RTL/Persian unreliably).
%
%  Ground-truth formulas taken from the FROZEN solver claude_R7.m:
%    * GPL weight-fraction patterns  (switch upper(GPL_pattern), lines 315-322)
%    * porosity mass-factor patterns (switch upper(porosity_pattern), 350-357)
%      with coefficients em1..em5 (lines 294-297) and centered coord zet.
%    * CGL grid: chebyshev_grid = a + (b-a)/2*(1-cos(pi*(0:N-1)/(N-1)))  (1058)
%
%  Aesthetic matches the finalized chapter-4 figures (claude_param_figures_R4):
%  Times New Roman, solid clean lines, distinct colours AND line-styles/markers
%  (grayscale-legible), legends, axis labels, no redundant super-title.
%  ========================================================================
clearvars; clc; close all;

outdir = 'C:/Users/InfosaicUser/Desktop/MSc/Lord-Shulman-theory-thermoelastic-cylinder/claude/figures_ch123';
if ~exist(outdir,'dir'), mkdir(outdir); end
NLc = char(10); %#ok<CHARTEN>  % real newline for multi-line text objects

% ---- global style ----
try
    set(groot,'defaultAxesFontName','Times New Roman');
    set(groot,'defaultTextFontName','Times New Roman');
    set(groot,'defaultLegendFontName','Times New Roman');
catch
end
CO = {[0 0.447 0.741],[0.850 0.325 0.098],[0.929 0.694 0.125],...
      [0.494 0.184 0.556],[0.466 0.674 0.188]};   % chapter-4 colour table
LS = {'-','--',':','-.','-'};                      % B&W-distinguishable
MK = {'o','s','^','d','v'};
FSZ = 11;

% ---- canonical geometry ----
Ri = 1.0; Ro = 1.5; hth = 0.5; L = 2.1; NL = 7;
Rb = Ri + (0:NL)*(hth/NL);                          % 8 interface radii

%% ================================================================= FIG 1
%  geometry_schematic.png : (a) annular cross-section, (b) r-z domain
fig = figure('Units','inches','Position',[1 1 13 5.6],'Color','w');

% ---------- (a) cross-section ----------
ax1 = subplot(1,2,1); hold(ax1,'on'); axis(ax1,'equal'); axis(ax1,'off');
th = linspace(0,2*pi,400);
for k = 1:NL                                         % filled rings
    ro = Rb(k+1); ri = Rb(k);
    sh = 0.90 - 0.07*mod(k,2);
    patch([ro*cos(th) ri*cos(fliplr(th))],[ro*sin(th) ri*sin(fliplr(th))],...
          [sh sh sh],'EdgeColor','none');
end
for k = 1:NL+1                                        % interface circles
    lw = 0.5; if k==1||k==NL+1, lw = 1.6; end
    plot(Rb(k)*cos(th),Rb(k)*sin(th),'-','Color',[0.25 0.25 0.25],'LineWidth',lw);
end
na = 12; ang = linspace(0,2*pi,na+1); ang(end) = [];
qi = quiver(Ri*cos(ang),Ri*sin(ang),0.14*cos(ang),0.14*sin(ang),0,...   % inner load
       'Color',CO{2},'LineWidth',1.2,'MaxHeadSize',0.55,'DisplayName','inner: T_{in}(t) + P_i');
qo = quiver(Ro*cos(ang),Ro*sin(ang),0.11*cos(ang),0.11*sin(ang),0,...   % outer conv.
       'Color',CO{1},'LineWidth',1.0,'MaxHeadSize',0.55,'DisplayName','outer: convection h_c');
legend([qi(1) qo(1)],'Location','southoutside','Orientation','horizontal','FontSize',9,'Box','off');
xlim(ax1,[-(Ro+0.55) Ro+0.55]); ylim(ax1,[-(Ro+0.5) Ro+0.5]);

% ---------- (b) r-z computational domain ----------
ax2 = subplot(1,2,2); hold(ax2,'on'); box(ax2,'on');
for k = 1:NL                                          % layer bands
    sh = 0.90 - 0.07*mod(k,2);
    patch([0 L L 0],[Rb(k) Rb(k) Rb(k+1) Rb(k+1)],[sh sh sh],'EdgeColor','none');
end
for k = 1:NL+1
    lw = 0.5; if k==1||k==NL+1, lw = 1.4; end
    plot([0 L],[Rb(k) Rb(k)],'-','Color',[0.35 0.35 0.35],'LineWidth',lw);
end
plot([0 0],[Ri Ro],'k-','LineWidth',1.4);
plot([L L],[Ri Ro],'k-','LineWidth',1.4);
zc = linspace(0.12*L,0.88*L,5);
quiver(zc,Ri*ones(size(zc)),zeros(size(zc)),-0.07*ones(size(zc)),0,...
       'Color',CO{2},'LineWidth',1.1,'MaxHeadSize',0.45);
quiver(zc,Ro*ones(size(zc)),zeros(size(zc)), 0.07*ones(size(zc)),0,...
       'Color',CO{1},'LineWidth',1.1,'MaxHeadSize',0.45);
xlabel(ax2,'z  (m)','FontSize',FSZ); ylabel(ax2,'r  (m)','FontSize',FSZ);
set(ax2,'FontSize',10,'Layer','top');
xlim(ax2,[-0.17*L 1.17*L]); ylim(ax2,[Ri-0.20 Ro+0.20]);
print(fig,fullfile(outdir,'geometry_schematic.png'),'-dpng','-r300');
close(fig); fprintf('done: geometry_schematic.png\n');

%% ================================================================= FIG 2
%  GPL_patterns_schematic.png : W_GPL^(e) vs layer index, 5 patterns
W = 0.003;                                            % 0.3 % total (task spec)
e = (1:NL)';  hlf = (NL+1)/2;
Wg.UD = W*ones(NL,1);
Wg.O  = 4*W*((hlf) - abs(e-hlf))/(NL+2);
Wg.X  = 4*W*(0.5 + abs(e-hlf))/(NL+2);
Wg.V  = 2*W*e/(NL+1);
Wg.A  = 2*W*(NL+1-e)/(NL+1);
pat = {'UD','O','X','V','A'};

fig = figure('Units','inches','Position',[1 1 7 5],'Color','w'); hold on; box on;
for ci = 1:5
    plot(e, Wg.(pat{ci})*100,'LineStyle','-','Color',CO{ci},'LineWidth',1.8,...
         'Marker',MK{ci},'MarkerSize',7,'MarkerFaceColor','w');
end
grid on; set(gca,'FontSize',FSZ,'XTick',1:NL);
xlabel('layer index  e  ( 1 = inner  \rightarrow  7 = outer )','FontSize',FSZ);
ylabel('GPL weight fraction  W_{GPL}^{(e)}  (%)','FontSize',FSZ);
legend(pat,'Location','northoutside','Orientation','horizontal','FontSize',10);
xlim([0.7 NL+0.3]); ylim([0 0.62]);
print(fig,fullfile(outdir,'GPL_patterns_schematic.png'),'-dpng','-r300');
close(fig); fprintf('done: GPL_patterns_schematic.png\n');

%% ================================================================= FIG 3
%  porosity_patterns_schematic.png : mass-factor P_m vs xi, 5 patterns
%  EXACT reproduction of claude_R7.m switch upper(porosity_pattern) block.
em3 = 0.8980;                                         % solver default (e3=0.8064)
em1 = (pi/2)*(1-em3);
em2 = (1-em3)/(1-2/pi);
em4 = (pi/4)*em3;   em5 = em4;
zet = linspace(-0.5,0.5,400);                         % centered coord (fine)
xi  = zet + 0.5;                                      % through-thickness in [0,1]
Pm.UD = em3*ones(size(zet));
Pm.O  = 1 - em1*cos(pi*zet);
Pm.X  = 1 - em2*(1 - cos(pi*zet));
Pm.V  = 2*em4*cos(pi*zet/2 + pi/4);                   % max at INNER face
Pm.A  = 2*em5*cos(pi*zet/2 - pi/4);                   % max at OUTER face
% Porosity (stiffness-side) coefficient e = E/E_s = (rho/rhos)^2 = P_m^2
% (thesis eq. 3-39/3-40..3-44: e_i is the POROSITY coefficient, e_mi is the
% MASS coefficient; e = P_m^2 pointwise for every pattern). Plotted here
% instead of the mass factor P_m so the figure matches "porosity intensity"
% as used in the thesis text, not the mass-retention factor.
Pf.UD = Pm.UD.^2; Pf.O = Pm.O.^2; Pf.X = Pm.X.^2; Pf.V = Pm.V.^2; Pf.A = Pm.A.^2;
% NOTE: patterns plotted EXACTLY as the solver computes them (no clipping).
% The V/A formulas overshoot P_m>1 (so e=P_m^2>1) near their peak face —
% shown faithfully so the schematic represents the actual model (relevant
% to the A7 porosity review).
zlay = ((1:NL)-4)/NL;                                 % 7 layer-centre coords
xilay = zlay + 0.5;
mIdx = arrayfun(@(v) find(abs(xi-v)==min(abs(xi-v)),1), xilay);      % marker pos

fig = figure('Units','inches','Position',[1 1 7.4 5],'Color','w'); hold on; box on;
for ci = 1:5
    plot(xi, Pf.(pat{ci}),'LineStyle','-','Color',CO{ci},'LineWidth',1.8,...
         'Marker',MK{ci},'MarkerIndices',mIdx,'MarkerSize',7,'MarkerFaceColor','w');
end
grid on; set(gca,'FontSize',FSZ);
xlabel('\xi = (r-R_i)/h','FontSize',FSZ);
ylabel('porosity coefficient  e = E/E_s = (\rho/\rho_s)^2','FontSize',FSZ);
legend(pat,'Location','southoutside','Orientation','horizontal','FontSize',10);
xlim([0 1]); ylim([0 2.2]); plot(xlim,[1 1],'-','Color',[0.5 0.5 0.5],'HandleVisibility','off');
print(fig,fullfile(outdir,'porosity_patterns_schematic.png'),'-dpng','-r300');
close(fig); fprintf('done: porosity_patterns_schematic.png\n');

%% ================================================================= FIG 4
%  DQM_nodes_schematic.png : (a) radial CGL nodes/layer, (b) axial CGL nodes
%  N=9 used for both panels (illustrative point count, not the production
%  mesh N_r=15/N_z=11 used in the actual computations).
Nr = 9; Nz = 9;
cgl = @(a,b,N) a + (b-a)/2*(1 - cos(pi*(0:N-1)/(N-1)));
fig = figure('Units','inches','Position',[1 1 12 4.6],'Color','w');

% (a) radial
axr = subplot(1,2,1); hold(axr,'on'); box(axr,'on');
for k = 1:NL
    sh = 0.93 - 0.06*mod(k,2);
    patch([Rb(k) Rb(k+1) Rb(k+1) Rb(k)],[-0.5 -0.5 0.5 0.5],[sh sh sh],'EdgeColor','none');
end
for k = 1:NL+1
    lw = 0.6; if k==1||k==NL+1, lw = 1.4; end
    plot([Rb(k) Rb(k)],[-0.5 0.5],'-','Color',[0.35 0.35 0.35],'LineWidth',lw);
    if k<=NL, text((Rb(k)+Rb(k+1))/2,0.40,sprintf('L%d',k),'FontSize',8,...
            'HorizontalAlignment','center','Color',[0.3 0.3 0.3]); end
end
for k = 1:NL
    rn = cgl(Rb(k),Rb(k+1),Nr);
    plot(rn,zeros(size(rn)),'o','MarkerFaceColor',CO{1},'MarkerEdgeColor',CO{1},'MarkerSize',3.2);
end
set(axr,'YTick',[],'FontSize',10); xlim(axr,[Ri-0.012 Ro+0.012]); ylim(axr,[-0.78 0.62]);
xlabel(axr,'radial coordinate  r  (m)','FontSize',FSZ);

% (b) axial
axz = subplot(1,2,2); hold(axz,'on'); box(axz,'on');
patch([0 L L 0],[-0.5 -0.5 0.5 0.5],[0.94 0.94 0.94],'EdgeColor',[0.35 0.35 0.35]);
zn = cgl(0,L,Nz);
for j = 1:Nz, plot([zn(j) zn(j)],[-0.14 0.14],'-','Color',CO{4},'LineWidth',0.7); end
plot(zn,zeros(size(zn)),'s','MarkerFaceColor',CO{4},'MarkerEdgeColor',CO{4},'MarkerSize',5.5);
set(axz,'YTick',[],'FontSize',10); xlim(axz,[-0.04 L+0.04]); ylim(axz,[-0.78 0.62]);
xlabel(axz,'axial coordinate  z  (m)','FontSize',FSZ);
print(fig,fullfile(outdir,'DQM_nodes_schematic.png'),'-dpng','-r300');
close(fig); fprintf('done: DQM_nodes_schematic.png\n');

%% ================================================================= FIG 5
%  solution_flowchart.png : top-to-bottom algorithm flow (7 boxes)
steps = {
 ['Input: geometry, material,' NLc 'GPL & porosity patterns, BCs']
 ['Compute effective layer properties' NLc '(Halpin-Tsai + rule of mixtures' NLc '+ open-cell porosity)']
 ['Build CGL grid & DQM weight' NLc 'matrices (A, B) in r and z']
 ['Assemble mass [M], damping [C], stiffness [K]' NLc 'and load {f};  apply BCs' NLc '(N_{dof} = 3 N_L N_r N_z)']
 ['Row equilibration + LU' NLc 'factorization of effective matrix']
 ['Newmark time march ( \delta = 1/2, \beta = 1/4 )' NLc 't = 0 .. 3000 s,  \Deltat = 1 s']
 ['Post-process:  T^{*}, U^{*}, \Sigma^{*}' NLc 'fields & histories'] };
nb = numel(steps);
fig = figure('Units','inches','Position',[1 1 7.6 10.6],'Color','w');
ax = axes('Position',[0.02 0.02 0.96 0.96]); hold(ax,'on'); axis(ax,'off');
bw = 8.4; bh = 2.05; cx = 5; gap = 1.0; top = nb*(bh+gap);
xlim(ax,[0 10]); ylim(ax,[0 top+0.5]);
fc = {[0.86 0.92 0.99],[0.90 0.95 0.90],[0.90 0.95 0.90],[0.99 0.95 0.86],...
      [0.99 0.95 0.86],[0.97 0.90 0.90],[0.92 0.90 0.97]};
cy = zeros(nb,1);
for i = 1:nb
    cy(i) = top - (i-1)*(bh+gap) - bh/2;
    rectangle('Position',[cx-bw/2, cy(i)-bh/2, bw, bh],'Curvature',0.18,...
        'FaceColor',fc{i},'EdgeColor',[0.20 0.20 0.20],'LineWidth',1.2);
    text(cx,cy(i),steps{i},'HorizontalAlignment','center','VerticalAlignment','middle',...
        'FontSize',11,'Interpreter','tex');
end
for i = 1:nb-1                                         % downward arrows
    y1 = cy(i)-bh/2; y2 = cy(i+1)+bh/2;
    plot([cx cx],[y1 y2+0.03],'k-','LineWidth',1.3);
    plot(cx,y2+0.06,'kv','MarkerFaceColor','k','MarkerSize',9);
end
print(fig,fullfile(outdir,'solution_flowchart.png'),'-dpng','-r300');
close(fig); fprintf('done: solution_flowchart.png\n');

%% ================================================================= FIG 6
%  theory_taxonomy.png : classification tree of thermoelasticity theories
fig = figure('Units','inches','Position',[1 1 13 7],'Color','w');
ax = axes('Position',[0 0 1 1]); hold(ax,'on'); axis(ax,'off');
xlim(ax,[0 106]); ylim(ax,[0 100]);
blue = [0.86 0.92 0.99]; grey = [0.93 0.93 0.93]; hi = [1.0 0.90 0.55];
% root
rx = 45; ry = 90;
tbox(rx,ry,34,9,'Thermoelasticity Theories',blue,[0.15 0.15 0.15],1.6,13);
% level 1
clx = 22; gnx = 71; l1y = 68;
tbox(clx,l1y,30,14,['Classical' NLc '(Fourier''s law,' NLc 'infinite wave speed)'],grey,[0.2 0.2 0.2],1.2,11);
tbox(gnx,l1y,34,14,['Generalized' NLc '(hyperbolic, finite wave' NLc 'speed / second sound)'],grey,[0.2 0.2 0.2],1.2,11);
tconn(rx,ry-4.5,clx,l1y+7); tconn(rx,ry-4.5,gnx,l1y+7);
% level 2 : classical children
ucx = 12; cox = 32; l2y = 46;
tbox(ucx,l2y,15,8,'Uncoupled',[0.97 0.97 0.97],[0.35 0.35 0.35],1.0,10);
tbox(cox,l2y,15,8,'Coupled',[0.97 0.97 0.97],[0.35 0.35 0.35],1.0,10);
tconn(clx,l1y-7,ucx,l2y+4); tconn(clx,l1y-7,cox,l2y+4);
% level 2 : generalized children (4)
gy = 40; gw = 14; gh = 14;
gxs = [49 65 81 97];
labels = { ...
  ['Lord-Shulman' NLc '(1 relaxation time \tau_0)'], ...
  ['Green-Lindsay' NLc '(2 relaxation times)'], ...
  ['Green-Naghdi' NLc '(type I / II / III, k^{*})'], ...
  ['Dual-Phase-Lag' NLc '(2 phase lags)'] };
for q = 1:4
    if q==1, fcq = hi; ecq = [0.80 0.30 0.0]; lwq = 2.2; else, fcq = [0.97 0.97 0.97]; ecq = [0.35 0.35 0.35]; lwq = 1.0; end
    tbox(gxs(q),gy,gw,gh,labels{q},fcq,ecq,lwq,10);
    tconn(gnx,l1y-7,gxs(q),gy+7);
end
% highlight annotation for LS (this thesis)
text(gxs(1),gy-9.5,'\leftarrow  THIS THESIS','Color',[0.80 0.20 0.0],...
     'FontSize',12,'FontWeight','bold','HorizontalAlignment','center');
print(fig,fullfile(outdir,'theory_taxonomy.png'),'-dpng','-r300');
close(fig); fprintf('done: theory_taxonomy.png\n');

fprintf('\nAll 6 chapter-2/3 schematic figures written to:\n  %s\n',outdir);

%% ---- local helper functions (must be at end of a script) ----------------
function tbox(cx,cy,w,hh,txt,fc,ec,lw,fsz)
    rectangle('Position',[cx-w/2, cy-hh/2, w, hh],'Curvature',0.15,...
        'FaceColor',fc,'EdgeColor',ec,'LineWidth',lw);
    text(cx,cy,txt,'HorizontalAlignment','center','VerticalAlignment','middle',...
        'FontSize',fsz,'Interpreter','tex');
end
function tconn(px,py,cx,cy)
    plot([px cx],[py cy],'-','Color',[0.25 0.25 0.25],'LineWidth',1.1);
    plot(cx,cy,'v','MarkerFaceColor',[0.25 0.25 0.25],...
        'MarkerEdgeColor',[0.25 0.25 0.25],'MarkerSize',7);
end
