
clc,clear;
% function [T,N,M] = Displacements(r,z,t)


%% Number of nodes
  N=9;  %% r direction
  M=11;  %% z direction
  NM = N*M;
  
%% Legend

%%% e : Layer number

%%% NL : Number of layers

%%% h : Thickness of cylinder(R_o-R_i)

%%% Lt : Layer thickness

%%% R_i : Internal radius

%%% R_o : External radius

%%%


%%% Material properties:


%%% nu : Poisson's ratio

%%% Ym : young's modules

%%% ro : Density

%%% al : Thermal expansion coefficient

%%% Sc : Specific heat capacity

%%% ka : Thermal conductivity

%%% Ch : Convection heat transfer coefficient

%%% C_ij : Elastic coefficients

%%% gama

%%% e_i

%%% e_im

%%

Ym_m=3*10^9;
Ym_GPL=1010*10^9;

nu_m=0.34;
nu_GPL=0.186;

ro_m=1200;
ro_GPL=1062.5;
ro_Air=1.1774;

Sc_m=1110;
Sc_GPL=644;
Sc_Air=1.0057;

al_m=60*10^(-6);
al_GPL=5*10^(-6);

ka_m=0.246;
ka_GPL=3000;
ka_Air=0.02624;

a_GPL=2.5*10^(-6);
b_GPL=1.5*10^(-6);
t_GPL=1.5*10^(-9);

gama=1/2;

Ch=10;

%%


e=0.7404;


%%

r=zeros(1,N);
for i=1:N
        r(i)=0.5*(1-cos((i-1)*pi/(N-1))); %r1(i,1)=r(i); 
 end
 r;

%%

j=1;
 W_GPL=0.040;



V_GPL=W_GPL/(W_GPL+((ro_GPL/ro_m)*(1-W_GPL)));

ks_L=2*(a_GPL/t_GPL);
ks_W=2*(b_GPL/t_GPL);
et_L=((Ym_GPL/Ym_m)-1)/((Ym_GPL/Ym_m)+ks_L);
et_W=((Ym_GPL/Ym_m)-1)/((Ym_GPL/Ym_m)+ks_W);
Ym_L=((1+ks_L*et_L*V_GPL)/(1-et_L*V_GPL))*Ym_m;
Ym_T=((1+ks_W*et_W*V_GPL)/(1-et_W*V_GPL))*Ym_m;

Ym_s = 3/8*Ym_L+5/8*Ym_T;


V_m=1-V_GPL;

nu_s=V_GPL*nu_GPL+V_m*nu_m;

ro_s=V_GPL*ro_GPL+V_m*ro_m;

Sc_s=V_GPL*Sc_GPL+V_m*Sc_m;

al_s=V_GPL*al_GPL+V_m*al_m;

P=a_GPL/t_GPL;
H_P=((log(P+sqrt(P^2-1))*P)/(sqrt((P^2-1)^3)))-(1/(P^2-1));

ka_s=(((2/3)*(V_GPL-(1/P))^(gama))/(H_P+(1/((ka_GPL/ka_m)-1))))*ka_m+ka_m;

e_mass = sqrt(e);

Ym(1,j) = Ym_s*e;

nu(1,j) = nu_s;

ro(1,j) = ro_s*e_mass;

al(1,j) = al_s;

V_s=e_mass;
V_Air=1-V_s;

Sc(1,j) = V_s*Sc_s+V_Air*Sc_Air;

ka(1,j) =((ka_Air+2*ka_s+2*V_Air*(ka_Air-ka_s))/(ka_Air+2*ka_s-V_Air*(ka_Air-ka_s)))*ka_s;

Ch(1,j)=10;

d_r_al=0;



%%
Ym_s ;
nu_s ;
ro_s ;
al_s ;
Sc_s ;
ka_s ;
Ch ;

%% 

