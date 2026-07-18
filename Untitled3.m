
clc,clear;
% function [T,N,M] = Displacements(r,z,t)


%% Number of nodes
  N=7;  %% r direction
  M=5;  %% z direction
  NM = N*M;
  
%% Material properties

%%% nu : Poisson's ratio for r direction

%%% Ym : young's modules for r direction

%%% ro : Density

%%% al : Thermal espantion coefficient for r direction

%%% Sc : Specific heat capacity

%%% ka : Thermal conductivity for r direction

%%% Ch : Convection heat transfer coefficient

%%% C_ij : Elastic coefficients

%%%

%%%

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

%%


e=0.7404;


%%

for i=1:N
        r(i)=0.5*(1-cos((i-1)*pi/(N-1))); %r1(i,1)=r(i); 
 end
 r;

%%
% i=0;
j=0;
for i=0.010:0.002:0.030;
    j=j+1;
   
    W_GPL=i;
%  W_GPL=0.040



V_GPL=W_GPL/(W_GPL+((ro_GPL/ro_m)*(1-W_GPL)));

ks_L=2*(a_GPL/t_GPL);
ks_W=2*(b_GPL/t_GPL);
et_L=((Ym_GPL/Ym_m)-1)/((Ym_GPL/Ym_m)+ks_L);
et_W=((Ym_GPL/Ym_m)-1)/((Ym_GPL/Ym_m)+ks_W);
Ym_L=((1+ks_L*et_L*V_GPL)/(1-et_L*V_GPL))*Ym_m;
Ym_T=((1+ks_W*et_W*V_GPL)/(1-et_W*V_GPL))*Ym_m;

Ym_s = 3/8*Ym_L+5/8*Ym_T;


V_m=1-V_GPL;

nu_s=V_GPL*nu_GPL+V_m*al_m;

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


end
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

L_1 = (ka/r);
L_2 = ka;
L_3 = 0;
L_4 = ro*Sc;

J_1 = C_11;
J_2 = d_r_C_11+(C_11/r);
J_3 = C_55;
J_4 = (d_r_C_12-(C_22/r))/r;
J_5 = d_r_C_13+((C_13-C_23)/r);
J_6 = C-55+C_13;
J_7 = (d_r_C_11+d_r_C_12+d_r_C_13)*al;
J_7_p = (d_r_C_11+d_r_C_12+d_r_C_13)*al + (C_11+C_12+C_13)*d_r_al;
J_8 = C_11+C_12+C_13;
J_8_p = (C_11+C_12+C_13)*al;
J_9 = ro;
J_10 = C_12;
J_11 = d_r_C_55+(C_55/r);
J_12 = d_r_C_55+((C_23-C_55)/r);


%% Weight functions
  %function [A_r,B_r]=WEIGHT(N) %% r direction
 for i=1:N
        r(i)=0.5*(1-cos((i-1)*pi/(N-1))); %r1(i,1)=r(i); 
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
       
  %end
   
   
   
 %function [A_z,B_z]=WEIGHT(M) %% z direction
      for i=1:M
        z(i)=0.5*(1-cos((i-1)*pi/(M-1))); %y1(i,1)=y(i); 
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
      
 %end
  %% Modified Weight functions
      
A_r_new = zeros(NM);
A_z_new = zeros(NM);
  
 for i=0:(M-1)
    A_r_new((i*N+1):(i*N+N),(i*N+1):(i*N+N)) = A_r(1:N,1:N);
 end
A_r_new;
det_A_r_new=det(A_r_new);

A_z_T=A_z';
for i=0:(M-1)
    for j=0:(N-1)
         A_z_new((j+1):N:(j+1+(M-1)*N),(i*N+j+1)) = A_z_T(1:M,(i+1));
    end
end
A_z_new = A_z_new';
det_A_z_new=det(A_z_new);
  

B_r_new = zeros(NM);
B_z_new = zeros(NM);
  
 for i=0:(M-1)
    B_r_new((i*N+1):(i*N+N),(i*N+1):(i*N+N)) = B_r(1:N,1:N);
 end
B_r_new;
det_B_r_new=det(B_r_new);

B_z_T=B_z';
for i=0:(M-1)
    for j=0:(N-1)
         B_z_new((j+1):N:(j+1+(M-1)*N),(i*N+j+1)) = B_z_T(1:M,(i+1));
    end
end
B_z_new = B_z_new';
det_B_z_new=det(B_z_new);


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

L_1 = (ka/r);
L_2 = ka;
L_3 = 0;
L_4 = ro*Sc;

J_1 = C_11;
J_2 = d_r_C_11+(C_11/r);
J_3 = C_55;
J_4 = (d_r_C_12-(C_22/r))/r;
J_5 = d_r_C_13+((C_13-C_23)/r);
J_6 = C-55+C_13;
J_7 = (d_r_C_11+d_r_C_12+d_r_C_13)*al;
J_7_p = (d_r_C_11+d_r_C_12+d_r_C_13)*al + (C_11+C_12+C_13)*d_r_al;
J_8 = C_11+C_12+C_13;
J_8_p = (C_11+C_12+C_13)*al;
J_9 = ro;
J_10 = C_12;
J_11 = d_r_C_55+(C_55/r);
J_12 = d_r_C_55+((C_23-C_55)/r);



%% Boundry conditions types

%%%---------------Mechanical---------------

%%% (r)diretion normal stress:

% C_rz_rrNS*U_W - J_8_p*del_T = 0;

%%% (z)diretion normal stress:

% C_rz_zzNS*U_W - J_8_p*del_T = 0;


%%% (r)plan (z)diretion shear stress:

% C_rz_rzSS*U_W = 0;

%%% at z=0 and z=L:

% u=0;
 %or
% C_rz_rzSS*U_W = 0;

