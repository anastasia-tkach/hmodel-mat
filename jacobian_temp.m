function [n1, n2, Jn1, Jn2] = jacobian_temp(c1, c2, c3, r1, r2, r3, variables)

D = length(c1);

for v = 1:length(variables)
    variable = variables{v};
    switch variable
        case 'c1', dc1 = eye(D, D); dc2 = zeros(D, D); dc3 =  zeros(D, D);
            dr1 =  zeros(1, D); dr2 =  zeros(1, D); dr3 =  zeros(1, D);
        case 'c2',  dc1 =  zeros(D, D); dc2 =  eye(D, D); dc3 =  zeros(D, D);
            dr1 =  zeros(1, D); dr2 =  zeros(1, D); dr3 =  zeros(1, D);
        case 'c3', dc1 = zeros(D, D); dc2 =  zeros(D, D); dc3 =  eye(D, D);
            dr1 =  zeros(1, D); dr2 =  zeros(1, D); dr3 =  zeros(1, D);
        case 'r1', dc1=  zeros(D, 1); dc2 =  zeros(D, 1); dc3 =  zeros(D, 1);
            dr1 =  1; dr2 =  0; dr3 =  0;
        case 'r2', dc1 =  zeros(D, 1); dc2 =  zeros(D, 1); dc3 =  zeros(D, 1);
            dr1 =  0; dr2 =  1; dr3 =  0;
        case 'r3', dc1 =  zeros(D, 1); dc2 =  zeros(D, 1); dc3 =  zeros(D, 1);
            dr1 =  0; dr2 =  0; dr3 =  1;
    end
    
    % z12 = c1 + (c2 - c1) * r1 / (r1 - r2);
    [O1, dO1] = difference_derivative(c2, dc2, c1, dc1);
    [O2, dO2] = product_derivative(r1, dr1, O1, dO1);
    [O3, dO3] = difference_derivative(r1, dr1, r2, dr2);
    [O4, dO4] = ratio_derivative(O2, dO2, O3, dO3);
    [z12, dz12] = sum_derivative(O4, dO4, c1, dc1);
    
    % z13 = c1 + (c3 - c1) * r1 / (r1 - r3);
    [O1, dO1] = difference_derivative(c3, dc3, c1, dc1);
    [O2, dO2] = product_derivative(r1, dr1, O1, dO1);
    [O3, dO3] = difference_derivative(r1, dr1, r3, dr3);
    [O4, dO4] = ratio_derivative(O2, dO2, O3, dO3);
    [z13, dz13] = sum_derivative(O4, dO4, c1, dc1);
    
    % l = (z12 - z13) / norm(z12 - z13);
    [O1, dO1] = difference_derivative(z12, dz12, z13, dz13);
    [l, dl] = normalize_derivative(O1, dO1);
    
    % projection = (c1 - z12)' * l;
    [O1, dO1] = difference_derivative(c1, dc1, z12, dz12);
    [projection, dprojection] = dot_derivative(O1, dO1, l, dl);
    
    % z = z12 + projection * l;
    [O1, dO1] = product_derivative(projection, dprojection, l, dl);
    [z, dz] = sum_derivative(z12, dz12, O1, dO1);
    
    % eta = norm(c1 - z);
    [O1, dO1] = difference_derivative(c1, dc1, z, dz);
    [eta, deta] = norm_derivative(O1, dO1);
    
    % sin_beta = r1/norm(c1 - z);
    [sin_beta, dsin_beta] = ratio_derivative(r1, dr1, eta, deta);
    
    % j = sqrt(eta^2 - r1^2);
    [O1, dO1] = dot_derivative(eta, deta, eta, deta);
    [O2, dO2] = dot_derivative(r1, dr1, r1, dr1);
    [O3, dO3] = difference_derivative(O1, dO1, O2, dO2);
    [j, dj] = sqrt_derivative(O3, dO3);
    
    % cos_beta = j/eta;
    [cos_beta, dcos_beta] = ratio_derivative(j, dj, eta, deta);
    
    % f = (c1 - z) / eta;
    [O1, dO1] = difference_derivative(c1, dc1, z, dz);
    [f, df] = ratio_derivative(O1, dO1, eta, deta);
    
    % h = cross(l, f);
    [h, dh] = cross_derivative(l, dl, f, df);
    
    % h = h / norm(h);
    [h, dh] = normalize_derivative(h, dh);
    
    for index = [-1, 1]
        % g = sin_beta * h + cos_beta * f;
        [O1, dO1] = product_derivative(sin_beta, dsin_beta, h, dh);
        O1 = index * O1; dO1 = index * dO1;
        [O2, dO2] = product_derivative(cos_beta, dcos_beta, f, df);
        [g, dg] = sum_derivative(O1, dO1, O2, dO2);
        
        % v1 = z + j * g;
        [O1, dO1] = product_derivative(j, dj, g, dg);
        [v1, dv1] = sum_derivative(z, dz, O1, dO1);
        
        % n = (v1  - c1) / norm(v1  - c1);
        [O1, dO1] = difference_derivative(v1, dv1, c1, dc1);
        [n, dn] = normalize_derivative(O1, dO1);
        
        if (index == 1)
            n1 = n;
            switch variable
                case 'c1', Jn1.dc1 = dn; 
                case 'c2', Jn1.dc2 = dn;
                case 'c3', Jn1.dc3 = dn;
                case 'r1', Jn1.dr1 = dn;
                case 'r2', Jn1.dr2 = dn;
                case 'r3', Jn1.dr3 = dn;
            end
        elseif (index == -1)
            n2 = n;
            switch variable
                case 'c1', Jn2.dc1 = dn; 
                case 'c2', Jn2.dc2 = dn;
                case 'c3', Jn2.dc3 = dn;
                case 'r1', Jn2.dr1 = dn;
                case 'r2', Jn2.dr2 = dn;
                case 'r3', Jn2.dr3 = dn;
            end
        end
    end
end














