clear; close all;
D = 3; verbose = false;
num_parameters = 26;

%% Hmodel
input_path = '_my_hand/fitting_result/';
semantics_path = '_my_hand/semantics/';
output_path = '_my_hand/tracking_initialization/';
data_path = '_data/hmodel/';
load([semantics_path, 'tracking/names_map.mat']);
load([semantics_path, 'tracking/named_blocks.mat']);
load([semantics_path, 'palm_blocks.mat']);
load([semantics_path, 'fingers_blocks.mat']);
load([semantics_path, 'tracking/blocks.mat']);
load([input_path, 'radii.mat']);

load([input_path, '4_centers.mat']);
load([input_path, 'radii.mat']);
[centers, ~, M, scaling] = align_restpose_hmodel_with_htrack(centers, radii, blocks, names_map, num_parameters);

%% Align rest and fist
load([input_path, '4_centers.mat']); rest_centers = centers;
load([input_path, '5_centers.mat']); fist_centers = centers;

[blocks, named_blocks, names_map] = remove_wrist(semantics_path);

%% Apply the transform
for i = 1:length(centers)
    rest_centers{i} = rest_centers{i} * scaling;
    fist_centers{i} = fist_centers{i} * scaling; 
    rest_centers{i} = transform(rest_centers{i}, M);
    fist_centers{i} = transform(fist_centers{i}, M);    
    radii{i} = radii{i} * scaling;
end

%% Find scaling
palm_indices = [];
for i = 1:5%length(palm_blocks)
    for j = 1:length(palm_blocks{i})
        palm_indices = [palm_indices; palm_blocks{i}(j)];
    end
end
palm_indices = unique(palm_indices);

for i = 1:length(palm_indices)
    p{i} = rest_centers{palm_indices(i)};
    q{i} = fist_centers{palm_indices(i)};
end

[M, scaling] = find_rigid_transformation(p, q, false);
for i = 1:length(fist_centers)
    fist_centers{i} = transform(fist_centers{i}, M);
end

%% Display

