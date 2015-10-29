% clc;
% D = 3;
% 
% c2 = 0.5 * rand(D ,1);
% p = rand(D, 1);
% alpha = rand;
% beta = 1 - alpha;
% c1a = 0.5 * rand(D ,1);
% c1b = 0.5 * rand(D, 1);

function [f, gradients] = jacobian_arap_segment_attachment(p, c1, c2, gradients)

D = length(p);
dp = zeros(D, D);

for var = 1:length(gradients)
    
    dc1 = gradients{var}.dc1;
    dc2 = gradients{var}.dc2;
   
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
    gradients{var}.df = dq;
end