C_11=((1-nu)*Ym)/((1+nu)*(1-(2*nu)));
d_r_C_11=0;
C_22=((1-nu)*Ym)/((1+nu)*(1-(2*nu)));
% d_r_C_22=0;
% C_33=((1-nu)*Ym)/((1+nu)*(1-(2*nu)));
% d_r_C_33=0;

C_12=(nu*Ym)/((1+nu)*(1-(2*nu)));
d_r_C_12=0;
C_23=(nu*Ym)/((1+nu)*(1-(2*nu)));
C_13=(nu*Ym)/((1+nu)*(1-(2*nu)));
d_r_C_13=0;

C_55=(Ym)/(2*(1+nu));
d_r_C_55=0;

%%


L_1 = zeros(1,N);
L_2 = zeros(1,N);
L_3 = zeros(1,N);
L_4 = zeros(1,N);

J_1 = zeros(1,N);
J_2 = zeros(1,N);
J_3 = zeros(1,N);
J_4 = zeros(1,N);
J_5 = zeros(1,N);
J_6 = zeros(1,N);
J_7 = zeros(1,N);
J_7_p = zeros(1,N);
J_8 = zeros(1,N);
J_8_p = zeros(1,N);
J_9 = zeros(1,N);
J_10 = zeros(1,N);
J_11 = zeros(1,N);
J_12 = zeros(1,N);
J_13 = zeros(1,N);

j=0;
for i=1:N
    
    j=j+1;
    
    if i==1
     r(i)=0.5*(1-cos((i-1)*pi/(N-1)))+1e-10; %r1(i,1)=r(i); 
%      r(i)=0.5*(1-cos((i-1)*pi/(N-1)))-0.5; %r1(i,1)=r(i); 
%      r(i)=0.5*(1-cos((i-1)*pi/(N-1)))+eps; %r1(i,1)=r(i);
     
L_1(1,j) = (ka)/r(1,j);
L_2(1,j) = ka;
L_3(1,j) = 0;
L_4(1,j) = ro*Sc;

J_1(1,j) = C_11;
J_2(1,j) = d_r_C_11+(C_11/r(1,j));
J_3(1,j) = C_55;
J_4(1,j) = (d_r_C_12-(C_22/r(1,j)))/r(1,j);
J_5(1,j) = d_r_C_13+((C_13-C_23)/r(1,j));
J_6(1,j) = C_55+C_13;
J_7(1,j) = (d_r_C_11+d_r_C_12+d_r_C_13)*al;
J_7_p(1,j) = (d_r_C_11+d_r_C_12+d_r_C_13)*al + (C_11+C_12+C_13)*d_r_al;
J_8(1,j) = C_11+C_12+C_13;
J_8_p(1,j) = (C_11+C_12+C_13)*al;
J_9(1,j) = ro;
J_10(1,j) = C_12;
J_11(1,j) = d_r_C_55+(C_55/r(1,j));
J_12(1,j) = d_r_C_55+((C_23-C_55)/r(1,j));
J_13(1,j) = C_23/r(1,j);

    else 
       r(i)=0.5*(1-cos((i-1)*pi/(N-1))); %r1(i,1)=r(i);  
       
    
L_1(1,j) = (ka)/r(1,j);
L_2(1,j) = ka;
L_3(1,j) = 0;
L_4(1,j) = ro*Sc;

J_1(1,j) = C_11;
J_2(1,j) = d_r_C_11+(C_11/r(1,j));
J_3(1,j) = C_55;
J_4(1,j) = (d_r_C_12-(C_22/r(1,j)))/r(1,j);
J_5(1,j) = d_r_C_13+((C_13-C_23)/r(1,j));
J_6(1,j) = C_55+C_13;
J_7(1,j) = (d_r_C_11+d_r_C_12+d_r_C_13)*al;
J_7_p(1,j) = (d_r_C_11+d_r_C_12+d_r_C_13)*al + (C_11+C_12+C_13)*d_r_al;
J_8(1,j) = C_11+C_12+C_13;
J_8_p(1,j) = (C_11+C_12+C_13)*al;
J_9(1,j) = ro;
J_10(1,j) = C_12;
J_11(1,j) = d_r_C_55+(C_55/r(1,j));
J_12(1,j) = d_r_C_55+((C_23-C_55)/r(1,j));
J_13(1,j) = C_23/r(1,j);

   end
