



clc,
clear;
% function [T,N,M] = Displacements(r,z,t)


%% Number of nodes
 N=5;  %% r direction(one element or one layer)
 M=5;  %% z direction
 NM = N*M;
  
 NL=2;

 
 %%
C_T_ext=zeros(2*(NL-1)*(M-2),NM*NL);


 for i=0:NL-1
     
     if i==0
         
       %%%--- Positive r direction --> i & i+1
       
        A_r_G_L2_ext_p=L_2(1,i+1)*A_r_G(N,(i*N+1:(i+1)*N));
        A_r_G_L2_ext_n=-L_2(1,i+2)*A_r_G(1,((i+1)*N+1:(i+2)*N));
       
       for q=1:M-2
           for j=(i*NM+2*N):N:((i+1)*NM-N)
               for k=0:N-1
%                    C_T_ext((2*i)*(M-2)+q,j-k)=C_T_ext(j,j-k)+(GaM)*A_r_G_L2_ext_p(1,N-k);
                   C_T_ext((2*i)*(M-2)+q,j-k)=A_r_G_L2_ext_p(1,N-k);
               end 
           end
       end
       
       for q=1:M-2
           for j=(i*NM+2*N):N:((i+1)*NM-N)
               for k=0:N-1
%                    C_T_ext((2*i)*(M-2)+q,j+k+NM-N+1)=C_T_ext(j,j+k+NM-N+1)+(GaM)*A_r_G_L2_ext_n(1,k+1);
                   C_T_ext((2*i)*(M-2)+q,j+k+NM-N+1)=A_r_G_L2_ext_n(1,k+1);
               end 
           end
       end
       
      
       for q=1:M-2
           for j=(i*NM+2*N):N:((i+1)*NM-N)
%                C_T_ext((2*i)*(M-2)+q,j)=C_T_ext(j,j)+(GaM)*1-0;
               C_T_ext((2*i)*(M-2)+q,j)=C_T_ext(j,j)+1-0; 
           end
       end
       
       for q=1:M-2
           for j=(i*NM+2*N):N:((i+1)*NM-N)
%                C_T_ext((2*i)*(M-2)+q,j+NM-N+1)=C_T_ext(j,j+NM-N+1)-(GaM)*1+0;
               C_T_ext((2*i)*(M-2)+q,j+NM-N+1)=C_T_ext(j,j+NM-N+1)-1+0;
           end
       end
       

     elseif i==NL-1
         
       %%%--- Negative r direction --> i-1 & i
       
       A_r_G_L2_ext_p=-L_2(1,i)*A_r_G(N,((i-1)*N+1:(i)*N));
       A_r_G_L2_ext_n=L_2(1,i+1)*A_r_G(1,((i)*N+1:(i+1)*N));
       
       
       for q=1:M-2
           for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
               for k=0:N-1
%                    C_T_ext((2*i-1)*(M-2)+q,j-k-NM+N-1)=C_T_ext(j,j-k-NM+N-1)+(GaM)*A_r_G_L2_ext_p(1,N-k);
                   C_T_ext((2*i-1)*(M-2)+q,j-k-NM+N-1)=A_r_G_L2_ext_p(1,N-k);
               end 
           end
       end
       
       for q=1:M-2
           for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
               for k=0:N-1
%                    C_T_ext((2*i-1)*(M-2)+q,j+k)=C_T_ext(j,j+k)+(GaM)*A_r_G_L2_ext_n(1,k+1);
                   C_T_ext((2*i-1)*(M-2)+q,j+k)=A_r_G_L2_ext_n(1,k+1);
               end 
           end
       end
       
       
       for q=1:M-2
           for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%                C_T_ext((2*i-1)*(M-2)+q,(j-NM+N-1))=C_T_ext(j,(j-NM+N-1))+(GaM)*1-0;
               C_T_ext((2*i-1)*(M-2)+q,(j-NM+N-1))=C_T_ext(j,(j-NM+N-1))+1-0;
           end
       end
       
       for q=1:M-2
           for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%                C_T_ext((2*i-1)*(M-2)+q,j)=C_T_ext(j,j)-(GaM)*1+0;
               C_T_ext((2*i-1)*(M-2)+q,j)=C_T_ext(j,j)-1+0; 
          end
       end
       
       
       
     elseif i~=0 && i~=NL-1
         
       %%%--- Negative r direction --> i-1 & i
       
       A_r_G_L2_ext_p=-L_2(1,i)*A_r_G(N,((i-1)*N+1:(i)*N));
       A_r_G_L2_ext_n=L_2(1,i+1)*A_r_G(1,((i)*N+1:(i+1)*N));
       
       for q=1:M-2
           for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
               for k=0:N-1
