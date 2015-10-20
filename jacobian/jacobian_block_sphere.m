function [f, df] = jacobian_ik_sphere(p, c1, r1, d1, a1, variables)

D = length(p);
w1 = [cos(a1); sin(a1)];

for v = 1:length(variables)
    variable = variables{v};
    switch variable
        case 'c1'
            dc1 = eye(D, D);
            dr1 = zeros(1, D);
            dp = zeros(D, D);
            dd1 = zeros(1, D);
            dw1 = zeros(D, D);
        case 'a1'
            dc1 = zeros(D, 1);
            dr1 = zeros(1, 1);
            dp = zeros(D, 1);
            dd1 = 0;
            dw1 = [-sin(a1); cos(a1)];
    end
    
    %% c2 =  c1 + d * v;
    [b, db] = product_derivative(d1, dd1, w1, dw1);
    [e1, de1] = sum_derivative(c1, dc1, b, db);
    [m, dm] = difference_derivative(p, dp, e1, de1);
    [n, dn] = normalize_derivative(m, dm);
    [l, dl] = product_derivative(r1, dr1, n, dn);
    [q, dq] = sum_derivative(e1, de1, l, dl);    
    f = q;
    %% Display result
    switch variable
        case 'c1'
            df.dc1 = dq;
        case 'a1'
            df.da1 = dq;
    end
end


