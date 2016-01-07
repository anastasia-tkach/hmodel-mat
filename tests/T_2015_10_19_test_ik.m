
%% Make picture
clear; clc; close all; rng(0);
figure(1); hold on;
clf; cla; axis equal;
set(gcf, 'Position', [100, 100, 1024, 768]);
set(gcf,'color','white'); axis off;
h_src = []; h_src_p = []; h_corresp = [];
settings.D = 2;

%% Parameters
noise_jlength = 1;
noise_sigma = 0.025;
lambda = 1;
samples_per_branch = 30;
settings.num_translations = 3;
settings.num_joints = 3;
if settings.D == 2, settings.num_rotation_dof = 1; end
if settings.D == 3, settings.num_rotation_dof = 3; end
settings.num_rotations = settings.num_rotation_dof * (settings.num_joints + 1);
settings.num_parameters =  settings.num_translations +  settings.num_rotations;
settings.skeleton = true;

%% Create source
if settings.D == 2
    S.segments = {[4]; [5]; [6]; [7]};
    S.parent_id = [0; 0; 0; 0; 4; 5; 6];
    S.children_ids = {[0]; [0]; [0]; [5]; [6]; [7]; []};
    S.kinematic_chain = {[1:4]; [1:5]; [1:6]; [1:7]};
end
if settings.D == 3
    S.segments = {[4; 5; 6]; [7; 8; 9]; [10; 11; 12]; [13; 14; 15]};
    S.parent_id = [0; 0; 0; 0; 4; 5; 6; 7; 8; 9; 10; 11; 12; 13; 14];
    S.children_ids = {[0]; [0]; [0]; [5]; [6]; [7]; [8]; [9]; [10]; [11]; [12]; [13]; [14]; [15]; []};
    S.kinematic_chain = {[1:6]; [1:9]; [1:12]; [1:15]};
end
S = initialize(S, settings);
if settings.D == 2
    S.thetas = [0; 0; 0; 0.1; 0.2; -0.5; 0];
    S = pose(S,  settings.num_translations + 1, settings);
end
if settings.D == 3
    S.thetas = zeros(settings.num_parameters, 1);
    S = pose(S,  settings.num_translations + 1, settings);
end

S.color = [0.2 0.4 .9];
S.samples_per_branch = samples_per_branch;

%% Define target geometry
T = S;
T = initialize(T, settings);
T.samples_per_branch = samples_per_branch;
if settings.D == 2
    T.thetas = [0; 0; 0; -0.7; -0.5; 0.6; 0];
    T = pose(T,  settings.num_translations + 1, settings);
end
if settings.D == 3
    T.thetas = [1; 1; 1; 0; 0; -0.7; 0; 0; -0.5; 0; 1; 0.6; 0; 0; 0];
    T = pose(T,  settings.num_translations + 1, settings);
end

T.points = sample(T, settings);
T.points = T.points + noise_sigma*randn(size(T.points));
T.kdtree = KDTreeSearcher(T.points);
T.normals = compute_normals(T.points(:,1:settings.D), settings);
T.color = [0.9 0.2 0.7];

%% Display Target
scatter2(T.points, settings, 20, T.color, 'fill');

%% Display source
hold on; axis equal; axis off;
[h_src, h_src_p, h_corresp] = display_source(h_src, h_src_p, h_corresp, S, T, settings);

%% Run
for i = 1:10
    %% Create model-data correspondences
    [model_points, block_indices] = sample(S, settings);
    closest_data_indices = T.kdtree.knnsearch(model_points); %< ICP like search
    data_points = T.points(closest_data_indices,:); %< effector vector
    data_normals = T.normals(closest_data_indices,:); %< normal matrix
    
    %% Create data-model correspondences
    %for j = 1:size(T.points, 1), points{j} = T.points(j, :)'; end
    %for j = settings.num_translations + 1:settings.num_parameters
    %    centers{j - settings.num_translations} = S.global_translation(j, :)'; end
    %blocks = {[1, 2], [2, 3], [3, 4]};
    %[model_indices, projections, cell_block_indices] = compute_skeleton_projections(points, centers, blocks);
    %mylines(points, projections, 'r'); mypoints(projections, 'r');
    %block_indices = zeros(length(projections), 1);
    %model_points = zeros(length(projections), settings.D);
    %for j = 1:length(projections)
    %    model_points(j, :) = projections{j}';
    %    block_indices(j) = cell_block_indices{j} + settings.num_translations;
    %end
    
    %% Solve IK & apply
    [F, J] = jacobian_ik(S, model_points, block_indices, T.points, data_normals, settings);
    
    %% Solve for IK
    I = eye(settings.num_parameters, settings.num_parameters);
    LHS = J' * J + lambda^2 * I;
    RHS = J' * F;
    delta_theta = LHS \ RHS;
    disp(F' * F);
    
    S.thetas = S.thetas + delta_theta;
    if settings.D == 2, S.thetas(settings.D + 1) = 0; end
    S = pose(S, settings.num_translations + 1, settings);
    
    %% Visualize the new source
    [h_src, h_src_p, h_corresp] = display_source(h_src, h_src_p, h_corresp, S, T, settings); view([0; 0; 1]);
    %waitforbuttonpress;
end

%% Verify
disp([T.thetas S.thetas]);
figure; hold on; axis off; axis equal;
S = pose(S, settings.num_translations + 1, settings);
draw(S, settings, S.color, 'color', S.color, 'linewidth', 5);
S.thetas = T.thetas;
S = pose(S, settings.num_translations + 1, settings);
draw(S, settings, T.color, 'color', T.color, 'linewidth', 5);


