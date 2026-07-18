


clc,clear;

% function [T,N,M] = Displacements(r,z,t)
% format short

%% Number of nodes
  N=19;  %% r direction
  M=17;  %% z direction
  NM = N*M; 
  
% Clamped boundry condition is equall to 1
% Simply support boundry condition is equall to 2
% Free boundry condition is equall to 3
% Fully clamped boundry condition is equall to type 4
  boundry_condition=01;


%% Legend

%%% e : Layer number

%%% NL : Number of layers

%%% h : Thickness of cylinder(R_o-R_i)

%%% Lt : Layer thickness

%%% R_i : Internal radius

%%% R_o : External radius

%%% p_i : Internal pressure


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

p_i=300*10^(6);


%%

r=zeros(1,N);
for i=1:N
        r(i)=0.5*(1-cos((i-1)*pi/(N-1))); %r1(i,1)=r(i); 
 end
 r;

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
% O-Type GPL pattern is equall to 1
% X-Type GPL pattern is equall to 2
% UD-Type GPL pattern is equall to 3
% V-Type GPL pattern is equall to 4
% A-Type GPL pattern is equall to 5

% Non-porous material is equall to 0
% O-Type porosity pattern is equall to 1
% X-Type porosity pattern is equall to 2
% UD-Type porosity pattern is equall to 3
% V-Type porosity pattern is equall to 4
% A-Type porosity pattern is equall to 5


GPL_patern=3;

Porosity_pattern=1;

%%
W_GPL=0.04;

vec_e_3=[0.9361;  %1
         0.8716;  %2
         0.8064;  %3
         0.7404;  %4
         0.6733;  %5
         0.6047]; %6
     
e_3=vec_e_3(5,1);


R_o=NL;
R_i=0;

%%

Ym = zeros(1,NL);
nu = zeros(1,NL);
ro = zeros(1,NL);
al = zeros(1,NL);
Sc = zeros(1,NL);
ka = zeros(1,NL);
Ch = zeros(1,NL);

Ym_s = zeros(1,NL);
nu_s = zeros(1,NL);
ro_s = zeros(1,NL);
al_s = zeros(1,NL);
Sc_s = zeros(1,NL);
ka_s = zeros(1,NL);
% Ch = zeros(1,NL);

if GPL_patern==1
    j=0;
for e=1:NL
     W_GPL_O = 4*W_GPL*(((NL+1)/2)-abs(e-((NL+1)/2)))/(NL+2);
     
    j=j+1;

V_GPL=W_GPL_O/(W_GPL_O+((ro_GPL/ro_m)*(1-W_GPL_O)));

ks_L=2*(a_GPL/t_GPL);
ks_W=2*(b_GPL/t_GPL);
et_L=((Ym_GPL/Ym_m)-1)/((Ym_GPL/Ym_m)+ks_L);
et_W=((Ym_GPL/Ym_m)-1)/((Ym_GPL/Ym_m)+ks_W);
Ym_L=((1+ks_L*et_L*V_GPL)/(1-et_L*V_GPL))*Ym_m;
Ym_T=((1+ks_W*et_W*V_GPL)/(1-et_W*V_GPL))*Ym_m;

Ym_s(1,j) = 3/8*Ym_L+5/8*Ym_T;


V_m=1-V_GPL;

nu_s(1,j) = V_GPL*nu_GPL+V_m*nu_m;

ro_s(1,j) = V_GPL*ro_GPL+V_m*ro_m;

Sc_s(1,j) = V_GPL*Sc_GPL+V_m*Sc_m;

al_s(1,j) = V_GPL*al_GPL+V_m*al_m;

P=a_GPL/t_GPL;
H_P=((log(P+sqrt(P^2-1))*P)/(sqrt((P^2-1)^3)))-(1/(P^2-1));

ka_s(1,j) = (((2/3)*(V_GPL-(1/P))^(gama))/(H_P+(1/((ka_GPL/ka_m)-1))))*ka_m+ka_m;

Ch(1,j) = 10;

% d_r_al=0;


end

 elseif GPL_patern==2
    j=0;
for e=1:NL
     W_GPL_X = 4*W_GPL*((1/2)+abs(e-((NL+1)/2)))/(NL+2);
     
    j=j+1;

V_GPL=W_GPL_X/(W_GPL_X+((ro_GPL/ro_m)*(1-W_GPL_X)));

ks_L=2*(a_GPL/t_GPL);
ks_W=2*(b_GPL/t_GPL);
et_L=((Ym_GPL/Ym_m)-1)/((Ym_GPL/Ym_m)+ks_L);
et_W=((Ym_GPL/Ym_m)-1)/((Ym_GPL/Ym_m)+ks_W);
Ym_L=((1+ks_L*et_L*V_GPL)/(1-et_L*V_GPL))*Ym_m;
Ym_T=((1+ks_W*et_W*V_GPL)/(1-et_W*V_GPL))*Ym_m;

Ym_s(1,j) = 3/8*Ym_L+5/8*Ym_T;


V_m=1-V_GPL;

nu_s(1,j) = V_GPL*nu_GPL+V_m*nu_m;

ro_s(1,j) = V_GPL*ro_GPL+V_m*ro_m;

Sc_s(1,j) = V_GPL*Sc_GPL+V_m*Sc_m;

al_s(1,j) = V_GPL*al_GPL+V_m*al_m;

P=a_GPL/t_GPL;
H_P=((log(P+sqrt(P^2-1))*P)/(sqrt((P^2-1)^3)))-(1/(P^2-1));

ka_s(1,j) = (((2/3)*(V_GPL-(1/P))^(gama))/(H_P+(1/((ka_GPL/ka_m)-1))))*ka_m+ka_m;

Ch(1,j) = 10;

% d_r_al=0;

end
  
 elseif GPL_patern==3
    
