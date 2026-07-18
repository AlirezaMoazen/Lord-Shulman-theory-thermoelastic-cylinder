

% Compatibility conditions
% Boundry conditions
% Global & Local Weight functions



%%
% clc,clear;
N=5;
M=5;
NM=N*M;
NL=2;
R_i=15;
Lt=10;
R_o=R_i+NL*Lt;

r_l=zeros(1,N);
r_G=zeros(1,N*NL);

for i=1:N
    r_l(i)=0.5*(1-cos((i-1)*pi/(N-1)));
  
end
for j=0:NL-1
    co((j*N+1):(j*N+N))=r_l(1:N)+j;
    r_G=(co*Lt)+R_i;
    
end
    

r_G_bar = (r_G-R_i)/(NL*Lt);




%%




A_r=zeros(N);
B_r=zeros(N);
A_r_G=zeros(N,N*NL);
B_r_G=zeros(N,N*NL);
A_r_G_new=zeros(NM*NL);
B_r_G_new=zeros(NM*NL);
r=zeros(1,N);
 
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
 
 
 for k=0:(M-1)
    A_r_new((k*N+1):(k*N+N),(k*N+1):(k*N+N)) = A_r(1:N,1:N);
 end
A_r_new;


 A_r_G(:,(i*N+1):(i*N+N))=A_r(:,:);
 
 A_r_G_new((i*NM+1):(i*NM+NM),(i*NM+1):(i*NM+NM)) = A_r_new(1:NM,1:NM);

 
 
 end
 
 A_r_G;  
 A_r_G_new;
 
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
 
 
 for k=0:(M-1)
    B_r_new((k*N+1):(k*N+N),(k*N+1):(k*N+N)) = B_r(1:N,1:N);
 end
B_r_new;


B_r_G(:,(i*N+1):(i*N+N))=B_r(:,:);

B_r_G_new((i*NM+1):(i*NM+NM),(i*NM+1):(i*NM+NM)) = B_r_new(1:NM,1:NM);

 end

 B_r_G;
 B_r_G_new;
  
%% 

A_r_G_new_1Com=A_r_G_new;
% A_r_G_new_1Com=zeros(NM*NL);
A_r_G_new_2Com=A_r_G_new;
% A_r_G_new_2Com=zeros(NM*NL);

A_r_G_new_3Com=zeros(NM*NL);

A_r_G_new_4Com=zeros(NM*NL);

A_r_G_new_5Com=zeros(NM*NL);

 %%%compati
 
 
  for i=0:NL-1
     
     if i==0
         
       %%%--- Positive r direction --> i & i+1
       
        A_r_G_new_1Com((i*NM+2*N):N:((i+1)*NM-N),:)=0;
       
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           A_r_G_new_1Com(j,j)=1;
       end 
       
         
     elseif i==NL-1
         
       %%%--- Negative r direction --> i-1 & i
       
       A_r_G_new_1Com((i*NM+N+1):N:((i+1)*NM-2*N+1),:)=0;
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           A_r_G_new_1Com(j,j)=1;
       end
       
     elseif i~=0 && i~=NL-1
         
       %%%--- Negative r direction --> i-1 & i
       
       A_r_G_new_1Com((i*NM+N+1):N:((i+1)*NM-2*N+1),:)=0;
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           A_r_G_new_1Com(j,j)=1;
       end
       
       %%%--- Positive r direction --> i & i+1
       
        A_r_G_new_1Com((i*NM+2*N):N:((i+1)*NM-N),:)=0;
       
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           A_r_G_new_1Com(j,j)=1;
       end 
       
     end
  end
  
  
  
  
 for i=0:NL-1
     
     if i==0
         
       %%%--- Positive r direction --> i & i+1
       
        A_r_G_new_2Com((i*NM+2*N):N:((i+1)*NM-N),:)=0;
       
%        for j=(i*NM+2*N):N:((i+1)*NM-N)
%            A_r_G_new_2Com(j,j)=1;
%        end 
       
         
     elseif i==NL-1
         
       %%%--- Negative r direction --> i-1 & i
       
       A_r_G_new_2Com((i*NM+N+1):N:((i+1)*NM-2*N+1),:)=0;
       
%        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%            A_r_G_new_2Com(j,j)=1;
%        end
       
     elseif i~=0 && i~=NL-1
         
       %%%--- Negative r direction --> i-1 & i
       
       A_r_G_new_2Com((i*NM+N+1):N:((i+1)*NM-2*N+1),:)=0;
       
%        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%            A_r_G_new_2Com(j,j)=1;
%        end
       
       %%%--- Positive r direction --> i & i+1
       
        A_r_G_new_2Com((i*NM+2*N):N:((i+1)*NM-N),:)=0;
       
%        for j=(i*NM+2*N):N:((i+1)*NM-N)
%            A_r_G_new_2Com(j,j)=1;
%        end 
       
     end
  end


  
 
  i=0;
  c=0;
  Li_N=0;
for i=1:NM*NL
    if A_r_G_new_1Com(i,i)==1
        c=c+1;
        Li_N(1,c)=i;
    end
end

c;
Li_N;
  
A_r_G_new_1Com;

A_r_G_new_2Com=A_r_G_new-A_r_G_new_2Com;


% L_2=ones(1,NL);

for i=1:NL
    L_2(1,i)=i+1;
    
end


