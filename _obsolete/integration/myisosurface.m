close all; clc; clear;

%% Cone equation
a = rand; b = rand; c = rand;
u = rand; v = rand; w = rand;
alpha = rand;


%% Rotation matrices
Rx = @(alpha) [1, 0, 0;
      0, cos(alpha), -sin(alpha);
      0, sin(alpha), cos(alpha)]; 
  
Ry = @(alpha)[cos(alpha), 0, sin(alpha);
      0, 1, 0;
      -sin(alpha), 0, cos(alpha)];
  
Rz = @(alpha)[cos(alpha), -sin(alpha), 0;
      sin(alpha), cos(alpha), 0;
      0, 0, 1];
  
%% Derive rotation
%x = randn; y = randn; z = randn; alpha = randn; c = randn;
f_handle = @(x,y,z) x^2 + y^2 - c*z^2;

%% Rotation around axis x
% [t] = Rx(alpha) * [x; y; z];
% f1 = f_handle(t(1), t(2), t(3));
% u = x;
% v = y * cos(alpha) - z * sin(alpha);
% w = y * sin(alpha) + z * cos(alpha);
% f2 = x^2 + (y * cos(alpha) - z * sin(alpha))^2 - c * ( y * sin(alpha) + z * cos(alpha))^2;
% f3 = x^2 + ...
%     y^2 * (1 - (c + 1) * sin(alpha)^2) + ...
%     z^2 * (1 - (c + 1) * cos(alpha)^2) + ...
%     - 2 * (c + 1)*sin(alpha)*cos(alpha) * y*z;

ax = 1;
bx = cos(alpha)^2 - c * sin(alpha)^2;
cx = sin(alpha)^2 - c * cos(alpha)^2;
vx = - (c + 1)*sin(alpha)*cos(alpha);

fx_handle = @(x,y,z) ax*x^2 + bx*y^2 + cx*z^2 + 2*vx*y*z;

%% Rotation around axis y
% [t] = Ry(alpha) * [x; y; z];
% f1 = f_handle(t(1), t(2), t(3));% 
% u = x * cos(alpha) + z * sin(alpha);
% v = y;
% w = -x * sin(alpha) + z * cos(alpha);% 
% f2 = (x * cos(alpha) + z * sin(alpha))^2 + y^2 - c*(-x * sin(alpha) + z * cos(alpha))^2;
% f3 = x^2 * (cos(alpha)^2 - c * sin(alpha)^2) + ...
%     y^2 + ...
%     z^2 * (sin(alpha)^2 + - c * cos(alpha)^2) + ...
%     2*x*z*(c + 1)*sin(alpha)*cos(alpha); 
% 
ay = cos(alpha)^2 - c * sin(alpha)^2;
by = 1;
cy = sin(alpha)^2 - c * cos(alpha)^2;
wy = (c + 1)*sin(alpha)*cos(alpha);
 
fy_handle = @(x,y,z) ay*x^2 + by*y^2 + cy*z^2 + 2*wy*x*z;

%% Rotation around axis x and then around axis y
% [t] = Ry(alpha) * Rx(alpha) * [x; y; z];
% f1 = f_handle(t(1), t(2), t(3));
% 
% x_x = x;
% y_x = (y * cos(alpha) - z * sin(alpha));
% z_x = (y * sin(alpha) + z * cos(alpha));
% 
% x_xy = x_x * cos(alpha) + z_x * sin(alpha);
% y_xy = y_x;
% z_xy = -x_x * sin(alpha) + z_x * cos(alpha);
% 
% f2 = f_handle(x_xy, y_xy, z_xy);
% 
% ay = cos(alpha)^2 - c * sin(alpha)^2;
% by = 1;
% cy = sin(alpha)^2 - c * cos(alpha)^2;
% wy = (c + 1)*sin(alpha)*cos(alpha);
%  
% f3 = ay*x_x^2 + by*y_x^2 + cy*z_x^2 + 2*wy*x_x*z_x;
% f4 = ay*x^2 + by*(y * cos(alpha) - z * sin(alpha))^2 + cy*(y * sin(alpha) + z * cos(alpha))^2 + 2*wy*x*(y * sin(alpha) + z * cos(alpha));
% f5 = ay*x^2 + ...
%     y^2 * (by * cos(alpha)^2 + cy * sin(alpha)^2) + ...
%     z^2 * (by * sin(alpha)^2 + cy * cos(alpha)^2) + ...
%     y*z * ((-2*by + 2*cy)*sin(alpha)*cos(alpha)) + ...
%     x*y * 2*wy*sin(alpha) + ...
%     x*z * 2*wy*cos(alpha);

