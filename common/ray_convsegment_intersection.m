function [i, normal] = ray_convsegment_intersection(c1, c2, r1, r2, p, v)
D = length(p);
n = (c2 - c1)/norm(c2 - c1);

beta = asin((r1 - r2) /norm(c1 - c2));
eta1 = r1 * sin(beta);
s1 = c1 + eta1 * n;
eta2 = r2 * sin(beta);
s2 = c2 + eta2 * n;

z = c1 + (c2 - c1) * r1 / (r1 - r2);
r = r1 * cos(beta);
h = norm(z - s1);
alpha = atan(r / h);

%% Ray - cone intersection
i = Inf * ones(D, 1);
normal = zeros(D, 1);
[i12, n12] = ray_cone_intersection(z, n, alpha, p, v);
if n' *(i12  - s1) >= 0 && n' * (i12 - s2) <= 0 && norm(i12) < Inf
    i = i12; 
    normal = n12;
end

%% Ray - sphere intersection
[i1, n1] = ray_sphere_intersection(c1, r1, p, v);
if n' * (i1 - s1) < 0  && norm(i1) < Inf
    i = i1;
    normal = n1;
end

%% Ray - sphere intersection

[i2, n2] = ray_sphere_intersection(c2, r2, p, v);
if n' * (i2 - s2) > 0 && norm(i2) < Inf
    i = i2;
    normal = n2;
end
















