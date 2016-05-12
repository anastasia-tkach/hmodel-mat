clear; clc; close all;
format shortg;
settings.mode = 'fitting';
settings_default;
num_poses = 4;%5;
start_pose = 1;

w1 = 1; w2 = 0.3; w4 = 0.8; w5 = 100;
settings.w1 = w1; settings.w2 = w2;
settings.w4 = w4; settings.w5 = w5;
settings.discard_threshold = 0.5;
settings.block_safety_factor = 1.3;

input_path = '_my_hand/fitting_initialization/';
output_path = '_my_hand/fitting_result/';
semantics_path = '_my_hand/semantics/';

%% Load input
load([semantics_path, 'solid_blocks.mat']);
load([semantics_path, 'fitting/names_map.mat']);
%solid_blocks{19} = [names_map('palm_right'), names_map('palm_back'), names_map('palm_left'), names_map('palm_thumb'), ...
%    names_map('pinky_base'), names_map('ring_base'), names_map('middle_base'), names_map('index_base'), names_map('thumb_base')];

solid_blocks = {
    % fingers
    [names_map('pinky_top'), names_map('pinky_middle')]; [names_map('pinky_middle'), names_map('pinky_bottom')]; [names_map('pinky_bottom'), names_map('pinky_base')];
    [names_map('ring_top'), names_map('ring_middle')]; [names_map('ring_middle'), names_map('ring_bottom')]; [names_map('ring_bottom'), names_map('ring_base')];
    [names_map('middle_top'), names_map('middle_middle')]; [names_map('middle_middle'), names_map('middle_bottom')]; [names_map('middle_bottom'), names_map('middle_base')];
    [names_map('index_top'), names_map('index_middle')]; [names_map('index_middle'), names_map('index_bottom')]; [names_map('index_bottom'), names_map('index_base')];
    % thumb
    [names_map('thumb_additional'), names_map('thumb_top')]; [names_map('thumb_top'), names_map('thumb_middle')];
    [names_map('thumb_middle'), names_map('thumb_bottom')]; [names_map('thumb_bottom'), names_map('palm_left'), names_map('thumb_fold')];
    % palm
    [names_map('palm_right'), names_map('palm_back'), names_map('palm_left'), ...
    names_map('palm_pinky'), names_map('palm_ring'), names_map('palm_middle'), names_map('palm_index'), names_map('palm_thumb'), ...
    names_map('pinky_base'), names_map('ring_base'), names_map('middle_base'), names_map('index_base')];%, names_map('thumb_base')];
    % wrist
    %[names_map('wrist_top_left'), names_map('wrist_top_right'), names_map('wrist_bottom_left'), names_map('wrist_bottom_right')];
    % membranes
    [names_map('palm_pinky'), names_map('pinky_membrane')];
    [names_map('palm_ring'), names_map('ring_membrane')];
    [names_map('palm_middle'), names_map('middle_membrane')];
    [names_map('palm_index'), names_map('index_membrane')];
    };

load([semantics_path, 'fitting/blocks.mat']);
poses = cell(num_poses, 1);

for k = start_pose:start_pose + num_poses - 1
    p = k - start_pose + 1;
    load([input_path, num2str(k), '_centers.mat']); poses{p}.centers = centers; poses{p}.initial_centers = centers;
    load([input_path, num2str(k), '_radii.mat']); poses{p}.radii = radii;
    load([input_path, num2str(k), '_points.mat']); poses{p}.points = points;
    load([input_path, num2str(k), '_normals.mat']); poses{p}.normals = normals;
end

[blocks] = reindex(radii, blocks);
num_centers = length(radii); num_poses = length(poses);

%% Modify
for i = 1:length(radii)
    if i < 20 || i == 25 || (i >= 29 && i <= 34)
        radii{i} = 0.2 + 0.001 * randn;
    else
        radii{i} = 0.4 +  + 0.001 * randn;
    end
