function [] = energy1_case3_analytical(p, c1, c2, c3, r1, r2, r3, index, D)

arguments = 'c1, c2, c3, r1, r2, r3';
variables = {'c1', 'c2', 'c3', 'r1', 'r2', 'r3'};

c1_ = @(c1, c2, c3, r1, r2, r3) c1;
c2_ = @(c1, c2, c3, r1, r2, r3) c2;
c3_ = @(c1, c2, c3, r1, r2, r3) c3;
r1_ = @(c1, c2, c3, r1, r2, r3) r1;
r2_ = @(c1, c2, c3, r1, r2, r3) r2;
r3_ = @(c1, c2, c3, r1, r2, r3) r3;

Jnumerical = [];
Janalytical = [];
p_ = @(c1, c2, c3, r1, r2, r3) p;
dp = @(c1, c2, c3, r1, r2, r3) zeros(D, D);
for v = 1:length(variables)
    variable = variables{v};
    switch variable
        case 'c1', dc1= @(c1, c2, c3, r1, r2, r3) eye(D, D); dc2 = @(c1, c2, c3, r1, r2, r3) zeros(D, D); dc3 = @(c1, c2, c3, r1, r2, r3) zeros(D, D);
            dr1 = @(c1, c2, c3, r1, r2, r3) zeros(1, D); dr2 = @(c1, c2, c3, r1, r2, r3) zeros(1, D); dr3 = @(c1, c2, c3, r1, r2, r3) zeros(1, D);
            dp = @(c1, c2, c3, r1, r2, r3) zeros(D, D);
        case 'c2',  dc1= @(c1, c2, c3, r1, r2, r3) zeros(D, D); dc2 = @(c1, c2, c3, r1, r2, r3) eye(D, D); dc3 = @(c1, c2, c3, r1, r2, r3) zeros(D, D);
            dr1 = @(c1, c2, c3, r1, r2, r3) zeros(1, D); dr2 = @(c1, c2, c3, r1, r2, r3) zeros(1, D); dr3 = @(c1, c2, c3, r1, r2, r3) zeros(1, D);
            dp = @(c1, c2, c3, r1, r2, r3) zeros(D, D);
        case 'c3', dc1= @(c1, c2, c3, r1, r2, r3) zeros(D, D); dc2 = @(c1, c2, c3, r1, r2, r3) zeros(D, D); dc3 = @(c1, c2, c3, r1, r2, r3) eye(D, D);
            dr1 = @(c1, c2, c3, r1, r2, r3) zeros(1, D); dr2 = @(c1, c2, c3, r1, r2, r3) zeros(1, D); dr3 = @(c1, c2, c3, r1, r2, r3) zeros(1, D);
            dp = @(c1, c2, c3, r1, r2, r3) zeros(D, D);
        case 'r1', dc1= @(c1, c2, c3, r1, r2, r3) zeros(D, 1); dc2 = @(c1, c2, c3, r1, r2, r3) zeros(D, 1); dc3 = @(c1, c2, c3, r1, r2, r3) zeros(D, 1);
            dr1 = @(c1, c2, c3, r1, r2, r3) 1; dr2 = @(c1, c2, c3, r1, r2, r3) 0; dr3 = @(c1, c2, c3, r1, r2, r3) 0;
            dp = @(c1, c2, c3, r1, r2, r3) zeros(D, 1);
        case 'r2', dc1= @(c1, c2, c3, r1, r2, r3) zeros(D, 1); dc2 = @(c1, c2, c3, r1, r2, r3) zeros(D, 1); dc3 = @(c1, c2, c3, r1, r2, r3) zeros(D, 1);
            dr1 = @(c1, c2, c3, r1, r2, r3) 0; dr2 = @(c1, c2, c3, r1, r2, r3) 1; dr3 = @(c1, c2, c3, r1, r2, r3) 0;
            dp = @(c1, c2, c3, r1, r2, r3) zeros(D, 1);
        case 'r3', dc1= @(c1, c2, c3, r1, r2, r3) zeros(D, 1); dc2 = @(c1, c2, c3, r1, r2, r3) zeros(D, 1); dc3 = @(c1, c2, c3, r1, r2, r3) zeros(D, 1);
            dr1 = @(c1, c2, c3, r1, r2, r3) 0; dr2 = @(c1, c2, c3, r1, r2, r3) 0; dr3 = @(c1, c2, c3, r1, r2, r3) 1;
            dp = @(c1, c2, c3, r1, r2, r3) zeros(D, 1);
    end
    
    % z12 = c1 + (c2 - c1) * r1 / (r1 - r2);
    [O1, dO1] = difference_handle(c2_, dc2, c1_, dc1, arguments);
    [O2, dO2] = product_handle(r1_, dr1, O1, dO1, arguments);
    [O3, dO3] = difference_handle(r1_, dr1, r2_, dr2, arguments);
    [O4, dO4] = ratio_handle(O2, dO2, O3, dO3, arguments);
    [z12, dz12] = sum_handle(O4, dO4, c1_, dc1, arguments);
    
    % z13 = c1 + (c3 - c1) * r1 / (r1 - r3);
    [O1, dO1] = difference_handle(c3_, dc3, c1_, dc1, arguments);
    [O2, dO2] = product_handle(r1_, dr1, O1, dO1, arguments);
    [O3, dO3] = difference_handle(r1_, dr1, r3_, dr3, arguments);
    [O4, dO4] = ratio_handle(O2, dO2, O3, dO3, arguments);
    [z13, dz13] = sum_handle(O4, dO4, c1_, dc1, arguments);
    
    % l = (z12 - z13) / norm(z12 - z13);
    [O1, dO1] = difference_handle(z12, dz12, z13, dz13, arguments);
    [l, dl] = normalize_handle(O1, dO1, arguments);
    
    % projection = (c1 - z12)' * l;
    [O1, dO1] = difference_handle(c1_, dc1, z12, dz12, arguments);
    [projection, dprojection] = dot_handle(O1, dO1, l, dl, arguments);
    
    % z = z12 + projection * l;
    [O1, dO1] = product_handle(projection, dprojection, l, dl, arguments);
    [z, dz] = sum_handle(z12, dz12, O1, dO1, arguments);
    
    % eta = norm(c1 - z);
    [O1, dO1] = difference_handle(c1_, dc1, z, dz, arguments);
    [eta, deta] = norm_handle(O1, dO1, arguments);
    
    % sin_beta = r1/norm(c1 - z);
    [sin_beta, dsin_beta] = ratio_handle(r1_, dr1, eta, deta, arguments);
    
    % j = sqrt(eta^2 - r1^2);
    [O1, dO1] = dot_handle(eta, deta, eta, deta, arguments);
    [O2, dO2] = dot_handle(r1_, dr1, r1_, dr1, arguments);
    [O3, dO3] = difference_handle(O1, dO1, O2, dO2, arguments);
    [j, dj] = sqrt_handle(O3, dO3, arguments);
    
    % cos_beta = j/eta;
    [cos_beta, dcos_beta] = ratio_handle(j, dj, eta, deta, arguments);
    
    % f = (c1 - z) / eta;
    [O1, dO1] = difference_handle(c1_, dc1, z, dz, arguments);
    [f, df] = ratio_handle(O1, dO1, eta, deta, arguments);
    
    % h = cross(l, f);
    [h, dh] = cross_handle(l, dl, f, df, arguments);
    
    % h = h / norm(h);
    [h, dh] = normalize_handle(h, dh, arguments);
    
    % g = sin_beta * h + cos_beta * f;
    [O1, dO1] = product_handle(sin_beta, dsin_beta, h, dh, arguments);
    
    if (index == -1)
        [O1, dO1] = minus_handle(O1, dO1, arguments);
    end
    [O2, dO2] = product_handle(cos_beta, dcos_beta, f, df, arguments);
    [g, dg] = sum_handle(O1, dO1, O2, dO2, arguments);
    
    % v1 = z + j * g;
    [O1, dO1] = product_handle(j, dj, g, dg, arguments);
    [v1, dv1] = sum_handle(z, dz, O1, dO1, arguments);
    
    % n = (v1  - c1) / norm(v1  - c1);
    [O1, dO1] = difference_handle(v1, dv1, c1_, dc1, arguments);
    [n, dn] = normalize_handle(O1, dO1, arguments);
    
    % v2 = c2 + r2 * n;
    [O1, dO1] = product_handle(r2_, dr2, n, dn, arguments);
    [v2, dv2] = sum_handle(c2_, dc2, O1, dO1, arguments);
    
    % v3 = c3 + r3 * n;
    [O1, dO1] = product_handle(r3_, dr3, n, dn, arguments);
    [v3, dv3] = sum_handle(c3_, dc3, O1, dO1, arguments);
    
    % m = cross(v1 - v2, v1 - v3);
    [O1, dO1] = difference_handle(v1, dv1, v2, dv2, arguments);
    [O2, dO2] = difference_handle(v1, dv1, v3, dv3, arguments);
    [m, dm] = cross_handle(O1, dO1, O2, dO2, arguments);
    
    % m = m / norm(m);
    [m, dm] = normalize_handle(m, dm, arguments);
    
    % distance = (p - v1)' * m;    
    [O1, dO1] = difference_handle(p_, dp, v1, dv1, arguments);
    [distance, ddistance] = dot_handle(O1, dO1, m, dm, arguments);
    
    % t = p - distance * m;
    [O1, dO1] = product_handle(distance, ddistance, m, dm, arguments);
    [t, dt] = difference_handle(p_, dp, O1, dO1, arguments);
    
     % f = norm(p - t)
    [O1, dO1] = difference_handle(p_, dp, t, dt, arguments);
    [O, dO] = norm_handle(O1, dO1, arguments);    
   
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

disp(Janalytical);








