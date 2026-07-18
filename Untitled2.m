
clc,clear;

N=7;
M=17;
NM=N*M;





           
          L_1(1,1:N) = 2;
          L_2(1,1:N) = 3;
          L_3(1,1:N) = 5;
%           L_4(1,1:N) = ro*Sc;


A_r_new = ones(NM,2*N);
B_r_new = ones(NM,2*N);

A_z_new = ones(NM,2*N);
B_z_new = ones(NM,2*N);




i=0;
j=0;
for i=1:M
      for j=0:(N-1)
          
          C_T_1((i*j)+1:(j+1)*i,:) = L_1(1,(j+1)).*A_r_new((i*j)+1:(j+1)*i,:);
          
      end 
end

for i=1:M
      for j=0:(N-1)
          
          C_T_2((i*j)+1:(j+1)*i,:) = L_2(1,(j+1)).*B_r_new((i*j)+1:(j+1)*i,:);
          
      end 
end

for i=1:M
      for j=0:(N-1)
          
          C_T_3((i*j)+1:(j+1)*i,:) = L_3(1,(j+1)).*A_z_new((i*j)+1:(j+1)*i,:);
          
      end 
end

for i=1:M
      for j=0:(N-1)
          
          C_T_4((i*j)+1:(j+1)*i,:) = L_2(1,(j+1)).*B_z_new((i*j)+1:(j+1)*i,:);
          
      end 
end

C_T_1
C_T_2
C_T_3
C_T_4






