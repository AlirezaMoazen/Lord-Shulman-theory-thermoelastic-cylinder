%% claude_anim_preview.m — 3-frame still montage of the ring animation (for review)
clearvars; clc; close all;
casename='M_GAUSS_LS'; d=load(fullfile('param_studies_ch4',[casename '.mat']));
NL=d.NL;Nr=d.N_r;Nz=d.N_z;iz0=round(Nz/2);tv=d.tv;T_inf=300;
ahat=8.9708e-5;Ri=d.r_nodes{1}(1);Ro=d.r_nodes{end}(end);h=Ro-Ri;
rr=zeros(NL*Nr,1);q=0;for e=1:NL,for ir=1:Nr,q=q+1;rr(q)=d.r_nodes{e}(ir);end,end
[rru,iu]=unique(rr);th=linspace(0,2*pi,160);[TH,RG]=meshgrid(th,rru);Xc=RG.*cos(TH);Yc=RG.*sin(TH);
tsel=[250 500 850];
f=figure('Position',[60 80 1500 520],'Color','w');
for j=1:3
  [~,n]=min(abs(tv-tsel(j))); Tt=zeros(NL*Nr,1);q=0;
  for e=1:NL,for ir=1:Nr,q=q+1;g=(e-1)*Nr*Nz+(ir-1)*Nz+iz0;Tt(q)=d.X_hist(g,n)/T_inf;end,end
  subplot(1,3,j); pcolor(Xc,Yc,repmat(Tt(iu),1,numel(th))); shading interp; axis equal off; colormap(jet);
  clim([0 1]); cb=colorbar; cb.Label.String='T^*';
end
print(f,'figures_ch4/anim_preview_MGAUSS.png','-dpng','-r120'); close(f);
fprintf('preview done\n');
