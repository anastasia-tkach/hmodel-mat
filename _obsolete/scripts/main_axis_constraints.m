%% Initialize
clc; clear;
close all; set_path;
absolute_path = ['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\'];
data_path = [absolute_path, '_data\robert_wang\'];
% data_path = [absolute_path, '_data\convtriangles\'];
load([data_path, 'radii']);
load([data_path, 'blocks']);
load([data_path, 'axis']);
load([data_path, 'joints']);

D = 3;
num_poses = 5;
test_pose = 0;
num_centers = length(radii);
num_links = sum(cellfun('length', blocks));
num_parameters = D * num_centers * num_poses + num_centers;

total_num_points = 0;
cumsum_num_points = zeros(num_poses + 1, 1);
poses = cell(num_poses, 1);
for p = 1:num_poses
    load([data_path, num2str(p), '_points']);
    load([data_path, num2str(p), '_centers']);
    if (test_pose)
        load([data_path, num2str(test_pose), '_points']);
        load([data_path, num2str(test_pose), '_centers']);
    end
    poses{p}.num_points = length(points);
    total_num_points = total_num_points + poses{p}.num_points;
    cumsum_num_points(p + 1) = cumsum_num_points(p) + poses{p}.num_points;
    poses{p}.points = points;
    poses{p}.centers = centers;
    poses{p}.num_centers = num_centers;
    if (test_pose)        
        display_result_convtriangles(poses{1}, blocks, radii, 2);
        num_poses = 1; break;
    end
end

%% Optimize
num_iters = 10;
history = cell(num_iters + 1, 1);
for iter = 1:num_iters
    disp(iter);
    %% Re-index
    [blocks] = reindex(radii, blocks);
    
    for p = 1:num_poses
        
        %% Compute correspondences
        [poses{p}.indices, poses{p}.projections, poses{p}.block_indices] = compute_projections(poses{p}.points, poses{p}.centers, blocks, radii);
        
        %% Display
        history{iter + 1}.poses{p} = poses{p};
        history{iter + 1}.radii = radii;
        history{iter + 1}.blocks = blocks;
        
        if (iter > num_iters), break; end
        
        %% Build linear system
        poses{p} = compute_energy1(poses{p}, radii, D);
    end

    %% Assemble overall linear system
    f1 = zeros(total_num_points, 1);
    J1 = zeros(total_num_points, num_parameters);
    
    for p = 1:num_poses
        J1(cumsum_num_points(p) + 1:cumsum_num_points(p + 1), D * num_centers * (p - 1) + 1:D * num_centers * p) = poses{p}.Jc;
        J1(cumsum_num_points(p) + 1:cumsum_num_points(p + 1), D * num_centers * num_poses + 1:end) = poses{p}.Jr;
        f1(cumsum_num_points(p) + 1:cumsum_num_points(p + 1)) = poses{p}.f;
    end
    
    %% Poses coherence energy term
    f2 = zeros(num_links, 1);
    J2 = zeros(num_links, num_parameters);
    count = 1;
    for k = 2:num_poses
        for b = 1:length(blocks)
            if (length(blocks{b}) == 2)
                index1 = blocks{b}(1);
                index2 = blocks{b}(2);
            end
            if (length(blocks{b}) == 3)
                index1 = [blocks{b}(1), blocks{b}(1), blocks{b}(2)];
                index2 = [blocks{b}(2), blocks{b}(3), blocks{b}(3)];
            end
            for l = 1:length(index1)
                i = index1(l);
                j = index2(l);
                [fi, Ja, Jb, Jc, Jd] = energy2(poses{1}.centers{i}, poses{1}.centers{j}, poses{k}.centers{i}, poses{k}.centers{j});
                f2(count) = fi;
                J2(count, D * (i - 1) + 1 : D * i) = Ja;
                J2(count, D * (j - 1) + 1 : D * j) = Jb;
                shift = (k - 1) * D * num_centers;
                J2(count, shift + D * (i - 1) + 1 : shift + D * i) = Jc;
                J2(count, shift + D * (j - 1) + 1 : shift + D * j) = Jd;
                count = count + 1;
            end
        end
    end
    
    %% Compute update
    alpha = 1;
    beta = 20;
    gamma = 200;
    I = eye(D * num_centers * num_poses + num_centers, D * num_centers * num_poses + num_centers);
    delta = - (alpha * (J1' * J1) + beta * (J2' * J2) + gamma * I) \ (alpha * J1' * f1 + beta * J2' * f2);
    
    %% Add a check is there is a tangent plane for each capsule
    [poses, radii] = apply_update(poses, blocks, radii, delta, D);
    
end

save([absolute_path, 'rendering\history'], 'history');
examine_history;

