%% claude_catalog_R6_full.m — FULL-COMPONENT Chapter-4 catalog (new geometry)
%  Companion to claude_catalog_R6.m (4-panel selection). This one shows EVERY
%  field component per study so figures can be chosen for Chapter 4:
%    Part 1  <study>_hist.png (1x3): T*(Fo)  u*(Fo)  w*(Fo)   [mid-point histories]
%    Part 2  <study>_prof.png (2x4): T*  eps_rr eps_thth eps_zz   (row 1)
%                                    u*  Sig_rr Sig_thth Sig_zz  (row 2)   vs xi
%  Dimensionless convention = app10041397 (Heydarpour), same as R6:
%    Fo=ahat t/h^2, T*=(T-Tinf)/Tinf, U*=u/[(1-nu)alpha Tinf h],
%    Sig*=(1+nu)sig/(E alpha Tinf), xi=(r-Ri)/(Ro-Ri), h=R_o-R_i.
%  Strains are kinematic-exact: eps_thth=u/r, eps_rr=du/dr (DQ), and eps_zz from
%  the SAVED final stresses via Hooke (2*mu read per-layer from the same data) —
%  the R5 method (verbatim helpers strainprof/dqA), correct for any pattern.
%  Reference props = BASE material (W=0.3%, e_m3=0.8604), fixed for all cases.
%  New revision file; modifies no solver or earlier catalog.
clearvars; clc; close all;
pdir='param_studies_ch4'; cdir='figures_ch4'; if ~exist(cdir,'dir'), mkdir(cdir); end

ahat=8.9708e-5; E_ref=4.433e9; nu_ref=0.3395; alp_ref=5.9814e-5; T_inf=300;
Fo =@(t,h) ahat.*t./h.^2;
Tst=@(T)   (T-T_inf)./T_inf;
Ust=@(u,h) u./((1-nu_ref).*alp_ref.*T_inf.*h);
Sst=@(s)   (1+nu_ref).*s./(E_ref.*alp_ref.*T_inf);

STY.co={[0 0 0],[0 0 0],[0.45 0.45 0.45],[0.45 0.45 0.45],[0.68 0.68 0.68]};
STY.ls={'-','--',':','-.','-'}; STY.mk={'o','s','^','d','v'};
STY.lw=[1.4 1.2 1.2 1.2 1.4]; FNT='Times New Roman'; FSZ=9;

studies = { ...
 'A_GPL_patterns',     {'BASE','A_GPL_O','A_GPL_X','A_GPL_V','A_GPL_A'}, {'UD','O','X','V','A'};
 'B_porosity_patterns',{'BASE','B_POR_O','B_POR_X','B_POR_V','B_POR_A'}, {'UD','O','X','V','A'};
 'E_porosity_level',   {'E_EM3_9675','BASE','E_EM3_7776'}, {'e_{m3}=0.9675','0.8604','0.7776'};
 'D_wt_low',           {'D_W_001','BASE','D_W_005','D_W_009','D_W_015'}, {'W=0.1%','0.3%','0.5%','0.9%','1.5%'};
 'D2_wt_high',         {'D2_W_010','D2_W_020','D2_W_040','D2_W_080'}, {'W=1%','2%','4%','8%'};
 'C_relaxation',       {'C_FOURIER','C_TAU_004','C_TAU_015','C_TAU_044','C_TAU_087'}, {'Fourier','\tau^*=0.04','0.15','0.44','0.87'};
 'F_end_BC',           {'BASE','F_BC_SC','F_BC_C'}, {'S-S','S-C','C-C'};
 'G_pressure',         {'G_P000','G_P010','BASE','G_P100'}, {'P_i=0','10 MPa','50 MPa','100 MPa'};
 'I_coupling',         {'BASE','I_UNCOUPLED'}, {'coupled','uncoupled'};
 'J_convection',       {'BASE','J_HC_100','J_HC_1000'}, {'h_c=10','100','1000'};
 'K_thickness',        {'K_RO_125','BASE','K_RO_200'}, {'R_o/R_i=1.25','1.5','2.0'};
 'L_layers',           {'L_NL_3','L_NL_5','BASE','L_NL_9','L_NL_15'}, {'N_L=3','5','7','9','15'};
 'Q_length',           {'Q_L_1','BASE','Q_L_5','Q_L_10'}, {'L=1','2.1','5','10'};
 'O_aspect_ab',        {'O_AB_100','BASE','O_AB_267'}, {'a/b=1.0','1.67','2.67'};
 'P_aspect_bt',        {'P_BT_500','BASE','P_BT_2000'}, {'b/t=500','1000','2000'};
 'M_gauss_shock',      {'M_GAUSS_LS','M_GAUSS_FOU'}, {'LS','Fourier'};
 'T3_theories',        {'C_FOURIER','C_TAU_015','T3_DPL','T3_GN3'}, {'Fourier','LS','DPL','GN-III'} };

