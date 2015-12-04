function [f, gradients] = jacobian_tangent_cone_existence_attachment(c1, c2, r1, r2, factor, gradients)

D = length(c1);

dr1 = zeros(1, D);
dr2 = zeros(1, D);
dfactor = 0;


for var = 1:length(gradients)        
    
    dc1 = gradients{var}.dc1;
    dc2 = gradients{var}.dc2;
   
    %% norm(c1 - c2) - factor * (r1 - r2) = 0;
    [a, da] = difference_derivative(c1, dc1, c2, dc2);
    [b, db] = norm_derivative(a, da);
    [c, dc] = difference_derivative(r1, dr1, r2, dr2);
    [d, dd] = product_derivative(factor, dfactor, c, dc);
    [r, dr] = difference_derivative(b, db, d, dd);
    
    f = r;
    gradients{var}.df = dr;
end
