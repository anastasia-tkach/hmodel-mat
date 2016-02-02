function [i1, i2] = intersect_trinagle_triangle(v1, v2, v3, u1, u2, u3)

i1 = [inf; inf; inf];
i2 = [inf; inf; inf];

I = cell(6, 1);
I{1} = intersect_triangle_segment(v1, v2, v3, u1, u2);
I{2} = intersect_triangle_segment(v1, v2, v3, u1, u3);
I{3} = intersect_triangle_segment(v1, v2, v3, u2, u3);
I{4} = intersect_triangle_segment(u1, u2, u3, v1, v2);
I{5} = intersect_triangle_segment(u1, u2, u3, v1, v3);
I{6} = intersect_triangle_segment(u1, u2, u3, v2, v3);

for k = 1:6
    if all(~isinf(I{k}))
        i1 = I{k};
        I{k} = [inf; inf; inf];
        break;
    end
end
for l = k + 1:6
    if all(~isinf(I{l}))
        i2 = I{l};
        break;
    end
end
