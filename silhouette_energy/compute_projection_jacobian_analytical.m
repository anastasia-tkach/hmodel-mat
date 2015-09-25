function [q, m, m_analyt, dm, variables] = compute_projection_jacobian_analytical(centers, radii, tangent_gradient, point, index, P, view_axis, H, W)
D = 3;
A = P(:, 1:3);
b = P(:, 4);

vector_entry = @(vector, index) vector(index);
matrix_row = @(matrix, index) matrix(index, :);

%% Compute projection
if length(index) == 1
    c1 = centers{index(1)};
    r1 = radii{index(1)};
    [q, dq_dc1, dq_dr1] = jacobian_sphere_analytical(point, centers{index(1)}, radii{index(1)});
    variables = {'c1', 'r1'};
end
if length(index) == 2
    c1 = centers{index(1)};
    c2 = centers{index(2)};
    r1 = radii{index(1)};
    r2 = radii{index(2)};
    [q, dq_dc1, dq_dc2, dq_dr1, dq_dr2] = jacobian_convsegment_analytical(point, centers{index(1)}, centers{index(2)}, radii{index(1)}, radii{index(2)});
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

if length(index) == 1
    for l = 1:length(variables)
        variable = variables{l};
        switch variable
            case 'c1', dq = dq_dc1;
            case 'r1', dq = dq_dr1;
        end
        
        n = @(c1, r1) A * q(c1, r1) + b;
        dn = @(c1, r1) A * dq(c1, r1);
        n1 = @(c1, r1) vector_entry(n(c1, r1), 1);
        n2 = @(c1, r1) vector_entry(n(c1, r1), 2);
        n3 = @(c1, r1) vector_entry(n(c1, r1), 3);
        dn1 = @(c1, r1) matrix_row(dn(c1, r1), 1);
        dn2 = @(c1, r1) matrix_row(dn(c1, r1), 2);
        dn3 = @(c1, r1) matrix_row(dn(c1, r1), 3);
        
        
        if strcmp(view_axis, 'Y')
            mx = @(c1, r1) n1(c1, r1) / n3(c1, r1);
            dmx = @(c1, r1) (dn1(c1, r1) * n3(c1, r1) - n1(c1, r1) * dn3(c1, r1)) / n3(c1, r1)^2;
        else
            mx = @(c1, r1) W - n1(c1, r1) / n3(c1, r1);
            dmx = @(c1, r1) - (dn1(c1, r1) * n3(c1, r1) - n1(c1, r1) * dn3(c1, r1)) / n3(c1, r1)^2;
        end
        
        my = @(c1, r1) n2(c1, r1) / n3(c1, r1);
        dmy = @(c1, r1) (dn2(c1, r1) * n3(c1, r1) - n2(c1, r1) * dn3(c1, r1)) / n3(c1, r1)^2;
        m = @(c1, r1) [mx(c1, r1); my(c1, r1)];
        m_analyt = m;
        dm.dv = @(c1, r1) [dmx(c1, r1); dmy(c1, r1)];
        
        switch variable
            case 'c1'
                m_c1 = @(c1) m(c1, r1);
                dm_dc1 = my_gradient(m_c1, c1);
                % disp(my_gradient(m_c1, c1));
                % disp(dm.dv(c1, r1));
                dm.dc1 = dm.dv(c1, r1);
                dm.dc1_analyt = dm.dv;
                if norm(dm_dc1 - dm.dc1) > 1e-4
                    disp('Error');
                end
            case 'r1'
                m_r1 = @(r1) m(c1, r1);
                dm_dr1 = my_gradient(m_r1, r1);
                disp([my_gradient(m_r1, r1), dm.dv(c1, r1)]');
                
                dm.dr1 = dm.dv(c1, r1);
                dm.dr1_analyt = dm.dv;
                if norm(dm_dr1 - dm.dr1) > 1e-4
                    disp('Error');
                end
        end
    end
    m = m(c1, r1);
end



if length(index) == 2
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

        n = @(c1, c2, r1, r2) A * q(c1, c2, r1, r2) + b;
        dn = @(c1, c2, r1, r2) A * dq(c1, c2, r1, r2);
        n1 = @(c1, c2, r1, r2) vector_entry(n(c1, c2, r1, r2), 1);
        n2 = @(c1, c2, r1, r2) vector_entry(n(c1, c2, r1, r2), 2);
        n3 = @(c1, c2, r1, r2) vector_entry(n(c1, c2, r1, r2), 3);
        dn1 = @(c1, c2, r1, r2) matrix_row(dn(c1, c2, r1, r2), 1);
        dn2 = @(c1, c2, r1, r2) matrix_row(dn(c1, c2, r1, r2), 2);
        dn3 = @(c1, c2, r1, r2) matrix_row(dn(c1, c2, r1, r2), 3);
        
        
        if strcmp(view_axis, 'Y')
            mx = @(c1, c2, r1, r2) n1(c1, c2, r1, r2) / n3(c1, c2, r1, r2);
            dmx = @(c1, c2, r1, r2) (dn1(c1, c2, r1, r2) * n3(c1, c2, r1, r2) - n1(c1, c2, r1, r2) * dn3(c1, c2, r1, r2)) / n3(c1, c2, r1, r2)^2;
        else
            mx = @(c1, c2, r1, r2) W - n1(c1, c2, r1, r2) / n3(c1, c2, r1, r2);
            dmx = @(c1, c2, r1, r2) - (dn1(c1, c2, r1, r2) * n3(c1, c2, r1, r2) - n1(c1, c2, r1, r2) * dn3(c1, c2, r1, r2)) / n3(c1, c2, r1, r2)^2;
        end
        
        my = @(c1, c2, r1, r2) n2(c1, c2, r1, r2) / n3(c1, c2, r1, r2);
        dmy = @(c1, c2, r1, r2) (dn2(c1, c2, r1, r2) * n3(c1, c2, r1, r2) - n2(c1, c2, r1, r2) * dn3(c1, c2, r1, r2)) / n3(c1, c2, r1, r2)^2;
        m = @(c1, c2, r1, r2) [mx(c1, c2, r1, r2); my(c1, c2, r1, r2)];
        dm.dv = @(c1, c2, r1, r2) [dmx(c1, c2, r1, r2); dmy(c1, c2, r1, r2)];
        m_analyt = m;
        switch variable
            case 'c1'
                m_c1 = @(c1) m(c1, c2, r1, r2);
                dm_dc1 = my_gradient(m_c1, c1);
                %disp(my_gradient(m_c1, c1));
                %disp(dm.dv(c1, c2, r1, r2));
                dm.dc1 = dm.dv(c1, c2, r1, r2);
                dm.dc1_analyt = dm.dv;
                if norm(dm_dc1 - dm.dc1) > 1e-4
                    disp('Error');
                end
            case 'r1'
                m_r1 = @(r1) m(c1, c2, r1, r2);
                dm_dr1 = my_gradient(m_r1, r1);                
                %disp([my_gradient(m_r1, r1), dm.dv(c1, c2, r1, r2)]');                
                dm.dr1 = dm.dv(c1, c2, r1, r2);
                dm.dr1_analyt = dm.dv;
                if norm(dm_dr1 - dm.dr1) > 1e-4
                    disp('Error');
                end
            case 'c2'
                m_c2 = @(c2) m(c1, c2, r1, r2);
                dm_dc2 = my_gradient(m_c2, c2);
                % disp(my_gradient(m_c2, c2));
                % disp(dm.dv(c1, c2, r1, r2));
                dm.dc2 = dm.dv(c1, c2, r1, r2);
                dm.dc2_analyt = dm.dv;
                if norm(dm_dc2 - dm.dc2) > 1e-4
                    disp('Error');
                end
            case 'r2'
                m_r2 = @(r2) m(c1, c2, r1, r2);
                dm_dr2 = my_gradient(m_r2, r2);                
                % disp([my_gradient(m_r2, r2), dm.dv(c1, c2, r1, r2)]');                
                dm.dr2 = dm.dv(c1, c2, r1, r2);
                dm.dr2_analyt = dm.dv;
                if norm(dm_dr2 - dm.dr2) > 1e-4
                    disp('Error');
                end
        end
    end
    m = m(c1, c2, r1, r2);
end


if length(index) == 3
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
end
