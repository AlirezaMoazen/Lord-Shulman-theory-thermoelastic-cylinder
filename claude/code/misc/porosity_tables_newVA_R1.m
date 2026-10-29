%% porosity_tables_newVA_R1.m -- e and e_m tables of MZ-R 0.docx recomputed for the NEW V and A patterns
%  Author request (2026-10-14). New patterns (centred zeta in [-1/2,1/2]):
%    V : P_m = 1 - e_m4 cos(pi*zeta/2 + pi/4)      A : P_m = 1 - e_m5 cos(pi*zeta/2 - pi/4)
%  Conventions are those that reproduce the O/X columns of the MZ-R 0 tables (checked below):
%    mass side   (e_m* table):  int P_m dzeta = e_m3                      -> closed form
%    stiffness   (e_*  table):  int sqrt(P_i) dzeta = e_m3 , P_i = 1 - e*F  -> numeric (as e1, e2); e3 = e_m3^2
%  UD, O, X columns (e_m1, e_m2, e1, e2, e3) are unchanged. Only e_m4 = e_m5 and e4 = e5 change.
%  Output: porosity_tables_newVA_R1.csv  (same folder) ; nothing in the solver is changed.
clear; clc;
EM3 = [0.9675 0.9336 0.8980 0.8604 0.8205 0.7776].';
% MZ-R 0 tables for the check [em3 e1 e2 e3 e4 e5] and [em3 em1 em2 em4 em5]
TE = [0.9675 0.1001 0.1738 0.9361 0.9070 0.9070; 0.9336 0.2043 0.3446 0.8716 0.8445 0.8445;
      0.8980 0.3100 0.5123 0.8064 0.7813 0.7813; 0.8604 0.4170 0.6765 0.7403 0.7173 0.7173;
      0.8205 0.5254 0.8358 0.6732 0.6523 0.6523; 0.7776 0.6350 0.9870 0.6047 0.5859 0.5859];
TM = [0.9675 0.0511 0.0894 0.7599 0.7599; 0.9336 0.1043 0.1827 0.7333 0.7333;
      0.8980 0.1602 0.2807 0.7056 0.7056; 0.8604 0.2193 0.3842 0.6758 0.6758;
      0.8205 0.2820 0.4940 0.6444 0.6444; 0.7776 0.3493 0.6120 0.6107 0.6107];
Sq = @(f) integral(f,-0.5,0.5,'RelTol',1e-12,'AbsTol',1e-14);
out = zeros(6,11);
for k = 1:6
    m3 = EM3(k);
    em1 = (pi/2)*(1-m3);  em2 = (1-m3)/(1-2/pi);
    e1  = fzero(@(x) Sq(@(z) sqrt(max(1-x*cos(pi*z),0))) - m3,[0 0.999]);
    e2  = fzero(@(x) Sq(@(z) sqrt(max(1-x*(1-cos(pi*z)),0))) - m3,[0 0.999]);
    e3  = m3^2;
    em4n = (pi/2)*(1-m3);                                   % NEW mass-side constant (V and A)
    e4n  = fzero(@(x) Sq(@(z) sqrt(max(1-x*cos(pi*z/2+pi/4),0))) - m3,[0 0.999]);   % NEW stiffness-side
    chkM = Sq(@(z) 1-em4n*cos(pi*z/2+pi/4)) - m3;           % mass conservation residual
    chkS = Sq(@(z) sqrt(max(1-e4n*cos(pi*z/2+pi/4),0))) - m3;
    em4o = (pi/4)*m3; e4o = (pi/2)*em4o^2;                  % OLD values (for the comparison)
    out(k,:) = [m3 em1 em2 em4n e1 e2 e3 e4n em4o e4o max(abs(chkM),abs(chkS))];
    fprintf('em3=%.4f | check vs MZ table: em1 %.4f/%.4f em2 %.4f/%.4f e1 %.4f/%.4f e2 %.4f/%.4f e4old %.4f/%.4f | NEW em4=em5=%.4f e4=e5=%.4f (resid %.1e)\n', ...
        m3,em1,TM(k,2),em2,TM(k,3),e1,TE(k,2),e2,TE(k,3),e4o,TE(k,5),em4n,e4n,out(k,11));
end
T = array2table(out,'VariableNames',{'em3','em1','em2','em4_em5_NEW','e1','e2','e3','e4_e5_NEW','em4_em5_old','e4_e5_old','residual'});
writetable(T,'porosity_tables_newVA_R1.csv'); disp(T);