a_xy = ay;
b_xy = by * cos(alpha)^2 + cy * sin(alpha)^2;
c_xy = by * sin(alpha)^2 + cy * cos(alpha)^2;
u_xy = wy*sin(alpha);
v_xy = (-by + cy)*sin(alpha)*cos(alpha);
w_xy = wy*cos(alpha);

fxy_handle = @(x, y, z) a_xy*x^2 + b_xy*y^2 + c_xy*z^2 + 2*u_xy*x*y + 2*v_xy*y*z + 2*w_xy*x*z;

%% Define grid
n = 50;
xm = linspace(-1, 1, n)';
ym = linspace(-1, 1, n)';
zm = linspace(-1, 1, n)';
[x,y,z] = meshgrid(xm, ym, zm);

s = [reshape(x, 1, n^3); reshape(y, 1, n^3); reshape(z, 1, n^3)];
t = Ry(alpha) * Rx(alpha) * s;
xt = reshape(t(1, :), n, n, n); yt = reshape(t(2, :), n, n, n); zt = reshape(t(3, :), n, n, n);

%% Formatting "fun"
f_text = strrep(char(f_handle),' ','');
fx_text = strrep(char(fx_handle),' ','');
fy_text = strrep(char(fy_handle),' ','');
fxy_text = strrep(char(fxy_handle),' ','');


f_handle = eval([vectorize(f_text),';']);
fx_handle = eval([vectorize(fx_text),';']);
fy_handle = eval([vectorize(fy_text),';']);
fxy_handle = eval([vectorize(fxy_text),';']);

f_values = f_handle(xt, yt, zt);
fx_values = fx_handle(x, y, z);
fy_values = fy_handle(x, y, z);
fxy_values = fxy_handle(x, y, z);

%% Making the 3D graph of the 0-level surface of the 4D function "fun":
figure; hold on;
color  = 'c';
h = patch(isosurface(x, y, z, f_values, 0));
isonormals(x, y, z, f_values, h);
set(h, 'FaceColor', color, 'EdgeColor', 'none');
axis on; grid off; view([1, 1, 1]); axis equal; camlight; lighting gouraud

% figure; hold on;
% color  = 'r';
% h = patch(isosurface(x, y, z, fx_values, 0));
% isonormals(x, y, z, fx_values, h);
% set(h, 'FaceColor', color, 'EdgeColor', 'none');
% axis on; grid off; view([1, 1, 1]); axis equal; camlight; lighting gouraud

% figure; hold on;
% color  = 'g';
% h = patch(isosurface(x, y, z, fy_values, 0));
% isonormals(x, y, z, fy_values, h);
% set(h, 'FaceColor', color, 'EdgeColor', 'none');
% axis on; grid off; view([1, 1, 1]); axis equal; camlight; lighting gouraud

figure; hold on;
color  = 'g';
h = patch(isosurface(x, y, z, fxy_values, 0));
isonormals(x, y, z, fxy_values, h);
set(h, 'FaceColor', color, 'EdgeColor', 'none');
axis on; grid off; view([1, 1, 1]); axis equal; camlight; lighting gouraud


