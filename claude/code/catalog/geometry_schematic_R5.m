%% geometry_schematic_R5.m — R4_5 without the loading arrows and without the insulated region (author request 2026-11-03)
%  R5 changes (marked R5): the inner/outer loading arrows (both panels) and the left-panel legend are removed; the yellow insulation blocks and the two "insulated" labels are removed (cylinder now ends at z=0 and z=L); zlim tightened with the same midpoint. R_i, R_o, L, h, the r-theta-z triads and all other geometry are unchanged. Output: geometry_schematic_R5.png/.fig. R4_5 and earlier stay frozen.
%  ----- R4_5 header follows -----
%% geometry_schematic_R4_5.m — R4_3 + left panel moved right and the gap between the two panels reduced; margin as in R4_3 (author request 2026-11-02; R4_4's tight crop is NOT used)
%  R4_5 changes (marked 'R4_5'): figure width 12 -> 11.45 in; left axes moved 0.35 in to the right, right axes 0.55 in to the left (gap reduced by 0.9 in; axes sizes in inches unchanged).
%  ----- R4_3 header follows -----
%% geometry_schematic_R4_3.m — R4_2 + label font back to 12 pt, bottom 'insulated' just below the yellow crescent (outside the yellow), both labels a little to the left, larger legend font (author request 2026-11-02)
%  R4_3 changes (marked 'R4_3'): label font size, anchors, dxl, legend FontSize. Everything else = R4_2.
%  ----- R4_2 header follows -----
%% geometry_schematic_R4_2.m — R4_1 + 'insulated' labels centred on the middle axis of the cylinder; the bottom label sits inside the crescent (top face of the bottom insulation block)
%  R4_2 changes (marked 'R4_2'): label anchor positions only. Everything else = R4_1.
%  ----- R4_1 header follows -----
%% geometry_schematic_R4_1.m — R4 + 'insulated' labels closer to the cylinder (centred) and the two panel centres on one horizontal line (author request 2026-11-02)
%  R4_1 changes (marked 'R4_1'): label offsets reduced; left panel shifted vertically by dyAx1. Everything else = R4.
%  ----- R4 header follows -----
%% geometry_schematic_R4.m — R3 + layout changes requested by the author (2026-11-02)
%  Changes vs R3 (all marked 'R4'; geometry, loads, colours untouched; only
%  geometry_schematic_R5.png/.fig is written -- the standalone 3D cutaway is not redrawn):
%    * right panel: the two words 'insulated' moved above the top end and below the bottom
%      end, horizontally centred on the cylinder axis;
%    * right panel: R_i and R_o removed; they are shown on the left (cross-section) panel as
%      radial dimension arrows from the centre;
%    * right panel: the wall thickness h is shown on the LEFT wall at the bottom, beside the
%      length L (dimension below the bottom insulation block, on the theta = pi cut face);
%    * right panel: the coordinate triad is rotated about z (outward) and theta is drawn as an
%      arc with an arrow head (as in the left panel) instead of a straight arrow.
%  ----- R3 header follows -----
%% geometry_schematic_R3.m — R2 + coordinate systems (r, theta, z) in the geometry figures
%  R3 (2026-10-29, author request Prom 6): "in the two figures that introduce the cylinder
%  geometry (axial-section figure and cross-section figure) a coordinate system must be added".
%  Changes vs R2 (all marked 'R3'; geometry, loads and colours untouched):
%    * cross-section panel (a): triad at the bore centre -- radial axis r, circumferential
%      direction theta (arc with arrow), axial direction z shown as the out-of-plane symbol;
%    * axial cutaway (panel (b) and the standalone 3D cutaway): the lone z arrow is replaced by
%      a full right-handed triad r, theta, z drawn at the theta = 0 cut plane;
%    * outputs: geometry_schematic_R3.png/.fig and geometry_3D_cutaway_R2.png/.fig
%      (R2/R1 figures stay frozen).
%  ----- R2 header follows -----
%% geometry_schematic_R2.m — geometry schematic with an axially cut half-cylinder (3D)
%  R2 (2026-10-12, author request) revises the geometry schematic that
%  ch123_figs_R10.m draws (geometry_schematic.png: (a) annular cross-section,
%  (b) r-z graph):
%    * the RIGHT-HAND GRAPH (the r-z axes plot) is DELETED;
%    * in its place, an axially cut HALF CYLINDER in 3D showing
%        - the 7 layers on the cut faces and on the top face,
%        - the INNER loading (internal pressure P_i + thermal load T_in(t)),
%        - the OUTER convection h_c,
%        - the TOP and BOTTOM ends THERMALLY INSULATED (shown as insulation
%          blocks, labelled).
%    The cross-section panel (a) and its legend are unchanged.
%  Output: figures_ch123/geometry_schematic_R2.png (+ .fig). R1 and
%  ch123_figs_R10.m (which keeps writing the old geometry_schematic.png) are frozen.
%
%  Second output (author request: "draw something like" the 3D cylinder
%  drawings in Heydarpour's papers, e.g. Thin-Walled Struct. 155 (2020) 106914
%  Fig. 1a): figures_ch123/geometry_3D_cutaway_R1.png — the same cylinder with a
%  135-degree wedge removed, layers in a blue scale, loads and insulated ends.
%  All figure text in English, Times New Roman (as in the other ch1-3 schematics).
clearvars; clc; close all;
outdir = 'C:/Users/InfosaicUser/Desktop/MSc/Lord-Shulman-theory-thermoelastic-cylinder/claude/figures_ch123';
if ~exist(outdir,'dir'), mkdir(outdir); end
try
    set(groot,'defaultAxesFontName','Times New Roman');
    set(groot,'defaultTextFontName','Times New Roman');
    set(groot,'defaultLegendFontName','Times New Roman');
catch
end
CO = {[0 0.447 0.741],[0.850 0.325 0.098]};          % chapter colours: outer = blue, inner = orange
Ri = 1.0; Ro = 1.5; L = 2.1; NL = 7;
Rb = Ri + (0:NL)*((Ro-Ri)/NL);                       % 8 interface radii
G.Ri = Ri; G.Ro = Ro; G.L = L; G.NL = NL; G.Rb = Rb; G.tI = 0;   % R5: no insulation blocks (tI = 0)
az = -25; el = 22;                                   % camera: from the front, slightly right and above

%% ================= FIGURE 1: cross-section (a) + half cylinder (b) =================
fig = figure('Units','inches','Position',[1 1 11.45 6],'Color','w','Renderer','opengl');

% ---------- (a) annular cross-section: unchanged from ch123_figs_R10 ----------
dyAx1 = 0.0296 + 0.024;   % R5: left panel lowered (position y = 0.08 - dyAx1) so the two panel centres stay on one horizontal line (R4_1 value: 0.0296)
ax1 = axes('Parent',fig,'Position',[0.0410 0.08-dyAx1 0.3773 0.90]); hold(ax1,'on'); axis(ax1,'equal'); axis(ax1,'off');
th = linspace(0,2*pi,400);
for k = 1:NL
    ro = Rb(k+1); ri = Rb(k); sh = 0.90 - 0.07*mod(k,2);
    patch(ax1,[ro*cos(th) ri*cos(fliplr(th))],[ro*sin(th) ri*sin(fliplr(th))],[sh sh sh],'EdgeColor','none');
end
for k = 1:NL+1
    lw = 0.5; if k==1||k==NL+1, lw = 1.6; end
    plot(ax1,Rb(k)*cos(th),Rb(k)*sin(th),'-','Color',[0.25 0.25 0.25],'LineWidth',lw);
end
na = 12; ang = linspace(0,2*pi,na+1); ang(end) = [];
xlim(ax1,[-(Ro+0.55) Ro+0.55]); ylim(ax1,[-(Ro+0.5) Ro+0.5]);
% R3: coordinate system of the cross-section: r (radial), theta (circumferential), z (out of the page)
tri_r = 0.55; tri_a = 0.33;
quiver(ax1,0,0,tri_r,0,0,'Color','k','LineWidth',1.3,'MaxHeadSize',0.6);          % r axis
text(ax1,tri_r+0.07,0.0,'r','FontSize',14,'FontAngle','italic','HorizontalAlignment','left','VerticalAlignment','middle');
ta = linspace(deg2rad(8),deg2rad(80),40);
plot(ax1,tri_a*cos(ta),tri_a*sin(ta),'k-','LineWidth',1.3);                         % theta arc
% arrow head at the arc end: filled triangle along the counter-clockwise tangent
Ee = tri_a*[cos(ta(end)) sin(ta(end))]; tg = [-sin(ta(end)) cos(ta(end))]; nn = [cos(ta(end)) sin(ta(end))];
hl = 0.10; hw = 0.045;
patch(ax1,[Ee(1)+hl*tg(1), Ee(1)+hw*nn(1), Ee(1)-hw*nn(1)],[Ee(2)+hl*tg(2), Ee(2)+hw*nn(2), Ee(2)-hw*nn(2)],'k','EdgeColor','k');
text(ax1,0.45*cos(deg2rad(58)),0.45*sin(deg2rad(58)),'\theta','FontSize',14,'HorizontalAlignment','left','VerticalAlignment','bottom');
plot(ax1,0,0,'ko','MarkerSize',9,'LineWidth',1.2); plot(ax1,0,0,'k.','MarkerSize',9);   % z out of the page
text(ax1,0.03,-0.13,'z','FontSize',14,'FontAngle','italic','HorizontalAlignment','center','VerticalAlignment','top');   % R4: moved below the symbol (clear of the R_o line)
% R4: radii R_i and R_o as radial dimension arrows from the centre (moved here from the right panel)
ai = deg2rad(145); ao = deg2rad(215);
quiver(ax1,0,0,Ri*cos(ai),Ri*sin(ai),0,'Color','k','LineWidth',1.0,'MaxHeadSize',0.10);
quiver(ax1,0,0,Ro*cos(ao),Ro*sin(ao),0,'Color','k','LineWidth',1.0,'MaxHeadSize',0.07);
text(ax1,0.52*cos(ai),0.52*sin(ai)+0.05,'R_i','FontSize',14,'HorizontalAlignment','center','VerticalAlignment','bottom');
text(ax1,(Ro+0.10)*cos(ao),(Ro+0.10)*sin(ao),'R_o','FontSize',14,'HorizontalAlignment','right','VerticalAlignment','top');

% ---------- (b) axially cut half cylinder, 3D ----------
ax2 = axes('Parent',fig,'Position',[0.2349 0.0 0.7441 1.0]);
draw_cyl3d(ax2, pi, 'gray', CO, G, az, el, true);

exportgraphics(fig,fullfile(outdir,'geometry_schematic_R5.png'),'Resolution',300,'Padding',30);   % R4: was _R3; R4_1: padding so the top label is not at the edge
savefig(fig,fullfile(outdir,'geometry_schematic_R5.fig'));
close(fig); fprintf('done: geometry_schematic_R5.png\n');
% R4: FIGURE 2 (standalone 3D cutaway) removed from this script; geometry_3D_cutaway_R2 stays as is

%% ============================ helpers ============================
function draw_cyl3d(ax, thMax, palette, CO, G, az, el, withDims)
    hold(ax,'on');
    Ri = G.Ri; Ro = G.Ro; L = G.L; NL = G.NL; Rb = G.Rb; tI = G.tI;
    edge = [0.25 0.25 0.25];
    % layer colours: alternating greys (as in the 2D panel) or a light->dark blue scale
    for k = 1:NL
        if strcmp(palette,'gray')
            lay{k} = (0.90 - 0.07*mod(k,2))*[1 1 1]; %#ok<AGROW>
        else
            t = (k-1)/(NL-1);
            lay{k} = [0.80 0.89 0.99]*(1-t) + [0.10 0.27 0.60]*t; %#ok<AGROW>
        end
    end
    if strcmp(palette,'gray'), cIn = [0.93 0.93 0.95]; cOut = [0.80 0.80 0.80];
    else,                      cIn = [0.82 0.90 0.98]; cOut = [0.66 0.79 0.95]; end
    cIns = [1.00 0.93 0.62];                                  % insulation blocks
    th = linspace(0,thMax,120);

    % ---- curved surfaces (inner + outer), light-dependent shading ----
    [T,Z] = meshgrid(th,[0 L]);
    surf_shaded(ax,Ri*cos(T),Ri*sin(T),Z,T,cIn);
    surf_shaded(ax,Ro*cos(T),Ro*sin(T),Z,T,cOut);

    % ---- cut faces (theta = 0 and theta = thMax): the 7 layers ----
    for k = 1:NL
        for tc = [0 thMax]
            patch(ax,[Rb(k) Rb(k+1) Rb(k+1) Rb(k)]*cos(tc),[Rb(k) Rb(k+1) Rb(k+1) Rb(k)]*sin(tc), ...
                  [0 0 L L],lay{k},'EdgeColor',edge,'LineWidth',0.4);
        end
        % ---- top face z = L: annular sector of layer k ----
        sector(ax,L,Rb(k),Rb(k+1),0,thMax,lay{k},edge);
    end



    % ---- annotations ----
    % z axis arrow and length dimension
    xa = -Ro-0.45;
    plot3(ax,[xa xa],[0 0],[0 L],'k-','LineWidth',1.0);
    plot3(ax,[xa-0.05 xa+0.05],[0 0],[0 0],'k-','LineWidth',1.0);
    plot3(ax,[xa-0.05 xa+0.05],[0 0],[L L],'k-','LineWidth',1.0);
    text(ax,xa-0.08,0,L/2,'L','FontSize',14,'FontAngle','italic','HorizontalAlignment','right');
    % R3: full coordinate triad (r, theta, z) at the theta = 0 cut plane, clear of the cylinder
    xz = Ro+0.85; z0 = 0.35; Lt = 0.62;
    % R4: triad rotated about z by phT (outward); theta shown as an arc with an arrow head
    phT = deg2rad(-55);
    er = [cos(phT) sin(phT) 0];
    quiver3(ax,xz,0,z0,0,0,0.75,0,'Color','k','LineWidth',1.3,'MaxHeadSize',0.8);   % z (axial)
    text(ax,xz,0,z0+0.75+0.12,'z','FontSize',14,'FontAngle','italic','HorizontalAlignment','center');
    quiver3(ax,xz,0,z0,Lt*er(1),Lt*er(2),0,0,'Color','k','LineWidth',1.3,'MaxHeadSize',0.8);      % r (radial)
    text(ax,xz+(Lt+0.07)*er(1),(Lt+0.07)*er(2),z0,'r','FontSize',14,'FontAngle','italic','HorizontalAlignment','left');
    ra = 0.42; tt = linspace(deg2rad(12),deg2rad(85),40);                                       % theta arc (r -> theta)
    plot3(ax,xz+ra*cos(phT+tt),ra*sin(phT+tt),z0*ones(size(tt)),'k-','LineWidth',1.3);
    qe = [xz+ra*cos(phT+tt(end)), ra*sin(phT+tt(end))]; qd = [-sin(phT+tt(end)), cos(phT+tt(end))];
    nr = [cos(phT+tt(end)) sin(phT+tt(end))]; hl = 0.13; hw = 0.055;   % filled triangular arrow head at the arc end (as in the left panel)
    patch(ax,[qe(1)+hl*qd(1), qe(1)+hw*nr(1), qe(1)-hw*nr(1)],[qe(2)+hl*qd(2), qe(2)+hw*nr(2), qe(2)-hw*nr(2)],z0*ones(1,3),'k','EdgeColor','k');
    ta = phT+deg2rad(50);
    text(ax,xz+(ra+0.10)*cos(ta),(ra+0.10)*sin(ta),z0,'\theta','FontSize',14,'HorizontalAlignment','left');
    plot3(ax,xz,0,z0,'k.','MarkerSize',10);
    if withDims
        % R4: only the thickness h, on the LEFT wall (theta = pi cut face) at the bottom, beside L
        zd = -tI-0.30;
        plot3(ax,[-Ri -Ri],[0 0],[-tI zd-0.05],':','Color',[0.3 0.3 0.3],'LineWidth',0.8);
        plot3(ax,[-Ro -Ro],[0 0],[-tI zd-0.05],':','Color',[0.3 0.3 0.3],'LineWidth',0.8);
        quiver3(ax,-Ro,0,zd,Ro-Ri,0,0,0,'Color','k','LineWidth',1.0,'MaxHeadSize',0.5);
        quiver3(ax,-Ri,0,zd,-(Ro-Ri),0,0,0,'Color','k','LineWidth',1.0,'MaxHeadSize',0.5);
        text(ax,-(Ri+Ro)/2,0,zd-0.14,'h','FontSize',14,'FontAngle','italic','HorizontalAlignment','center');
    end

    axis(ax,'equal'); axis(ax,'off');
    view(ax,az,el); camproj(ax,'orthographic');
    xlim(ax,[-Ro-0.60 Ro+1.55]); ylim(ax,[-Ro-0.3 Ro+0.55]); zlim(ax,[-0.75 L+0.95]);   % R5: tighter (insulation labels gone); midpoint kept --    % R3: room for the triad (was Ro+1.40 / Ro+0.3)
end

function surf_shaded(ax,X,Y,Z,T,col)
    s = 0.78 + 0.22*cos(T - pi/4);                     % simple directional shading
    C = cat(3, min(col(1)*s,1), min(col(2)*s,1), min(col(3)*s,1));
    surf(ax,X,Y,Z,C,'EdgeColor','none','FaceColor','interp');
end

function sector(ax,z,r1,r2,t0,t1,col,edge)
    t = linspace(t0,t1,80);
    X = [r2*cos(t) r1*cos(fliplr(t))]; Y = [r2*sin(t) r1*sin(fliplr(t))];
    patch(ax,X,Y,z*ones(size(X)),col,'EdgeColor',edge,'LineWidth',0.4);
end

function ins_block(ax,z0,z1,r1,r2,thMax,col,edge)
    t = linspace(0,thMax,100);
    sector(ax,z1,r1,r2,0,thMax,col,edge);               % outer face of the block
    sector(ax,z0,r1,r2,0,thMax,col,edge);
    [T,Z] = meshgrid(t,[z0 z1]);
    surface(ax,r2*cos(T),r2*sin(T),Z,'FaceColor',col,'EdgeColor','none');
    surface(ax,r1*cos(T),r1*sin(T),Z,'FaceColor',col*0.97,'EdgeColor','none');
    for tc = [0 thMax]
        patch(ax,[r1 r2 r2 r1]*cos(tc),[r1 r2 r2 r1]*sin(tc),[z0 z0 z1 z1],col,'EdgeColor',edge,'LineWidth',0.5);
    end
end
