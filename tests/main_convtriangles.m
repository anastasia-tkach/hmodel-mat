%% Initialize
clc; clear;
close all; set_path;
absolute_path = ['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\'];
data_path = [absolute_path, '_data\convtriangles\'];
pp = 1;
load([data_path, 'radii']);
load([data_path, 'blocks']);

D = 3;
num_poses = 1;
total_num_points = 0;
cumsum_num_points = zeros(num_poses + 1, 1);
poses = cell(num_poses, 1);

for p = 1:num_poses
    load([data_path, num2str(pp), '_points']);
    load([data_path, num2str(pp), '_centers']);
    %load([data_path, 'points']);
    %load([data_path, 'centers']);
    poses{p}.num_points = length(points);
    total_num_points = total_num_points + poses{p}.num_points;
    cumsum_num_points(p + 1) = cumsum_num_points(p) + poses{p}.num_points;
    poses{p}.points = points;
    poses{p}.centers = centers;
    num_centers = length(centers);
    poses{p}.num_centers = num_centers;
end

%% Restart from previous iteration
% iter = 8;
% load history;
% poses{1}.centers = history{iter}.poses{1}.centers;
% radii = history{iter}.radii;
% blocks = history{iter}.blocks;


%% Optimize
num_iters = 5;
history = cell(num_iters + 1, 1);
p = 1;
for iter = 1:num_iters
    disp(iter);
    %% Re-index
    [blocks] = reindex(radii, blocks);
    
    %% Compute correspondences
    [poses{p}.indices, poses{p}.projections, poses{p}.block_indices] = compute_projections(poses{p}.points, poses{p}.centers, blocks, radii);

    %% Display
    history{iter + 1}.poses{p} = poses{p};
    history{iter + 1}.radii = radii;
    history{iter + 1}.blocks = blocks;
    
    %display_result_convtriangles(poses{p}, blocks, radii, true);
    if (iter > num_iters), break; end
    
    %% Build linear system
    poses{p} = compute_energy1(poses{p}, radii, D);
    
    %% Assemble overall linear system
    num_parameters = D * num_centers * num_poses + num_centers;
    f = zeros(total_num_points, 1);
    J = zeros(total_num_points, num_parameters);
    
    for p = 1:num_poses
        J(cumsum_num_points(p) + 1:cumsum_num_points(p + 1), D * num_centers * (p - 1) + 1:D * num_centers * p) = poses{p}.Jc;
        J(cumsum_num_points(p) + 1:cumsum_num_points(p + 1), D * num_centers * num_poses + 1:end) = poses{p}.Jr;
        f(cumsum_num_points(p) + 1:cumsum_num_points(p + 1)) = poses{p}.f;
    end   

    
    %% Compute update
    beta = 0;
    I = eye(D * num_centers * num_poses + num_centers, D * num_centers * num_poses + num_centers);
    delta = - (J' * J + beta * I) \ (J' * f);
    
    %% Add a check is there is a tangent plane for each capsule
    [poses, radii] = apply_update(poses, blocks, radii, delta, D);
    
end

save([absolute_path, 'rendering\history'], 'history');
examine_history;