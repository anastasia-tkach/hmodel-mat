function [i] = rays_intersection_point(p1, p2, q1, q2)

r = (p2 - p1) / norm(p2 - p1);
s = (q2 - q1) / norm(q2 - q1);

t = norm(cross(q1 - p1, s)) / norm(cross(r, s));
i = p1 + t * r;

% figure; hold on;
% mypoint(p1, 'b');
% mypoint(p2, 'b');
% mypoint(q1, 'b');
% mypoint(q2, 'b');
% mypoint(i, 'r');
% myline(p1, p2, 'c');
% myline(q1, q2, 'c');