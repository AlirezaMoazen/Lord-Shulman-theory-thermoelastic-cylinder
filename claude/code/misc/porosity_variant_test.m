%% ========================================================================
%  claude_porosity_variant_test.m — determine the V/A/O/X porosity formulas
%  ------------------------------------------------------------------------
%  The MZ-R 0.docx tables link the pattern coefficients by mass equivalence:
%     row k:  [em3  e1  e2  e3  e4  e5]
%  We test every plausible formula variant and both conservation laws:
%     C1:  integral of P(s) ds        = e3      (stiffness-factor equality)
%     C2:  integral of sqrt(P(s)) ds  = em3 = sqrt(e3)  (mass equality)
%  over s in [0,1] (from inner) or centered zeta = s-1/2.
%  The variant that reproduces ALL table rows is the spec's intended one.
%  ========================================================================
clear; clc;

% MZ-R 0.docx table  [em3, e1, e2, e3, e4, e5]
T = [0.9675 0.1001 0.1738 0.9361 0.9070 0.9070;
     0.9336 0.2043 0.3446 0.8716 0.8445 0.8445;
     0.8980 0.3100 0.5123 0.8064 0.7813 0.7813;
     0.8604 0.4170 0.6765 0.7403 0.7173 0.7173;
     0.8205 0.5254 0.8358 0.6732 0.6523 0.6523;
     0.7776 0.6350 0.9870 0.6047 0.5859 0.5859];

s = linspace(0,1,20001);  ds = s(2)-s(1);
I  = @(f) trapz(s, f);                 % integral over thickness fraction

fprintf('=== O-pattern candidates:  P = 1 - e1*F(s) ===\n');
cand_O = { 'cos(pi*s), from inner',      @(x) cos(pi*x);
           'cos(pi*(s-1/2)) = sin(pi*s)',@(x) sin(pi*x) };
for c = 1:size(cand_O,1)
    res1 = zeros(6,1); res2 = zeros(6,1);
    for k = 1:6
        P = 1 - T(k,2)*cand_O{c,2}(s);
        res1(k) = I(P) - T(k,4);                    % C1 vs e3
        res2(k) = I(sqrt(max(P,0))) - T(k,1);       % C2 vs em3
    end
    fprintf('%-30s  C1 max|res| = %.4f   C2 max|res| = %.4f\n', ...
            cand_O{c,1}, max(abs(res1)), max(abs(res2)));
end

fprintf('\n=== X-pattern candidates:  P = 1 - e2*F(s) ===\n');
cand_X = { '1-cos(pi*s), from inner',    @(x) 1-cos(pi*x);
           '1-sin(pi*s), centered',      @(x) 1-sin(pi*x) };
for c = 1:size(cand_X,1)
    res1 = zeros(6,1); res2 = zeros(6,1);
    for k = 1:6
        P = 1 - T(k,3)*cand_X{c,2}(s);
        res1(k) = I(P) - T(k,4);
        res2(k) = I(sqrt(max(P,0))) - T(k,1);
    end
    fprintf('%-30s  C1 max|res| = %.4f   C2 max|res| = %.4f\n', ...
            cand_X{c,1}, max(abs(res1)), max(abs(res2)));
end

fprintf('\n=== V-pattern candidates:  P = e4*F(s) ===\n');
cand_V = { 'cos(pi*s/2 + pi/4)',          @(x) cos(pi*x/2 + pi/4);
           'sqrt2*cos(pi*s/2 + pi/4)',    @(x) sqrt(2)*cos(pi*x/2 + pi/4);
           '2*cos(pi*s/2 + pi/4)',        @(x) 2*cos(pi*x/2 + pi/4);
           'cos(pi*(s-1/2)/2 + pi/4)',    @(x) cos(pi*(x-0.5)/2 + pi/4);
           'sqrt2*cos(pi*(s-1/2)/2+pi/4)',@(x) sqrt(2)*cos(pi*(x-0.5)/2 + pi/4);
           '2*cos(pi*(s-1/2)/2 + pi/4)',  @(x) 2*cos(pi*(x-0.5)/2 + pi/4);
           'cos(pi*s/2)',                 @(x) cos(pi*x/2);
           'sqrt2*cos(pi*s/2)',           @(x) sqrt(2)*cos(pi*x/2) };
for c = 1:size(cand_V,1)
    res1 = zeros(6,1); res2 = zeros(6,1);
    for k = 1:6
        P = T(k,5)*cand_V{c,2}(s);
        res1(k) = I(min(max(P,0),1)) - T(k,4);
        res2(k) = I(sqrt(min(max(P,0),1))) - T(k,1);
    end
    fprintf('%-32s  C1 max|res| = %.4f   C2 max|res| = %.4f\n', ...
            cand_V{c,1}, max(abs(res1)), max(abs(res2)));
end

fprintf('\n(The A-pattern mirrors V: A(s) = V(1-s); same residuals by symmetry.)\n');
fprintf('Smallest residual = the intended formula. Values < ~0.003 = table rounding.\n');
