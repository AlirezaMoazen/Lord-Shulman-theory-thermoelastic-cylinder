%% claude_catalog_relax_finer_N35.m — C_relaxation 4-panel figure at N_r=35 (EXPLORATORY)
%  Part of the negative-temperature-dip investigation (2026-08-25/26). Reuses
%  the exact 4-panel format/dimensionless convention from claude_catalog_R6.m's
%  'C_relaxation' study (T*(Fo), U*(Fo), T*(xi), Sigma_thth(xi)) but reads the
%  finer-mesh (N_r=35, N_z=11, total_time=6000, dt=1) diagnostic data in
%  param_studies_relax_finer\ instead of the locked N_r=15 param_studies_ch4\
%  campaign. Purpose: let the author see how much the N_r=15 negative-T* dip
%  shrinks at N_r=35 for the three LS cases (Fourier's small residual dip is
%  separately confirmed to be real coupled-physics, not a discretization
%  artifact -- see chat). NOT part of the official campaign; output kept in
%  its own folder so it never touches figures_ch4_*. New file.
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

STY.co = {[0 0 0],[0 0 0],[0.45 0.45 0.45],[0.45 0.45 0.45]};
STY.ls = {'-','--',':','-.'};  STY.mk = {'o','s','^','d'};
STY.lw = [1.4 1.2 1.2 1.2];  FNT='Times New Roman'; FSZ=9;

cnames = {'C_FOURIER','C_TAU_004','C_TAU_015','C_TAU_044'};
labels = {'Fourier','\tau^*=0.04','0.15','0.44'};
D = cell(1,numel(cnames)); minT = nan(1,numel(cnames));
for ci = 1:numel(cnames)
    f = fullfile(pdir,[cnames{ci} '.mat']);
    D{ci} = load(f,'tv','hist_T','hist_U','r_nodes','r_all','T_all','S_tt');
    minT(ci) = min(Tst(D{ci}.T_all(:)));
    fprintf('%-10s min T* (N_r=35) = %+.5f\n', cnames{ci}, minT(ci));
end

f1 = figure('Position',[30 50 1180 820],'Color','w','Name','C_relaxation_N35');
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

print(f1, fullfile(cdir,'C_relaxation_N35.png'), '-dpng','-r130');
savefig(f1, fullfile(cdir,'C_relaxation_N35.fig')); close(f1);
fprintf('\nDONE -> %s\\C_relaxation_N35.png\n', cdir);

function curve(x,y,ci,STY)
    k=mod(ci-1,4)+1; x=x(:); y=y(:);
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
