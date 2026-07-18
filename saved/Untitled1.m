



%%




 A_r_i=zeros(N);
 A_r_o=zeros(N);
 B_r_i=zeros(N);
 B_r_o=zeros(N);
 r_i=zeros(1,N);
 r_o=zeros(1,N);
 A_r_G=zeros(N,N*NL);
 B_r_G=zeros(N,N*NL);
 
 
 for i=0:NL-1
%         r(1:N)=r_G((i*N+1):(i*N+N)); 
        r_i(1:N)=r_G_bar((i*N+1):(i*N+N)); 
        r_o(1:N)=r_G_bar(((i+1)*N+1):((i+1)*N+N)); 
 
 r_i;
 r_o;
 for ii=1:N
    for jj=1:N
         qi_r=1;qj_r=1;
       for kk=1:N 
          if kk~=ii  
              qi_r=(r_i(ii)-r_i(kk))*qi_r;
          end
          if kk~=jj  
              qj_r=(r_i(jj)-r_i(kk))*qj_r;
          end   
       end
       if ii~=jj 
           A_r_i(ii,jj)=qi_r/((r_i(ii)-r_i(jj))*qj_r);
       end   
    end  
    for kk=1:N  
       if kk~=ii
           A_r_i(ii,ii)=A_r_i(ii,ii)-A_r_i(ii,kk);
       end
    end
 end
 A_r_i;
 
 
 for ii=1:N
    for jj=1:N
         qi_r=1;qj_r=1;
       for kk=1:N 
          if kk~=ii  
              qi_r=(r_o(ii)-r_o(kk))*qi_r;
          end
          if kk~=jj  
              qj_r=(r_o(jj)-r_o(kk))*qj_r;
          end   
       end
       if ii~=jj 
           A_r_o(ii,jj)=qi_r/((r_o(ii)-r_o(jj))*qj_r);
       end   
    end  
    for kk=1:N  
       if kk~=ii
           A_r_o(ii,ii)=A_r_o(ii,ii)-A_r_o(ii,kk);
       end
    end
 end
 A_r_o;
 
 
 
 A_r_G(:,(i*N+1):(i*N+N))=A_r_i(:,:);
 
 end
 
 
 
 
 for i=0:NL-1        
        A_r_i(:,:)=A_r_G(:,(i*N+1):(i*N+N)); 
        A_r_o(:,:)=A_r_G(:,((i+1)*N+1):((i+1)*N+N));
 
 A_r_i;
 A_r_o;
 for ii=1:N
    for jj=1:N
       if ii~=jj
           B_r_i(ii,jj)=2*(A_r_i(ii,ii)*A_r_i(ii,jj)-(A_r_i(ii,jj)/(r_i(ii)-r_i(jj))));
       end   
    end      
    for kk=1:N
       if ii~=kk
           B_r_i(ii,ii)=B_r_i(ii,ii)-B_r_i(ii,kk);
       end   
    end    
 end
 B_r_i;
 
 
 for ii=1:N
    for jj=1:N
       if ii~=jj
           B_r_o(ii,jj)=2*(A_r_o(ii,ii)*A_r_o(ii,jj)-(A_r_o(ii,jj)/(r_i(ii)-r_i(jj))));
       end   
    end      
    for kk=1:N
       if ii~=kk
           B_r_o(ii,ii)=B_r_o(ii,ii)-B_r_o(ii,kk);
       end   
    end    
 end
 B_r_o;
 

B_r_G(:,(i*N+1):(i*N+N))=B_r_i(:,:);

 end


%%





%%


 for i=0:NL-1
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
 
 
 L_1(:,:) = L_1_G(:,(i*N+1):(i*N+N));
 
 for j=1:N
     A_r_L1(j,:) = L_1(1,j)*A_r(j,:);         
 end
 
 
 for k=0:(M-1)
     A_r_new_L1((k*N+1):(k*N+N),(k*N+1):(k*N+N)) = A_r_L1(1:N,1:N);
 end
 A_r_new_L1;


 A_r_G(:,(i*N+1):(i*N+N))=A_r(:,:);
 
 A_r_G_new_L1((i*NM+1):(i*NM+NM),(i*NM+1):(i*NM+NM)) = A_r_new_L1(1:NM,1:NM);

 
 
 end
 
 C_T_1 = A_r_new_L1;
 
 for i=0:NL-1
     
     C_T_2((i*NM+1):(i*NM+NM),:) = L_2(1,(i+1))*B_r_G_new((i*NM+1):(i*NM+NM),:);
     C_T_3((i*NM+1):(i*NM+NM),:) = L_3(1,(i+1))*A_z_G_new((i*NM+1):(i*NM+NM),:);
     C_T_4((i*NM+1):(i*NM+NM),:) = L_2(1,(i+1))*B_z_G_new((i*NM+1):(i*NM+NM),:);


 end
 
 
C_T = C_T_1+C_T_2+C_T_3+C_T_4; 
 

 
 
%%
 
 
 
 %%% boundry
 
 for i=0:NL-1
     
     if i==0
         
       %%%--- Negative z direction
       
       C_T(1:N,:)=0;
       for j=1:N
           C_T(j,j)=1;
       end
       
       %%%--- Positive z direction 
       
       C_T((NM-N):NM,:)=0;
       for j=(NM-N):NM
           C_T(j,j)=1;
       end
       
       %%%--- Negative r direction
       
       for j=1:(M-2)
           C_T((j*N+1),:)=0;
       end
       for j=1:(M-2)
           C_T((j*N+1),(j*N+1))=1;
       end
       
         
     elseif i==NL-1
         
       %%%--- Negative z direction
       
       C_T(1+i*NM:i*NM+N,:)=0;
       C_T(1+i*NM:i*NM+N,1+i*NM:i*NM+N)=1;
%        for j=1:N
%            C_T(j,j)=1;
%        end
       
       %%%--- Positive z direction 
       
       C_T(((i+1)*NM-N):(i+1)*NM,:)=0;
       C_T(((i+1)*NM-N):(i+1)*NM,((i+1)*NM-N):(i+1)*NM)=1;
%        for j=(NM-N):NM
%            C_T(j,j)=1;
%        end
       
       %%%--- Positive r direction 
       
       for j=2:(M-1)
           C_T((j*N+i*NM),:)=0;
       end
       for j=2:(M-1)
           C_T((j*N+i*NM),(j*N+i*NM))=1;
       end
       
       
       
     elseif i~=0 && i~=NL-1
         
       %%%--- Negative z direction
       
       C_T(1+i*NM:i*NM+N,:)=0;
       C_T(1+i*NM:i*NM+N,1+i*NM:i*NM+N)=1;
       
       %%%--- Positive z direction 
       
       C_T(((i+1)*NM-N):(i+1)*NM,:)=0;
       C_T(((i+1)*NM-N):(i+1)*NM,((i+1)*NM-N):(i+1)*NM)=1;
       
       
     end
 end
 
 
 
 
 
 
 
 
 %%%compati
 
 
  for i=0:NL-1
     
     if i==0
         
       %%%--- Positive r direction 
       
       
         
     elseif i==NL-1
         
       %%%--- Negative r direction
       
       
       
     elseif i~=0 && i~=NL-1
         
       %%%--- Negative r direction
       
       
       %%%--- Positive r direction 
       
     end
 end
 
 
 
 
 
 
 
 