end





% r(i)=0.5*(1-cos((i-1)*pi/(N-1)))-0.5;
% j=0;
% for i=1:N
%     
%     j=j+1;
%     
%     if r(i)==0
%      r(i)=0.5*(1-cos((i-1)*pi/(N-1)))+1e-10; %r1(i,1)=r(i); 
% %      r(i)=0.5*(1-cos((i-1)*pi/(N-1)))+eps; %r1(i,1)=r(i);
%      
% L_1(1,j) = (ka*1^(-12))/r(1,j);
% L_2(1,j) = ka;
% L_3(1,j) = 0;
% L_4(1,j) = ro*Sc;
% 
% J_1(1,j) = C_11;
% J_2(1,j) = d_r_C_11+(C_11/r(1,j));
% J_3(1,j) = C_55;
% J_4(1,j) = (d_r_C_12-(C_22/r(1,j)))/r(1,j);
% J_5(1,j) = d_r_C_13+((C_13-C_23)/r(1,j));
% J_6(1,j) = C_55+C_13;
% J_7(1,j) = (d_r_C_11+d_r_C_12+d_r_C_13)*al;
% J_7_p(1,j) = (d_r_C_11+d_r_C_12+d_r_C_13)*al + (C_11+C_12+C_13)*d_r_al;
% J_8(1,j) = C_11+C_12+C_13;
% J_8_p(1,j) = (C_11+C_12+C_13)*al;
% J_9(1,j) = ro;
% J_10(1,j) = C_12;
% J_11(1,j) = d_r_C_55+(C_55/r(1,j));
% J_12(1,j) = d_r_C_55+((C_23-C_55)/r(1,j));
% J_13(1,j) = C_23/r(1,j);
% 
%     else 
%        r(i)=0.5*(1-cos((i-1)*pi/(N-1)))-0.5; %r1(i,1)=r(i);  
%        
%     
% L_1(1,j) = (ka*1^(-12))/r(1,j);
% L_2(1,j) = ka;
% L_3(1,j) = 0;
% L_4(1,j) = ro*Sc;
% 
% J_1(1,j) = C_11;
% J_2(1,j) = d_r_C_11+(C_11/r(1,j));
% J_3(1,j) = C_55;
% J_4(1,j) = (d_r_C_12-(C_22/r(1,j)))/r(1,j);
% J_5(1,j) = d_r_C_13+((C_13-C_23)/r(1,j));
% J_6(1,j) = C_55+C_13;
% J_7(1,j) = (d_r_C_11+d_r_C_12+d_r_C_13)*al;
% J_7_p(1,j) = (d_r_C_11+d_r_C_12+d_r_C_13)*al + (C_11+C_12+C_13)*d_r_al;
% J_8(1,j) = C_11+C_12+C_13;
% J_8_p(1,j) = (C_11+C_12+C_13)*al;
% J_9(1,j) = ro;
% J_10(1,j) = C_12;
% J_11(1,j) = d_r_C_55+(C_55/r(1,j));
% J_12(1,j) = d_r_C_55+((C_23-C_55)/r(1,j));
% J_13(1,j) = C_23/r(1,j);
% 
%    end
% end





