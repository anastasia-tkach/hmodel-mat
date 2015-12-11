clear;
close all;
D = 3;
mode = 'my_hand';

%% Load htrack data
K = 171;
initialized_path = 'tracking/test4/';

num_joints = 21; num_entries = num_joints * D; num_thetas = 29;
path = 'C:/Users/tkach/Desktop/training/';
fileID = fopen('C:/Users/tkach/Desktop/training/solutions.track','r');
joint_angles = fscanf(fileID, '%f');
num_frames = joint_angles(1); joint_angles = joint_angles(2:end);
joint_angles = reshape(joint_angles, [num_thetas, num_frames]);
joint_angles = joint_angles([1:6, 10:29], :); theta = joint_angles(:, K);

%% Manual initialization
data_path = 'tracking/rectified/';
load([data_path, 'radii.mat']);
load([data_path, 'blocks.mat']); [blocks] = reindex(radii, blocks);
load([data_path, 'centers.mat']);
load([data_path, 'joints.mat']);
for i = 1:length(centers)
    centers{i} = centers{i} * 30 + joints(1:3);
    radii{i} = radii{i} * 30;
end

%% Find scaling
thumb_indices = [5, 4, 3]; pinky_indices = [9, 8, 7, 6];
ring_indices = [13, 12, 11, 10]; middle_indices = [17, 16, 15, 14];
index_indices = [21, 20, 19, 18]; base_index = 1;
htrack_indices = [pinky_indices, ring_indices, middle_indices, index_indices, thumb_indices, base_index];
hmodel_indices = [1:3, 33, 5:7, 34, 9:11, 35, 13:15, 36, 17:19, 26];
for i = 1:length(htrack_indices)
    p{i} = joints(D *(htrack_indices(i) - 1) + 1:D * htrack_indices(i));
    q{i} = centers{hmodel_indices(i)};
end
[M, scaling] = find_rigid_transformation(p, q, true);
for i = 1:length(centers)
    centers{i} = transform(centers{i}, M);
    radii{i} = radii{i} * scaling;
end

%% Display
display_result(centers, [], [], blocks(16:end-1), radii, false, 0.3);
display_skeleton(centers, radii, blocks, [], false, []);
segments = create_ik_model('hand');
[segments, joints] = pose_ik_model(segments, theta, true, 'hand');
[htrack_centers, htrack_radii, htrack_blocks, ~, ~] = make_convolution_model(segments, 'hand');
view([180, -90]); camlight; drawnow;

%% Compute principal axis of the palm
names_map_keys = {'palm_pinky', 'palm_ring', 'palm_middle', 'palm_index', 'palm_thumb', 'palm_back', 'palm_attachment', 'palm_right', 'palm_back'};
data_path = '_data/my_hand/trial1/'; compute_attachments;
points = cell(length(names_map_keys), 1);
for i = 1:length(names_map_keys)
    points{i} = centers{names_map(names_map_keys{i})};
end

[hmodel_frame, hmodel_translation] = compute_principle_axis(points, true);
[htrack_frame, htrack_translation] = compute_principle_axis(htrack_centers([21:24]), true);

hmodel_orientation = hmodel_frame(:, 2)' * (centers{names_map('thumb_bottom')} - hmodel_translation) > 0;
htrack_orientation = htrack_frame(:, 2)' * (htrack_centers{19} - htrack_translation) > 0;

if hmodel_orientation && htrack_orientation == false
    hmodel_frame(:, 2) = -hmodel_frame(:, 2);
    hmodel_frame(:, 3) = -hmodel_frame(:, 3);
end

%{
factor = 10;
myline(htrack_translation, htrack_translation + factor * htrack_frame(:, 1), 'm');
myline(htrack_translation, htrack_translation + factor * htrack_frame(:, 2), 'm');
myline(htrack_translation, htrack_translation + factor * htrack_frame(:, 3), 'm');
myline(hmodel_translation, hmodel_translation + factor * hmodel_frame(:, 1), 'm');
myline(hmodel_translation, hmodel_translation + factor * hmodel_frame(:, 2), 'm');
myline(hmodel_translation, hmodel_translation + factor * hmodel_frame(:, 3), 'm');
%}

%% Find hmodel transformation
rotation = find_svd_rotation(htrack_frame, hmodel_frame);
R = eye(D + 1, D + 1); R(1:D, 1:D) = rotation;
T1 = makehgtform('translate', -hmodel_translation);
T2 = makehgtform('translate', htrack_translation);
for i = 1:length(centers)
    centers{i} = transform(centers{i}, T2 * R * T1);
end

%% Initialize ARAP

[attachments, ~] = initialize_attachments(centers, radii, blocks, centers, attachments, mode, global_frame_indices, names_map, names_map_keys);
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