for j=1:NL
     W_GPL_UD = W_GPL;
     
   

V_GPL=W_GPL_UD/(W_GPL_UD+((ro_GPL/ro_m)*(1-W_GPL_UD)));

ks_L=2*(a_GPL/t_GPL);
ks_W=2*(b_GPL/t_GPL);
et_L=((Ym_GPL/Ym_m)-1)/((Ym_GPL/Ym_m)+ks_L);
et_W=((Ym_GPL/Ym_m)-1)/((Ym_GPL/Ym_m)+ks_W);
Ym_L=((1+ks_L*et_L*V_GPL)/(1-et_L*V_GPL))*Ym_m;
Ym_T=((1+ks_W*et_W*V_GPL)/(1-et_W*V_GPL))*Ym_m;

Ym_s(1,j) = 3/8*Ym_L+5/8*Ym_T;


V_m=1-V_GPL;

nu_s(1,j) = V_GPL*nu_GPL+V_m*nu_m;

ro_s(1,j) = V_GPL*ro_GPL+V_m*ro_m;

Sc_s(1,j) = V_GPL*Sc_GPL+V_m*Sc_m;

al_s(1,j) = V_GPL*al_GPL+V_m*al_m;

P=a_GPL/t_GPL;
H_P=((log(P+sqrt(P^2-1))*P)/(sqrt((P^2-1)^3)))-(1/(P^2-1));

ka_s(1,j) = (((2/3)*(V_GPL-(1/P))^(gama))/(H_P+(1/((ka_GPL/ka_m)-1))))*ka_m+ka_m;

Ch(1,j) = 10;

% d_r_al=0;

end

 elseif GPL_patern==4
    j=0;
for e=1:NL
     W_GPL_V = 2*W_GPL*e/(NL+1);
     
    j=j+1;

V_GPL=W_GPL_V/(W_GPL_V+((ro_GPL/ro_m)*(1-W_GPL_V)));

ks_L=2*(a_GPL/t_GPL);
ks_W=2*(b_GPL/t_GPL);
et_L=((Ym_GPL/Ym_m)-1)/((Ym_GPL/Ym_m)+ks_L);
et_W=((Ym_GPL/Ym_m)-1)/((Ym_GPL/Ym_m)+ks_W);
Ym_L=((1+ks_L*et_L*V_GPL)/(1-et_L*V_GPL))*Ym_m;
Ym_T=((1+ks_W*et_W*V_GPL)/(1-et_W*V_GPL))*Ym_m;

Ym_s(1,j) = 3/8*Ym_L+5/8*Ym_T;


V_m=1-V_GPL;

nu_s(1,j) = V_GPL*nu_GPL+V_m*nu_m;

ro_s(1,j) = V_GPL*ro_GPL+V_m*ro_m;

Sc_s(1,j) = V_GPL*Sc_GPL+V_m*Sc_m;

al_s(1,j) = V_GPL*al_GPL+V_m*al_m;

P=a_GPL/t_GPL;
H_P=((log(P+sqrt(P^2-1))*P)/(sqrt((P^2-1)^3)))-(1/(P^2-1));

ka_s(1,j) = (((2/3)*(V_GPL-(1/P))^(gama))/(H_P+(1/((ka_GPL/ka_m)-1))))*ka_m+ka_m;

Ch(1,j) = 10;

% d_r_al=0;

end
 
elseif GPL_patern==5
    j=0;
for e=1:NL
     W_GPL_A = W_GPL*(2*(NL+1-e)/(NL+1));
     
    j=j+1;

V_GPL=W_GPL_A/(W_GPL_A+((ro_GPL/ro_m)*(1-W_GPL_A)));

ks_L=2*(a_GPL/t_GPL);
ks_W=2*(b_GPL/t_GPL);
et_L=((Ym_GPL/Ym_m)-1)/((Ym_GPL/Ym_m)+ks_L);
et_W=((Ym_GPL/Ym_m)-1)/((Ym_GPL/Ym_m)+ks_W);
Ym_L=((1+ks_L*et_L*V_GPL)/(1-et_L*V_GPL))*Ym_m;
Ym_T=((1+ks_W*et_W*V_GPL)/(1-et_W*V_GPL))*Ym_m;

Ym_s(1,j) = 3/8*Ym_L+5/8*Ym_T;


V_m=1-V_GPL;

nu_s(1,j) = V_GPL*nu_GPL+V_m*nu_m;

ro_s(1,j) = V_GPL*ro_GPL+V_m*ro_m;

Sc_s(1,j) = V_GPL*Sc_GPL+V_m*Sc_m;

al_s(1,j) = V_GPL*al_GPL+V_m*al_m;

P=a_GPL/t_GPL;
H_P=((log(P+sqrt(P^2-1))*P)/(sqrt((P^2-1)^3)))-(1/(P^2-1));

ka_s(1,j) = (((2/3)*(V_GPL-(1/P))^(gama))/(H_P+(1/((ka_GPL/ka_m)-1))))*ka_m+ka_m;

Ch(1,j) = 10;

% d_r_al=0;

end
end  


Ym_s;
nu_s;
ro_s;
al_s;
Sc_s;
ka_s;
Ch;


if e_3==0.9361
    
    e_1=0.1; e_2=0.1738; e_4=0; e_5=0;
        
elseif e_3==0.8716
    
    e_1=0.2; e_2=0.3442; e_4=0; e_5=0;
        
elseif e_3==0.8064
    
    e_1=0.3; e_2=0.5103; e_4=0; e_5=0;
      
elseif e_3==0.7404
    
    e_1=0.4; e_2=0.6708; e_4=0; e_5=0;
       
 elseif e_3==0.6733
    
    e_1=0.5; e_2=0.8231; e_4=0; e_5=0;
          
elseif e_3==0.6047
    
    e_1=0.6; e_2=0.9612; e_4=0;e_5=0;
        
