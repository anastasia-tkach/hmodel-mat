function [t1, t2] = intersect_arc_arc(c1, r1, p1, q1, c2, r2, p2, q2)

% D = 2;
% c1 = 0.2 * randn(D, 1);
% c2 = 0.2 * randn(D, 1);
% alpha1 = randn(1, 1);
% beta1 = randn(1, 1);
% alpha2 = randn(1, 1);
% beta2 = randn(1, 1);
% r1 = rand(1, 1);
% r2 = rand(1, 1);
% r2 = mean([r1, r2]);
% p1 = c1 + r1 * [cos(alpha1); sin(alpha1)];
% q1 = c1 + r1 * [cos(beta1); sin(beta1)];
% p2 = c2 + r2 * [cos(alpha2); sin(alpha2)];
% q2 = c2 + r2 * [cos(beta2); sin(beta2)];

[t1, t2] = intersect_circle_circle(c1, r1, c2, r2);

%% Check if point is in arc
if isempty(t1) || ~is_point_on_arc(c1, p1, q1, t1) || ~is_point_on_arc(c2, p2, q2, t1)
    t1 = [];
end
if isempty(t2) || ~is_point_on_arc(c1, p1, q1, t2) || ~is_point_on_arc(c2, p2, q2, t2)
    t2 = [];
end

%% Display
% figure; hold on; axis equal; axis off;
% draw_circle(c1, r1, 'c');
% draw_circle(c2, r2, 'c');
% draw_circle_sector(c1, r1, p1, q1, 'b');
% draw_circle_sector(c2, r2, p2, q2, 'b');
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