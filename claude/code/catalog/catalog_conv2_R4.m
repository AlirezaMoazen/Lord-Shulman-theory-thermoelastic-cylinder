%% catalog_conv2_R4.m — 2-panel convergence PROFILE figures (legend on both panels)
%  For each spatial direction (N_r, N_z, N_L): a 2-panel figure
%    (a) hoop-stress profile   (b) temperature profile   overlaying the meshes.
%  The error/cost panels are reported as tables in the chapter text instead.
%  Rendered in B&W (-> figures_ch4_bw) and colour (-> figures_ch4_color); no sgtitle.
%  Run from claude/ :  addpath('code/catalog'); catalog_conv2_R2
clearvars; clc; close all;
pdir='param_studies_ch4'; bw='figures_ch4_bw_R10'; co='figures_ch4_color_R10';
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
    tl=tiledlayout(fg,1,2,'TileSpacing','tight','Padding','tight');
    nexttile(tl); hold on;
    for ci=1:nc, d=D{ci}; k=mod(ci-1,6)+1; plot(gx(d),Sst(d.S_tt),'Color',CO{k},'LineStyle',LS{k},'LineWidth',1.4); end
    grid on; box on; set(gca,'FontName','Times New Roman','FontSize',14);
    xlabel('\xi'); ylabel('\Sigma_{\theta\theta}');   % no panel title
    place_legend(gca,lg,'Times New Roman',14,L(li).nm,1);
    nexttile(tl); hold on;
    for ci=1:nc, d=D{ci}; k=mod(ci-1,6)+1; plot(gx(d),Tst(d.T_all),'Color',CO{k},'LineStyle',LS{k},'LineWidth',1.4); end
    grid on; box on; set(gca,'FontName','Times New Roman','FontSize',14);
    xlabel('\xi'); ylabel('T^*');   % no panel title
    place_legend(gca,lg,'Times New Roman',14,L(li).nm,2);
    print(fg,fullfile(outdir,[L(li).nm '.png']),'-dpng','-r140'); close(fg);
  end
  fprintf('conv2 %s\n',L(li).nm);
end
fprintf('DONE conv2\n');
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
    fprintf('    %-18s panel %d: legend %-13s covered points = %d\n', sname, panel, bestLoc, bestN);
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

