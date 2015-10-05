clear;
close all;
clc;
D = 3;
while(true)
    c1 = rand(D, 1); c2 = rand(D, 1); c3 = rand(D, 1);
    x1 = rand(1, 1); x2 = rand(1, 1); x3 = rand(1, 1);
    x = [x1, x2, x3];
    [r1, i1] = max(x); [r3, i3] = min(x);
    x([i1, i3]) = 0; r2 = max(x);
    if norm(c1 - c2) > r1 && norm(c1 - c3) > r1 &&  norm(c2 - c3) > r2
        break;
    end
end

%verify_tangent_plane(c1, c2, c3, r1, r2, r3);
factor = 1.5;
x = r1 - r2;
u = c2 - c1;
unorm = norm(u);

z = c1 + u * r1 / x;

w = z - c1;
gamma = u' * (c3 - c1) / (u' * u);
t = c1 + gamma * u;

y = t - c1;
if y' * w > 0 && norm(y) > norm(w)
    t = c1 + w + (z - t);
end
delta_r = norm(c2 - t) * x / unorm;

if y' * u > 0 &&  norm(y) > unorm
    delta_r = -delta_r;
end

r_tilde = delta_r + r2;
sin_beta = x / unorm;
cos_beta = sqrt(1 - sin_beta^2);
r = r_tilde/cos_beta;
eta = r3 + norm(c3 - t);
disp(eta - factor * r)


%function [f, df] = jacobian_tangent_plane_analytical(c1, c2, c3, r1, r2, r3, factor, variables, arguments)

D = length(c1);

arguments = 'c1, c2, c3, r1, r2, r3';
variables = {'c1', 'c2', 'c3', 'r1', 'r2', 'r3'};

c1_ = @(c1, c2, c3, r1, r2, r3) c1;
c2_ = @(c1, c2, c3, r1, r2, r3) c2;
c3_ = @(c1, c2, c3, r1, r2, r3) c3;
r1_ = @(c1, c2, c3, r1, r2, r3) r1;
r2_ = @(c1, c2, c3, r1, r2, r3) r2;
r3_ = @(c1, c2, c3, r1, r2, r3) r3;
factor = @(c1, c2, c3, r1, r2, r3) factor;
dfactor = @(c1, c2, c3, r1, r2, r3) 0;
one = @(c1, c2, c3, r1, r2, r3) 1;
done =  @(c1, c2, c3, r1, r2, r3) 0;

Jnumerical = [];
Janalytical = [];

