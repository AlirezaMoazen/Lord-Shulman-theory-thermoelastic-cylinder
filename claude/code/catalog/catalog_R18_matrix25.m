%% catalog_R18_matrix25.m — 25-matrix figures, titled panels, coloured lines
%  The full 5x5 GPL-pattern x porosity-pattern matrix, one panel per
%  combination: Sigma_thth(xi) and T*(xi) at the final time.
%
%  R18 (2026-10-04): the colour set draws the curves in colour again. The
%  enlarged revision (catalog_R12_extras_R2) plotted every panel in black,
%  because the script it grew from used a single 'k-' for both output sets. The
%  old colour figures that are in the draft are drawn in MATLAB's second default
%  colour, so that exact orange is restored here and the B&W set keeps black.
%  Everything else follows the enlarged revision:
%    * tiledlayout with tight spacing and padding instead of subplot(5,5,n);
%    * canvas 1740x1260 at 140 dpi, axis fonts 12 pt (the old figures were 6 pt);
%    * the GPL/porosity combination written as a title on top of each graph;
%    * axis labels kept on every panel.
%  There is one curve per panel, so no legend is needed or drawn.
%  Output: figures_ch4_R18 (black) and figures_ch4_color_R18 (orange).
clearvars; clc; close all;
base='c:/Users/InfosaicUser/Desktop/MSc/Lord-Shulman-theory-thermoelastic-cylinder/claude';
pdir=fullfile(base,'param_studies_ch4');
T_inf=300; E_ref=4.433e9; nu_ref=0.3395; alp_ref=5.9814e-5;
Sst=@(s) (1+nu_ref).*s./(E_ref.*alp_ref.*T_inf);
FNT='Times New Roman'; FSZ=12;

pats={'UD','O','X','V','A'};
qnames={'Sigma_thth','Tstar'}; qlab={'\Sigma_{\theta\theta}','T^*'};

for mode=1:2
    if mode==1, LCOL=[0 0 0];                   outdir=fullfile(base,'figures_ch4_R18');
    else,       LCOL=[0.8500 0.3250 0.0980];    outdir=fullfile(base,'figures_ch4_color_R18'); end
    if ~exist(outdir,'dir'), mkdir(outdir); end
    for qty=1:2
        f=figure('Position',[10 10 1740 1260],'Color','w','Name',['matrix25_' qnames{qty}]);
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
        print(f,fullfile(outdir,['matrix25_' qnames{qty} '.png']),'-dpng','-r140');
        savefig(f,fullfile(outdir,['matrix25_' qnames{qty} '.fig'])); close(f);
        fprintf('matrix25: %-12s %d panels -> %s\n',qnames{qty},np,outdir);
    end
end
fprintf('\nDONE 25-matrix (titled, coloured + B&W)\n');
