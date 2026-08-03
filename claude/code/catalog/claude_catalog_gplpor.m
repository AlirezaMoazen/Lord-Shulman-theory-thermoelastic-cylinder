%% claude_catalog_gplpor.m — GPL-pattern comparison at each fixed porosity pattern
%  NEW figure set (author request, 2026-08): 5 figures, one per porosity pattern;
%  each overlays the 5 GPL patterns (UD/O/X/V/A) at that fixed porosity. It unpacks
%  the 25-combination data (H_<GPL>_<Por>.mat) by porosity, so each figure answers
%  "at this porosity background, how do the GPL distributions compare?".
%  Same 4-panel format & Heydarpour convention as claude_catalog_R6:
%    (1) T*(Fo)  (2) U*(Fo)   [mid-point histories]
%    (3) T*(xi)  (4) Sig_thth(xi)   [profiles at final time]
%  Title-free (Prom.5); legends kept. Renders B&W (-> figures_ch4_bw) and colour
%  (-> figures_ch4_color). New revision file; changes no earlier catalog or solver.
clearvars; clc; close all;
pdir='param_studies_ch4';
ahat=8.9708e-5; E_ref=4.433e9; nu_ref=0.3395; alp_ref=5.9814e-5; T_inf=300;
Fo=@(t,h) ahat.*t./h.^2; Tst=@(T)(T-T_inf)./T_inf;
Ust=@(u,h) u./((1-nu_ref).*alp_ref.*T_inf.*h); Sst=@(s)(1+nu_ref).*s./(E_ref.*alp_ref.*T_inf);

pats={'UD','O','X','V','A'};   % patterns for GPL (curves) and porosity (one per figure)

% B&W and colour style sets (up to 5 curves), matching R6 / R6_color
BW.co={[0 0 0],[0 0 0],[0.45 0.45 0.45],[0.45 0.45 0.45],[0.68 0.68 0.68]};
BW.ls={'-','--',':','-.','-'}; BW.mk={'o','s','^','d','v'}; BW.lw=[1.4 1.2 1.2 1.2 1.4];
CO.co={[0 0.447 0.741],[0.850 0.325 0.098],[0.466 0.674 0.188],[0.494 0.184 0.556],[0.20 0.20 0.20]};
CO.ls={'-','-','-','-','-'}; CO.mk={'o','s','^','d','v'}; CO.lw=[1.6 1.4 1.4 1.4 1.4];   % Prom.4: solid colour lines
FNT='Times New Roman'; FSZ=9;

for pj=1:5                       % one figure per porosity pattern
    por=pats{pj};
    D={}; ok=true; labels={};
    for gi=1:5                   % the 5 GPL patterns at this porosity
        nm=sprintf('H_%s_%s',pats{gi},por);
        f=fullfile(pdir,[nm '.mat']);
        if ~exist(f,'file'), fprintf('SKIP porosity %s (missing %s)\n',por,nm); ok=false; break; end
        D{gi}=load(f,'tv','hist_T','hist_U','r_nodes','r_all','T_all','S_tt'); %#ok<SAGROW>
        labels{gi}=pats{gi}; %#ok<SAGROW>
    end
    if ~ok, continue; end

    for mode=1:2
        if mode==1, STY=BW; outdir='figures_ch4_bw'; else, STY=CO; outdir='figures_ch4_color'; end
        if ~exist(outdir,'dir'), mkdir(outdir); end
        f1=figure('Position',[30 50 1180 820],'Color','w','Name',sprintf('gplpor_por%s',por));
        subplot(2,2,1); hold on;
        for gi=1:5, d=D{gi}; hh=d.r_nodes{end}(end)-d.r_nodes{1}(1); curve(Fo(d.tv,hh),Tst(d.hist_T),gi,STY); end
        fin(gca,FNT,FSZ,'Fo','T^*'); legend(labels,'Location','best','FontSize',8,'FontName',FNT);
        subplot(2,2,2); hold on;
        for gi=1:5, d=D{gi}; hh=d.r_nodes{end}(end)-d.r_nodes{1}(1); curve(Fo(d.tv,hh),Ust(d.hist_U,hh),gi,STY); end
        fin(gca,FNT,FSZ,'Fo','U^*');
        subplot(2,2,3); hold on;
        for gi=1:5, d=D{gi}; Ri=d.r_nodes{1}(1); Ro=d.r_nodes{end}(end); xi=(d.r_all(:)-Ri)/(Ro-Ri); curve(xi,Tst(d.T_all),gi,STY); end
        fin(gca,FNT,FSZ,'\xi','T^*');
        subplot(2,2,4); hold on;
        for gi=1:5, d=D{gi}; Ri=d.r_nodes{1}(1); Ro=d.r_nodes{end}(end); xi=(d.r_all(:)-Ri)/(Ro-Ri); curve(xi,Sst(d.S_tt),gi,STY); end
        fin(gca,FNT,FSZ,'\xi','\Sigma_{\theta\theta}');
        print(f1,fullfile(outdir,sprintf('gplpor_por%s.png',por)),'-dpng','-r130');
        savefig(f1,fullfile(outdir,sprintf('gplpor_por%s.fig',por))); close(f1);
    end
    fprintf('gplpor: porosity %s (5 GPL patterns)\n',por);
end
fprintf('gplpor done: 5 porosity figures x (bw+colour)\n');

%% helpers
function curve(x,y,ci,STY)
    k=mod(ci-1,5)+1; x=x(:); y=y(:);
    if all(isnan(y))||numel(x)<2, return; end
    xm=x; for i=2:numel(xm), if xm(i)<=xm(i-1), xm(i)=xm(i-1)+1e-12; end, end
    nP=max(300,numel(x)); xf=linspace(xm(1),xm(end),nP); yf=interp1(xm,y,xf,'makima');
    mi=unique(round(linspace(1,nP,8)));
    plot(xf,yf,'Color',STY.co{k},'LineStyle',STY.ls{k},'LineWidth',STY.lw(k),...
        'Marker',STY.mk{k},'MarkerIndices',mi,'MarkerSize',4.5,'MarkerFaceColor','w');
end
function fin(ax,FNT,FSZ,xl,yl)
    grid(ax,'on'); box(ax,'on'); set(ax,'FontName',FNT,'FontSize',FSZ);
    xlabel(ax,xl,'FontName',FNT); ylabel(ax,yl,'FontName',FNT);
end
