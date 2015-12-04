function [frames] = compute_model_frames(centers, axis_indices, mode, global_frame_indices, names_map, names_map_keys)


%% Load current model
if strcmp(mode, 'hand');
    axis_indices(1:15) = {[2, 1]; [3, 2]; [4, 3]; [6, 5]; [7, 6]; [8, 7]; [10, 9]; [11, 10]; [12, 11]; [14, 13]; [15, 14]; [16, 15]; [18, 17]; [19, 18]; [20, 19]};
    points = cell(length(names_map_keys), 1);
    for i = 1:length(names_map_keys), points{i} = centers{names_map(names_map_keys{i})}; end
    [global_frame, ~] = compute_principle_axis(points, false);
    global_axis = - global_frame(:, 1);
else
    global_axis = (centers{global_frame_indices(3)} - centers{global_frame_indices(1)}) / ...
        norm( (centers{global_frame_indices(3)} - centers{global_frame_indices(1)}));    
    global_frame = find_frame(centers(global_frame_indices), 0);
end

%factor = 10;
%display_skeleton(centers, [], axis_indices, [], false);
% myline(centers{23}, centers{23} + factor * global_frame(:, 1), 'm');
% myline(centers{23}, centers{23} + factor * global_frame(:, 2), 'm');
% myline(centers{23}, centers{23} + factor * global_frame(:, 3), 'm');

frames = cell(length(axis_indices), 1);
for i = 1:length(axis_indices)
%     if i == 12
%        disp(' ');
%     end
    if length(axis_indices{i}) == 2
        local_axis = (centers{axis_indices{i}(2)} - centers{axis_indices{i}(1)}) / norm(centers{axis_indices{i}(1)} - centers{axis_indices{i}(2)});
        axis_angle = vrrotvec(global_axis, local_axis);
        R = vrrotvec2mat(axis_angle);
        local_frame = R * global_frame;
        frames{i} = local_frame;
    end
    if length(axis_indices{i}) == 3
        frames{i} = find_frame(centers(axis_indices{i}), 0);
    end
%     factor = 10;
%     myline(centers{axis_indices{i}(1)}, centers{axis_indices{i}(1)} + factor *  frames{i}(:, 1), 'r');
%     myline(centers{axis_indices{i}(1)}, centers{axis_indices{i}(1)} + factor *  frames{i}(:, 2), 'r');
%     myline(centers{axis_indices{i}(1)}, centers{axis_indices{i}(1)} + factor *  frames{i}(:, 3), 'r');
end
