function [f, df] = jacobian_ik_convsegment(p, e1, e2, r1, r2, d1, d2, a1, a2)

variables = {'c1', 'c2', 'a1', 'a2'};
w1 = [cos(a1); sin(a1)];
w2 = [cos(a2); sin(a2)];

for var = 1:length(variables)
    variable = variables{var};
    switch variable
        case 'c1', de1 = eye(D, D); de2 = zeros(D, D);
            dr1 = zeros(1, D); dr2 = zeros(1, D);
            dw1 = zeros(D, D); dw2 = zeros(D, D);
            dd1 = zeros(1, D); dd2 = zeros(1, D);
            dp = zeros(D, D);
        case 'c2',  de1 = zeros(D, D); de2 = eye(D, D);
            dr1 = zeros(1, D); dr2 = zeros(1, D);
            dw1 = zeros(D, D); dw2 = zeros(D, D);
            dd1 = zeros(1, D); dd2 = zeros(1, D);
            dp = zeros(D, D);
        case 'a1', de1 = zeros(D, 1); de2 = zeros(D, 1);
            dr1 = @(c1, c2, r1, r2) 0; dr2 = @(c1, c2, r1, r2) 0;
            dw1 = [-sin(a1); cos(a1)]; dw2 = zeros(D, 1);
            dd1 = zeros(1, 1); dd2 = zeros(1, 1);
            dp = zeros(D, 1);
        case 'a2', de1 = zeros(D, 1); de2 = zeros(D, 1);
            dr1 = @(c1, c2, r1, r2) 0; dr2 = @(c1, c2, r1, r2) 0;
            dw1 = zeros(D, 1); dw2 = [-sin(a2); cos(a2)];
            dd1 = zeros(1, 1); dd2 = zeros(1, 1);
            dp = zeros(D, 1);
    end
    
    %% b1 = d1 * w1; b2 = d2 * w2;
    [b1, db1] = product_handle(d1, dd1, w1, dw1);
    [b2, db2] = product_handle(d2, dd2, w2, dw2);
    [c1, dc1] = sum_handle(e1, de1, b1, db1);
    [c2, dc2] = sum_handle(e2, de2, b2, db2);
    
    %% u =  c2 - c1; v =  p - c1;
    [u, du] = difference_handle(c2, dc2, c1, dc1);
    [v, dv] = difference_handle(p, dp, c1, dc1);
    
    %% t - closest point on the axis, t = c1 + alpha * u;
    [s, ds] = dot_handle(u, du, v, dv);
    [tn, dtn] = product_handle(s, ds, u, du);
    [uu, duu] = dot_handle(u, du, u, du);
    [b, db] = ratio_handle(tn, dtn, uu, duu);
    [t, dt] =  sum_handle(c1, dc1, b, db);
    
    %% omega - lenght of the tangent, omega = sqrt(u' * u - (r1 - r2)^2);
    [r, dr] = difference_handle(r1, dr1, r2, dr2);
    [c, dc] = product_handle(r, dr, r, dr);
    [omega2, domega2] = difference_handle(uu, duu, c, dc);
    [omega, domega] = sqrt_handle(omega2, domega2);
    
    %% delta - size of the correction, % delta =  norm(p - t) * (r1 - r2) / omega;
    [a, da] = difference_handle(p, dp, t, dt);
    [b, db] = dot_handle(a, da, a, da);
    [c, dc] = sqrt_handle(b, db);
    [deltanum, ddeltanum] = product_handle(c, dc, r, dr);
    [delta, ddelta] = ratio_handle(deltanum, ddeltanum, omega, domega);
    
    %% w - correction vector, w = delta * u / norm(u);
    [wnum, dwnum] = product_handle(delta, ddelta, u, du);
    [unorm, dunorm] = sqrt_handle(uu, duu);
    [w, dw] = ratio_handle(wnum, dwnum, unorm, dunorm);
    
    %% s - corrected point on the axis, s = t - w
    [s, ds] =  difference_handle(t, dt, w, dw);
    
    %% gamma - correction in the direction orthogonal to cone surface, gamma = (r1 - r2) * norm(c2 - t + w)/ norm(u);
    [a, da] = difference_handle(c2, dc2, t, dt);
    [b, db] = sum_handle(a, da, w, dw);
    [c, dc] = dot_handle(b, db, b, db);
    [gammafactor, dgammafactor] = sqrt_handle(c, dc);
    [gammanum, dgammanum] =  product_handle(r, dr, gammafactor, dgammafactor);
    [gamma, dgamma] = ratio_handle(gammanum, dgammanum, unorm, dunorm);
    
    %% q - the point on the model surface, q = s + (p - s) / norm(p - s) * (gamma + r2);
    
    [a, da] = difference_handle(p, dp, s, ds);
    [qfactor, dqfactor] = normalize_handle(a, da);
    [b, db] = sum_handle(gamma, dgamma, r2, dr2);
    [c, dc] = product_handle(b, db, qfactor, dqfactor);
    [q, dq] = sum_handle(s, ds, c, dc);
    f = q;

    %% Display result
    switch variable
        case 'c1', df.dc1 = dq;
        case 'c2', df.dc2 = dq;
        case 'a1', df.da1 = dq;
        case 'a2', df.da2 = dq;   
    end
end










