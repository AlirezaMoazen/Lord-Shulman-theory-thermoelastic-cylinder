clc,clear;
% function [T,N,M] = Displacements(r,z,t)


%% Number of nodes
  N=5;  %% r direction
  M=9;  %% z direction
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
 r

%%
%%% i=0;
j=0;
% for i=0.010:0.002:0.030;
    j=j+1;
%    
%     W_GPL=i;
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


% end
%% 

C_11=((1-nu)*Ym)/((1+nu)*(1-(2*nu)));
d_r_C_11=0;
C_22=((1-nu)*Ym)/((1+nu)*(1-(2*nu)));
d_r_C_22=0;
C_33=((1-nu)*Ym)/((1+nu)*(1-(2*nu)));
d_r_C_33=0;

C_12=(nu*Ym)/((1+nu)*(1-(2*nu)));
d_r_C_12=0;
C_23=(nu*Ym)/((1+nu)*(1-(2*nu)));
C_13=(nu*Ym)/((1+nu)*(1-(2*nu)));
d_r_C_13=0;

C_55=(Ym)/(2*(1+nu));
d_r_C_55=0;

%%


 j=0;
for i=1:N
    
    j=j+1;
    
    if i==1;
     r(i)=0.5*(1-cos((i-1)*pi/(N-1)))+10^(-10) %r1(i,1)=r(i); 
     
     
L_1(1,j) = ka/r(1,j);
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

    else i>1;
       r(i)=0.5*(1-cos((i-1)*pi/(N-1))); %r1(i,1)=r(i);  
       
       
L_1(1,j) = ka/r(1,j);
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





L_1 ; 
L_2 ;
L_3 ;
L_4 ;

J_1; 
J_2 ;
J_3 ;
J_4 ;
J_5 ;
J_6 ;
J_7 ;
J_7_p ;
J_8 ;
J_8_p ; 
J_9 ;
J_10 ;
J_11 ;
J_12 ;
J_13 ;




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






