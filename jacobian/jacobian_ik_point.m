function [f, df] = jacobian_ik_point(p, b1, d1, a1)

D = length(p);
variables = {'c1', 'a1'};

w1 = [cos(a1); sin(a1)];

for v = 1:length(variables)
    variable = variables{v};
    switch variable
        case 'c1'
            db1 = eye(D, D); 
            dd1 = zeros(1, D);
            dw1 = zeros(D, D);
        case 'a1'
            db1 = zeros(D, 1);          
            dd1 = 0;
            dw1 = [-sin(a1); cos(a1)];
    end
    
    %% c1 =  b1 + d1 * w1;
    [g, dg] = product_derivative(d1, dd1, w1, dw1);
    [q, dq] = sum_derivative(b1, db1, g, dg);
    
    f = q;
    
    %% Display result
    switch variable
        case 'c1'
            df.dc1 = dq;
        case 'a1'
            df.da1 = dq;
    end
end



