% A = rand(3, 3);
% 
% det(A)
% 
% a11 = A(1, 1); a12 = A(1, 2); a13  = A(1, 3);
% a21 = A(2, 1); a22 = A(2, 2); a23  = A(2, 3);
% a31 = A(3, 1); a32 = A(3, 2); a33  = A(3, 3);
% 
% D = a11 * (a22 * a33 - a23 * a32) - a12 * (a21 * a33 - a23 * a31) + a13 * (a21 * a32 - a22 * a31);

%% The centers
clc
D = 3;
c1 = rand(D, 1);
c2 = rand(D, 1);
c3 = rand(D, 1);
c4 = rand(D, 1);

A = [c2 - c1, c3 - c1, c4 - c1];
det(A)

b11 = A(1, 1); b12 = A(1, 2); b13  = A(1, 3);
b21 = A(2, 1); b22 = A(2, 2); b23  = A(2, 3);
b31 = A(3, 1); b32 = A(3, 2); b33  = A(3, 3);

D = b11 * (b22 * b33 - b23 * b32) - b12 * (b21 * b33 - b23 * b31) + b13 * (b21 * b32 - b22 * b31);

c11 = c1(1); c12 = c1(2); c13 = c1(3);
c21 = c2(1); c22 = c2(2); c23 = c2(3);
c31 = c3(1); c32 = c3(2); c33 = c3(3);
c41 = c4(1); c42 = c4(2); c43 = c4(3);

a11 = @(c21, c11) c21 - c11;
a12 = @(c31, c11) c31 - c11;
a13 = @(c41, c11) c41 - c11;

a21 = @(c22, c12) c22 - c12;
a22 = @(c32, c12) c32 - c12;
a23 = @(c42, c12) c42 - c12;

a31 = @(c23, c13) c23 - c13;
a32 = @(c33, c13) c33 - c13;
a33 = @(c43, c13) c43 - c13;

D = @(c11, c12, c13, c21, c22, c23, c31, c32, c33, c41, c42, c43)  ...
    a11(c21, c11) * (a22(c32, c12) * a33(c43, c13) - a23(c42, c12) * a32(c33, c13)) - ...
    a12(c31, c11) * (a21(c22, c12) * a33(c43, c13) - a23(c42, c12) * a31(c23, c13)) + ...
    a13(c41, c11) * (a21(c22, c12) * a32(c33, c13) - a22(c32, c12) * a31(c23, c13));

%% Compute gradient
arguments = 'c11, c12, c13, c21, c22, c23, c31, c32, c33, c41, c42, c43';
variables = {'c11', 'c12', 'c13', 'c21', 'c22', 'c23', 'c31', 'c32', 'c33', 'c41', 'c42', 'c43'};
p_ = @(c1, r1) p;
c1_ = @(c1, r1) c1;
r1_ = @(c1, r1) r1;

for v = 1:length(variables)
    variable = variables{v};
    switch variable
        case 'c1'
            dc1 = @(c1, r1) eye(D, D);
            dr1 = @(c1, r1) zeros(1, D);
            dp = @(c1, r1) zeros(D, D);
        case 'r1'
            dc1 = @(c1, r1) zeros(D, 1);
            dr1 = @(c1, r1) 1;
            dp = @(c1, r1) zeros(D, 1);
    end
    
    [m, dm] = difference_handle(p_, dp, c1_, dc1, arguments);
    [n, dn] = normalize_handle(m, dm, arguments);
    [l, dl] = product_handle(r1_, dr1, n, dn, arguments);
    [q, dq] = sum_handle(c1_, dc1, l, dl, arguments);
    
    %% Display result
    switch variable
        case 'c1'
            dq_dc1 = dq;
        case 'r1'
            dq_dr1 = dq;
    end
end


