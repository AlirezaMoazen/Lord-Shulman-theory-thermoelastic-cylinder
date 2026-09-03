%% catalog_conv_R2.m — CONVERGENCE / MINIMUM-NODES figures
%  Standalone "efficiency & minimum nodes per direction" study for Chapter 4.
%  Four refinement ladders: radial N_r, axial N_z, layers N_L, time-step dt.
%  Per ladder, a 2x2 figure:
%     (a) Sigma_thth(xi) profile overlay   (b) T*(xi) profile overlay
%     (c) convergence: L2 profile error + inner-hoop error vs node count (semilog)
%     (d) cost: N_dof (clean serial solve time for the N_z ladder)
%  Plus a master error-vs-Ndof figure (which direction is binding).
%  Anchor = BASE (N_r15, N_z11, N_L7, dt1), common to every ladder.
%  Reads param_studies_ch4 and writes figures to figures_ch4.
clearvars; clc; close all;
CLROOT='c:/Users/InfosaicUser/Desktop/MSc/Lord-Shulman-theory-thermoelastic-cylinder/claude';
pdir=fullfile(CLROOT,'param_studies_ch4'); cdir=fullfile(CLROOT,'figures_ch4'); if ~exist(cdir,'dir'), mkdir(cdir); end
T_inf=300; E_ref=4.433e9; nu_ref=0.3395; alp_ref=5.9814e-5;
Sst=@(s)(1+nu_ref).*s./(E_ref.*alp_ref.*T_inf);
Tst=@(T)(T-T_inf)./T_inf;
xic=linspace(0,1,200)';                 % common grid for L2 error

L(1)=struct('nm','conv_Nr','cases',{{'SM_NR07','SM_NR09','SM_NR11','SM_NR13','BASE'}},...
    'val',[7 9 11 13 15],'xl','N_r  (radial nodes / layer)','ct','Ndof','cost',[]);
L(2)=struct('nm','conv_Nz','cases',{{'SM_NZ05','SM_NZ07','SM_NZ09','BASE','SM_NZ13','SM_NZ15'}},...
    'val',[5 7 9 11 13 15],'xl','N_z  (axial nodes)','ct','time','cost',[90 198 349 NaN 987 1630]);
L(3)=struct('nm','conv_NL','cases',{{'L_NL_3','L_NL_5','BASE','L_NL_9','L_NL_15'}},...
    'val',[3 5 7 9 15],'xl','N_L  (layers)','ct','Ndof','cost',[]);
L(4)=struct('nm','conv_dt','cases',{{'TI_DT_05','BASE','TI_DT_20','TI_DT_50'}},...
    'val',[0.5 1 2 5],'xl','\Deltat  (s)','ct','steps','cost',[]);

