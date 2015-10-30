function [r] = get_convolution_radius_at_points(centers, radii, indices, normal, p)

if length(indices) == 2
    c1 = centers{indices(1)};
    c2 = centers{indices(2)};
    r1 = radii{indices(1)};
    r2 = radii{indices(2)};
    
    z = c1 + (c2 - c1) * r1 / (r1 - r2);
    r = r1 * norm(z - p) / norm(z - c1);
end

if length(indices) == 3
    c1 = centers{indices(1)};
    r1 = radii{indices(1)};   
    f = normal' * (c1 - p);
    r = r1 - f;      
end

%% Test for convtriangle
% point = a * c1 + b * c2 + c * c3;
% [v1, v2, v3, u1, u2, u3] = tangent_points_function(c1, c2, c3, r1, r2, r3); normal = (c1 - v1)/norm(c1 - v1);
% radius = get_convolution_radius_at_points(centers, radii, [1, 2, 3], normal, point);
% radius = radius + radius * 0.01;
% mypoint(point, 'k');
% myline(c1, c2, 'm'); myline(c2, c3, 'm'); myline(c1, c3, 'm');
% draw_sphere(point, radius, 'k')
