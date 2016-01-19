close all; clear; clc;
settings.mode = 'tracking';
settings_default;

data_path = '_data/htrack_model/';
skeleton = false; mode = 'hand';

damping = 0.0001;
w1 = 1; w4 = 10e4;
num_iters = 2;
num_parameters = 26;

%% Load data
load([data_path, 'points.mat']); data_points = points;
%load([data_path, 'normals.mat']); data_normals = normals;
data_points = data_points(2303:2303);

%% Initialize
segments = create_ik_model(mode);
theta = zeros(num_parameters, 1);
[posed_segments, joints] = pose_ik_model(segments, theta, false, mode);

%% Run
for iter = 1:num_iters
    %% Create model-data correspondences
    [centers, radii, blocks, solid_blocks] = make_convolution_model(posed_segments, mode);
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
        display_result(centers, data_points, model_points, blocks, radii, true, 0.7, 'big');        
        view([-90, 0]); camlight; drawnow;
        %campos([10, 160, -1500]); camlight; drawnow;
    end
    
    %% Solve IK & apply
    [F1, J1] = jacobian_ik(segments, joints, model_points, data_points, get_segment_indcies(block_indices, mode), settings);
    [F4, J4] = jacobian_ik_joint_limits(joints);
    %J1([1:23, 25:26]) = 0;
    %% Solve for IK
    I = eye(length(theta), length(theta));    
    LHS = w1 * (J1' * J1) + w4 * (J4' * J4) + damping * I;
    RHS = w1 * J1' * F1 + w4 * J4' * F4;
    delta_theta = LHS \ RHS;
    energies(1) = w1 * F1' * F1; energies(2) = w4 * F4' * F4; 
    history{iter + 1}.energies = energies; disp(energies);    
    
    theta = theta + delta_theta;
    [posed_segments, joints] = pose_ik_model(segments, theta, false, mode);
end
display_energies(history, 'IK');
