close all; clear; clc;
settings_default;

%% Test: finger skeleton, rotated
data_path = '_data/htrack_model/skeleton_rotated/';
skeleton = true; mode = 'finger';

%% Test: finger skeleton, shifted
%data_path = '_data/htrack_model/skeleton_shifted/';
%skeleton = true; mode = 'finger';

%% Test: finger skeleton, bent
%data_path = '_data/htrack_model/skeleton_bent/';
%skeleton = true; mode = 'finger';

%% Test: finger skeleton, shifted and bent
%data_path = '_data/htrack_model/skeleton_shifted_and_bent/';
%skeleton = true; mode = 'finger';

%% Test: single finger
%data_path = '_data/htrack_model/finger/';
%skeleton = false; mode = 'finger';

%% Test: full hand with one bent finger
%data_path = '_data/htrack_model/hand_one_finger/';
%skeleton = false; mode = 'hand';

%% Test: full hand with all bent fingers
%data_path = '_data/htrack_model/hand_rest_pose/';
%skeleton = false; mode = 'hand';

%% Settings
damping = 50; num_iters = 5;
switch mode, case 'finger', num_parameters = 8;        
case 'hand', num_parameters = 26; end

%% Load data
load([data_path, 'points.mat']); data_points = points;
load([data_path, 'normals.mat']); data_normals = normals;

%% Initialize
segments = create_ik_model(mode);
theta = zeros(num_parameters, 1);
[posed_segments, joints] = pose_ik_model(segments, theta, false, mode);

%% Run
for i = 1:num_iters
    %% Create model-data correspondences
    [centers, radii, blocks, solid_blocks] = make_convolution_model(posed_segments, mode);
    if skeleton
        [data_model_indices, model_points, block_indices] = compute_skeleton_projections(points, centers, blocks);
    else
        [data_model_indices, model_points, block_indices] = compute_projections_matlab(data_points, centers, blocks, radii);
        % comment the line above and uncomment the line below to run faster
        % (it might crash)
        %[data_model_indices, model_points, block_indices] = compute_projections(data_points, centers, blocks, radii);
    end
    
    if skeleton
        figure; axis equal; axis off; hold on; set(gcf,'color','white'); 
        mylines(model_points, data_points, [0, 0.8, 0.8]);
        for i = 1:length(blocks), myline(centers{blocks{i}(1)}, centers{blocks{i}(2)}, 'k'); end
        mypoints(data_points, 'm'); mypoints(centers, 'k'); view(90, 0); drawnow;
    else
        display_result_convtriangles(centers, data_points, model_points, blocks, radii, true); campos([10, 160, -1500]); camlight; drawnow;
    end
    
    %% Solve IK & apply
    [F, J] = jacobian_ik(segments, joints, model_points, data_points, data_normals, get_segment_indcies(block_indices, mode), settings);
    
    %% Solve for IK
    I = eye(length(theta), length(theta));

    LHS = J' * J + damping * I;
    RHS = J' * F;
    delta_theta = LHS \ RHS;
    disp(F' * F);
    
    theta = theta + delta_theta;
    [posed_segments, joints] = pose_ik_model(segments, theta, false, mode);
end