end
scales = [0.95, 0.96, 0.98, 1];
for p = 1:length(poses)
    %poses{p}.points = poses{p}.points(1:2:end);
    %poses{p}.normals = poses{p}.normals(1:2:end);
    T = scales(p) * eye(3, 3);
    for i = 1:length(poses{p}.centers)
        poses{p}.centers{i} = T * poses{p}.centers{i};
    end
    for i = 1:length(poses{p}.points)
        poses{p}.points{i} = T * poses{p}.points{i};
    end 
    
    for i = 1:length(poses{p}.centers)
        if i == 33, continue; end
        poses{p}.centers{i} = poses{p}.centers{i} + min(0.01, 0.01 * randn);        
    end
    
end
for p = 1:length(poses)
    shift = poses{p}.centers{names_map('palm_back')};
    for i = 1:length(poses{p}.centers)
        poses{p}.centers{i} = poses{p}.centers{i} - shift;
    end
    for i = 1:length(poses{p}.points)
        poses{p}.points{i} = poses{p}.points{i} - shift;
    end
end
blocks{15} = [28; 19; 34];
blocks{27} = [28; 25; 34];
%% Initialize data structures
for p = 1:length(poses)
    poses{p}.data_bounding_box = compute_data_bounding_box(poses{p}.points);
    P = zeros(length(poses{p}.points), settings.D);
    for i = 1:length(poses{p}.points), P(i, :) = poses{p}.points{i}'; end
    poses{p}.kdtree = createns(P, 'NSMethod','kdtree');
end

settings.num_centers = num_centers;
settings.solid_blocks = solid_blocks;
settings.names_map = names_map;
settings.iter = 0;
settings.history = {};

save poses poses;
save settings settings;

%% Optimizaion
X0 = zeros(num_poses * D * num_centers + num_centers, 1);
Xl = -inf * ones(num_poses * D * num_centers + num_centers, 1);
Xu = inf * ones(num_poses * D * num_centers + num_centers, 1);
num_poses = length(poses);
for p = 1:num_poses
    c = zeros(num_centers * D, 1);
    for o = 1:num_centers
        c(D * o - D + 1:D * o) = poses{p}.centers{o};
    end
    X0(D * num_centers * (p - 1) + 1:D * num_centers * p) = c;
    
end
for o = 1:num_centers
    X0(D * num_poses * num_centers + o) = radii{o};
end

options = optimoptions(@lsqnonlin, 'Algorithm', 'levenberg-marquardt', 'InitDamping', 0.01, 'Jacobian','on', 'MaxIter', 100);
X = lsqnonlin(@(X) ITERATION_LSQNONLIN(X, blocks), X0, Xl, Xu, options);

%% Load result
D = 3;
load X;
load settings;
num_centers = settings.num_centers;
num_poses = length(poses);
for p = 1:num_poses
    c = X(D * num_centers * (p - 1) + 1:D * num_centers * p);
    for o = 1:num_centers
        poses{p}.centers{o} = c(D * o - D + 1:D * o);
    end
end
for o = 1:num_centers
    radii{o} = X(D * num_poses * num_centers + o);
end


%% Display
%{
for p = 1:length(poses)
    %[poses{p}.indices, poses{p}.projections, poses{p}.block_indices] = compute_projections(poses{p}.points, poses{p}.centers, blocks, radii);
    display_result(poses{p}.centers, [], [], blocks, radii, false, 1, 'big');
    mypoints(poses{p}.points, [179, 81, 109]/255, 8);
    
    if p == 1, zoom(2); view([148, 7.264]); end
    if p == 2, zoom(2.3); view([150,  -2.7356]); end
    if p == 3, zoom(2); view([-2.662, 11.761]); end
    if p == 4, zoom(2.2); view([47, 33.264]); end
    camlight;
    drawnow;
    print(['C:/Developer/data/MATLAB/photoscan_fitting/pose', num2str(p), '_iter', num2str(settings.iter + 1)],'-dpng', '-r300');
end
%}
%% Follow energies
display_energies(settings.history, 'fitting');

