function [q, points] = projection_circle_segment(c, d, r, t1, t2, n, p, to_verify)

s = project_point_on_plane(p, c, n);

l = d - c  - n * n' * (d - c);
m = c - r * l / norm(l);
q = c + r * (s - c) / norm(s - c);

%% Compute the angles
if ~isempty(t1) && ~isempty(t2)
    cos_theta = (q - c)' * (m - c) / norm(q - c) / norm(m - c);
    cos_alpha = (t1 - c)' * (m - c) / norm(t1 - c) / norm(m - c);
    theta = acos(cos_theta);
    alpha = acos(cos_alpha);
    if (theta > alpha) % outside
        d1 = norm(p - t1);
        d2 = norm(p - t2);
        if d1 < d2, q = t1;
        else q = t2; end
    end
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
if ~to_verify
    point = [];
else 
    %disp(norm(p - q));
    D = 3;
    u = randn(D, 1);
    v = cross(n, u);
    u = cross(n, v);
    u = u/norm(u);
    v = v/norm(v);
    num_points = 10000;
    results = Inf * ones(num_points, 1);
    points = cell(num_points, 1);
    phi_array = linspace(0, 2 * pi, num_points);
    for i = 1:length(phi_array)
        phi = phi_array(i);
        point = c + r * (u * sin(phi) + v * cos(phi));
        cos_theta = (point - c)' * (m - c) / norm(point - c) / norm(m - c);
        theta = acos(cos_theta);
    
        if ~isempty(t1) && ~isempty(t2)
            if theta > alpha, continue; end
        end
    
        results(i) = norm(point - p);
        points{i} = point;
    end
    %mypoints(points, 'g');
    %[min_value, min_index] = min(results);
    %mypoint(points{min_index}, 'm');
    %disp(min_value);
end



