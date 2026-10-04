%% catalog_R20_matrix25.m — 25-matrix figures, one colour per quantity
%  R20 (2026-10-04): the colour set now draws each matrix in the colour that
%  figure already has in the draft -- blue for the hoop-stress matrix and orange
%  for the temperature matrix. R19 used orange for both. The two colours were
%  read off the images embedded in the draft rather than guessed: RGB(0,114,189)
%  and RGB(217,83,25), which are MATLAB's first and second default colours.
%  Everything else is unchanged from R19, including the fixed print canvas.
%  Output: figures_ch4_R20 (black) and figures_ch4_color_R20 (blue / orange).
%
%  (R19 header follows)
%% 25-matrix figures, titled panels, coloured lines, fixed canvas
%  The full 5x5 GPL-pattern x porosity-pattern matrix, one panel per
%  combination: Sigma_thth(xi) and T*(xi) at the final time. Colour set in
%  MATLAB's second default colour (the colour the old Chapter-4 figures use),
%  B&W set in black; titles on top of every panel; axis labels on every panel.
%
%  R19 (2026-10-04): the printed canvas no longer depends on the screen.
%  R18 asked for a 1740x1260 figure at 140 dpi, but a figure that large is
%  clamped to the available display, and the clamp is not even consistent
%  between sessions: the R18 run produced 2106x1064 (squat panels) where an
%  earlier run of the same geometry produced 2538x1838. Printing is therefore
%  driven by an explicit PaperPosition instead of the on-screen size, which
%  pins the output at 2538x1838 regardless of the display. The figure is
%  created at the same aspect ratio so the on-screen layout and the printed
%  layout agree.
%  Output: figures_ch4_R20 (black) and figures_ch4_color_R20 (orange).
clearvars; clc; close all;
base='c:/Users/InfosaicUser/Desktop/MSc/Lord-Shulman-theory-thermoelastic-cylinder/claude';
pdir=fullfile(base,'param_studies_ch4');
T_inf=300; E_ref=4.433e9; nu_ref=0.3395; alp_ref=5.9814e-5;
Sst=@(s) (1+nu_ref).*s./(E_ref.*alp_ref.*T_inf);
FNT='Times New Roman'; FSZ=12;

DPI = 140; PX_W = 2538; PX_H = 1838;          % target printed size, pixels
IN_W = PX_W/DPI; IN_H = PX_H/DPI;             % same thing in inches

pats={'UD','O','X','V','A'};
qnames={'Sigma_thth','Tstar'}; qlab={'\Sigma_{\theta\theta}','T^*'};

% Colour per quantity, matching the figures already in the draft: the hoop-stress
% matrix is drawn in MATLAB's first default colour and the temperature matrix in
% the second. Sampling the two images embedded in the draft gives RGB(0,114,189)
% and RGB(217,83,25), i.e. exactly these two.
QCOL = {[0 0.4470 0.7410], [0.8500 0.3250 0.0980]};   % {Sigma_thth, Tstar}

for mode=1:2
    if mode==1, outdir=fullfile(base,'figures_ch4_R20');
    else,       outdir=fullfile(base,'figures_ch4_color_R20'); end
    if ~exist(outdir,'dir'), mkdir(outdir); end
    for qty=1:2
        if mode==1, LCOL=[0 0 0]; else, LCOL=QCOL{qty}; end
        f=figure('Units','inches','Position',[0.2 0.2 IN_W IN_H], ...
                 'Color','w','Name',['matrix25_' qnames{qty}]);
        % print from the paper rectangle, not the (possibly clamped) window
        set(f,'PaperUnits','inches','PaperPosition',[0 0 IN_W IN_H]);
        tl=tiledlayout(f,5,5,'TileSpacing','tight','Padding','tight');
        np=0;
        for gi=1:5, for pj=1:5
            nm=sprintf('H_%s_%s',pats{gi},pats{pj});
            fp=fullfile(pdir,[nm '.mat']); if ~exist(fp,'file'), continue; end
            d=load(fp,'r_all','r_nodes','T_all','S_tt');
            Ri=d.r_nodes{1}(1); Ro=d.r_nodes{end}(end); xi=(d.r_all(:)-Ri)/(Ro-Ri);
            ax=nexttile(tl,(gi-1)*5+pj); hold(ax,'on');
            if qty==1, y=Sst(d.S_tt); else, y=(d.T_all-300)/300; end
            plot(ax,xi,y,'-','Color',LCOL,'LineWidth',1.2);
            grid(ax,'on'); box(ax,'on'); set(ax,'FontName',FNT,'FontSize',FSZ);
            ylabel(ax,qlab{qty},'FontName',FNT); xlabel(ax,'\xi','FontName',FNT);
            title(ax,sprintf('%s-GPL + %s-Por',pats{gi},pats{pj}), ...
                  'FontName',FNT,'FontSize',FSZ,'FontWeight','normal');
            np=np+1;
        end, end
        fn=fullfile(outdir,['matrix25_' qnames{qty} '.png']);
        print(f,fn,'-dpng',sprintf('-r%d',DPI));
        savefig(f,fullfile(outdir,['matrix25_' qnames{qty} '.fig'])); close(f);
        ii=imfinfo(fn);
        fprintf('matrix25: %-12s %d panels  %dx%d px -> %s\n',qnames{qty},np,ii.Width,ii.Height,outdir);
    end
end
fprintf('\nDONE 25-matrix (titled, coloured + B&W, fixed canvas)\n');
