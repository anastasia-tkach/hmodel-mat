clear; clc; close all;
settings.mode = 'fitting';
settings_default;
num_poses = 5;
start_pose = 1;
num_iters = 7;
damping = 100;
%{
    From previou5s experience
    - Do not set w2 high, it interferes with other energies
    - Set w5 quite high
%}
%w1 = 1; w2 = 1; w3 = 0.3;  w4 = 1; w5 = 1000; w6 = 1;
w1 = 1; w2 = 1; w3 = 1;  w4 = 1; w5 = 1000; w6 = 2;
settings.damping = damping;
settings.w1 = w1; settings.w2 = w2; settings.w3 = w3; 
settings.w4 = w4; settings.w5 = w5;
settings.discard_threshold = 0.5;
settings.block_safety_factor = 1.3;

input_path = '_my_hand/fitting_initialization/';
output_path = '_my_hand/fitting_result/';
semantics_path = '_my_hand/semantics/';

%% Load input
load([semantics_path, 'solid_blocks.mat']);
load([semantics_path, 'fitting/blocks.mat']);
load([semantics_path, 'smooth_blocks.mat']);
load([semantics_path, 'tangent_spheres.mat']);
load([semantics_path, 'tangent_blocks.mat']);
poses = cell(num_poses, 1);

for k = start_pose:start_pose + num_poses - 1
    p = k - start_pose + 1;
    load([input_path, num2str(k), '_centers.mat']); poses{p}.centers = centers; poses{p}.initial_centers = centers;
    load([input_path, num2str(k), '_radii.mat']); poses{p}.radii = radii;
    load([input_path, num2str(k), '_points.mat']); poses{p}.points = points;
    load([input_path, num2str(k), '_normals.mat']); poses{p}.normals = normals;
end

%[poses, radii] = adjust_poses_scales(poses, blocks, false);
%radii = poses{5}.radii;
[blocks] = reindex(radii, blocks);
num_centers = length(radii); num_poses = length(poses);

%% Initialize data structures
for p = 1:length(poses)
    poses{p}.data_bounding_box = compute_data_bounding_box(poses{p}.points);
    P = zeros(length(poses{p}.points), settings.D);
    for i = 1:length(poses{p}.points), P(i, :) = poses{p}.points{i}'; end
    poses{p}.kdtree = createns(P, 'NSMethod','kdtree');
end

history{1}.poses = poses; history{1}.radii = radii;

%% Optimizaion
for iter = 1:num_iters
    settings.iter = iter;
    %% Re-index
    [blocks] = reindex(radii, blocks);
    
    for p = 1:num_poses
        settings.p = p;
        %% Data fitting energy
        poses{p} = compute_energy1(poses{p}, radii, blocks, settings, false);
        
        %% Smoothness energy
        [poses{p}.f3, poses{p}.Jc3, poses{p}.Jr3] = compute_energy3(poses{p}.centers, radii, blocks, settings);
        
        %% Silhouette energy
        poses{p} = compute_energy4(poses{p}, blocks, radii, settings, false);
        
        %% Building blocks existence energy
        poses{p} = compute_energy5(poses{p}, radii, blocks, settings);
        
        %% Tangency energy
        [poses{p}.f6, poses{p}.Jc6, poses{p}.Jr6] = compute_energy6(centers, radii, tangent_blocks, tangent_spheres, false);
    end
    
    %% Shape consistency energy
    [f2, J2] = compute_energy2(poses, solid_blocks, settings, false);
    
    if (iter > num_iters), break; end
    
    %% Assemble overall linear system
    [f1, J1] = assemble_energy(poses, '1', settings);
    [f3, J3] = assemble_energy(poses, '3', settings);
    [f4, J4] = assemble_energy(poses, '4', settings);
    [f5, J5] = assemble_energy(poses, '5', settings);
    [f6, J6] = assemble_energy(poses, '6', settings);
    
    %% Compute update
    I = eye(D * num_centers * num_poses + num_centers, D * num_centers * num_poses + num_centers);
    I(D * num_centers * num_poses + 1:end, D * num_centers * num_poses + 1:end) = 5 * eye(num_centers, num_centers);
    
    %% Apply update
    w4 = length(f1) / length(f4);
    LHS = damping * I + w1 * (J1' * J1) + w2 * (J2' * J2) +  w3 * (J3' * J3) + w4 * (J4' * J4) +  w5 * (J5' * J5) +  w6 * (J6' * J6);
    rhs = w1 * J1' * f1 + w2 * J2' * f2 + w3 * J3' * f3 +  w4 * J4' * f4 + w5 * J5' * f5 + w6 * J6' * f6;
    delta = -  LHS \ rhs;
    
    if ~isreal(delta), error('complex parameters'), end;    
    
    [valid_update, poses, radii, ~] = apply_update(poses, blocks, radii, delta, D);
    
    energies(1) = w1 * (f1' * f1); energies(2) = w2 * (f2' * f2); energies(3) = w3 * (f3' * f3); 
    energies(4) = w4 * (f4' * f4); energies(5) = w5 * (f5' * f5); energies(6) = w6 * (f6' * f6); disp(energies);
    history{iter + 1}.poses = poses; history{iter + 1}.radii = radii; history{iter + 1}.energies = energies;
    
end

%% Display
for p = 1:length(poses)
    [poses{p}.indices, poses{p}.projections, poses{p}.block_indices] = compute_projections(poses{p}.points, poses{p}.centers, blocks, radii);
    display_result(poses{p}.centers, poses{p}.points, poses{p}.projections, blocks, radii, false, 1, 'big');
    %figure; axis off; axis equal; hold on; 
    %display_skeleton(poses{p}.centers, radii, blocks, poses{p}.points, false, []);
end

%% Color code length change
% display_edge_stretching(poses, blocks, history);

%% Follow energies
display_energies(history, 'fitting');

%% Final result - average distance
total_fitting_error = 0;
for p = 1:length(poses)
    [~, projections, ~] = compute_projections(poses{p}.points, poses{p}.centers, blocks, radii); 
    fitting_error = 0;
    count = 0;
    for i = 1:length(poses{p}.points)
        if isempty(projections{i}), continue; end
        fitting_error = fitting_error + norm(poses{p}.points{i} - projections{i});
        count = count + 1;
    end
    total_fitting_error = total_fitting_error + fitting_error / count;    
end
total_fitting_error = total_fitting_error / length(poses);
disp(['RESULT = ', num2str(total_fitting_error)]);

%% Store the results
% centers = poses{4}.centers;
% points = poses{4}.points;
% save([output_path, 'centers.mat'], 'centers');
% save([output_path, 'points.mat'], 'points');
% save([output_path, 'radii.mat'], 'radii');
% save([output_path, 'blocks.mat'], 'blocks');
