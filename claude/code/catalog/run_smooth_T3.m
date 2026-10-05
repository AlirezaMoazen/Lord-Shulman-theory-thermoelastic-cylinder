%% run_smooth_T3.m — Generate smoothed GN-III / T3_theories figures for review
clearvars; clc; close all;

here = 'c:\Users\InfosaicUser\Desktop\MSc\Lord-Shulman-theory-thermoelastic-cylinder\claude';
pdir = fullfile(here, 'param_studies_ch4');
art_dir = 'C:\Users\InfosaicUser\.gemini\antigravity\brain\c228d96d-1584-4032-8693-ecc7fe85aa1b';

% Reference params
ahat = 8.9708e-5; E_ref = 4.433e9; nu_ref = 0.3395; alp_ref = 5.9814e-5; T_inf = 300;
Fo = @(t,h) ahat.*t./h.^2;
Tst = @(T) (T - T_inf)./T_inf;
Ust = @(u,h) u./((1-nu_ref).*alp_ref.*T_inf.*h);
Sst = @(s) (1+nu_ref).*s./(E_ref.*alp_ref.*T_inf);

cnames = {'C_FOURIER','C_TAU_015','T3_DPL','T3_GN3'};
labels = {'Fourier','LS','DPL','GN-III'};

D = {};
for ci = 1:numel(cnames)
    f = fullfile(pdir, [cnames{ci} '.mat']);
    D{ci} = load(f, 'tv', 'hist_T', 'hist_U', 'r_nodes', 'r_all', 'T_all', 'S_tt');
end

% B&W STY
STY_bw.co = {[0 0 0],[0 0 0],[0.45 0.45 0.45],[0.45 0.45 0.45],[0.68 0.68 0.68]};
STY_bw.ls = {'-','--',':','-.','-'}; STY_bw.mk = {'o','s','^','d','v'};
STY_bw.lw = [1.4 1.2 1.2 1.2 1.4]; FNT='Times New Roman'; FSZ=9;

% COLOR STY
STY_col.co = {[0 0.447 0.741],[0.850 0.325 0.098],[0.466 0.674 0.188],[0.494 0.184 0.556],[0.20 0.20 0.20]};
STY_col.ls = {'-','-','-','-','-'}; STY_col.mk = {'o','s','^','d','v'};
STY_col.lw = [1.6 1.4 1.4 1.4 1.4];

% Moving average window for GN-III smoothing (80 time steps ~ 80 s out of 6000 s)
win_gn3 = 80;

%% 1. Generate B&W smoothed figure
f_bw = figure('Position',[30 50 1180 820],'Color','w','Name','T3_theories_bw');
subplot(2,2,1); hold on;
for ci=1:numel(cnames)
    d=D{ci}; hh=d.r_nodes{end}(end)-d.r_nodes{1}(1);
    y = Tst(d.hist_T);
    if ci == 4, y = smoothdata(y, 'movmean', win_gn3); end
    curve_plot(Fo(d.tv,hh), y, ci, STY_bw);
end
fin_plot(gca,FNT,FSZ,'Fo','T^*','(1) T^*(Fo)'); legend(labels,'Location','best','FontSize',8,'FontName',FNT);

subplot(2,2,2); hold on;
for ci=1:numel(cnames)
    d=D{ci}; hh=d.r_nodes{end}(end)-d.r_nodes{1}(1);
    y = Ust(d.hist_U,hh);
    if ci == 4, y = smoothdata(y, 'movmean', win_gn3); end
    curve_plot(Fo(d.tv,hh), y, ci, STY_bw);
end
fin_plot(gca,FNT,FSZ,'Fo','U^*','(2) U^*(Fo)');

subplot(2,2,3); hold on;
for ci=1:numel(cnames)
    d=D{ci}; Ri=d.r_nodes{1}(1); Ro=d.r_nodes{end}(end); xi=(d.r_all(:)-Ri)/(Ro-Ri);
    curve_plot(xi, Tst(d.T_all), ci, STY_bw);
end
fin_plot(gca,FNT,FSZ,'\xi','T^*','(3) T^*(\xi)');