% A_r_G=ones(N,N*NL);




 for i=0:NL-1
     
     if i==0
         
       %%%--- Positive r direction --> i & i+1
       
        A_r_G_new_3Com((i*NM+2*N):N:((i+1)*NM-N),:)=0;
        A_r_G_L2_ext_p=L_2(1,i+1)*A_r_G(N,(i*N+1:(i+1)*N))-L_2(1,i+2)*A_r_G(1,((i+1)*N+1:(i+2)*N));

       for j=(i*NM+2*N):N:((i+1)*NM-N)
           for k=0:N-1
               A_r_G_new_3Com(j,j-k)=A_r_G_L2_ext_p(1,N-k);
           end 
       end
       
         
     elseif i==NL-1
         
       %%%--- Negative r direction --> i-1 & i
       
       A_r_G_new_3Com((i*NM+N+1):N:((i+1)*NM-2*N+1),:)=0;
       A_r_G_L2_ext_n=L_2(1,i)*A_r_G(N,((i-1)*N+1:(i)*N))-L_2(1,i+1)*A_r_G(1,((i)*N+1:(i+1)*N));
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           for k=0:N-1
               A_r_G_new_3Com(j,j+k)=A_r_G_L2_ext_n(1,k+1);
           end
       end
       
     elseif i~=0 && i~=NL-1
         
       %%%--- Negative r direction --> i-1 & i
       
       A_r_G_new_3Com((i*NM+N+1):N:((i+1)*NM-2*N+1),:)=0;
       A_r_G_L2_ext_n=L_2(1,i)*A_r_G(N,((i-1)*N+1:(i)*N))-L_2(1,i+1)*A_r_G(1,((i)*N+1:(i+1)*N));
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           for k=0:N-1
               A_r_G_new_3Com(j,j+k)=A_r_G_L2_ext_n(1,k+1);
           end
       end
       
       %%%--- Positive r direction --> i & i+1
       
        A_r_G_new_3Com((i*NM+2*N):N:((i+1)*NM-N),:)=0;
        A_r_G_L2_ext_p=L_2(1,i+1)*A_r_G(N,(i*N+1:(i+1)*N))-L_2(1,i+2)*A_r_G(1,((i+1)*N+1:(i+2)*N));

       for j=(i*NM+2*N):N:((i+1)*NM-N)
           for k=0:N-1
               A_r_G_new_3Com(j,j-k)=A_r_G_L2_ext_p(1,N-k);
           end 
       end
       
     end
  end




 for i=0:NL-1
     
     if i==0
         
       %%%--- Positive r direction --> i & i+1
       
        A_r_G_new_4Com((i*NM+2*N):N:((i+1)*NM-N),:)=0;
       
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           A_r_G_new_4Com(j,j)=1;
       end 
       
         
     elseif i==NL-1
         
       %%%--- Negative r direction --> i-1 & i
       
       A_r_G_new_4Com((i*NM+N+1):N:((i+1)*NM-2*N+1),:)=0;
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           A_r_G_new_4Com(j,j)=1;
       end
       
     elseif i~=0 && i~=NL-1
         
       %%%--- Negative r direction --> i-1 & i
       
       A_r_G_new_4Com((i*NM+N+1):N:((i+1)*NM-2*N+1),:)=0;
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           A_r_G_new_4Com(j,j)=1;
       end
       
       %%%--- Positive r direction --> i & i+1
       
        A_r_G_new_4Com((i*NM+2*N):N:((i+1)*NM-N),:)=0;
       
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           A_r_G_new_4Com(j,j)=1;
       end 
       
     end
 end



 T_UP    = 400 ;  %% Positive z direction
 T_DOWN  = 500 ;  %% Negative z direction
 T_LEFT  = 600 ;  %% Negative r direction
 T_RIGHT = 300 ;  %% Positive r direction
 
 
 

T_Side_A = T_LEFT;
T_Side_B = T_DOWN;
T_Side_C = T_RIGHT;
T_Side_D = T_UP;

d = ones(N*NL,M); 

d(1,2:(M-1))=T_Side_A;
d(N*NL,2:(M-1))=T_Side_C;
d((2:N*NL-1),1)=T_Side_D;
d((2:N*NL-1),M)=T_Side_B;
d(1,1)=0.5*(T_Side_A+T_Side_D);
d(1,M)=0.5*(T_Side_A+T_Side_B);
d(N*NL,M)=0.5*(T_Side_C+T_Side_B);
d(N*NL,1)=0.5*(T_Side_C+T_Side_D);

d;

for i=0:NL-1
    d_ex(1:N,1:M)=d(i*N+1:i*N+N,1:M);
    d_vec(i*NM+1:i*NM+NM,1)=reshape(d_ex,NM,[]);
 
end
d_vec;
Td_vec=d_vec';

d = d_vec;


test_1=A_r_G_new_4Com*d;

for i=0:NL-1
    
    test_1_new(i*N+1:i*N+N,1:M)=reshape(test_1(i*NM+1:i*NM+NM,1),N,M);
    
end

test_1_new;






%  for i=0:NL-1
%      
%      if i==0
%          
%        %%--- Positive r direction --> i & i+1
%        
%         A_r_G_new_5Com((i*NM+2*N):N:((i+1)*NM-N),:)=0;
%         A_r_G_L2_ext_p=L_2(1,i+1)*A_r_G(N,(i*N+1:(i+1)*N))-L_2(1,i+2)*A_r_G(1,((i+1)*N+1:(i+2)*N));
% 
%        for j=(i*NM+2*N):N:((i+1)*NM-N)
%            c=1;
%            for k=(i*NM+2*N):N:((i+1)*NM-N)
%                A_r_G_new_5Com(j,k)=A_r_G_L2_ext_p(1,c);
%                c=c+1;
%            end 
%        end
%        
%          
%      elseif i==NL-1
%          
%        %%--- Negative r direction --> i-1 & i
%        
%        A_r_G_new_5Com((i*NM+N+1):N:((i+1)*NM-2*N+1),:)=0;
%        A_r_G_L2_ext_n=L_2(1,i)*A_r_G(N,((i-1)*N+1:(i)*N))-L_2(1,i+1)*A_r_G(1,((i)*N+1:(i+1)*N));
%        
%        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%            c=1;
%            for k=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%                A_r_G_new_5Com(j,k)=A_r_G_L2_ext_n(1,c);
%                c=c+1;
%            end
%        end
%        
%      elseif i~=0 && i~=NL-1
%          
%        %%--- Negative r direction --> i-1 & i
%        
%        A_r_G_new_5Com((i*NM+N+1):N:((i+1)*NM-2*N+1),:)=0;
%        A_r_G_L2_ext_n=L_2(1,i)*A_r_G(N,((i-1)*N+1:(i)*N))-L_2(1,i+1)*A_r_G(1,((i)*N+1:(i+1)*N));
%        
%        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%            c=1;
%            for k=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%                A_r_G_new_5Com(j,k)=A_r_G_L2_ext_n(1,c);
%                c=c+1;
%            end
%        end
%        
%        %%--- Positive r direction --> i & i+1
%        
%         A_r_G_new_5Com((i*NM+2*N):N:((i+1)*NM-N),:)=0;
%         A_r_G_L2_ext_p=L_2(1,i+1)*A_r_G(N,(i*N+1:(i+1)*N))-L_2(1,i+2)*A_r_G(1,((i+1)*N+1:(i+2)*N));
% 
%        for j=(i*NM+2*N):N:((i+1)*NM-N)
%            c=1;
%            for k=(i*NM+2*N):N:((i+1)*NM-N)
%                A_r_G_new_5Com(j,k)=A_r_G_L2_ext_p(1,c);
%                c=c+1;
%            end 
%        end
%        
%      end
%  end








 for i=0:NL-1
     
     if i==0
         
       %%%--- Positive r direction --> i & i+1
       
        A_r_G_new_6Com((i*NM+2*N):N:((i+1)*NM-N),:)=0;
        A_r_G_L2_ext_p=L_2(1,i+1)*A_r_G(N,(i*N+1:(i+1)*N))-L_2(1,i+2)*A_r_G(1,((i+1)*N+1:(i+2)*N));

       for j=(i*NM+2*N):N:((i+1)*NM-N)
           for k=0:N-1
               A_r_G_new_6Com(j,j)=A_r_G_L2_ext_p(1,N-k);
           end 
       end
       
         
     elseif i==NL-1
         
       %%%--- Negative r direction --> i-1 & i
       
       A_r_G_new_6Com((i*NM+N+1):N:((i+1)*NM-2*N+1),:)=0;
       A_r_G_L2_ext_n=L_2(1,i)*A_r_G(N,((i-1)*N+1:(i)*N))-L_2(1,i+1)*A_r_G(1,((i)*N+1:(i+1)*N));
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           for k=0:N-1
               A_r_G_new_6Com(j,j)=A_r_G_L2_ext_n(1,k+1);
           end
       end
       
     elseif i~=0 && i~=NL-1
         
       %%%--- Negative r direction --> i-1 & i
       
       A_r_G_new_6Com((i*NM+N+1):N:((i+1)*NM-2*N+1),:)=0;
       A_r_G_L2_ext_n=L_2(1,i)*A_r_G(N,((i-1)*N+1:(i)*N))-L_2(1,i+1)*A_r_G(1,((i)*N+1:(i+1)*N));
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           for k=0:N-1
               A_r_G_new_6Com(j,j)=A_r_G_L2_ext_n(1,k+1);
           end
       end
       
       %%%--- Positive r direction --> i & i+1
       
        A_r_G_new_6Com((i*NM+2*N):N:((i+1)*NM-N),:)=0;
        A_r_G_L2_ext_p=L_2(1,i+1)*A_r_G(N,(i*N+1:(i+1)*N))-L_2(1,i+2)*A_r_G(1,((i+1)*N+1:(i+2)*N));

       for j=(i*NM+2*N):N:((i+1)*NM-N)
           for k=0:N-1
               A_r_G_new_6Com(j,j)=A_r_G_L2_ext_p(1,N-k);
           end 
       end
       
     end
 end






 
 
