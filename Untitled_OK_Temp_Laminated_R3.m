
clc,clear;
% function [T,N,M] = Displacements(r,z,t)


%% Number of nodes
 N=3;  %% r direction(one element or one layer)
 M=5;  %% z direction
 NM = N*M;
  
 NL=3;
 N_G = N*NL;
 NM_G = NM*NL;
 
 R_i=15;
 Lt=10;
 R_o=R_i+NL*Lt;
 
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


% e=0.7404;


%%

r=zeros(1,N);
for i=1:N
        r(i)=0.5*(1-cos((i-1)*pi/(N-1))); %r1(i,1)=r(i); 
 end
 r;

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

Porosity_pattern=0;

%%
W_GPL=0.04;

vec_e_3=[0.9361;  %1
         0.8716;  %2
         0.8064;  %3
         0.7404;  %4
         0.6733;  %5
         0.6047]; %6
     
e_3 = vec_e_3(5,1);

% % Lt=1;
% % R_i=1;
% % R_o = R_i+Lt*NL;


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
    e_1=0.1; e_2=0.1738; e_4=NaN; e_5=NaN;
        
elseif e_3==0.8716
    e_1=0.2; e_2=0.3442; e_4=NaN; e_5=NaN;
        
elseif e_3==0.8064
    e_1=0.3; e_2=0.5103; e_4=NaN; e_5=NaN;
       
elseif e_3==0.7404
    e_1=0.4; e_2=0.6708; e_4=NaN; e_5=NaN;
        
 elseif e_3==0.6733
    e_1=0.5; e_2=0.8231; e_4=NaN; e_5=NaN;
           
elseif e_3==0.6047
    e_1=0.6; e_2=0.9612; e_4=NaN; e_5=NaN;
        
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




%% Elastic coefficients

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


% 
% 
% %% Weight functions
%   %function [A_r,B_r]=WEIGHT(N) %% r direction
%  A_r=zeros(N);
%  B_r=zeros(N);
%  r=zeros(1,N);
%  
%  for i=1:N
%         r(i)=0.5*(1-cos((i-1)*pi/(N-1))); %r1(i,1)=r(i); 
%  end
%  r;
%  for i=1:N
%     for j=1:N
%          qi_r=1;qj_r=1;
%        for k=1:N 
%           if k~=i  
%               qi_r=(r(i)-r(k))*qi_r;
%           end
%           if k~=j  
%               qj_r=(r(j)-r(k))*qj_r;
%           end   
%        end
%        if i~=j 
%            A_r(i,j)=qi_r/((r(i)-r(j))*qj_r);
%        end   
%     end  
%     for k=1:N  
%        if k~=i
%            A_r(i,i)=A_r(i,i)-A_r(i,k);
%        end
%     end
%  end
%  A_r;
%  for i=1:N
%     for j=1:N
%          B_r(i,j)=0;
%     end  
%  end      
%  for i=1:N
%     for j=1:N
%        if i~=j
%            B_r(i,j)=2*(A_r(i,i)*A_r(i,j)-(A_r(i,j)/(r(i)-r(j))));
%        end   
%     end      
%     for k=1:N
%        if i~=k
%            B_r(i,i)=B_r(i,i)-B_r(i,k);
%        end   
%     end    
%  end
%  B_r;
%        
%   %end
%    
%    
%    
%  %function [A_z,B_z]=WEIGHT(M) %% z direction
% A_z=zeros(M);
% B_z=zeros(M);
% z=zeros(1,M);
%  
%       for i=1:M
%         z(i)=0.5*(1-cos((i-1)*pi/(M-1))); %z1(i,1)=z(i); 
%       end
%        z;
%       for i=1:M
%          for j=1:M
%               qi_z=1;qj_z=1;
%             for k=1:M 
%                if k~=i  
%                   qi_z=(z(i)-z(k))*qi_z;
%                end
%                if k~=j  
%                   qj_z=(z(j)-z(k))*qj_z;
%                end   
%             end
%             if i~=j 
%                A_z(i,j)=qi_z/((z(i)-z(j))*qj_z);
%             end   
%          end  
%          for k=1:M  
%              if k~=i
%                 A_z(i,i)=A_z(i,i)-A_z(i,k);
%              end
%          end   
%       end
%       A_z;
%       for i=1:M
%          for j=1:M
%              B_z(i,j)=0;
%          end  
%       end      
%       for i=1:M
%          for j=1:M
%             if i~=j
%                B_z(i,j)=2*(A_z(i,i)*A_z(i,j)-(A_z(i,j)/(z(i)-z(j))));
%             end   
%          end      
%          for k=1:M
%             if i~=k
%                B_z(i,i)=B_z(i,i)-B_z(i,k);
%             end   
%          end    
%       end
%       B_z;
%       
%  %end
%   %% Modified Weight functions
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
% 
% 
%% Weight functions , Modified Weight functions & Global Weight functions



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


