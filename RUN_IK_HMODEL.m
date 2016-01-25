close all; clear; clc;
settings.mode = 'tracking';
settings_default;
skeleton = false; mode = 'hand';
D = 3; verbose = false;

%% Hmodel5
input_path = '_my_hand/fitting_result/';
semantics_path = '_my_hand/semantics/';
sensor_path = 'C:/Users/tkach/Desktop/training/';
output_path = '_my_hand/tracking_initialization/';
data_path = '_data/hmodel/';
load([semantics_path, 'tracking/names_map.mat']);
load([semantics_path, 'tracking/named_blocks.mat']);
% load([input_path, 'centers.mat']);
% load([input_path, 'radii.mat']);
load([semantics_path, 'tracking/blocks.mat']);

damping = 50;
w1 = 1; w4 = 10e4;
num_iters = 15;
num_parameters = 26;

%% Load data
load([data_path, 'points.mat']); data_points = points;
%load([data_path, 'normals.mat']); data_normals = normals;

%% Initialize
% [centers, radii] = align_restpose_hmodel_with_htrack(centers, radii, blocks, names_map, num_parameters);
% [blocks, named_blocks, names_map] = remove_wrist(semantics_path);
load([output_path, 'segments.mat']);
load([output_path, 'centers.mat']);
load([output_path, 'radii.mat']);
load([output_path, 'theta.mat']);
[attachments, global_frame_indices, palm_centers_names, solid_blocks, elastic_blocks, parents] = get_semantic_structures(centers, blocks, names_map, named_blocks);
[attachments, ~] = initialize_attachments(centers, radii, blocks, centers, attachments, mode, global_frame_indices, names_map, palm_centers_names);

% segments = initialize_ik_hmodel(centers, names_map);
% theta = zeros(num_parameters, 1);
[centers, joints] = pose_ik_hmodel(theta, centers, names_map, segments);
display_result(centers, [], [], blocks, radii, false, 1, 'big');
%% Run
for iter = 1:num_iters
    %% Create model-data correspondences
    if skeleton
        [data_model_indices, model_points, block_indices] = compute_skeleton_projections(points, centers, blocks);
    else
        [data_model_indices, model_points, block_indices] = compute_projections(data_points, centers, blocks, radii);
    end
    
    if skeleton
        figure; axis equal; axis off; hold on; set(gcf,'color','white');
        mylines(model_points, data_points, [0.75, 0.75, 0.75]);
        for j = 1:length(blocks), c1 = centers{blocks{j}(1)};  c2 = centers{blocks{j}(2)};
            scatter3(c1(1), c1(2), c1(3), 100, [0.1, 0.4, 0.7], 'o', 'filled'); scatter3(c2(1), c2(2), c2(3), 100, [0.1, 0.4, 0.7], 'o', 'filled');
            line([c1(1), c2(1)], [c1(2), c2(2)], [c1(3), c2(3)], 'color', [0.1, 0.4, 0.7], 'lineWidth', 6);
        end; mypoints(data_points, [0.9, 0.3, 0.5]);view(90, 0); drawnow;
    else
        display_result(centers, data_points, model_points, blocks, radii, true, 1, 'big');
        %figure; hold on; axis equal; axis off;
        %display_skeleton(centers, radii, blocks, [], false, []);
        %view([-90, 0]); camlight; drawnow;       
                
        campos([10, 160, -1500]); camlight; drawnow;        
    end
    
    %% Solve IK & apply
    [F1, J1] = jacobian_ik(segments, joints, model_points, data_points, get_segment_indcies_hmodel(block_indices), settings);
    [F4, J4] = jacobian_ik_joint_limits(joints);
    
    %% Solve for IK
    I = eye(length(theta), length(theta));
    
    LHS = w1 * (J1' * J1) + w4 * (J4' * J4) + damping * I;
    RHS = w1 * J1' * F1 + w4 * J4' * F4;
    delta_theta = LHS \ RHS;
    energies(1) = w1 * F1' * F1; energies(2) = w4 * F4' * F4; history{iter + 1}.energies = energies; disp(energies);
   
    theta = theta + delta_theta;
    [centers, joints] = pose_ik_hmodel(theta, centers, names_map, segments);
    [centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, mode, global_frame_indices, names_map, palm_centers_names);
    [centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, mode, global_frame_indices, names_map, palm_centers_names);
end
display_energies(history, 'IK');
