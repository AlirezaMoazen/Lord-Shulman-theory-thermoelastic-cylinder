
clc,clear;
% Complete material properties whit assuming of GPL and pores distribution patterns, thermo-elastic coefficients,
% motion equations coefficients, heat transfer equation coefficient
 
% Untitled_Complete_material_properties_whit_assuming_of_GPL_and_pores_distribution_patterns

NL=5;
N=7;


R_i=15;
Lt=10;
R_o=R_i+NL*Lt;

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

% Lt=1;
% R_i=1;
% R_o = R_i+Lt*NL;


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
    e_4=NaN;
    e_5=NaN;
    
    
elseif e_3==0.8716
    
    e_1=0.2;
    e_2=0.3442;
    e_4=NaN;
    e_5=NaN;
    
    
elseif e_3==0.8064
    
    e_1=0.3;
    e_2=0.5103;
    e_4=NaN;
    e_5=NaN;
    
   
elseif e_3==0.7404
    
    e_1=0.4;
    e_2=0.6708;
    e_4=NaN;
    e_5=NaN;
    
    
 elseif e_3==0.6733
    
    e_1=0.5;
    e_2=0.8231;
    e_4=NaN;
    e_5=NaN;
    
       
elseif e_3==0.6047
    
    e_1=0.6;
    e_2=0.9612;
    e_4=NaN;
    e_5=NaN;
    
    
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

d_r_al=0;




%% 

C_11 = zeros(1,NL);
C_22 = zeros(1,NL);
C_12 = zeros(1,NL);
C_23 = zeros(1,NL);
C_13 = zeros(1,NL);
C_55 = zeros(1,NL);

for j=1:NL
    
C_11(1,j)=((1-nu(1,j))*Ym(1,j))/((1+nu(1,j))*(1-(2*nu(1,j))));
d_r_C_11=0;
C_22(1,j)=((1-nu(1,j))*Ym(1,j))/((1+nu(1,j))*(1-(2*nu(1,j))));
% d_r_C_22=0;
% C_33=((1-nu)*Ym)/((1+nu)*(1-(2*nu)));
% d_r_C_33=0;

C_12(1,j)=(nu(1,j)*Ym(1,j))/((1+nu(1,j))*(1-(2*nu(1,j))));
d_r_C_12=0;
C_23(1,j)=(nu(1,j)*Ym(1,j))/((1+nu(1,j))*(1-(2*nu(1,j))));
C_13(1,j)=(nu(1,j)*Ym(1,j))/((1+nu(1,j))*(1-(2*nu(1,j))));
d_r_C_13=0;

C_55(1,j)=(Ym(1,j))/(2*(1+nu(1,j)));
d_r_C_55=0;

end




%%

L_1 = zeros(1,N);
L_2 = zeros(1,NL);
L_3 = zeros(1,NL);
L_4 = zeros(1,NL);

J_1 = zeros(1,NL);
J_2 = zeros(1,N);
J_3 = zeros(1,NL);
J_4 = zeros(1,N);
J_5 = zeros(1,N);
J_6 = zeros(1,NL);
J_7 = zeros(1,NL);
J_7_p = zeros(1,NL);
J_8 = zeros(1,NL);
J_8_p = zeros(1,NL);
J_9 = zeros(1,NL);
J_10 = zeros(1,NL);
J_11 = zeros(1,N);
J_12 = zeros(1,N);
J_13 = zeros(1,N);






for j=1:NL
        
L_2(1,j) = ka(1,j);
L_3(1,j) = 0;
L_4(1,j) = ro(1,j)*Sc(1,j);

J_1(1,j) = C_11(1,j);
J_3(1,j) = C_55(1,j);
J_6(1,j) = C_55(1,j)+C_13(1,j);
J_7(1,j) = (d_r_C_11+d_r_C_12+d_r_C_13)*al(1,j);
J_7_p(1,j) = (d_r_C_11+d_r_C_12+d_r_C_13)*al(1,j) + (C_11(1,j)+C_12(1,j)+C_13(1,j))*d_r_al;
J_8(1,j) = C_11(1,j)+C_12(1,j)+C_13(1,j);
J_8_p(1,j) = (C_11(1,j)+C_12(1,j)+C_13(1,j))*al(1,j);
J_9(1,j) = ro(1,j);
J_10(1,j) = C_12(1,j);


end




%%


r_l=zeros(1,N);
r_G=zeros(1,N*NL);

for i=1:N
    r_l(i)=0.5*(1-cos((i-1)*pi/(N-1)));
  
end
for j=0:NL-1
    co((j*N+1):(j*N+N))=r_l(1:N)+j;
    co_b=co*Lt;
    co_r=co_b+R_i;
    r_G=co_r;
               
end


r_G_bar = (r_G-R_i)/(NL*Lt);





 for i=0:NL-1
     
     r(1:N)=r_G_bar((i*N+1):(i*N+N)); 
 
 r;
  if r(1,1)==0
      r(1,1)=eps;
     
  end
  r;
  
  for j=1:N
 
        L_1(1,j) = (ka(1,i+1)*1^(-12))/r(1,j);
        
        J_2(1,j) = d_r_C_11+(C_11(1,i+1)/r(1,j));
        J_4(1,j) = d_r_C_12/r(1,j)-(C_22(1,i+1)/(r(1,j)*r(1,j)));
        J_5(1,j) = d_r_C_13+((C_13(1,i+1)-C_23(1,i+1))/r(1,j));
        J_11(1,j) = d_r_C_55+(C_55(1,i+1)/r(1,j));
        J_12(1,j) = d_r_C_55+((C_23(1,i+1)+C_55(1,i+1))/r(1,j));
        J_13(1,j) = C_23(1,i+1)/r(1,j);
 
  end   
  
  L_1_G(:,(i*N+1):(i*N+N)) = L_1(:,:);
  
  J_2_G(:,(i*N+1):(i*N+N)) = J_2(:,:);
  J_4_G(:,(i*N+1):(i*N+N)) = J_4(:,:);
  J_5_G(:,(i*N+1):(i*N+N)) = J_5(:,:);
  J_11_G(:,(i*N+1):(i*N+N)) = J_11(:,:);
  J_12_G(:,(i*N+1):(i*N+N)) = J_12(:,:);
  J_13_G(:,(i*N+1):(i*N+N)) = J_13(:,:);    
      
 
 end



















