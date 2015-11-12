settings_default;
%data_path = '_data/convtriangles/';
%data_path = '_data/htrack_model/';
data_path = '_data/htrack_model/2D/';

load([data_path, 'radii.mat']);
load([data_path, 'blocks.mat']); [blocks] = reindex(radii, blocks);
load([data_path, 'centers.mat']);
load([data_path, 'points.mat']);
%load([data_path, 'normals.mat']);
load([data_path, 'solid_blocks.mat']);


w1 = 1; w2 = 0; w3 = 20; damping = 0.1; num_iters = 7;
settings.skeleton = true;
settings.display = true;

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
pose.data_bounding_box = compute_data_bounding_box(points);
P = zeros(length(points), settings.D);
for i = 1:length(points), P(i, :) = points{i}'; end
pose.kdtree = createns(P, 'NSMethod','kdtree');

%% Optimizaion5
for iter = 1:num_iters
    [blocks] = reindex(radii, blocks);
    
    %pose.centers = centers; pose.points = points; pose.normals = normals; display = true;
    %[f1, J1, f2, J2, f3, J3] = combined_arap(pose, centers, points, radii, blocks, solid_blocks, restpose_edges, edge_indices, settings, true);
    
    %% Compute projections
    if settings.skeleton
        [data_model_indices, projections, ~] = compute_skeleton_projections(points, centers, blocks);
    else
        [data_model_indices, projections, ~] = compute_projections(points, centers, blocks, radii);
    end
    %[model_points, data_points] = sample_model(pose, radii, blocks, settings);
    %[model_data_indices, ~, ~] = compute_projections(model_points, centers, blocks, radii);
    model_points = []; model_data_indices = []; data_points = [];
    
    
    
    %% Display
    if settings.display && ~settings.skeleton
        display_result_convtriangles(centers, points, projections, blocks, radii, true); %campos([10, 160, -1500]); camlight;
        %display_result_convtriangles(centers, points, [], blocks, radii, false);
        %mypoints(points, [0.75, 0.75, 0.75]); mypoints(data_points, 'm');
        %mylines(data_points, model_points, [0.1, 0.8, 0.8]); campos([10, 160, -1500]); camlight; drawnow;
        drawnow;
    end
    if settings.display && settings.skeleton
        figure; axis equal; axis off; hold on;
        mylines(projections, points, [0, 0.8, 0.8]);
        for i = 1:length(blocks), myline(centers{blocks{i}(1)}, centers{blocks{i}(2)}, 'k'); end
        mypoints(points, 'm'); mypoints(centers, 'k'); view(90, 0); drawnow;
    end
    
    
    %% Translations energy
    if settings.skeleton
        [f1, J1] = jacobian_arap_translation_skeleton(centers, projections, data_model_indices, points, D);
    else
        [f1, J1] = jacobian_arap_translation(centers, radii, blocks, points, data_model_indices, points, D);
        %[f2, J2] = jacobian_arap_translation(centers, radii, blocks, model_points, model_data_indices, data_points, D);
    end
    
    %% Rotations energy
    [f3, J3] = jacobian_arap_rotation(centers, blocks, edge_indices, restpose_edges, solid_blocks, D);
    
    %% Compute update
    I = eye(D * length(centers), D * length(centers));
       
    %LHS = damping * I + w1 * (J1' * J1) + w2 * (J2' * J2) + w3 * (J3' * J3);
    %rhs = w1 * (J1' * f1) + w2 * (J2' * f2) + w3 * (J3' * f3);
    
    LHS = damping * I + w1 * (J1' * J1) + w3 * (J3' * J3);
    rhs = w1 * (J1' * f1) + w3 * (J3' * f3);
    
    delta = -  LHS \ rhs;
    
    %% Apply update
    for o = 1:length(centers)
        centers{o} = centers{o} + delta(D * o - D + 1:D * o);
    end
    
    
    %disp([w1 * (f1' * f1) + w2 * (f2' * f2) + w3 * (f3' * f3),  w1 * (f1' * f1), w2 * (f2' * f2), w3 * (f3' * f3)]);
    
    disp([w1 * (f1' * f1) + w3 * (f3' * f3),  w1 * (f1' * f1), w3 * (f3' * f3)]);
    
    
end





