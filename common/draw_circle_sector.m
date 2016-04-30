function [] = draw_circle_sector(c, r, t1, t2, color, varargin)
% D = 2;
% c = randn(D, 1);
% r = rand(1, 1);
% v1 = randn(D, 1);
% v2 = randn(D, 1);
% t1 = c + r * v1/norm(v1);
% t2 = c + r * v2/norm(v2);
% color = 'b';

line_width = 2;
if ~isempty(varargin)
    line_width = varargin{1};
end

% Counter clock-wise

u = [1; 0];
v = [0; 1];
v1 = t1 - c;
v2 = t2 - c;
alpha = atan2(v1(1), v1(2));
beta = atan2(v2(1), v2(2));
if beta > alpha, alpha = alpha + 2 * pi; end

D = 2;
num_points = 50;

phi_array = linspace(alpha, beta, num_points);
P = zeros(num_points, D);
for i = 1:length(phi_array)
    phi = phi_array(i);
    P(i, :) = c + r * sin(phi) * u + r * cos(phi) * v;
end

%figure; axis off; axis equal; hold on;
%draw_circle(c, r, 'c');
line(P(:, 1), P(:, 2), 'lineWidth', line_width, 'color', color);
%mypoint(t1, 'm'); mypoint(t2, 'b');