% w=0;
 %or
% C_rz_zzNS*U_W - J_8_p*del_T = 0;

%%% at r=R_i:

% C_rz_rzSS*U_W = 0;
% C_rz_rrNS*U_W - J_8_p*del_T = -P_i;


%%%---Clasical Boundry conditions---

%%% Simply support

% u=0;
% C_rz_zzNS*U_W - J_8_p*del_T = 0;

%%% Free

% C_rz_rzSS*U_W = 0;
% C_rz_zzNS*U_W - J_8_p*del_T = 0;

%%% clamped

% u=0;
% w=0;



%%%---------------Thermal---------------

%%% 1-Known temperature on all sides.
%%% 2-Known temperature on some sides and zero heat flex on other sides.
%%% 3-Known temperature on some sides and heat flex on other sides.
%%% 4-Heat flex on all sides.

%%% Type 1 :
 T_UP    =300 ;  %% Negative X direction
 T_DOWN  =700 ;  %% Positive X direction
 T_LEFT  =100 ;  %% Negative Y direction
 T_RIGHT =120 ;  %% Positive Y direction

%%% Type 2 :
%  T_Side_A = ;  %% Negative X direction
%  T_Side_B = ;  %% Positive X direction
%  T_Side_C = ;  %% Negative Y direction
%  T_Side_D = ;  %% Positive Y direction
%  Heat_flex_Side_A = ;  %% Negative X direction
%  Heat_flex_Side_B = ;  %% Positive X direction
%  Heat_flex_Side_C = ;  %% Negative Y direction
%  Heat_flex_Side_D = ;  %% Positive Y direction

%%% Type 3 :
%  T_Side_A = ;  %% Negative X direction
%  T_Side_B = ;  %% Positive X direction
%  T_Side_C = ;  %% Negative Y direction
%  T_Side_D = ;  %% Positive Y direction
%  Heat_flex_Side_A = ;  %% Negative X direction
%  Heat_flex_Side_B = ;  %% Positive X direction
%  Heat_flex_Side_C = ;  %% Negative Y direction
%  Heat_flex_Side_D = ;  %% Positive Y direction

%%% Type 4 : 
%  Heat_flex_UP    = ;  %% Negative X direction
%  Heat_flex_DOWN  = ;  %% Positive X direction
%  Heat_flex_LEFT  = ;  %% Negative Y direction
%  Heat_flex_RIGHT = ;  %% Positive Y direction

%% Initial conditions types

%%%---------------Mechanical---------------
















%%%---------------Thermal---------------


%% Compatibility conditions

%%%---------------Mechanical---------------
















%%%---------------Thermal---------------




%%


C_T = L_1*A_r_new+L_2*B_r_new+L_3*A_z_new+L_4*B_z_new;

C_r_U = J_2*A_r_new+J_1*B_r_new+J_3*B_z_new+J_4*eye(NM);
C_r_W = J_5*A_z_new+J_6*(A_r_new*A_z_new);

C_r_dl_T = J_7_p*eye(NM)+J_8_p*A_r_new;

C_z_U = J_12*A_z_new;
C_z_W = J_6*(A_r_new*A_z_new)+J_11*A_r_new+J_3*B_r_new+J_1*B_z_new;

C_rz_U = C_r_U+C_z_U;
C_rz_W = C_r_W+C_z_W;

C_r = zeros(2*NM);
C_r(1:NM,1:NM) = C_r_U;
C_r((NM+1):(2*NM),(NM+1):(2*NM)) = C_r_W;

C_z = zeros(2*NM);
C_z(1:NM,1:NM) = C_z_U;
C_z((NM+1):(2*NM),(NM+1):(2*NM)) = C_z_W;

C_rz = C_r+C_z;
  
 %%  Boundry conditions implantation
 
 %%%---------------Mechanical---------------
 
 
 
 
 
 
 
 
 
 
 
 
 %%%---------------Thermal---------------
 
 d = zeros(N,M); 

% d(1,2:(M-1))= T(1,2:(M-1));
% d(N,2:(M-1))=T(N,2:(M-1));
% d((2:N-1),1)=T((2:N-1),1);
% d((2:N-1),M)=T((2:N-1),M);
% d(1,1)=T(1,1);
% d(1,M)=T(1,M);
% d(N,M)=T(N,M);
% d(N,1)=T(N,1); 

d(1,2:(M-1))=T_UP;
d(N,2:(M-1))=T_DOWN;
d((2:N-1),1)=T_LEFT;
d((2:N-1),M)=T_RIGHT;
d(1,1)=0.5*(T_UP+T_LEFT);
d(1,M)=0.5*(T_UP+T_RIGHT);
d(N,M)=0.5*(T_DOWN+T_RIGHT);
d(N,1)=0.5*(T_DOWN+T_LEFT);

d;
d = reshape(d,NM,[]);
 
 
 
C_T(1:N,:)=0;
C_T((NM-N):NM,:)=0;
  for i=1:(M-2)
      C_T((i*N+1),:)=0;
  end
  for i=2:(M-1)
      C_T((i*N),:)=0;
  end
  for i=1:N
      C_T(i,i)=1;
  end
  for i=(NM-N):NM
      C_T(i,i)=1;
  end
  for i=1:(M-2)
      C_T((i*N+1),(i*N+1))=1;
  end
  for i=2:(M-1)
      C_T((i*N),(i*N))=1;
  end
C_T
det_C_T = det(C_T); 
 
 
 
% T = (C_T^(-1))*d; 
% T = reshape(T,N,M)

for i=1:N
    r(i)=0.5*(1-cos((i-1)*pi/(N-1))); %r1(i,1)=r(i);
      for r= r(i):r(N)
          T = (C_T^(-1))*d;
      end 
 end

T = reshape(T,N,M)

























