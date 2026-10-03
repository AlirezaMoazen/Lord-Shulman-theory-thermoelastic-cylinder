%% catalog_R12_extras.m — wave-front + 25-matrix figures, Chapter-4 display standard
%  Same figures and same data as catalog_R7_extras: the Lord-Shulman wave-front
%  sweep and the 5x5 GPL-pattern x porosity-pattern matrices. What changed is
%  the display, brought into line with the 4-panel and 2-panel catalog figures:
%    * subplot(5,5,..) -> tiledlayout with tight spacing and tight padding, so
%      the 25 axes fill the canvas instead of being separated by wide margins;
%    * canvas enlarged (1740x1260 at 140 dpi) and axis fonts raised from 6 pt
%      to 12 pt, which is what made the old matrices hard to read;
%    * the per-panel title is replaced by a per-panel LEGEND carrying the same
%      GPL/porosity identification, matching the rest of the catalog (which
%      carries no panel titles) and giving each axes back the title row;
%    * each legend is verified not to sit on top of the curve, exactly as in
%      catalog_R12_color; the y-range of each panel is padded upwards first so
%      a corner is free and the legend never has to be pushed outside the axes;
%    * axis labels are kept on every panel, as required for the matrices.
%  The wave-front figures get the same font and canvas treatment.
%  Output: figures_ch4_R12 (alongside the B&W 4-panel figures of catalog_R12).
clearvars; clc; close all;
CLROOT='c:/Users/InfosaicUser/Desktop/MSc/Lord-Shulman-theory-thermoelastic-cylinder/claude';
pdir=fullfile(CLROOT,'param_studies_ch4'); cdir=fullfile(CLROOT,'figures_ch4_R12');
if ~exist(cdir,'dir'), mkdir(cdir); end
T_inf=300; E_ref=4.433e9; nu_ref=0.3395; alp_ref=5.9814e-5;
Sst=@(s) (1+nu_ref).*s./(E_ref.*alp_ref.*T_inf);
FNT='Times New Roman'; FSZ=12; LGSZ=12;

%% ---- WAVE-FRONT figures (from full history) ----
wf = {'BASE',3000; 'C_TAU_087',6000; 'M_GAUSS_LS',3000};
for wc=1:size(wf,1)
    nm=wf{wc,1}; tt=wf{wc,2};
    fp=fullfile(pdir,[nm '.mat']);
    if ~exist(fp,'file'), fprintf('SKIP wavefront %s (no .mat)\n',nm); continue; end
    d=load(fp);
    if ~isfield(d,'X_hist'), fprintf('no X_hist in %s\n',nm); continue; end
    NL=d.NL; Nr=d.N_r; Nz=d.N_z; iz0=round(Nz/2); tv=d.tv;
    Ri=d.r_nodes{1}(1); Ro=d.r_nodes{end}(end);
    rr=zeros(NL*Nr,1); q=0;
    for e=1:NL, for ir=1:Nr, q=q+1; rr(q)=d.r_nodes{e}(ir); end, end
    xi=(rr-Ri)/(Ro-Ri);
    tsel=unique([0:tt/20:0.6*tt, 0.7*tt:0.1*tt:tt]);
    ns=zeros(size(tsel)); for j=1:numel(tsel), [~,ns(j)]=min(abs(tv-tsel(j))); end
    ns=unique(ns);
    cmap=parula(numel(ns));
    f=figure('Position',[40 60 980 700],'Color','w','Name',[nm '_wavefront']);
    tl=tiledlayout(f,1,1,'TileSpacing','tight','Padding','tight');
    nexttile(tl); hold on;
    for j=1:numel(ns)
        n=ns(j); Tst=zeros(NL*Nr,1); q=0;
        for e=1:NL, for ir=1:Nr
            q=q+1; g=(e-1)*Nr*Nz+(ir-1)*Nz+iz0;   % idx_Th (theta block)
            Tst(q)=d.X_hist(g,n)/T_inf;             % theta/T_inf = T*
        end, end
        plot(xi,Tst,'-','Color',cmap(j,:),'LineWidth',1.1);
    end
    grid on; box on; set(gca,'FontName',FNT,'FontSize',FSZ+2);
    xlabel('\xi   (inner \rightarrow outer)'); ylabel('T^*');
    cb=colorbar; cb.Label.String='time (early \rightarrow late)';
    cb.FontName=FNT; cb.FontSize=FSZ+2; cb.Label.FontSize=FSZ+2;
    try, clim([tv(ns(1)) tv(ns(end))]); catch, caxis([tv(ns(1)) tv(ns(end))]); end
    colormap(parula);
    print(f,fullfile(cdir,[nm '_wavefront.png']),'-dpng','-r140'); close(f);
    fprintf('wavefront: %s (%d frames)\n',nm,numel(ns));