%% Weight functions
 
 A_r=zeros(N);
 B_r=zeros(N);
 r=zeros(1,N);
 
 for i=1:N
        r(i)=0.5*(1-cos((i-1)*pi/(N-1)))-0.5; %r1(i,1)=r(i); 
 end
 r;
 for i=1:N
    for j=1:N
         qi_r=1;qj_r=1;
       for k=1:N 
          if k~=i  
              qi_r=(r(i)-r(k))*qi_r;
          end
          if k~=j  
              qj_r=(r(j)-r(k))*qj_r;
          end   
       end
       if i~=j 
           A_r(i,j)=qi_r/((r(i)-r(j))*qj_r);
       end   
    end  
    for k=1:N  
       if k~=i
           A_r(i,i)=A_r(i,i)-A_r(i,k);
       end
    end
 end
 A_r;
 for i=1:N
    for j=1:N
         B_r(i,j)=0;
    end  
 end      
 for i=1:N
    for j=1:N
       if i~=j
           B_r(i,j)=2*(A_r(i,i)*A_r(i,j)-(A_r(i,j)/(r(i)-r(j))));
       end   
    end      
    for k=1:N
       if i~=k
           B_r(i,i)=B_r(i,i)-B_r(i,k);
       end   
    end    
 end
 B_r;
       

   
   
   
A_z=zeros(M);
B_z=zeros(M);
z=zeros(1,M);
 
      for i=1:M
        z(i)=0.5*(1-cos((i-1)*pi/(M-1))); %z1(i,1)=z(i); 
      end
       z;
      for i=1:M
         for j=1:M
              qi_z=1;qj_z=1;
            for k=1:M 
               if k~=i  
                  qi_z=(z(i)-z(k))*qi_z;
               end
               if k~=j  
                  qj_z=(z(j)-z(k))*qj_z;
               end   
            end
            if i~=j 
               A_z(i,j)=qi_z/((z(i)-z(j))*qj_z);
            end   
         end  
         for k=1:M  
             if k~=i
                A_z(i,i)=A_z(i,i)-A_z(i,k);
             end
         end   
      end
      A_z;
      for i=1:M
         for j=1:M
             B_z(i,j)=0;
         end  
      end      
      for i=1:M
         for j=1:M
            if i~=j
               B_z(i,j)=2*(A_z(i,i)*A_z(i,j)-(A_z(i,j)/(z(i)-z(j))));
            end   
         end      
         for k=1:M
            if i~=k
               B_z(i,i)=B_z(i,i)-B_z(i,k);
            end   
         end    
      end
      B_z;
      

%% Modified Weight functions
  
%%% Method 1
%   
% A_r_new = zeros(NM);
% A_z_new = zeros(NM);
%   
%  for i=0:(M-1)
%     A_r_new((i*N+1):(i*N+N),(i*N+1):(i*N+N)) = A_r(1:N,1:N);
%  end
% A_r_new;
% det_A_r_new=det(A_r_new);
% 
% A_z_T=A_z';
% for i=0:(M-1)
%     for j=0:(N-1)
%          A_z_new((j+1):N:(j+1+(M-1)*N),(i*N+j+1)) = A_z_T(1:M,(i+1));
%     end
% end
% A_z_new = A_z_new';
% det_A_z_new=det(A_z_new);
%   
% 
% B_r_new = zeros(NM);
% B_z_new = zeros(NM);
%   
%  for i=0:(M-1)
%     B_r_new((i*N+1):(i*N+N),(i*N+1):(i*N+N)) = B_r(1:N,1:N);
%  end
% B_r_new;
% det_B_r_new=det(B_r_new);
% 
% B_z_T=B_z';
% for i=0:(M-1)
%     for j=0:(N-1)
%          B_z_new((j+1):N:(j+1+(M-1)*N),(i*N+j+1)) = B_z_T(1:M,(i+1));
%     end
% end
% B_z_new = B_z_new';
% det_B_z_new=det(B_z_new);


%%% Method 2

I_r = eye(N);
I_z = eye(M);

A_r_new = kron(I_z,A_r);
B_r_new = kron(I_z,B_r);

A_z_new = kron(A_z,I_r);
B_z_new = kron(B_z,I_r);



%% 

C_11=((1-nu)*Ym)/((1+nu)*(1-2*nu));
d_r_C_11=0;
C_22=((1-nu)*Ym)/((1+nu)*(1-2*nu));
d_r_C_22=0;
C_33=((1-nu)*Ym)/((1+nu)*(1-2*nu));
d_r_C_33=0;

