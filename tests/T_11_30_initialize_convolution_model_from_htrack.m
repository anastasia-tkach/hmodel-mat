close all; clear;
D = 3;
K = 95;
num_joints = 21;
num_entries = num_joints * D;
num_thetas = 29;
path = 'C:/Users/tkach/Desktop/training/';

data_path = '_data/my_hand/model/';
load([data_path, 'radii.mat']);
load([data_path, 'blocks.mat']); [blocks] = reindex(radii, blocks);
load([data_path, 'centers.mat']);

%% Read joint locations
fileID = fopen('C:/Users/tkach/Desktop/training/joint_locations.txt','r');
joint_locations = fscanf(fileID, '%f');
num_frames = joint_locations(1); joint_locations = joint_locations(2:end);
joint_locations = reshape(joint_locations, [num_entries, num_frames]);

%% Read joint angles
fileID = fopen('C:/Users/tkach/Desktop/training/solutions.track','r');
joint_angles = fscanf(fileID, '%f');
num_frames = joint_angles(1); joint_angles = joint_angles(2:end);
joint_angles = reshape(joint_angles, [num_thetas, num_frames]);
joint_angles = joint_angles([1:6, 10:29], :);

%% Show in XYZ
figure; axis off; axis equal; hold on;
theta = joint_angles(:, K);
segments = create_ik_model('hand');
[segments, joints] = pose_ik_model(segments, theta, true, 'hand');
scatter3(joint_locations(1:3:end, K), joint_locations(2:3:end, K), joint_locations(3:3:end, K), 50, 'm', 'filled');

%% Manual initialization
shift = joint_locations(1:3, K);
for i = 1:length(centers)
    centers{i} = centers{i} * 30 + shift;
    radii{i} = radii{i} * 30;
end
data_path = '_data/my_hand/trial1/';
compute_attachments;

%% Create correspondences
thumb_indices = [5, 4, 3]; pinky_indices = [9, 8, 7, 6];
ring_indices = [13, 12, 11, 10]; middle_indices = [17, 16, 15, 14];
index_indices = [21, 20, 19, 18]; base_index = 1;
htrack_indices = [pinky_indices, ring_indices, middle_indices, index_indices, thumb_indices, base_index];
hmodel_indices = [1:3, 33, 5:7, 34, 9:11, 35, 13:15, 36, 17:19, 26];

tracking_path = 'C:\Users\tkach\OneDrive\EPFL\Code\HModel\tracking\';
load([tracking_path, 'centers.mat']);
load([tracking_path, 'radii.mat']);
for i = 1:length(htrack_indices)
    p{i} = joint_locations(D *(htrack_indices(i) - 1) + 1:D * htrack_indices(i), K);
    q{i} = centers{hmodel_indices(i)};
end

%% Find scaling
% [M, scaling] = find_rigid_transformation(p, q, true);
% for i = 1:length(centers)
%     centers{i} = transform(centers{i}, M);
%     radii{i} = radii{i} * scaling;
% end
% tracking_path = 'tracking/scaling/';
% save([tracking_path, 'centers.mat'], 'centers');
% save([tracking_path, 'radii.mat'], 'radii');
% save([tracking_path, 'blocks.mat'], 'blocks');
% save([tracking_path, 'theta.mat'], 'theta');

%% Find rigid transformation
[M, scaling] = find_rigid_transformation(p, q, false);
for i = 1:length(centers)
    centers{i} = transform(centers{i}, M);
    radii{i} = radii{i} * scaling;
end
display_skeleton(centers, radii, blocks, [], false);

%% Find non-rigid transformation

damping = 0.1; w1 = 1; w2 = 10;
[attachments, ~] = initialize_attachments(centers, radii, blocks, centers, attachments, global_frame_indices);
restpose_edges = cell(length(blocks), 1);
k = 1;
for i = 1:length(blocks)
    index = nchoosek(blocks{i}, 2);
    for j = 1:size(index, 1)
        edge_indices{i}{j} = [index(j, :)];
        restpose_edges{k} = centers{edge_indices{i}{j}(2)} - centers{edge_indices{i}{j}(1)};
        previous_rotations{k} = eye(3, 3);
        k = k + 1;
    end
