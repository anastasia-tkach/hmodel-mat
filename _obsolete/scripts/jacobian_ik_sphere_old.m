function [f, df] = jacobian_ik_sphere(p, c1, r1, variables)

D = length(p);

for v = 1:length(variables)
    variable = variables{v};
    switch variable
        case 'c1'
            dc1 = eye(D, D);
            dr1 = zeros(1, D);
            dp = zeros(D, D);
    end
    
    [m, dm] = difference_derivative(p, dp, c1, dc1);
    [n, dn] = normalize_derivative(m, dm);
    [l, dl] = product_derivative(r1, dr1, n, dn);
    [q, dq] = sum_derivative(c1, dc1, l, dl);
    f = q;

    %% Display result
    switch variable
        case 'c1'
            df.dc1 = dq;
    end
end


