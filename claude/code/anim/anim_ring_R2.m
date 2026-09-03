%% ANSYS-style animated transient contour (proof of concept)
%  Annular cross-section of the cylinder (looking down the axis) coloured by the
%  dimensionless temperature T* at the mid-axial plane, animated over time from
%  the saved full-history data (X_hist). Writes an animated GIF.
%  Run from claude/ :  addpath('code/anim'); anim_ring_R2
%  Pick the case near the top (must be a full-history case: BASE, C_TAU_*, M_GAUSS_*, T3_*).
clearvars; clc; close all;
casename = 'M_GAUSS_LS';
outdir = 'figures_ch4'; if ~exist(outdir,'dir'), mkdir(outdir); end
d = load(fullfile('param_studies_ch4',[casename '.mat']));
if ~isfield(d,'X_hist'), error('%s has no X_hist (full history not stored).',casename); end
NL=d.NL; Nr=d.N_r; Nz=d.N_z; iz0=round(Nz/2); tv=d.tv; T_inf=300;
ahat=8.9708e-5; Ri=d.r_nodes{1}(1); Ro=d.r_nodes{end}(end); h=Ro-Ri;
rr=zeros(NL*Nr,1); q=0; for e=1:NL, for ir=1:Nr, q=q+1; rr(q)=d.r_nodes{e}(ir); end, end
[rru,iu]=unique(rr);
th=linspace(0,2*pi,160); [TH,RG]=meshgrid(th,rru); Xc=RG.*cos(TH); Yc=RG.*sin(TH);
nsteps=numel(tv); frames=unique(round(linspace(1,nsteps,80)));
% global colour scale (stable colorbar)
gmax=0;
for k=1:numel(frames)
  n=frames(k); q=0;
  for e=1:NL, for ir=1:Nr, q=q+1; g=(e-1)*Nr*Nz+(ir-1)*Nz+iz0; gmax=max(gmax,d.X_hist(g,n)/T_inf); end, end
end
cmax=max(0.2,ceil(gmax*20)/20);
gif=fullfile(outdir,['anim_' casename '_Tstar.gif']);
f=figure('Position',[120 90 640 580],'Color','w');
for k=1:numel(frames)
  n=frames(k); Tt=zeros(NL*Nr,1); q=0;
  for e=1:NL, for ir=1:Nr, q=q+1; g=(e-1)*Nr*Nz+(ir-1)*Nz+iz0; Tt(q)=d.X_hist(g,n)/T_inf; end, end
  Ttu=Tt(iu); ZZ=repmat(Ttu,1,numel(th));
  clf; pcolor(Xc,Yc,ZZ); shading interp; axis equal off; colormap(jet);
  cb=colorbar; cb.Label.String='T^*'; try, clim([0 cmax]); catch, caxis([0 cmax]); end
  drawnow; fr=getframe(f); im=frame2im(fr); [A,map]=rgb2ind(im,256);
  if k==1, imwrite(A,map,gif,'gif','LoopCount',inf,'DelayTime',0.07);
  else,   imwrite(A,map,gif,'gif','WriteMode','append','DelayTime',0.07); end
end
close(f); fprintf('animation -> %s (%d frames, cmax=%.2f)\n', gif, numel(frames), cmax);
