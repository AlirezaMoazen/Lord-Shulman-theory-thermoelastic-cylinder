%% claude_catalog_R6_extras.m — wave-front + 25-matrix figures (Ch4 catalog R6)
%  Wave-front: T*(xi) at dense early times from the full DOF history (X_hist),
%              showing the Lord-Shulman second-sound front cross the wall.
%  25-matrix : 5x5 grid (GPL pattern x porosity pattern), Sigma_thth(xi) and T*(xi).
clearvars; clc; close all;
pdir='param_studies_ch4'; cdir='figures_ch4';
T_inf=300; E_ref=4.433e9; nu_ref=0.3395; alp_ref=5.9814e-5;
Sst=@(s) (1+nu_ref).*s./(E_ref.*alp_ref.*T_inf);

%% ---- WAVE-FRONT figures (from full history) ----
wf = {'BASE',3000; 'C_TAU_087',6000; 'M_GAUSS_LS',3000};
for wc=1:size(wf,1)
    nm=wf{wc,1}; tt=wf{wc,2};
    d=load(fullfile(pdir,[nm '.mat']));
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
    f=figure('Position',[40 60 760 560],'Color','w','Name',[nm '_wavefront']); hold on;
    for j=1:numel(ns)
        n=ns(j); Tst=zeros(NL*Nr,1); q=0;
        for e=1:NL, for ir=1:Nr
            q=q+1; g=(e-1)*Nr*Nz+(ir-1)*Nz+iz0;   % idx_Th (theta block)
            Tst(q)=d.X_hist(g,n)/T_inf;             % theta/T_inf = T*
        end, end
        plot(xi,Tst,'-','Color',cmap(j,:),'LineWidth',1.1);
    end
    grid on; box on; set(gca,'FontName','Times New Roman','FontSize',10);
    xlabel('\xi   (inner \rightarrow outer)'); ylabel('T^*');
    title(sprintf('%s — thermal-wave front through the thickness',strrep(nm,'_','\_')),'FontWeight','normal');
    cb=colorbar; cb.Label.String='time (early \rightarrow late)';
    try, clim([tv(ns(1)) tv(ns(end))]); catch, caxis([tv(ns(1)) tv(ns(end))]); end
    colormap(parula);
    print(f,fullfile(cdir,[nm '_wavefront.png']),'-dpng','-r130'); close(f);
    fprintf('wavefront: %s (%d frames)\n',nm,numel(ns));
end

%% ---- 25-MATRIX figures (5x5 GPL x porosity) ----
pats={'UD','O','X','V','A'};
qnames={'Sigma_thth','Tstar'}; qlab={'\Sigma_{\theta\theta}(\xi)','T^*(\xi)'};
for qty=1:2
    f=figure('Position',[10 10 1500 1120],'Color','w','Name',['matrix25_' qnames{qty}]);
    for gi=1:5, for pj=1:5
        nm=sprintf('H_%s_%s',pats{gi},pats{pj});
        fp=fullfile(pdir,[nm '.mat']); if ~exist(fp,'file'), continue; end
        d=load(fp,'r_all','r_nodes','T_all','S_tt');
        Ri=d.r_nodes{1}(1); Ro=d.r_nodes{end}(end); xi=(d.r_all(:)-Ri)/(Ro-Ri);
        subplot(5,5,(gi-1)*5+pj);
        if qty==1, y=Sst(d.S_tt); else, y=(d.T_all-300)/300; end
        plot(xi,y,'k-','LineWidth',1.0); grid on; box on;
        set(gca,'FontName','Times New Roman','FontSize',6);
        title(sprintf('%s-GPL + %s-Por',pats{gi},pats{pj}),'FontSize',6,'FontWeight','normal');
        if pj==1, ylabel(qlab{qty},'FontSize',7); end
        if gi==5, xlabel('\xi','FontSize',7); end
    end, end
    sgtitle(sprintf('25-case GPL \\times porosity matrix  —  %s',qlab{qty}),'FontName','Times New Roman','FontSize',13);
    print(f,fullfile(cdir,['matrix25_' qnames{qty} '.png']),'-dpng','-r120');
    savefig(f,fullfile(cdir,['matrix25_' qnames{qty} '.fig'])); close(f);
    fprintf('matrix25: %s\n',qnames{qty});
end
fprintf('extras done\n');