made={};
for si=1:size(studies,1)
    sname=studies{si,1}; cnames=studies{si,2}; labels=studies{si,3};
    D={}; ok=true;
    for ci=1:numel(cnames)
        f=fullfile(pdir,[cnames{ci} '.mat']);
        if ~exist(f,'file'), fprintf('SKIP %s (missing %s)\n',sname,cnames{ci}); ok=false; break; end
        D{ci}=load(f,'tv','hist_T','hist_U','hist_W','r_nodes','r_all','T_all','U_all','S_rr','S_tt','S_zz','NL','N_r'); %#ok<SAGROW>
    end
    if ~ok, continue; end
    hOf =@(d) d.r_nodes{end}(end)-d.r_nodes{1}(1);
    xiOf=@(d) (d.r_all(:)-d.r_nodes{1}(1))/(d.r_nodes{end}(end)-d.r_nodes{1}(1));

    % ===== PART 1: mid-point time histories (1x3) =====
    f1=figure('Position',[40 60 1360 430],'Color','w','Name',[sname '_hist']);
    subplot(1,3,1); hold on;
    for ci=1:numel(cnames), d=D{ci}; curve(Fo(d.tv,hOf(d)),Tst(d.hist_T),ci,STY); end
    fin(gca,FNT,FSZ,'Fo','T^*','(1) T^* history'); legend(labels,'Location','best','FontSize',8,'FontName',FNT);
    subplot(1,3,2); hold on;
    for ci=1:numel(cnames), d=D{ci}; curve(Fo(d.tv,hOf(d)),Ust(d.hist_U,hOf(d)),ci,STY); end
    fin(gca,FNT,FSZ,'Fo','u^*','(2) u^* history (radial)');
    subplot(1,3,3); hold on;
    for ci=1:numel(cnames), d=D{ci}; curve(Fo(d.tv,hOf(d)),Ust(d.hist_W,hOf(d)),ci,STY); end
    fin(gca,FNT,FSZ,'Fo','w^*','(3) w^* history (axial)');
    sgtitle(sprintf('%s  —  part 1: time histories',strrep(sname,'_','\_')),'FontName',FNT,'FontSize',12);
    print(f1,fullfile(cdir,[sname '_hist.png']),'-dpng','-r130'); savefig(f1,fullfile(cdir,[sname '_hist.fig'])); close(f1);

    % ===== PART 2: final radial profiles (2x4): T*, 3 strains, u*, 3 stresses =====
    f2=figure('Position',[20 40 1660 760],'Color','w','Name',[sname '_prof']);
    subplot(2,4,1); hold on;
    for ci=1:numel(cnames), d=D{ci}; curve(xiOf(d),Tst(d.T_all),ci,STY); end
    fin(gca,FNT,FSZ,'\xi','T^*','(1) T^*(\xi)'); legend(labels,'Location','best','FontSize',8,'FontName',FNT);
    subplot(2,4,2); hold on;
    for ci=1:numel(cnames), d=D{ci}; [er,~,~]=strainprof(d); curve(xiOf(d),er,ci,STY); end
    fin(gca,FNT,FSZ,'\xi','\epsilon_{rr}','(2) \epsilon_{rr}(\xi) radial');
    subplot(2,4,3); hold on;
    for ci=1:numel(cnames), d=D{ci}; [~,et,~]=strainprof(d); curve(xiOf(d),et,ci,STY); end
    fin(gca,FNT,FSZ,'\xi','\epsilon_{\theta\theta}','(3) \epsilon_{\theta\theta}(\xi) hoop');
    subplot(2,4,4); hold on;
    for ci=1:numel(cnames), d=D{ci}; [~,~,ez]=strainprof(d); curve(xiOf(d),ez,ci,STY); end
    fin(gca,FNT,FSZ,'\xi','\epsilon_{zz}','(4) \epsilon_{zz}(\xi) axial [Hooke]');
    subplot(2,4,5); hold on;
    for ci=1:numel(cnames), d=D{ci}; curve(xiOf(d),Ust(d.U_all,hOf(d)),ci,STY); end
    fin(gca,FNT,FSZ,'\xi','u^*','(5) u^*(\xi)');
    subplot(2,4,6); hold on;
    for ci=1:numel(cnames), d=D{ci}; curve(xiOf(d),Sst(d.S_rr),ci,STY); end
    fin(gca,FNT,FSZ,'\xi','\Sigma_{rr}','(6) \Sigma_{rr}(\xi)');
    subplot(2,4,7); hold on;
    for ci=1:numel(cnames), d=D{ci}; curve(xiOf(d),Sst(d.S_tt),ci,STY); end
    fin(gca,FNT,FSZ,'\xi','\Sigma_{\theta\theta}','(7) \Sigma_{\theta\theta}(\xi)');
    subplot(2,4,8); hold on;
    for ci=1:numel(cnames), d=D{ci}; curve(xiOf(d),Sst(d.S_zz),ci,STY); end
    fin(gca,FNT,FSZ,'\xi','\Sigma_{zz}','(8) \Sigma_{zz}(\xi)');
    sgtitle(sprintf('%s  —  part 2: final-time radial profiles (strains + stresses)',strrep(sname,'_','\_')),'FontName',FNT,'FontSize',12);
    print(f2,fullfile(cdir,[sname '_prof.png']),'-dpng','-r130'); savefig(f2,fullfile(cdir,[sname '_prof.fig'])); close(f2);

    made{end+1}=sname; %#ok<SAGROW>
    fprintf('full catalog: %s\n',sname);
