
close all;
D = 3;
%% Generate data
% [centers, radii, blocks] = get_random_convtriangle();
% edge_indices = {{[1, 2], [1, 3], [2, 3]}};

[centers, radii, blocks] = get_random_convsegment(D);
edge_indices = {{[1, 2]}};
for i = 1:length(centers)
    centers{i} = centers{i} + [0; 0; 1];
end
c1 = centers{1}; c2 = centers{2};
r1 = radii{1}; r2 = radii{2};
camera_center = [0; 0; 0];
camera_ray = [0; 0; 1];
p = rand(D, 1) + [0; 0; 1];

%% Compute outline
% [t1, t2] = compute_last_visible_point(c1, c2, r1, r2, camera_ray, c1);
% [t3, t4] = compute_last_visible_point(c1, c2, r1, r2, camera_ray, c2);
% if norm(t1 - t3) > norm(t1 - t4), swap(t3, t4); end
% 
% Q = cell(4, 1);
% [Q{1}, points1] = projection_circle_segment(c1, c2, r1, t1, t2, camera_ray, p);
% 
% if ~isempty(t1)
%     [Q{2}, points2] = projection_circle_segment(c2, c1, r2, t3, t4, camera_ray, p);
%     Q{3} = project_point_on_segment(p, t1, t3);
%     Q{4} = project_point_on_segment(p, t2, t4);
% else
%     Q{2} = [Inf; Inf; Inf];
%     Q{3} = [Inf; Inf; Inf];
%     Q{4} = [Inf; Inf; Inf];
% end
% d = zeros(4, 1);
% for i = 1:length(Q), d(i) = norm(p - Q{i}); end
% [~, min_index] = min(d); q = Q{min_index};

q = projection_convsegment_outline(p, c1, c2, r1, r2, camera_ray);

%% Display
display_result(centers, [], [], blocks, radii, false, 0.5, 'small');
mypoint(p, 'b'); mypoint(q, 'k'); myline(p, q, 'r');
view([180, -90]); camlight;


%% Verify
% num_points = 1000;
% alpha = linspace(0, 1, num_points);
% points3 = cell(num_points, 1);
% points4 = cell(num_points, 1);
% for i = 1:num_points
%     points3{i} = alpha(i) * t1 + (1 - alpha(i)) * t3;
%     points4{i} = alpha(i) * t2 + (1 - alpha(i)) * t4;
% end
% points = [points1; points2; points3; points4];
% distances = Inf * ones(length(points), 1);
% for i = 1:length(points)
%     if isempty(points{i}), continue; end
%     distances(i) = norm(points{i} - p);    
% end
% mypoints(points, 'g');
% [min_value, min_index] = min(distances);
% scatter3(points{min_index}(1), points{min_index}(2), points{min_index}(3), 50, 'm', 'o', 'filled');
% view([180, -90]); camlight;

%% Additional
% points = {}; directions = {[1; 0; 0]; [0; 1; 0]; [0; 0; 1]; [-1; 0; 0]; [0; -1; 0]; [0; 0; -1]};
% for i = 1:length(centers), for d = 1:length(directions), points{end + 1} = centers{i} + radii{i} * directions{d}; end; end;
% mypoint(camera_center, 'k');
% myvector(camera_center, camera_ray, 1, 'k');
% myline(t1, t3, 'g');
% myline(t2, t4, 'g');
% draw_circle_in_plane(c1, r1, camera_ray, 'y');
% draw_circle_in_plane(c2, r2, camera_ray, 'y');
% myline(c1, t1, 'y'); myline(c1, t2, 'y');
% myline(c2, t3, 'y'); myline(c2, t4, 'y');
