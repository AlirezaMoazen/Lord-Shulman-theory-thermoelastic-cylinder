%% catalog_R12_extras_R2.m — 25-matrix figures with the pattern combination as a title
%  Second revision of the Chapter-4 25-matrix figures. Identical to
%  catalog_R12_extras in data, layout, canvas and fonts; the panel
%  identification goes back to where it was before: a TITLE on top of each
%  graph reading "<GPL>-GPL + <Por>-Por", as in catalog_R7_extras, instead of
%  the per-panel legend. Written at 12 pt rather than the old 6 pt, so it is
%  readable at the enlarged panel size, and the upward y-padding that was only
%  there to make room for a legend is dropped, so each curve again fills its
%  panel.
%  Axis labels stay on every panel; spacing stays tight; canvas stays
%  1740x1260 at 140 dpi.
%  The wave-front figures are unchanged by this revision and are not rebuilt --
%  they remain in figures_ch4_R12 from the catalog_R12_extras run.
%  Output: figures_ch4_R12_extras_R2.
clearvars; clc; close all;
CLROOT='c:/Users/InfosaicUser/Desktop/MSc/Lord-Shulman-theory-thermoelastic-cylinder/claude';
pdir=fullfile(CLROOT,'param_studies_ch4');
cdir=fullfile(CLROOT,'figures_ch4_R12_extras_R2');
if ~exist(cdir,'dir'), mkdir(cdir); end
T_inf=300; E_ref=4.433e9; nu_ref=0.3395; alp_ref=5.9814e-5;
Sst=@(s) (1+nu_ref).*s./(E_ref.*alp_ref.*T_inf);
FNT='Times New Roman'; FSZ=12;

%% ---- 25-MATRIX figures (5x5 GPL x porosity) ----
pats={'UD','O','X','V','A'};
qnames={'Sigma_thth','Tstar'}; qlab={'\Sigma_{\theta\theta}','T^*'};
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
        plot(ax,xi,y,'k-','LineWidth',1.2);
        grid(ax,'on'); box(ax,'on'); set(ax,'FontName',FNT,'FontSize',FSZ);
        ylabel(ax,qlab{qty},'FontName',FNT); xlabel(ax,'\xi','FontName',FNT);
        title(ax,sprintf('%s-GPL + %s-Por',pats{gi},pats{pj}), ...
              'FontName',FNT,'FontSize',FSZ,'FontWeight','normal');
        np=np+1;
    end, end
    % no top title on the 25-matrix figure itself
    print(f,fullfile(cdir,['matrix25_' qnames{qty} '.png']),'-dpng','-r140');
    savefig(f,fullfile(cdir,['matrix25_' qnames{qty} '.fig'])); close(f);
    fprintf('matrix25: %-12s  %d panels titled\n',qnames{qty},np);
end
fprintf('\nDONE 25-matrix (titled) -> %s\n',cdir);