%  for i=0:NL-1
%      
%      if i==0
%          
%        %%%--- Positive r direction --> i & i+1
%        
%         A_r_G_new_7Com((i*NM+2*N):N:((i+1)*NM-N),:)=0;
%         A_r_G_L2_ext_p=L_2(1,i+1)*A_r_G(N,(i*N+1:(i+1)*N))-L_2(1,i+2)*A_r_G(1,((i+1)*N+1:(i+2)*N));
%         
%         c=0; 
%        for j=(i*NM+2*N):N:((i+1)*NM-N)
%            c=c+1;
%            A_r_G_new_7Com(j,j)=A_r_G_L2_ext_p(1,c);
%        end 
%        
%          
%      elseif i==NL-1
%          
%        %%%--- Negative r direction --> i-1 & i
%        
%        A_r_G_new_7Com((i*NM+N+1):N:((i+1)*NM-2*N+1),:)=0;
%        A_r_G_L2_ext_n=L_2(1,i)*A_r_G(N,((i-1)*N+1:(i)*N))-L_2(1,i+1)*A_r_G(1,((i)*N+1:(i+1)*N));
%        
%        c=0;
%        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%            c=c+1;
%            A_r_G_new_7Com(j,j)=A_r_G_L2_ext_n(1,c);
%        end
%        
%      elseif i~=0 && i~=NL-1
%          
%        %%%--- Negative r direction --> i-1 & i
%        
%        A_r_G_new_7Com((i*NM+N+1):N:((i+1)*NM-2*N+1),:)=0;
%        A_r_G_L2_ext_n=L_2(1,i)*A_r_G(N,((i-1)*N+1:(i)*N))-L_2(1,i+1)*A_r_G(1,((i)*N+1:(i+1)*N));
%        
%        c=0;
%        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%            c=c+1;
%            A_r_G_new_7Com(j,j)=A_r_G_L2_ext_n(1,c);
%        end
%        
%        %%%--- Positive r direction --> i & i+1
%        
%         A_r_G_new_7Com((i*NM+2*N):N:((i+1)*NM-N),:)=0;
%         A_r_G_L2_ext_p=L_2(1,i+1)*A_r_G(N,(i*N+1:(i+1)*N))-L_2(1,i+2)*A_r_G(1,((i+1)*N+1:(i+2)*N));
%         
%         c=0; 
%        for j=(i*NM+2*N):N:((i+1)*NM-N)
%            c=c+1;
%            A_r_G_new_7Com(j,j)=A_r_G_L2_ext_p(1,c);
%        end 
%        
%      end
%  end







A_r_G_new_7Com = A_r_G_new;


 for i=0:NL-1
     
     if i==0
         
       %%%--- Positive r direction --> i & i+1
       
        A_r_G_new_7Com((i*NM+2*N):N:((i+1)*NM-N),:)=0;
        A_r_G_L2_ext_p=L_2(1,i+1)*A_r_G(N,(i*N+1:(i+1)*N));
        A_r_G_L2_ext_n=-L_2(1,i+2)*A_r_G(1,((i+1)*N+1:(i+2)*N));
        
