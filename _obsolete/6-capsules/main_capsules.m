%% Initialize

close all; clc; clear;
path = 'C:\Users\tkach\OneDrive\EPFL\Code\HandModel\data\simple_3d\';
load([path, 'radii']);

D = 3;
num_centers = 4;
num_poses = 1;
total_num_points = 0;
cumsum_num_points = zeros(num_poses + 1, 1);
children = cell(num_centers, 1);
for i = 1:num_centers - 1
    children{i} = [i + 1];
end

poses = cell(num_poses, 1);

for p = 1:num_poses
    load([path, 'points']);
    load([path, 'centers']);
    poses{p}.num_centers = num_centers;
    poses{p}.num_points = length(points);
    total_num_points = total_num_points + poses{p}.num_points;
    cumsum_num_points(p + 1) = cumsum_num_points(p) + poses{p}.num_points;
    for i = 1:length(points)
        points{i} = points{i} + 0.01 * randn(3, 1);
    end
    poses{p}.points = points;
    poses{p}.centers = centers;
end

%% Optimize
num_iters = 3;
for iter = 1:num_iters + 1
    
    for p = 1:num_poses
        
        %% Compute correspondences
        poses{p} = compute_correspondences_tangent(poses{p}, children, radii);
        
        %% Display
        display_result(poses{p}, children, radii);
        if (iter > num_iters), break; end
        
        %% Build linear system
        poses{p} = build_linear_system_tangent(poses{p}, radii, D);
        
    end
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