end
fprintf('\nDONE full: %d studies x 2 parts -> %s\n',numel(made),cdir);

%% ---- helpers (strainprof + dqA verbatim from R5; curve/fin shared) ----
function [err,ett,ezz]=strainprof(d)
    NL=d.NL; Nr=d.N_r;
    ett=d.U_all(:)./d.r_all(:);
    err=zeros(numel(d.U_all),1);
    for e=1:NL
        Ar=dqA(d.r_nodes{e}); idx=(e-1)*Nr+(1:Nr);
        err(idx)=Ar*d.U_all(idx).';
    end
    Srr=d.S_rr(:); Stt=d.S_tt(:); Szz=d.S_zz(:);
    ezz=nan(numel(d.U_all),1);
    for e=1:NL
        idx=(e-1)*Nr+(1:Nr);
        ei=err(idx); ei=ei(:); ti=ett(idx); ti=ti(:);
        sr=Srr(idx); sr=sr(:); st=Stt(idx); st=st(:); sz=Szz(idx); sz=sz(:);
        de=ei-ti; ds=sr-st; den=de.'*de;
        if den>1e-30, twomu=(de.'*ds)/den;
        else, dg=err(:)-ett(:); twomu=(dg.'*(Srr(:)-Stt(:)))/(dg.'*dg); end
        ezz(idx)=0.5*(ei+ti)-0.5*((sr+st-2*sz)/twomu);
    end
end
function A=dqA(x)
    x=x(:); N=numel(x); A=zeros(N);
    for i=1:N, for j=1:N
        if i~=j
            num=1; den=1;
            for k=1:N, if k~=i && k~=j, num=num*(x(i)-x(k)); den=den*(x(j)-x(k)); end, end
            A(i,j)=num/(den*(x(j)-x(i)));
        end
    end, end
    for i=1:N, A(i,i)=-sum(A(i,:)); end
end
function curve(x,y,ci,STY)
    k=mod(ci-1,5)+1; x=x(:); y=y(:);
    if all(isnan(y))||numel(x)<2, return; end
    xm=x; for i=2:numel(xm), if xm(i)<=xm(i-1), xm(i)=xm(i-1)+1e-12; end, end
    nP=max(300,numel(x)); xf=linspace(xm(1),xm(end),nP); yf=interp1(xm,y,xf,'makima');
    mi=unique(round(linspace(1,nP,8)));
    plot(xf,yf,'Color',STY.co{k},'LineStyle',STY.ls{k},'LineWidth',STY.lw(k),...
        'Marker',STY.mk{k},'MarkerIndices',mi,'MarkerSize',4.5,'MarkerFaceColor','w');
end
function fin(ax,FNT,FSZ,xl,yl,tl)
    grid(ax,'on'); box(ax,'on'); set(ax,'FontName',FNT,'FontSize',FSZ);
    xlabel(ax,xl,'FontName',FNT); ylabel(ax,yl,'FontName',FNT);
    title(ax,tl,'FontName',FNT,'FontWeight','normal','FontSize',FSZ+1);
end
