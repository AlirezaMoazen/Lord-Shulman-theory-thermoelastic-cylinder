%% catalog_conv_explore_R2.m — EXPLORATORY convergence / master figure
%  Standalone diagnostic convergence study at anchor N_r=11, N_z=13, N_L=7
%  (distinct from the locked reference mesh N_r=15/N_z=11 used by the
%  main Chapter-4 campaign). Same structure/quantities as
%  catalog_conv.m, pointed at param_studies_conv_explore/ and its
%  own case names. No time-step (dt) ladder in this study.
%  Reads param_studies_conv_explore and writes figures to figures_conv_explore.
clearvars; clc; close all;
CLROOT='c:/Users/InfosaicUser/Desktop/MSc/Lord-Shulman-theory-thermoelastic-cylinder/claude';
pdir=fullfile(CLROOT,'param_studies_conv_explore'); cdir=fullfile(CLROOT,'figures_conv_explore');
if ~exist(cdir,'dir'), mkdir(cdir); end
T_inf=300; E_ref=4.433e9; nu_ref=0.3395; alp_ref=5.9814e-5;
Sst=@(s)(1+nu_ref).*s./(E_ref.*alp_ref.*T_inf);
Tst=@(T)(T-T_inf)./T_inf;
xic=linspace(0,1,200)';                 % common grid for L2 error

% anchor = EXP_ANCHOR (Nr=11, Nz=13, NL=7), shared by all three ladders
L(1)=struct('nm','conv_Nr','cases',{{'EXP_NR05','EXP_NR07','EXP_NR09','EXP_ANCHOR','EXP_NR13','EXP_NR15'}},...
    'val',[5 7 9 11 13 15],'xl','N_r  (radial nodes / layer)','ct','Ndof','cost',[]);
L(2)=struct('nm','conv_Nz','cases',{{'EXP_NZ05','EXP_NZ07','EXP_NZ09','EXP_NZ11','EXP_ANCHOR','EXP_NZ15'}},...
    'val',[5 7 9 11 13 15],'xl','N_z  (axial nodes)','ct','Ndof','cost',[]);
L(3)=struct('nm','conv_NL','cases',{{'EXP_NL03','EXP_NL05','EXP_ANCHOR','EXP_NL09','EXP_NL15'}},...
    'val',[3 5 7 9 15],'xl','N_L  (layers)','ct','Ndof','cost',[]);

master=struct('lab',{},'nd',{},'er',{});
for li=1:numel(L)
    cs=L(li).cases; nv=L(li).val; nc=numel(cs); D=cell(1,nc); ok=true;
    for ci=1:nc
        f=fullfile(pdir,[cs{ci} '.mat']);
        if ~exist(f,'file'), fprintf('MISS %s\n',cs{ci}); ok=false; break; end
        D{ci}=load(f,'S_tt','T_all','r_all','r_nodes','NL','N_r','N_z');
    end
    if ~ok, continue; end
    ref=nc;   % finest = last for every ladder here
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
    plot(nv,nd,'ko-','LineWidth',1.5,'MarkerFaceColor','k'); yl='N_{dof}=3 N_L N_r N_z';
    fin(gca,L(li).xl,yl,'(d) cost');
    print(fg,fullfile(cdir,[L(li).nm '.png']),'-dpng','-r140'); savefig(fg,fullfile(cdir,[L(li).nm '.fig'])); close(fg);
    fprintf('%s  L2err=[%s]  innerHoopErr=[%s] %%\n',L(li).nm,sprintf('%.3f ',eL2),sprintf('%.3f ',ein));
    emr=eL2; emr(ref)=NaN;            % drop the self-reference (0-error) point -> no cliff
    master(end+1)=struct('lab',L(li).nm(6:end),'nd',nd,'er',emr); %#ok<SAGROW>
end

fgm=figure('Position',[60 60 820 620],'Color','w','Name','conv_master_explore'); hold on;
mk={'o','s','^'}; cm=lines(numel(master));
for i=1:numel(master), [ns,is]=sort(master(i).nd);
    semilogy(ns,master(i).er(is),['-' mk{i}],'Color',cm(i,:),'LineWidth',1.6,'MarkerFaceColor','w','MarkerSize',6); end
set(gca,'YScale','log'); yline(1,'-','Color',[0.3 0.3 0.3]); yline(0.1,'-','Color',[0.7 0.7 0.7]);
fin(gca,'N_{dof} = 3 N_L N_r N_z','L_2 error in hoop profile (%)','Minimum nodes: error vs problem size, by direction (anchor N_r=11, N_z=13, N_L=7)');
legend([{master.lab},{'1%','0.1%'}],'Location','best','FontSize',9);
print(fgm,fullfile(cdir,'conv_master_explore.png'),'-dpng','-r140'); savefig(fgm,fullfile(cdir,'conv_master_explore.fig')); close(fgm);
fprintf('conv_explore figures done -> %s\n',cdir);

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
        if contains(nm,'Nr'), s{i}=sprintf('N_r=%d',vals(i));
        elseif contains(nm,'Nz'), s{i}=sprintf('N_z=%d',vals(i));
        else, s{i}=sprintf('N_L=%d',vals(i)); end
    end
end