% for j=0:M-1
%     A_r_G_new((j*N*NL+i*N+1):(j*N*NL+i*N+N),(i*NM+j*N+1):(i*NM+j*N+N)) = A_r(1:N,1:N);
% end


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


% for j=0:M-1
%     B_r_G_new((j*N*NL+i*N+1):(j*N*NL+i*N+N),(i*NM+j*N+1):(i*NM+j*N+N)) = B_r(1:N,1:N);
% end



B_r_G(:,(i*N+1):(i*N+N))=B_r(:,:);

B_r_G_new((i*NM+1):(i*NM+NM),(i*NM+1):(i*NM+NM)) = B_r_new(1:NM,1:NM);

 end
 B_r_G;
 B_r_G_new;
 
 
 
 
 
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
 z;
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
 A_z_G;
 A_z_G_new;

 
%  for i=0:NL-1
%      for j=0:M-1
%          A_z_G_new((j*N*NL+i*N+1):(j*N*NL+i*N+N),:) = A_z_G_new1((i*NM+j*N+1):(i*NM+j*N+N),:);
% 
%      end
%  end
 
 

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
 B_z_G;
 B_z_G_new;


 
%  for i=0:NL-1
%      for j=0:M-1
%          B_z_G_new((j*N*NL+i*N+1):(j*N*NL+i*N+N),:) = B_z_G_new1((i*NM+j*N+1):(i*NM+j*N+N),:);
% 
%      end
%  end



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





% C_r_rrNS = J_1*A_r_new+J_13*eye(NM);
% C_z_rrNS = J_10*A_z_new;

% C_r_zzNS = J_10*A_r_new+J_13*eye(NM);
% C_z_zzNS = J_1*A_z_new;

% C_r_rzSS = A_z_new;
% C_z_rzSS = A_r_new;


 
% C_rz_rrNS = zeros(2*NM);
% C_rz_rrNS(1:NM,1:NM) = C_r_rrNS;
% C_rz_rrNS((NM+1):(2*NM),(NM+1):(2*NM)) = C_z_rrNS;

% C_rz_zzNS = zeros(2*NM);
% C_rz_zzNS(1:NM,1:NM) = C_r_zzNS;
% C_rz_zzNS((NM+1):(2*NM),(NM+1):(2*NM)) = C_z_zzNS;


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
 T_UP    = 400 ;  %% Positive z direction
 T_DOWN  = 500 ;  %% Negative z direction
 T_LEFT  = 600 ;  %% Negative r direction
 T_RIGHT = 300 ;  %% Positive r direction

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

%%% Type 3 :
%  T_Side_A = ;  %% Negative r direction
%  T_Side_B = ;  %% Positive z direction
%  T_Side_C = ;  %% Negative r direction
%  T_Side_D = ;  %% Positive z direction
%  Heat_flex_Side_A = ;  %% Negative r direction
%  Heat_flex_Side_B = ;  %% Positive z direction
%  Heat_flex_Side_C = ;  %% Negative r direction
%  Heat_flex_Side_D = ;  %% Positive z direction

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


% C_T = L_1*A_r_new+L_2*B_r_new+L_3*A_z_new+L_2*B_z_new;

% C_r_U = J_2*A_r_new+J_1*B_r_new+J_3*B_z_new+J_4*eye(NM);
% C_r_W = J_5*A_z_new+J_6*(A_r_new*A_z_new);
% 
% C_r_dl_T = J_7_p*eye(NM)+J_8_p*A_r_new;
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

    I_J4(i,:) = J_2(1,i)*I(i,:);
         
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


C_z_U_1 =0;
 



C_z_U = C_z_U_1;

C_z_W_1 = J_6(1,1)*(A_r_new*A_z_new);


 A_r_J11=zeros(N);
