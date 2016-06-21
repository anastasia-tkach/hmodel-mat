clear; clc; close all;
settings.mode = 'fitting';
settings_default;
downscaling_factor = 2;
settings.H = 480/downscaling_factor;
settings.W = 640/downscaling_factor;
num_iters = 7;
damping = 10;
%{
    From previou5s experience
    - Do not set w2 high, it interferes with other energies
    - Set w5 quite high
%}

w1 = 1; w2 = 0.02;  w4 = 1; w5 = 100; w7 = 500;
settings.damping = damping;
settings.w1 = w1; settings.w2 = w2; settings.w3 = w3;
settings.w4 = w4; settings.w5 = w5;
settings.discard_threshold = 0.5;
settings.block_safety_factor = 1.3;

input_path = 'C:/Developer/data/MATLAB/andrii/stage2/initial/';
output_path = 'C:/Developer/data/MATLAB/andrii/stage2/final/';
semantics_path = '_my_hand/semantics/';

%% Load input
load([semantics_path, 'solid_blocks.mat']);
load([semantics_path, 'fitting/names_map.mat']);
solid_blocks{19} = [names_map('palm_right'), names_map('palm_back'), names_map('palm_left'), names_map('palm_thumb'), ...
    names_map('pinky_base'), names_map('ring_base'), names_map('middle_base'), names_map('index_base'), names_map('thumb_base')];
solid_blocks{23} = [29, 30]; % wrist

load([input_path, 'blocks.mat']);
load([input_path, 'poses.mat']);
load([input_path, 'radii.mat']);
load([input_path, 'alpha.mat']);
for i = 1:length(radii)
    radii{i} = radii{i} + 0.01 * randn;
end

[blocks] = reindex(radii, blocks);
num_centers = length(radii); num_poses = length(poses);

for p = 1:length(poses)
    poses{p}.data_bounding_box = compute_data_bounding_box(poses{p}.points);
    poses{p}.init_centers = poses{p}.centers;
end
history{1}.poses = poses; history{1}.radii = radii;

%% Optimizaion
for iter = 1:num_iters
    settings.iter = iter;
    disp(iter);
    %% Re-index
    [blocks] = reindex(radii, blocks);
    
    for p = 1:num_poses
        settings.p = p;
        
        %% Data fitting energy
        poses{p} = compute_energy1_realsense(poses{p}, radii, blocks, settings, false);
        
        %% Silhouette energy
        poses{p} = compute_energy4_realsense(poses{p}, radii, blocks, settings, false);
        
        %% Building blocks existence energy
        poses{p} = compute_energy5(poses{p}, radii, blocks, settings);
        
        %% Synch transformations energy
        poses{p}.f7 = zeros(D * length(poses{p}.centers), 1);
        poses{p}.Jc7 = eye(D * length(poses{p}.centers), D * length(poses{p}.centers));
        poses{p}.Jr7 = zeros(D * length(poses{p}.centers), length(poses{p}.centers));
        for i = 1:length(poses{p}.centers)
            if ~isempty(poses{p}.sync_centers{i})
                poses{p}.f7(D * i - D + 1:D * i) = poses{p}.centers{i} - poses{p}.sync_centers{i};
            end
        end
    end
    
    %% Shape consistency energy
    [f2, J2] = compute_energy2(poses, solid_blocks, settings, false);
    
    if (iter > num_iters), break; end
    
    %% Assemble overall linear system
    [f1, J1] = assemble_energy(poses, '1', settings);
    [f4, J4] = assemble_energy(poses, '4', settings);
    [f5, J5] = assemble_energy(poses, '5', settings);
    [f7, J7] = assemble_energy(poses, '7', settings);
    
    %% Compute update
    I = eye(D * num_centers * num_poses + num_centers, D * num_centers * num_poses + num_centers);
    I(D * num_centers * num_poses + 1:end, D * num_centers * num_poses + 1:end) = 5 * eye(num_centers, num_centers);
    I(D * num_centers * num_poses + 1:D * num_centers * num_poses + 20, ...
        D * num_centers * num_poses + 1:D * num_centers * num_poses + 20) = 10000 * eye(20, 20);
    
    %% Apply update
    w2 = w2 * 2;
    w4 = 0.5 * length(f1) / length(f4);
    
    LHS = damping * I + w1 * (J1' * J1) + w2 * (J2' * J2) + w4 * (J4' * J4) +  w5 * (J5' * J5) + w7 * (J7' * J7);
    rhs = w1 * J1' * f1 + w2 * J2' * f2 + w4 * J4' * f4 +  w5 * J5' * f5 + w7 * J7' * f7;
    delta = -  LHS \ rhs;
    
    if ~isreal(delta), error('complex parameters'), end;
    
    [valid_update, poses, radii, ~] = apply_update(poses, blocks, radii, delta, D);
    
    energies(1) = w1 * (f1' * f1); energies(2) = w2 * (f2' * f2);
    energies(4) = w4 * (f4' * f4);  energies(5) = w5 * (f5' * f5);  energies(7) = w7 * (f7' * f7);
    history{iter + 1}.poses = poses; history{iter + 1}.radii = radii; history{iter + 1}.energies = energies;
    
    %% Shift to zero
    for p = 1:num_poses
        shift = poses{p}.centers{names_map('palm_back')};
        for i = 1:length(poses{p}.centers)
            poses{p}.centers{i} = poses{p}.centers{i} - shift;
        end
        for i = 1:length(poses{p}.points)
            poses{p}.points{i} = poses{p}.points{i} - shift;
        end
    end
    
    %% Synchronize transfromations
    [poses, alpha, phalanges] = synchronize_transformations(poses, blocks, alpha, names_map, false);
end

%% Display
for p = 1:length(poses)
    %[poses{p}.indices, poses{p}.projections, poses{p}.block_indices] = compute_projections(poses{p}.points, poses{p}.centers, blocks, radii);
    %display_result(poses{p}.centers, poses{p}.points, poses{p}.projections, blocks, radii, true, 1, 'big');
    %view([-180, -90]); camlight; drawnow;
    
    display_result(poses{p}.centers, [], [], blocks, radii, false, 0.9, 'big');
    mypoints(poses{p}.points, [0.8, 0.1, 0.9]);
    view([-180, -90]); camlight; drawnow;
    
    %figure; axis off; axis equal; hold on;
    %display_skeleton(poses{p}.centers, radii, blocks, poses{p}.points, false, []);
end

%% Follow energies
display_energies(history, 'fitting');

%% Display change
%{
for p = 1:length(poses)
    figure; axis off; axis equal; hold on;
    display_skeleton(poses{p}.init_centers, radii, blocks, [], false, 'b');
    display_skeleton(poses{p}.centers, radii, blocks, [], false, 'r');
end
%}

%% Store the results
save([output_path, 'poses.mat'], 'poses');
save([output_path, 'radii.mat'], 'radii');
save([output_path, 'blocks.mat'], 'blocks');
save([output_path, 'alpha.mat'], 'alpha');
save([output_path, 'phalanges.mat'], 'phalanges');

%% Send data to hmodel-cpp
send_results_to_cpp;

