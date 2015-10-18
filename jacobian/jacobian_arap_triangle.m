% clc; clear; D = 3;
% while(true)
%     c1 = rand(D, 1); c2 = rand(D, 1); c3 = rand(D, 1);
%     x1 = rand(1, 1); x2 = rand(1, 1); x3 = rand(1, 1); x = [x1, x2, x3];
%     [r1, i1] = max(x); [r3, i3] = min(x); x([i1, i3]) = 0; r2 = max(x);
%     if norm(c1 - c2) > r1 && norm(c1 - c3) > r1 &&  norm(c2 - c3) > r2, break; end
% end
% p = rand(D, 1); index = -1;

function [f, df] = jacobian_arap_triangle(p, c1, c2, c3)

variables = {'c1', 'c2', 'c3'};

D = length(p);

for v = 1:length(variables)
    variable = variables{v};
    switch variable
        case 'c1', dc1 = eye(D, D); dc2 = zeros(D, D); dc3 = zeros(D, D); dp =  zeros(D, D);
        case 'c2', dc1 = zeros(D, D); dc2 = eye(D, D); dc3 = zeros(D, D); dp =  zeros(D, D);
        case 'c3', dc1 = zeros(D, D); dc2 = zeros(D, D); dc3 = eye(D, D); dp =  zeros(D, D);
    end
    
    % m = cross(c1 - c2, c1 - c3);
    [O1, dO1] = difference_derivative(c1, dc1, c2, dc2);
    [O2, dO2] = difference_derivative(c1, dc1, c3, dc3);
    [m, dm] = cross_derivative(O1, dO1, O2, dO2);
    
    % m = m / norm(m);
    [m, dm] = normalize_derivative(m, dm);
    
    % distance = (p - c1)' * m;
    [O1, dO1] = difference_derivative(p, dp, c1, dc1);
    [distance, ddistance] = dot_derivative(O1, dO1, m, dm);
    
    % t = p - distance * m;
    [O1, dO1] = product_derivative(distance, ddistance, m, dm);
    [q, dq] = difference_derivative(p, dp, O1, dO1);
    f = q;
    switch variable
        case 'c1', df.dc1 = dq;
        case 'c2', df.dc2 = dq;
        case 'c3', df.dc3 = dq;   
    end     
end












