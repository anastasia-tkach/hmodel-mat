function [t1, t2] = intersect_arc_segment(p, q, c, r, a, b)

% D = 2;
% p = randn(D, 1);
% q = randn(D, 1);
% c = 0.2 * randn(D, 1);
% alpha = randn(1, 1);
% beta = randn(1, 1);
% r = rand(1, 1);
% a = c + r * [cos(alpha); sin(alpha)];
% b = c + r * [cos(beta); sin(beta)];

[t1, t2] = intersect_circle_segment(p, q, c, r);

if isempty(t1) || ~is_point_on_arc(c, a, b, t1) 
    t1 = [];
end
if isempty(t2) || ~is_point_on_arc(c, a, b, t2) 
    t2 = [];
end

%% Display
% figure; hold on; axis equal; axis off;
% draw_circle(c, r, 'c');
% draw_circle_sector(c, r, a, b, 'b');
% myline(p, q, 'b');
% mypoint(t1, 'm');
% mypoint(t2, 'm');

end

function [result] = is_point_on_arc(c, p, q, t)

alpha = myatan2(p - c);
beta = myatan2(q - c);
gamma = myatan2(t - c);

if beta < alpha, beta = beta + 2 * pi; end
if gamma < alpha, gamma = gamma + 2 * pi; end
if gamma < beta, result = true;
else result = false;
end

end
