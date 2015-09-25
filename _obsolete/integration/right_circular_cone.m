function [] = right_circular_cone(color, c, alpha, beta, shift)

ay = cos(alpha)^2 - c * sin(alpha)^2;
by = 1;
cy = sin(alpha)^2 - c * cos(alpha)^2;
wy = (c + 1)*sin(alpha)*cos(alpha);

a_xy = ay;
b_xy = by * cos(beta)^2 + cy * sin(beta)^2;
c_xy = by * sin(beta)^2 + cy * cos(beta)^2;
u_xy = wy*sin(beta);
v_xy = (-by + cy)*sin(beta)*cos(beta);
w_xy = wy*cos(beta);

fxy_handle = @(x, y, z) a_xy*x^2 + b_xy*y^2 + c_xy*z^2 + 2*u_xy*x*y + 2*v_xy*y*z + 2*w_xy*x*z;

fxy_handle = @(x, y, z) a_xy*(x - shift(1))^2 + b_xy*(y - shift(2))^2 + c_xy*(z - shift(3))^2 +...
    2*u_xy*(x - shift(1))*(y - shift(2)) + 2*v_xy*(y - shift(2))*(z - shift(3)) + 2*w_xy*(x - shift(1))*(z - shift(3));

%% Define grid
n = 100;
xm = linspace(-3, 4, n)' + shift(1);
ym = linspace(-3, 4, n)' + shift(2);
zm = linspace(0, 4.5, n)' + shift(3);
[x,y,z] = meshgrid(xm, ym, zm);

%% Formatting "fun"
fxy_text = strrep(char(fxy_handle),' ','');
fxy_handle = eval([vectorize(fxy_text),';']);
fxy_values = fxy_handle(x, y, z);

h = patch(isosurface(x, y, z, fxy_values, 0));
isonormals(x, y, z, fxy_values, h);
set(h, 'FaceColor', color, 'EdgeColor', 'none',  'FaceAlpha', 1);
axis on; grid off; view([1, 1, 1]); axis equal; camlight; lighting gouraud

%% Find the axis
% Rx = @(alpha) [1, 0, 0;
%       0, cos(alpha), -sin(alpha);
%       0, sin(alpha), cos(alpha)]; 
%   
% Ry = @(alpha)[cos(alpha), 0, sin(alpha);
%       0, 1, 0;
%       -sin(alpha), 0, cos(alpha)];
%   
% a = [0; 0; 1];
% myline([0; 0; 0], a, color);
% a = Ry(beta) * Rx(alpha) * a;
% myline([0; 0; 0], a, color);
