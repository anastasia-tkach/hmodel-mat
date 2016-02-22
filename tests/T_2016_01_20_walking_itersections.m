
close all;
clear;
%% Synthetic data
[centers, radii, blocks] = get_random_convquad();
for i = 1:length(centers)
    centers{i} = centers{i} + [0; 0; 1];
end

%% Hand model
input_path = '_my_hand/tracking_initialization/';
semantics_path = '_my_hand/semantics/';
load([input_path, 'centers.mat']); load([input_path, 'radii.mat']);
load([semantics_path, 'tracking/blocks.mat']); [blocks] = reindex(radii, blocks);
load([semantics_path, 'palm_blocks.mat']);
load([semantics_path, 'fingers_blocks.mat']);
load([semantics_path, 'fingers_base_centers.mat']);
load([semantics_path, 'tracking/names_map.mat']);
load([semantics_path, 'tracking/named_blocks.mat']);


%% Topology change
palm_blocks = {[21,22,28], [28,22,26], [22,23,26], [26, 23, 25], [26, 20, 25], [23, 24, 25], [20, 25, 36], [20, 36, 19], ...
    [30,31,21], [21,22,31], [31,32,22], [22,23,32], [32,23,24], [32,24,33]};
fingers_blocks{5} = {[35,17], [17,18], [18,19]};

blocks = [fingers_blocks{1}, fingers_blocks{2}, fingers_blocks{3}, fingers_blocks{4}, fingers_blocks{5}, palm_blocks];
palm_blocks = [palm_blocks, fingers_blocks{1}{3}, fingers_blocks{2}{3}, fingers_blocks{3}{3}, fingers_blocks{4}{3}];
fingers_blocks{1} = fingers_blocks{1}(1:2);
fingers_blocks{2} = fingers_blocks{2}(1:2);
fingers_blocks{3} = fingers_blocks{3}(1:2);
fingers_blocks{4} = fingers_blocks{4}(1:2);
fingers_blocks{5} = fingers_blocks{5}(1:3);
fingers_base_centers(1) = 3;
fingers_base_centers(2) = 7;
fingers_base_centers(3) = 11;
fingers_base_centers(4) = 15;
fingers_base_centers(5) = 19;

%% Pose the model
[attachments, global_frame_indices, palm_centers_names, solid_blocks, elastic_blcks, parents] = get_semantic_structures(centers, blocks, names_map, named_blocks);
[attachments, ~] = initialize_attachments(centers, radii, blocks, centers, attachments, 'hand', global_frame_indices, names_map, palm_centers_names);
segments = initialize_ik_hmodel(centers, names_map);
theta = 0.4 * randn(26, 1);
theta(4:6) = theta(4:6) * 2;
[centers, joints] = pose_ik_hmodel(theta, centers, names_map, segments);
[centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, 'hand', global_frame_indices, names_map, palm_centers_names);
[centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, 'hand', global_frame_indices, names_map, palm_centers_names);

camera_ray = [0; 0; 1];

[final_outline] = find_model_outline(centers, radii, blocks, palm_blocks, fingers_blocks, fingers_base_centers, camera_ray, false);
