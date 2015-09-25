function [pose] = render_data_2D(pose, camera_axis, camera_center, view_axis, settings)

fov = settings.fov; H = settings.H; W = settings.W; D = settings.D;

RAND_MAX = 32767;
focal = H/tand(fov/2);
a = camera_axis; t = camera_center;
A = [focal, H/2; 0, 1];
rendered_data = zeros(H, 1);
back_map_for_rendered_data = zeros(H, D);
min_r = RAND_MAX; max_r = -RAND_MAX;

%% Display
% figure; axis equal; hold on;
% mypoint(camera_center, 'r');
% myline(camera_center, camera_center - camera_axis * 3000, 'k');
% myline(camera_center - camera_axis * focal, camera_center - camera_axis * focal + H/2 * [1; 0], 'k');
% myline(camera_center - camera_axis * focal, camera_center - camera_axis * focal - H/2 * [1; 0], 'k');
% mypoints(pose.points, 'b'); hold on;

switch view_axis
    case 'X', b = [-1; 0]; t = [t(2); t(1)];        
    case 'Y', b = [0; -1];        
end
cos_theta = a'*b/norm(a)/norm(b);
sin_theta = sqrt(1 - cos_theta^2);
R = [cos_theta, -sin_theta; sin_theta, cos_theta];
P = A * [R -R*t];

for i = 1:length(pose.points)
    p = [pose.points{i}; 1];
    if strcmp(view_axis, 'X'),        
        p = [p(2); p(1); p(3)];
        m = P * p; m = m(1) / m(2);
    end
    if strcmp(view_axis, 'Y'),       
        m = P * p;  m = m(1) / m(2);
    end
    
    if (m(1) < 1 || m(1) > H), continue; end
    rendered_data(round(m)) = 1;
    if round(m) < min_r, min_r = round(m); end;
    if round(m) > max_r, max_r = round(m); end;
    back_map_for_rendered_data(round(m), :) = pose.points{i};
    % myline(pose.points{i}, camera_center, 'm');
    % mypoint(camera_center - camera_axis * focal + (m - H/2)*[1; 0], 'g');
end

rendered_data([1:min_r - 1, max_r + 1:end], :) = 0;
rendered_data(min_r:max_r) = 1;

[distance_transform] = dtform(double(rendered_data));
[~, gradient_directions] = imgradient(distance_transform);

%% Store results
pose.rendered_data = rendered_data;
pose.back_map_for_rendered_data = back_map_for_rendered_data;
pose.gradient_directions = gradient_directions;
pose.distance_transform = distance_transform;
pose.P = P;
