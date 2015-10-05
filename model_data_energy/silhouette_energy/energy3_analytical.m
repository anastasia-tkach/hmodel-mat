function [f, f_analyt, m_analyt, df, m, p] = energy3_analytical(centers, radii, point, index, tangent_gradient, P, view_axis, H, W, rendered_data, distance_transform, gradient_directions)

[~, m, m_analyt, dm, variables] = compute_projection_jacobian_analytical(centers, radii, tangent_gradient, point, index, P, view_axis, H, W);

%% Find closest 2D data point

x = round(m(1)); y = round(m(2));

if x < 1 || y < 1 || x > W || y > H
    m = []; p = []; f = []; df = [];
    return;
end
if (rendered_data(y, x) == 1)
    m = []; p = []; f = []; df = [];
    return;
else
    while(rendered_data(y, x) == 0)
        delta_x = round(distance_transform(y, x) * cosd(gradient_directions(y, x)));
        delta_y = round(distance_transform(y, x) * sind(gradient_directions(y, x)));
        x = x - delta_x;
        y = y + delta_y;
    end
    p = [x; y];
end

%% Compute gradients
f =  sqrt((p - m)' * (p - m));
if length(variables) == 2
    f_analyt =  @(c1, r1) sqrt((p - m_analyt(c1, r1))' * (p - m_analyt(c1, r1)));
else
    f_analyt = @(c1, r1, c2, r2)sqrt((p - m_analyt(c1, c2, r1, r2))' * (p - m_analyt(c1, c2, r1, r2)));
end
for l = 1:length(variables)
    variable = variables{l};
    switch variable
        case 'c1',
            dm.dv = dm.dc1;
            dm.dv_analyt = dm.dc1_analyt;
        case 'r1',
            dm.dv = dm.dr1;
            dm.dv_analyt = dm.dr1_analyt;
        case 'c2',
            dm.dv = dm.dc2;
            dm.dv_analyt = dm.dc2_analyt;
        case 'r2',
            dm.dv = dm.dr2;
            dm.dv_analyt = dm.dr2_analyt;
        case 'c3',
            dm.dv = dm.dc3;
            dm.dv_analyt = dm.dc3_analyt;
        case 'r3',
            dm.dv = dm.dr3;
            dm.dv_analyt = dm.dr3_analyt;
    end
    df.dv = - (p - m)' * dm.dv / sqrt((p - m)' * (p - m));
    if length(variables) == 2
        c1 = centers{index(1)}; r1 = radii{index(1)};
        df.dv_analyt =  @(c1, r1, p) - (p - m_analyt(c1, r1))' * dm.dv_analyt(c1, r1) / sqrt((p - m_analyt(c1, r1))' * (p - m_analyt(c1, r1)));
    else
        c1 = centers{index(1)}; r1 = radii{index(1)};
        c2 = centers{index(2)}; r2 = radii{index(2)};
        df.dv_analyt = @(c1, r1, c2, r2, p) - (p - m_analyt(c1, c2, r1, r2))' * dm.dv_analyt(c1, c2, r1, r2) / sqrt((p - m_analyt(c1, c2, r1, r2))' * (p - m_analyt(c1, c2, r1, r2)));
    end
    switch variable
        case 'c1',
            df.dc1 = df.dv;
            df.dc1_analyt = df.dv_analyt;
        case 'r1',
            df.dr1 = df.dv;
            df.dr1_analyt = df.dv_analyt;
        case 'c2',
            df.dc2 = df.dv;
            df.dc2_analyt = df.dv_analyt;
        case 'r2',
            df.dr2 = df.dv;
            df.dr2_analyt = df.dv_analyt;
        case 'c3',
            df.dc3 = df.dv;
            df.dc3_analyt = df.dv_analyt;
        case 'r3',
            df.dr3 = df.dv;
            df.dr3_analyt = df.dv_analyt;
    end
end


if length(variables) == 2
    f_c1 =  @(c1)  f_analyt(c1, r1);
    f_r1 =  @(r1)  f_analyt(c1, r1);
    df.dc1_num = my_gradient(f_c1, c1);
    df.dr1_num = my_gradient(f_r1, r1);
    f_analyt = f_analyt(c1, r1);
else
    f_c1 =  @(c1)  f_analyt(c1, r1, c2, r2);
    f_r1 =  @(r1)  f_analyt(c1, r1, c2, r2);
    f_c2 =  @(c2)  f_analyt(c1, r1, c2, r2);
    f_r2 =  @(r2)  f_analyt(c1, r1, c2, r2);
    df.dc1_num = my_gradient(f_c1, c1);
    df.dr1_num = my_gradient(f_r1, r1);
    df.dc2_num = my_gradient(f_c2, c2);
    df.dr2_num = my_gradient(f_r2, r2);
    f_analyt = f_analyt(c1, r1, c2, r2);
end

