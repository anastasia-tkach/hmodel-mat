clc;
close all;
clear;
camera_ray = [0; 0; 1];

%% Hand model
new_model = false;

if ~new_model
    input_path = '_my_hand/tracking_initialization/';
    semantics_path = '_my_hand/semantics/';
    load([input_path, 'centers.mat']); load([input_path, 'radii.mat']);
    load([semantics_path, 'tracking/blocks.mat']);
    [blocks] = reindex(radii, blocks);
    load([semantics_path, 'palm_blocks.mat']);
    load([semantics_path, 'fingers_blocks.mat']);
    load([semantics_path, 'fingers_base_centers.mat']);
    load([semantics_path, 'fitting/names_map.mat']);
    load([semantics_path, 'tracking/names_map.mat']);
    load([semantics_path, 'tracking/named_blocks.mat']);
    palm_blocks = {[21,22,28], [28,22,26], [22,23,26], [26, 23, 25], [26, 20, 25], [23, 24, 25], [20, 25, 36], [20, 36, 19], ...
        [30,31,21], [21,22,31], [31,32,22], [22,23,32], [32,23,24], [32,24,33]};
    fingers_blocks{5} = {[35,17], [17,18], [18,19]};
    blocks = [fingers_blocks{1}, fingers_blocks{2}, fingers_blocks{3}, fingers_blocks{4}, fingers_blocks{5}, palm_blocks];
    blocks = reindex(radii, blocks);
else
    input_path = '_my_hand/final/';
    semantics_path = '_my_hand/semantics/';
    load([semantics_path, 'fitting/names_map.mat']);
    load([semantics_path, 'fitting/blocks.mat'], 'blocks');
    load([input_path, 'centers.mat'], 'centers');
    load([input_path, 'radii.mat'], 'radii');
    load([input_path, 'phalanges.mat'], 'phalanges');
    load([input_path, 'dofs.mat'], 'dofs');
    blocks = blocks(1:28);
    palm_blocks = {
        [names_map('thumb_base'), names_map('thumb_bottom'), names_map('thumb_fold')], ...
        [names_map('palm_ring'), names_map('palm_pinky'), names_map('palm_right')], ...
        [names_map('palm_back'), names_map('palm_ring'), names_map('palm_right')], ...
        [names_map('palm_back'), names_map('palm_ring'), names_map('palm_middle')], ...
        [names_map('palm_back'), names_map('palm_left'), names_map('palm_middle')], ...
        [names_map('palm_left'), names_map('palm_middle'), names_map('palm_index')], ...
        [names_map('pinky_membrane'), names_map('palm_pinky'), names_map('ring_membrane')], ...
        [names_map('palm_ring'), names_map('palm_pinky'), names_map('ring_membrane')], ...
        [names_map('palm_ring'), names_map('middle_membrane'), names_map('ring_membrane')], ...
        [names_map('palm_ring'), names_map('palm_middle'), names_map('middle_membrane')], ...
        [names_map('palm_middle'), names_map('palm_index'), names_map('middle_membrane')], ...
        [names_map('palm_index'), names_map('index_membrane'), names_map('middle_membrane')], ...
        [names_map('thumb_base'), names_map('thumb_fold'), names_map('palm_thumb')]
        };
    
    fingers_blocks{1} = {[names_map('pinky_middle'), names_map('pinky_top')], ...
        [names_map('pinky_bottom'), names_map('pinky_middle')], ...
        [names_map('pinky_base'), names_map('pinky_bottom')]};
    fingers_blocks{2} = {[names_map('ring_top'), names_map('ring_middle')], ...
        [names_map('ring_bottom'), names_map('ring_middle')], ...
        [names_map('ring_bottom'), names_map('ring_base')]};
    fingers_blocks{3} = {[names_map('middle_top'), names_map('middle_middle')], ...
        [names_map('middle_bottom'), names_map('middle_middle')], ...
        [names_map('middle_bottom'), names_map('middle_base')]};
    fingers_blocks{4} = {[names_map('index_middle'), names_map('index_top')], ...
        [names_map('index_bottom'), names_map('index_middle')], ...
        [names_map('index_base'), names_map('index_bottom')]};
    fingers_blocks{5} = {[names_map('thumb_top'), names_map('thumb_additional')], ...
        [names_map('thumb_top'), names_map('thumb_middle')], ...
        [names_map('thumb_bottom'), names_map('thumb_middle')]};
    
end


%print_blocks_names(blocks, names_map);

%% Pose the model
if ~new_model
    [attachments, global_frame_indices, palm_centers_names, solid_blocks, elastic_blcks, parents] = get_semantic_structures(centers, blocks, names_map, named_blocks);
    [attachments, ~] = initialize_attachments(centers, radii, blocks, centers, attachments, 'hand', global_frame_indices, names_map, palm_centers_names);
    segments = initialize_ik_hmodel(centers, names_map);
    theta = zeros(26, 1);
    theta = 0.1 * randn(26, 1);
    theta(4:6) = theta(4:6) * 2;
    joints = joints_parameters(zeros(26, 1));
    [centers, segments] = pose_ik_hmodel(theta, centers, names_map, segments, joints);
    [centers] = pose_ik_hmodel(theta, centers, names_map, segments, joints);
    [centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, 'hand', global_frame_indices, names_map, palm_centers_names);
    [centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, 'hand', global_frame_indices, names_map, palm_centers_names);
    
    %% Adjust the model
    centers{names_map('thumb_fold')} = centers{names_map('thumb_fold')} + [-7; 2; 0];
    centers{names_map('middle_membrane')} = centers{names_map('middle_membrane')} + [0; -3; 2];
    centers{names_map('index_membrane')} = centers{names_map('index_membrane')} + [0; 0; -2];
    radii{names_map('thumb_top')} = 0.9 * radii{names_map('thumb_top')};
else
    num_thetas = 29;
    phalanges = initialize_offsets(centers, phalanges, names_map);
    theta = 0.2 * randn(num_thetas, 1);
    phalanges = htrack_move(theta, dofs, phalanges);
    [centers] = update_centers(centers, phalanges, names_map);
end


%% Find outline
[final_outline] = find_model_outline(centers, radii, blocks, palm_blocks, fingers_blocks, camera_ray, names_map, true, true);