end


h = R_o-R_i;
Lt = h/NL;

if Porosity_pattern==0

Ym = Ym_s;
nu = nu_s;
ro = ro_s;
al = al_s;
Sc = Sc_s;
ka = ka_s;
% Ch = Ch;

elseif Porosity_pattern==1
    j=0;
for k=0:NL-1
     r_m=R_i+Lt/2+Lt*k;
     r_m_bar=(r_m-R_i)/(NL*Lt);
     r=r_m_bar;
      e_1_m=(1-sqrt(1-e_1*cos(pi*r/h)))/cos(pi*r/h);
      P_O = 1-e_1*cos(pi*r/h);
      P_O_m = 1-e_1_m*cos(pi*r/h);

    j=j+1;

Ym(1,j) = Ym_s(1,j)*P_O;

nu(1,j) = nu_s(1,j);

ro(1,j) = ro_s(1,j)*P_O_m;

Sc(1,j) = Sc_s(1,j)*P_O;

al(1,j) = al_s(1,j);

ka(1,j) = ka_s(1,j)*P_O;

Ch(1,j) = 10;

end

elseif Porosity_pattern==2
    j=0;
for k=0:NL-1
     r_m=R_i+Lt/2+Lt*k;
     r_m_bar=(r_m-R_i)/(NL*Lt);
     r=r_m_bar;
      e_2_m=(1-sqrt(1-e_2*(1-cos(pi*r/h))))/(1-cos(pi*r/h));
      P_X = 1-e_2*(1-cos(pi*r/h));
      P_X_m = 1-e_2_m*(1-cos(pi*r/h));

    j=j+1;

Ym(1,j) = Ym_s(1,j)*P_X;

nu(1,j) = nu_s(1,j);

ro(1,j) = ro_s(1,j)*P_X_m;

Sc(1,j) = Sc_s(1,j)*P_X;

al(1,j) = al_s(1,j);

ka(1,j) = ka_s(1,j)*P_X;

Ch(1,j) = 10;

end

elseif Porosity_pattern==3
    j=0;
for j=1:NL
     e_3_m=sqrt(e_3);
     P_UD = e_3;
     P_UD_m = e_3_m;
     


Ym(1,j) = Ym_s(1,j)*P_UD;

nu(1,j) = nu_s(1,j);

ro(1,j) = ro_s(1,j)*P_UD_m;

Sc(1,j) = Sc_s(1,j)*P_UD;

al(1,j) = al_s(1,j);

ka(1,j) = ka_s(1,j)*P_UD;

Ch(1,j) = 10;

end

elseif Porosity_pattern==4
    j=0;
for k=0:NL-1
     r_m=R_i+Lt/2+Lt*k;
     r_m_bar=(r_m-R_i)/(NL*Lt);
     r=r_m_bar;
      e_4_m=(sqrt(e_4*cos(pi*r/2*h+pi/4)))/(e_4*cos(pi*r/2*h+pi/4));
      P_V = e_4*cos(pi*r/2*h+pi/4);
      P_V_m = e_4_m*cos(pi*r/2*h+pi/4);

    j=j+1;

Ym(1,j) = Ym_s(1,j)*P_V;

nu(1,j) = nu_s(1,j);

ro(1,j) = ro_s(1,j)*P_V_m;

Sc(1,j) = Sc_s(1,j)*P_V;

al(1,j) = al_s(1,j);

ka(1,j) = ka_s(1,j)*P_V;

Ch(1,j) = 10;

end

elseif Porosity_pattern==5
    j=0;
for k=0:NL-1
     r_m=R_i+Lt/2+Lt*k;
     r_m_bar=(r_m-R_i)/(NL*Lt);
     r=r_m_bar;
      e_5_m=(sqrt(e_5*cos(pi*r/2*h+5*pi/4)))/(e_5*cos(pi*r/2*h+5*pi/4));
      P_A = e_5*cos(pi*r/2*h+5*pi/4);
      P_A_m = e_5_m*cos(pi*r/2*h+5*pi/4);
      
    j=j+1;

Ym(1,j) = Ym_s(1,j)*P_A;

nu(1,j) = nu_s(1,j);

ro(1,j) = ro_s(1,j)*P_A_m;

Sc(1,j) = Sc_s(1,j)*P_A;

al(1,j) = al_s(1,j);

ka(1,j) = ka_s(1,j)*P_A;

Ch(1,j) = 10;

end
end
   

Ym;
nu;
ro;
al;
Sc;
ka;
Ch;


%%
Ym_s ;
nu_s ;
ro_s ;
al_s ;
Sc_s ;
ka_s ;
Ch ;

% Ym = Ym_m ;
% nu = nu_m ;
% ro = ro_m ;
% al = al_m ;
% Sc = Sc_m ;
% ka = ka_m ;
% Ch = Ch ;

Ym;
nu;
ro;
al;
Sc;
ka;
Ch;


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
%      r(i)=0.5*(1-cos((i-1)*pi/(N-1)))+1e-10; %r1(i,1)=r(i); 
     r(i)=0.5*(1-cos((i-1)*pi/(N-1)))+eps; %r1(i,1)=r(i);
     
L_1(1,j) = (ka*1^(-12))/r(1,j);
L_2(1,j) = ka;
L_3(1,j) = 0;
L_4(1,j) = ro*Sc;

