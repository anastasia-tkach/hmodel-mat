function [q] = project_skewed_point_on_triangle(p, v1, v2, v3, n)

distance = (p - v1)' * n;
q = p - n * distance;

if is_point_in_triangle(q, v1, v2, v3), return; end

[q12] = project_point_on_segment(p, v1, v2);
[q13] = project_point_on_segment(p, v1, v3);
[q23] = project_point_on_segment(p, v2, v3);

d12 = norm(p - q12); d13 = norm(p - q13); d23 = norm(p - q23);
q = [q12, q13, q23];
[~, i] = min([d12, d13, d23]);
q = q(:, i);
