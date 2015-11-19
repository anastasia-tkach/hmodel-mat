function [frames] = compute_model_frames(centers, axis_indices, global_frame_indices)


%% Load current model

global_axis = (centers{global_frame_indices(3)} - centers{global_frame_indices(1)}) / ...
    norm( (centers{global_frame_indices(3)} - centers{global_frame_indices(1)}));

global_frame = find_frame(centers(global_frame_indices));

%factor = 10;
%display_skeleton(centers, [], axis_indices, [], false);
% myline(centers{23}, centers{23} + factor * global_frame(:, 1), 'm');
% myline(centers{23}, centers{23} + factor * global_frame(:, 2), 'm');
% myline(centers{23}, centers{23} + factor * global_frame(:, 3), 'm');

frames = cell(length(axis_indices), 1);
for i = 1:length(axis_indices)
    if length(axis_indices{i}) == 2
        local_axis = (centers{axis_indices{i}(2)} - centers{axis_indices{i}(1)}) / norm(centers{axis_indices{i}(1)} - centers{axis_indices{i}(2)});
        axis_angle = vrrotvec(global_axis, local_axis);
        R = vrrotvec2mat(axis_angle);
        local_frame = R * global_frame;
        frames{i} = local_frame;
    end
    if length(axis_indices{i}) == 3
        frames{i} = find_frame(centers(axis_indices{i}));
    end
    %myline(centers{axis_indices{i}(1)}, centers{axis_indices{i}(1)} + factor *  frames{i}(:, 1), 'g');
    %myline(centers{axis_indices{i}(1)}, centers{axis_indices{i}(1)} + factor *  frames{i}(:, 2), 'g');
    %myline(centers{axis_indices{i}(1)}, centers{axis_indices{i}(1)} + factor *  frames{i}(:, 3), 'g');
end
