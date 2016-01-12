function [f, gradients] = jacobian_sphere_attachment(p, c, r, gradients)

for var = 1:length(gradients)
    dc = gradients{var}.dc1;
    dp = zeros(size(dc));
    dr = zeros(1, size(dc, 2));
    
    [m, dm] = difference_derivative(p, dp, c, dc);
    [n, dn] = normalize_derivative(m, dm);
    [l, dl] = product_derivative(r, dr, n, dn);
    [q, dq] = sum_derivative(c, dc, l, dl);
    f = q;
    
    gradients{var}.df = dq;
end