% figure; hold on; axis off; axis equal;
% display_skeleton(rest_centers, radii, [palm_blocks, blocks(21:24)'], [], false, 'b');
% display_skeleton(fist_centers, radii, [palm_blocks, blocks(21:24)'], [], false, 'm');
% view([180, -90]); camlight; drawnow;
% return

%% Replace the fingers
fingers_indices = [];
for i = 1:4
    for j = 1:2
        for k = 1:length(fingers_blocks{i}{j})
            fingers_indices = [fingers_indices; fingers_blocks{i}{j}(k)];
        end
    end
end
fingers_indices = unique(fingers_indices);

[attachments, global_frame_indices, palm_centers_names, solid_blocks, elastic_blocks, parents] = get_semantic_structures(rest_centers, blocks, names_map, named_blocks);
attachments{names_map('palm_pinky')} = []; attachments{names_map('palm_ring')} = []; attachments{names_map('palm_middle')} = []; attachments{names_map('palm_index')} = [];
[attachments, ~] = initialize_attachments(rest_centers, radii, blocks, rest_centers, attachments, 'my_hand', global_frame_indices, names_map, palm_centers_names);

%% Fix the palm of fist pose
copy_centers = rest_centers;
copy_centers(fingers_indices) = fist_centers(fingers_indices);
fist_centers = copy_centers;
[fist_centers, ~, ~, attachments] = update_attachments(fist_centers, blocks, fist_centers, attachments, 'my_hand', global_frame_indices, names_map, palm_centers_names);
[fist_centers, ~, ~, attachments] = update_attachments(fist_centers, blocks, fist_centers, attachments, 'my_hand', global_frame_indices, names_map, palm_centers_names);

%% Pose rest model
segments = initialize_ik_hmodel(rest_centers, names_map);

theta = zeros(num_parameters, 1);

% index
theta(12) = -63 * pi / 180; 
theta(13) =  -75 * pi / 180;
theta(14) = -57 * pi / 180;
% middle
theta(16) = -63 * pi / 180;
theta(17) = -75 * pi / 180;
theta(18) = -60 * pi / 180;
% ring
theta(20) = -61 * pi / 180;
theta(21) = -85 * pi / 180;
theta(22) = -45 * pi / 180;
% pinky
theta(24) = -71 * pi / 180;
theta(25) = -75 * pi / 180;
theta(26) = -78 * pi / 180;

[rest_centers, joints, posed_segments] = pose_ik_hmodel(theta, rest_centers, names_map, segments);
[rest_centers, ~, ~, attachments] = update_attachments(rest_centers, blocks, rest_centers, attachments, 'my_hand', global_frame_indices, names_map, palm_centers_names);
[rest_centers, ~, ~, attachments] = update_attachments(rest_centers, blocks, rest_centers, attachments, 'my_hand', global_frame_indices, names_map, palm_centers_names);

%% Display
figure; hold on; axis off; axis equal;
display_skeleton(rest_centers, radii, blocks, [], false, 'b');
display_skeleton(fist_centers, radii, blocks, [], false, 'm');
view([180, -90]); camlight; drawnow;

%% Index segment
s1 = 14; s2 = 15; s3 = 16;
j1 = 12; j2 = 11; j3 = 13; j4 = 14;
name1 = 'index_bottom'; name2 = 'index_middle'; name3 = 'index_top';
[L_index] = brute_force_initial_transformation(fist_centers, segments, joints, names_map, s1, s2, s3, j1, j2, j3, j4, name1, name2, name3);
segments{s1}.local(1:D, 1:D) = L_index;

%% Middle segment
s1 = 11; s2 = 12; s3 = 13;
j1 = 16; j2 = 15; j3 = 17; j4 = 18;
name1 = 'middle_bottom'; name2 = 'middle_middle'; name3 = 'middle_top';
[L_middle] = brute_force_initial_transformation(fist_centers, segments, joints, names_map, s1, s2, s3, j1, j2, j3, j4, name1, name2, name3);
segments{s1}.local(1:D, 1:D) = L_middle;

%% Ring segment
s1 = 8; s2 = 9; s3 = 10;
j1 = 20; j2 = 19; j3 = 21; j4 = 22;
name1 = 'ring_bottom'; name2 = 'ring_middle'; name3 = 'ring_top';
[L_ring] = brute_force_initial_transformation(fist_centers, segments, joints, names_map, s1, s2, s3, j1, j2, j3, j4, name1, name2, name3);
segments{s1}.local(1:D, 1:D) = L_ring;

%% Pinky segment
s1 = 5; s2 = 6; s3 = 7;
j1 = 24; j2 = 23; j3 = 25; j4 = 26;
name1 = 'pinky_bottom'; name2 = 'pinky_middle'; name3 = 'pinky_top';
[L_pinky] = brute_force_initial_transformation(fist_centers, segments, joints, names_map, s1, s2, s3, j1, j2, j3, j4, name1, name2, name3);
segments{s1}.local(1:D, 1:D) = L_pinky;

%% Display result
[rest_centers, joints, posed_segments] = pose_ik_hmodel(theta, rest_centers, names_map, segments);
[rest_centers, ~, ~, attachments] = update_attachments(rest_centers, blocks, rest_centers, attachments, 'my_hand', global_frame_indices, names_map, palm_centers_names);
[rest_centers, ~, ~, attachments] = update_attachments(rest_centers, blocks, rest_centers, attachments, 'my_hand', global_frame_indices, names_map, palm_centers_names);
figure; hold on; axis off; axis equal;
display_skeleton(rest_centers, radii, blocks, [], false, 'b');
display_skeleton(fist_centers, radii, blocks, [], false, 'm');
view([180, -90]); camlight; drawnow;

%% Rest pose
theta = zeros(num_parameters, 1);
theta(11) = -2 * pi / 180;
theta(15) = -2 * pi / 180;
theta(19) = 4 * pi / 180;
[rest_centers, joints, ~] = pose_ik_hmodel(theta, rest_centers, names_map, segments);
[rest_centers, ~, ~, attachments] = update_attachments(rest_centers, blocks, rest_centers, attachments, 'my_hand', global_frame_indices, names_map, palm_centers_names);
[rest_centers, ~, ~, attachments] = update_attachments(rest_centers, blocks, rest_centers, attachments, 'my_hand', global_frame_indices, names_map, palm_centers_names);
display_result(rest_centers, [], [], blocks, radii, false, 1, 'big');
view([180, -90]); camlight; drawnow;
centers = rest_centers;
save([output_path,  'theta.mat'], 'theta');
save([output_path,  'segments.mat'], 'segments');
save([output_path,  'centers.mat'], 'centers');
save([output_path,  'radii.mat'], 'radii');