%        for j=(i*NM+2*N):N:((i+1)*NM-N)
%            for k=0:N-1
%                A_r_G_new_7Com(j,j-k)=A_r_G_L2_ext_p(1,N-k);
%            end 
%            for q=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%                for k=0:N-1
%                    A_r_G_new_7Com(j,q+k)=A_r_G_L2_ext_n(1,k+1);
%                end
%            end 
%        end
       
         
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           for k=0:N-1
               A_r_G_new_7Com(j,j-k)=A_r_G_L2_ext_p(1,N-k);
           end 
       end
       
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           for k=0:N-1
               A_r_G_new_7Com(j,j+k+NM-N+1)=A_r_G_L2_ext_n(1,k+1);
           end 
       end
       
       
       
       
     elseif i==NL-1
         
       %%%--- Negative r direction --> i-1 & i
       
       A_r_G_new_7Com((i*NM+N+1):N:((i+1)*NM-2*N+1),:)=0;
       A_r_G_L2_ext_p=-L_2(1,i)*A_r_G(N,((i-1)*N+1:(i)*N));
       A_r_G_L2_ext_n=L_2(1,i+1)*A_r_G(1,((i)*N+1:(i+1)*N));
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           for k=0:N-1
               A_r_G_new_7Com(j,j-k-NM+N-1)=A_r_G_L2_ext_p(1,N-k);
           end 
       end
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           for k=0:N-1
               A_r_G_new_7Com(j,j+k)=A_r_G_L2_ext_n(1,k+1);
           end 
       end
       
       
       
     elseif i~=0 && i~=NL-1
         
       %%%--- Negative r direction --> i-1 & i
       
       A_r_G_new_7Com((i*NM+N+1):N:((i+1)*NM-2*N+1),:)=0;
       A_r_G_L2_ext_p=-L_2(1,i)*A_r_G(N,((i-1)*N+1:(i)*N));
       A_r_G_L2_ext_n=L_2(1,i+1)*A_r_G(1,((i)*N+1:(i+1)*N));
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           for k=0:N-1
               A_r_G_new_7Com(j,j-k-NM+N-1)=A_r_G_L2_ext_p(1,N-k);
           end 
       end
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           for k=0:N-1
               A_r_G_new_7Com(j,j+k)=A_r_G_L2_ext_n(1,k+1);
           end 
       end
       
       %%%--- Positive r direction --> i & i+1
       
        A_r_G_new_7Com((i*NM+2*N):N:((i+1)*NM-N),:)=0;
        A_r_G_L2_ext_p=L_2(1,i+1)*A_r_G(N,(i*N+1:(i+1)*N));
        A_r_G_L2_ext_n=-L_2(1,i+2)*A_r_G(1,((i+1)*N+1:(i+2)*N));
         
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           for k=0:N-1
               A_r_G_new_7Com(j,j-k)=A_r_G_L2_ext_p(1,N-k);
           end 
       end
       
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           for k=0:N-1
               A_r_G_new_7Com(j,j+k+NM-N+1)=A_r_G_L2_ext_n(1,k+1);
           end 
       end
       
     end
  end



det_A_r_G_new_7Com = det(A_r_G_new_7Com);







% A_r_G_new_8Com


 for i=0:NL-1
     
     if i==0
         
       %%%--- Positive r direction --> i & i+1
       
        A_r_G_new_8Com((i*NM+2*N):N:((i+1)*NM-N),:)=0;
        A_r_G_L2_ext_p=L_2(1,i+1)*A_r_G(N,(i*N+1:(i+1)*N));
        A_r_G_L2_ext_n=-L_2(1,i+2)*A_r_G(1,((i+1)*N+1:(i+2)*N));
         
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           for k=0:N-1
               A_r_G_new_8Com(j,j-k)=A_r_G_L2_ext_p(1,N-k);
           end 
       end
       
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           for k=0:N-1
               A_r_G_new_8Com(j,j+k+NM-N+1)=A_r_G_L2_ext_n(1,k+1);
           end 
       end
       
       
       
     elseif i==NL-1
         
       %%%--- Negative r direction --> i-1 & i
       
       A_r_G_new_8Com((i*NM+N+1):N:((i+1)*NM-2*N+1),:)=0;
       A_r_G_L2_ext_p=-L_2(1,i)*A_r_G(N,((i-1)*N+1:(i)*N));
       A_r_G_L2_ext_n=L_2(1,i+1)*A_r_G(1,((i)*N+1:(i+1)*N));
       
%        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%            for k=0:N-1
%                A_r_G_new_7Com(j,j-k-NM+N-1)=A_r_G_L2_ext_p(1,N-k);
%            end 
%        end
%        
%        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%            for k=0:N-1
%                A_r_G_new_7Com(j,j+k)=A_r_G_L2_ext_n(1,k+1);
%            end 
%        end
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           A_r_G_new_8Com(j,(j-NM+N-1))=1;
       end
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           A_r_G_new_8Com(j,j)=-1; 
       end
       
       
       
     elseif i~=0 && i~=NL-1
         
       %%%--- Negative r direction --> i-1 & i
       
       A_r_G_new_8Com((i*NM+N+1):N:((i+1)*NM-2*N+1),:)=0;
       A_r_G_L2_ext_p=-L_2(1,i)*A_r_G(N,((i-1)*N+1:(i)*N));
       A_r_G_L2_ext_n=L_2(1,i+1)*A_r_G(1,((i)*N+1:(i+1)*N));
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           for k=0:N-1
               A_r_G_new_7Com(j,j-k-NM+N-1)=A_r_G_L2_ext_p(1,N-k);
           end 
       end
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           for k=0:N-1
               A_r_G_new_7Com(j,j+k)=A_r_G_L2_ext_n(1,k+1);
           end 
       end
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           A_r_G_new_8Com(j,(j-NM+N-1))=1;
       end
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           A_r_G_new_8Com(j,j)=-1; 
       end
       
       %%%--- Positive r direction --> i & i+1
       
        A_r_G_new_8Com((i*NM+2*N):N:((i+1)*NM-N),:)=0;
         A_r_G_L2_ext_p=L_2(1,i+1)*A_r_G(N,(i*N+1:(i+1)*N));
        A_r_G_L2_ext_n=-L_2(1,i+2)*A_r_G(1,((i+1)*N+1:(i+2)*N));
         
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           for k=0:N-1
               A_r_G_new_8Com(j,j-k)=A_r_G_L2_ext_p(1,N-k);
           end 
       end
       
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           for k=0:N-1
               A_r_G_new_8Com(j,j+k+NM-N+1)=A_r_G_L2_ext_n(1,k+1);
           end 
       end
       
     end
 end





  
 
 

% A_r_G_new_9Com
A_r_G_new_9Com = A_r_G_new;


 for i=0:NL-1
     
     if i==0
         
       %%%--- Positive r direction --> i & i+1
       
        A_r_G_new_9Com((i*NM+2*N):N:((i+1)*NM-N),:)=0;
        A_r_G_L2_ext_p=L_2(1,i+1)*A_r_G(N,(i*N+1:(i+1)*N));
        A_r_G_L2_ext_n=-L_2(1,i+2)*A_r_G(1,((i+1)*N+1:(i+2)*N));
         
%        for j=(i*NM+2*N):N:((i+1)*NM-N)
%            for k=0:N-1
%                A_r_G_new_9Com(j,j-k)=A_r_G_L2_ext_p(1,N-k);
%            end 
%        end
%        
%        for j=(i*NM+2*N):N:((i+1)*NM-N)
%            for k=0:N-1
%                A_r_G_new_9Com(j,j+k+NM-N+1)=A_r_G_L2_ext_n(1,k+1);
%            end 
%        end
       
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           A_r_G_new_9Com(j,j)=1; 
       end
       
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           A_r_G_new_9Com(j,j+NM-N+1)=-1;
       end
       
       
       
     elseif i==NL-1
         
       %%%--- Negative r direction --> i-1 & i
       
       A_r_G_new_9Com((i*NM+N+1):N:((i+1)*NM-2*N+1),:)=0;
       A_r_G_L2_ext_p=-L_2(1,i)*A_r_G(N,((i-1)*N+1:(i)*N));
       A_r_G_L2_ext_n=L_2(1,i+1)*A_r_G(1,((i)*N+1:(i+1)*N));
       
