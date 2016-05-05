user_name = 'andrii';
stage = 1;

%% Measured values
scaling_factor = 0.811646;
if strcmp(user_name, 'anastasia')
    real_membrane_offset = [18, 22, 22, 18];
    
    real_phalanges_length = cell(5, 1);
    real_phalanges_length{1} = scaling_factor * [42, 29, 15, 21];
    real_phalanges_length{2} = scaling_factor * [42, 20, 15];
    real_phalanges_length{3} = scaling_factor * [44, 24, 26];
    real_phalanges_length{4} = scaling_factor * [40, 24, 16];
    real_phalanges_length{5} = scaling_factor * [33, 18, 17];
end
if strcmp(user_name, 'andrii')
    real_membrane_offset = [18, 22, 22, 18];
    
    real_phalanges_length = cell(5, 1);
    real_phalanges_length{1} = scaling_factor * [38, 34, 15, 21];
    real_phalanges_length{2} = scaling_factor * [50, 26, 17];
    real_phalanges_length{3} = scaling_factor * [51, 31, 16];
    real_phalanges_length{4} = scaling_factor * [52, 29, 19];
    real_phalanges_length{5} = scaling_factor * [40, 19, 14];
end

data_root = 'C:/Developer/data/MATLAB/';
save([data_root, '/stage.mat'],  'stage');
save([data_root, '/user_name.mat'], 'user_name');
save([data_root, '/real_membrane_offset.mat'], 'real_membrane_offset');
save([data_root, '/real_phalanges_length.mat'], 'real_phalanges_length');

%close all;
input_path = [data_root, user_name, '/stage', num2str(stage), '/'];

semantics_path = '_my_hand/semantics/';
load([semantics_path, 'fitting/names_map.mat']);

num_poses = 4;
poses = cell(1, num_poses);
tx = 640 / 4; ty = 480 / 4; fx = 287.26; fy = 287.26;

for p = 1:num_poses
    filename = [input_path, num2str(p), '/depth.png']; D = imread(filename);
    filename = [input_path, num2str(p), '/mask.png']; M = imread(filename);
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
    
    %% Read model
    [centers, radii, blocks, theta, ~, mean_centers] = read_cpp_model([input_path,  num2str(p), '/']);
    
    %% Filter data  
    %%{
    depth_image = reshape(I, 3, ty * 2, tx * 2);
    depth_image = shiftdim(depth_image, 1);
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
    %%}
    %% Display model
    for i = 1:length(data_points)
        data_points{i} = data_points{i} - mean_centers;
    end
    data_points = data_points(1:2:end);
    
    %figure; hold on; axis off; axis equal;
    display_result(centers, [], [], blocks, radii, false, 0.9, 'big');
    mypoints(data_points,  [0.6759, 0.2088, 0.46373]);
    view([-180, -90]); camlight; drawnow;
    
    poses{p}.points = data_points;
    poses{p}.centers = centers;
    poses{p}.initial_centers = centers;
    poses{p}.theta = theta;
    poses{p}.init_theta = theta;
    poses{p}.mean_centers = mean_centers;
end
5
%% Shift together
%figure; axis off; axis equal; hold on;
for p = 1:num_poses
    for i = 1:length(poses{p}.centers)
        poses{p}.centers{i} = poses{p}.centers{i} - poses{p}.init_theta(1:3) + poses{p}.mean_centers;
    end
    for i = 1:length(poses{p}.points)
        poses{p}.points{i} = poses{p}.points{i} - poses{p}.init_theta(1:3) + poses{p}.mean_centers;
    end
    poses{p}.initial_centers =  poses{p}.centers;
    poses{p}.initial_radii = radii;
    %display_skeleton(poses{p}.centers, [], blocks, [], false, 'b');
end


%% Read inital transformations
%{
transformations_path = [input_path, '1/'];
fileID = fopen([transformations_path, 'I.txt'], 'r');
I = fscanf(fileID, '%f');
I = I(2:end);
I = reshape(I, 16, length(I)/16)';
num_phalanges = 17;
scaling_factor = 0.811646;
alpha = cell(num_phalanges, 1);
[phalanges, dofs] = hmodel_parameters();
for i = 1:size(I, 1)
    M = reshape(I(i, :), 4, 4)';
    phalanges{i}.init_local = M;
    phalanges{i}.init_local(1:3, 4) = scaling_factor * phalanges{i}.init_local(1:3, 4);
    phalanges{i}.local = phalanges{i}.init_local;
    
    M = M(1:3, 1:3);
    euler_angles = rotm2eul(M, 'ZYX');
    alpha{i} = zeros(3, 1);
    alpha{i}(1) = euler_angles(3);
    alpha{i}(2) = euler_angles(2);
    alpha{i}(3) = euler_angles(1);
end
alpha{4}(1) = 0;

%% Synchronize initial transformations
%[poses, alpha, phalanges] = synchronize_transformations(poses, radii, blocks, alpha, names_map, real_membrane_offset, true);
%}

%% Save initial rotations
num_phalanges = 17;
transformations_path = [input_path, '1/'];
fileID = fopen([transformations_path, 'I.txt'], 'r');
I = fscanf(fileID, '%f');
I = I(2:end);
I = reshape(I, 16, length(I)/16)';
initial_rotations = cell(num_phalanges + 2, 1);
for i = 1:num_phalanges
    initial_rotations{i} = reshape(I(i, :), 4, 4)';
end
initial_rotations{18} = eye(4, 4);
initial_rotations{19} = eye(4, 4);

%% Save
save([input_path, 'initial/poses.mat'], 'poses');
save([input_path, 'initial/radii.mat'], 'radii');
save([input_path, 'initial/blocks.mat'], 'blocks');
save([input_path, 'initial/initial_rotations.mat'], 'initial_rotations');
