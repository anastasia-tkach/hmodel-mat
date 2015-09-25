%% Initialize

close all; clc; clear;
addpath('C:\Users\Anastasia\OneDrive\EPFL\Code\HandModel');
path = 'C:\Users\Anastasia\OneDrive\EPFL\Code\HandModel\data\finger_photo\';
load([path, 'R']);

num_centers = 4;
num_poses = 5;
total_num_points = 0;
cumsum_num_points = zeros(num_poses + 1, 1);
children = cell(num_centers, 1);
radii = cell(num_centers, 1);
for i = 1:num_centers
    radii{i} = R(i);
end
for i = 1:num_centers - 1
    children{i} = [i + 1];
end

poses = cell(num_poses, 1);

for p = 1:num_poses
    load([path, 'P', num2str(p)]);
    load([path, 'C', num2str(p)]);
    poses{p}.num_centers = num_centers;
    poses{p}.num_points = size(P, 1);
    total_num_points = total_num_points + poses{p}.num_points;
    cumsum_num_points(p + 1) = cumsum_num_points(p) + poses{p}.num_points;
    poses{p}.centers = cell(num_centers, 1);
    poses{p}.points = cell(poses{p}.num_points, 1);
    poses{p}.f = zeros(poses{p}.num_points, 1);
    poses{p}.J = zeros(poses{p}.num_points, num_centers * 3);
    
    for i = 1:num_centers
        poses{p}.centers{i} = C(i, :)';
    end
    for i = 1:poses{p}.num_points
        poses{p}.points{i} = P(i, :)';
    end
end

%% Show input

for p = 1:num_poses
    figure; axis equal;
    picture = imread([path, num2str(p), '.jpg']);
    imshow(picture); hold on;
    draw_data(poses{p}.num_points, poses{p}.points);
    draw_model(num_centers, poses{p}.centers, radii);
end

waitforbuttonpress;

%% Optimize
num_iters = 3;
for iter = 1:num_iters
    
    for p = 1:num_poses
        
        %% Compute correspondences
        poses{p} = compute_correspondences(poses{p}, children);
        
        %% Build linear system
        poses{p} = build_linear_system(poses{p}, radii);
        
        %% Display
        %if (iter == num_iters)
            display_many_poses(poses{p}, radii);
        %end
        
    end
    
    %% Assemble overall linear system
    
    f1 = zeros(total_num_points, 1);
    J1 = zeros(total_num_points, 2 * num_centers * num_poses + num_centers);
    
    for p = 1:num_poses
        J1(cumsum_num_points(p) + 1:cumsum_num_points(p + 1), 2 * num_centers * (p - 1) + 1:2 * num_centers * p) = poses{p}.Jc;
        J1(cumsum_num_points(p) + 1:cumsum_num_points(p + 1), 2 * num_centers * num_poses + 1:end) = poses{p}.Jr;
        f1(cumsum_num_points(p) + 1:cumsum_num_points(p + 1)) = poses{p}.f;
    end
    
    %% Poses coherence energy term
    f2 = zeros(num_centers - 1, 1);
    J2 = zeros(num_centers - 1, 2 * num_centers * num_poses + num_centers);
    u = 1;
    for i = 1:num_centers
        for j = children{i}
            for k = 2:num_poses
                [f_u, J_ci, J_cj, J_ck, J_cl] = energy2(poses{1}.centers{i}, poses{1}.centers{j}, poses{k}.centers{i}, poses{k}.centers{j});
                f2(u) = f_u;
                J2(u, 2 * i - 1 : 2 * i) = J_ci;
                J2(u, 2 * j - 1 : 2 * j) = J_cj;
                J2(u, (k - 1) * 2 * num_centers + 2 * i - 1:(k - 1) * 2 * num_centers + 2 * i) = J_ck;
                J2(u, (k - 1) * 2 * num_centers + 2 * j - 1:(k - 1) * 2 * num_centers + 2 * j) = J_cl;
                u = u + 1;
            end
        end
    end
    
    %% Compute update
    beta = 20;
    delta = - (J1' * J1 + beta * J2' * J2) \ (J1' * f1 + beta * J2' * f2);
    for p = 1:num_poses
        poses{p}.delta_c = delta(2 * num_centers * (p - 1) + 1:2 * num_centers * p);
        for o = 1:num_centers
            poses{p}.centers{o} = poses{p}.centers{o} + poses{p}.delta_c(2 * o - 1:2 * o);
        end
    end
    
    for o = 1:num_centers
        radii{o} = radii{o} + delta(2 * num_poses * num_centers + o);
    end
    
end

%close all;

%% Display output

for p = 1:num_poses
    figure; axis equal;
    picture = imread([path, num2str(p), '.jpg']);
    imshow(picture); hold on;
    draw_data(poses{p}.num_points, poses{p}.points);
    draw_model(num_centers, poses{p}.centers, radii);
end

indices{1} = [1, 2];
indices{2} = [2, 3];
indices{3} = [3, 4];
for i = 1:length(indices)
    l = zeros(1, num_poses);
    for p = 1:num_poses
        l(p) = norm(poses{p}.centers{indices{i}(1)} - poses{p}.centers{indices{i}(2)});
    end
    disp(l);
end




