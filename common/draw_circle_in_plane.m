function [] = draw_circle_in_plane(o, r, n, color)

D = 3;

u = randn(D, 1);
v = cross(n, u);
u = cross(n, v);
u = u/norm(u);
v = v/norm(v);

% figure; axis off; axis equal; hold on;
% draw_sphere(o, r, 'c');
% myvector(o, n, r/norm(n), 'k');
% myvector(o, u, r, 'k');
% myvector(o, v, r, 'k');

num_points = 50;
phi_array = linspace(0, 2 * pi, num_points);
P = zeros(num_points, 3);
for i = 1:length(phi_array)
    phi = phi_array(i);
    P(i, :) = o + r * (u * sin(phi) + v * cos(phi));
end
line(P(:, 1), P(:, 2), P(:, 3), 'lineWidth', 2, 'color', color);