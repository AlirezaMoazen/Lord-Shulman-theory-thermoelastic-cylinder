%% ========================================================================
%  ls_wave_benchmark_R1.m — QUANTITATIVE validation of the second-sound wave
%  ------------------------------------------------------------------------
%  Closes the project's largest verification gap: the Lord-Shulman thermal
%  wave (the central novelty of the thesis) previously had only a QUALITATIVE
%  benchmark -- speeds and reflections "looked right", with no reference curve
%  overlaid and no error figure.
%
%  Strategy: instead of digitising a published figure, an EXACT reference is
%  derived for the solver's own geometry. Setting coupling_on = false removes
%  the only term that ties temperature to (u,w), so the solver's energy row
%  becomes exactly
%       rho*c*( dtheta/dt + tau0*d2theta/dt2 ) = k*( d2theta/dr2 + (1/r) dtheta/dr )
%  and with material_mode='FG_powerlaw' at zero exponents the layer properties
%  are exactly constant. With insulated ends and a z-uniform inner condition the
%  2-D (r,z) field must reduce to the 1-D radial solution computed in closed
%  form by ls_wave_exact_R2.m (Fourier-Bessel modes, exact in time).
%
%  Reported here:
%   (1) pointwise error of the solver against the exact wave, at several times
%   (2) mesh convergence of that error in N_r -- which simultaneously shows the
%       oscillations behind the sharp front shrink under refinement, i.e. they
%       are a discretisation (Gibbs) artefact, not a physical instability
%   (3) front arrival: measured front position vs the exact wave speed
%       C = sqrt(alpha/tau0), the finite-speed claim the whole LS argument rests on
%
%  Outputs -> claude/figures_validation/ , claude/thesis_chapter/
%  ========================================================================
clearvars; clc; close all;

CLROOT  = 'c:/Users/InfosaicUser/Desktop/MSc/Lord-Shulman-theory-thermoelastic-cylinder/claude';
addpath(fullfile(CLROOT,'code','solver'));
addpath(fullfile(CLROOT,'code','validation'));
outfig  = fullfile(CLROOT,'figures_validation');
if ~exist(outfig,'dir'), mkdir(outfig); end

%% ---- reference physical problem (chosen so the wave crosses the wall) ----
S.Ri=1.0; S.Ro=1.5; S.Lz=2.1; S.NL=7; S.Nz=5;
S.k=10; S.rho=1000; S.c=100;            % alpha = 1e-4 m^2/s
S.tau0=400;                              % -> C = sqrt(alpha/tau0) = 5e-4 m/s
S.h_c=10; S.Tref=300; S.Tin=600; S.Delta=300;
S.t0=50;                                 % inner ramp time constant (s)
S.total=900; S.dt=0.5;
S.NrList=[7 11 15 21];                   % mesh-convergence sweep
S.Nmode=400;                             % modes in the exact reference
S.alpha=S.k/(S.rho*S.c);  S.C=sqrt(S.alpha/S.tau0);

P.Ri=S.Ri; P.Ro=S.Ro; P.k=S.k; P.rho=S.rho; P.c=S.c;
P.tau0=S.tau0; P.h_c=S.h_c; P.Delta=S.Delta; P.t0=S.t0;
S.P=P;

fprintf('\n=== LS second-sound quantitative benchmark ===\n');
fprintf('alpha=%.3e m^2/s   C=%.4e m/s   wall transit=%.1f s\n', ...
        S.alpha, S.C, (S.Ro-S.Ri)/S.C);