end

%% ---- 25-MATRIX figures (5x5 GPL x porosity) ----
pats={'UD','O','X','V','A'};
qnames={'Sigma_thth','Tstar'}; qlab={'\Sigma_{\theta\theta}','T^*'};
rep={};
for qty=1:2
    f=figure('Position',[10 10 1740 1260],'Color','w','Name',['matrix25_' qnames{qty}]);
    tl=tiledlayout(f,5,5,'TileSpacing','tight','Padding','tight');
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
        headroom(ax);                       % free a corner for the legend
        lab={sprintf('%s-GPL + %s-Por',pats{gi},pats{pj})};
        rep(end+1,:)=place_legend(ax,lab,FNT,LGSZ,['matrix25_' qnames{qty}],(gi-1)*5+pj); %#ok<SAGROW>
    end, end
    % no top title on the 25-matrix figure
    print(f,fullfile(cdir,['matrix25_' qnames{qty} '.png']),'-dpng','-r140');
    savefig(f,fullfile(cdir,['matrix25_' qnames{qty} '.fig'])); close(f);
    fprintf('matrix25: %s\n',qnames{qty});
end
nz=sum(cellfun(@(v)v>0,rep(:,4)));
fprintf('\nextras done -> %s\n',cdir);
fprintf('legends placed: %d, panels where the legend still covers data: %d\n',size(rep,1),nz);

%% ---- helpers ----
function headroom(ax)
% Pad the y-range upwards so one of the top corners is empty. With 25 small
% panels there is otherwise no room for an in-axes legend, and place_legend
% would be forced to put it outside, which would shrink that one tile.
    yl=ylim(ax); dy=diff(yl);
    if dy<=0 || ~all(isfinite(yl)), return; end
    ylim(ax,[yl(1)-0.04*dy, yl(2)+0.30*dy]);
end

function out = place_legend(ax,labels,FNT,SZ,sname,panel)
% Put a legend on THIS axes and verify it does not sit on top of any plotted
% line. MATLAB's 'best' only minimises overlap -- it does not guarantee zero --
% so every candidate location is tried and the overlap is measured directly:
% each data point is mapped into figure-normalised coordinates and tested
% against the legend's own rectangle. The first location with zero covered
% points wins; if every in-axes location still covers data, the legend is moved
% outside the axes, which cannot overlap by construction.
    cand = {'best','northeast','northwest','southeast','southwest','north','south','east','west'};
    ln = findobj(ax,'Type','line');
    X = []; Y = [];
    for i = 1:numel(ln)
        X = [X, ln(i).XData(:).']; Y = [Y, ln(i).YData(:).']; %#ok<AGROW>
    end
    good = isfinite(X) & isfinite(Y); X = X(good); Y = Y(good);
    bestLoc = cand{1}; bestN = inf;
    for c = 1:numel(cand)
        lg = legend(ax,labels,'Location',cand{c},'FontSize',SZ,'FontName',FNT);
        drawnow limitrate;
        n = count_covered(ax,lg,X,Y);
        if n < bestN, bestN = n; bestLoc = cand{c}; end
        if n == 0, break; end
    end
    if bestN > 0
        lg = legend(ax,labels,'Location','eastoutside','FontSize',SZ,'FontName',FNT);
        drawnow limitrate;
        bestLoc = 'eastoutside'; bestN = 0;
    else
        lg = legend(ax,labels,'Location',bestLoc,'FontSize',SZ,'FontName',FNT); %#ok<NASGU>
    end
    fprintf('    %-20s panel %2d: legend %-13s covered points = %d\n', sname, panel, bestLoc, bestN);
    out = {sname, panel, bestLoc, bestN};
end

function n = count_covered(ax,lg,X,Y)
% number of plotted points falling inside the legend rectangle
    set(lg,'Units','normalized'); LP = lg.Position;
    P  = ax.Position;                      % axes box, figure-normalised
    xl = xlim(ax); yl = ylim(ax);
    if strcmp(ax.XScale,'log'), xs = (log10(X)-log10(xl(1)))/(log10(xl(2))-log10(xl(1)));
    else,                       xs = (X-xl(1))/(xl(2)-xl(1)); end
    if strcmp(ax.YScale,'log'), ys = (log10(Y)-log10(yl(1)))/(log10(yl(2))-log10(yl(1)));
    else,                       ys = (Y-yl(1))/(yl(2)-yl(1)); end
    vis = xs>=0 & xs<=1 & ys>=0 & ys<=1;   % only points actually drawn in view
    xn = P(1) + xs*P(3);  yn = P(2) + ys*P(4);
    inx = xn>=LP(1) & xn<=LP(1)+LP(3);
    iny = yn>=LP(2) & yn<=LP(2)+LP(4);
    n = sum(vis & inx & iny);
end