%% Create correspondences
p = cell(0, 1); q = cell(0, 1);
hmodel_indices = [1:3, 5:7, 9:11, 13:15, 17:19];
for i = 1:length(hmodel_indices)
    centers{hmodel_indices(i)} = htrack_centers{hmodel_indices(i)};
    p{i} = htrack_centers{hmodel_indices(i)};
    q{i} = centers{hmodel_indices(i)};
end
for i = 1:length(names_map_keys)
    p{end + 1} = centers{names_map(names_map_keys{i})};
    q{end + 1} = centers{names_map(names_map_keys{i})};
    hmodel_indices = [hmodel_indices, names_map(names_map_keys{i})];
end

figure; axis off; axis equal; hold on;
%segments = create_ik_model('hand'); pose_ik_model(segments, theta, true, 'hand');
display_skeleton(centers, radii, blocks, [], false, []);

%% Run ARAP
damping = 0.1; w1 = 1; w2 = 1;
I = eye(D * length(centers), D * length(centers));
%% Respore the shape
for inner_iter = 1:20
    if rem(inner_iter, 5) == 0
        a = 0.1;
        %display_shape_preservation(centers, edge_indices, restpose_edges);
    else
        a = 100;
    end
    [centers, axis_projections, ~, attachments] = update_attachments(centers, blocks, centers, attachments, mode, global_frame_indices, names_map, names_map_keys);
    %figure; axis off; axis equal; hold on; display_skeleton(centers, radii, blocks, [], false, []);
    [centers, axis_projections, ~, attachments] = update_attachments(centers, blocks, centers, attachments, mode, global_frame_indices, names_map, names_map_keys);
    
    %% Display
    figure; axis off; axis equal; hold on;
    %segments = create_ik_model('hand'); pose_ik_model(segments, theta, true, 'hand');
    display_skeleton(centers, radii, blocks, [], false, []);
    for i = 1:length(hmodel_indices), q{i} = centers{hmodel_indices(i)}; end
    for i = 1:length(attachments)
        if ~isempty(attachments{i}), myline(axis_projections{i}, centers{i}, 'g'); end
    end
    mylines(p, q, 'm');  mypoints(p, 'm'); drawnow;
    
    for i = 1:length(hmodel_indices), q{i} = centers{hmodel_indices(i)}; end
    f1 = zeros(length(p) * D, 1); J1 = zeros(length(p) * D, length(centers) * D);
    for i = 1:length(p)
        index = hmodel_indices(i);
        gradients = get_parameters_gradients(index, attachments, D);
        f1(D * i - D + 1:D * i) = (q{i} - p{i});
        for j = 1:length(gradients)
            J1(D * i - D + 1:D * i, D * gradients{j}.index - D + 1:D * gradients{j}.index) = gradients{j}.dc1;
        end
    end
    [f2, J2, previous_rotations, parents, edge_ids] = jacobian_arap_ik_rotation_attachment(centers, blocks, edge_indices, restpose_edges, solid_blocks, elastic_blocks, D, previous_rotations, attachments, parents);
    LHS = damping * I + w1 * (J1' * J1) + a * w2 * (J2' * J2); rhs = w1 * (J1' * f1) + a * w2 * (J2' * f2);  delta = -  LHS \ rhs;
    for o = 1:length(centers), centers{o} = centers{o} + delta(D * o - D + 1:D * o); end
end

%% Display data
tx = 640 / 4; ty = 480 / 4; fx = 287.26; fy = 287.26;
sensor_path = 'C:/Users/tkach/Desktop/training/';
filename = [sensor_path, sprintf('%3.7d', K-1), '.png']; D = imread(filename);
filename = [sensor_path, 'mask_', sprintf('%3.7d', K-1), '.png']; M = imread(filename);
D(M == 0) = 0;
[U, V] = meshgrid(1:size(D, 2), 1:size(D, 1));
UVD = zeros(size(D, 1), size(D, 2), 3);
UVD(:, :, 1) = U; UVD(:, :, 2) = V; UVD(:, :, 3) = D;
uvd = reshape(UVD, size(UVD, 1) * size(UVD, 2), 3)';
I = convert_uvd_to_xyz(tx, ty, fx, fy, uvd);

data_points = {};
for i = 1:size(I, 2)
    if ~any(isnan(I(:, i))), data_points{end + 1} = I(:, i); end
end

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
depth = bfilter2(depth, 5, [2 0.1]);
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

save([initialized_path, 'centers.mat'], 'centers');
save([initialized_path, 'radii.mat'], 'radii');
save([initialized_path, 'blocks.mat'], 'blocks');
save([initialized_path, 'data_points.mat'], 'data_points');
save([initialized_path, 'theta.mat'], 'theta');

