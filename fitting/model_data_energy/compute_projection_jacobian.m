function [q, m, dm, variables] = compute_projection_jacobian(centers, radii, tangent_gradient, point, index, P, view_axis, settings)
H = settings.H; W = settings.W; D = settings.D;
A = P(:, 1:D);
b = P(:, D + 1);

%% Compute projection
if length(index) == 1
    [q, dq_dc1, dq_dr1] = jacobian_sphere(point, centers{index(1)}, radii{index(1)});
    variables = {'c1', 'r1'};
end
if length(index) == 2
    [q, dq_dc1, dq_dc2, dq_dr1, dq_dr2] = jacobian_convsegment(point, centers{index(1)}, centers{index(2)}, radii{index(1)}, radii{index(2)});
    variables = {'c1', 'r1', 'c2', 'r2'};
end
if length(index) == 3
    v1 = tangent_gradient.v1; v2 = tangent_gradient.v2; v3 = tangent_gradient.v3;
    u1 = tangent_gradient.u1; u2 = tangent_gradient.u2; u3 = tangent_gradient.u3;
    Jv1 = tangent_gradient.Jv1; Jv2 = tangent_gradient.Jv2; Jv3 = tangent_gradient.Jv3;
    Ju1 = tangent_gradient.Ju1; Ju2 = tangent_gradient.Ju2; Ju3 = tangent_gradient.Ju3;
    if (index(1) > 0)
        [q, dq_dc1, dq_dc2, dq_dc3, dq_dr1, dq_dr2, dq_dr3] = jacobian_convtriangle(point, v1, v2, v3, Jv1, Jv2, Jv3, D);
    else
        [q, dq_dc1, dq_dc2, dq_dc3, dq_dr1, dq_dr2, dq_dr3] = jacobian_convtriangle(point, u1, u2, u3, Ju1, Ju2, Ju3, D);
    end
    variables = {'c1', 'r1', 'c2', 'r2', 'c3', 'r3'};
end

if D == 2 && strcmp(view_axis, 'X')
    q = [q(2); q(1)];
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
    
    if D == 2
        if strcmp(view_axis, 'X')
            dq = [dq(2, :); dq(1, :)];
        end
        n = A * q + b;
        dn = A * dq;
        n1 = n(1); n2 = n(2);
        dn1 = dn(1, :); dn2 = dn(2, :);
        m = n1 / n2;
        dm.dv = (dn1 * n2 - n1 * dn2) / n2^2;
    else
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
    end
    
    switch variable
        case 'c1', dm.dc1 = dm.dv;
        case 'r1', dm.dr1 = dm.dv;
        case 'c2', dm.dc2 = dm.dv;
        case 'r2', dm.dr2 = dm.dv;
        case 'c3', dm.dc3 = dm.dv;
        case 'r3', dm.dr3 = dm.dv;
    end
end

% vector_entry = @(vector, index) vector(index);
% matrix_row = @(matrix, index) matrix(index, :);
% dq = eye(3, 3);
% n = @(q) A * q + b;
% dn = @(q) A * dq;
% n1 = @(q) vector_entry(n(q), 1);
% n2 = @(q) vector_entry(n(q), 2);
% n3 = @(q) vector_entry(n(q), 3);
% dn1 = @(q) matrix_row(dn(q), 1);
% dn2 = @(q) matrix_row(dn(q), 2);
% dn3 = @(q) matrix_row(dn(q), 3);
%
% mx = @(q) W - n1(q) / n3(q);
% dmx = @(q) - (dn1(q) * n3(q) - n1(q) * dn3(q)) / n3(q)^2;
% my = @(q) n2(q) / n3(q);
% dmy = @(q) (dn2(q) * n3(q) - n2(q) * dn3(q)) / n3(q)^2;
%
% disp([my_gradient(mx, q); my_gradient(my, q)]);
% disp([dmx(q); dmy(q)]);
