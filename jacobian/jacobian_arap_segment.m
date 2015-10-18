function [f, df] = jacobian_arap_segment(p, c1, c2)
D = length(p);
variables = {'c1', 'c2'};
for var = 1:length(variables)
    variable = variables{var};
    switch variable
        case 'c1', dc1 = eye(D, D); dc2 = zeros(D, D);           
            dp = zeros(D, D);
        case 'c2',  dc1 = zeros(D, D); dc2 = eye(D, D);          
            dp = zeros(D, D);       
    end
    
    %% u =  c2 - c1; v =  p - c1;
    [u, du] = difference_derivative(c2, dc2, c1, dc1);
    [v, dv] = difference_derivative(p, dp, c1, dc1);
    
    %% q - closest point on the axis, q = c1 + alpha * u;
    [s, ds] = dot_derivative(u, du, v, dv);
    [tn, dtn] = product_derivative(s, ds, u, du);
    [uu, duu] = dot_derivative(u, du, u, du);
    [b, db] = ratio_derivative(tn, dtn, uu, duu);
    [q, dq] =  sum_derivative(c1, dc1, b, db);
   
    f = q;
    %% Display result
    switch variable
        case 'c1'
            df.dc1 = dq;
        case 'c2'
            df.dc2 = dq;
    end
end