%                    C_T_ext((2*i-1)*(M-2)+q,j-k-NM+N-1)=C_T_ext(j,j-k-NM+N-1)+(GaM)*A_r_G_L2_ext_p(1,N-k);
                   C_T_ext((2*i-1)*(M-2)+q,j-k-NM+N-1)=A_r_G_L2_ext_p(1,N-k);
               end 
           end
       end
       
       for q=1:M-2
           for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
               for k=0:N-1
%                    C_T_ext((2*i-1)*(M-2)+q,j+k)=C_T_ext(j,j+k)+(GaM)*A_r_G_L2_ext_n(1,k+1);
                   C_T_ext((2*i-1)*(M-2)+q,j+k)=A_r_G_L2_ext_n(1,k+1);
               end 
           end
       end
       
       
       for q=1:M-2
           for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%                C_T_ext((2*i-1)*(M-2)+q,(j-NM+N-1))=C_T_ext(j,(j-NM+N-1))+(GaM)*1-0;
               C_T_ext((2*i-1)*(M-2)+q,(j-NM+N-1))=C_T_ext(j,(j-NM+N-1))+1-0;
           end
       end
       
       for q=1:M-2
           for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%                C_T_ext((2*i-1)*(M-2)+q,j)=C_T_ext(j,j)-(GaM)*1+0;
               C_T_ext((2*i-1)*(M-2)+q,j)=C_T_ext(j,j)-1+0; 
          end
       end
       
       %%%--- Positive r direction --> i & i+1
       
        A_r_G_L2_ext_p=L_2(1,i+1)*A_r_G(N,(i*N+1:(i+1)*N));
        A_r_G_L2_ext_n=-L_2(1,i+2)*A_r_G(1,((i+1)*N+1:(i+2)*N));
         
       for q=1:M-2
           for j=(i*NM+2*N):N:((i+1)*NM-N)
               for k=0:N-1
%                    C_T_ext((2*i)*(M-2)+q,j-k)=C_T_ext(j,j-k)+(GaM)*A_r_G_L2_ext_p(1,N-k);
                   C_T_ext((2*i)*(M-2)+q,j-k)=A_r_G_L2_ext_p(1,N-k);
               end 
           end
       end
       
       for q=1:M-2
           for j=(i*NM+2*N):N:((i+1)*NM-N)
               for k=0:N-1
%                    C_T_ext((2*i)*(M-2)+q,j+k+NM-N+1)=C_T_ext(j,j+k+NM-N+1)+(GaM)*A_r_G_L2_ext_n(1,k+1);
                   C_T_ext((2*i)*(M-2)+q,j+k+NM-N+1)=A_r_G_L2_ext_n(1,k+1);
               end 
           end
       end
       
      
       for q=1:M-2
           for j=(i*NM+2*N):N:((i+1)*NM-N)
%                C_T_ext((2*i)*(M-2)+q,j)=C_T_ext(j,j)+(GaM)*1-0;
               C_T_ext((2*i)*(M-2)+q,j)=C_T_ext(j,j)+1-0; 
           end
       end
       
       for q=1:M-2
           for j=(i*NM+2*N):N:((i+1)*NM-N)
