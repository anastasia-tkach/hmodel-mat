function [i, normal] = ray_cone_intersection(pa, va, alpha, p, v)
D = length(p);

cos2 = cos(alpha)^2;
sin2 = sin(alpha)^2;
delta_p = p - pa;

e = v - (v'*va)*va;
f = v'*va;
g = delta_p - (delta_p'*va)*va;
h = delta_p'*va;

A = cos2 * (e' * e) - sin2 * (f' * f);
B = 2 * cos2 * (e' * g) - 2 * sin2 * (f' * h);
C = cos2 * (g' * g) - sin2 * (h' * h);

discriminant = B^2 - 4*A*C;

t1 = Inf;
t2 = Inf;
if (discriminant >= 0)
    t1 = (-B - sqrt(discriminant)) / 2 /A;
    t2 = (-B + sqrt(discriminant)) / 2 /A;
    i1 = p + t1 * v;
    i2 = p + t2 * v;
    if (i1 - pa)' * va > 0, t1 = Inf; end
    if (i2 - pa)' * va > 0, t2 = Inf; end
end

i = Inf * ones(D, 1);
if (abs(t1) < abs(t2))
    i = i1;
end
if (abs(t1) > abs(t2))
    i = i2;
end

%% Find normal
c = pa - va;
a = i - c;
b = (i - pa)/norm(i - pa);
normal = a - a' * b * b;
normal = normal / norm(normal);


