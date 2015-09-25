function [f, df, m, p] = energy3_2D(centers, radii, point, index, tangent_gradient, P, view_axis, H, W, rendered_data, distance_transform, gradient_directions)

[~, m, dm, variables] = compute_projection_jacobian(centers, radii, tangent_gradient, point, index, P, view_axis, H, W);

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
for l = 1:length(variables)
    variable = variables{l};
    switch variable
        case 'c1', dm.dv = dm.dc1;
        case 'r1', dm.dv = dm.dr1;
        case 'c2', dm.dv = dm.dc2;
        case 'r2', dm.dv = dm.dr2;
        case 'c3', dm.dv = dm.dc3;
        case 'r3', dm.dv = dm.dr3;
    end
    df.dv = - (p - m)' * dm.dv / sqrt((p - m)' * (p - m));
    switch variable
        case 'c1', df.dc1 = df.dv;
        case 'r1', df.dr1 = df.dv;
        case 'c2', df.dc2 = df.dv;
        case 'r2', df.dr2 = df.dv;
        case 'c3', df.dc3 = df.dv;
        case 'r3', df.dr3 = df.dv;
    end
end

