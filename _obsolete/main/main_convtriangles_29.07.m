%% Initialize

%close all; clc; clear;
w = warning ('off','all');
path = ['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\data\convtriangles\hand\'];
%path = ['C:\Users\', getenv('USERNAME'), '\Desktop\HandModel_24.07\data\convtriangles\cut_hand\'];
load([path, 'radii']);
load([path, 'blocks']);

D = 3;
num_poses = 1;
total_num_points = 0;
cumsum_num_points = zeros(num_poses + 1, 1);
poses = cell(num_poses, 1);

for p = 1:num_poses
    load([path, 'points']);
    load([path, 'centers']);
    poses{p}.num_points = length(points);
    total_num_points = total_num_points + poses{p}.num_points;
    cumsum_num_points(p + 1) = cumsum_num_points(p) + poses{p}.num_points;
    poses{p}.points = points;
    poses{p}.centers = centers;
    num_centers = length(centers);
    poses{p}.num_centers = num_centers;
end

%% Restart from previous iteration
iter = 9;
load history;
poses{1}.centers = history{iter}.poses{1}.centers;
radii = history{iter}.radii;
blocks = history{iter}.blocks;


%% Optimize
num_iters = 11;
%history = cell(num_iters + 1, 1);
p = 1;
for iter = 10:num_iters

    %% Re-index
    [blocks] = reindex(radii, blocks);
    
    %% Compute correspondences
    poses{p} = compute_projections_convtriangles(poses{p}, blocks, radii);
    
    %% Display        
    history{iter + 1}.poses{p} = poses{p};
    history{iter + 1}.radii = radii;
    history{iter + 1}.blocks = blocks;    
    
    display_result_convtriangles(poses{p}, blocks, radii, true);
    if (iter > num_iters), break; end      
    
    %% Build linear system
    poses{p} = compute_energy1(poses{p}, radii, D);
    
    %% Assemble overall linear system
    
    f = zeros(total_num_points, 1);
    J = zeros(total_num_points, D * num_centers * num_poses + num_centers);
    
    for p = 1:num_poses
        J(cumsum_num_points(p) + 1:cumsum_num_points(p + 1), D * num_centers * (p - 1) + 1:D * num_centers * p) = poses{p}.Jc;
        J(cumsum_num_points(p) + 1:cumsum_num_points(p + 1), D * num_centers * num_poses + 1:end) = poses{p}.Jr;
        f(cumsum_num_points(p) + 1:cumsum_num_points(p + 1)) = poses{p}.f;
    end
    
    %% Compute update
    delta = - (J' * J) \ (J' * f);
    
    %% Add a check is there is a tangent plane for each capsule    
    
    for p = 1:num_poses
        poses{p}.delta_c = delta(D * num_centers * (p - 1) + 1:D * num_centers * p);
        for o = 1:num_centers
            poses{p}.centers{o} = poses{p}.centers{o} + poses{p}.delta_c(D * o - D + 1:D * o);
        end
    end
    
    for o = 1:num_centers
        radii{o} = radii{o} + delta(D * num_poses * num_centers + o);
    end
    
end

%save history history
