function [] = draw_sphere(center, radius, color, face_alpha)
num = 60;
%face_alpha = 0.1;
[rho, theta] = meshgrid(linspace(0, radius, num), linspace(0, 2*pi, num));
x0 = rho .* cos(theta);
y0 = rho .* sin(theta);
z0 = (radius.^2 - rho.^2).^0.5;

% p = [reshape(x0, num^2, 1), reshape(y0, num^2, 1), reshape(z0, num^2, 1)];
% p = rotation_matrix * p';
% x0 = p(1, :); x0 = reshape(x0, num, num);
% y0 = p(2, :); y0 = reshape(y0, num, num);
% z0 = p(3, :); z0 = reshape(z0, num, num);

x = x0 + center(1);
y = y0 + center(2);
z = z0 + center(3);
mesh(x, y, z, 'FaceColor', color, 'EdgeColor', 'none', 'FaceAlpha', face_alpha);

z0 = - (radius.^2 - rho.^2).^0.5;
z = z0 + center(3);
mesh(x, y, z, 'FaceColor', color, 'EdgeColor', 'none', 'FaceAlpha', face_alpha);

hold on; axis equal; grid off; lighting gouraud;

