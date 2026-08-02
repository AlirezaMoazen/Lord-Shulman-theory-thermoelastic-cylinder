%% claude_catalog_ch4_variants.m — fill the missing style variants for the Ch4 docx.
%  Produces: B&W convergence figures + B&W wave-fronts -> figures_ch4_bw/
%            colour 25-matrix figures                   -> figures_ch4_color/
%  (The colour conv/wavefront already exist in figures_ch4/, and the B&W 4-panel
%   and B&W matrix already exist there; those are copied into the two folders by
%   the PowerShell step. This script only renders what is genuinely missing.)
clearvars; clc; close all;
pdir='param_studies_ch4'; bw='figures_ch4_bw'; co='figures_ch4_color';
if ~exist(bw,'dir'), mkdir(bw); end
if ~exist(co,'dir'), mkdir(co); end
T_inf=300; E_ref=4.433e9; nu_ref=0.3395; alp_ref=5.9814e-5;
Sst=@(s)(1+nu_ref).*s./(E_ref.*alp_ref.*T_inf); Tst=@(T)(T-T_inf)./T_inf;
xic=linspace(0,1,200)';

%% ---- B&W convergence (grayscale) ----
CO={[0 0 0],[0.35 0.35 0.35],[0.6 0.6 0.6],[0.35 0.35 0.35],[0 0 0],[0.6 0.6 0.6]};
LS={'-','--',':','-.','-','--'}; MK={'o','s','^','d','v','>'};
L(1)=struct('nm','conv_Nr','cases',{{'SM_NR07','SM_NR09','SM_NR11','SM_NR13','BASE'}},'val',[7 9 11 13 15],'xl','N_r','ct','Ndof','cost',[]);
L(2)=struct('nm','conv_Nz','cases',{{'SM_NZ05','SM_NZ07','SM_NZ09','BASE','SM_NZ13','SM_NZ15'}},'val',[5 7 9 11 13 15],'xl','N_z','ct','time','cost',[90 198 349 NaN 987 1630]);
L(3)=struct('nm','conv_NL','cases',{{'L_NL_3','L_NL_5','BASE','L_NL_9','L_NL_15'}},'val',[3 5 7 9 15],'xl','N_L','ct','Ndof','cost',[]);
L(4)=struct('nm','conv_dt','cases',{{'TI_DT_05','BASE','TI_DT_20','TI_DT_50'}},'val',[0.5 1 2 5],'xl','\Deltat (s)','ct','steps','cost',[]);
for li=1:numel(L)
    cs=L(li).cases; nv=L(li).val; nc=numel(cs); D=cell(1,nc); ok=true;
    for ci=1:nc, f=fullfile(pdir,[cs{ci} '.mat']); if ~exist(f,'file'), ok=false; break; end
        D{ci}=load(f,'S_tt','T_all','r_all','r_nodes','NL','N_r','N_z'); end
    if ~ok, fprintf('skip %s\n',L(li).nm); continue; end
    if strcmp(L(li).nm,'conv_dt'), ref=1; else, ref=nc; end
    gx=@(d)(d.r_all(:)-d.r_nodes{1}(1))/(d.r_nodes{end}(end)-d.r_nodes{1}(1));
    [xr,ir]=unique(round(gx(D{ref}),10)); Sr=Sst(D{ref}.S_tt); Sr=Sr(ir); Sref=interp1(xr,Sr,xic,'pchip');
    eL2=zeros(1,nc); ein=zeros(1,nc); nd=zeros(1,nc);
    for ci=1:nc, d=D{ci}; [xu,iu]=unique(round(gx(d),10)); Su=Sst(d.S_tt); Su=Su(iu);
        eL2(ci)=100*norm(interp1(xu,Su,xic,'pchip')-Sref)/norm(Sref);
        S=Sst(d.S_tt); ein(ci)=100*abs(S(1)-Sr(1))/abs(Sr(1)); nd(ci)=3*d.NL*d.N_r*d.N_z; end
    fg=figure('Position',[20 40 1200 900],'Color','w');
    subplot(2,2,1); hold on; for ci=1:nc, d=D{ci}; k=mod(ci-1,6)+1;
        plot(gx(d),Sst(d.S_tt),'Color',CO{k},'LineStyle',LS{k},'LineWidth',1.3); end
    fin(gca,'\xi','\Sigma_{\theta\theta}','(a) hoop-stress profile'); legend(lgd(nv,L(li).nm),'Location','best','FontSize',8);
    subplot(2,2,2); hold on; for ci=1:nc, d=D{ci}; k=mod(ci-1,6)+1;
        plot(gx(d),Tst(d.T_all),'Color',CO{k},'LineStyle',LS{k},'LineWidth',1.3); end
    fin(gca,'\xi','T^*','(b) temperature profile');
    subplot(2,2,3); semilogy(nv,max(eL2,1e-4),'k-o','LineWidth',1.5,'MarkerFaceColor','k'); hold on;
    semilogy(nv,max(ein,1e-4),'--s','Color',[.55 .55 .55],'LineWidth',1.2,'MarkerFaceColor',[.55 .55 .55]);
    yline(1,'-.'); yline(0.1,':'); fin(gca,L(li).xl,'rel. error (%)','(c) convergence');
    legend({'L_2 profile','inner hoop','1%','0.1%'},'Location','best','FontSize',8);
    subplot(2,2,4);
    if strcmp(L(li).ct,'time'), cc=L(li).cost; m=~isnan(cc); plot(nv(m),cc(m),'k-o','LineWidth',1.5,'MarkerFaceColor','k'); yl='solve time (s)';
    elseif strcmp(L(li).ct,'steps'), plot(nv,3000./nv,'k-o','LineWidth',1.5,'MarkerFaceColor','k'); yl='N_{steps}';
    else, plot(nv,nd,'k-o','LineWidth',1.5,'MarkerFaceColor','k'); yl='N_{dof}'; end
    fin(gca,L(li).xl,yl,'(d) cost');
    sgtitle(sprintf('Convergence — %s',strrep(L(li).nm,'_','\_')),'FontName','Times New Roman','FontSize',13);
    print(fg,fullfile(bw,[L(li).nm '.png']),'-dpng','-r140'); close(fg); fprintf('bw %s\n',L(li).nm);
