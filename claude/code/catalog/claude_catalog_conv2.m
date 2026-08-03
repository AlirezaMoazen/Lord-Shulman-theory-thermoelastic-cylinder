%% claude_catalog_conv2.m — 2-panel convergence PROFILE figures (Prom.4 #9)
%  For each spatial direction (N_r, N_z, N_L): a 2-panel figure
%    (a) hoop-stress profile   (b) temperature profile   overlaying the meshes.
%  The old error/cost panels (c),(d) are replaced by TABLES in the chapter text.
%  Rendered in B&W (-> figures_ch4_bw) and colour (-> figures_ch4_color); no sgtitle.
%  Run from claude/ :  matlab -batch "run('code/catalog/claude_catalog_conv2.m')"
clearvars; clc; close all;
pdir='param_studies_ch4'; bw='figures_ch4_bw'; co='figures_ch4_color';
if ~exist(bw,'dir'), mkdir(bw); end
if ~exist(co,'dir'), mkdir(co); end
T_inf=300; E_ref=4.433e9; nu_ref=0.3395; alp_ref=5.9814e-5;
Sst=@(s)(1+nu_ref).*s./(E_ref.*alp_ref.*T_inf); Tst=@(T)(T-T_inf)./T_inf;
L(1)=struct('nm','conv_Nr','cases',{{'SM_NR07','SM_NR09','SM_NR11','SM_NR13','BASE'}},'val',[7 9 11 13 15],'sym','N_r');
L(2)=struct('nm','conv_Nz','cases',{{'SM_NZ05','SM_NZ07','SM_NZ09','BASE','SM_NZ13','SM_NZ15'}},'val',[5 7 9 11 13 15],'sym','N_z');
L(3)=struct('nm','conv_NL','cases',{{'L_NL_3','L_NL_5','BASE','L_NL_9','L_NL_15'}},'val',[3 5 7 9 15],'sym','N_L');
BWc={[0 0 0],[0.35 0.35 0.35],[0.6 0.6 0.6],[0.35 0.35 0.35],[0 0 0],[0.6 0.6 0.6]};
BWs={'-','--',':','-.','-','--'};
COc=lines(6);
for li=1:numel(L)
  cs=L(li).cases; nv=L(li).val; nc=numel(cs); D=cell(1,nc); ok=true;
  for ci=1:nc, f=fullfile(pdir,[cs{ci} '.mat']); if ~exist(f,'file'), ok=false; break; end
    D{ci}=load(f,'S_tt','T_all','r_all','r_nodes'); end
  if ~ok, fprintf('skip %s\n',L(li).nm); continue; end
  gx=@(d)(d.r_all(:)-d.r_nodes{1}(1))/(d.r_nodes{end}(end)-d.r_nodes{1}(1));
  lg=arrayfun(@(v)sprintf('%s=%d',L(li).sym,v),nv,'uni',0);
  for mode=1:2
    if mode==1, CO=BWc; LS=BWs; outdir=bw; else, CO=num2cell(COc,2)'; LS=repmat({'-'},1,6); outdir=co; end
    fg=figure('Position',[40 60 1180 460],'Color','w');
    subplot(1,2,1); hold on;
    for ci=1:nc, d=D{ci}; k=mod(ci-1,6)+1; plot(gx(d),Sst(d.S_tt),'Color',CO{k},'LineStyle',LS{k},'LineWidth',1.4); end
    grid on; box on; set(gca,'FontName','Times New Roman','FontSize',10);
    xlabel('\xi'); ylabel('\Sigma_{\theta\theta}');   % Prom.5: panel title removed per author
    legend(lg,'Location','best','FontSize',8);
    subplot(1,2,2); hold on;
    for ci=1:nc, d=D{ci}; k=mod(ci-1,6)+1; plot(gx(d),Tst(d.T_all),'Color',CO{k},'LineStyle',LS{k},'LineWidth',1.4); end
    grid on; box on; set(gca,'FontName','Times New Roman','FontSize',10);
    xlabel('\xi'); ylabel('T^*');   % Prom.5: panel title removed per author
    print(fg,fullfile(outdir,[L(li).nm '.png']),'-dpng','-r140'); close(fg);
  end
  fprintf('conv2 %s\n',L(li).nm);
end
fprintf('DONE conv2\n');