end
I = eye(D * length(centers), D * length(centers));
for iter = 1:50
    [blocks] = reindex(radii, blocks);
    
    %% Display
    figure; axis off; axis equal; hold on;
    segments = create_ik_model('hand');
    [segments, joints] = pose_ik_model(segments, joint_angles(:, K), true, 'hand');
    mypoints(p, 'm');
    display_skeleton(centers, radii, blocks, [], false);
    for i = 1:length(htrack_indices), q{i} = centers{hmodel_indices(i)}; end
    mylines(p, q, 'm');
    
    %% Solve with gradients
    for i = 1:length(htrack_indices), q{i} = centers{hmodel_indices(i)}; end
    f1 = zeros(length(p) * D, 1); J1 = zeros(length(p) * D, length(centers) * D);
    for i = 1:length(p)
        index = hmodel_indices(i);
        gradients = get_parameters_gradients(index, attachments, D);
        f1(D * i - D + 1:D * i) = (q{i} - p{i});
        for j = 1:length(gradients)
            J1(D * i - D + 1:D * i, D * gradients{j}.index - D + 1:D * gradients{j}.index) = gradients{j}.dc1;
        end
    end
    
    [f2, J2, previous_rotations, parents, edge_ids] = jacobian_arap_ik_rotation_attachment(centers, blocks, edge_indices, restpose_edges, solid_blocks, D, previous_rotations, attachments, parents);
    LHS = damping * I + w1 * (J1' * J1) + w2 * (J2' * J2); rhs = w1 * (J1' * f1) + w2 * (J2' * f2); delta = -  LHS \ rhs;
    for o = 1:length(centers), centers{o} = centers{o} + delta(D * o - D + 1:D * o); end
    [centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, global_frame_indices);
    [centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, global_frame_indices);
    energies(1) = w1 * (f1' * f1); energies(2) = w2 * (f2' * f2); disp(energies);
    
    %% Respore the shape
    for inner_iter = 1:5
        for i = 1:length(htrack_indices), q{i} = centers{hmodel_indices(i)}; end
        f1 = zeros(length(p) * D, 1); J1 = zeros(length(p) * D, length(centers) * D);
        for i = 1:length(p)
            index = hmodel_indices(i);
            gradients = get_parameters_gradients(index, attachments, D);
            f1(D * i - D + 1:D * i) = (q{i} - p{i});
            for j = 1:length(gradients)
                J1(D * i - D + 1:D * i, D * gradients{j}.index - D + 1:D * gradients{j}.index) = gradients{j}.dc1;
            end
        end
        [f2, J2, previous_rotations, parents, edge_ids] = jacobian_arap_ik_rotation_attachment(centers, blocks, edge_indices, restpose_edges, solid_blocks, D, previous_rotations, attachments, parents);
        LHS = damping * I + w1 * (J1' * J1) + 100 * w2 * (J2' * J2); rhs = w1 * (J1' * f1) + 100 * w2 * (J2' * f2);  delta = -  LHS \ rhs;
        for o = 1:length(centers), centers{o} = centers{o} + delta(D * o - D + 1:D * o); end
        [centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, global_frame_indices);
        [centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, global_frame_indices);
        
        %if inner_iter == 4, display_shape_preservation(centers, edge_indices, restpose_edges); end
    end
end

%% Display data
tx = 640 / 4;
ty = 480 / 4;
fx = 287.26;
fy = 287.26;
sensor_path = 'C:/Users/tkach/Desktop/training/';
filename = [sensor_path, sprintf('%3.7d', K-1), '.png'];
D = imread(filename);
filename = [sensor_path, 'mask_', sprintf('%3.7d', K-1), '.png'];
M = imread(filename);
D(M == 0) = 0;
[U, V] = meshgrid(1:size(D, 2), 1:size(D, 1));
UVD = zeros(size(D, 1), size(D, 2), 3);
UVD(:, :, 1) = U;
UVD(:, :, 2) = V;
UVD(:, :, 3) = D;
uvd = reshape(UVD, size(UVD, 1) * size(UVD, 2), 3)';
I = convert_uvd_to_xyz(tx, ty, fx, fy, uvd);

scatter3(I(1, :), I(2, :), I(3, :), 10, [0, 0.8, 0.9], 'filled');

data_points = {};
for i = 1:size(I, 2)
    if ~any(isnan(I(:, i)))
        data_points{end + 1} = I(:, i);
    end
end
mypoints(data_points, 'r');

%% Filter datapoints
figure; axis off; axis equal; hold on;
mypoints(data_points, 'r');
gaussian_filter = fspecial('gaussian', 3, 1);
depth_image = reshape(I, 3, ty * 2, tx * 2);
depth_image = shiftdim(depth_image, 1);
mask = zeros(ty * 2, tx * 2);
mask(depth_image(:, :, 3) > 0) = 1;
depth = depth_image(:, :, 3);
max_depth = max(depth(:));
depth = depth ./ max_depth;
depth = bfilter2(depth, 5, [5 0.1]);
depth = depth .* max_depth;
depth_image(:, :, 3) = depth;
depth_image = shiftdim(depth_image, 2);
I2 = reshape(depth_image, 3, ty * 2 * tx * 2);

data_points = {};
for i = 1:size(I2, 2)
    if ~any(isnan(I2(:, i)))
        data_points{end + 1} = I2(:, i);
    end
end
mypoints(data_points, 'b');
%% Save the data
initialized_path = 'tracking/test2/';
save([initialized_path, 'centers.mat'], 'centers');
save([initialized_path, 'radii.mat'], 'radii');
save([initialized_path, 'blocks.mat'], 'blocks');
save([initialized_path, 'data_points.mat'], 'data_points');
save([initialized_path, 'theta.mat'], 'theta');
