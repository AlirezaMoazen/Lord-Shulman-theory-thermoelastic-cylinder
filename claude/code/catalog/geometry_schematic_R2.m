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
G.Ri = Ri; G.Ro = Ro; G.L = L; G.NL = NL; G.Rb = Rb; G.tI = 0.16;   % tI = insulation block thickness
az = -25; el = 22;                                   % camera: from the front, slightly right and above

%% ================= FIGURE 1: cross-section (a) + half cylinder (b) =================
fig = figure('Units','inches','Position',[1 1 12 6],'Color','w','Renderer','opengl');

% ---------- (a) annular cross-section: unchanged from ch123_figs_R10 ----------
ax1 = axes('Parent',fig,'Position',[0.01 0.08 0.36 0.90]); hold(ax1,'on'); axis(ax1,'equal'); axis(ax1,'off');
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
qi = quiver(ax1,Ri*cos(ang),Ri*sin(ang),0.14*cos(ang),0.14*sin(ang),0,'Color',CO{2},'LineWidth',1.2,'MaxHeadSize',0.55,'DisplayName','inner: T_{in}(t) + P_i');
qo = quiver(ax1,Ro*cos(ang),Ro*sin(ang),0.11*cos(ang),0.11*sin(ang),0,'Color',CO{1},'LineWidth',1.0,'MaxHeadSize',0.55,'DisplayName','outer: convection h_c');
legend(ax1,[qi(1) qo(1)],'Location','southoutside','Orientation','horizontal','FontSize',9,'Box','off');
xlim(ax1,[-(Ro+0.55) Ro+0.55]); ylim(ax1,[-(Ro+0.5) Ro+0.5]);

% ---------- (b) axially cut half cylinder, 3D ----------
ax2 = axes('Parent',fig,'Position',[0.27 0.0 0.71 1.0]);
draw_cyl3d(ax2, pi, 'gray', CO, G, az, el, true);

exportgraphics(fig,fullfile(outdir,'geometry_schematic_R2.png'),'Resolution',300);
savefig(fig,fullfile(outdir,'geometry_schematic_R2.fig'));
close(fig); fprintf('done: geometry_schematic_R2.png\n');

%% ================= FIGURE 2: Heydarpour-style cutaway cylinder =================
fig = figure('Units','inches','Position',[1 1 8 7.5],'Color','w','Renderer','opengl');
ax3 = axes('Parent',fig,'Position',[0 0 1 1]);
draw_cyl3d(ax3, 1.25*pi, 'blue', CO, G, az, el, false);
exportgraphics(fig,fullfile(outdir,'geometry_3D_cutaway_R1.png'),'Resolution',300);
savefig(fig,fullfile(outdir,'geometry_3D_cutaway_R1.fig'));
close(fig); fprintf('done: geometry_3D_cutaway_R1.png\n');

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

    % ---- insulation blocks at the top and bottom ends ----
    for zc = [-tI, L]
        ins_block(ax,zc,zc+tI,Ri,Ro,thMax,cIns,edge);
    end

    % ---- inner loading: arrows from the bore onto the inner surface (P_i + T_in) ----
    if thMax > pi, thI = deg2rad([40 65 90 110]); else, thI = deg2rad([45 80 115 150]); end
    zr = [0.25 0.50 0.75]*L;
    for a = thI
        for z = zr
            quiver3(ax,(Ri-0.34)*cos(a),(Ri-0.34)*sin(a),z,0.30*cos(a),0.30*sin(a),0,0, ...
                    'Color',CO{2},'LineWidth',1.8,'MaxHeadSize',0.9);
        end
    end
    % ---- outer convection: arrows leaving the outer surface where it faces the camera ----
    if thMax > pi, thO = deg2rad([4 16 198 212]); else, thO = deg2rad([4 12 20]); end
    for a = thO
        for z = zr
            quiver3(ax,Ro*cos(a),Ro*sin(a),z,0.36*cos(a),0.36*sin(a),0,0, ...
                    'Color',CO{1},'LineWidth',1.8,'MaxHeadSize',0.9);
        end
    end

    % ---- annotations ----
    text(ax,Ro+0.12,0,L+tI/2,'insulated','FontSize',12,'HorizontalAlignment','left', ...
         'VerticalAlignment','middle','BackgroundColor','w','Margin',1);
    text(ax,Ro+0.12,0,-tI/2,'insulated','FontSize',12,'HorizontalAlignment','left', ...
         'VerticalAlignment','middle','BackgroundColor','w','Margin',1);
    % z axis arrow and length dimension
    xa = -Ro-0.45;
    plot3(ax,[xa xa],[0 0],[0 L],'k-','LineWidth',1.0);
    plot3(ax,[xa-0.05 xa+0.05],[0 0],[0 0],'k-','LineWidth',1.0);
    plot3(ax,[xa-0.05 xa+0.05],[0 0],[L L],'k-','LineWidth',1.0);
    text(ax,xa-0.08,0,L/2,'L','FontSize',14,'FontAngle','italic','HorizontalAlignment','right');
    xz = Ro+1.05;                                       % z axis triad, clear of the cylinder
    quiver3(ax,xz,0,0.35,0,0,0.75,0,'Color','k','LineWidth',1.3,'MaxHeadSize',0.8);
    text(ax,xz,0,1.35,'z','FontSize',14,'FontAngle','italic','HorizontalAlignment','center');
    if withDims
        % R_i, R_o, h marked on the cut face below the bottom insulation block
        zd = -tI-0.30;
        plot3(ax,[Ri Ri],[0 0],[-tI zd-0.05],':','Color',[0.3 0.3 0.3],'LineWidth',0.8);
        plot3(ax,[Ro Ro],[0 0],[-tI zd-0.05],':','Color',[0.3 0.3 0.3],'LineWidth',0.8);
        quiver3(ax,Ri,0,zd,Ro-Ri,0,0,0,'Color','k','LineWidth',1.0,'MaxHeadSize',0.5,'ShowArrowHead','on');
        quiver3(ax,Ro,0,zd,-(Ro-Ri),0,0,0,'Color','k','LineWidth',1.0,'MaxHeadSize',0.5);
        text(ax,(Ri+Ro)/2,0,zd-0.14,'h','FontSize',14,'FontAngle','italic','HorizontalAlignment','center');
        text(ax,Ri,0,zd-0.14,'R_i','FontSize',13,'HorizontalAlignment','right');
        text(ax,Ro,0,zd-0.14,'R_o','FontSize',13,'HorizontalAlignment','left');
    end

    axis(ax,'equal'); axis(ax,'off');
    view(ax,az,el); camproj(ax,'orthographic');
    xlim(ax,[-Ro-0.60 Ro+1.40]); ylim(ax,[-Ro-0.3 Ro+0.3]); zlim(ax,[-0.95 L+0.75]);
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
