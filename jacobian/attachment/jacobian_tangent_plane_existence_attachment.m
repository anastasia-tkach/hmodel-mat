function [f, gradients] = jacobian_tangent_plane_existence_attachment(c1, c2, c3, r1, r2, r3, factor, gradients)

D = length(c1);

dfactor = 0;
one = 1;
done =  0;
dr1 = zeros(1, D);
dr2 = zeros(1, D);
dr3 = zeros(1, D);

for var = 1:length(gradients)        
    
    dc1 = gradients{var}.dc1;
    dc2 = gradients{var}.dc2;
    dc3 = gradients{var}.dc3;
    
    %% z - epix of the tangent cone, z = c1 + (c2 - c1) * r1 / (r1 - r2);
    [x, dx] = difference_derivative(r1, dr1, r2, dr2);
    [u, du] = difference_derivative(c2, dc2, c1, dc1);
    [unorm, dunorm] = norm_derivative(u, du);
    
    [a, da] = product_derivative(r1, dr1, u, du);
    [b, db] = ratio_derivative(a, da, x, dx);
    [z, dz] = sum_derivative(c1, dc1, b, db);
    
    %% t - rojection of c3 of the axis c1-c2,  gamma = u' * (c3 - c1) / (u' * u); t = c1 + gamma * u;    
    [a, da] = difference_derivative(c3, dc3, c1, dc1);
    [b, db] = dot_derivative(u, du, u, du);
    [c, dc] = ratio_derivative(a, da, b, db);
    [gamma, dgamma] = dot_derivative(u, du, c, dc);
    
    [d, dd] = product_derivative(gamma, dgamma, u, du);
    [t, dt] = sum_derivative(c1, dc1, d, dd);
    
    %% What if projection of c3 is outside c1-c2
    w = z - c1;
    y = t - c1;
    if y' * w > 0 && norm(y) > norm(w)
        [a, da] = difference_derivative(z, dz, t, dt);
        [b, db] = difference_derivative(z, dz, c1, dc1); 
        [c, dc] = sum_derivative(b, db, a, da);
        [t, dt] = sum_derivative(c1, dc1, c, dc);
    end
    
    %% delta_r - linear part of the radius at point t, delta_r = norm(c2 - t) * x / unorm;   
    [a, da] = ratio_derivative(x, dx, unorm, dunorm);
    [b, db] = difference_derivative(c2, dc2, t, dt);
    [c, dc] = norm_derivative(b, db);
    [delta_r, ddelta_r] = product_derivative(c, dc, a, da);
    
    if y' * u > 0 && norm(y) > unorm
       [delta_r, ddelta_r] = minus_derivative(delta_r, ddelta_r);
    end
    
    %% r - orthogonal radius of cone at t,  r_tilde = delta_r + r2; sin_beta = x / unorm; cos_beta = sqrt(1 - sin_beta^2);  r = r_tilde/cos_beta;    
    [r_tilde, dr_tilde] = sum_derivative(delta_r, ddelta_r, r2, dr2);
    [sin_beta, dsin_beta] = ratio_derivative(x, dx, unorm, dunorm);
    [a, da] = product_derivative(sin_beta, dsin_beta, sin_beta, dsin_beta);
    [b, db] = difference_derivative(one, done, a, da);
    [cos_beta, dcos_beta] = sqrt_derivative(b, db);
    [r, dr] = ratio_derivative(r_tilde, dr_tilde, cos_beta, dcos_beta);
    
    %% eta - orthogonal distance from c3 to the axis, eta = r3 + norm(c3 - t);
    [a, da] = difference_derivative(c3, dc3, t, dt);
    [b, db] = norm_derivative(a, da);
    [eta, deta] = sum_derivative(r3, dr3, b, db);
    
    %% objective function, f = eta - factor * r
    [a, da] = product_derivative(factor, dfactor, r, dr);
    [f, df_] = difference_derivative(eta, deta, a, da);
    
    %% Display result
    gradients{var}.df = df_;
end
