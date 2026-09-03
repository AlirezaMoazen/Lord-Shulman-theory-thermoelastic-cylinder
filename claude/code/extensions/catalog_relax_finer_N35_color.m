%% claude_catalog_relax_finer_N35_color.m — COLOR C_relaxation 4-panel at N_r=35 (EXPLORATORY)
%  Color mirror of claude_catalog_relax_finer_N35.m (B&W), same relationship
%  as claude_catalog_R6.m / claude_catalog_R6_color.m: same style/legend
%  convention as the official color 4-panel (claude_catalog_R6_color.m's
%  STY: blue/orange, solid lines, white-face markers). Author request:
%  only Fourier + tau*=0.15 (the two cases under active investigation),
%  not all 4 relaxation-time cases. Reads the finer-mesh (N_r=35)
%  diagnostic data in param_studies_relax_finer\. NOT part of the official
%  campaign; output kept in its own folder. New file.
clearvars; clc; close all;
pdir = 'param_studies_relax_finer';
cdir = 'results_extensions/figures_relax_finer';
if ~exist(cdir,'dir'), mkdir(cdir); end

ahat  = 8.9708e-5;
E_ref = 4.433e9;  nu_ref = 0.3395; alp_ref = 5.9814e-5;
T_inf = 300;
Fo  = @(t,h) ahat.*t./h.^2;
Tst = @(T)   (T - T_inf)./T_inf;
Ust = @(u,h) u./((1-nu_ref).*alp_ref.*T_inf.*h);
Sst = @(s)   (1+nu_ref).*s./(E_ref.*alp_ref.*T_inf);

% COLOUR style set (matches claude_catalog_R6_color.m exactly, first 2 entries)
STY.co = {[0 0.447 0.741],[0.850 0.325 0.098]};
STY.ls = {'-','-'};  STY.mk = {'o','s'};
STY.lw = [1.6 1.4];  FNT='Times New Roman'; FSZ=9;

cnames = {'C_FOURIER','C_TAU_015'};
labels = {'Fourier','LS'};
D = cell(1,numel(cnames));
for ci = 1:numel(cnames)
    f = fullfile(pdir,[cnames{ci} '.mat']);
    D{ci} = load(f,'tv','hist_T','hist_U','r_nodes','r_all','T_all','S_tt');
end

f1 = figure('Position',[30 50 1180 820],'Color','w','Name','C_relaxation_N35_color');
subplot(2,2,1); hold on;
for ci=1:numel(cnames)
    d=D{ci}; hh=d.r_nodes{end}(end)-d.r_nodes{1}(1);
    curve(Fo(d.tv,hh), Tst(d.hist_T), ci, STY);
end
fin(gca,FNT,FSZ,'Fo','T^*'); legend(labels,'Location','best','FontSize',8,'FontName',FNT);
subplot(2,2,2); hold on;
for ci=1:numel(cnames)
    d=D{ci}; hh=d.r_nodes{end}(end)-d.r_nodes{1}(1);
    curve(Fo(d.tv,hh), Ust(d.hist_U,hh), ci, STY);
end
fin(gca,FNT,FSZ,'Fo','U^*');
subplot(2,2,3); hold on;
for ci=1:numel(cnames)
    d=D{ci}; Ri=d.r_nodes{1}(1); Ro=d.r_nodes{end}(end);
    xi=(d.r_all(:)-Ri)/(Ro-Ri);
    curve(xi, Tst(d.T_all), ci, STY);
end
fin(gca,FNT,FSZ,'\xi','T^*');
subplot(2,2,4); hold on;
for ci=1:numel(cnames)
    d=D{ci}; Ri=d.r_nodes{1}(1); Ro=d.r_nodes{end}(end);
    xi=(d.r_all(:)-Ri)/(Ro-Ri);
    curve(xi, Sst(d.S_tt), ci, STY);
end
fin(gca,FNT,FSZ,'\xi','\Sigma_{\theta\theta}');

print(f1, fullfile(cdir,'C_relaxation_N35_color.png'), '-dpng','-r130');
savefig(f1, fullfile(cdir,'C_relaxation_N35_color.fig')); close(f1);
fprintf('\nDONE -> %s\\C_relaxation_N35_color.png\n', cdir);

function curve(x,y,ci,STY)
    k=mod(ci-1,2)+1; x=x(:); y=y(:);
    if all(isnan(y))||numel(x)<2, return; end
    % light adaptive smoothing to declutter small-scale sample-to-sample
    % noise (second-sound reflections) while keeping the genuine sharp
    % wavefront jump intact -- window scales with series length so sparse
    % spatial profiles are left essentially untouched.
    w = max(1, round(numel(y)*0.01));
    if w > 1, y = smoothdata(y,'movmean',w); end
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