for var = 1:length(variables)
    variable = variables{var};
    switch variable
        case 'c1', dc1= @(c1, c2, c3, r1, r2, r3) eye(D, D); dc2 = @(c1, c2, c3, r1, r2, r3) zeros(D, D); dc3 = @(c1, c2, c3, r1, r2, r3) zeros(D, D);
            dr1 = @(c1, c2, c3, r1, r2, r3) zeros(1, D); dr2 = @(c1, c2, c3, r1, r2, r3) zeros(1, D); dr3 = @(c1, c2, c3, r1, r2, r3) zeros(1, D);
        case 'c2',  dc1= @(c1, c2, c3, r1, r2, r3) zeros(D, D); dc2 = @(c1, c2, c3, r1, r2, r3) eye(D, D); dc3 = @(c1, c2, c3, r1, r2, r3) zeros(D, D);
            dr1 = @(c1, c2, c3, r1, r2, r3) zeros(1, D); dr2 = @(c1, c2, c3, r1, r2, r3) zeros(1, D); dr3 = @(c1, c2, c3, r1, r2, r3) zeros(1, D);
        case 'c3', dc1= @(c1, c2, c3, r1, r2, r3) zeros(D, D); dc2 = @(c1, c2, c3, r1, r2, r3) zeros(D, D); dc3 = @(c1, c2, c3, r1, r2, r3) eye(D, D);
            dr1 = @(c1, c2, c3, r1, r2, r3) zeros(1, D); dr2 = @(c1, c2, c3, r1, r2, r3) zeros(1, D); dr3 = @(c1, c2, c3, r1, r2, r3) zeros(1, D);
        case 'r1', dc1= @(c1, c2, c3, r1, r2, r3) zeros(D, 1); dc2 = @(c1, c2, c3, r1, r2, r3) zeros(D, 1); dc3 = @(c1, c2, c3, r1, r2, r3) zeros(D, 1);
            dr1 = @(c1, c2, c3, r1, r2, r3) 1; dr2 = @(c1, c2, c3, r1, r2, r3) 0; dr3 = @(c1, c2, c3, r1, r2, r3) 0;
        case 'r2', dc1= @(c1, c2, c3, r1, r2, r3) zeros(D, 1); dc2 = @(c1, c2, c3, r1, r2, r3) zeros(D, 1); dc3 = @(c1, c2, c3, r1, r2, r3) zeros(D, 1);
            dr1 = @(c1, c2, c3, r1, r2, r3) 0; dr2 = @(c1, c2, c3, r1, r2, r3) 1; dr3 = @(c1, c2, c3, r1, r2, r3) 0;
        case 'r3', dc1= @(c1, c2, c3, r1, r2, r3) zeros(D, 1); dc2 = @(c1, c2, c3, r1, r2, r3) zeros(D, 1); dc3 = @(c1, c2, c3, r1, r2, r3) zeros(D, 1);
            dr1 = @(c1, c2, c3, r1, r2, r3) 0; dr2 = @(c1, c2, c3, r1, r2, r3) 0; dr3 = @(c1, c2, c3, r1, r2, r3) 1;
    end
    
    %% z - epix of the tangent cone, z = c1 + (c2 - c1) * r1 / (r1 - r2);
    [x, dx] = difference_handle(r1_, dr1, r2_, dr2, arguments);
    [u, du] = difference_handle(c2_, dc2, c1_, dc1, arguments);
    [unorm, dunorm] = norm_handle(u, du, arguments);
    
    [a, da] = product_handle(r1_, dr1, u, du, arguments);
    [b, db] = ratio_handle(a, da, x, dx, arguments);
    [z, dz] = sum_handle(c1_, dc1, b, db, arguments);
    
    %% t - rojection of c3 of the axis c1-c2,  gamma = u' * (c3 - c1) / (u' * u); t = c1 + gamma * u;
    
    [a, da] = difference_handle(c3_, dc3, c1_, dc1, arguments);
    [b, db] = dot_handle(u, du, u, du, arguments);
    [c, dc] = ratio_handle(a, da, b, db, arguments);
    [gamma, dgamma] = dot_handle(u, du, c, dc, arguments);
    
    [d, dd] = product_handle(gamma, dgamma, u, du, arguments);
    [t, dt] = sum_handle(c1_, dc1, d, dd, arguments);
    
    %% What if projection of c3 is outside c1-c2
    w = z(c1, c2, c3, r1, r2, r3) - c1;
    y = t(c1, c2, c3, r1, r2, r3) - c1;
    if y' * w > 0 && norm(y) > norm(w)
        [a, da] = difference_handle(z, dz, t, dt, arguments);
        [b, db] = difference_handle(z, dz, c1_, dc1, arguments); 
        [c, dc] = sum_handle(b, db, a, da, arguments);
        [t, dt] = sum_handle(c1_, dc1, c, dc, arguments);
    end
    
    %% delta_r - linear part of the radius at point t, delta_r = norm(c2 - t) * x / unorm;
   
    [a, da] = ratio_handle(x, dx, unorm, dunorm, arguments);
    [b, db] = difference_handle(c2_, dc2, t, dt, arguments);
    [c, dc] = norm_handle(b, db, arguments);
    [delta_r, ddelta_r] = product_handle(c, dc, a, da, arguments);
    
    if y' * u(c1, c2, c3, r1, r2, r3) > 0 && norm(y) > unorm(c1, c2, c3, r1, r2, r3)
       [delta_r, ddelta_r] = minus_handle(delta_r, ddelta_r, arguments);
    end
    
    %% r - orthogonal radius of cone at t,  r_tilde = delta_r + r2; sin_beta = x / unorm; cos_beta = sqrt(1 - sin_beta^2);  r = r_tilde/cos_beta;
    
    [r_tilde, dr_tilde] = sum_handle(delta_r, ddelta_r, r2_, dr2, arguments);
    [sin_beta, dsin_beta] = ratio_handle(x, dx, unorm, dunorm, arguments);
    [a, da] = product_handle(sin_beta, dsin_beta, sin_beta, dsin_beta, arguments);
    [b, db] = difference_handle(one, done, a, da, arguments);
    [cos_beta, dcos_beta] = sqrt_handle(b, db, arguments);
    [r, dr] = ratio_handle(r_tilde, dr_tilde, cos_beta, dcos_beta, arguments);
    
    %% eta - orthogonal distance from c3 to the axis, eta = r3 + norm(c3 - t);
    [a, da] = difference_handle(c3_, dc3, t, dt, arguments);
    [b, db] = norm_handle(a, da, arguments);
    [eta, deta] = sum_handle(r3_, dr3, b, db, arguments);
    
    %% objective function, f = eta - factor * r
    
    [a, da] = product_handle(factor, dfactor, r, dr, arguments);
    [f_, df_] = difference_handle(eta, deta, a, da, arguments);
    
    O = f_;
    dO = df_;
    %% Display result
    switch variable
        case 'c1'
            O = @(c1) O(c1, c2, c3, r1, r2, r3);
            Jnumerical = [Jnumerical, my_gradient(O, c1)];
            Janalytical = [Janalytical, dO(c1, c2, c3, r1, r2, r3)];
        case 'c2'
            O = @(c2) O(c1, c2, c3, r1, r2, r3);
            Jnumerical = [Jnumerical, my_gradient(O, c2)];
            Janalytical = [Janalytical, dO(c1, c2, c3, r1, r2, r3)];
        case 'c3'
            O = @(c3) O(c1, c2, c3, r1, r2, r3);
            Jnumerical = [Jnumerical, my_gradient(O, c3)];
            Janalytical = [Janalytical, dO(c1, c2, c3, r1, r2, r3)];
        case 'r1'
            O = @(r1) O(c1, c2, c3, r1, r2, r3);
            Jnumerical = [Jnumerical, my_gradient(O, r1)];
            Janalytical = [Janalytical, dO(c1, c2, c3, r1, r2, r3)];
        case 'r2'
            O = @(r2) O(c1, c2, c3, r1, r2, r3);
            Jnumerical = [Jnumerical, my_gradient(O, r2)];
            Janalytical = [Janalytical, dO(c1, c2, c3, r1, r2, r3)];
        case 'r3'
            O = @(r3) O(c1, c2, c3, r1, r2, r3);
            Jnumerical = [Jnumerical, my_gradient(O, r3)];
            Janalytical = [Janalytical, dO(c1, c2, c3, r1, r2, r3)];
    end
end
O(r3)
Jnumerical
Janalytical
