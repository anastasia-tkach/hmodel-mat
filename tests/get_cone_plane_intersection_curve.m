%h = h_bottom; a = xz_normal(1); b = xz_normal(3); d = -xz_point' * xz_normal;
function [y_handle] = get_cone_plane_intersection_curve(h, r, point, normal)

a = normal(1); b =  normal(3); d = -point' * normal;

c = r^2/h^2; num = 60;
[rho, theta] = meshgrid(linspace(0, r, num), linspace(0, 2*pi, num));
x = rho .* cos(theta); y = rho .* sin(theta); z = 1/sqrt(c) * rho;
% mesh(x, y, z, 'FaceColor', 'm', 'EdgeColor', 'none', 'FaceAlpha', 1);

%% Draw plane
[x, y] = meshgrid(linspace(-r, r, num), linspace(-r, r, num));
z = -a / b * x - d / b;
% mesh(x, y, z, 'FaceColor', 'c', 'EdgeColor', 'none', 'FaceAlpha', 1);

%% Derivation
% x = rand; z = rand; y = rand;
% f0 = x^2 + y^2 - c * ( -a / b * x - d / b)^2;
% f2 = x^2 + y^2 - c/b^2 * (a*x + d)^2;
% f3 = x^2 + y^2 - c/b^2 * (a^2*x^2 + 2*a*d*x + d^2);
% f4 = y^2 - 1/b^2 * (a^2*c*x^2 - b^2*x^2 + 2*a*c*d*x + c*d^2);
% f5 = y^2 - (1/b * (a^2*c*x^2 - b^2*x^2 + 2*a*c*d*x + c*d^2).^0.5)^2;

x_max = point(1);
x_min = -b * h / a - d/a;
if (x_max < x_min) 
    temp = x_min; x_min = x_max; x_max = temp;
end
[x, z] = meshgrid(linspace(x_min + 10e-10, x_max - 10e-10, num), linspace(0, h, num));
y_handle = @(x) 1/b * (a^2*c*x.^2 - b^2*x.^2 + 2*a*c*d*x + c*d^2).^0.5;
y = y_handle(x);

mesh(x, y, z, 'FaceColor', 'y', 'EdgeColor', 'none', 'FaceAlpha', 1);
mesh(x, -y, z, 'FaceColor', 'y', 'EdgeColor', 'none', 'FaceAlpha', 1);

%% Cone in Carthesian coordinates
% [x, y] = meshgrid(linspace(-r, r, num), linspace(-r, r, num));
% z = (x.^2/c + y.^2/c).^0.5; 
% mesh(x, y, z, 'FaceColor', 'r', 'EdgeColor', 'none', 'FaceAlpha', 0.7);





