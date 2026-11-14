%% catalog_fields_R1.m — COLOUR figures of ALL displacement, strain and stress components
%  R1 (2026-11-14, author request): complete field catalogue for Chapter 4.
%  The existing catalog (catalog_R18_color) shows T*, U* and Sigma_thth only.
%  This script adds every displacement (u, w), every strain (err, ett, ezz, grz)
%  and every stress (Srr, Stt, Szz, Trz) for the thesis BASE case and for every
%  parametric study, using the stored campaign states (no solver re-run).
%
%  NEW DERIVED FIELDS. The .mat files hold the state [theta; u; w] at 6 snapshot
%  times (and, for BASE and the shock studies, at every step). Strains and
%  stresses are rebuilt from it by LSTE_fields_R1 (same DQ derivatives and Hooke
%  law as LSTE_solver_R11 section 7) with the layer moduli from LSTE_case_props_R1.
%  LSTE_fields_R1_check proves the rebuild reproduces the solver's own Srr, Stt,
%  Szz at z = L/2 for all 51 cases used here (worst relative error 1.4e-11).
%
%  LAYOUT RULES. At most 4 panels per window (2x2; windows with only 2 fields
%  use 1x2). Colour only. Times New Roman, axis font 14 pt, legend font 14 pt
%  (same as catalog_R18_color). No figure title: number/caption go in the
%  document. Every figure is saved as .png (130 dpi) AND .fig.
%
%  DIMENSIONLESS FORMS (reference constants as in catalog_R18_color)
%    U*  = u /((1-nu)*alpha*T_inf*h)     h = R_o - R_i
%    W*  = w /((1-nu)*alpha*T_inf*L)     L = cylinder length (NEW: w grows with L)
%    eps*= eps/(alpha*T_inf)  for err, ett, ezz and the engineering shear grz
%    Sigma = (1+nu)*sigma/(E*alpha*T_inf)  for Srr, Stt, Szz, Trz
%    xi = (r-R_i)/(R_o-R_i),  z* = z/L,  Fo = ahat*t/h^2
%  EVALUATION LOCATIONS. Normal quantities (u, err, ett, ezz, Srr, Stt, Szz) are
%  shown at mid-length z = L/2. w is odd about L/2 and grz, Trz vanish there, so
%  w, grz and Trz are shown at the Chebyshev node nearest z = L/4
%  (z = 0.206 L for N_z = 11); the axis label says so. Axial profiles are taken
%  at mid-thickness (xi = 0.5). Profiles are at the final time of each case.
%
%  PARTS (each is its own folder = one git commit)
%    1  P1_BASE_detail       BASE: histories (inner/mid/outer), snapshots, contours
%    2  P2_displacement      18 studies x {u, w}
%    3  P3_strain            18 studies x {err, ett, ezz, grz}
%    4  P4_stress            18 studies x {Srr, Stt, Szz, Trz}
%    5  P5_shock_histories   C_relaxation, M_gauss_shock, T3_theories: histories
%  Run from claude/ (parts are independent; at most 3 MATLAB jobs at once):
%    addpath('code/catalog'); PARTS=1; catalog_fields_R1
%  Output root: figures_fields_R1. Each part writes its own README.md.
if ~exist('PARTS','var'), PARTS = 1:5; end
clearvars -except PARTS; clc; close all;
pdir = 'param_studies_ch4'; root = 'figures_fields_R1';
ahat=8.9708e-5; E_ref=4.433e9; nu_ref=0.3395; alp_ref=5.9814e-5; T_inf=300; %#ok<NASGU>
STY.co={[0 0.447 0.741],[0.850 0.325 0.098],[0.466 0.674 0.188],[0.494 0.184 0.556],[0.20 0.20 0.20],[0.929 0.694 0.125]};
STY.ls={'-','-','-','-','-','-'}; STY.mk={'o','s','^','d','v','>'};
STY.lw=[1.6 1.4 1.4 1.4 1.4 1.4]; FNT='Times New Roman'; FSZ=14; LGSZ=14;
G.pdir=pdir; G.STY=STY; G.FNT=FNT; G.FSZ=FSZ; G.LGSZ=LGSZ;

