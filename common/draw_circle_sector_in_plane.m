function [] = draw_circle_sector_in_plane(c, r, n, t1, t2, color)

D = 3;

u = [1; 0; 0];
v = cross(n, u);
u = cross(v, n);
u = u/norm(u);
v = v/norm(v);

% figure; axis off; axis equal; hold on;
% draw_sphere(o, r, 'c');
% myvector(o, n, r/norm(n), 'k');
% myvector(o, u, r, 'k');
% myvector(o, v, r, 'k');

num_points = 50;
v1 = t1 - c(1:2);
v2 = t2 - c(1:2);
% alpha = myatan2(v1);
% beta = myatan2(v2);
alpha = atan2(v1(1), v1(2));
beta = atan2(v2(1), v2(2));
if beta > alpha, alpha = alpha + 2 * pi; end
phi_array = linspace(alpha, beta, num_points);
%phi_array = linspace(0, 2 * pi, num_points);
P = zeros(num_points, 3);
for i = 1:length(phi_array)
    phi = phi_array(i);
    P(i, :) = c + r * (u * sin(phi) + v * cos(phi));
end
line(P(:, 1), P(:, 2), P(:, 3), 'lineWidth', 2, 'color', color);