for i=1:N

    A_r_J11(i,:) = J_11(1,i)*A_r(i,:);
         
end

for i=0:(M-1)
    A_r_new_J11((i*N+1):(i*N+N),(i*N+1):(i*N+N)) = A_r_J11(1:N,1:N);
 end
A_r_new_J11;
 
C_z_W_2 = A_r_new_J11;
C_z_W_3 = J_3(1,1)*B_r_new;
C_z_W_4 = J_1(1,1)*B_z_new;

C_z_W = C_z_W_1+C_z_W_2+C_z_W_3+C_z_W_4;
 


C_rz_U = C_r_U+C_z_U;
C_rz_W = C_r_W+C_z_W;

C_r = zeros(2*NM);
C_r(1:NM,1:NM) = C_r_U;
C_r((NM+1):(2*NM),(NM+1):(2*NM)) = C_r_W;

C_z = zeros(2*NM);
C_z(1:NM,1:NM) = C_z_U;
C_z((NM+1):(2*NM),(NM+1):(2*NM)) = C_z_W;

C_rz = C_r+C_z;



 %%%---------------Thermal---------------

 %%% Type 1 :
%  
% 
%  
% T_Side_A = T_LEFT;
% T_Side_B = T_DOWN;
% T_Side_C = T_RIGHT;
% T_Side_D = T_UP;
% 
% d = zeros(N,M); 
% 
% d(1,2:(M-1))=T_Side_A;
% d(N,2:(M-1))=T_Side_C;
% d((2:N-1),1)=T_Side_D;
% d((2:N-1),M)=T_Side_B;
% d(1,1)=0.5*(T_Side_A+T_Side_D);
% d(1,M)=0.5*(T_Side_A+T_Side_B);
% d(N,M)=0.5*(T_Side_C+T_Side_B);
% d(N,1)=0.5*(T_Side_C+T_Side_D);
% 
% % d(1,1)=0.65*T_Side_A+0.35*T_Side_D;
% % d(1,M)=0.65*T_Side_A+0.35*T_Side_D;
% 
% d;
% d = reshape(d,NM,[]);
% 
% 
% %%% Type 1.a
% 
%  A_r_L1=zeros(N);
% for i=1:N
% 
%     A_r_L1(i,:) = L_1(1,i)*A_r(i,:);
%          
% end
% 
% for i=0:(M-1)
%     A_r_new_L1((i*N+1):(i*N+N),(i*N+1):(i*N+N)) = A_r_L1(1:N,1:N);
%  end
% A_r_new_L1;
% 
% C_T_1 = A_r_new_L1;
% C_T_2 = L_2(1,1)*B_r_new;
% C_T_3 = L_3(1,1)*A_z_new;
% C_T_4 = L_2(1,1)*B_z_new;
% 
% 
% C_T = C_T_1+C_T_2+C_T_3+C_T_4;
% 
% 
% 
% C_T(1:N,:)=0;
%   for i=1:N
%       C_T(i,i)=1;
%   end
% 
% 
% C_T((NM-N):NM,:)=0;
%   for i=(NM-N):NM
%       C_T(i,i)=1;
%   end
% 
%   
%   for i=1:(M-2)
%       C_T((i*N+1),:)=0;
%   end
%   for i=1:(M-2)
%       C_T((i*N+1),(i*N+1))=1;
%   end
%   
%   for i=2:(M-1)
%       C_T((i*N),:)=0;
%   end
%   for i=2:(M-1)
%       C_T((i*N),(i*N))=1;
%   end
% C_T;
% 
% det_C_T = det(C_T); 
%  
%  
% C_T;
% T = (C_T^(-1))*d;
% T = reshape(T,N,M);
% T = T'
% 
% 
% %%% Type 1.b
% 
% 
%  C_T_test = B_r_new+B_z_new;
%  
% C_T_test(1:N,:)=0;
%   for i=1:N
%       C_T_test(i,i)=1;
%   end
% 
% 
% C_T_test((NM-N):NM,:)=0;
%   for i=(NM-N):NM
%       C_T_test(i,i)=1;
%   end
% 
% 
%   for i=1:(M-2)
%       C_T_test((i*N+1),:)=0;
%   end
%   for i=1:(M-2)
%       C_T_test((i*N+1),(i*N+1))=1;
%   end
%   
%   for i=2:(M-1)
%       C_T_test((i*N),:)=0;
%   end
%   for i=2:(M-1)
%       C_T_test((i*N),(i*N))=1;
%   end
% C_T_test;
% 
% 
% C_T_test;
% T_test = (C_T_test^(-1))*d;
% T_test = reshape(T_test,N,M);
% T_test = (T_test)';
% 
% 
% %%% Type 2 :
% 
% d = zeros(N,M); 
% 
% d(1,2:(M-1))=T_i;
% d(N,2:(M-1))=(T_Amb);
% d((2:N-1),1)=0;
% d((2:N-1),M)=0;
% d(1,1)=0.5*(T_i+0);
% d(1,M)=0.5*(T_i+0);
% d(N,1)=0.5*((T_Amb)+0);
% d(N,M)=0.5*((T_Amb)+0);
% 
% 
% 
% d;
% d';
% d = reshape(d,NM,[]);
% 
% 
% 
% 
% A_r_L1=zeros(N);
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
% %%%--- Negative z direction
% 
% C_T_1(1:N,:)=0;
% %   for i=1:N
% %       C_T_1(i,i)=1;
% %   end
% 
% 
% %%%--- Positive z direction 
% 
% C_T_1((NM-N):NM,:)=0;
% %   for i=(NM-N):NM
% %       C_T_1(i,i)=1;
% %   end
% 
% 
% %%%--- Negative r direction
% 
%   for i=1:(M-2)
%       C_T_1((i*N+1),:)=0;
%   end
%   for i=1:(M-2)
%       C_T_1((i*N+1),(i*N+1))=1;
%   end
%   
%   
% %%%--- Positive r direction 
% 
%   for i=2:(M-1)
%       C_T_1((i*N),:)=0;
%   end
%   for i=2:(M-1)
%       C_T_1((i*N),(i*N))=1;
%   end
% C_T_1;
% % C_T_1(NM-N,:) = A_r_new_L1(NM-N,:); 
% % C_T_1(NM-N,NM-N) = 1.0;
% % C_T_1(NM-N,NM-N) = A_r_new_L1(NM-N,NM-N); 
% 
% 
% 
% C_T_2 = L_2(1,1)*B_r_new;
% 
% 
% 
% %%%--- Negative z direction
% 
% C_T_2(1:N,:)=0;
% %   for i=1:N
% %       C_T_2(i,i)=1;
% %   end
% 
% 
% %%%--- Positive z direction 
% 
% C_T_2((NM-N):NM,:)=0;
% %   for i=(NM-N):NM
% %       C_T_2(i,i)=1;
% %   end
% 
% 
% %%%--- Negative r direction
% 
%   for i=1:(M-2)
%       C_T_2((i*N+1),:)=0;
%   end
% %   for i=1:(M-2)
% %       C_T_2((i*N+1),(i*N+1))=1;
% %   end
%   
%   
% %%%--- Positive r direction 
% 
%   for i=2:(M-1)
%       C_T_2((i*N),:)=0;
%   end
% %   for i=2:(M-1)
% %       C_T_2((i*N),(i*N))=1;
% %   end
% C_T_2;
% 
% 
% 
% C_T_3 = L_3(1,1)*A_z_new;
% 
% 
% 
% 
% %%%--- Negative z direction
% 
% C_T_3(1:N,:)=0;
%   for i=1:N
%       C_T_3(i,:)=A_z_new(i,:);
%   end
% 
% 
% %%%--- Positive z direction 
% 
% C_T_3((NM-N):NM,:)=0;
%   for i=(NM-N):NM
%       C_T_3(i,:)=A_z_new(i,:);
%   end
% 
%   
% %   for i=2*N:N:(M-2)*N
% %       C_T_3(i,i)=A_z_new(i,i);
% %   end  
%   
% 
% %%%--- Negative r direction
% 
%   for i=1:(M-2)
%       C_T_3((i*N+1),:)=0;
%   end
% %   for i=1:(M-2)
% %       C_T_3((i*N+1),(i*N+1))=1;
% %   end
%   
%   
% %%%--- Positive r direction 
% 
%   for i=2:(M-1)
%       C_T_3((i*N),:)=0;
%   end
% %   for i=2:(M-1)
% %       C_T_3((i*N),(i*N))=1;
% %   end
% C_T_3;
% C_T_3(1,:) = 0;
% C_T_3(1,1) = 1;
% C_T_3(NM-N+1,:) = 0;
% C_T_3(NM-N+1,NM-N+1) = 1;
% 
% 
% 
% 
% C_T_4 = L_2(1,1)*B_z_new;
% 
% 
% 
% %%%--- Negative z direction
% 
% C_T_4(1:N,:)=0;
% %   for i=1:N
% %       C_T_4(i,i)=1;
% %   end
% 
% 
% %%%--- Positive z direction 
% 
% C_T_4((NM-N):NM,:)=0;
% %   for i=(NM-N):NM
% %       C_T_4(i,i)=1;
% %   end
% 
% 
% %%%--- Negative r direction
% 
%   for i=1:(M-2)
%       C_T_4((i*N+1),:)=0;
%   end
% %   for i=1:(M-2)
% %       C_T_4((i*N+1),(i*N+1))=1;
% %   end
%   
%   
% %%%--- Positive r direction 
% 
%   for i=2:(M-1)
%       C_T_4((i*N),:)=0;
%   end
% %   for i=2:(M-1)
% %       C_T_4((i*N),(i*N))=1;
% %   end
% C_T_4;
% 
% 
% 
% C_T = C_T_1+C_T_2+C_T_3+C_T_4;
% 
% 
% 
% 
% 
%%%--- Laminated





