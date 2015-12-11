settings_default;

%% Test: finger skeleton, rotated
%data_path = '_data/htrack_model/skeleton_rotated/';
%skeleton = true; mode = 'finger';

%% Test: finger skeleton, shifted
%data_path = '_data/htrack_model/skeleton_shifted/';
%skeleton = true; mode = 'finger';

%% Test: finger skeleton, bent
%data_path = '_data/htrack_model/skeleton_bent/';
%skeleton = true; mode = 'finger';

%% Test: finger skeleton, strongly bent
%data_path = '_data/htrack_model/skeleton_strongly_bent/';
%skeleton = true; mode = 'finger';

%% Test: finger skeleton, shifted and bent
%data_path = '_data/htrack_model/skeleton_shifted_and_bent/';
%skeleton = true; mode = 'finger';

%% Test: single finger
%data_path = '_data/htrack_model/finger_bent/';
%skeleton = false; mode = 'finger';

%% Test: single finger
%data_path = '_data/htrack_model/finger_strongly_bent/';
%skeleton = false; mode = 'finger';

%% Test: full hand with one slightly bent finger
%data_path = '_data/htrack_model/hand_finger_bent/';
%skeleton = false; mode = 'hand';

%% Test: full hand with one bent finger
data_path = '_data/htrack_model/hand_one_finger/';
skeleton = false; mode = 'hand';

%% Test: full hand with all bent fingers
%data_path = '_data/htrack_model/hand_rest_pose/';
%skeleton = false; mode = 'hand';

%% Weights
w1 = 1;
if skeleton, w2 = 10; end
if ~skeleton && strcmp(mode, 'finger') w2 = 50; end
if ~skeleton && strcmp(mode, 'hand') w2 = 50; end

%% Load data
load([data_path, 'radii.mat']);
load([data_path, 'blocks.mat']); [blocks] = reindex(radii, blocks);
load([data_path, 'centers.mat']);
load([data_path, 'points.mat']); data_points = points;
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
        previous_rotations{k} = eye(3, 3);
        k = k + 1;
    end
end


%% Optimizaion5
for iter = 1:5
    [blocks] = reindex(radii, blocks);
    
    %% Compute model_points
    if skeleton
        [data_model_indices, model_points, ~] = compute_skeleton_projections(data_points, centers, blocks);
    else
        %[data_model_indices, model_points, ~] = compute_projections_matlab(data_points, centers, blocks, radii);
        % comment the line above and uncomment the line below to run faster
        % (it might crash)
        [data_model_indices, model_points, block_indices] = compute_projections(data_points, centers, blocks, radii);
    end
    
    
    %% Display
    if skeleton
        figure; axis equal; axis off; hold on; set(gcf,'color','white');
        mylines(model_points, data_points, [0.75, 0.75, 0.75]);
        for j = 1:length(blocks), c1 = centers{blocks{j}(1)};  c2 = centers{blocks{j}(2)};
            scatter3(c1(1), c1(2), c1(3), 100, [0.1, 0.4, 0.7], 'o', 'filled'); scatter3(c2(1), c2(2), c2(3), 100, [0.1, 0.4, 0.7], 'o', 'filled');
            line([c1(1), c2(1)], [c1(2), c2(2)], [c1(3), c2(3)], 'color', [0.1, 0.4, 0.7], 'lineWidth', 6);
        end; mypoints(data_points, [0.9, 0.3, 0.5]);view(90, 0); drawnow;
    else
        display_result_convtriangles(centers, data_points, model_points, blocks, radii, true);
        view([-90, 0]); drawnow;
        %campos([10, 160, -1500]); camlight;
    end
    
    %% Translations energy
    if skeleton
        [f1, J1] = jacobian_arap_translation_skeleton(centers, model_points, data_model_indices, data_points, D);
    else
        [f1, J1] = jacobian_arap_translation(centers, radii, blocks, data_points, data_model_indices, data_points, D);
    end
    
    %% Rotations energy
    [f2, J2] = jacobian_arap_rotation(centers, blocks, edge_indices, restpose_edges, solid_blocks, D);
    %[f2, J2, previous_rotations] = jacobian_arap_ik_rotation(centers, blocks, edge_indices, restpose_edges, solid_blocks, D, previous_rotations, mode);
    
    %% Compute update
    I = eye(D * length(centers), D * length(centers));
    LHS = damping * I + w1 * (J1' * J1) + w2 * (J2' * J2);
    rhs = w1 * (J1' * f1) + w2 * (J2' * f2);
    delta = -  LHS \ rhs;
    
    %% Apply update
    for o = 1:length(centers), centers{o} = centers{o} + delta(D * o - D + 1:D * o); end
    disp([w1 * (f1' * f1) + w2 * (f2' * f2),  w1 * (f1' * f1), w2 * (f2' * f2)]);
end