J_1(1,j) = C_11;
J_2(1,j) = d_r_C_11+(C_11/r(1,j));
J_3(1,j) = C_55;
J_4(1,j) = d_r_C_12/r(1,j)-(C_22/(r(1,j)*r(1,j)));
J_5(1,j) = d_r_C_13+((C_13-C_23)/r(1,j));
J_6(1,j) = C_55+C_13;
J_7(1,j) = (d_r_C_11+d_r_C_12+d_r_C_13)*al;
J_7_p(1,j) = (d_r_C_11+d_r_C_12+d_r_C_13)*al + (C_11+C_12+C_13)*d_r_al;
J_8(1,j) = C_11+C_12+C_13;
J_8_p(1,j) = (C_11+C_12+C_13)*al;
J_9(1,j) = ro;
J_10(1,j) = C_12;
J_11(1,j) = d_r_C_55+(C_55/r(1,j));
J_12(1,j) = d_r_C_55+((C_23+C_55)/r(1,j));
J_13(1,j) = C_23/r(1,j);

    else 
       r(i)=0.5*(1-cos((i-1)*pi/(N-1))); %r1(i,1)=r(i);  
       
    
L_1(1,j) = (ka*1^(-12))/r(1,j);
L_2(1,j) = ka;
L_3(1,j) = 0;
L_4(1,j) = ro*Sc;

J_1(1,j) = C_11;
J_2(1,j) = d_r_C_11+(C_11/r(1,j));
J_3(1,j) = C_55;
J_4(1,j) = d_r_C_12/r(1,j)-(C_22/(r(1,j)*r(1,j)));
J_5(1,j) = d_r_C_13+((C_13-C_23)/r(1,j));
J_6(1,j) = C_55+C_13;
J_7(1,j) = (d_r_C_11+d_r_C_12+d_r_C_13)*al;
J_7_p(1,j) = (d_r_C_11+d_r_C_12+d_r_C_13)*al + (C_11+C_12+C_13)*d_r_al;
J_8(1,j) = C_11+C_12+C_13;
J_8_p(1,j) = (C_11+C_12+C_13)*al;
J_9(1,j) = ro;
J_10(1,j) = C_12;
J_11(1,j) = d_r_C_55+(C_55/r(1,j));
J_12(1,j) = d_r_C_55+((C_23+C_55)/r(1,j));
J_13(1,j) = C_23/r(1,j);

   end
end

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
%      r(i)=0.5*(1-cos((i-1)*pi/(N-1)))+1e-10; %r1(i,1)=r(i); 
     r(i)=0.5*(1-cos((i-1)*pi/(N-1)))+eps; %r1(i,1)=r(i);
     
L_1(1,j) = (ka*1^(-12))/r(1,j);
L_2(1,j) = ka;
L_3(1,j) = 0;
L_4(1,j) = ro*Sc;

J_1(1,j) = C_11;
J_2(1,j) = d_r_C_11+(C_11/r(1,j));
J_3(1,j) = C_55;
J_4(1,j) = d_r_C_12/r(1,j)-(C_22/(r(1,j)*r(1,j)));
J_5(1,j) = d_r_C_13+((C_13-C_23)/r(1,j));
J_6(1,j) = C_55+C_13;
J_7(1,j) = (d_r_C_11+d_r_C_12+d_r_C_13)*al;
J_7_p(1,j) = (d_r_C_11+d_r_C_12+d_r_C_13)*al + (C_11+C_12+C_13)*d_r_al;
J_8(1,j) = C_11+C_12+C_13;
J_8_p(1,j) = (C_11+C_12+C_13)*al;
J_9(1,j) = ro;
J_10(1,j) = C_12;
J_11(1,j) = d_r_C_55+(C_55/r(1,j));
J_12(1,j) = d_r_C_55+((C_23+C_55)/r(1,j));
J_13(1,j) = C_23/r(1,j);

    else 
       r(i)=0.5*(1-cos((i-1)*pi/(N-1))); %r1(i,1)=r(i);  
       
    
L_1(1,j) = (ka*1^(-12))/r(1,j);
L_2(1,j) = ka;
L_3(1,j) = 0;
L_4(1,j) = ro*Sc;

J_1(1,j) = C_11;
J_2(1,j) = d_r_C_11+(C_11/r(1,j));
J_3(1,j) = C_55;
J_4(1,j) = d_r_C_12/r(1,j)-(C_22/(r(1,j)*r(1,j)));
J_5(1,j) = d_r_C_13+((C_13-C_23)/r(1,j));
J_6(1,j) = C_55+C_13;
J_7(1,j) = (d_r_C_11+d_r_C_12+d_r_C_13)*al;
J_7_p(1,j) = (d_r_C_11+d_r_C_12+d_r_C_13)*al + (C_11+C_12+C_13)*d_r_al;
J_8(1,j) = C_11+C_12+C_13;
J_8_p(1,j) = (C_11+C_12+C_13)*al;
J_9(1,j) = ro;
J_10(1,j) = C_12;
J_11(1,j) = d_r_C_55+(C_55/r(1,j));
J_12(1,j) = d_r_C_55+((C_23+C_55)/r(1,j));
J_13(1,j) = C_23/r(1,j);

   end
end


L_1 ;
L_2 ;
L_3 ;
L_4 ;

J_1 ;
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

%% Weight functions
  %function [A_r,B_r]=WEIGHT(N) %% r direction
 A_r=zeros(N);
 B_r=zeros(N);
 r=zeros(1,N);
 
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




%% Boundry conditions types

%%%---------------Mechanical---------------

%%% (r)diretion normal stress:

% C_rz_rrNS*U_W - J_8_p*Dlt_T = 0;

%%% (z)diretion normal stress:

% C_rz_zzNS*U_W - J_8_p*Dlt_T = 0;


%%% (r)plan (z)diretion shear stress:

% C_rz_rzSS*U_W = 0;

%%% at z=0 and z=L:

% u=0;
 %or
% C_rz_rzSS*U_W = 0;

% w=0;
 %or
% C_rz_zzNS*U_W - J_8_p*Dlt_T = 0;

%%% at r=R_i:

% C_rz_rzSS*U_W = 0;
% C_rz_rrNS*U_W - J_8_p*Dlt_T = -P_i;


%%%---Clasical Boundry conditions---

