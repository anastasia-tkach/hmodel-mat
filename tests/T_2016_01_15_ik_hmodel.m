clear; clc; close all;
D = 3; verbose = false;
num_parameters = 26;

%% Hmodel
input_path = '_my_hand/fitting_result/';
semantics_path = '_my_hand/semantics/';
sensor_path = 'C:/Users/tkach/Desktop/training/';
output_path = '_my_hand/tracking_initialization/';
mode = 'my_hand';
load([semantics_path, 'tracking/names_map.mat']);
load([semantics_path, 'tracking/named_blocks.mat']);
load([input_path, 'centers.mat']);
load([input_path, 'radii.mat']);
load([semantics_path, 'tracking/blocks.mat']);

%% Initialize IK
[centers, radii] = align_restpose_hmodel_with_htrack(centers, radii, blocks, names_map, num_parameters);
[blocks, named_blocks, names_map] = remove_wrist(semantics_path);
[attachments, global_frame_indices, palm_centers_names, solid_blocks, elastic_blocks, parents] = get_semantic_structures(centers, blocks, names_map, named_blocks);
[attachments, ~] = initialize_attachments(centers, radii, blocks, centers, attachments, mode, global_frame_indices, names_map, palm_centers_names);

segments = initialize_ik_hmodel(centers, names_map);

%% Rigid transformation
rotation_axis = randn(D, 1);
rotation_angle = randn;
euler_angles = pi * randn(D, 1);
translation_vector = 100 * randn(D, 1);
Rx = makehgtform('axisrotate', [1; 0; 0], euler_angles(1));
Ry = makehgtform('axisrotate', [0; 1; 0], euler_angles(2));
Rz = makehgtform('axisrotate', [0; 0; 1], euler_angles(3));
T = makehgtform('translate', translation_vector);
offset = centers{names_map('palm_back')};
for i = 1:length(centers), centers{i} = centers{i} - offset; end
M = T * Rx * Ry * Rz;
for i = 1:length(centers), centers{i} = transform(centers{i}, M); end
for i = 1:length(centers), centers{i} = centers{i} + offset; end
display_result(centers, [], [], blocks, radii, true, 0.35, 'big');
campos([10, 160, -1500]); camlight; drawnow;

theta = zeros(num_parameters, 1);
theta(1:3) = translation_vector;
theta(4:6) = euler_angles;
%theta([9, 10, 12, 13, 14, 16, 17, 18, 20, 21, 22, 24, 25, 26]) = -pi/3;

%% Pose the model
[centers] = pose_ik_hmodel(theta, centers, names_map, segments);
[centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, mode, global_frame_indices, names_map, palm_centers_names);
[centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, mode, global_frame_indices, names_map, palm_centers_names);

display_result(centers, [], [], blocks, radii, true, 1, 'none');
%figure; axis off; axis equal; hold on; display_skeleton(centers, radii, blocks, [], false, []);
campos([10, 160, -1500]); %camlight; drawnow;
