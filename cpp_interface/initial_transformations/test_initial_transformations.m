close all; clc;
display = false;

input_path = '_my_hand/fitting_result/';
semantics_path = '_my_hand/semantics/';
load([semantics_path, 'fitting/names_map.mat']);
load([input_path, 'radii.mat'], 'radii');
load([semantics_path, 'fitting/blocks.mat'], 'blocks');
num_poses = 5;
poses = cell(num_poses, 1);
for p = 1:num_poses
    load([input_path, num2str(p), '_centers.mat']);
    poses{p}.centers = centers;
end

%% Scale to make the alignment more stable
scaling_factor = 25;
for p = 1:num_poses
    for i = 1:length(poses{p}.centers)
        poses{p}.centers{i} = scaling_factor * poses{p}.centers{i};
        radii{i} = scaling_factor * radii{i};
    end
end
poses_blocks = blocks;

%% Align with previous model
input_path = '_my_hand/tracking_initialization/';
load([input_path, 'centers.mat']);
load([semantics_path, 'tracking/blocks.mat']);
pose.centers = centers;
p = 4;
palm_indices = [names_map('palm_right'), names_map('palm_back'), names_map('palm_left'), ...
    names_map('pinky_base'), names_map('ring_base'), names_map('middle_base'), names_map('index_base'), names_map('thumb_base')];
P = cell(length(palm_indices), 1); Q = cell(length(palm_indices), 1);
for i = 1:length(palm_indices)
    P{i} = pose.centers{palm_indices(i)}; 
    Q{i} = poses{p}.centers{palm_indices(i)};
end
[M, scaling] = find_rigid_transformation(P, Q, true);
for i = 1:length(poses{p}.centers)
    poses{p}.centers{i} = transform(poses{p}.centers{i}, M);
    radii{i} = radii{i} * scaling;
end
if display
    figure; hold on; axis off; axis equal;
    display_skeleton(pose.centers, [], blocks, [], false, 'b');
    display_skeleton(poses{p}.centers, radii, poses_blocks, [], false, 'r');
end
blocks = poses_blocks;

%% Align poses
[poses] = align_poses(poses, radii, blocks, names_map, false);
if (display)
    figure; hold on; axis off; axis equal; hold on;
    for i = 1:length(poses)
        display_skeleton(poses{i}.centers, radii, blocks, [], false, 'b');
    end
end

%% Initial transformations

thumb_indices = [names_map('thumb_base'), names_map('thumb_bottom'), names_map('thumb_middle'), names_map('thumb_additional')];
alpha1 = compute_initial_transformation(poses, thumb_indices, 'thumb');

index_indices = [names_map('index_base'), names_map('index_bottom'), names_map('index_middle'), names_map('index_top')];
alpha2 = compute_initial_transformation(poses, index_indices, 'index');

middle_indices = [names_map('middle_base'), names_map('middle_bottom'), names_map('middle_middle'), names_map('middle_top')];
alpha3 = compute_initial_transformation(poses, middle_indices, 'middle');

ring_indices = [names_map('ring_base'), names_map('ring_bottom'), names_map('ring_middle'), names_map('ring_top')];
alpha4 = compute_initial_transformation(poses, ring_indices, 'ring');

pinky_indices = [names_map('pinky_base'), names_map('pinky_bottom'), names_map('pinky_middle'), names_map('pinky_top')];
alpha5 = compute_initial_transformation(poses, pinky_indices, 'pinky');