master=struct('lab',{},'nd',{},'er',{});
for li=1:numel(L)
    cs=L(li).cases; nv=L(li).val; nc=numel(cs); D=cell(1,nc); ok=true;
    for ci=1:nc
        f=fullfile(pdir,[cs{ci} '.mat']);
        if ~exist(f,'file'), fprintf('MISS %s\n',cs{ci}); ok=false; break; end
        D{ci}=load(f,'S_tt','T_all','r_all','r_nodes','NL','N_r','N_z');
    end
    if ~ok, continue; end
    if strcmp(L(li).nm,'conv_dt'), ref=1; else, ref=nc; end   % finest = last (dt: first)
    getxi=@(d)(d.r_all(:)-d.r_nodes{1}(1))/(d.r_nodes{end}(end)-d.r_nodes{1}(1));
    dd=@(x,y) deal_unique(x,y);
    [xr,Sr]=dd(getxi(D{ref}),Sst(D{ref}.S_tt)); Sref=interp1(xr,Sr,xic,'pchip');
    eL2=zeros(1,nc); ein=zeros(1,nc); nd=zeros(1,nc);
    for ci=1:nc
        d=D{ci}; [xu,Su]=dd(getxi(d),Sst(d.S_tt)); Si=interp1(xu,Su,xic,'pchip');
        eL2(ci)=100*norm(Si-Sref)/norm(Sref);
        S=Sst(d.S_tt); ein(ci)=100*abs(S(1)-Sr(1))/abs(Sr(1));
        nd(ci)=3*d.NL*d.N_r*d.N_z;
    end

    cmap=lines(nc);
    fg=figure('Position',[20 40 1200 900],'Color','w','Name',L(li).nm);
    subplot(2,2,1); hold on;
    for ci=1:nc, d=D{ci}; plot(getxi(d),Sst(d.S_tt),'-','Color',cmap(ci,:),'LineWidth',1.4); end
    fin(gca,'\xi','\Sigma_{\theta\theta}','(a) hoop-stress profile'); legend(lg(nv,L(li).nm),'Location','best','FontSize',8);
    subplot(2,2,2); hold on;
    for ci=1:nc, d=D{ci}; plot(getxi(d),Tst(d.T_all),'-','Color',cmap(ci,:),'LineWidth',1.4); end
    fin(gca,'\xi','T^*','(b) temperature profile');
    subplot(2,2,3);
    semilogy(nv,max(eL2,1e-4),'ko-','LineWidth',1.5,'MarkerFaceColor','k'); hold on;
    semilogy(nv,max(ein,1e-4),'s-','Color',[.55 .55 .55],'LineWidth',1.2,'MarkerFaceColor',[.55 .55 .55]);
    yline(1,'-','Color',[0.3 0.3 0.3]); yline(0.1,'-','Color',[0.7 0.7 0.7]); fin(gca,L(li).xl,'rel. error vs finest (%)','(c) convergence');
    legend({'L_2 profile','inner hoop','1%','0.1%'},'Location','best','FontSize',8);
    subplot(2,2,4);
    if strcmp(L(li).ct,'time'), cc=L(li).cost; m=~isnan(cc);
        plot(nv(m),cc(m),'ko-','LineWidth',1.5,'MarkerFaceColor','k'); yl='solve time (s, serial)';
    elseif strcmp(L(li).ct,'steps'), plot(nv,3000./nv,'ko-','LineWidth',1.5,'MarkerFaceColor','k'); yl='N_{steps}';
    else, plot(nv,nd,'ko-','LineWidth',1.5,'MarkerFaceColor','k'); yl='N_{dof}=3 N_L N_r N_z'; end
    fin(gca,L(li).xl,yl,'(d) cost');
    print(fg,fullfile(cdir,[L(li).nm '.png']),'-dpng','-r140'); savefig(fg,fullfile(cdir,[L(li).nm '.fig'])); close(fg);
    fprintf('%s  L2err=[%s]  innerHoopErr=[%s] %%\n',L(li).nm,sprintf('%.3f ',eL2),sprintf('%.3f ',ein));
    if ~strcmp(L(li).nm,'conv_dt')        % dt does not change Ndof -> not on the Ndof master
        emr=eL2; emr(ref)=NaN;            % drop the self-reference (0-error) point -> no cliff
        master(end+1)=struct('lab',L(li).nm(6:end),'nd',nd,'er',emr); %#ok<SAGROW>
    end
end

fgm=figure('Position',[60 60 820 620],'Color','w','Name','conv_master'); hold on;
mk={'o','s','^','d'}; cm=lines(numel(master));
for i=1:numel(master), [ns,is]=sort(master(i).nd);
    semilogy(ns,master(i).er(is),['-' mk{i}],'Color',cm(i,:),'LineWidth',1.6,'MarkerFaceColor',cm(i,:),'MarkerSize',6); end
set(gca,'YScale','log'); yline(1,'-','Color',[0.3 0.3 0.3]); yline(0.1,'-','Color',[0.7 0.7 0.7]);
fin(gca,'N_{dof} = 3 N_L N_r N_z','L_2 error in hoop profile (%)','Minimum nodes: error vs problem size, by direction');
legend([{master.lab},{'1%','0.1%'}],'Location','best','FontSize',9);
print(fgm,fullfile(cdir,'conv_master.png'),'-dpng','-r140'); savefig(fgm,fullfile(cdir,'conv_master.fig')); close(fgm);
fprintf('conv figures done -> %s\n',cdir);

function fin(ax,xl,yl,tl) %#ok<INUSD>
    grid(ax,'on'); box(ax,'on'); set(ax,'FontName','Times New Roman','FontSize',10);
    xlabel(ax,xl); ylabel(ax,yl);
end
function [xu,yu]=deal_unique(x,y)
    [xu,iu]=unique(round(x(:),10)); yu=y(iu);
end
function s=lg(vals,nm)
    s=cell(1,numel(vals));
    for i=1:numel(vals)
        if contains(nm,'dt'), s{i}=sprintf('\\Deltat=%.1f',vals(i));
        elseif contains(nm,'Nr'), s{i}=sprintf('N_r=%d',vals(i));
        elseif contains(nm,'Nz'), s{i}=sprintf('N_z=%d',vals(i));
        else, s{i}=sprintf('N_L=%d',vals(i)); end
    end
end
