function [f, gradients] = jacobian_convsegment_attachment(p, c1, c2, r1, r2, gradients)

for var = 1:length(gradients)        
    
    dc1 = gradients{var}.dc1;
    dc2 = gradients{var}.dc2;
    
    dp = zeros(size(dc1));
    dr1 = zeros(1, size(dc1, 2));
    dr2 = zeros(1, size(dc2, 2));
    
    %% u = c2 - c1; v = p - c1;
    [u, du] = difference_derivative(c2, dc2, c1, dc1);
    [v, dv] = difference_derivative(p, dp, c1, dc1);
    
    %% t - closest point on the axis, t = c1 + alpha * u;
    [s, ds] = dot_derivative(u, du, v, dv);
    [tn, dtn] = product_derivative(s, ds, u, du);
    [uu, duu] = dot_derivative(u, du, u, du);
    [b, db] = ratio_derivative(tn, dtn, uu, duu);
    [t, dt] = sum_derivative(c1, dc1, b, db);
    
    %% omega - lenght of the tangent, omega = sqrt(u' * u - (r1 - r2)^2);
    [r, dr] = difference_derivative(r1, dr1, r2, dr2);
    [c, dc] = product_derivative(r, dr, r, dr);
    [omega2, domega2] = difference_derivative(uu, duu, c, dc);
    [omega, domega] = sqrt_derivative(omega2, domega2);
    
    %% delta - size of the correction, % delta = norm(p - t) * (r1 - r2) / omega;
    [a, da] = difference_derivative(p, dp, t, dt);
    [b, db] = dot_derivative(a, da, a, da);
    [c, dc] = sqrt_derivative(b, db);
    [deltanum, ddeltanum] = product_derivative(c, dc, r, dr);
    [delta, ddelta] = ratio_derivative(deltanum, ddeltanum, omega, domega);
    
    %% w - correction vector, w = delta * u / norm(u);
    [wnum, dwnum] = product_derivative(delta, ddelta, u, du);
    [unorm, dunorm] = sqrt_derivative(uu, duu);
    [w, dw] = ratio_derivative(wnum, dwnum, unorm, dunorm);
    
    %% s - corrected point on the axis, s = t - w
    [s, ds] = difference_derivative(t, dt, w, dw);
    
    %% gamma - correction in the direction orthogonal to cone surface, gamma = (r1 - r2) * norm(c2 - t + w)/ norm(u);
    [a, da] = difference_derivative(c2, dc2, t, dt);
    [b, db] = sum_derivative(a, da, w, dw);
    [c, dc] = dot_derivative(b, db, b, db);
    [gammafactor, dgammafactor] = sqrt_derivative(c, dc);
    [gammanum, dgammanum] = product_derivative(r, dr, gammafactor, dgammafactor);
    [gamma, dgamma] = ratio_derivative(gammanum, dgammanum, unorm, dunorm);
    
    %% q - the point on the model surface, q = s + (p - s) / norm(p - s) * (gamma + r2);
    
    [a, da] = difference_derivative(p, dp, s, ds);
    [qfactor, dqfactor] = normalize_derivative(a, da);
    [b, db] = sum_derivative(gamma, dgamma, r2, dr2);
    [c, dc] = product_derivative(b, db, qfactor, dqfactor);
    [q, dq] = sum_derivative(s, ds, c, dc);    
    
    %% Store result
    f = q;
    gradients{var}.df = dq;
end










