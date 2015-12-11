%{
TODO
- Visualize length change
- Visualize radius change
- Change the topology back and add thumb membrane spheres
- Try adding closeness to initial length 
- Try ARAP with averaged edge length
%}

clear; clc; close all;
settings.mode = 'fitting';
settings_default;
data_path = '_data/my_hand/initialized/';

%% Load input
load([data_path, 'solid_blocks_indices.mat']);
load([data_path, 'blocks.mat']);
load([data_path, 'named_blocks.mat']);
poses = cell(num_poses, 1);

for k = start_pose:start_pose + num_poses - 1
    p = k - start_pose + 1;
    load([data_path, num2str(k), '_centers.mat']); poses{p}.centers = centers; poses{p}.initial_centers = centers;
    load([data_path, num2str(k), '_radii.mat']); poses{p}.radii = radii;
    load([data_path, num2str(k), '_points.mat']); poses{p}.points = points;
    load([data_path, num2str(k), '_normals.mat']); poses{p}.normals = normals;
end

[poses, radii] = adjust_poses_scales(poses, blocks, true);
[blocks] = reindex(radii, blocks);
num_centers = length(radii); num_poses = length(poses);

%% Initialize data structures
for p = 1:length(poses)
    poses{p}.data_bounding_box = compute_data_bounding_box(poses{p}.points);
    P = zeros(length(poses{p}.points), settings.D);
    for i = 1:length(poses{p}.points), P(i, :) = poses{p}.points{i}'; end
    poses{p}.kdtree = createns(P, 'NSMethod','kdtree');
end

%% Optimizaion
for iter = 1:num_iters
    settings.iter = iter;
    %% Re-index
    [blocks] = reindex(radii, blocks);
    
    for p = 1:num_poses
        %% Data fitting energy
        poses{p} = compute_energy1(poses{p}, radii, blocks, settings, false);
        
        %% Silhouette energy
        poses{p} = compute_energy4(poses{p}, blocks, radii, settings, false);
        
        %% Building blocks existence energy
        poses{p} = compute_energy5(poses{p}, radii, blocks, settings);
    end
    
    %% Shape consistency energy
    [f2, J2] = compute_energy2(poses, solid_blocks_indices, blocks, settings);
    
    if (iter > num_iters), break; end
    
    %% Assemble overall linear system
    [f1, J1] = assemble_energy(poses, '1', settings);
    [f4, J4] = assemble_energy(poses, '4', settings);
    [f5, J5] = assemble_energy(poses, '5', settings);
    
    %% Compute update
    I = eye(D * num_centers * num_poses + num_centers, D * num_centers * num_poses + num_centers);
    I(D * num_centers * num_poses + 1:end, D * num_centers * num_poses + 1:end) = 5 * eye(num_centers, num_centers);
    
    %% Apply update
    LHS = damping * I + w1 * (J1' * J1) + w2 * (J2' * J2) +  w4 * (J4' * J4) +  w5 * (J5' * J5);
    rhs = w1 * J1' * f1 + w2 * J2' * f2 + w4 * J4' * f4 + w5 * J5' * f5;
    delta = -  LHS \ rhs;
    
    [valid_update, poses, radii, ~] = apply_update(poses, blocks, radii, delta, D);
    
    energies(1) = w1 * (f1' * f1); energies(2) = w2 * (f2' * f2); energies(3) = w4 * (f4' * f4); energies(4) = w5 * (f5' * f5); disp(energies);
    
    
end

for p = 1:length(poses)
    [poses{p}.indices, poses{p}.projections, poses{p}.block_indices] = compute_projections(poses{p}.points, poses{p}.centers, blocks, radii);
    display_result(poses{p}.centers, poses{p}.points, poses{p}.projections, blocks, radii, true, 1);
    % figure; axis off; axis equal; hold on; display_skeleton(poses{p}.centers, radii, blocks, poses{p}.points, false, []);
end

results_path = '_data/my_hand/fitted_model/';
centers = poses{2}.centers;
save([results_path, 'centers.mat'], 'centers');
save([results_path, 'radii.mat'], 'radii');
save([results_path, 'blocks.mat'], 'blocks');

%% Display change in length by pose
solid_blocks_indices = solid_blocks;
solid_blocks = cell(length(solid_blocks_indices), 1);
for i = 1:length(solid_blocks_indices)
    solid_blocks{i} = [];
    for j = 1:length(solid_blocks_indices{i})
        solid_blocks{i} = [solid_blocks{i}, blocks{solid_blocks_indices{i}(j)}];
    end
    solid_blocks{i} = unique(solid_blocks{i});
end
for p = 1:length(poses)
    poses{p}.edges_length = [];
    poses{p}.restpose_edges_length = [];
    count = 1;
    for b = 1:length(solid_blocks)
        indices = nchoosek(solid_blocks{b}, 2);
        index1 = indices(:, 1);
        index2 = indices(:, 2);
        for l = 1:length(index1)
            i = index1(l);
            j = index2(l);
            poses{p}.edges_length(count) = norm(poses{p}.centers{i} -  poses{p}.centers{j});
            poses{p}.restpose_edges_length(count) = norm(poses{p}.initial_centers{i} -  poses{p}.initial_centers{j});
            count = count + 1;
        end
    end
    figure; hold on;    
    stem(poses{p}.edges_length, 'filled', 'lineWidth', 2);    
    stem(poses{p}.restpose_edges_length, 'filled', 'lineWidth', 2);    
    ylim([0, 3]); drawnow;
end