T_Side_A = T_LEFT;
T_Side_B = T_DOWN;
T_Side_C = T_RIGHT;
T_Side_D = T_UP;

d = zeros(N*NL,M); 

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

for i=0:NL-1
    
    d_l(i*N+1:i*N+N,1:M)=reshape(d(i*NM+1:i*NM+NM,1),N,M);
    
end

d_l;



% d = reshape(d,NM*NL,[]);
% Td=d'


%  C_T_1 = zeros(NM*NL,NM*NL);
 C_T_2 = zeros(NM*NL,NM*NL);
 C_T_3 = zeros(NM*NL,NM*NL);
 C_T_4 = zeros(NM*NL,NM*NL);
%  C_T = zeros(NM*NL,NM*NL);
 
 

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

 
%  for j=0:M-1
%     A_r_G_new_L1((j*N*NL+i*N+1):(j*N*NL+i*N+N),(i*NM+j*N+1):(i*NM+j*N+N)) = A_r_L1(1:N,1:N);
% end
 
 

 A_r_G(:,(i*N+1):(i*N+N))=A_r(:,:);
 
 A_r_G_new_L1((i*NM+1):(i*NM+NM),(i*NM+1):(i*NM+NM)) = A_r_new_L1(1:NM,1:NM);

 
 
end
 
