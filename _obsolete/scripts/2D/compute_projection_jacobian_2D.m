function [q, m, dm, variables] = compute_projection_jacobian_2D(centers, radii, tangent_gradient, point, index, P, view_axis, H, W)
D = 3;
A = P(:, 1:3);
b = P(:, 4);

%% Compute projection
if length(index) == 1
    [q, dq_dc1, dq_dr1] = jacobian_sphere(point, centers{index(1)}, radii{index(1)});
    variables = {'c1', 'r1'};
end
if length(index) == 2
    [q, dq_dc1, dq_dc2, dq_dr1, dq_dr2] = jacobian_convsegment(point, centers{index(1)}, centers{index(2)}, radii{index(1)}, radii{index(2)});
    variables = {'c1', 'r1', 'c2', 'r2'};
end

for l = 1:length(variables)
    variable = variables{l};
    switch variable
        case 'c1', dq = dq_dc1;
        case 'r1', dq = dq_dr1;
        case 'c2', dq = dq_dc2;
        case 'r2', dq = dq_dr2;
        case 'c3', dq = dq_dc3;
        case 'r3', dq = dq_dr3;
    end
    
    n = A * q + b;
    n1 = n(1); n2 = n(2); n3 = n(3);
    if strcmp(view_axis, 'Y')
        mx = n1/n3;
    else
        mx = W - n1/n3;
    end
    my = n2/n3;
    m = [mx; my];
    
    dn = A * dq;
    dn1 = dn(1, :); dn2 = dn(2, :); dn3 = dn(3, :);
    if strcmp(view_axis, 'Y')
        dmx = (dn1*n3 - n1*dn3)/n3^2;
    else
        dmx = - (dn1*n3 - n1*dn3)/n3^2;
    end
    
    dmy = (dn2*n3 - n2*dn3)/n3^2;
    dm.dv = [dmx; dmy];
    
    switch variable
        case 'c1', dm.dc1 = dm.dv;
        case 'r1', dm.dr1 = dm.dv;
        case 'c2', dm.dc2 = dm.dv;
        case 'r2', dm.dr2 = dm.dv;
        case 'c3', dm.dc3 = dm.dv;
        case 'r3', dm.dr3 = dm.dv;
    end
end


