clc,clear;

N=15;
M=7;
NM=N*M;


A_z_new = ones(NM,NM);

J=zeros(N,1);
for i=1:N
    J(1,i) = i;
end

J;


A_z_new_J = zeros(NM,NM);
i=0;j=0;k=0;
for j=1:N
    for i=0:(M-1)
      A_z_new_J((i*N+1)+k,:) = J(1,j)*A_z_new((i*N+1)+k,:);
    end
    k=k+1;
end





A_z_new_J_1=A_z_new_J(:,1);
A_z_new_J_1=reshape(A_z_new_J_1,N,M);