C_T_1 = A_r_G_new_L1;
 
 for i=0:NL-1
     
     C_T_2((i*NM+1):(i*NM+NM),:) = L_2(1,(i+1))*B_r_G_new((i*NM+1):(i*NM+NM),:);
     C_T_3((i*NM+1):(i*NM+NM),:) = L_3(1,(i+1))*A_z_G_new((i*NM+1):(i*NM+NM),:);
     C_T_4((i*NM+1):(i*NM+NM),:) = L_2(1,(i+1))*B_z_G_new((i*NM+1):(i*NM+NM),:);


 end
 
 
C_T = C_T_1+C_T_2+C_T_3+C_T_4; 



% % C_T = zeros(NM*NL,NM*NL);

% 
% for i=0:NL-1
%      
%      if i==0
%          
%        %%%--- Negative z direction 
%        
%        C_T(1:N,:)=0;
%        for j=1:N
%            C_T(j,j)=1;
%        end
%        
%        %%%--- Positive z direction 
%        
%        C_T((NM*NL-N*NL+1):(NM*NL-N*NL+N),:)=0;
%        for j=(NM*NL-N*NL+1):(NM*NL-N*NL+N)
%            C_T(j,j)=1;
%        end
%        
%        %%%--- Negative r direction 
%        
%        C_T((N*NL+1):N*NL:((M-2)*N*NL+1),:)=0;
%        
%        for j=(N*NL+1):N*NL:((M-2)*N*NL+1)
%            C_T(j,j)=1;
%        end
%        
%          
%      elseif i==NL-1
%          
%        %%%--- Negative z direction 
%        
%        C_T(i*N+1:i*N+N,:)=0;
%        
%        for j=i*N+1:i*N+N
%            C_T(j,j)=1;
%        end
%        
%        %%%--- Positive z direction 
%        
%        C_T((NM*NL-N*NL+i*N+1):(NM*NL-N*NL+i*N+N),:)=0;
%        
%        for j=(NM*NL-N*NL+i*N+1):(NM*NL-N*NL+i*N+N)
%            C_T(j,j)=1;
%        end
%        
%        %%%--- Positive r direction 
%        
%        C_T((N*NL+i*N+N):N*NL:((M-2)*N*NL+i*N+N),:)=0;
%        
%        for j=(N*NL+i*N+N):N*NL:((M-2)*N*NL+i*N+N)
%            C_T(j,j)=1;
%        end
%        
%        
%        
%      elseif i~=0 && i~=NL-1
%          
%        %%%--- Negative z direction 
%        
%        C_T(i*N+1:i*N+N,:)=0;
%        
%        for j=i*N+1:i*N+N
%            C_T(j,j)=1;
%        end
%        
%        %%%--- Positive z direction 
%        
%        C_T((NM*NL-N*NL+i*N+1):(NM*NL-N*NL+i*N+N),:)=0;
%        
%        for j=(NM*NL-N*NL+i*N+1):(NM*NL-N*NL+i*N+N)
%            C_T(j,j)=1;
%        end
%        
%        
%      end
% end









