

% GP genareated


% Multilayer cylindrical heat conduction via Chebyshev DQM
% - Temperature continuity at each interface
% - Heat-flux continuity at each interface
% - External BCs: Dirichlet or Robin (convection)
% - Indexing order: r is fast (inner loop), z is slow (outer loop) within each layer

clear; clc;

%% ----------------------- USER INPUTS ------------------------------------
% Geometry
Ri      = 0.150;                % inner radius [m]
h_layer = [0.010, 0.010, 0.010];% layer thicknesses [m] (Nlay elements)
Lz      = 0.100;                % axial length [m]

% Materials per layer (constant within each layer)
kL   = [30, 15, 5];             % thermal conductivity [W/m-K] for each layer
% (Other mechanical properties are not needed for steady heat conduction)

% Collocation points per direction (Chebyshev–Gauss–Lobatto)
Nr = 8;                          % # radial points per layer (>=2)
Nz = 8;                          % # axial points (shared across layers)

% Boundary conditions
% Types: 'Dirichlet' or 'Robin'
BC_r_in.type  = 'Robin';         % at r = Ri  (inner surface)
BC_r_out.type = 'Dirichlet';     % at r = Ro  (outer surface)

% Values:
BC_r_in.T     = 350;             % used if Dirichlet
BC_r_out.T    = 300;             % used if Dirichlet
BC_r_in.h     = 100;             % convection coefficient [W/m^2-K], if Robin
BC_r_out.h    = 0;               % convection coefficient [W/m^2-K], if Robin
BC_r_in.Tinf  = 320;             % ambient temperature [K], if Robin
BC_r_out.Tinf = 300;             % ambient temperature [K], if Robin

% Axial boundaries z = 0 and z = Lz (same type for every layer)
BC_z_bot.type = 'Dirichlet';
BC_z_top.type = 'Dirichlet';
BC_z_bot.T    = 400;
BC_z_top.T    = 300;
BC_z_bot.h    = 0;       % if Robin
BC_z_top.h    = 0;       % if Robin
BC_z_bot.Tinf = 0;       % if Robin
BC_z_top.Tinf = 0;       % if Robin
%% ------------------------------------------------------------------------

% Sanity
Nlay = numel(h_layer);
Ro   = Ri + sum(h_layer);

% Chebyshev points & differentiation on [-1,1]
[xr, Dr_ref] = chebyshev_D( Nr );
[xz, Dz_ref] = chebyshev_D( Nz );

% Map axial to [0, Lz] (global for all layers)
Zscale = Lz/2; Zmid = Lz/2;
z_nodes = Zscale * xz + Zmid;
Dz = Dz_ref / Zscale;       % d/dz
Dzz = Dz*Dz;                % d2/dz2

% Pre-size per-layer data
r_nodes_layer = cell(Nlay,1);
Dr_layer      = cell(Nlay,1);
Drr_layer     = cell(Nlay,1);
NrNz          = Nr * Nz;    % we will use Nr x Nz (not Nr+1 by Nz+1) – already includes endpoints via Chebyshev

% Build per-layer radial grids and operators
Ri_accum = Ri;
for L = 1:Nlay
    Ri_L = Ri_accum;
    Ro_L = Ri_accum + h_layer(L);
    Ri_accum = Ro_L;

    Rscale = (Ro_L - Ri_L)/2; Rmid = (Ro_L + Ri_L)/2;
    r_nodes = Rscale * xr + Rmid;      % physical r nodes in this layer

    Dr = Dr_ref / Rscale;              % d/dr
    Drr= Dr*Dr;                        % d2/dr2

    r_nodes_layer{L} = r_nodes(:);
    Dr_layer{L}      = Dr;
    Drr_layer{L}     = Drr;
end

% Build block-diagonal operator for each layer:
% L[T] = k ( d2T/dr2 + (1/r) dT/dr + d2T/dz2 )
Ablocks = cell(Nlay,1);
for L = 1:Nlay
    rL  = r_nodes_layer{L};
    DrL = Dr_layer{L};
    DrrL= Drr_layer{L};
    kLw = kL(L);

    Lr = DrrL + diag(1./rL) * DrL;
    Lz = Dzz;

    % kron order: z-slow (rows), r-fast (cols). We keep r-fast ordering.
    % BUT for operator assembly on vector T(:), where T is (Nr x Nz),
    % we assume vectorization as [T(:,1); T(:,2); ... ; T(:,Nz)]
    % i.e., r-fast, z-slow. The operator becomes:
    Ablocks{L} = kLw * ( kron( eye(Nz), Lr ) + kron( Lz, eye(Nr) ) );
end