studies = { ...
 'A_GPL_patterns',    {'BASE','A_GPL_O','A_GPL_X','A_GPL_V','A_GPL_A'}, {'UD','O','X','V','A'};
 'B_porosity_patterns',{'BASE','B_POR_O','B_POR_X','B_POR_V','B_POR_A'}, {'UD','O','X','V','A'};
 'E_porosity_level',  {'E_EM3_9675','BASE','E_EM3_7776'}, {'e_{m3}=0.9675','0.8604','0.7776'};
 'D_wt_low',          {'D_W_001','BASE','D_W_005','D_W_009','D_W_015'}, {'W=0.1%','0.3%','0.5%','0.9%','1.5%'};
 'D2_wt_high',        {'D2_W_010','D2_W_020','D2_W_040','D2_W_080'}, {'W=1%','2%','4%','8%'};
 'C_relaxation',      {'C_FOURIER','C_TAU_004','C_TAU_015'}, {'Fourier','\tau^*=0.04','0.15'};
 'F_end_BC',          {'BASE','F_BC_SC','F_BC_C'}, {'S-S','S-C','C-C'};
 'G_pressure',        {'G_P000','G_P010','BASE','G_P100'}, {'P_i=0','10 MPa','50 MPa','100 MPa'};
 'I_coupling',        {'BASE','I_UNCOUPLED'}, {'coupled','uncoupled'};
 'J_convection',      {'BASE','J_HC_100','J_HC_1000'}, {'h_c=10','100','1000'};
 'K_thickness',       {'BASE','K_RO_200','K_RO_500'}, {'R_o/R_i=1.5','2.0','5.0'};
 'L_layers',          {'L_NL_3','L_NL_5','BASE','L_NL_9','L_NL_15'}, {'N_L=3','5','7','9','15'};
 'Q_length',          {'Q_L_1','BASE','Q_L_5','Q_L_10'}, {'L=1','2.1','5','10'};
 'O_aspect_ab',       {'O_AB_100','BASE','O_AB_400','O_AB_1000'}, {'a/b=1.0','1.67','4','10'};
 'P_aspect_bt',       {'P_BT_010','P_BT_100','BASE'}, {'b/t=10','100','1000'};
 'P_aspect_bt_fine',  {'P_BT_100','P_BT_200','P_BT_500T','BASE','P_BT_2000T'}, {'b/t=100','200','500','1000','2000'};
 'M_gauss_shock',     {'M_GAUSS_LS','M_GAUSS_FOU'}, {'LS','Fourier'};
 'T3_theories',       {'C_FOURIER','C_TAU_015','T3_DPL','T3_GN3'}, {'Fourier','LS','DPL','GN-III'} };
SHARED_BOTTOM = {'B_porosity_patterns','G_pressure'};   % one legend under all panels
shock = {'C_relaxation','M_gauss_shock','T3_theories'};

% field table: key, tex label, evaluation z ('mid' = L/2, 'sel' = node nearest L/4)
FT.u   = {'U^*','mid'};                 FT.w   = {'W^*','sel'};
FT.err = {'\epsilon^*_{rr}','mid'};     FT.ett = {'\epsilon^*_{\theta\theta}','mid'};
FT.ezz = {'\epsilon^*_{zz}','mid'};     FT.grz = {'\gamma^*_{rz}','sel'};
FT.Srr = {'\Sigma_{rr}','mid'};         FT.Stt = {'\Sigma_{\theta\theta}','mid'};
FT.Szz = {'\Sigma_{zz}','mid'};         FT.Trz = {'\Sigma_{rz}','sel'};
GROUPS.disp   = {'u','w'};
GROUPS.strain = {'err','ett','ezz','grz'};
GROUPS.stress = {'Srr','Stt','Szz','Trz'};
GNAME = struct('disp','displacement','strain','strain','stress','stress');

