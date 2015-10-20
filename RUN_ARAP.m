settings_default;

%% Test: finger skeleton, rotated
data_path = '_data/htrack_model/skeleton_rotated/';
skeleton = true; 

%% Test: finger skeleton, shifted
%data_path = '_data/htrack_model/skeleton_shifted/';
%skeleton = true;

%% Test: finger skeleton, bent
%data_path = '_data/htrack_model/skeleton_bent/';
%skeleton = true;

%% Test: finger skeleton, shifted and bent
%data_path = '_data/htrack_model/skeleton_shifted_and_bent/';
%skeleton = true;

%% Test: single finger
%data_path = '_data/htrack_model/finger/';
%skeleton = false;

%% Test: full hand with one bent finger
%data_path = '_data/htrack_model/hand_one_finger/';
%skeleton = false;

%% Test: full hand with all bent fingers
%data_path = '_data/htrack_model/hand_rest_pose/';
%skeleton = false;

%% Weights
w1 = 1; w2 = 1; damping = 0.1; num_iters = 5;

%% Load data
load([data_path, 'radii.mat']);
load([data_path, 'blocks.mat']); [blocks] = reindex(radii, blocks);
load([data_path, 'centers.mat']);
load([data_path, 'points.mat']);
load([data_path, 'solid_blocks.mat']);

%% Set up data structures
edge_indices = cell(length(blocks), 1);
restpose_edges = cell(length(blocks), 1);
k = 1;
for i = 1:length(blocks)
    index = nchoosek(blocks{i}, 2);
    for j = 1:size(index, 1)
        edge_indices{i}{j} = [index(j, :)];
        restpose_edges{k} = centers{edge_indices{i}{j}(2)} - centers{edge_indices{i}{j}(1)};
        k = k + 1;
    end
end

%% Optimizaion5
for iter = 1:num_iters
    [blocks] = reindex(radii, blocks);
    
    %% Compute projections
    if skeleton
        [data_model_indices, projections, ~] = compute_skeleton_projections(points, centers, blocks);
    else
        [data_model_indices, projections, ~] = compute_projections(points, centers, blocks, radii);
    end
    
    %% Display
    if skeleton
        figure; axis equal; axis off; hold on;
        mylines(projections, points, [0, 0.8, 0.8]);
        for i = 1:length(blocks), myline(centers{blocks{i}(1)}, centers{blocks{i}(2)}, 'k'); end
        mypoints(points, 'm'); mypoints(centers, 'k'); view(90, 0); drawnow;
    else
        display_result_convtriangles(centers, points, projections, blocks, radii, true); %campos([10, 160, -1500]); camlight;
        drawnow;
    end
    
    %% Translations energy
    if skeleton
        [f1, J1] = jacobian_arap_translation_skeleton(centers, projections, data_model_indices, points, D);
    else
        [f1, J1] = jacobian_arap_translation(centers, radii, blocks, points, data_model_indices, points, D);
    end
    
    %% Rotations energy
    [f2, J2] = jacobian_arap_rotation(centers, blocks, edge_indices, restpose_edges, solid_blocks, D);
    
    %% Compute update
    I = eye(D * length(centers), D * length(centers));
    LHS = damping * I + w1 * (J1' * J1) + w2 * (J2' * J2);
    rhs = w1 * (J1' * f1) + w2 * (J2' * f2);
    delta = -  LHS \ rhs;
    
    %% Apply update
    for o = 1:length(centers), centers{o} = centers{o} + delta(D * o - D + 1:D * o); end
    disp([w1 * (f1' * f1) + w2 * (f2' * f2),  w1 * (f1' * f1), w2 * (f2' * f2)]);
    
    
end





