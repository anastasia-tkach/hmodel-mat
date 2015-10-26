function [v1, v2] = get_convsegment_tangent_points_along_vector(c1, c2, r1, r2, d)

d = d / norm(d);

n = (c2 - c1) / norm(c2 - c1);
beta = asin((r1 - r2) /norm(c1 - c2));

%% Tangent point for the bigger radius
eta = r1 * sin(beta);
t = r1 * d + n * eta;

v1 = c1 + r1 * t / norm(t); 

%% Tangent point for the bigger radius
eta = r2 * sin(beta);
t = r2 * d - n * eta;

v2 = c2 + r2 * t / norm(t);