%        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%            for k=0:N-1
%                A_r_G_new_9Com(j,j-k-NM+N-1)=A_r_G_L2_ext_p(1,N-k);
%            end 
%        end
%        
%        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%            for k=0:N-1
%                A_r_G_new_9Com(j,j+k)=A_r_G_L2_ext_n(1,k+1);
%            end 
%        end
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           A_r_G_new_9Com(j,(j-NM+N-1))=1;
       end
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           A_r_G_new_9Com(j,j)=-1; 
       end
       
       
       
     elseif i~=0 && i~=NL-1
         
       %%%--- Negative r direction --> i-1 & i
       
       A_r_G_new_9Com((i*NM+N+1):N:((i+1)*NM-2*N+1),:)=0;
       A_r_G_L2_ext_p=-L_2(1,i)*A_r_G(N,((i-1)*N+1:(i)*N));
       A_r_G_L2_ext_n=L_2(1,i+1)*A_r_G(1,((i)*N+1:(i+1)*N));
       
%        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%            for k=0:N-1
%                A_r_G_new_9Com(j,j-k-NM+N-1)=A_r_G_L2_ext_p(1,N-k);
%            end 
%        end
%        
%        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%            for k=0:N-1
%                A_r_G_new_9Com(j,j+k)=A_r_G_L2_ext_n(1,k+1);
%            end 
%        end
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           A_r_G_new_9Com(j,(j-NM+N-1))=1;
       end
       
       for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
           A_r_G_new_9Com(j,j)=-1; 
       end
       
       %%%--- Positive r direction --> i & i+1
       
        A_r_G_new_9Com((i*NM+2*N):N:((i+1)*NM-N),:)=0;
        A_r_G_L2_ext_p=L_2(1,i+1)*A_r_G(N,(i*N+1:(i+1)*N));
        A_r_G_L2_ext_n=-L_2(1,i+2)*A_r_G(1,((i+1)*N+1:(i+2)*N));
         
%        for j=(i*NM+2*N):N:((i+1)*NM-N)
%            for k=0:N-1
%                A_r_G_new_9Com(j,j-k)=A_r_G_L2_ext_p(1,N-k);
%            end 
%        end
%        
%        for j=(i*NM+2*N):N:((i+1)*NM-N)
%            for k=0:N-1
%                A_r_G_new_9Com(j,j+k+NM-N+1)=A_r_G_L2_ext_n(1,k+1);
%            end 
%        end
       
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           A_r_G_new_9Com(j,j)=1; 
       end
       
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           A_r_G_new_9Com(j,j+NM-N+1)=-1;
       end
       
       
       
     end
 end


 for i=1:NL-1
     for j=(i*NM+1):N:((i+1)*NM-N+1)
         j;
     end
 end
  
 
 
 % A_r_G_new_10Com
 
 A_r_G_new_10Com = A_r_G_new;
 
 
% Node_number_G_new = A_r_G_new;
%  
% for i=1:NM*NL
%     for j=1:NM*NL
%         if  Node_number_G_new(i,j) ~= 0
%             
%             Node_number_G_new(i,j) = i;
%             
%         end
%     end
% end
% 
% A_r_G_new_10Com = Node_number_G_new;

 for i=0:NL-1
     
     if i==0
         
       %%%--- Positive r direction --> i & i+1
       
        A_r_G_new_10Com((i*NM+2*N):N:((i+1)*NM-N),:)=0;
        A_r_G_L2_ext_p=L_2(1,i+1)*A_r_G(N,(i*N+1:(i+1)*N));
        A_r_G_L2_ext_n=-L_2(1,i+2)*A_r_G(1,((i+1)*N+1:(i+2)*N));
         
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           for k=0:N-1
               A_r_G_new_10Com(j,j-k)=A_r_G_L2_ext_p(1,N-k);
           end 
       end
       
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           for k=0:N-1
               A_r_G_new_10Com(j,j+k+NM-N+1)=A_r_G_L2_ext_n(1,k+1);
           end 
       end
       
%        for j=(i*NM+2*N):N:((i+1)*NM-N)
%            A_r_G_new_10Com(j,j)=1; 
%        end
%        
%        for j=(i*NM+2*N):N:((i+1)*NM-N)
%            A_r_G_new_10Com(j,j+NM-N+1)=-1;
%        end
       
       
       
     elseif i==NL-1
         
       %%%--- Negative r direction --> i-1 & i
       
       
       for j=(i*NM+1):N:((i+1)*NM-N+1)
%            A_r_G_new_10Com(j,:)=A_r_G_new(j,:);
           A_r_G_new_10Com(j,:)=0;
%            A_r_G_new_10Com(:,j)=[];
       end
%        A_r_G_L2_ext_p=-L_2(1,i)*A_r_G(N,((i-1)*N+1:(i)*N));
%        A_r_G_L2_ext_n=L_2(1,i+1)*A_r_G(1,((i)*N+1:(i+1)*N));
%        
% %        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
% %            for k=0:N-1
% %                A_r_G_new_10Com(j,j-k-NM+N-1)=A_r_G_L2_ext_p(1,N-k);
% %            end 
% %        end
% %        
% %        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
% %            for k=0:N-1
% %                A_r_G_new_10Com(j,j+k)=A_r_G_L2_ext_n(1,k+1);
% %            end 
% %        end
%        
%        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%            A_r_G_new_10Com(j,(j-NM+N-1))=1;
%        end
%        
%        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%            A_r_G_new_10Com(j,j)=-1; 
%        end
       
       
       
     elseif i~=0 && i~=NL-1
         
       %%%--- Negative r direction --> i-1 & i
       
       for j=(i*NM+1):N:((i+1)*NM-N+1)
%            A_r_G_new_10Com(j,:)=A_r_G_new(j,:);
           A_r_G_new_10Com(j,:)=0;
%            A_r_G_new_10Com(:,j)=[];
       end
