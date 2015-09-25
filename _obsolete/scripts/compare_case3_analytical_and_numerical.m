clc; clear;
D = 3;
while(true)
    c1 = rand(D, 1);
    c2 = rand(D, 1);
    c3 = rand(D, 1);
    x1 = rand(1, 1);
    x2 = rand(1, 1);
    x3 = rand(1, 1);
    x = [x1, x2, x3];
    [r1, i1] = max(x);
    [r3, i3] = min(x);
    x([i1, i3]) = 0;
    r2 = max(x);
    if norm(c1 - c2) > r1 && norm(c1 - c3) > r1 &&  norm(c2 - c3) > r2
        break;
    end
end
p = rand(D, 1);

[v1, v2, v3, Jv1, Jv2, Jv3, u1, u2, u3, Ju1, Ju2, Ju3] = tangent_points_gradient(c1, c2, c3, r1, r2, r3, D);

index = -1;
[d1, Jc1, Jr1, Jc2, Jr2, Jc3, Jr3] = energy1_case3(p, u1, u2, u3, Ju1, Ju2, Ju3, c1, c2, c3, r1, r2, r3, index, D);
disp('');
index = 1;
[d2, Jc1, Jr1, Jc2, Jr2, Jc3, Jr3] = energy1_case3(p, v1, v2, v3, Jv1, Jv2, Jv3, c1, c2, c3, r1, r2, r3, index, D);

d1
d2

%% First way
z12 = c1 + (c2 - c1) * r1 / (r1 - r2);
z13 = c1 + (c3 - c1) * r1 / (r1 - r3);

l = (z12 - z13) / norm(z12 - z13);
projection = (c1 - z12)' * l;
z = z12 + projection * l;

beta = asin(r1/norm(c1 - z));

g = rotate_around_axis(l, c1 - z, beta);
v1 = z + norm(c1 - z) * cos(beta) * g;
n = v1  - c1; n = n / norm(n);
v2 = c2 + r2 * n;
v3 = c3 + r3 * n;

n = cross(v1 - v2, v1 - v3);
n = n / norm(n);
distance = (p - v1)' * n;
t1 = p - n * distance;

g = rotate_around_axis(l, c1 - z, -beta);
u1 = z + norm(c1 - z) * cos(beta) * g;
m = c1 - u1; m = m / norm(m);
u2 = c2 - r2 * m;
u3 = c3 - r3 * m;

n = cross(u1 - u2, u1 - u3);
n = n / norm(n);
distance = (p - u1)' * n;
t2 = p - n * distance;

dd1 = norm(p - t1);
dd2 = norm(p - t2);

dd1
dd2
return

%% Second way

index = -1;

z12 = c1 + (c2 - c1) * r1 / (r1 - r2);
z13 = c1 + (c3 - c1) * r1 / (r1 - r3);

l = (z12 - z13) / norm(z12 - z13);
projection = (c1 - z12)' * l;
z = z12 + projection * l;

eta = norm(c1 - z);
sin_beta = r1/eta;
j = sqrt(eta^2 - r1^2);
cos_beta = j/eta;

f = (c1 - z) / eta;
h = cross(l, f);
h = h / norm(h);
g = sign(index) * sin_beta * h + cos_beta * f;

v1 = z + j * g;
n = (v1  - c1) / norm(v1  - c1);
v2 = c2 + r2 * n;
v3 = c3 + r3 * n;

m = cross(v1 - v2, v1 - v3);
m = m / norm(m);
distance = (p - v1)' * m;
t = p - m * distance;

t'