C_12=(nu*Ym)/((1+nu)*(1-2*nu));
d_r_C_12=0;
C_23=(nu*Ym)/((1+nu)*(1-2*nu));
C_13=(nu*Ym)/((1+nu)*(1-2*nu));
d_r_C_13=0;

C_55=(Ym)/(2*(1+nu));
d_r_C_55=0;

%%

% L_1% = L_1(1,j);
% L_2% = L_2(1,j);
% L_3% = L_3(1,j);
% L_4% = L_4(1,j);
% 
% J_1 = J_1(1,j);
% J_2 = J_2(1,j);
% J_3 = J_3(1,j);
% J_4 = J_4(1,j);
% J_5 = J_5(1,j);
% J_6 = J_6(1,j);
% J_7 = J_7(1,j);
% J_7_p = J_7_p(1,j);
% J_8 = J_8(1,j);
% J_8_p = J_8_p(1,j);
% J_9 = J_9(1,j);
% J_10 = J_10(1,j);
% J_11 = J_11(1,j);
% J_12 = J_12(1,j);
% J_13 = J_13(1,j);


%% Boundry conditions types

%%%---------------Mechanical---------------


%%%---------------Thermal---------------

%%% 1-Known temperature on all sides.
%%% 2-Known temperature on some sides and zero heat flex on other sides.

%%% Type 1 :
 T_UP    = 400 ;  %% Positive z direction
 T_DOWN  = 400 ;  %% Negative z direction
 T_LEFT  = 600 ;  %% Negative r direction
 T_RIGHT = 600 ;  %% Positive r direction

%%% Type 2 :
 T_Side_A = 600 ;  %% Negative r direction
%  T_Side_B = ;  %% Positive z direction
%  T_Side_C = ;  %% Positive r direction
%  T_Side_D = ;  %% Negative z direction
%  Heat_flex_Side_A = ;  %% Negative r direction
%  Heat_flex_Side_B = 0 ;  %% Positive z direction
%  Heat_flex_Side_C = convect ;  %% Positive r direction
%  Heat_flex_Side_D = 0 ;  %% Negative z direction
 T_Amb = 300 ;
 T_i = T_Side_A;



%% Initial conditions types

%%%---------------Mechanical---------------


%%%---------------Thermal---------------


%% Compatibility conditions

%%%---------------Mechanical---------------


%%%---------------Thermal---------------


 %%  Boundry conditions implantation
 
 %%%---------------Mechanical---------------
 
 %%%---------------Thermal---------------

 %%% Type 1 :
 
% d = zeros(N,M); 
%  
% d(1,2:(M-1))=T_UP;
% d(N,2:(M-1))=T_DOWN;
% d((2:N-1),1)=T_LEFT;
% d((2:N-1),M)=T_RIGHT;
% d(1,1)=0.5*(T_UP+T_LEFT);
% d(1,M)=0.5*(T_UP+T_RIGHT);
% d(N,M)=0.5*(T_DOWN+T_RIGHT);
% d(N,1)=0.5*(T_DOWN+T_LEFT);

 
T_Side_A = T_LEFT;
T_Side_B = T_DOWN;
T_Side_C = T_RIGHT;
T_Side_D = T_UP;

d = zeros(N,M); 

d(1,2:(M-1))=T_Side_A;
d(N,2:(M-1))=T_Side_C;
d((2:N-1),1)=T_Side_D;
d((2:N-1),M)=T_Side_B;
d(1,1)=0.5*(T_Side_A+T_Side_D);
d(1,M)=0.5*(T_Side_A+T_Side_B);
d(N,M)=0.5*(T_Side_C+T_Side_B);
d(N,1)=0.5*(T_Side_C+T_Side_D);

% d(1,1)=0.65*T_Side_A+0.35*T_Side_D;
% d(1,M)=0.65*T_Side_A+0.35*T_Side_D;

d;
d = reshape(d,NM,[]);



 A_r_L1=zeros(N);