%        A_r_G_L2_ext_p=-L_2(1,i)*A_r_G(N,((i-1)*N+1:(i)*N));
%        A_r_G_L2_ext_n=L_2(1,i+1)*A_r_G(1,((i)*N+1:(i+1)*N));
%        
% %        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
% %            for k=0:N-1
% %                A_r_G_new_10Com(j,j-k-NM+N-1)=A_r_G_L2_ext_p(1,N-k);
% %            end 
% %        end
% %        
% %        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
% %            for k=0:N-1
% %                A_r_G_new_10Com(j,j+k)=A_r_G_L2_ext_n(1,k+1);
% %            end 
% %        end
%        
%        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%            A_r_G_new_10Com(j,(j-NM+N-1))=1;
%        end
%        
%        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%            A_r_G_new_10Com(j,j)=-1; 
%        end
       
       %%%--- Positive r direction --> i & i+1
       
        A_r_G_new_10Com((i*NM+2*N):N:((i+1)*NM-N),:)=0;
        A_r_G_L2_ext_p=L_2(1,i+1)*A_r_G(N,(i*N+1:(i+1)*N));
        A_r_G_L2_ext_n=-L_2(1,i+2)*A_r_G(1,((i+1)*N+1:(i+2)*N));
         
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           for k=0:N-1
               A_r_G_new_10Com(j,j-k)=A_r_G_L2_ext_p(1,N-k);
           end 
       end
       
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           for k=0:N-1
               A_r_G_new_10Com(j,j+k+NM-N+1)=A_r_G_L2_ext_n(1,k+1);
           end 
       end
       
%        for j=(i*NM+2*N):N:((i+1)*NM-N)
%            A_r_G_new_10Com(j,j)=1; 
%        end
%        
%        for j=(i*NM+2*N):N:((i+1)*NM-N)
%            A_r_G_new_10Com(j,j+NM-N+1)=-1;
%        end
       
       
       
     end
  end


 
% for i=1:NL-1
%      for j=(i*NM+1):N:((i+1)*NM-N+1)
%          j
%          if A_r_G_new_10Com(j,:)==0
%              a=j
%              A_r_G_new_10Com(j,:)=[];
%              A_r_G_new_10Com(:,j)=[];
%          end
%      end
%  end

for i=NM*NL:-1:1
    if A_r_G_new_10Com(i,:)==0
       a=i;
%        A_r_G_new_10Com(i,:)=[];
       A_r_G_new_10Com(:,i)=[];
    end
end

for i=NM*NL:-1:1
    if A_r_G_new_10Com(i,:)==0
%        a=i
       A_r_G_new_10Com(i,:)=[];
%        A_r_G_new_10Com(:,i)=[];
    end
end

% for i=1:NM*NL
%     if A_r_G_new_10Com(i,i)==0
% %        a=i
%        A_r_G_new_10Com(i,:)=[];
% %        A_r_G_new_10Cojm(:,i)=[];
%     end
% end




C_T_ext=zeros(2*(NL-1)*(M-2),NM*NL);


 for i=0:NL-1
     
     if i==0
         
       %%%--- Positive r direction --> i & i+1
       
        A_r_G_L2_ext_p=L_2(1,i+1)*A_r_G(N,(i*N+1:(i+1)*N));
        A_r_G_L2_ext_n=-L_2(1,i+2)*A_r_G(1,((i+1)*N+1:(i+2)*N));
       
       for q=1:M-2
           for j=(i*NM+2*N):N:((i+1)*NM-N)
               for k=0:N-1
%                    C_T_ext((2*i)*(M-2)+q,j-k)=C_T(j,j-k)+(GaM)*A_r_G_L2_ext_p(1,N-k);
                   C_T_ext((2*i)*(M-2)+q,j-k)=A_r_G_L2_ext_p(1,N-k);
               end 
           end
       end
       
       for q=1:M-2
           for j=(i*NM+2*N):N:((i+1)*NM-N)
               for k=0:N-1
%                    C_T_ext((2*i)*(M-2)+q,j+k+NM-N+1)=C_T(j,j+k+NM-N+1)+(GaM)*A_r_G_L2_ext_n(1,k+1);
                   C_T_ext((2*i)*(M-2)+q,j+k+NM-N+1)=A_r_G_L2_ext_n(1,k+1);
               end 
           end
       end
       
      
       for q=1:M-2
           for j=(i*NM+2*N):N:((i+1)*NM-N)
%                C_T_ext((2*i)*(M-2)+q,j)=C_T(j,j)+(GaM)*1-0;
               C_T_ext((2*i)*(M-2)+q,j)=C_T(j,j)+1-0; 
           end
       end
       
       for q=1:M-2
           for j=(i*NM+2*N):N:((i+1)*NM-N)
%                C_T_ext((2*i)*(M-2)+q,j+NM-N+1)=C_T(j,j+NM-N+1)-(GaM)*1+0;
               C_T_ext((2*i)*(M-2)+q,j+NM-N+1)=C_T(j,j+NM-N+1)-1+0;
           end
       end
       

     elseif i==NL-1
         
       %%%--- Negative r direction --> i-1 & i
       
       A_r_G_L2_ext_p=-L_2(1,i)*A_r_G(N,((i-1)*N+1:(i)*N));
       A_r_G_L2_ext_n=L_2(1,i+1)*A_r_G(1,((i)*N+1:(i+1)*N));
       
       
       for q=1:M-2
           for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
               for k=0:N-1
%                    C_T_ext((2*i-1)*(M-2)+q,j-k-NM+N-1)=C_T(j,j-k-NM+N-1)+(GaM)*A_r_G_L2_ext_p(1,N-k);
                   C_T_ext((2*i-1)*(M-2)+q,j-k-NM+N-1)=A_r_G_L2_ext_p(1,N-k);
               end 
           end
       end
       
       for q=1:M-2
           for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
               for k=0:N-1
%                    C_T_ext((2*i-1)*(M-2)+q,j+k)=C_T(j,j+k)+(GaM)*A_r_G_L2_ext_n(1,k+1);
                   C_T_ext((2*i-1)*(M-2)+q,j+k)=A_r_G_L2_ext_n(1,k+1);
               end 
           end
       end
       
       
       for q=1:M-2
           for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%                C_T_ext((2*i-1)*(M-2)+q,(j-NM+N-1))=C_T(j,(j-NM+N-1))+(GaM)*1-0;
               C_T_ext((2*i-1)*(M-2)+q,(j-NM+N-1))=C_T(j,(j-NM+N-1))+1-0;
           end
       end
       
       for q=1:M-2
           for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%                C_T_ext((2*i-1)*(M-2)+q,j)=C_T(j,j)-(GaM)*1+0;
               C_T_ext((2*i-1)*(M-2)+q,j)=C_T(j,j)-1+0; 
          end
       end
       
       
       
     elseif i~=0 && i~=NL-1
         
       %%%--- Negative r direction --> i-1 & i
       
       A_r_G_L2_ext_p=-L_2(1,i)*A_r_G(N,((i-1)*N+1:(i)*N));
       A_r_G_L2_ext_n=L_2(1,i+1)*A_r_G(1,((i)*N+1:(i+1)*N));
       
       for q=1:M-2
           for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
               for k=0:N-1
