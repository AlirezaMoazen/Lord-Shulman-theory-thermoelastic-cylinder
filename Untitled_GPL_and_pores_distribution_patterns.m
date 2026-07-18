
clc,clear;
%GPL and pores distribution patterns

%GPL distribution patterns

%O-Type
for e=1:NL
W_GPL_O = 4*W_GPL*(((NL+1)/2)-abs(e-((NL+1)/2)))/(NL+2);
end
%X-Type
for e=1:NL
W_GPL_X = 4*W_GPL*((1/2)+abs(e-((NL+1)/2)))/(NL+2);
end
%UD-Type
W_GPL_UD = W_GPL;
%V-Type
for e=1:NL
W_GPL_V = 2*W_GPL*e/(NL+1);
end
%A-Type
for e=1:NL
W_GPL_A = W_GPL*(2*(NL+1-e)/(NL+1));
end


%Pores distribution patterns
h=R_o-R_i;
Lt=h/NL;
%O-Type
for j=0:NL-1
     r_m=R_i+Lt/2+Lt*j;
      P_O = 1-e_1*cos(pi*r_m/h);
end
%X-Type
for j=0:NL-1
     r_m=R_i+Lt/2+Lt*j;
      P_X = 1-e_2*(1-cos(pi*r_m/h));
end
%UD-Type
P_UD = e_3;
%V-Type
for j=0:NL-1
     r_m=R_i+Lt/2+Lt*j;
      P_V = e_4*cos(pi*r_m/2*h+pi/4);
end
%A-Type
for j=0:NL-1
     r_m=R_i+Lt/2+Lt*j;
      P_A = e_5*cos(pi*r_m/2*h+5*pi/4);
end