% Assemble global block diagonal
A = blkdiag(Ablocks{:});
b = zeros(size(A,1),1);

% Helper for indexing
nPerLayer = NrNz;                 % unknowns per layer
idxL = @(L) ( (L-1)*nPerLayer + (1:nPerLayer) );  % linear indices for layer L
% For a given layer L and axial slice j (1..Nz), the r-slice is:
idx_rs = idxL(L);                 
idx_rslice = @(j) idx_rs( (j-1)*Nr + (1:Nr) );  


%% Apply interface compatibility (for L = 1..Nlay-1)
% For each axial collocation j: 
%   (1) Temperature continuity:       T_L(r=Ro_L, z_j) - T_{L+1}(r=Ri_{L+1}, z_j) = 0
%   (2) Heat-flux continuity: k_L * (dT/dr)_L@Ro_L  -  k_{L+1} * (dT/dr)_{L+1}@Ri_{L+1} = 0
% These replace the two original PDE rows at those boundary nodes.

for L = 1:(Nlay-1)
    % Row masks at outer/inner radial boundaries
    DrL_end   = Dr_layer{L}(end,:);     % derivative row at r = Ro of layer L
    DrLp1_beg = Dr_layer{L+1}(1,:);     % derivative row at r = Ri of layer L+1

    for j = 1:Nz
        % Row indices in global matrix to replace:
        rowL    = idx_rslice(L, j);     rowL = rowL(end);     % r = Ro_L
        rowLp1  = idx_rslice(L+1, j);   rowLp1 = rowLp1(1);   % r = Ri_{L+1}

        % -------- Replace PDE row at (L, r end, z j) by: T_L - T_{L+1} = 0
        A(rowL,:) = 0;
        A(rowL, idx_rslice(L, j))   = A(rowL, idx_rslice(L, j))   + [zeros(1, Nr-1), 1];
        A(rowL, idx_rslice(L+1, j)) = A(rowL, idx_rslice(L+1, j)) + [-1, zeros(1, Nr-1)];
        b(rowL) = 0;

        % -------- Replace PDE row at (L+1, r beg, z j) by flux continuity
        A(rowLp1,:) = 0;
        % k_L * dT_L/dr at Ro_L
        A(rowLp1, idx_rslice(L, j))   = A(rowLp1, idx_rslice(L, j))   + kL(L)   * DrL_end;
        % - k_{L+1} * dT_{L+1}/dr at Ri_{L+1}
        A(rowLp1, idx_rslice(L+1, j)) = A(rowLp1, idx_rslice(L+1, j)) - kL(L+1) * DrLp1_beg;
        b(rowLp1) = 0;
    end
end

%% External radial boundary conditions
% Layer 1 inner boundary (r = Ri)
switch lower(BC_r_in.type)
    case 'dirichlet'
        for j = 1:Nz
            row = idx_rslice(1,j); row = row(1); % r = Ri of layer 1
            A(row,:) = 0; A(row,row) = 1; b(row) = BC_r_in.T;
        end
    case 'robin'
        % -k dT/dr = h (T - T_inf)  --> k(Dr_row) + h*I_row
        Dr_beg = Dr_layer{1}(1,:);
        for j = 1:Nz
            cols = idx_rslice(1,j);
            row  = cols(1);
            A(row,:) = 0;
            A(row, cols) = kL(1)*Dr_beg + BC_r_in.h * [1, zeros(1,Nr-1)];
            b(row)      = BC_r_in.h * BC_r_in.Tinf;
        end
    otherwise
        error('Unknown BC_r_in.type');
end

% Last layer outer boundary (r = Ro)
switch lower(BC_r_out.type)
    case 'dirichlet'
        for j = 1:Nz
            row = idx_rslice(Nlay,j); row = row(end); % r = Ro of last layer
            A(row,:) = 0; A(row,row) = 1; b(row) = BC_r_out.T;
        end
    case 'robin'
        Dr_end = Dr_layer{Nlay}(end,:);
        for j = 1:Nz
            cols = idx_rslice(Nlay,j);
            row  = cols(end);
            A(row,:) = 0;
            A(row, cols) = -kL(Nlay)*Dr_end + BC_r_out.h * [zeros(1,Nr-1), 1];
            b(row)       = BC_r_out.h * BC_r_out.Tinf;
        end
    otherwise
        error('Unknown BC_r_out.type');
end

