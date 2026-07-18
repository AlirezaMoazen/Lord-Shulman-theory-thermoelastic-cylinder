


% Global & Local Weight functions



%%
clc,clear;
N=3;
M=5;
NM=N*M;
NL=3;
R_i=25;
Lt=20;
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

 
 
  
%% 
 

A_z=zeros(M);
B_z=zeros(M);
A_z_new = zeros(NM);
B_z_new = zeros(NM);
A_z_G_new=zeros(NM*NL);
B_z_G_new=zeros(NM*NL);
z=zeros(1,M);

 
      for ii=1:M
        z(ii)=0.5*(1-cos((ii-1)*pi/(M-1))); %z1(i,1)=z(i); 
      end
%        z=z-0.5;
      for ii=1:M
         for jj=1:M
              qi_z=1;qj_z=1;
            for kk=1:M 
               if kk~=ii  
                  qi_z=(z(ii)-z(kk))*qi_z;
               end
               if kk~=jj  
                  qj_z=(z(jj)-z(kk))*qj_z;
               end   
            end
            if ii~=jj 
               A_z(ii,jj)=qi_z/((z(ii)-z(jj))*qj_z);
            end   
         end  
         for kk=1:M  
             if kk~=ii
                A_z(ii,ii)=A_z(ii,ii)-A_z(ii,kk);
             end
         end   
      end
      A_z;
      
A_z_T=A_z';
for i=0:(M-1)
    for j=0:(N-1)
         A_z_new((j+1):N:(j+1+(M-1)*N),(i*N+j+1)) = A_z_T(1:M,(i+1));
    end
end
A_z_new = A_z_new';

for i=0:NL-1
    A_z_G(:,(i*M+1):(i*M+M))=A_z(:,:); 
    A_z_G_new((i*NM+1):(i*NM+NM),(i*NM+1):(i*NM+NM)) = A_z_new(1:NM,1:NM);

end


 

      for ii=1:M
         for jj=1:M
            if ii~=jj
               B_z(ii,jj)=2*(A_z(ii,ii)*A_z(ii,jj)-(A_z(ii,jj)/(z(ii)-z(jj))));
            end   
         end      
         for kk=1:M
            if ii~=kk
               B_z(ii,ii)=B_z(ii,ii)-B_z(ii,kk);
            end   
         end    
      end
      B_z;
      
B_z_T=B_z';
for i=0:(M-1)
    for j=0:(N-1)
         B_z_new((j+1):N:(j+1+(M-1)*N),(i*N+j+1)) = B_z_T(1:M,(i+1));
    end
end
B_z_new = B_z_new';

for i=0:NL-1
    B_z_G(:,(i*M+1):(i*M+M))=B_z(:,:); 
    B_z_G_new((i*NM+1):(i*NM+NM),(i*NM+1):(i*NM+NM)) = B_z_new(1:NM,1:NM);

 end








%%

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



e=i+1;
if e==1
    
end




 A_r_G(:,(i*N+1):(i*N+N))=A_r(:,:);
 
 A_r_G_new((i*NM+1):(i*NM+NM),(i*NM+1):(i*NM+NM)) = A_r_new(1:NM,1:NM);

 
 
 end
 
    
 
 
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
 


