%%% Simply support

% u=0;
% C_rz_zzNS*U_W - J_8_p*Dlt_T = 0;

%%% Free

% C_rz_rzSS*U_W = 0;
% C_rz_zzNS*U_W - J_8_p*Dlt_T = 0;

%%% clamped

% u=0;
% w=0;





% clamped boundry condition is equall to 1
% Simply support boundry condition is equall to 2
% Free boundry condition is equall to 3

% boundry_condition=1;

%%%---------------Thermal---------------

%%% 1-Known temperature on all sides.
%%% 2-Known temperature on some sides and zero heat flex on other sides.


%%% Type 1 :
 T_UP    = 1400 ;  %% Positive z direction
 T_DOWN  = 1400 ;  %% Negative z direction
 T_LEFT  = 400 ;  %% Negative r direction
 T_RIGHT = 400 ;  %% Positive r direction

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




%%


% C_T = L_1*A_r_new+L_2*B_r_new+L_3*A_z_new+L_2*B_z_new;

% C_r_U = J_2*A_r_new+J_1*B_r_new+J_3*B_z_new+J_4*eye(NM);
% C_r_W = J_5*A_z_new+J_6*(A_r_new*A_z_new);
% 
% C_r_Dlt_T = J_7_p*eye(NM)+J_8_p*A_r_new;
% C_z_Dlt_T = J_8_p*A_z_new;
% 
% C_z_U = J_12*A_z_new;
% C_z_W = J_6*(A_r_new*A_z_new)+J_11*A_r_new+J_3*B_r_new+J_1*B_z_new;
% 
% C_rz_U = C_r_U+C_z_U;
% C_rz_W = C_r_W+C_z_W;
% 
% C_r = zeros(2*NM);
% C_r(1:NM,1:NM) = C_r_U;
% C_r((NM+1):(2*NM),(NM+1):(2*NM)) = C_r_W;
% 
% C_z = zeros(2*NM);
% C_z(1:NM,1:NM) = C_z_U;
% C_z((NM+1):(2*NM),(NM+1):(2*NM)) = C_z_W;
% 
% C_rz = C_r+C_z;
% 
% C_rz_Dlt_T = zeros(2*NM);
% C_rz_Dlt_T(1:NM,1:NM) = C_r_Dlt_T;
% C_rz_Dlt_T((NM+1):(2*NM),(NM+1):(2*NM)) = C_z_Dlt_T;


I_J13=zeros(N);
I=eye(N);
for i=1:N
    I_J13(i,:) = J_13(1,i)*I(i,:);       
end
for i=0:(M-1)
    I_new_J13((i*N+1):(i*N+N),(i*N+1):(i*N+N)) =I_J13(1:N,:);
 end
I_new_J13;

C_r_rrNS = J_1(1,1)*A_r_new+I_new_J13;
C_z_rrNS = J_10(1,1)*A_z_new;

C_r_zzNS = J_10(1,1)*A_r_new+I_new_J13;
C_z_zzNS = J_1(1,1)*A_z_new;

C_r_rzSS = J_3(1,1)*A_z_new;
C_z_rzSS = J_3(1,1)*A_r_new;

% C_r_rzSS = A_z_new;
% C_z_rzSS = A_r_new;
 
% C_rz_rrNS = zeros(2*NM);
% C_rz_rrNS(1:NM,1:NM) = C_r_rrNS;
% C_rz_rrNS((NM+1):(2*NM),(NM+1):(2*NM)) = C_z_rrNS;

% C_rz_zzNS = zeros(2*NM);
% C_rz_zzNS(1:NM,1:NM) = C_r_zzNS;
% C_rz_zzNS((NM+1):(2*NM),(NM+1):(2*NM)) = C_z_zzNS;




  
 %%  Boundry conditions implantation
 
 %%%---------------Mechanical---------------
 
 A_r_J2=zeros(N);
for i=1:N
    A_r_J2(i,:) = J_2(1,i)*A_r(i,:);        
end

for i=0:(M-1)
    A_r_new_J2((i*N+1):(i*N+N),(i*N+1):(i*N+N)) = A_r_J2(1:N,1:N);
 end
A_r_new_J2;

C_r_U_1 = A_r_new_J2;
C_r_U_2 = J_1(1,1)*B_r_new;
C_r_U_3 = J_3(1,1)*B_z_new;

I_J4=zeros(N);
I=eye(N);
for i=1:N
    I_J4(i,:) = J_4(1,i)*I(i,:);     
end

for i=0:(M-1)
    I_new_J4((i*N+1):(i*N+N),(i*N+1):(i*N+N)) = I_J4(1:N,1:N);
 end
I_new_J4;

C_r_U_4 = I_new_J4;

C_r_U = C_r_U_1+C_r_U_2+C_r_U_3+C_r_U_4;


C_r_W_1 = J_5(1,1)*A_z_new;
C_r_W_2 = J_6(1,1)*(A_r_new*A_z_new);

C_r_W= C_r_W_1+C_r_W_2;


A_z_new_J12 = zeros(NM,NM); 
k=0;
for j=1:N
    for i=0:(M-1)
      A_z_new_J12((i*N+1)+k,:) = J_12(1,j)*A_z_new((i*N+1)+k,:);
    end
    k=k+1;
end

C_z_U_1 = A_z_new_J12;
C_z_U_2 = J_6(1,1)*(A_r_new*A_z_new);


C_z_U = C_z_U_1+C_z_U_2;




 A_r_J11=zeros(N);
for i=1:N
    A_r_J11(i,:) = J_11(1,i)*A_r(i,:);        
end

for i=0:(M-1)
    A_r_new_J11((i*N+1):(i*N+N),(i*N+1):(i*N+N)) = A_r_J11(1:N,1:N);
 end
A_r_new_J11;
 
