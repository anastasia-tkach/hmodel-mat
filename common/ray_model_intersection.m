function [i] = ray_model_intersection(centers, blocks, radii, tangent_points, p, d)
D = length(p);
min_i = Inf * ones(D, 1);
for j = 1:length(blocks)
    block = blocks{j};
    tangent_point = tangent_points{j};
    if (length(block) == 3)
        c1 = centers{block(1)}; c2 = centers{block(2)}; c3 = centers{block(3)};
        r1 = radii{block(1)}; r2 = radii{block(2)}; r3 = radii{block(3)};
        v1 = tangent_point.v1; v2 = tangent_point.v2; v3 = tangent_point.v3;
        u1 = tangent_point.u1; u2 = tangent_point.u2; u3 = tangent_point.u3;
        i = ray_convtriangle_intersection(c1, c2, c3, v1, v2, v3, u1, u2, u3, r1, r2, r3, p, d);
        if (norm(p - i) < norm(p - min_i))
            min_i = i;
        end
    end
    if length(block) == 2
        c1 = centers{block(1)}; c2 = centers{block(2)};
        r1 = radii{block(1)}; r2 = radii{block(2)};
        i = ray_convsegment_intersection(c1, c2, r1, r2, p, d);
        if (norm(p - i) < norm(p - min_i))
            min_i = i;
        end
    end
end

i = min_i;