%% Load initial model
data_path = '_data/htrack_model/temp/';

load([data_path, 'centers.mat']);

axis_indices = {[2, 1]; [3, 2]; [4, 3]; [6, 5]; [7, 6]; [8, 7]; [10, 9]; [11, 10]; [12, 11]; [14, 13]; ...
    [15, 14]; [16, 15]; [18, 17]; [19, 18]; [20, 19]; [23, 21]; [23, 24]; [22, 24]; [21, 22];};

initial_centers = centers;
global_frame_indices = [23, 24, 21];

frames = compute_model_frames(centers, axis_indices, global_frame_indices);
return

%% Load current model
data_path = '_data/htrack_model/joint_limits_hand/';

load([data_path, 'centers.mat']);

global_axis = (centers{21} - centers{23}) / norm(centers{21} - centers{23});

global_frame = find_frame(centers(global_frame_indices));

factor = 10;

display_skeleton(centers, radii, axis_indices, [], false);

myline(centers{23}, centers{23} + factor * global_frame(:, 1), 'm');
myline(centers{23}, centers{23} + factor * global_frame(:, 2), 'm');
myline(centers{23}, centers{23} + factor * global_frame(:, 3), 'm');

for i = 1:15
    local_axis = (centers{axis_indices{i}(2)} - centers{axis_indices{i}(1)}) / norm(centers{axis_indices{i}(1)} - centers{axis_indices{i}(2)});
    axis_angle = vrrotvec(global_axis, local_axis);
    R = vrrotvec2mat(axis_angle);
    local_frame = R * global_frame;
    myline(centers{axis_indices{i}(1)}, centers{axis_indices{i}(1)} + factor * local_frame(:, 1), 'g');
    myline(centers{axis_indices{i}(1)}, centers{axis_indices{i}(1)} + factor * local_frame(:, 2), 'g');
    myline(centers{axis_indices{i}(1)}, centers{axis_indices{i}(1)} + factor * local_frame(:, 3), 'g');
end