C_z_W_1 = A_r_new_J11;
C_z_W_2 = J_3(1,1)*B_r_new;
C_z_W_3 = J_1(1,1)*B_z_new;

C_z_W = C_z_W_1+C_z_W_2+C_z_W_3;
 




C_rz_U = C_r_U+C_z_U;
C_rz_W = C_r_W+C_z_W;

C_rz_UW(1:NM,1:NM) = C_r_U;
C_rz_UW(1:NM,(NM+1):(2*NM)) = C_r_W;
C_rz_UW((NM+1):(2*NM),(NM+1):(2*NM)) = C_z_W;
C_rz_UW((NM+1):(2*NM),1:NM) = C_z_U;





K_U(1:NM,1:NM) = C_r_U;
K_U(1:NM,(NM+1):(2*NM)) = C_r_W;

K_W(1:NM,1:NM) = C_z_U;
K_W(1:NM,(NM+1):(2*NM)) = C_z_W;

%%%--- U


%%%--- Negative r direction

if boundry_condition~=4

for i=0:(M-1)
    K_U((i*N+1),1:NM)=C_r_rrNS((i*N+1),:);
end
for i=0:(M-1)
    K_U((i*N+1),NM+1:2*NM)=C_z_rrNS((i*N+1),:);
end

elseif boundry_condition==4 %fully clamped

for i=0:(M-1)
    K_U((i*N+1),:)=0;
end
for i=0:(M-1)
    K_U((i*N+1),(i*N+1))=1;
end

end
    
%%%--- Positive r direction 

if boundry_condition~=4

for i=1:M
    K_U((i*N),1:NM)=C_r_rrNS((i*N),:);
end
for i=1:M
    K_U((i*N),NM+1:2*NM)=C_z_rrNS((i*N),:);
end

elseif boundry_condition==4 %fully clamped

for i=1:M
    K_U((i*N),:)=0;
end
for i=1:M
    K_U((i*N),(i*N))=1;
end

end

%%%--- Negative z direction

if boundry_condition==1 %clamp
    
K_U(1:N,:)=0;
for i=1:N
    K_U(i,i)=1;
end
K_U(1:N,:)=0;
for i=1:N
    K_U(i,i)=1;
end 

elseif boundry_condition==2 %simply
 
K_U(1:N,:)=0;
for i=1:N
    K_U(i,i)=1;
end 

elseif boundry_condition==3 %free
   
for i=1:N
    K_U(i,1:NM)=C_r_rzSS(i,:);
end
for i=1:N
    K_U(i,NM+1:2*NM)=C_z_rzSS(i,:);
end

elseif boundry_condition==4 %fully clamped

K_U(1:N,:)=0;
for i=1:N
    K_U(i,i)=1;
end 

end


%%%--- Positive z direction 

if boundry_condition==1 %clamp

K_U((NM-N)+1:NM,:)=0;
for i=(NM-N)+1:NM
    K_U(i,i)=1;
end 

elseif boundry_condition==2 %simply

K_U((NM-N)+1:NM,:)=0;
for i=(NM-N)+1:NM
    K_U(i,i)=1;
end 

elseif boundry_condition==3 %free
    
for i=(NM-N)+1:NM
    K_U(i,1:NM)=C_r_rzSS(i,:);
end
for i=(NM-N)+1:NM
    K_U(i,NM+1:2*NM)=C_z_rzSS(i,:);
end

elseif boundry_condition==4 %fully clamped

K_U((NM-N)+1:NM,:)=0;
for i=(NM-N)+1:NM
    K_U(i,i)=1;
end
    
end



%%%--- W


%%%--- Negative r direction

if boundry_condition~=4

for i=0:(M-1)
    K_W((i*N+1),1:NM)=C_r_rrNS((i*N+1),:)+C_r_rzSS((i*N+1),:);
end
for i=0:(M-1)
    K_W((i*N+1),NM+1:2*NM)=C_z_rrNS((i*N+1),:)+C_z_rzSS((i*N+1),:);
end

elseif boundry_condition==4 %fully clamped

for i=0:(M-1)
    K_W((i*N+1),:)=0;
end
for i=0:(M-1)
    K_W((i*N+1),(i*N+1)+NM)=1;
end
    
end


%%%--- Positive r direction 

if boundry_condition~=4

for i=1:M
    K_W((i*N),1:NM)=C_r_rzSS((i*N),:);
end
for i=1:M
    K_W((i*N),NM+1:2*NM)=C_z_rzSS((i*N),:);
end

elseif boundry_condition==4 %fully clamped

for i=1:M
    K_W((i*N),:)=0;
end
for i=1:M
    K_W((i*N),(i*N)+NM)=1;
end
    
end

%%%--- Negative z direction

if boundry_condition==1 %clamp
    
K_W(1:N,:)=0;
for i=1:N
    K_W(i,i+NM)=1;
end 

elseif boundry_condition==2 %simply
 
for i=1:N
    K_W(i,1:NM)=C_r_zzNS(i,:);
end
for i=1:N
    K_W(i,NM+1:2*NM)=C_z_zzNS(i,:);
end

elseif boundry_condition==3 %free
   
for i=1:N
    K_W(i,1:NM)=C_r_zzNS(i,:);
end
for i=1:N
    K_W(i,NM+1:2*NM)=C_z_zzNS(i,:);
end

elseif boundry_condition==4 %fully clamped

K_W(1:N,:)=0;
for i=1:N
    K_W(i,i+NM)=1;
end
    
end


%%%--- Positive z direction 

if boundry_condition==1 %clamp

K_W((NM-N)+1:NM,:)=0;
for i=(NM-N)+1:NM
    K_W(i,i+NM)=1;
end 

elseif boundry_condition==2 %simply
    
for i=(NM-N)+1:NM
    K_W(i,1:NM)=C_r_zzNS(i,:);
