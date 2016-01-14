clear;
close all;
clc;
D = 3;
mode = 'tracking';
verbose = false;
semantics_path = '_my_hand/semantics/';
input_path = '_my_hand/fitting_result/';
output_path = '_my_hand/tracking_initialization/';
sensor_path = 'C:/Users/tkach/Desktop/training/';

%% Load data
load([input_path, 'radii.mat']);
load([input_path, 'centers.mat']);

%% Remove wrist
[blocks, named_blocks, names_map] = remove_wrist(semantics_path);

%% Load htrack data
K = 360;
[beta, theta] = load_htrack_data(sensor_path, output_path, K, D);

%% Rigid transformation
if verbose, figure; hold on; axis off; axis equal; end
segments = create_ik_model('hand');
[segments, joints] = pose_ik_model(segments, theta, verbose, 'hand');
[htrack_centers, htrack_radii, htrack_blocks, ~, ~] = make_convolution_model(segments, 'hand');

[centers, radii] = find_htrack_hmodel_transformation(centers, radii, blocks, beta, names_map, verbose, D);

%% Compute principal axis of the palm
key_points_names = {'palm_pinky', 'palm_ring', 'palm_middle', 'palm_index', 'palm_back', 'palm_attachment', 'palm_right', 'palm_back', 'palm_left'};
[centers, htrack_centers] = aling_htrack_hmodel_frames(centers, radii, blocks, theta, htrack_centers, names_map, key_points_names, verbose, D);

%% Find non-rigid fitting
[centers] = find_htrack_model_nonrigid(centers, radii, blocks, htrack_centers, theta, names_map, named_blocks, key_points_names, false, D);

%% Get sensor points
[data_points] = get_sensor_points(sensor_path, K);

%% Save the data
save([output_path, 'centers.mat'], 'centers');
save([output_path, 'radii.mat'], 'radii');
save([output_path, 'data_points.mat'], 'data_points');
save([output_path, 'theta.mat'], 'theta');

