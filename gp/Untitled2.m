

% GP genareated

% Multilayer DQM code with interface continuity (Temperature + Heat Flux)
% All comments and explanations are in English only

clearall; clc;

% Number of layers
Nlay = 3;

% Thickness of each layer
h = [0.02, 0.03, 0.025];
Htotal = sum(h);

% Material properties for each layer
E   = [200e9, 150e9, 100e9];
nu  = [0.3, 0.28, 0.25];
rho = [7800, 7600, 7400];
k   = [20, 15, 10];

% Chebyshev collocation points in each layer (Nr x Nz)
Nr = 6; Nz = 6;

% Build DQM differentiation matrices
[xr, Ar] = chebyshev(Nr);
[xz, Bz] = chebyshev(Nz);

% Initialize global system
A_blocks = cell(Nlay,1);
r_nodes_layers = cell(Nlay,1);

% Loop over layers
for i = 1:Nlay
    % Local coordinates scaled to physical layer thickness
    Ri = sum(h(1:i-1));
    Ro = Ri + h(i);
    Rscale = (Ro - Ri)/2;
    Rmid   = (Ro + Ri)/2;
    r_nodes = Rscale*xr + Rmid;
    r_nodes_layers{i} = r_nodes;

    % Scale differentiation matrices
    Ar_scaled = Ar / Rscale;
    Bz_scaled = Bz / 1; % assume length in z = 1 for simplicity

    % Local operator (heat conduction in cylindrical coordinates)
    Lr = Ar_scaled*Ar_scaled + diag(1./r_nodes)*Ar_scaled;
    Lz = Bz_scaled*Bz_scaled;
    A_local = k(i)*(kron(eye(Nz),Lr) + kron(Lz,eye(Nr)));

    A_blocks{i} = A_local;
end

% Assemble block diagonal system
A_global = blkdiag(A_blocks{:});

% Interface continuity conditions
for i = 1:Nlay-1
    % Indices of last radial node in layer i and first radial node in layer i+1
    nLayer = (Nr+1)*(Nz+1);
    offset_i   = (i-1)*nLayer;
    offset_ip1 = i*nLayer;

    % Select rows corresponding to inner/outer interfaces (here: radial boundary)
    % For simplicity, assume node ordering: (Nr+1) in r-direction x (Nz+1) in z-direction
    % So the last radial node of layer i corresponds to indices: (Nr+1), 2*(Nr+1), ...

    for j = 1:(Nz+1)
        idx_i   = offset_i   + j*(Nr+1);   % outer boundary node of layer i
        idx_ip1 = offset_ip1 + (j-1)*(Nr+1) + 1; % inner boundary node of layer i+1

        % --- Temperature continuity: T(i,end) - T(i+1,1) = 0 ---
        eq_temp = zeros(1,size(A_global,1));
        eq_temp(idx_i)   = 1;
        eq_temp(idx_ip1) = -1;

        A_global(end+1,:) = eq_temp;
    end

    % Heat flux continuity (radial derivative)
    for j = 1:(Nz+1)
        idx_i   = offset_i   + j*(Nr+1);
        idx_ip1 = offset_ip1 + (j-1)*(Nr+1) + 1;

        eq_flux = zeros(1,size(A_global,1));

        % Apply derivative operator at boundary nodes
        eq_flux(offset_i+(j-1)*(Nr+1)+1:offset_i+j*(Nr+1)) = k(i)*Ar(end,:);
        eq_flux(offset_ip1+(j-1)*(Nr+1)+1:offset_ip1+j*(Nr+1)) = -k(i+1)*Ar(1,:);

        A_global(end+1,:) = eq_flux;
    end
end

% Apply boundary conditions at external surfaces
% Example: Dirichlet T=0 at inner and outer radius
% Replace corresponding rows
A_global(1,:) = 0; A_global(1,1) = 1;
A_global(Nr+1,:) = 0; A_global(Nr+1,Nr+1) = 1;

% Solve system (example with dummy RHS)
RHS = ones(size(A_global,1),1);
T_sol = A_global \ RHS;

% --- Chebyshev subfunction ---
function [x,D] = chebyshev(N)
    if N==0
        x=1; D=0;
        return
    end
    x = cos(pi*(0:N)/N)';
    c = [2; ones(N-1,1); 2].*(-1).^(0:N)';
    X = repmat(x,1,N+1);
    dX = X - X';
    D  = (c*(1./c)')./(dX+eye(N+1));
    D  = D - diag(sum(D,2));
end
