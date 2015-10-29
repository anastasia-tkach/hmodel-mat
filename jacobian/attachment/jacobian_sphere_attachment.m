function [f, gradients] = jacobian_sphere_attachment(p, c, r, gradients)

D = length(p);
dp = zeros(D, D);
dr = zeros(1, D);

for var = 1:length(gradients)
    dc = gradients{var}.dc1;
    
    [m, dm] = difference_derivative(p, dp, c, dc);
    [n, dn] = normalize_derivative(m, dm);
    [l, dl] = product_derivative(r, dr, n, dn);
    [q, dq] = sum_derivative(c, dc, l, dl);
    f = q;
    
    gradients{var}.df = dq;
end