for i=0:NL-1
     
     if i==0
         
       %%%--- Negative z direction +
       
       C_T(1:N,:)=0;
       for j=1:N
           C_T(j,j)=1;
       end
       
       %%%--- Positive z direction +
       
       C_T((NM-N+1):NM,:)=0;
       for j=(NM-N+1):NM
           C_T(j,j)=1;
       end
       
       %%%--- Negative r direction +
       
       C_T(N+1:N:(NM-2*N+1),:)=0;
       
       for j=N+1:N:(NM-2*N+1)
           C_T(j,j)=1;
       end
       
         
     elseif i==NL-1
         
       %%%--- Negative z direction +
       
       C_T((i*NM+1):(i*NM+N),:)=0;
       
       for j=i*NM+1:i*NM+N
           C_T(j,j)=1;
       end
       
       %%%--- Positive z direction +
       
       C_T(((i+1)*NM-N+1):(i+1)*NM,:)=0;
       
       for j=((i+1)*NM-N+1):(i+1)*NM
           C_T(j,j)=1;
       end
       
       %%%--- Positive r direction 
       
       C_T((i*NM+2*N):N:((i+1)*NM-N),:)=0;
       
       for j=(i*NM+2*N):N:((i+1)*NM-N)
           C_T(j,j)=1;
       end
       
       
       
     elseif i~=0 && i~=NL-1
         
       %%%--- Negative z direction +
       
       C_T((i*NM+1):(i*NM+N),:)=0;
       
       for j=i*NM+1:i*NM+N
           C_T(j,j)=1;
       end
       
       %%%--- Positive z direction +
       
       C_T(((i+1)*NM-N+1):(i+1)*NM,:)=0;
       
       for j=((i+1)*NM-N+1):(i+1)*NM
           C_T(j,j)=1;
       end
       
       
     end
end










c=0;
for i=1:NM_G
    if C_T(i,i) ==1
        c=c+1;
        i;
    end
end

c
B_n=2*(N_G+M-2)

%%


det_C_T = det(C_T);
 
 
C_T;
T = (C_T^(-1))*d;
% T = C_T \ d;

for i=0:NL-1
    
    T_calc(i*N+1:i*N+N,1:M)=reshape(T(i*NM+1:i*NM+NM,1),N,M);
    
end
T_real = T_calc'


% T_calc = reshape(T,N*NL,M)
% T_real = T_calc';



T=T_calc;
Dlt_T = T-T_Amb;

Dlt_T = Dlt_T';





T_1=T_real;

T_1(2:M-1,2:N_G-1) = 0;


d_calc = reshape(d,N*NL,M);
d_real = d_calc';

test_1 = T_1-d_real;
test_2 = reshape(test_1',NM*NL,[]);
test_2';







test_3 = C_T*d;


% test_3 = reshape(test_3,N*NL,M);

for i=0:NL-1
    
    test_3_new(i*N+1:i*N+N,1:M)=reshape(test_3(i*NM+1:i*NM+NM,1),N,M);
    
end

test_3_new