end

%% ---- B&W wave-fronts (gray colormap) ----
wf={'BASE',3000; 'C_TAU_087',6000; 'M_GAUSS_LS',3000};
for wc=1:size(wf,1)
    nm=wf{wc,1}; tt=wf{wc,2}; f=fullfile(pdir,[nm '.mat']); if ~exist(f,'file'), continue; end
    d=load(f); if ~isfield(d,'X_hist'), continue; end
    NL=d.NL; Nr=d.N_r; Nz=d.N_z; iz0=round(Nz/2); tv=d.tv;
    Ri=d.r_nodes{1}(1); Ro=d.r_nodes{end}(end);
    rr=zeros(NL*Nr,1); q=0; for e=1:NL, for ir=1:Nr, q=q+1; rr(q)=d.r_nodes{e}(ir); end, end
    xi=(rr-Ri)/(Ro-Ri); tsel=unique([0:tt/20:0.6*tt, 0.7*tt:0.1*tt:tt]);
    ns=zeros(size(tsel)); for j=1:numel(tsel), [~,ns(j)]=min(abs(tv-tsel(j))); end
    ns=unique(ns); cmap=flipud(gray(numel(ns)+2)); cmap=cmap(1:numel(ns),:);
    fg=figure('Position',[40 60 760 560],'Color','w'); hold on;
    for j=1:numel(ns), n=ns(j); Tt=zeros(NL*Nr,1); q=0;
        for e=1:NL, for ir=1:Nr, q=q+1; g=(e-1)*Nr*Nz+(ir-1)*Nz+iz0; Tt(q)=d.X_hist(g,n)/T_inf; end, end
        plot(xi,Tt,'-','Color',cmap(j,:),'LineWidth',1.0); end
    grid on; box on; set(gca,'FontName','Times New Roman','FontSize',10);
    xlabel('\xi   (inner \rightarrow outer)'); ylabel('T^*');
    title(sprintf('%s — thermal-wave front',strrep(nm,'_','\_')),'FontWeight','normal');
    print(fg,fullfile(bw,[nm '_wavefront.png']),'-dpng','-r130'); close(fg); fprintf('bw wf %s\n',nm);
end

%% ---- COLOUR 25-matrix ----
pats={'UD','O','X','V','A'}; qn={'Sigma_thth','Tstar'}; ql={'\Sigma_{\theta\theta}(\xi)','T^*(\xi)'};
for qty=1:2
    fg=figure('Position',[10 10 1500 1120],'Color','w');
    for gi=1:5, for pj=1:5
        nm=sprintf('H_%s_%s',pats{gi},pats{pj}); fp=fullfile(pdir,[nm '.mat']); if ~exist(fp,'file'), continue; end
        d=load(fp,'r_all','r_nodes','T_all','S_tt'); xi=(d.r_all(:)-d.r_nodes{1}(1))/(d.r_nodes{end}(end)-d.r_nodes{1}(1));
        subplot(5,5,(gi-1)*5+pj);
        if qty==1, y=Sst(d.S_tt); cl=[0 0.447 0.741]; else, y=Tst(d.T_all); cl=[0.85 0.325 0.098]; end
        plot(xi,y,'-','Color',cl,'LineWidth',1.0); grid on; box on;
        set(gca,'FontName','Times New Roman','FontSize',6);
        title(sprintf('%s-GPL + %s-Por',pats{gi},pats{pj}),'FontSize',6,'FontWeight','normal');
        ylabel(ql{qty},'FontSize',6); xlabel('\xi','FontSize',6);   % Prom.4: axis labels on every subplot
    end, end
    sgtitle(sprintf('25-case GPL \\times porosity matrix — %s',ql{qty}),'FontName','Times New Roman','FontSize',13);
    print(fg,fullfile(co,['matrix25_' qn{qty} '.png']),'-dpng','-r120'); close(fg); fprintf('color matrix %s\n',qn{qty});
end
fprintf('DONE variants\n');

function fin(ax,xl,yl,tl)
    grid(ax,'on'); box(ax,'on'); set(ax,'FontName','Times New Roman','FontSize',10);
    xlabel(ax,xl); ylabel(ax,yl); title(ax,tl,'FontWeight','normal');
end
function s=lgd(vals,nm)
    s=cell(1,numel(vals));
    for i=1:numel(vals)
        if contains(nm,'dt'), s{i}=sprintf('\\Deltat=%.1f',vals(i));
        elseif contains(nm,'Nr'), s{i}=sprintf('N_r=%d',vals(i));
        elseif contains(nm,'Nz'), s{i}=sprintf('N_z=%d',vals(i));
        else, s{i}=sprintf('N_L=%d',vals(i)); end
    end
end
