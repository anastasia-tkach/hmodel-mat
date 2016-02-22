function [index, q, s, tangent_points] = projection_convtriangle_frontfacing(p, c1, c2, c3, r1, r2, r3, block, tangent_points, camera_ray)

%% Compute skewed distance to triangle

[q, s, index, tangent_points] = project_skewed_point_on_triangle(p, c1, c2, c3, block, tangent_points, camera_ray);
if ~isempty(q), return; end

%% Compute skewed distance to segments
[q12, s12, index12] = project_skewed_point_on_segment(p, c1, c2, r1, r2, block(1), block(2));
[q13, s13, index13] = project_skewed_point_on_segment(p, c1, c3, r1, r3, block(1), block(3));
[q23, s23, index23] = project_skewed_point_on_segment(p, c2, c3, r2, r3, block(2), block(3));

%% Supress sphere projections corresponding to non-existing surface
if (length(index12) == 1 && (length(index23) == 2 || index12(1) ~= index23(1))) ...
        && (length(index12) == 1 && (length(index13) == 2 || index12(1) ~= index13(1)))
    s12 = [inf; inf; inf];
end

if (length(index23) == 1 && (length(index12) == 2 || index23(1) ~= index12(1))) ...
        && (length(index23) == 1 && (length(index13) == 2 || index23(1) ~= index13(1)))
    s23 = [inf; inf; inf];
end

if (length(index13) == 1 && (length(index12) == 2 || index13(1) ~= index12(1))) ...
        && (length(index13) == 1 && (length(index23) == 2 || index13(1) ~= index23(1)))
    s13 = [inf; inf; inf];
end

d12 = sign(norm(p - s12) - norm(q12 - s12)) * norm(p - q12);
d13 = sign(norm(p - s13) - norm(q13 - s13)) * norm(p - q13);
d23 = sign(norm(p - s23) - norm(q23 - s23)) * norm(p - q23);

s = {s12, s13, s23};
q = {q12, q13, q23};
index = {index12, index13, index23};
[~, k] = min([d12, d13, d23]);
s = s{k};
index = index{k};
q = q{k};