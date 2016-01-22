function [q] = project_point_on_arc(p, c, r, n, t1, t2)

s = project_point_on_plane(p, c, n);
q = c + r * (s - c) / norm(s - c);

%% Asume that arc is in xy plane (this is always the case in our system)
if ~is_point_on_arc(c(1:2), t1(1:2), t2(1:2), q(1:2))    
    d1 = norm(p - t1);
    d2 = norm(p - t2);
    if d1 < d2, q = t1;
    else q = t2; end
end

%% Display
% figure; hold on; axis off; axis equal;
% draw_circle_in_plane(c, r, n, 'b');
% myline(c, t1, 'g'); myline(c, t2, 'g');
% myline(c, m, 'm');
% mypoint(p, 'r');
% mypoint(q, 'b');
% myline(q, p, 'c');


%% Verify
%disp(norm(p - q));
% D = 3;
% u = randn(D, 1);
% v = cross(n, u);
% u = cross(n, v);
% u = u/norm(u);
% v = v/norm(v);
% num_points = 10000;
% results = Inf * ones(num_points, 1);
% points = cell(num_points, 1);
% phi_array = linspace(0, 2 * pi, num_points);
% for i = 1:length(phi_array)
%     phi = phi_array(i);
%     point = c + r * (u * sin(phi) + v * cos(phi));
%     cos_theta = (point - c)' * (m - c) / norm(point - c) / norm(m - c);
%     theta = acos(cos_theta);
%
%     if ~isempty(t1) && ~isempty(t2)
%         if theta > alpha, continue; end
%     end
%
%     results(i) = norm(point - p);
%     points{i} = point;
% end
%mypoints(points, 'g');
%[min_value, min_index] = min(results);
%mypoint(points{min_index}, 'm');
%disp(min_value);

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




