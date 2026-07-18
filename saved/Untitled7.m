


C_11 = zeros(1,NL);
C_22 = zeros(1,NL);
C_12 = zeros(1,NL);
C_23 = zeros(1,NL);
C_13 = zeros(1,NL);
C_55 = zeros(1,NL);

for j=1:NL
    
C_11(1,j)=((1-nu(1,j))*Ym(1,j))/((1+nu(1,j))*(1-(2*nu(1,j))));
d_r_C_11=0;
C_22=((1-nu(1,j))*Ym(1,j))/((1+nu(1,j))*(1-(2*nu(1,j))));
% d_r_C_22=0;
% C_33=((1-nu)*Ym)/((1+nu)*(1-(2*nu)));
% d_r_C_33=0;

C_12=(nu(1,j)*Ym(1,j))/((1+nu(1,j))*(1-(2*nu(1,j))));
d_r_C_12=0;
C_23=(nu(1,j)*Ym(1,j))/((1+nu(1,j))*(1-(2*nu(1,j))));
C_13=(nu(1,j)*Ym(1,j))/((1+nu(1,j))*(1-(2*nu(1,j))));
d_r_C_13=0;

C_55=(Ym(1,j))/(2*(1+nu(1,j)));
d_r_C_55=0;

end





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