end
for i=(NM-N)+1:NM
    K_W(i,NM+1:2*NM)=C_z_zzNS(i,:);
end

elseif boundry_condition==3 %free
    
for i=(NM-N)+1:NM
    K_W(i,1:NM)=C_r_zzNS(i,:);
end
for i=(NM-N)+1:NM
    K_W(i,NM+1:2*NM)=C_z_zzNS(i,:);
end
  
%privent solid body motin 

K_W((NM-N)+1,:)=0;
K_W((NM-N)+1,(NM-N)+1+NM)=1;

% K_W(NM,:)=0;
% K_W(NM,NM+NM)=1;

elseif boundry_condition==4 %fully clamped

K_W((NM-N)+1:NM,:)=0;
for i=(NM-N)+1:NM
    K_W(i,i+NM)=1;
end 

end


K(1:NM,:)=K_U;
K((NM+1):(2*NM),:)=K_W;





 %%%---------------Thermal---------------

 
 %%% Type 1 :


 
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

 
 
C_T;
T = (C_T^(-1))*d;
T = reshape(T,N,M);
T = T';




 C_T_test = B_r_new+B_z_new;
 
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
T_test_real = (T_test)';


%%% Type 2 :

d = zeros(N,M); 

d(1,2:(M-1))=T_i;
d(N,2:(M-1))=(T_Amb);
d((2:N-1),1)=0;
d((2:N-1),M)=0;
d(1,1)=0.5*(T_i+0);
d(1,M)=0.5*(T_i+0);
d(N,1)=0.5*((T_Amb)+0);
d(N,M)=0.5*((T_Amb)+0);



d;
% d';
d = reshape(d,NM,[]);



A_r_L1=zeros(N);
for i=1:N

    A_r_L1(i,:) = L_1(1,i)*A_r(i,:);
         
end
A_r_L1(N,:) = 0;
A_r_L1(N,:) = (ka/Ch)*A_r(N,:)+1;

for i=0:(M-1)
    A_r_new_L1((i*N+1):(i*N+N),(i*N+1):(i*N+N)) = A_r_L1(1:N,1:N);
 end
A_r_new_L1;

C_T_1 = A_r_new_L1;


%%%--- Negative z direction

C_T_1(1:N,:)=0;


%%%--- Positive z direction 

C_T_1((NM-N):NM,:)=0;


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




C_T_2 = L_2(1,1)*B_r_new;



%%%--- Negative z direction

C_T_2(1:N,:)=0;


%%%--- Positive z direction 

C_T_2((NM-N):NM,:)=0;


%%%--- Negative r direction

  for i=1:(M-2)
      C_T_2((i*N+1),:)=0;
  end

  
%%%--- Positive r direction 

  for i=2:(M-1)
      C_T_2((i*N),:)=0;
  end

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
 
  
%%%--- Negative r direction

  for i=1:(M-2)
      C_T_3((i*N+1),:)=0;
  end

  
%%%--- Positive r direction 

  for i=2:(M-1)
      C_T_3((i*N),:)=0;
  end

C_T_3;
C_T_3(1,:) = 0;
C_T_3(1,1) = 1;
C_T_3(NM-N+1,:) = 0;
C_T_3(NM-N+1,NM-N+1) = 1;




C_T_4 = L_2(1,1)*B_z_new;



%%%--- Negative z direction

C_T_4(1:N,:)=0;


%%%--- Positive z direction 

C_T_4((NM-N):NM,:)=0;


%%%--- Negative r direction

  for i=1:(M-2)
      C_T_4((i*N+1),:)=0;
  end

  
%%%--- Positive r direction 

  for i=2:(M-1)
      C_T_4((i*N),:)=0;
  end

C_T_4;



C_T = C_T_1+C_T_2+C_T_3+C_T_4;







det_C_T = det(C_T);
 
 
C_T;
T = (C_T^(-1))*d;
% T = C_T \ d;
T_calc = reshape(T,N,M);
T_real = T_calc';




%%



C_r_Dlt_T_1 =J_7_p(1,1)*eye(NM);
C_r_Dlt_T_2 =J_8_p(1,1)*A_r_new;

C_r_Dlt_T = C_r_Dlt_T_1 + C_r_Dlt_T_2;

C_z_Dlt_T_1 = J_8_p(1,1)*A_z_new;

C_z_Dlt_T = C_z_Dlt_T_1;


C_rz_Dlt_T = zeros(2*NM);
C_rz_Dlt_T(1:NM,1:NM) = C_r_Dlt_T;
C_rz_Dlt_T((NM+1):(2*NM),(NM+1):(2*NM)) = C_z_Dlt_T;



T_test_real;
% T = T_test;

T_real;
T = T_calc;


Dlt_T = T-T_Amb;
Dlt_T_rea=Dlt_T';

Dlt_T_r_new = reshape(Dlt_T,NM,1);
Dlt_T_z_new = reshape(Dlt_T,NM,1);
Dlt_T_new = reshape(Dlt_T,NM,1);






%%% known matrices

C_r_Dlt_T_1 =J_7_p(1,1)*eye(NM);
C_r_Dlt_T_2 =J_8_p(1,1)*A_r_new;

C_r_Dlt_T = C_r_Dlt_T_1 + C_r_Dlt_T_2;

C_z_Dlt_T_1 = J_8_p(1,1)*A_z_new;

C_z_Dlt_T = C_z_Dlt_T_1;




% C_r_Dlt_T; %(NM,NM)
% C_z_Dlt_T; %(NM,NM)
% Dlt_T_r_new; %(NM,1)
% Dlt_T_z_new; %(NM,1)


known_Dlt_T_r = C_r_Dlt_T*Dlt_T_r_new;
known_Dlt_T_z = C_z_Dlt_T*Dlt_T_z_new;



%%%--- U

%%%--- Negative r direction

if boundry_condition~=4
    
