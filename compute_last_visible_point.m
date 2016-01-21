function [p1, p2] = compute_last_visible_point(c1, c2, r1, r2, camera_ray, o)

a = (c2 - c1) / norm(c2 - c1);

u = cross(camera_ray, a);
u = u/norm(u);
v = cross(a, u);
v = v/norm(v);

z = c1 + (c2 - c1) * r1 / (r1 - r2);
r = r1 * norm(z - o) / norm(z - c1);
alpha = asin(r1 / norm(c1 - z));
r_tilde = r * cos(alpha);
delta = r * sin(alpha);
p = o + a * delta;

%% Debug
% draw_sphere(o, r, 'm');
% draw_sphere(p, r_tilde, 'c');
% mypoint(p, 'k');
% myline(c1, c2, 'b');
% mypoint(o, 'g');
% myvector(p, u, r_tilde, 'r');
% myvector(p, v, r_tilde, 'r');

%% Compute phi
tz = camera_ray(3);

c = tz * p(3)  - tz * o(3);
b = tz * r_tilde * u(3);
a = tz * r_tilde * v(3);

A = a^2 + b^2;
B = 2 * b * c;
C = c^2 - a^2;

discriminant = B^2 - 4*A*C;

s1 = Inf; s2 = Inf;
p1 = []; p2 = [];
if (discriminant >= 0)
    s1 = (-B - sqrt(discriminant)) / 2 /A;  
    s2 = (-B + sqrt(discriminant)) / 2 /A;    

    p11 = p + r_tilde * (u * s1 + v * sqrt(1 - s1^2));
    p12 = p + r_tilde * (u * s1 - v * sqrt(1 - s1^2));
    
    p21 = p + r_tilde * (u * s2 + v * sqrt(1 - s2^2));
    p22 = p + r_tilde * (u * s2 - v * sqrt(1 - s2^2)); 
    
    r11 = abs(camera_ray' * (p11 - o));
    r12 = abs(camera_ray' * (p12 - o));
    
    if r11 < r12, p1 = p11;
    else p1 = p12; end
    
    r21 = abs(camera_ray' * (p21 - o));
    r22 = abs(camera_ray' * (p22 - o));
    
    if r21 < r22, p2 = p21;
    else p2 = p22; end
end

%% Brute-force phi
% num_points = 500;
% phi_array = linspace(0, 2 * pi, num_points);
% results = zeros(num_points, 1);
% normals = {};
% for i = 1:length(phi_array)
%     phi = phi_array(i);
%     point = p + r_tilde * (u * sin(phi) + v * cos(phi));
%     normals{i} = point - o;
%     results(i) = camera_ray' * normals{i};
%     %mypoint(point, 'b');
% end
% [min_value, min_index] = min(abs(results));
% ff1 = phi_array(min_index);
% pp1 = p + r_tilde * (u * sin(phi_array(min_index)) + v * cos(phi_array(min_index)));
% results(min_index) = 10;
% [~, min_index2] = min(abs(results));
% pp2 = p + r_tilde * (u * sin(phi_array(min_index2)) + v * cos(phi_array(min_index2)));
% ff2 = phi_array(min_index2);

%% Derive phi
% phi = phi_array(min_index);
% sign = 1;
% if phi > pi/2 && phi < 3 * pi / 2, sign = -1; end
% 
% f = sin(phi_array(min_index));
% o1 = [tx; ty; tz]' * (p + r_tilde * (u * f + v * sign * sqrt(1 - f^2)) - o);
% 
% o2 = tx * ((p(1) + r_tilde * (u(1) * f + v(1) * sign * sqrt(1 - f^2)) - o(1))) + ...
%     ty * ((p(2) + r_tilde * (u(2) * f + v(2) * sign * sqrt(1 - f^2)) - o(2))) + ...
%     tz * ((p(3) + r_tilde * (u(3) * f + v(3) * sign * sqrt(1 - f^2)) - o(3)));
% 
% o3 = tx * (p(1) + r_tilde * u(1) * f + r_tilde * v(1) * sign * sqrt(1 - f^2) - o(1)) + ...
%     ty * (p(2) + r_tilde * u(2) * f + r_tilde * v(2) * sign * sqrt(1 - f^2) - o(2)) + ...
%     tz * (p(3) + r_tilde * u(3) * f + r_tilde * v(3) * sign * sqrt(1 - f^2) - o(3));
% 
% o4 = tx * p(1) + tx * r_tilde * u(1) * f + tx * r_tilde * v(1) * sign * sqrt(1 - f^2) - tx * o(1) + ...
%     ty * p(2) + ty * r_tilde * u(2) * f + ty * r_tilde * v(2) * sign * sqrt(1 - f^2) - ty * o(2) + ...
%     tz * p(3) + tz * r_tilde * u(3) * f + tz * r_tilde * v(3) * sign * sqrt(1 - f^2) - tz * o(3);
% 
% o5 = tz * p(3) + tz * r_tilde * u(3) * f + tz * r_tilde * v(3) * sign * sqrt(1 - f^2) - tz * o(3);
% 
% c = tz * p(3)  - tz * o(3);
% b = tz * r_tilde * u(3);
% a = tz * r_tilde * v(3) * sign;
% o6 = c + b * f + a * sqrt(1 - f^2);
% 
% A = a^2 + b^2;
% B = 2 * b * c;
% C = c^2 - a^2;
% 
% discriminant = B^2 - 4*A*C;
% 
% f1 = Inf;
% f2 = Inf;
% if (discriminant >= 0)
%     f1 = (-B - sqrt(discriminant)) / 2 /A;
%     f2 = (-B + sqrt(discriminant)) / 2 /A;
% end
% 
% disp([sin(phi_array(min_index)), f1; sin(phi_array(min_index2)), f2]);









