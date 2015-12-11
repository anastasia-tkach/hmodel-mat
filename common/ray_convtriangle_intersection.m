function [i] = ray_convtriangle_intersection(c1, c2, c3, v1, v2, v3, u1, u2, u3, r1, r2, r3, p, v)

T = Inf * ones(3, 1);
I = cell(5, 1);

I{1} = ray_convsegment_intersection(c1, c2, r1, r2, p, v);
I{2} = ray_convsegment_intersection(c1, c3, r1, r3, p, v);
I{3} = ray_convsegment_intersection(c2, c3, r2, r3, p, v);
I{4} = ray_triangle_intersection(v1, v2, v3, p, v);
I{5} = ray_triangle_intersection(u1, u2, u3, p, v);

for j = 1:length(I)
    T(j) = norm(p - I{j});
end
[~, min_index] = min(T);
i = I{min_index};










