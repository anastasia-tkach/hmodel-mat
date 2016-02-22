function [q, s, index, tangent_points] = project_skewed_point_on_triangle(p, c1, c2, c3, index, tangent_points, camera_ray)

verbose = false;

l = cross(c2 - c1, c3 - c1); l = l/norm(l);
if camera_ray' * tangent_points.n < 0
    n = tangent_points.n;
    v1 = tangent_points.v1; v2 = tangent_points.v2; v3 = tangent_points.v3;
else
    n = tangent_points.m;
    v1 = tangent_points.u1; v2 = tangent_points.u2; v3 = tangent_points.u3;
    tangent_points.v1 = v1; tangent_points.v2 = v2; tangent_points.v3 = v3;
end

%% Compute skewed distance to triangle
if l' * n < 0, l = -l; end
cos_alpha = l' * n;

distance = (p - c1)' * l;
distance = distance / cos_alpha;
s = p - n * distance;

if is_point_in_triangle(s, c1, c2, c3)
    %skeleton{j} = s;
    %indices{j} = blocks{j};
    q = project_point_on_triangle(p, v1, v2, v3);
    if verbose
        scatter3(s(1), s(2), s(3), 50, 'm', 'o', 'filled');
    end
else
    q = [];
    s = [];
    index = [];
end