%% ---- solver runs (via run_solver_case so the solver's clearvars is contained) ----
D = cell(numel(S.NrList),1);
for ii = 1:numel(S.NrList)
    Nr = S.NrList(ii);
    fprintf('\n--- solver run N_r = %d ---\n', Nr);
    cfg = struct();
    cfg.theory='LS';  cfg.tau0=S.tau0;  cfg.coupling_on=false;
    cfg.material_mode='FG_powerlaw';
    cfg.FG_rho_i=S.rho; cfg.FG_nrho=0; cfg.FG_k=S.k; cfg.FG_c=S.c;
    cfg.FG_alpha=0;     cfg.FG_E_i=1e9; cfg.FG_nE=0; cfg.FG_nu=0.3;
    cfg.porosity_on=false;
    cfg.NL=S.NL; cfg.R_i=S.Ri; cfg.R_o=S.Ro; cfg.L=S.Lz;
    cfg.N_r=Nr;  cfg.N_z=S.Nz;
    cfg.T_ref=S.Tref; cfg.T_inf=S.Tref; cfg.h_c=S.h_c;
    cfg.T_in_val=S.Tin; cfg.t0_ramp=S.t0;
    cfg.T_BC_in='dirichlet'; cfg.T_in_mode='ramp'; cfg.T_BC_out='convection';
    cfg.P_i=0;
    cfg.total_time=S.total; cfg.dt=S.dt;
    cfg.out_name=fullfile(CLROOT,'code','validation',sprintf('tmp_lswave_Nr%02d.mat',Nr));
    D{ii} = run_solver_case(cfg);
end

%% ---- compare each mesh against the exact solution at the final time ----
res = struct([]);
for ii = 1:numel(S.NrList)
    Nr = S.NrList(ii);
    r  = D{ii}.r_all(:);  Tn = D{ii}.T_all(:) - S.Tref;      % theta, final time
    Te = ls_wave_exact_R2(r, S.total, S.P, S.Nmode);
    e  = Tn - Te;
    res(ii).Nr   = Nr;
    res(ii).npts = S.NL*Nr;
    res(ii).Linf = max(abs(e))/S.Delta;
    res(ii).L2   = sqrt(mean(e.^2))/S.Delta;
    fprintf('N_r=%2d (%3d radial pts):  Linf=%.4e   L2=%.4e   (rel. to Delta)\n', ...
            Nr, res(ii).npts, res(ii).Linf, res(ii).L2);
end

%% ---- time evolution on the finest mesh: solver vs exact at the snapshots ----
Nrf = S.NrList(end);
Df  = D{end};
rf  = Df.r_all(:);
iz0 = round(S.Nz/2);
Nn  = S.NL*Nrf*S.Nz;
snapT = zeros(numel(rf), numel(Df.snap_t));
for js = 1:numel(Df.snap_t)
    x = Df.snaps{js};
    cnt = 0;
    for e = 1:S.NL
        for ir = 1:Nrf
            cnt = cnt + 1;
            snapT(cnt,js) = x((e-1)*Nrf*S.Nz + (ir-1)*S.Nz + iz0);
        end
    end
end

%% ---- check the 2-D field really collapsed to the 1-D radial problem ----
%  (the whole comparison assumes it did: insulated ends + z-uniform inner BC)
xend = Df.snaps{end};
dz   = 0;
for e = 1:S.NL
    for ir = 1:Nrf
        v1 = xend((e-1)*Nrf*S.Nz + (ir-1)*S.Nz + 1);
        v2 = xend((e-1)*Nrf*S.Nz + (ir-1)*S.Nz + S.Nz);
        dz = max(dz, abs(v1-v2));
    end
end
fprintf('\nz-independence of the solver field: max_r |theta(z=0)-theta(z=L)| = %.3e K (%.2e of Delta)\n',...
        dz, dz/S.Delta);

fprintf('\n--- time evolution (N_r=%d) : solver vs exact ---\n', Nrf);
tabT = []; frontTab = [];
for js = 1:numel(Df.snap_t)
    tt = Df.snap_t(js);
    Te = ls_wave_exact_R2(rf, tt, S.P, S.Nmode);
    er = snapT(:,js) - Te;
    Li = max(abs(er))/S.Delta;  L2 = sqrt(mean(er.^2))/S.Delta;
    % front position = location of steepest radial gradient
    [~,imN] = max(abs(gradient(snapT(:,js), rf)));
    [~,imE] = max(abs(gradient(Te,          rf)));
    rfr_num = rf(imN);  rfr_exa = rf(imE);  rfr_law = min(S.Ri + S.C*tt, S.Ro);
    fprintf('t=%6.1f s  Linf=%.3e  L2=%.3e | front: solver %.4f  exact %.4f  Ri+C t %.4f m\n',...
            tt, Li, L2, rfr_num, rfr_exa, rfr_law);
    tabT(end+1,:)     = [tt Li L2];                                   %#ok<SAGROW>
    frontTab(end+1,:) = [tt rfr_num rfr_exa rfr_law];                 %#ok<SAGROW>
end

%% ---- figure: (a) overlay of solver vs exact, (b) mesh convergence ----
CO = {[0 0.447 0.741],[0.850 0.325 0.098],[0.929 0.694 0.125],...
      [0.494 0.184 0.556],[0.466 0.674 0.188],[0.301 0.745 0.933]};
try
    set(groot,'defaultAxesFontName','Times New Roman');
    set(groot,'defaultTextFontName','Times New Roman');
    set(groot,'defaultLegendFontName','Times New Roman');
catch
end
xi = (rf - S.Ri)/(S.Ro - S.Ri);

fig = figure('Units','inches','Position',[1 1 12 4.6],'Color','w');

subplot(1,2,1); hold on; box on; grid on;
rr = linspace(S.Ri,S.Ro,600).';
xir = (rr-S.Ri)/(S.Ro-S.Ri);
lg = {};
for js = 1:numel(Df.snap_t)
    tt = Df.snap_t(js);
    Te = ls_wave_exact_R2(rr, tt, S.P, S.Nmode);
    plot(xir, Te, '-', 'Color', CO{min(js,numel(CO))}, 'LineWidth',1.6);
    lg{end+1} = sprintf('exact, t=%g s', tt);                          %#ok<SAGROW>
end
for js = 1:numel(Df.snap_t)
    plot(xi, snapT(:,js), 'o', 'Color', CO{min(js,numel(CO))}, ...
         'MarkerSize',4.5, 'MarkerFaceColor','w','LineWidth',0.9);
end
lg{end+1} = 'present solver';
set(gca,'FontSize',10);
xlabel('\xi = (r-R_i)/h','FontSize',11);
ylabel('\theta = T - T_{ref}   (K)','FontSize',11);
legend(lg,'Location','northeast','FontSize',8);
xlim([0 1]); ylim([-20 320]);

subplot(1,2,2); hold on; box on; grid on;
np = [res.npts];  Li = [res.Linf];  L2 = [res.L2];
loglog(np, Li,'-o','Color',CO{2},'LineWidth',1.8,'MarkerSize',7,'MarkerFaceColor','w');
loglog(np, L2,'-s','Color',CO{1},'LineWidth',1.8,'MarkerSize',7,'MarkerFaceColor','w');
set(gca,'XScale','log','YScale','log','FontSize',10);
xlabel('total radial DQ points  N_L \times N_r','FontSize',11);
ylabel('relative error vs exact solution','FontSize',11);
legend({'L_\infty','L_2'},'Location','northeast','FontSize',9);

exportgraphics(fig, fullfile(outfig,'ls_wave_validation_R1.png'),'Resolution',300);
savefig(fig, fullfile(outfig,'ls_wave_validation_R1.fig'));
close(fig);
fprintf('\nwrote %s\n', fullfile(outfig,'ls_wave_validation_R1.png'));

%% ---- CSV tables for the thesis ----
f1 = fullfile(CLROOT,'thesis_chapter','ls_wave_mesh_convergence_R1.csv');
fid = fopen(f1,'w');
fprintf(fid,'N_r,radial_points,Linf_rel,L2_rel\n');
for ii=1:numel(res)
    fprintf(fid,'%d,%d,%.6e,%.6e\n',res(ii).Nr,res(ii).npts,res(ii).Linf,res(ii).L2);
end
fclose(fid);

f2 = fullfile(CLROOT,'thesis_chapter','ls_wave_time_errors_R1.csv');
fid = fopen(f2,'w');
fprintf(fid,'t_s,Linf_rel,L2_rel,front_solver_m,front_exact_m,front_Ri_plus_Ct_m\n');
for ii=1:size(tabT,1)
    fprintf(fid,'%.3f,%.6e,%.6e,%.5f,%.5f,%.5f\n', ...
            tabT(ii,1),tabT(ii,2),tabT(ii,3), ...
            frontTab(ii,2),frontTab(ii,3),frontTab(ii,4));
end
fclose(fid);
fprintf('wrote %s\n  and %s\n', f1, f2);

%% ---- cleanup temp solver outputs ----
for ii=1:numel(S.NrList)
    fn = fullfile(CLROOT,'code','validation',sprintf('tmp_lswave_Nr%02d.mat',S.NrList(ii)));
    if exist(fn,'file'), delete(fn); end
    fn2 = strrep(fn,'.mat','_DOFmap.csv');
    if exist(fn2,'file'), delete(fn2); end
end
fprintf('\ndone.\n');
