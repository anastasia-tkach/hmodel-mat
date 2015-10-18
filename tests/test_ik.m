
%% Make picture
clear; clc; rng(0);
figure(1); clf; cla; axis equal;
set(gcf, 'Position', [100, 100, 1024, 768]);
set(gcf,'color','white'); axis off; hold on;
h_src = []; h_src_p = []; h_corresp = [];
settings.D = 3;

%% Parameters
noise_jlength = 1;
noise_sigma = 0.025;
lambda = 12;
samples_per_branch = 30;
settings.num_translations = 3;
settings.num_rotations = 3;
settings.num_parameters = 7;   
settings.skeleton = true;

%% Create source
S = initialize(settings);
S = pose(S, [0, 0, 0], [+.1, +.2, -.5], settings);
S.color = [0.2 0.4 .9];
S.samples_per_branch = samples_per_branch;

%% Define target geometry
T = initialize(settings);
T.samples_per_branch = samples_per_branch;
T = pose(T, [0,0,0], [-.8, -.5, +.6], settings);
T.points = sample(T, settings); 
T.points = T.points + noise_sigma*randn(size(T.points));
T.kdtree = KDTreeSearcher(T.points); 
T.normals = compute_normals(T.points(:,1:settings.D), settings);
T.color = [0.9 0.2 0.7];

%% Display Target
scatter2(T.points, settings, 20, T.color, 'fill');
%edge2(T.points, T.points + 0.3 * T.normals, settings, 'color', [1, 0.3, 1]);

%% Display source
[h_src, h_src_p, h_corresp] = display_source(h_src, h_src_p, h_corresp, S, T, settings); waitforbuttonpress;

%% Run
for i = 1:20
    %% Create effectors matrix
    [model_points, block_indices] = sample(S, settings);
    closest_data_indices = T.kdtree.knnsearch(model_points); %< ICP like search
    data_points = T.points(closest_data_indices,:); %< effector vector
    data_normals = T.normals(closest_data_indices,:); %< normal matrix
    
    %% Solve IK & apply
    thetas = solve(S, model_points, block_indices, data_points, data_normals, lambda, settings);
    
    if settings.D == 2, thetas(settings.D + 1) = 0; end    
    S = pose(S, thetas(1:settings.num_translations), ...
        thetas(settings.num_translations + 1: settings.num_translations + settings.num_rotations), settings);
    
    %% Visualize the new source
    [h_src, h_src_p, h_corresp] = display_source(h_src, h_src_p, h_corresp, S, T, settings);
    waitforbuttonpress;
end