cache = containers.Map();      % case name -> loaded case (final-state fields)
allrep = {};
for part = PARTS(:)'
    switch part
        case 1
            od = fullfile(root,'P1_BASE_detail'); mk(od); idx = {};
            c = getcase(cache,pdir,'BASE',true);
            for gn = {'disp','strain','stress'}
                g = gn{1}; keys = GROUPS.(g);
                % histories at inner / mid / outer, z = L/2 (or L/4 for w, grz, Trz)
                locs = [1 1; c.e_mid c.ir_mid; c.D.NL c.D.N_r];
                llab = {'\xi=0','\xi=0.5','\xi=1'};
                pr = {};
                for k = 1:numel(keys)
                    X = {}; Y = {};
                    for q = 1:3
                        [x,y] = hist_series(c,keys{k},locs(q,1),locs(q,2));
                        X{q} = x; Y{q} = y; %#ok<SAGROW>
                    end
                    pr{end+1} = mkpanel('Fo',ylab(c,keys{k},FT),X,Y); %#ok<SAGROW>
                end
                if strcmp(g,'disp')
                    for k = 1:2, pr{end+1} = mkpanel('\xi',ylab(c,keys{k},FT), ... %#ok<SAGROW>
                            snapX(c,keys{k}),snapY(c,keys{k})); end
                    nm = 'BASE_disp_hist_snap'; lab_h = llab;
                    % panels 1-2 use location labels, 3-4 snapshot labels: two legend sets
                    rep = draw_window(G,od,nm,pr,{lab_h,lab_h,snaplabels(c),snaplabels(c)},false,FT);
                    idx(end+1,:) = {nm,'u*, w*: histories at xi=0/0.5/1 (panels 1-2); radial profiles at the 6 snapshot times (panels 3-4)'}; %#ok<SAGROW>
                    allrep = [allrep; rep]; %#ok<AGROW>
                else
                    nm = ['BASE_' g '_hist'];
                    rep = draw_window(G,od,nm,pr,{llab},true,FT);
                    idx(end+1,:) = {nm,[GNAME.(g) ' histories at xi=0, 0.5, 1 (z=L/2; z=0.206L for w, grz, Trz)']}; %#ok<SAGROW>
                    allrep = [allrep; rep]; %#ok<AGROW>
                    pr = {};
                    for k = 1:numel(keys)
                        pr{end+1} = mkpanel('\xi',ylab(c,keys{k},FT),snapX(c,keys{k}),snapY(c,keys{k})); %#ok<SAGROW>
                    end
                    nm = ['BASE_' g '_snap'];
                    rep = draw_window(G,od,nm,pr,{snaplabels(c)},true,FT);
                    idx(end+1,:) = {nm,[GNAME.(g) ' radial profiles at the 6 stored times']}; %#ok<SAGROW>
                    allrep = [allrep; rep]; %#ok<AGROW>
                end
                nm = ['BASE_' g '_contour'];
                draw_contours(G,od,nm,c,keys,FT);
                idx(end+1,:) = {nm,[GNAME.(g) ' contours over (xi, z/L) at the final time, layer by layer']}; %#ok<SAGROW>
            end
            write_readme(od,'Part 1 - BASE case, complete fields',idx);
        case {2,3,4}
            g = {'disp','strain','stress'}; g = g{part-1};
            od = fullfile(root,['P' num2str(part) '_' GNAME.(g)]); mk(od); idx = {};
            keys = GROUPS.(g);
            for si = 1:size(studies,1)
                sn = studies{si,1}; cn = studies{si,2}; lb = studies{si,3};
                Cs = cell(1,numel(cn)); ok = true;
                for ci = 1:numel(cn)
                    if ~exist(fullfile(pdir,[cn{ci} '.mat']),'file'), ok = false; break; end
                    Cs{ci} = getcase(cache,pdir,cn{ci},false);
                end
                if ~ok, fprintf('SKIP %s\n',sn); continue; end
                pr = {};
                if strcmp(g,'disp')
                    spec = {{'xi','u'},{'xi','w'},{'z','u'},{'z','w'}};
                else
                    spec = {{'xi',keys{1}},{'xi',keys{2}},{'xi',keys{3}},{'xi',keys{4}}};
                end
                for k = 1:numel(spec)
                    X = cell(1,numel(Cs)); Y = X;
                    for ci = 1:numel(Cs)
                        [X{ci},Y{ci}] = final_profile(Cs{ci},spec{k}{2},spec{k}{1});
                    end
                    if strcmp(spec{k}{1},'xi'), xl = '\xi'; yl = ylab(Cs{1},spec{k}{2},FT);
                    else, xl = 'z/L'; yl = [FT.(spec{k}{2}){1} ' (\xi=0.5)']; end
                    pr{end+1} = mkpanel(xl,yl,X,Y); %#ok<SAGROW>
                end
                nm = [sn '_' g];
                rep = draw_window(G,od,nm,pr,{lb},any(strcmp(sn,SHARED_BOTTOM)),FT);
                allrep = [allrep; rep]; %#ok<AGROW>
                idx(end+1,:) = {nm,sprintf('%s, study %s',GNAME.(g),sn)}; %#ok<SAGROW>
            end
            write_readme(od,sprintf('Part %d - %s, all parametric studies',part,GNAME.(g)),idx);
        case 5
            od = fullfile(root,'P5_shock_histories'); mk(od); idx = {};
            for si = 1:size(studies,1)
                sn = studies{si,1}; if ~any(strcmp(sn,shock)), continue; end
                cn = studies{si,2}; lb = studies{si,3};
                Cs = cell(1,numel(cn)); ok = true;
                for ci = 1:numel(cn)
                    if ~exist(fullfile(pdir,[cn{ci} '.mat']),'file'), ok = false; break; end
                    Cs{ci} = getcase(cache,pdir,cn{ci},true);
                end
                if ~ok, fprintf('SKIP %s\n',sn); continue; end
                for gn = {'disp','strain','stress'}
                    g = gn{1}; keys = GROUPS.(g); pr = {};
                    for k = 1:numel(keys)
                        X = cell(1,numel(Cs)); Y = X;
                        for ci = 1:numel(Cs)
                            [X{ci},Y{ci}] = hist_series(Cs{ci},keys{k},Cs{ci}.e_mid,Cs{ci}.ir_mid);
                        end
                        pr{end+1} = mkpanel('Fo',ylab(Cs{1},keys{k},FT),X,Y); %#ok<SAGROW>
                    end
                    nm = [sn '_' g '_hist'];
                    rep = draw_window(G,od,nm,pr,{lb},any(strcmp(sn,SHARED_BOTTOM)),FT);
                    allrep = [allrep; rep]; %#ok<AGROW>
                    idx(end+1,:) = {nm,sprintf('%s histories at xi=0.5, study %s',GNAME.(g),sn)}; %#ok<SAGROW>
                end
                for ci = 1:numel(Cs), cache.remove(Cs{ci}.name); end
            end
            write_readme(od,'Part 5 - shock studies, time histories at mid-thickness',idx);
    end
    close all;