%                C_T_ext((2*i)*(M-2)+q,j+NM-N+1)=C_T_ext(j,j+NM-N+1)-(GaM)*1+0;
               C_T_ext((2*i)*(M-2)+q,j+NM-N+1)=C_T_ext(j,j+NM-N+1)-1+0;
           end
       end
       
       
       
       
     end
 end

  
 
 %%
 
 
 for i=0:NL-1
     
     if i==0
         
       %%%--- Positive r direction --> i & i+1
       
        A_r_G_L2_ext_p=L_2(1,i+1)*A_r_G(N,(i*N+1:(i+1)*N));
        A_r_G_L2_ext_n=-L_2(1,i+2)*A_r_G(1,((i+1)*N+1:(i+2)*N));
         
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           for k=0:N-1
               C_T(j,j-k)=A_r_G_L2_ext_p(1,N-k);
           end 
       end
       
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           for k=0:N-1
               C_T(j,j+k+NM-N+1)=A_r_G_L2_ext_n(1,k+1);
           end 
       end
       
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           C_T(j,j)=C_T(j,j)+1-0; 
       end
       
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           C_T(j,j+NM-N+1)=C_T(j,j+NM-N+1)-1+0;
       end
       
       
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           for q=1:M-2
               C_T_ext((2*i)*(M-2)+q,:)=C_T(j,:);
           end
       end
       
       
     elseif i==NL-1
         
       %%%--- Negative r direction --> i-1 & i
       
       A_r_G_L2_ext_p=-L_2(1,i)*A_r_G(N,((i-1)*N+1:(i)*N));
       A_r_G_L2_ext_n=L_2(1,i+1)*A_r_G(1,((i)*N+1:(i+1)*N));
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           for k=0:N-1
               C_T(j,j-k-NM+N-1)=A_r_G_L2_ext_p(1,N-k);
           end 
       end
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           for k=0:N-1
               C_T(j,j+k)=A_r_G_L2_ext_n(1,k+1);
           end 
       end
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           C_T(j,(j-NM+N-1))=C_T(j,(j-NM+N-1))+1-0;
       end
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           C_T(j,j)=C_T(j,j)-1+0; 
       end
       
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           for q=1:M-2
               C_T_ext((2*i-1)*(M-2)+q,:)=C_T(j,:);
           end 
       end
       
       
     elseif i~=0 && i~=NL-1
         
       %%%--- Negative r direction --> i-1 & i
       
       A_r_G_L2_ext_p=-L_2(1,i)*A_r_G(N,((i-1)*N+1:(i)*N));
       A_r_G_L2_ext_n=L_2(1,i+1)*A_r_G(1,((i)*N+1:(i+1)*N));
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           for k=0:N-1
               C_T(j,j-k-NM+N-1)=A_r_G_L2_ext_p(1,N-k);
           end 
       end
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           for k=0:N-1
               C_T(j,j+k)=A_r_G_L2_ext_n(1,k+1);
           end 
       end
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           C_T(j,(j-NM+N-1))=C_T(j,(j-NM+N-1))+1-0;
       end
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           C_T(j,j)=C_T(j,j)-1+0; 
       end
       
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           for q=1:M-2
               C_T_ext((2*i-1)*(M-2)+q,:)=C_T(j,:);
           end 
       end
       
       
       %%%--- Positive r direction --> i & i+1
       
        A_r_G_L2_ext_p=L_2(1,i+1)*A_r_G(N,(i*N+1:(i+1)*N));
        A_r_G_L2_ext_n=-L_2(1,i+2)*A_r_G(1,((i+1)*N+1:(i+2)*N));
         
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           for k=0:N-1
               C_T(j,j-k)=A_r_G_L2_ext_p(1,N-k);
           end 
       end
       
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           for k=0:N-1
               C_T(j,j+k+NM-N+1)=A_r_G_L2_ext_n(1,k+1);
           end 
       end
       
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           C_T(j,j)=C_T(j,j)+1-0; 
       end
       
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           C_T(j,j+NM-N+1)=C_T(j,j+NM-N+1)-1+0;
       end
       
       
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           for q=1:M-2
               C_T_ext((2*i)*(M-2)+q,:)=C_T(j,:);
           end
       end
       
     end
  end


 
 
 
 
