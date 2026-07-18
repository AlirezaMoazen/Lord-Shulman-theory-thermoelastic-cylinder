
clc,clear;
% Complete material properties whit assuming of GPL and pores distribution patterns
% Untitled_Complete_material_properties_whit_assuming_of_GPL_and_pores_distribution_patterns

NL=5;
N=17;

%% Legend

%%% e : Layer number

%%% NL : Number of layers

%%% h : Thickness of cylinder(R_o-R_i)or(Lt*NL)

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

% Ch=10;

%%


% e=0.7404;


%%

% r=zeros(1,N);
% for i=1:N
%         r(i)=0.5*(1-cos((i-1)*pi/(N-1))); %r1(i,1)=r(i); 
%  end
%  r;

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

Lt=1;
R_i=1;
R_o = R_i+Lt*NL;


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
    
    e_1=0.1;
    e_2=0.1738;
    e_4=0;
    e_5=0;
    
    
elseif e_3==0.8716
    
    e_1=0.2;
    e_2=0.3442;
    e_4=0;
    e_5=0;
    
    
elseif e_3==0.8064
    
    e_1=0.3;
    e_2=0.5103;
    e_4=0;
    e_5=0;
    
   
elseif e_3==0.7404
    
    e_1=0.4;
    e_2=0.6708;
    e_4=0;
    e_5=0;
    
    
 elseif e_3==0.6733
    
    e_1=0.5;
    e_2=0.8231;
    e_4=0;
    e_5=0;
    
       
elseif e_3==0.6047
    
    e_1=0.6;
    e_2=0.9612;
    e_4=0;
    e_5=0;
    
    
end

h = R_o-R_i;
% Lt = h/NL;

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
      e_1_m=(1-sqrt(1-e_1*cos(pi*r_m/h)))/cos(pi*r_m/h);
      P_O = 1-e_1*cos(pi*r_m/h);
      P_O_m = 1-e_1_m*cos(pi*r_m/h);

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
      e_2_m=(1-sqrt(1-e_2*(1-cos(pi*r_m/h))))/(1-cos(pi*r_m/h));
      P_X = 1-e_2*(1-cos(pi*r_m/h));
      P_X_m = 1-e_2_m*(1-cos(pi*r_m/h));

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
      e_4_m=(sqrt(e_4*cos(pi*r_m/2*h+pi/4)))/(e_4*cos(pi*r_m/2*h+pi/4));
      P_V = e_4*cos(pi*r_m/2*h+pi/4);
      P_V_m = e_4_m*cos(pi*r_m/2*h+pi/4);

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
      e_5_m=(sqrt(e_5*cos(pi*r_m/2*h+5*pi/4)))/(e_5*cos(pi*r_m/2*h+5*pi/4));
      P_A = e_5*cos(pi*r_m/2*h+5*pi/4);
      P_A_m = e_5_m*cos(pi*r_m/2*h+5*pi/4);
      
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