for i=1:N

    A_r_L1(i,:) = L_1(1,i)*A_r(i,:);
         
end

for i=0:(M-1)
    A_r_new_L1((i*N+1):(i*N+N),(i*N+1):(i*N+N)) = A_r_L1(1:N,1:N);
 end
A_r_new_L1;

C_T_1 = A_r_new_L1;
C_T_2 = L_2(1,1)*B_r_new;
C_T_3 = L_3(1,1)*A_z_new;
C_T_4 = L_2(1,1)*B_z_new;


C_T = C_T_1+C_T_2+C_T_3+C_T_4;



C_T(1:N,:)=0;
  for i=1:N
      C_T(i,i)=1;
  end


C_T((NM-N):NM,:)=0;
  for i=(NM-N):NM
      C_T(i,i)=1;
  end

  
  for i=1:(M-2)
      C_T((i*N+1),:)=0;
  end
  for i=1:(M-2)
      C_T((i*N+1),(i*N+1))=1;
  end
  
  for i=2:(M-1)
      C_T((i*N),:)=0;
  end
  for i=2:(M-1)
      C_T((i*N),(i*N))=1;
  end
C_T;

det_C_T = det(C_T); 
 
C_T_f=C_T;
C_T;
T = (C_T^(-1))*d;
T = reshape(T,N,M);
T = T'



ka=1;
% A_r_L11=zeros(N);
r=zeros(1,N);
for i=1:N
        r(i)=0.5*(1-cos((i-1)*pi/(N-1))); %r1(i,1)=r(i); 
 end
 r;
% r(1,1)=eps;
rr=diag(1./r);
A_r_L11 = ka*(diag(1./r))*A_r;

A_r_L11_new = kron(I_z,A_r_L11);

%  C_T_test = B_r_new+B_z_new+A_z_new;%+A_r_new;
 C_T_test = B_r_new+B_z_new+A_r_new;
%  C_T_test = B_r_new+B_z_new+A_r_L11_new;
 
 
C_T_test(1:N,:)=0;
  for i=1:N
      C_T_test(i,i)=1;
  end


C_T_test((NM-N):NM,:)=0;
  for i=(NM-N):NM
      C_T_test(i,i)=1;
  end


  for i=1:(M-2)
      C_T_test((i*N+1),:)=0;
  end
  for i=1:(M-2)
      C_T_test((i*N+1),(i*N+1))=1;
  end
  
  for i=2:(M-1)
      C_T_test((i*N),:)=0;
  end
  for i=2:(M-1)
      C_T_test((i*N),(i*N))=1;
  end
C_T_test;


C_T_test;
T_test = (C_T_test^(-1))*d;
T_test = reshape(T_test,N,M);
T_test = (T_test)'


%%% Type 2 :

d = zeros(N,M); 

% d(1,2:(M-1))=T_i;
% d(N,2:(M-1))=(T_Amb);
% d((2:N-1),1)=0;
% d((2:N-1),M)=0;
% d(1,1)=0.5*(T_i+0);
% d(1,M)=0.5*(T_i+0);
% d(N,1)=0.5*((T_Amb)+0);
% d(N,M)=0.5*((T_Amb)+0);


d(1,2:(M-1))=T_i;
d(N,2:(M-1))=(T_Amb);
d((2:N-1),1)=0;
d((2:N-1),M)=0;
d(1,1)=0;
d(1,M)=0;
d(N,1)=0;
d(N,M)=0;




d;
d = reshape(d,NM,[]);



