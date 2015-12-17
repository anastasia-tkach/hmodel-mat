function [i, normal] = ray_sphere_intersection(c, r, p, v)
D = length(p);

A = v' * v;
B = - 2 * (c - p)' * v;
C = (c - p)' * (c - p) - r^2;
discriminant = B^2 - 4*A*C;

i1 = Inf * ones(D, 1);
i2 = Inf * ones(D, 1);
if (discriminant >= 0)
    t1 = (-B - sqrt(discriminant)) / 2 /A;
    t2 = (-B + sqrt(discriminant)) / 2 /A;
    i1 = p + t1 * v;
    i2 = p + t2 * v;
end

i = Inf * ones(D, 1);
if (norm(i1 - p) <= norm(i2 - p))
    i = i1;
end
if (norm(i2 - p) < norm(i1 - p))
    i = i2;
end

%% Compute normal

normal = i - c;
normal = normal / norm(normal);

