%% claude_porosity_check_R3_1.m — verify R3_1 porosity scheme vs author's tables
%  Confirms the exact document relations reproduce BOTH tables for all rows.
clear; clc;
% author's em-table rows: [em3 em1 em2 em4 em5]
EM = [0.9675 0.0511 0.0894 0.7599 0.7599;
      0.9336 0.1043 0.1827 0.7333 0.7333;
      0.8980 0.1602 0.2807 0.7056 0.7056;
      0.8604 0.2193 0.3842 0.6758 0.6758;
      0.8205 0.2820 0.4940 0.6444 0.6444;
      0.7776 0.3493 0.6120 0.6107 0.6107];
% author's e-table rows: [em3 e1 e2 e3 e4 e5]
E  = [0.9675 0.1001 0.1738 0.9361 0.9070 0.9070;
      0.9336 0.2043 0.3446 0.8716 0.8445 0.8445;
      0.8980 0.3100 0.5123 0.8064 0.7813 0.7813;
      0.8604 0.4170 0.6765 0.7403 0.7173 0.7173;
      0.8205 0.5254 0.8358 0.6732 0.6523 0.6523;
      0.7776 0.6350 0.9870 0.6047 0.5859 0.5859];

fprintf('row |  em1 err   em2 err   em4 err  |  e3 err    e4 err\n');
for k = 1:6
    em3 = EM(k,1);
    em1 = (pi/2)*(1-em3);   em2 = (1-em3)/(1-2/pi);   em4 = (pi/4)*em3;
    e3  = em3^2;            e4  = (pi/2)*em4^2;
    fprintf('%d   | %9.5f %9.5f %9.5f | %9.5f %9.5f\n', k, ...
        em1-EM(k,2), em2-EM(k,3), em4-EM(k,4), e3-E(k,4), e4-E(k,5));
end
fprintf('\nAll errors should be at table-rounding level (<= 5e-5).\n');
fprintf('Conservation check (numeric): integral of P_m over zeta = em3:\n');
z = linspace(-0.5,0.5,20001);
for k = [1 3 6]
    em3 = EM(k,1); em1=(pi/2)*(1-em3); em2=(1-em3)/(1-2/pi); em4=(pi/4)*em3;
    IO = trapz(z, 1-em1*cos(pi*z));
    IX = trapz(z, 1-em2*(1-cos(pi*z)));
    IV = trapz(z, 2*em4*cos(pi*z/2+pi/4));
    fprintf('  row %d: O=%.5f X=%.5f V=%.5f (target em3=%.4f)\n', k, IO, IX, IV, em3);
end
