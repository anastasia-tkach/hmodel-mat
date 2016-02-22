close all;
clc;
D = 3;
c = randn(D, 1);
r = rand;
alpha1 = rand * 2 * pi;
beta1 = rand * 2 * pi;
alpha2 = rand * 2 * pi;
beta2 = rand * 2 * pi;
n = [0; 0; 1];

s1 = c + r * [cos(alpha1); sin(alpha1); 0];
e1 = c + r * [cos(beta1); sin(beta1); 0];

s2 = c + r * [cos(alpha2); sin(alpha2); 0];
e2 = c + r * [cos(beta2); sin(beta2); 0];

[intersections] = intersect_segment_segment_same_circle(c, r, n, s1, e1, s2, e2);