%% Axial boundary conditions (same for all layers)
% z = 0 (bottom, j = 1)
switch lower(BC_z_bot.type)
    case 'dirichlet'
        for L = 1:Nlay
            cols = idx_rslice(L,1);
            for i = 1:Nr
                row = cols(i);
                A(row,:) = 0; A(row,row) = 1; b(row) = BC_z_bot.T;
            end
        end
    case 'robin'
        % -k dT/dz = h (T - T_inf)
        for L = 1:Nlay
            kLw = kL(L);
            Dz_row = Dz_ref(1,:) / Zscale; % derivative in z at z=0 in reference scaled to physical
            for i = 1:Nr
                row = idx_rslice(L,1); row = row(i);
                % dT/dz at z=0 acts on all Nz points along z for a fixed r(i):
                % With r-fast ordering, we need a small helper to write kron row.
                A(row,:) = 0;
                % Contribution along z at fixed r(i):
                for j = 1:Nz
                    cols = idx_rslice(L,j);
                    A(row, cols(i)) = A(row, cols(i)) - kLw * Dz(1,j);
                end
                A(row,row) = A(row,row) + BC_z_bot.h;
                b(row) = BC_z_bot.h * BC_z_bot.Tinf;
            end
        end
    otherwise
        error('Unknown BC_z_bot.type');
end

% z = Lz (top, j = Nz)
switch lower(BC_z_top.type)
    case 'dirichlet'
        for L = 1:Nlay
            cols = idx_rslice(L,Nz);
            for i = 1:Nr
                row = cols(i);
                A(row,:) = 0; A(row,row) = 1; b(row) = BC_z_top.T;
            end
        end
    case 'robin'
        % +k dT/dz = h (T - T_inf) at z=Lz  (outward normal +z)
        for L = 1:Nlay
            kLw = kL(L);
            for i = 1:Nr
                row = idx_rslice(L,Nz); row = row(i);
                A(row,:) = 0;
                for j = 1:Nz
                    cols = idx_rslice(L,j);
                    A(row, cols(i)) = A(row, cols(i)) + kLw * Dz(Nz,j);
                end
                A(row,row) = A(row,row) + BC_z_top.h;
                b(row) = BC_z_top.h * BC_z_top.Tinf;
            end
        end
    otherwise
        error('Unknown BC_z_top.type');
end

%% Solve
Tvec = A \ b;

%% Reshape solution per layer to T_rz{L}(Nr x Nz)
T_rz = cell(Nlay,1);
for L = 1:Nlay
    TL = Tvec( idxL(L) );
    T_rz{L} = reshape(TL, [Nr, Nz]);
end

%% (Optional) quick check of interface continuity (max jump)
max_jump_T = 0; max_jump_q = 0;
for L = 1:Nlay-1
    % temperature jump at interfaces along z-slices
    T_end   = T_rz{L}(end,:);      % r=Ro_L
    T_begin = T_rz{L+1}(1,:);      % r=Ri_{L+1}
    max_jump_T = max( [max_jump_T, max(abs(T_end - T_begin))] );

    % flux jump: k dT/dr at both sides (use Dr rows)
    qL   = kL(L)   * ( Dr_layer{L}(end,:)   * T_rz{L} );
    qLp1 = kL(L+1) * ( Dr_layer{L+1}(1,:)   * T_rz{L+1} );
    max_jump_q = max( [max_jump_q, max(abs(qL - qLp1))] );
end

fprintf('Max temperature jump at interfaces: %.3e K\n', max_jump_T);
fprintf('Max heat-flux jump at interfaces:  %.3e W/m^2\n', max_jump_q);

%% ------------------------ Plot (optional) -------------------------------
% Simple surface plot for each layer (z on x-axis, r on y-axis)
doPlot = true;
if doPlot
    figure;
    Ri_accum = Ri;
    for L = 1:Nlay
        rL = r_nodes_layer{L};
        [ZZ, RR] = meshgrid(z_nodes, rL);
        TL = T_rz{L};
        subplot(1,Nlay,L);
        surf(ZZ, RR, TL, 'EdgeColor','none'); view(2); colorbar;
        xlabel('z [m]'); ylabel('r [m]'); title(sprintf('Layer %d', L));
        Ri_accum = Ri_accum + h_layer(L);
    end
end

%% ==================== Chebyshev helper (CGL) ============================
function [x, D] = chebyshev_D(N)
% Returns Chebyshev–Gauss–Lobatto nodes (size N) and 1st-derivative matrix D (N x N)
% N >= 2
    if N < 2
        error('N must be >= 2');
    end
    % Nodes x in [-1,1], ordered from 1 to N
    k = (0:N-1)';
    x = cos(pi * k/(N-1));
    % Weights for differentiation matrix
    c = [2; ones(N-2,1); 2] .* (-1).^k;
    X = repmat(x,1,N);
    dX = X - X.';
    D  = (c*(1./c)')./(dX + eye(N));  % off-diagonal
    D  = D - diag(sum(D,2));          % diagonal
end