%                    C_T_ext((2*i-1)*(M-2)+q,j-k-NM+N-1)=C_T(j,j-k-NM+N-1)+(GaM)*A_r_G_L2_ext_p(1,N-k);
                   C_T_ext((2*i-1)*(M-2)+q,j-k-NM+N-1)=A_r_G_L2_ext_p(1,N-k);
               end 
           end
       end
       
       for q=1:M-2
           for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
               for k=0:N-1
%                    C_T_ext((2*i-1)*(M-2)+q,j+k)=C_T(j,j+k)+(GaM)*A_r_G_L2_ext_n(1,k+1);
                   C_T_ext((2*i-1)*(M-2)+q,j+k)=A_r_G_L2_ext_n(1,k+1);
               end 
           end
       end
       
       
       for q=1:M-2
           for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%                C_T_ext((2*i-1)*(M-2)+q,(j-NM+N-1))=C_T(j,(j-NM+N-1))+(GaM)*1-0;
               C_T_ext((2*i-1)*(M-2)+q,(j-NM+N-1))=C_T(j,(j-NM+N-1))+1-0;
           end
       end
       
       for q=1:M-2
           for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%                C_T_ext((2*i-1)*(M-2)+q,j)=C_T(j,j)-(GaM)*1+0;
               C_T_ext((2*i-1)*(M-2)+q,j)=C_T(j,j)-1+0; 
          end
       end
       
       %%%--- Positive r direction --> i & i+1
       
        A_r_G_L2_ext_p=L_2(1,i+1)*A_r_G(N,(i*N+1:(i+1)*N));
        A_r_G_L2_ext_n=-L_2(1,i+2)*A_r_G(1,((i+1)*N+1:(i+2)*N));
         
       for q=1:M-2
           for j=(i*NM+2*N):N:((i+1)*NM-N)
               for k=0:N-1
%                    C_T_ext((2*i)*(M-2)+q,j-k)=C_T(j,j-k)+(GaM)*A_r_G_L2_ext_p(1,N-k);
                   C_T_ext((2*i)*(M-2)+q,j-k)=A_r_G_L2_ext_p(1,N-k);
               end 
           end
       end
       
       for q=1:M-2
           for j=(i*NM+2*N):N:((i+1)*NM-N)
               for k=0:N-1
%                    C_T_ext((2*i)*(M-2)+q,j+k+NM-N+1)=C_T(j,j+k+NM-N+1)+(GaM)*A_r_G_L2_ext_n(1,k+1);
                   C_T_ext((2*i)*(M-2)+q,j+k+NM-N+1)=A_r_G_L2_ext_n(1,k+1);
               end 
           end
       end
       
      
       for q=1:M-2
           for j=(i*NM+2*N):N:((i+1)*NM-N)
%                C_T_ext((2*i)*(M-2)+q,j)=C_T_ext(j,j)+(GaM)*1-0;
               C_T_ext((2*i)*(M-2)+q,j)=C_T(j,j)+1-0; 
           end
       end
       
       for q=1:M-2
           for j=(i*NM+2*N):N:((i+1)*NM-N)
%                C_T_ext((2*i)*(M-2)+q,j+NM-N+1)=C_T_ext(j,j+NM-N+1)-(GaM)*1+0;
               C_T_ext((2*i)*(M-2)+q,j+NM-N+1)=C_T(j,j+NM-N+1)-1+0;
           end
       end
       
       
       
       
     end
 end

  




d_vec;



 for i=0:NL-1
     
     if i==0
         
       %%%--- Positive r direction --> i & i+1
       
%         d_vec((i*NM+2*N):N:((i+1)*NM-N),:)=0;
%         A_r_G_L2_ext_p=L_2(1,i+1)*A_r_G(N,(i*N+1:(i+1)*N));
%         A_r_G_L2_ext_n=-L_2(1,i+2)*A_r_G(1,((i+1)*N+1:(i+2)*N));
         
%        for j=(i*NM+2*N):N:((i+1)*NM-N)
%            for k=0:N-1
%                d_vec(j,j-k)=A_r_G_L2_ext_p(1,N-k);
%            end 
%        end
%        
%        for j=(i*NM+2*N):N:((i+1)*NM-N)
%            for k=0:N-1
%                d_vec(j,j+k+NM-N+1)=A_r_G_L2_ext_n(1,k+1);
%            end 
%        end
       
%        for j=(i*NM+2*N):N:((i+1)*NM-N)
%            d_vec(j,j)=1; 
%        end
%        
%        for j=(i*NM+2*N):N:((i+1)*NM-N)
%            d_vec(j,j+NM-N+1)=-1;
%        end
       
       
       
     elseif i==NL-1
         
       %%%--- Negative r direction --> i-1 & i
       
       d_vec((i*NM+1):N:((i+1)*NM-N+1),:) = -1;
%        A_r_G_L2_ext_p=-L_2(1,i)*A_r_G(N,((i-1)*N+1:(i)*N));
%        A_r_G_L2_ext_n=L_2(1,i+1)*A_r_G(1,((i)*N+1:(i+1)*N));
       
%        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%            for k=0:N-1
%                d_vec(j,j-k-NM+N-1)=A_r_G_L2_ext_p(1,N-k);
%            end 
%        end
%        
%        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%            for k=0:N-1
%                d_vec(j,j+k)=A_r_G_L2_ext_n(1,k+1);
%            end 
%        end
       
%        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%            d_vec(j,(j-NM+N-1))=1;
%        end
%        
%        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%            d_vec(j,j)=-1; 
%        end
       
       
       
     elseif i~=0 && i~=NL-1
         
       %%%--- Negative r direction --> i-1 & i
       
       d_vec((i*NM+1):N:((i+1)*NM-N+1),:) = -1;
%        A_r_G_L2_ext_p=-L_2(1,i)*A_r_G(N,((i-1)*N+1:(i)*N));
%        A_r_G_L2_ext_n=L_2(1,i+1)*A_r_G(1,((i)*N+1:(i+1)*N));
       
%        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%            for k=0:N-1
%                d_vec(j,j-k-NM+N-1)=A_r_G_L2_ext_p(1,N-k);
%            end 
%        end
%        
%        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%            for k=0:N-1
%                d_vec(j,j+k)=A_r_G_L2_ext_n(1,k+1);
%            end 
%        end
       
%        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%            d_vec(j,(j-NM+N-1))=1;
%        end
%        
%        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%            d_vec(j,j)=-1; 
%        end
       
       %%%--- Positive r direction --> i & i+1
       
