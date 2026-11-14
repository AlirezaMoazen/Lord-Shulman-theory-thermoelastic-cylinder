function F = LSTE_fields_R1(D, P, X, sel)
%LSTE_FIELDS_R1  Displacements, strains and stresses from a stored LSTE state.
%  R1 (2026-11-14). Same kinematics and Hooke law as LSTE_solver_R11 section 7:
%      err = du/dr   ett = u/r   ezz = dw/dz   grz = du/dz + dw/dr  (engineering)
%      eth = al*theta   (isotropic thermal strain, theta = T - T_ref)
%      Srr = C11(err-eth) + C12(ett-eth) + C13(ezz-eth)
%      Stt = C12(err-eth) + C11(ett-eth) + C13(ezz-eth)
%      Szz = C13(err-eth) + C13(ett-eth) + C33(ezz-eth)
%      Trz = C55*grz
%  Derivatives use the layerwise DQ weights of the case, so the interface
%  nodes of adjacent layers carry each layer's own (discontinuous) strain/stress.
%
%  D   : struct with NL, N_r, N_z, r_nodes (NL x 1 cell), z_nodes
%  P   : layer constants from LSTE_props_R1
%  X   : Ndof x nt state matrix, x = [theta; u; w] (a snapshot, or X_hist)
%  sel : Ns x 3 list of nodes [layer, ir, iz]
%  F   : struct of Ns x nt arrays: r, z (Ns x 1), th, u, w, err, ett, ezz, grz,
%        Srr, Stt, Szz, Trz
NL = D.NL; N_r = D.N_r; N_z = D.N_z; Nn = NL*N_r*N_z;
idxTh = @(e,ir,iz)        (e-1)*N_r*N_z + (ir-1)*N_z + iz;
idxU  = @(e,ir,iz)   Nn + (e-1)*N_r*N_z + (ir-1)*N_z + iz;
idxW  = @(e,ir,iz) 2*Nn + (e-1)*N_r*N_z + (ir-1)*N_z + iz;
A_z = dq_weights(D.z_nodes(:).');
A_r = cell(NL,1);
for e = 1:NL, A_r{e} = dq_weights(D.r_nodes{e}(:).'); end

Ns = size(sel,1); nt = size(X,2);
names = {'th','u','w','err','ett','ezz','grz','Srr','Stt','Szz','Trz'};
for k = 1:numel(names), F.(names{k}) = zeros(Ns,nt); end
F.r = zeros(Ns,1); F.z = zeros(Ns,1);
for s = 1:Ns
    e = sel(s,1); ir = sel(s,2); iz = sel(s,3);
    r  = D.r_nodes{e}(ir);
    th = X(idxTh(e,ir,iz),:);
    u  = X(idxU(e,ir,iz),:);
    w  = X(idxW(e,ir,iz),:);
    dudr = A_r{e}(ir,:) * X(idxU(e,1:N_r,iz),:);
    dwdr = A_r{e}(ir,:) * X(idxW(e,1:N_r,iz),:);
    dudz = A_z(iz,:)    * X(idxU(e,ir,1:N_z),:);
    dwdz = A_z(iz,:)    * X(idxW(e,ir,1:N_z),:);
    err = dudr; ett = u/r; ezz = dwdz; grz = dudz + dwdr;
    eth = P.al(e)*th;
    F.r(s) = r;  F.z(s) = D.z_nodes(iz);
    F.th(s,:) = th;  F.u(s,:) = u;  F.w(s,:) = w;
    F.err(s,:) = err;  F.ett(s,:) = ett;  F.ezz(s,:) = ezz;  F.grz(s,:) = grz;
    F.Srr(s,:) = P.C11(e)*(err-eth) + P.C12(e)*(ett-eth) + P.C13(e)*(ezz-eth);
    F.Stt(s,:) = P.C12(e)*(err-eth) + P.C11(e)*(ett-eth) + P.C13(e)*(ezz-eth);
    F.Szz(s,:) = P.C13(e)*(err-eth) + P.C13(e)*(ett-eth) + P.C33(e)*(ezz-eth);
    F.Trz(s,:) = P.C55(e)*grz;
end
end

function A = dq_weights(x)
% DQ first-derivative weights (copy of DQ_weights in LSTE_solver_R11)
    N = numel(x);  A = zeros(N);
    for i = 1:N
        for j = 1:N
            if i~=j
                num=1; den=1;
                for k=1:N
                    if k~=i && k~=j
                        num = num*(x(i)-x(k));
                        den = den*(x(j)-x(k));
                    end
                end
                A(i,j) = num/(den*(x(j)-x(i)));
            end
        end
    end
    for i=1:N, A(i,i) = -sum(A(i,:)); end
end