%  A_r_L1=zeros(N);
% for i=1:N
% 
%     A_r_L1(i,:) = L_1(1,i)*A_r(i,:);
%          
% end
% A_r_L1(N,:) = 0;
% A_r_L1(N,:) = (-ka/Ch)*A_r(N,:);
% 
% for i=0:(M-1)
%     A_r_new_L1((i*N+1):(i*N+N),(i*N+1):(i*N+N)) = A_r_L1(1:N,1:N);
%  end
% A_r_new_L1;
% 
% C_T_1 = A_r_new_L1;
% 
% 
% 
% % % B_r(N,:) = 0;
% % for i=0:(M-1)
% %     B_r_new((i*N+1):(i*N+N),(i*N+1):(i*N+N)) = B_r(1:N,1:N);
% %  end
% % B_r_new;
% 
% C_T_2 = L_2(1,1)*B_r_new;
% 
% 
% 
% % A_z(:,1) = 0;
% % A_z(:,M) = 0;
% % A_z_T=A_z';
% % for i=0:(M-1)
% %     for j=0:(N-1)
% %          A_z_new((j+1):N:(j+1+(M-1)*N),(i*N+j+1)) = A_z_T(1:M,(i+1));
% %     end
% % end
% % A_z_new = A_z_new';
% 
% C_T_3 = L_3(1,1)*A_z_new;
% 
% 
% % % B_z(:,1) = 0;
% % % B_z(:,M) = 0;
% % B_z_T=B_z';
% % for i=0:(M-1)
% %     for j=0:(N-1)
% %          B_z_new((j+1):N:(j+1+(M-1)*N),(i*N+j+1)) = B_z_T(1:M,(i+1));
% %     end
% % end
% % B_z_new = B_z_new';
% 
% C_T_4 = L_2(1,1)*B_z_new;
% 
% 
% C_T = C_T_1+C_T_2+C_T_3+C_T_4;
% 
% 
% 
% %--- Negative z direction
% 
% % C_T(1:N,:)=0;
% %   for i=1:N
% %       C_T(i,i)=1;
% %   end
% 
% 
% %--- Positive z direction 
% 
% % C_T((NM-N):NM,:)=0;
% %   for i=(NM-N):NM
% %       C_T(i,i)=1;
% %   end
% 
% 
% %--- Negative r direction
% 
%   for i=1:(M-2)
%       C_T((i*N+1),:)=0;
%   end
%   for i=1:(M-2)
%       C_T((i*N+1),(i*N+1))=1;
%   end
%   
%   
% %--- Positive r direction 
% 
% %   for i=2:(M-1)
% %       C_T((i*N),:)=0;
% %   end
% %   for i=2:(M-1)
% %       C_T((i*N),(i*N))=1;
% %   end
% C_T;











A_r_L1=zeros(N);
for i=1:N

    A_r_L1(i,:) = L_1(1,i)*A_r(i,:);
         
end
A_r_L1(N,:) = 0;
A_r_L1(N,:) = (-ka/Ch)*A_r(N,:);

for i=0:(M-1)
    A_r_new_L1((i*N+1):(i*N+N),(i*N+1):(i*N+N)) = A_r_L1(1:N,1:N);
 end
A_r_new_L1;

C_T_1 = A_r_new_L1;


%%%--- Negative z direction

C_T_1(1:N,:)=0;
%   for i=1:N
%       C_T_1(i,i)=1;
%   end


%%%--- Positive z direction 

C_T_1((NM-N):NM,:)=0;
%   for i=(NM-N):NM
%       C_T_1(i,i)=1;
%   end


%%%--- Negative r direction

  for i=1:(M-2)
      C_T_1((i*N+1),:)=0;
  end
  for i=1:(M-2)
      C_T_1((i*N+1),(i*N+1))=1;
  end
  
  
%%%--- Positive r direction 

  for i=2:(M-1)
      C_T_1((i*N),:)=0;
  end
  for i=2:(M-1)
      C_T_1((i*N),(i*N))=1;
  end
C_T_1;
% C_T_1(NM-N,:) = A_r_new_L1(NM-N,:); 
% C_T_1(NM-N,NM-N) = 1.0;
% C_T_1(NM-N,NM-N) = A_r_new_L1(NM-N,NM-N); 



C_T_2 = L_2(1,1)*B_r_new;



%%%--- Negative z direction

