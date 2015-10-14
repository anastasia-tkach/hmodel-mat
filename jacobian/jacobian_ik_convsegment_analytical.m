clc; clear;
D = 2;
while(true)
    e1 = 0.5 * rand(D ,1);
    e2 = 0.5 * rand(D ,1);
    x1 = rand(1 ,1);
    x2 = rand(1 ,1);
    r1 = max(x1, x2);
    r2 = min(x1, x2);
    p = rand(D, 1);
    if norm(e1 - e2) > r1
        break;
    end
end
a1 = randn(1, 1)/pi;
a2 = randn(1, 1)/pi;
d1 = rand;
d2 = rand;

% function [q, dq_dc1, dq_dc2, dq_dr1, dq_dr2] = jacobian_ik_convsegment_analytical(p, c1, c2, r1, r2)

R1 = [cos(a1), -sin(a1); sin(a1), cos(a1)];
R2 = [cos(a2), -sin(a2); sin(a2), cos(a2)];
w1 =  R1 * [1; 0];
w2 =  R2 * [1; 0];
b1 = d1 * w1;
b2 = d2 * w2;
c1 =  e1 + b1;
c2 =  e2 + b2;

u = c2 - c1;
v = p - c1;
alpha = u' * v / (u' * u);
t = c1 + alpha * u;
omega = sqrt(u' * u - (r1 - r2)^2);
delta =  norm(p - t) * (r1 - r2) / omega;
w = u * delta/ norm(u);
s = t - w;
gamma = (r1 - r2) * norm(c2 - t + w)/ norm(u);
q = s + (p - s) / norm(p - s) * (gamma + r2);
disp(q);

arguments = 'c1, c2, a1, a2';
variables = {'c1', 'c2', 'a1', 'a2'};
p_ = @(e1, e2, a1, a2) p;
e1_ = @(e1, e2, a1, a2) e1;
e2_ = @(e1, e2, a1, a2) e2;
r1_ = @(e1, e2, a1, a2) r1;
r2_ = @(e1, e2, a1, a2) r2;
d1_ = @(e1, e2, a1, a2) d1;
d2_ = @(e1, e2, a1, a2) d2;
w1 = @(e1, e2, a1, a2) [cos(a1); sin(a1)];
w2 = @(e1, e2, a1, a2) [cos(a2); sin(a2)];

Jnumerical = [];
Janalytical = [];

for var = 1:length(variables)
    variable = variables{var};
    switch variable
        case 'c1', de1 = @(e1, e2, a1, a2) eye(D, D); de2 = @(e1, e2, a1, a2) zeros(D, D);
            dr1 = @(c1, c2, r1, r2) zeros(1, D); dr2 = @(c1, c2, r1, r2) zeros(1, D);
            dw1 = @(e1, e2, a1, a2) zeros(D, D); dw2 = @(e1, e2, a1, a2) zeros(D, D);
            dd1 = @(e1, e2, a1, a2) zeros(1, D); dd2 = @(e1, e2, a1, a2) zeros(1, D);
            dp = @(e1, e2, a1, a2) zeros(D, D);
        case 'c2',  de1 = @(e1, e2, a1, a2) zeros(D, D); de2 = @(e1, e2, a1, a2) eye(D, D);
            dr1 = @(c1, c2, r1, r2) zeros(1, D); dr2 = @(c1, c2, r1, r2) zeros(1, D);
            dw1 = @(e1, e2, a1, a2) zeros(D, D); dw2 = @(e1, e2, a1, a2) zeros(D, D);
            dd1 = @(e1, e2, a1, a2) zeros(1, D); dd2 = @(e1, e2, a1, a2) zeros(1, D);
            dp = @(e1, e2, a1, a2) zeros(D, D);
        case 'a1', de1 = @(e1, e2, a1, a2) zeros(D, 1); de2 = @(e1, e2, a1, a2) zeros(D, 1);
            dr1 = @(c1, c2, r1, r2) 0; dr2 = @(c1, c2, r1, r2) 0;
            dw1 = @(e1, e2, a1, a2) [-sin(a1); cos(a1)]; dw2 = @(e1, e2, a1, a2) zeros(D, 1);
            dd1 = @(e1, e2, a1, a2) zeros(1, 1); dd2 = @(e1, e2, a1, a2) zeros(1, 1);
            dp = @(e1, e2, a1, a2) zeros(D, 1);
        case 'a2', de1 = @(e1, e2, a1, a2) zeros(D, 1); de2 = @(e1, e2, a1, a2) zeros(D, 1);
            dr1 = @(c1, c2, r1, r2) 0; dr2 = @(c1, c2, r1, r2) 0;
            dw1 = @(e1, e2, a1, a2) zeros(D, 1); dw2 = @(e1, e2, a1, a2) [-sin(a2); cos(a2)];
            dd1 = @(e1, e2, a1, a2) zeros(1, 1); dd2 = @(e1, e2, a1, a2) zeros(1, 1);
            dp = @(e1, e2, a1, a2) zeros(D, 1);
    end
    
    %% b1 = d1 * w1; b2 = d2 * w2;
    [b1, db1] = product_handle(d1_, dd1, w1, dw1, arguments);
    [b2, db2] = product_handle(d2_, dd2, w2, dw2, arguments);
    [c1_, dc1] = sum_handle(e1_, de1, b1, db1, arguments);
    [c2_, dc2] = sum_handle(e2_, de2, b2, db2, arguments);
    
    %% u =  c2 - c1; v =  p - c1;
    [u, du] = difference_handle(c2_, dc2, c1_, dc1, arguments);
    [v, dv] = difference_handle(p_, dp, c1_, dc1, arguments);
    
    %% t - closest point on the axis, t = c1 + alpha * u;
    [s, ds] = dot_handle(u, du, v, dv, arguments);
    [tn, dtn] = product_handle(s, ds, u, du, arguments);
    [uu, duu] = dot_handle(u, du, u, du, arguments);
    [b, db] = ratio_handle(tn, dtn, uu, duu, arguments);
    [t, dt] =  sum_handle(c1_, dc1, b, db, arguments);
    
    %% omega - lenght of the tangent, omega = sqrt(u' * u - (r1 - r2)^2);
    [r, dr] = difference_handle(r1_, dr1, r2_, dr2, arguments);
    [c, dc] = product_handle(r, dr, r, dr, arguments);
    [omega2, domega2] = difference_handle(uu, duu, c, dc, arguments);
    [omega, domega] = sqrt_handle(omega2, domega2, arguments);
    
    %% delta - size of the correction, % delta =  norm(p - t) * (r1 - r2) / omega;
    [a, da] = difference_handle(p_, dp, t, dt, arguments);
    [b, db] = dot_handle(a, da, a, da, arguments);
    [c, dc] = sqrt_handle(b, db, arguments);
    [deltanum, ddeltanum] = product_handle(c, dc, r, dr, arguments);
    [delta, ddelta] = ratio_handle(deltanum, ddeltanum, omega, domega, arguments);
    
    %% w - correction vector, w = delta * u / norm(u);
    [wnum, dwnum] = product_handle(delta, ddelta, u, du, arguments);
    [unorm, dunorm] = sqrt_handle(uu, duu, arguments);
    [w, dw] = ratio_handle(wnum, dwnum, unorm, dunorm, arguments);
    
    %% s - corrected point on the axis, s = t - w
    [s, ds] =  difference_handle(t, dt, w, dw, arguments);
    
    %% gamma - correction in the direction orthogonal to cone surface, gamma = (r1 - r2) * norm(c2 - t + w)/ norm(u);
    [a, da] = difference_handle(c2_, dc2, t, dt, arguments);
    [b, db] = sum_handle(a, da, w, dw, arguments);
    [c, dc] = dot_handle(b, db, b, db, arguments);
    [gammafactor, dgammafactor] = sqrt_handle(c, dc, arguments);
    [gammanum, dgammanum] =  product_handle(r, dr, gammafactor, dgammafactor, arguments);
    [gamma, dgamma] = ratio_handle(gammanum, dgammanum, unorm, dunorm, arguments);
    
    %% q - the point on the model surface, q = s + (p - s) / norm(p - s) * (gamma + r2);
    
    [a, da] = difference_handle(p_, dp, s, ds, arguments);
    [qfactor, dqfactor] = normalize_handle(a, da, arguments);
    [b, db] = sum_handle(gamma, dgamma, r2_, dr2, arguments);
    [c, dc] = product_handle(b, db, qfactor, dqfactor, arguments);
    [q, dq] = sum_handle(s, ds, c, dc, arguments);
    O = q;
    dO = dq;
    %% Display result
    switch variable
        case 'c1'
            O = @(e1) O(e1, e2, a1, a2);
            Jnumerical = [Jnumerical, my_gradient(O, e1)];
            Janalytical = [Janalytical, dO(e1, e2, a1, a2)];
        case 'c2'
            O = @(e2) O(e1, e2, a1, a2);
            Jnumerical = [Jnumerical, my_gradient(O, e2)];
            Janalytical = [Janalytical, dO(e1, e2, a1, a2)];
        case 'a1'
            O = @(a1) O(e1, e2, a1, a2);
            Jnumerical = [Jnumerical, my_gradient(O, a1)];
            Janalytical = [Janalytical, dO(e1, e2, a1, a2)];
        case 'a2'
            O = @(a2) O(e1, e2, a1, a2);
            Jnumerical = [Jnumerical, my_gradient(O, a2)];
            Janalytical = [Janalytical, dO(e1, e2, a1, a2)];
    end
end
O(a2)
Jnumerical
Janalytical










