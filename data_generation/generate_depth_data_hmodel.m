clear; clc; close all;
D = 3; verbose = false;
num_parameters = 26;

%% Hmodel
input_path = '_my_hand/tracking_initialization/';
semantics_path = '_my_hand/semantics/';
sensor_path = 'C:/Users/tkach/Desktop/training/';
output_path = '_my_hand/tracking_initialization/';
data_path = '_data/hmodel/';
load([semantics_path, 'tracking/names_map.mat']);
load([semantics_path, 'tracking/named_blocks.mat']);
load([input_path, 'centers.mat']);
load([input_path, 'radii.mat']);
load([input_path, 'theta.mat']);
load([semantics_path, 'tracking/blocks.mat']);


mode = 'my_hand';
settings.fov = 15;
downscaling_factor = 5;
settings.H = 480/downscaling_factor;
settings.W = 640/downscaling_factor;
settings.D = 3;
settings.sparse_data = false;
settings.RAND_MAX = 32767;
side = 'front'; view_axis = 'Z';
closing_radius = 10;

%% Get model
[centers, radii] = align_restpose_hmodel_with_htrack(centers, radii, blocks, names_map, num_parameters);
[blocks, named_blocks, names_map] = remove_wrist(semantics_path);
[attachments, global_frame_indices, palm_centers_names, solid_blocks, elastic_blocks, parents] = get_semantic_structures(centers, blocks, names_map, named_blocks);
[attachments, ~] = initialize_attachments(centers, radii, blocks, centers, attachments, mode, global_frame_indices, names_map, palm_centers_names);

segments = initialize_ik_hmodel(centers, names_map);
model_centers = centers;

%% Set theta
%theta = zeros(26, 1);
%theta(1) = 7; % left/right
theta(2) = 0; % + up/ - down
theta(3) = 0; % - forwards/ + backwards
theta(5) = 0;
theta([9, 13, 17, 21, 25])  = -pi/4;
%theta(1) = 0; theta(3) = 0; theta(4:5) = pi/9;
%theta(24:26) = -pi/6; 
%theta(16:18) = -pi/6;
%theta(6) = pi/50;


%% Pose the model
[centers] = pose_ik_hmodel(theta, centers, names_map, segments);
%[centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, mode, global_frame_indices, names_map, palm_centers_names);
%[centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, mode, global_frame_indices, names_map, palm_centers_names);

%% Generate depth data
data_bounding_box = compute_model_bounding_box(centers, radii);
[raytracing_matrix, camera_axis, camera_center] = get_raytracing_matrix(centers, radii, data_bounding_box, view_axis, settings, side);       
rendered_model = render_tracking_model(centers, blocks, radii, raytracing_matrix, camera_center, settings);
[I, J] = find(rendered_model(:, :, 3) > - settings.RAND_MAX);
points = cell(length(I), 1);
for k = 1:length(I), points{k} = squeeze(rendered_model(I(k), J(k), :)); end

%% Display and save
display_result(model_centers, [], [], blocks, radii, false, 1, 'big');
mypoints(points, 'm');
view([-180, -90]); camlight;
save([data_path, 'points.mat'], 'points');