end
nbad = 0;
for i = 1:size(allrep,1)
    if allrep{i,4} > 0 && isempty(strfind(allrep{i,3},'outside')), nbad = nbad+1; end %#ok<STREMP>
end
fprintf('DONE catalog_fields_R1 parts %s: %d legends checked, %d in-axes legends covering data\n', ...
    mat2str(PARTS),size(allrep,1),nbad);

%% ---------------- data helpers ----------------
function mk(d), if ~exist(d,'dir'), mkdir(d); end, end

function c = getcase(cache,pdir,name,withHist)
% load a case once: layer moduli, final-state fields on the whole grid, snapshots
    if isKey(cache,name)
        c = cache(name);
        if withHist && isempty(c.XH)
            S = load(fullfile(pdir,[name '.mat']),'X_hist'); c.XH = S.X_hist; cache(name) = c;
        end
        return
    end
    [P,D] = LSTE_case_props_R1(pdir,name);
    S = load(fullfile(pdir,[name '.mat']),'snaps','snap_t','tv');
    c.name = name; c.D = D; c.P = P;
    c.Ri = D.r_nodes{1}(1); c.Ro = D.r_nodes{end}(end); c.h = c.Ro-c.Ri;
    c.L = D.z_nodes(end)-D.z_nodes(1); c.tv = S.tv; c.snap_t = S.snap_t;
    [E,R,Z] = ndgrid(1:D.NL,1:D.N_r,1:D.N_z);
    Xs = cell2mat(cellfun(@(x)x(:),S.snaps(:).','UniformOutput',false));
    c.Fs = LSTE_fields_R1(D,P,Xs,[E(:) R(:) Z(:)]);
    c.nsnap = numel(S.snap_t);
    if abs(S.snap_t(end)-S.tv(end)) > 1e-9, error('last snapshot is not the final time (%s)',name); end
    c.rr = cell2mat(D.r_nodes(:)); c.xi = (c.rr-c.Ri)/c.h;
    c.iz0 = round(D.N_z/2); [~,c.izs] = min(abs(D.z_nodes(:)/c.L-0.25));
    c.e_mid = ceil(D.NL/2); c.ir_mid = ceil(D.N_r/2);
    c.XH = [];
    if withHist
        H = load(fullfile(pdir,[name '.mat']),'X_hist'); c.XH = H.X_hist;
    end
    cache(name) = c;
end

function y = nrm(c,key,y)
% dimensionless forms (constants as in catalog_R18_color)
    E_ref=4.433e9; nu_ref=0.3395; alp_ref=5.9814e-5; T_inf=300;
    switch key
        case 'u', y = y./((1-nu_ref)*alp_ref*T_inf*c.h);
        case 'w', y = y./((1-nu_ref)*alp_ref*T_inf*c.L);
        case {'err','ett','ezz','grz'}, y = y./(alp_ref*T_inf);
        otherwise, y = (1+nu_ref)*y./(E_ref*alp_ref*T_inf);
    end
end

function A = fld(c,key,isnap)
% field on the whole grid, size [NL N_r N_z], at snapshot isnap
    A = reshape(c.Fs.(key)(:,isnap),[c.D.NL c.D.N_r c.D.N_z]);
end

function zm = zmode(key)
% evaluation height: 'mid' = z = L/2; 'sel' = node nearest L/4
% (w is odd about L/2 and grz, Trz vanish there, so those three live at L/4)
    if any(strcmp(key,{'w','grz','Trz'})), zm = 'sel'; else, zm = 'mid'; end
end

function s = ylab(c,key,FT)
    s = FT.(key){1};
    if strcmp(FT.(key){2},'sel'), s = sprintf('%s (z=%.2fL)',s,c.D.z_nodes(c.izs)/c.L); end
end

function [x,y] = final_profile(c,key,kind)
% profile at the final time: 'xi' = radial profile, 'z' = axial profile at mid-thickness
    A = fld(c,key,c.nsnap);
    if strcmp(kind,'xi')
        if strcmp(zmode(key),'sel'), iz = c.izs; else, iz = c.iz0; end
        v = squeeze(A(:,:,iz)); x = reshape(c.xi.',[],1); y = nrm(c,key,reshape(v.',[],1));
    else
        x = c.D.z_nodes(:)/c.L; y = nrm(c,key,squeeze(A(c.e_mid,c.ir_mid,:)));
    end
end

function X = snapX(c,key) %#ok<INUSD>
    X = cell(1,c.nsnap); for k = 1:c.nsnap, X{k} = reshape(c.xi.',[],1); end
end
function Y = snapY(c,key)
    if strcmp(zmode(key),'sel'), iz = c.izs; else, iz = c.iz0; end
    Y = cell(1,c.nsnap);
    for k = 1:c.nsnap
        v = squeeze(fld(c,key,k)); v = squeeze(v(:,:,iz));
        Y{k} = nrm(c,key,reshape(v.',[],1));
    end
end
function L = snaplabels(c)
    ahat = 8.9708e-5; L = cell(1,c.nsnap);
    for k = 1:c.nsnap, L{k} = sprintf('Fo=%.2f',ahat*c.snap_t(k)/c.h^2); end
end

function [x,y] = hist_series(c,key,e,ir)
% history of one field at node (e,ir) over the full stored history
    if strcmp(zmode(key),'sel'), iz = c.izs; else, iz = c.iz0; end
    F = LSTE_fields_R1(c.D,c.P,c.XH,[e ir iz]);
    ahat = 8.9708e-5;
    x = ahat*c.tv(:)/c.h^2; y = nrm(c,key,F.(key)(:));
end

function pr = mkpanel(xl,yl,X,Y)
    pr.xl = xl; pr.yl = yl; pr.X = X; pr.Y = Y;
end

%% ---------------- figure builders ----------------
function allrep = draw_window(G,od,nm,panels,labsets,shared,~)
% panels: cell of panel structs (<=4). labsets: one legend-label set for all
% panels, or one set per panel. shared: one legend strip under all panels.
    n = numel(panels);
    if n <= 2, pos = [30 50 1180 430]; lay = [1 n]; else, pos = [30 50 1180 820]; lay = [2 2]; end
    f1 = figure('Position',pos,'Color','w','Name',nm);
    tl = tiledlayout(f1,lay(1),lay(2),'TileSpacing','tight','Padding','tight');
    allrep = {};
    for p = 1:n
        ax = nexttile(tl); hold(ax,'on'); pr = panels{p};
        for ci = 1:numel(pr.X), curve(pr.X{ci},pr.Y{ci},ci,G.STY); end
        fin(ax,G.FNT,G.FSZ,pr.xl,pr.yl,'');
        if numel(labsets) == 1, labs = labsets{1}; else, labs = labsets{p}; end
        if ~shared, allrep(end+1,:) = place_legend(ax,labs,G.FNT,G.LGSZ,nm,p); end %#ok<AGROW>
    end
    if shared
        shared_bottom_legend(tl,labsets{1},G.FNT,G.LGSZ,nm);
        allrep(end+1,:) = {nm,0,'shared-bottom',0};
    else
        if numel(labsets) == 1
            rep = finalize_legends(f1,labsets{1},G.FNT,G.LGSZ,nm,false);
        else
            rep = finalize_legends_sets(f1,labsets,G.FNT,G.LGSZ,nm);
        end
        allrep = rep;
    end
    print(f1,fullfile(od,[nm '.png']),'-dpng','-r130');
    savefig(f1,fullfile(od,[nm '.fig'])); close(f1);
    fprintf('fields: %s\n',nm);
end

function rep = finalize_legends_sets(f1,labsets,FNT,SZ,sname)
% finalize_legends with a different label set per panel (panel p uses labsets{p})
    rep = {};
    axs = flipud(findobj(f1,'Type','axes'));
    for p = 1:numel(axs)
        ax = axs(p); lg = get(ax,'Legend'); if isempty(lg), continue; end
        labels = labsets{min(p,numel(labsets))};
        [X,Y] = line_points(ax);
        n = count_covered(ax,lg,X,Y); loc = lg.Location;
        if n > 0
            cand = {'best','northeast','northwest','southeast','southwest','north','south','east','west'};
            for c = 1:numel(cand)
                lg = legend(ax,labels,'Location',cand{c},'FontSize',SZ,'FontName',FNT);
                drawnow; n = count_covered(ax,lg,X,Y); loc = cand{c};
                if n == 0, break; end
            end
            if n > 0
                lg = legend(ax,labels,'Location','eastoutside','FontSize',SZ,'FontName',FNT);
                drawnow; loc = 'eastoutside'; n = count_covered(ax,lg,X,Y);
            end
        end
        if isempty(strfind(loc,'outside')) %#ok<STREMP>
            Pp = lg.Position; lg.Location = 'none'; lg.Position = Pp; drawnow;
        end
        n = count_covered(ax,lg,X,Y);
        fprintf('    %-26s panel %d: legend %-13s covered points = %d\n',sname,p,loc,n);
        rep(end+1,:) = {sname,p,loc,n}; %#ok<AGROW>
    end
end

function draw_contours(G,od,nm,c,keys,~)
% contour maps over (xi, z/L), one contourf per layer so the interface jumps stay sharp
    n = numel(keys);
    if n <= 2, pos = [30 50 1180 430]; lay = [1 n]; else, pos = [30 50 1180 820]; lay = [2 2]; end
    f1 = figure('Position',pos,'Color','w','Name',nm);
    tl = tiledlayout(f1,lay(1),lay(2),'TileSpacing','compact','Padding','compact');
    D = c.D; zL = D.z_nodes(:)'/c.L;
    for k = 1:n
        A = nrm(c,keys{k},fld(c,keys{k},c.nsnap));
        lo = min(A(:)); hi = max(A(:));
        if hi-lo < eps(max(abs([lo hi 1]))), hi = lo+1; end
        lev = linspace(lo,hi,26);
        ax = nexttile(tl); hold(ax,'on');
        for e = 1:D.NL
            Z = squeeze(A(e,:,:)).';          % N_z x N_r
            contourf(ax,c.xi(e,:),zL,Z,lev,'LineStyle','none');
        end
        colormap(ax,turbo); clim(ax,[lo hi]);
        cb = colorbar(ax); set(cb,'FontName',G.FNT,'FontSize',G.FSZ);
        FT1 = struct('u',{{'U^*','mid'}},'w',{{'W^*','mid'}},'err',{{'\epsilon^*_{rr}','mid'}}, ...
            'ett',{{'\epsilon^*_{\theta\theta}','mid'}},'ezz',{{'\epsilon^*_{zz}','mid'}}, ...
            'grz',{{'\gamma^*_{rz}','mid'}},'Srr',{{'\Sigma_{rr}','mid'}},'Stt',{{'\Sigma_{\theta\theta}','mid'}}, ...
            'Szz',{{'\Sigma_{zz}','mid'}},'Trz',{{'\Sigma_{rz}','mid'}});
        cb.Label.String = FT1.(keys{k}){1}; cb.Label.FontName = G.FNT; cb.Label.FontSize = G.FSZ;
        fin(ax,G.FNT,G.FSZ,'\xi','z/L','');
        xlim(ax,[0 1]); ylim(ax,[0 1]); set(ax,'Layer','top');
    end
    print(f1,fullfile(od,[nm '.png']),'-dpng','-r130');
    savefig(f1,fullfile(od,[nm '.fig'])); close(f1);
    fprintf('fields: %s\n',nm);
end

function write_readme(od,title,idx)
% one README per part: what is in the folder and how the fields are normalised
    fid = fopen(fullfile(od,'README.md'),'w');
    fprintf(fid,'# %s\n\nGenerated by `code/catalog/catalog_fields_R1.m` (R1, 2026-11-14). Colour figures, each saved as .png and .fig.\n\n',title);
    fprintf(fid,'Fields are rebuilt from the stored campaign states (`LSTE_fields_R1`); the rebuild reproduces the solver''s own Srr/Stt/Szz at z=L/2 to 1.4e-11 (`LSTE_fields_R1_check`).\n\n');
    fprintf(fid,'Dimensionless forms: U* = u/((1-nu)aT h), W* = w/((1-nu)aT L), eps* = eps/(aT) (also the engineering shear gamma_rz), Sigma = (1+nu)sigma/(E a T), with E, nu, a, T = 4.433e9, 0.3395, 5.9814e-5, 300 (as catalog_R18_color); xi = (r-Ri)/(Ro-Ri), z/L, Fo = ahat t/h^2.\n\n');
    fprintf(fid,'Locations: u, eps_rr, eps_tt, eps_zz, Sigma_rr, Sigma_tt, Sigma_zz at z = L/2; w, gamma_rz, Sigma_rz at the node nearest z = L/4 (z = 0.206 L), stated in the y-label. Axial profiles at xi = 0.5. Profiles at the final time of each case.\n\n');
    fprintf(fid,'| file (.png/.fig) | content |\n|---|---|\n');
    for i = 1:size(idx,1), fprintf(fid,'| %s | %s |\n',idx{i,1},idx{i,2}); end
    fclose(fid);
end

%% ---------------- legend and curve helpers (copied verbatim from catalog_R18_color) ----------------
function out = panel_legend(ax,labels,FNT,SZ,sname,panel,shared)
% Legend for one panel while the figure is being built.
%   shared  -> nothing here; one legend is drawn under the whole figure
%              afterwards by shared_bottom_legend.
%   default -> the usual search for a location that covers no data.
% This is only a starting point: the placement is re-checked and frozen by
% finalize_legends once all four panels exist.
    if shared
        out = {sname, panel, 'shared-bottom', 0};
        return;
    end
    out = place_legend(ax,labels,FNT,SZ,sname,panel);
end

function shared_bottom_legend(tl,labels,FNT,SZ,sname)
% One legend for all four panels, in its own strip under the tiled layout.
% It occupies a tile of its own, so it cannot overlap any curve by
% construction -- no placement search is needed, and nothing is pinned
% (pinning would take it out of the layout and lose its tile).
    axs = findobj(tl.Children,'flat','Type','axes');
    ax1 = axs(end);                       % first-created panel
    lg = legend(ax1,labels,'Orientation','horizontal','NumColumns',numel(labels), ...
                'FontSize',SZ,'FontName',FNT);
    lg.Layout.Tile = 'south';
    drawnow;
    fprintf('    %-18s one shared legend below all 4 panels (%d entries)\n',sname,numel(labels));
end

function rep = finalize_legends(f1,labels,FNT,SZ,sname,nudge)
% Re-check every legend AFTER all four panels exist, then freeze it.
%
% WHY THIS PASS IS NEEDED. A legend left on an automatic Location is re-solved
% by MATLAB whenever the tiled layout reflows, and the layout reflows each time
% a later panel is added. A location that genuinely covered no data when its own
% panel was built can therefore drift onto the curves before the figure is
% printed. That is not hypothetical: in P_aspect_bt_fine panel 1 the legend
% measured zero covered points during construction and sat on 617 plotted points
% in the saved figure, in both the B&W and the colour set, from R11 to R15.
%
% So the measurement is repeated here with the geometry the figure will actually
% be printed with; a legend that is no longer clean is moved (same candidate
% list, then outside the axes as a last resort); and every legend is then pinned
% to its rectangle, which takes it off automatic placement so no later reflow
% can move it again. Because this pass runs last, what is measured is what is
% saved.
    drawnow;
    axs  = flipud(findobj(f1,'Type','axes'));   % creation order: panel 1..4
    cand = {'best','northeast','northwest','southeast','southwest','north','south','east','west'};
    rep  = {};
    for p = 1:numel(axs)
        ax = axs(p); lg = get(ax,'Legend');
        if isempty(lg), continue; end
        [X,Y] = line_points(ax);
        n   = count_covered(ax,lg,X,Y);
        loc = lg.Location;
        if n > 0                                   % drifted: search again
            for c = 1:numel(cand)
                lg = legend(ax,labels,'Location',cand{c},'FontSize',SZ,'FontName',FNT);
                drawnow; n = count_covered(ax,lg,X,Y); loc = cand{c};
                if n == 0, break; end
            end
            if n > 0
                lg = legend(ax,labels,'Location','eastoutside','FontSize',SZ,'FontName',FNT);
                drawnow; loc = 'eastoutside'; n = count_covered(ax,lg,X,Y);
            end
        end
        % Pin in-axes legends so no later reflow can move them. A legend placed
        % OUTSIDE the axes must not be pinned: the space it occupies is reserved
        % by the layout only while its Location says "outside", so pinning frees
        % that strip, the axes grows back into it, and the curves run under the
        % legend again -- measured as 8 covered points in P_aspect_bt_fine panel
        % 3. Left on 'eastoutside' it cannot overlap by construction.
        if isempty(strfind(loc,'outside')) %#ok<STREMP>
            P = lg.Position; lg.Location = 'none'; lg.Position = P; drawnow;
        end
        % only a pinned (in-axes) legend may be walked upwards -- moving an
        % outside legend by Position would unpin it and reopen the bug above
        if nudge && p == 2 && isempty(strfind(loc,'outside')) %#ok<STREMP>
            loc = raise_legend(ax,lg,X,Y);
        end
        n = count_covered(ax,lg,X,Y);
        fprintf('    %-18s panel %d: legend %-13s covered points = %d\n',sname,p,loc,n);
        rep(end+1,:) = {sname,p,loc,n}; %#ok<AGROW>
    end
end

function loc = raise_legend(ax,lg,X,Y)
% Walk a pinned legend straight upwards in small steps and keep the highest
% position that still covers no plotted point. The walk stops at the first step
% that touches a curve, or when the legend would leave the top of the axes, and
% the last clean position is restored. Only the vertical position changes.
    best = lg.Position; start = best(2);
    axTop = ax.Position(2) + ax.Position(4);
    step = 0.003;
    while true
        trial = best; trial(2) = trial(2) + step;
        if trial(2) + trial(4) > axTop - 0.004, break; end   % would leave the axes
        lg.Position = trial; drawnow;
        if count_covered(ax,lg,X,Y) > 0, break; end          % would touch a curve
        best = trial;
    end
    % Back off a little from the highest clean position. Stopping hard against
    % the curve above is clean by the measure but reads as cramped, so give the
    % legend three steps of clearance -- never dropping below where it started.
    best(2) = max(start, best(2) - 3*step);
    lg.Position = best; drawnow;
    fprintf('      raised %.3f of axes height %.3f (after %.3f clearance), x unchanged at %.4f\n', ...
            best(2)-start, ax.Position(4), 3*step, best(1));
    loc = 'raised';
end

function [X,Y] = line_points(ax)
% every finite plotted point in the axes
    ln = findobj(ax,'Type','line');
    X = []; Y = [];
    for i = 1:numel(ln)
        X = [X, ln(i).XData(:).']; Y = [Y, ln(i).YData(:).']; %#ok<AGROW>
    end
    good = isfinite(X) & isfinite(Y); X = X(good); Y = Y(good);
end

function out = place_legend(ax,labels,FNT,SZ,sname,panel)
% First-pass placement for one panel. Each candidate location is drawn and the
% overlap measured directly: every data point is mapped into figure-normalised
% coordinates and tested against the legend's own rectangle. The first location
% with zero covered points wins and is KEPT -- the legend is not re-created
% afterwards, so the object that was measured is the object that stays. If no
% in-axes location is clean the legend goes outside the axes, which cannot
% overlap by construction. finalize_legends re-checks all of this at the end.
    cand = {'best','northeast','northwest','southeast','southwest','north','south','east','west'};
    [X,Y] = line_points(ax);
    bestLoc = ''; bestN = inf;
    for c = 1:numel(cand)
        lg = legend(ax,labels,'Location',cand{c},'FontSize',SZ,'FontName',FNT);
        drawnow;
        n = count_covered(ax,lg,X,Y);
        if n < bestN, bestN = n; bestLoc = cand{c}; end
        if n == 0, break; end
    end
    if bestN > 0
        lg = legend(ax,labels,'Location','eastoutside','FontSize',SZ,'FontName',FNT);
        drawnow; bestLoc = 'eastoutside'; bestN = count_covered(ax,lg,X,Y);
    end
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

function curve(x,y,ci,STY)
    k=mod(ci-1,numel(STY.co))+1; x=x(:); y=y(:);
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
    % Panel title intentionally omitted; panel identified by axis labels and figure number (tl unused)
end