for i=0:(M-1)
    known_Dlt_T_r((i*N+1),:)=J_8_p(1,1)*Dlt_T_new((i*N+1),:)-p_i;
end

elseif boundry_condition==4 %fully clamped
    
for i=0:(M-1)
    known_Dlt_T_r((i*N+1),:)=0;
end  
    
end   

%%%--- Positive r direction 

if boundry_condition~=4

for i=1:M
    known_Dlt_T_r((i*N),:)=J_8_p(1,1)*Dlt_T_new((i*N),:);
end

elseif boundry_condition==4 %fully clamped

for i=1:M
    known_Dlt_T_r((i*N),:)=0;
end
    
end
    
%%%--- Negative z direction

if boundry_condition==1 %clamp
    
known_Dlt_T_r(1:N,:)=0;

elseif boundry_condition==2 %simply
 
% for i=1:N
%     known_Dlt_T_r(i,:)=J_8_p(1,1)*Dlt_T_new(i,:);
% end

known_Dlt_T_r(1:N,:)=0;

elseif boundry_condition==3 %free
   
% for i=1:N
%     known_Dlt_T_r(i,:)=0;%J_8_p(1,1)*Dlt_T_new(i,:);
% end

known_Dlt_T_r(1:N,:)=0;

elseif boundry_condition==4 %fully clamped

known_Dlt_T_r(1:N,:)=0;

end


%%%--- Positive z direction 

if boundry_condition==1 %clamp

known_Dlt_T_r((NM-N)+1:NM,:)=0;

elseif boundry_condition==2 %simply
    
% for i=(NM-N)+1:NM
%     known_Dlt_T_r(i,:)=J_8_p(1,1)*Dlt_T_new(i,1);
% end

known_Dlt_T_r((NM-N)+1:NM,:)=0;

elseif boundry_condition==3 %free
    
% for i=(NM-N)+1:NM
%     known_Dlt_T_r(i,:)=0; %J_8_p(1,1)*Dlt_T_new(i,1);
% end
 
known_Dlt_T_r((NM-N)+1:NM,:)=0;

elseif boundry_condition==4 %fully clamped

known_Dlt_T_r((NM-N)+1:NM,:)=0;

end



%%%--- W


%%%--- Negative r direction

if boundry_condition~=4

for i=0:(M-1)
    known_Dlt_T_z((i*N+1),:)=0;%J_8_p(1,1)*Dlt_T_new((i*N+1),:)-p_i;
end

elseif boundry_condition==4 %fully clamped

for i=0:(M-1)
    known_Dlt_T_z((i*N+1),:)=0;
end
    
end
    
%%%--- Positive r direction 

if boundry_condition~=4

for i=1:M
    known_Dlt_T_z((i*N),:)=0;%J_8_p(1,1)*Dlt_T_new((i*N),:);
end

elseif boundry_condition==4 %fully clamped

for i=1:M
    known_Dlt_T_z((i*N),:)=0;
end    
    
end
    
%%%--- Negative z direction

if boundry_condition==1 %clamp
    
known_Dlt_T_z(1:N,:)=0;

elseif boundry_condition==2 %simply
 
for i=1:N
    known_Dlt_T_z(i,:)=J_8_p(1,1)*Dlt_T_new(i,:);
end

% known_Dlt_T_z(1:N,:)=0;

elseif boundry_condition==3 %free
   
for i=1:N
    known_Dlt_T_z(i,:)=J_8_p(1,1)*Dlt_T_new(i,:);
end

elseif boundry_condition==4 %fully clamped

known_Dlt_T_z(1:N,:)=0;
    
end


%%%--- Positive z direction 

if boundry_condition==1 %clamp

known_Dlt_T_z((NM-N)+1:NM,:)=0;

elseif boundry_condition==2 %simply
    
for i=(NM-N)+1:NM
    known_Dlt_T_z(i,:)=J_8_p(1,1)*Dlt_T_new(i,:);
end

% known_Dlt_T_z((NM-N)+1:NM,:)=0;

elseif boundry_condition==3 %free
    
for i=(NM-N)+1:NM
    known_Dlt_T_z(i,:)=J_8_p(1,1)*Dlt_T_new(i,:);
end
 
%privent solid body motion
% known_Dlt_T_z((NM-N)+1:NM,:)=0;

known_Dlt_T_z((NM-N)+1,:)=0;
% known_Dlt_T_z(NM,:)=0;

elseif boundry_condition==4 %fully clamped

known_Dlt_T_z((NM-N)+1:NM,:)=0;

end








re_known_Dlt_T_r=reshape(known_Dlt_T_r,N,M);
re_known_Dlt_T_r=re_known_Dlt_T_r';
re_known_Dlt_T_z=reshape(known_Dlt_T_z,N,M);
re_known_Dlt_T_z=re_known_Dlt_T_z';



Dlt_T_rz_new = zeros(2*NM,1);
Dlt_T_rz_new(1:NM,1) = Dlt_T_r_new;+Dlt_T_z_new;
Dlt_T_rz_new((NM+1):(2*NM),1) = Dlt_T_z_new;+Dlt_T_r_new;

Dlt_T_rz_new;

Dlt_T_rz_new = reshape(Dlt_T_rz_new,N,2*M);

C_rz_Dlt_T;


known_Dlt_T_rz = zeros(2*NM,1);
known_Dlt_T_rz(1:NM,1) = known_Dlt_T_r;
known_Dlt_T_rz((NM+1):(2*NM),1) = known_Dlt_T_z;







% UW = K^(-1)*known_Dlt_T_rz;
UW = K\known_Dlt_T_rz;













U = UW(1:NM,1);

U_calc = reshape(U,N,M);
U_real =U_calc'


W = UW(NM+1:2*NM,1);

W_calc = reshape(W,N,M);
W_real =W_calc'