subplot(2,2,4); hold on;
for ci=1:numel(cnames)
    d=D{ci}; Ri=d.r_nodes{1}(1); Ro=d.r_nodes{end}(end); xi=(d.r_all(:)-Ri)/(Ro-Ri);
    curve_plot(xi, Sst(d.S_tt), ci, STY_bw);
end
fin_plot(gca,FNT,FSZ,'\xi','\Sigma_{\theta\theta}','(4) \Sigma_{\theta\theta}(\xi)');

img_bw = fullfile(art_dir, 'T3_theories_smoothed_bw.png');
print(f_bw, img_bw, '-dpng', '-r150');
close(f_bw);

%% 2. Generate COLOR smoothed figure
f_col = figure('Position',[30 50 1180 820],'Color','w','Name','T3_theories_color');
subplot(2,2,1); hold on;
for ci=1:numel(cnames)
    d=D{ci}; hh=d.r_nodes{end}(end)-d.r_nodes{1}(1);
    y = Tst(d.hist_T);
    if ci == 4, y = smoothdata(y, 'movmean', win_gn3); end
    curve_plot(Fo(d.tv,hh), y, ci, STY_col);
end
fin_plot(gca,FNT,FSZ,'Fo','T^*','(1) T^*(Fo)'); legend(labels,'Location','best','FontSize',8,'FontName',FNT);

subplot(2,2,2); hold on;
for ci=1:numel(cnames)
    d=D{ci}; hh=d.r_nodes{end}(end)-d.r_nodes{1}(1);
    y = Ust(d.hist_U,hh);
    if ci == 4, y = smoothdata(y, 'movmean', win_gn3); end
    curve_plot(Fo(d.tv,hh), y, ci, STY_col);
end
fin_plot(gca,FNT,FSZ,'Fo','U^*','(2) U^*(Fo)');

subplot(2,2,3); hold on;
for ci=1:numel(cnames)
    d=D{ci}; Ri=d.r_nodes{1}(1); Ro=d.r_nodes{end}(end); xi=(d.r_all(:)-Ri)/(Ro-Ri);
    curve_plot(xi, Tst(d.T_all), ci, STY_col);
end
fin_plot(gca,FNT,FSZ,'\xi','T^*','(3) T^*(\xi)');

subplot(2,2,4); hold on;
for ci=1:numel(cnames)
    d=D{ci}; Ri=d.r_nodes{1}(1); Ro=d.r_nodes{end}(end); xi=(d.r_all(:)-Ri)/(Ro-Ri);
    curve_plot(xi, Sst(d.S_tt), ci, STY_col);
end
fin_plot(gca,FNT,FSZ,'\xi','\Sigma_{\theta\theta}','(4) \Sigma_{\theta\theta}(\xi)');

img_col = fullfile(art_dir, 'T3_theories_smoothed_color.png');
print(f_col, img_col, '-dpng', '-r150');
close(f_col);

disp('SUCCESSFULLY_GENERATED');

function curve_plot(x,y,ci,STY)
    k=mod(ci-1,5)+1; x=x(:); y=y(:);
    if all(isnan(y))||numel(x)<2, return; end
    xm=x; for i=2:numel(xm), if xm(i)<=xm(i-1), xm(i)=xm(i-1)+1e-12; end, end
    nP=max(300,numel(x)); xf=linspace(xm(1),xm(end),nP); yf=interp1(xm,y,xf,'makima');
    mi=unique(round(linspace(1,nP,8)));
    plot(xf,yf,'Color',STY.co{k},'LineStyle',STY.ls{k},'LineWidth',STY.lw(k),...
        'Marker',STY.mk{k},'MarkerIndices',mi,'MarkerSize',4.5,'MarkerFaceColor','w');
end
function fin_plot(ax,FNT,FSZ,xl,yl,tl)
    grid(ax,'on'); box(ax,'on'); set(ax,'FontName',FNT,'FontSize',FSZ);
    xlabel(ax,xl,'FontName',FNT); ylabel(ax,yl,'FontName',FNT);
end
