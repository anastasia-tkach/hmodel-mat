function [q, dq_dc, dq_dr] = jacobian_sphere(p, c, r)

D = length(p);
% c = rand(D, 1);
% p = rand(D, 1);
% r = rand(1, 1);

variables = {'c', 'r'};

for v = 1:length(variables)
    variable = variables{v};
    switch variable
        case 'c'
            dc = eye(D, D);
            dr = zeros(1, D);
            dp = zeros(D, D);
        case 'r'
            dc = zeros(D, 1);
            dr = 1;
            dp = zeros(D, 1);
    end
    
    [m, dm] = difference_derivative(p, dp, c, dc);
    [n, dn] = normalize_derivative(m, dm);
    [l, dl] = product_derivative(r, dr, n, dn);
    [q, dq] = sum_derivative(c, dc, l, dl);
    
    %% Display result
    switch variable
        case 'c'  
            dq_dc = dq;            
        case 'r'        
            dq_dr = dq;
    end
end

% energy1_case1_analytical(p, c, r);
% disp([dq_dc, dq_dr]);

