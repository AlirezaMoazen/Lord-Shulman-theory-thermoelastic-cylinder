

%%

L_1 = zeros(1,N*NL);
L_2 = zeros(1,NL);
L_3 = zeros(1,NL);
L_4 = zeros(1,NL);

J_1 = zeros(1,NL);
J_2 = zeros(1,N*NL);
J_3 = zeros(1,NL);
J_4 = zeros(1,N*NL);
J_5 = zeros(1,N*NL);
J_6 = zeros(1,NL);
J_7 = zeros(1,NL);
J_7_p = zeros(1,NL);
J_8 = zeros(1,NL);
J_8_p = zeros(1,NL);
J_9 = zeros(1,NL);
J_10 = zeros(1,NL);
J_11 = zeros(1,N*NL);
J_12 = zeros(1,N*NL);
J_13 = zeros(1,N*NL);






for j=1:NL
        
L_2(1,j) = ka(1,j);
L_3(1,j) = 0;
L_4(1,j) = ro(1,j)*Sc(1,j);

J_1(1,j) = C_11(1,j);
J_3(1,j) = C_55(1,j);
J_6(1,j) = C_55(1,j)+C_13(1,j);
J_7(1,j) = (d_r_C_11+d_r_C_12+d_r_C_13)*al(1,j);
J_7_p(1,j) = (d_r_C_11+d_r_C_12+d_r_C_13)*al(1,j) + (C_11(1,j)+C_12(1,j)+C_13(1,j))*d_r_al;
J_8(1,j) = C_11+C_12+C_13;
J_8_p(1,j) = (C_11(1,j)+C_12(1,j)+C_13(1,j))*al(1,j);
J_9(1,j) = ro(1,j);
J_10(1,j) = C_12(1,j);


end










%%
clc,clear;
format short;
% format long;
N=3;
M=13;
NL=5;
R_i=25;
Lt=20;
R_o=R_i+NL*Lt;

r_l=zeros(1,N);
r_G=zeros(1,N*NL);

for i=1:N
    r_l(i)=0.5*(1-cos((i-1)*pi/(N-1)));
  
end
    for j=0:NL-1
%         r_G_1((j*N+1):(j*N+N))=r_l(1:N)*(Lt*(j+1));%+Lt*j;
% %         r_G_1((j+1)*N+1)=r_G_1((j+1)*N+2);
%         r_G_2((j*N+1):(j*N+N))=r_G_1((j*N+1):(j*N+N))+R_i+j;
%         r_G_2((j*N+1):(j*N+N))=r_G_1((j*N+1):(j*N+N))+R_i+j;
        
        
%         r_G((j*N+1):(j*N+N))=r_l(1:N)+R_i+j;        
% %         r_G((1):(N))=r_G((1):(N));
% %         r_G((j+1*N+1):(j+1*N+N))=r_G((j+1*N+1):(j+1*N+N)).*(Lt*j+1);
        
        
%         r_G((j*N+1):(j*N+N))=r_l(1:N)*(Lt*(j+1))+R_i+Lt*j;

        
% %         r_G((j*N+1):(j*N+N))= r_G((j*N+1):(j*N+N))*Lt
        
% %         r_G((j*N+1):(j*N+N))=r_l(1:N)*Lt*(j+1)+R_i;
          
% %         r_G((j*N+1):(j*N+N))=r_l(1:N)+R_i+Lt*j;
% %         r_G((j+1*N+1):(j+1*N+N))=r_G((j+1*N+1):(j+1*N+N))+Lt*j+1;
% %         r_G((j+1*N+1):(j+1*N+N))=r_G((j+1*N+1):(j+1*N+N))+(Lt*j+1)/NL*Lt;



%         r_G_b(j*N+1)=r_l(1)+R_i+Lt*j;        
%         r_G_b(j*N+N)=r_l(N)*(Lt*(j+1))+R_i;

        
        
        
        
        co((j*N+1):(j*N+N))=r_l(1:N)+j;
        co_b=co*Lt;
        co_r=co_b+R_i;
        r_G=co_r;
        
        
    end
% end
% r_G= r_G_1+R_i;

% r_G_bar = (r_G-R_i)/NL*Lt;

r_G_bar = (r_G-R_i)/(NL*Lt);





r_m=zeros(1,NL);

for k=0:NL-1
     r_m(k+1)=R_i+Lt/2+Lt*k;
%       r_m_bar=r_m-R_i;
      r_m_bar=(r_m-R_i)/(NL*Lt);
%       r_m_bar=r_m_bar/(NL*Lt);
%       r_m_bar=r_m_bar/Lt;
%       r_m_bar=r_m_bar-Lt;
%       r_m_bar=r_m_bar-k;