C_T_2(1:N,:)=0;
%   for i=1:N
%       C_T_2(i,i)=1;
%   end


%%%--- Positive z direction 

C_T_2((NM-N):NM,:)=0;
%   for i=(NM-N):NM
%       C_T_2(i,i)=1;
%   end


%%%--- Negative r direction

  for i=1:(M-2)
      C_T_2((i*N+1),:)=0;
  end
%   for i=1:(M-2)
%       C_T_2((i*N+1),(i*N+1))=1;
%   end
  
  
%%%--- Positive r direction 

  for i=2:(M-1)
      C_T_2((i*N),:)=0;
  end
%   for i=2:(M-1)
%       C_T_2((i*N),(i*N))=1;
%   end
C_T_2;



C_T_3 = L_3(1,1)*A_z_new;




%%%--- Negative z direction

C_T_3(1:N,:)=0;
  for i=1:N
      C_T_3(i,:)=A_z_new(i,:);
  end


%%%--- Positive z direction 

C_T_3((NM-N):NM,:)=0;
  for i=(NM-N):NM
      C_T_3(i,:)=A_z_new(i,:);
  end

  
%   for i=2*N:N:(M-2)*N
%       C_T_3(i,i)=A_z_new(i,i);
%   end  
  

%%%--- Negative r direction

  for i=1:(M-2)
      C_T_3((i*N+1),:)=0;
  end
%   for i=1:(M-2)
%       C_T_3((i*N+1),(i*N+1))=1;
%   end
  
  
%%%--- Positive r direction 

  for i=2:(M-1)
      C_T_3((i*N),:)=0;
  end
%   for i=2:(M-1)
%       C_T_3((i*N),(i*N))=1;
%   end
C_T_3;
C_T_3(1,:) = 0;
C_T_3(1,1) = 1;
C_T_3(NM-N+1,:) = 0;
C_T_3(NM-N+1,NM-N+1) = 1;


C_T_3(1,:) = 0;
C_T_3(1,1) = -1;
C_T_3(1,2) = 0.5;
C_T_3(1,N+1) = 0.5;

C_T_3(NM-N+1,:) = 0;
C_T_3(NM-N+1,NM-N+1) = -1;
C_T_3(NM-N+1,NM-N+2) = 0.5;
C_T_3(NM-N+1,NM-2*N+1) = 0.5;


C_T_3(N,:) = 0;
C_T_3(N,N) = -1;
C_T_3(N,N-1) = 0.5;
C_T_3(N,2*N) = 0.5;

C_T_3(NM,:) = 0;
C_T_3(NM,NM) = -1;
C_T_3(NM,NM-1) = 0.5;
C_T_3(NM,NM-N) = 0.5;





C_T_4 = L_2(1,1)*B_z_new;



%%%--- Negative z direction

C_T_4(1:N,:)=0;
%   for i=1:N
%       C_T_4(i,i)=1;
%   end


%%%--- Positive z direction 

C_T_4((NM-N):NM,:)=0;
%   for i=(NM-N):NM
%       C_T_4(i,i)=1;
%   end


%%%--- Negative r direction

  for i=1:(M-2)
      C_T_4((i*N+1),:)=0;
  end
%   for i=1:(M-2)
%       C_T_4((i*N+1),(i*N+1))=1;
%   end
  
  
%%%--- Positive r direction 

  for i=2:(M-1)
      C_T_4((i*N),:)=0;
  end
%   for i=2:(M-1)
%       C_T_4((i*N),(i*N))=1;
%   end
C_T_4;



C_T = C_T_1+C_T_2+C_T_3+C_T_4;







det_C_T = det(C_T);
 
 
C_T;
T = (C_T^(-1))*d;
% T = C_T \ d;
T_calc = reshape(T,N,M);
T_real = T_calc'



T=T_calc;
Dlt_T = T(N,:)-T(1,:);

Dlt_T = Dlt_T';

for i=1:M
    Dlt_T_new(1:N:NM,1) = Dlt_T(i,1);
end









