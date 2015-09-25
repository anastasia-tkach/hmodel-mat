function [] = draw_trimmed_cone(r, h_top, h_bottom, cone_direction, translation_vector, color)

z_axis = [0; 0; 1];
rotation_axis = cross(cone_direction, z_axis);
rotation_angle = 180 * acos(z_axis' * cone_direction) / pi;

rotation_vector = [rotation_axis/norm(rotation_axis); rotation_angle]';
rotation_matrix = convert_rotations('EVtoDCM', rotation_vector, 10e-7, 0);

c = h_bottom/r;
r_top = h_top/c;
num = 30;
[rho, theta] = meshgrid(linspace(r_top, r, num), linspace(0, 2*pi, num));
x0 = rho .* cos(theta);
y0 = rho .* sin(theta);
z0 = c * rho;

p = [reshape(x0, num^2, 1), reshape(y0, num^2, 1), reshape(z0, num^2, 1)];
p = rotation_matrix * p';
x0 = p(1, :); x0 = reshape(x0, num, num);
y0 = p(2, :); y0 = reshape(y0, num, num);
z0 = p(3, :); z0 = reshape(z0, num, num);

x = x0 + translation_vector(1);
y = y0 + translation_vector(2);
z = z0 + translation_vector(3);

mesh(x, y, z, 'FaceColor', color, 'EdgeColor', 'none', 'FaceAlpha', 0.4);
hold on; axis equal; grid off; camlight; lighting gouraud;

%myline(translation_vector, rotation_matrix * [0; 0; 1] + translation_vector, 'g');
% xlim([0, 4]); ylim([0, 4]), zlim([0, 4]);
