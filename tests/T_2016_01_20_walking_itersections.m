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
fingers_base_centers(5) = 20;

%% Pose the model
[attachments, global_frame_indices, palm_centers_names, solid_blocks, elastic_blcks, parents] = get_semantic_structures(centers, blocks, names_map, named_blocks);
[attachments, ~] = initialize_attachments(centers, radii, blocks, centers, attachments, 'hand', global_frame_indices, names_map, palm_centers_names);
segments = initialize_ik_hmodel(centers, names_map);
theta = 0.2 * randn(26, 1);
theta(4:6) = theta(4:6) * 2;
[centers, joints] = pose_ik_hmodel(theta, centers, names_map, segments);
[centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, 'hand', global_frame_indices, names_map, palm_centers_names);
[centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, 'hand', global_frame_indices, names_map, palm_centers_names);

camera_ray = [0; 0; 1];

[final_outline] = find_model_outline(centers, radii, blocks, palm_blocks, fingers_blocks, fingers_base_centers, camera_ray, true);
view([-180, -90]); camlight;