%         d_vec((i*NM+2*N):N:((i+1)*NM-N),:)=0;
%         A_r_G_L2_ext_p=L_2(1,i+1)*A_r_G(N,(i*N+1:(i+1)*N));
%         A_r_G_L2_ext_n=-L_2(1,i+2)*A_r_G(1,((i+1)*N+1:(i+2)*N));
         
%        for j=(i*NM+2*N):N:((i+1)*NM-N)
%            for k=0:N-1
%                d_vec(j,j-k)=A_r_G_L2_ext_p(1,N-k);
%            end 
%        end
%        
%        for j=(i*NM+2*N):N:((i+1)*NM-N)
%            for k=0:N-1
%                d_vec(j,j+k+NM-N+1)=A_r_G_L2_ext_n(1,k+1);
%            end 
%        end
       
%        for j=(i*NM+2*N):N:((i+1)*NM-N)
%            d_vec(j,j)=1; 
%        end
%        
%        for j=(i*NM+2*N):N:((i+1)*NM-N)
%            d_vec(j,j+NM-N+1)=-1;
%        end
       
       
       
     end
 end


for i=NM*NL:-1:1
    if d_vec(i,1)==-1
       a=i;
       d_vec(i,:)=[];
    end
end

% for i=NM*NL:-1:1
%     if d_vec(i,:)==-1
% %        a=i
%        d_vec(i,:)=[];
% %        d_vec(:,i)=[];
%     end
% end




Renumbered_Calc_Global_node_numbering_vec = zeros(NM*NL,1);

for i=1:NM*NL
    Renumbered_Calc_Global_node_numbering_vec(i,1) = i;
end


 for i=0:NL-1
     
     if i==0
         
       %%%--- Positive r direction --> i & i+1
       
%         Renumbered_Calc_Global_node_numbering_vec((i*NM+2*N):N:((i+1)*NM-N),:)=0;
       
%        for j=(i*NM+2*N):N:((i+1)*NM-N)
%            Renumbered_Calc_Global_node_numbering_vec(j,j)=1; 
%        end
%        
%        for j=(i*NM+2*N):N:((i+1)*NM-N)
%            Renumbered_Calc_Global_node_numbering_vec(j,j+NM-N+1)=-1;
%        end
       
       
       
     elseif i==NL-1
         
       %%%--- Negative r direction --> i-1 & i
       
       Renumbered_Calc_Global_node_numbering_vec((i*NM+1):N:((i+1)*NM-N+1),:) = -1;
       
%        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%            Renumbered_Calc_Global_node_numbering_vec(j,(j-NM+N-1))=1;
%        end
%        
%        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%            Renumbered_Calc_Global_node_numbering_vec(j,j)=-1; 
%        end
       
       
       
     elseif i~=0 && i~=NL-1
         
       %%%--- Negative r direction --> i-1 & i
       
       Renumbered_Calc_Global_node_numbering_vec((i*NM+1):N:((i+1)*NM-N+1),:) = -1;

%        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%            Renumbered_Calc_Global_node_numbering_vec(j,(j-NM+N-1))=1;
%        end
%        
%        for j=(i*NM+N+1):N:((i+1)*NM-2*N+1)
%            Renumbered_Calc_Global_node_numbering_vec(j,j)=-1; 
%        end
       
       %%%--- Positive r direction --> i & i+1
       
%         Renumbered_Calc_Global_node_numbering_vec((i*NM+2*N):N:((i+1)*NM-N),:)=0;
       
%        for j=(i*NM+2*N):N:((i+1)*NM-N)
%            Renumbered_Calc_Global_node_numbering_vec(j,j)=1; 
%        end
%        
%        for j=(i*NM+2*N):N:((i+1)*NM-N)
%            Renumbered_Calc_Global_node_numbering_vec(j,j+NM-N+1)=-1;
%        end
       
       
       
     end
 end


%  for i=NM*NL:-1:1
%     if Renumbered_Calc_Global_node_numbering_vec(i,1)==-1
%        a=i;
%        Renumbered_Calc_Global_node_numbering_vec(i,:)=[];
%     end
%  end
 
 for i=1:NM*NL
    Renumbered_Calc_Global_node_numbering_vec(i,1) = i;
end
 
for i=0:NL-1
    if i==0 
    Renumbered_Calc_Global_node_numbering(i*N+1:i*N+N,1:M)=reshape(Renumbered_Calc_Global_node_numbering_vec(i*NM+1:i*NM+NM,1),N,M);
    
%     elseif i==1
%     Renumbered_Calc_Global_node_numbering(i*N+1:i*N+N-i,1:M)=reshape(Renumbered_Calc_Global_node_numbering_vec(i*NM+1:i*NM+NM-i*M,1),N-1,M);    
        
    elseif i~=0 %&& i~=1
    Renumbered_Calc_Global_node_numbering(i*N+2-i:i*N+N-i,1:M)=reshape(Renumbered_Calc_Global_node_numbering_vec(i*NM+1-(i-1)*M:i*NM+NM-i*M,1),N-1,M);    
        
    end
        
end
 
 

% for i=0:NL-1
%     Renumbered_Calc_Global_node_numbering(i*N+1:i*N+N,1:M)=reshape(Renumbered_Calc_Global_node_numbering_vec(i*NM+1:i*NM+NM,1),N,M);
% end
% 
% for i=1:NL-1
%      j=0:M-1;
%     Renumbered_Calc_Global_node_numbering(i*N+1,:)=-1-j-(i-1)*M;
% end




Renumbered_Calc_Global_node_numbering;








%%



  
n=N;
m=M;

MN= zeros(m,n);
k = 0;
for i=1:n
    MN(:,i)=MN(:,i)+i;
end
for j=1:m
    MN(j,:)=MN(j,:)+k;
    k = k+n;
end

MN;
MN_Trans = MN';

e=NL;

for i=0:(e-1)
    NM_new((i*n+1):(i*n+n),:) = MN_Trans(1:n,:)+i*n*m;
    NM_new1((i*n+1):(i*n+n),:) = MN_Trans(1:n,:);
end
NM_new;
NM_new1;

Calc_Global_node_numbering = NM_new
Real_Global_node_numbering = NM_new'

Calc_Local_node_numbering = NM_new1;
Real_Local_node_numbering = NM_new1';



%%


Node_number_G_new = A_r_G_new;
 
for i=1:NM*NL
    for j=1:NM*NL
        if  Node_number_G_new(i,j) ~= 0
            
            Node_number_G_new(i,j) = i;
            
        end
    end
end


Node_number_G_new_T = Node_number_G_new';