%      r_m_bar=r_m-k;
%      r_m_bar=r_m_bar/Lt;
%      r_m_bar=r_m_bar-R_i





end

r_m;
r_m_bar;

z=zeros(1,M);
for i=1:M
    z(i)=0.5*(1-cos((i-1)*pi/(M-1)));
    
end


z_s=z-0.5

r_l;
r_G;
r_m;

r_G_bar;
r_m_bar;

%%



 for i=0:NL-1
     
     r(1:N)=r_G_bar((i*N+1):(i*N+N)); 
 
 r;
  if r==0
      r=eps;
    for j=1:N
 
        L_1(1,j) = (ka(1,i+1)*1^(-12))/r(1,j);
        J_2(1,j) = d_r_C_11+(C_11(1,i+1)/r(1,j));
        J_4(1,j) = d_r_C_12/r(1,j)-(C_22(1,i+1)/(r(1,j)*r(1,j)));
        J_5(1,j) = d_r_C_13+((C_13(1,i+1)-C_23(1,i+1))/r(1,j));
        J_11(1,j) = d_r_C_55+(C_55(1,i+1)/r(1,j));
        J_12(1,j) = d_r_C_55+((C_23(1,i+1)+C_55(1,i+1))/r(1,j));
        J_13(1,j) = C_23(1,i+1)/r(1,j);
 
    end
     
  elseif r~=0
        
    for j=1:N
 
        L_1(1,j) = (ka(1,i+1)*1^(-12))/r(1,j);
        J_2(1,j) = d_r_C_11+(C_11(1,i+1)/r(1,j));
        J_4(1,j) = d_r_C_12/r(1,j)-(C_22(1,i+1)/(r(1,j)*r(1,j)));
        J_5(1,j) = d_r_C_13+((C_13(1,i+1)-C_23(1,i+1))/r(1,j));
        J_11(1,j) = d_r_C_55+(C_55(1,i+1)/r(1,j));
        J_12(1,j) = d_r_C_55+((C_23(1,i+1)+C_55(1,i+1))/r(1,j));
        J_13(1,j) = C_23(1,i+1)/r(1,j);
 
     end   
      
  end
  
  L_1_G(:,(i*N+1):(i*N+N)) = L_1(:,:);
  J_2_G(:,(i*N+1):(i*N+N)) = J_2(:,:);
  J_4_G(:,(i*N+1):(i*N+N)) = J_4(:,:);
  J_5_G(:,(i*N+1):(i*N+N)) = J_5(:,:);
  J_11_G(:,(i*N+1):(i*N+N)) = J_11(:,:);
  J_12_G(:,(i*N+1):(i*N+N)) = J_12(:,:);
  J_13_G(:,(i*N+1):(i*N+N)) = J_13(:,:);    
      
 
 end












%%




 A_r=zeros(N);
 B_r=zeros(N);
 r=zeros(1,N);
 A_r_G=zeros(N,N*NL);
 B_r_G=zeros(N,N*NL);
 
 
 for i=0:NL-1
%         r(1:N)=r_G((i*N+1):(i*N+N)); 
        r(1:N)=r_G_bar((i*N+1):(i*N+N)); 
 
 r;
 for ii=1:N
    for jj=1:N
         qi_r=1;qj_r=1;
       for kk=1:N 
          if kk~=ii  
              qi_r=(r(ii)-r(kk))*qi_r;
          end
          if kk~=jj  
              qj_r=(r(jj)-r(kk))*qj_r;
          end   
       end
       if ii~=jj 
           A_r(ii,jj)=qi_r/((r(ii)-r(jj))*qj_r);
       end   
    end  
    for kk=1:N  
       if kk~=ii
           A_r(ii,ii)=A_r(ii,ii)-A_r(ii,kk);
       end
    end
 end
 A_r;
 
 A_r_G(:,(i*N+1):(i*N+N))=A_r(:,:);
 
 end
 
%  for ii=1:N
%     for jj=1:N
%          B_r(ii,jj)=0;
%     end  
%  end    
 
 
 for i=0:NL-1        
        A_r(:,:)=A_r_G(:,(i*N+1):(i*N+N)); 
 
 A_r;
 
 for ii=1:N
    for jj=1:N
       if ii~=jj
           B_r(ii,jj)=2*(A_r(ii,ii)*A_r(ii,jj)-(A_r(ii,jj)/(r(ii)-r(jj))));
       end   
    end      
    for kk=1:N
       if ii~=kk
           B_r(ii,ii)=B_r(ii,ii)-B_r(ii,kk);
       end   
    end    
 end
 B_r;

B_r_G(:,(i*N+1):(i*N+N))=B_r(:,:);

 end


%%











