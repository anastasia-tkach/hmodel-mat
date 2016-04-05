close all; clc; clear;
display = true;
D = 3;

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
blocks = reindex(radii, blocks);
%% Scale to make the alignment more stable
scaling_factor = 25;
for p = 1:num_poses
    for i = 1:length(poses{p}.centers)
        poses{p}.centers{i} = scaling_factor * poses{p}.centers{i};        
    end
end
for i = 1:length(radii)
    radii{i} = scaling_factor * radii{i};
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

%% Shift palm base to [0; 0; 0]
disp('Shifting palm_back to zero');
t = [0; 0; 0];
for i = 1:num_poses
    t = t + poses{p}.centers{names_map('palm_back')};
end
t = t/num_poses;
for p = 1:num_poses
    for i = 1:length(poses{p}.centers)
        poses{p}.centers{i} = poses{p}.centers{i} - t;
    end
end

%% Initial transformations
[phalanges, dofs] = hmodel_parameters();
for i = 1:length(phalanges)
    phalanges{i}.local = eye(4, 4);
    phalanges{i}.length = 0;
end
num_thetas = 29;
parameters1 = zeros(num_thetas, 1);
parameters2 = zeros(num_thetas, 1);
parameters3 = zeros(num_thetas, 1);
parameters4 = zeros(num_thetas, 1);
parameters5 = zeros(num_thetas, 1);

num_alpha_thetas = 5 + num_poses * 4;
lower_bound_thumb = -pi/2 * ones(num_alpha_thetas, 1);
upper_bound_thumb = pi/2 * ones(num_alpha_thetas, 1);
% lower_bound_thumb(1:3) = -0.1;
% upper_bound_thumb(1:3) = 0.1;

lower_bound_thumb(4:5) = - pi/3; upper_bound_thumb(4:5) = pi/3;

lower_bound_fingers = -pi/9 * ones(num_alpha_thetas, 1);
upper_bound_fingers = pi/2 * ones(num_alpha_thetas, 1);
lower_bound_fingers(4:5) = -pi/40;
upper_bound_fingers(4:5) = pi/40;

thumb_indices = [names_map('thumb_base'), names_map('thumb_bottom'), names_map('thumb_middle'), names_map('thumb_top')];
[M1, M2, M3, L, theta_thumb] = compute_initial_transformation(poses, thumb_indices, lower_bound_thumb, upper_bound_thumb, 'thumb');
phalanges{2}.local = M1; phalanges{3}.local = M2; phalanges{4}.local = M3;
phalanges{2}.length = L(1); phalanges{3}.length = L(2); phalanges{4}.length = L(3);

lower_bound_fingers(1:3) = -pi/4;
upper_bound_fingers(1:3) = pi/4;

index_indices = [names_map('index_base'), names_map('index_bottom'), names_map('index_middle'), names_map('index_top')];
[M1, M2, M3, L, theta_index] = compute_initial_transformation(poses, index_indices, lower_bound_fingers, upper_bound_fingers, 'index');
phalanges{14}.local = M1; phalanges{15}.local = M2; phalanges{16}.local = M3;
phalanges{14}.length = L(1); phalanges{15}.length = L(2); phalanges{16}.length = L(3);

lower_bound_fingers(1:3) = -pi/6;
upper_bound_fingers(1:3) = pi/6;

middle_indices = [names_map('middle_base'), names_map('middle_bottom'), names_map('middle_middle'), names_map('middle_top')];
[M1, M2, M3, L, theta_middle] = compute_initial_transformation(poses, middle_indices, lower_bound_fingers, upper_bound_fingers, 'middle');
phalanges{11}.local = M1; phalanges{12}.local = M2; phalanges{13}.local = M3;
phalanges{11}.length = L(1); phalanges{12}.length = L(2); phalanges{13}.length = L(3);

lower_bound_fingers(1:3) = -pi/6;
upper_bound_fingers(1:3) = pi/6;

ring_indices = [names_map('ring_base'), names_map('ring_bottom'), names_map('ring_middle'), names_map('ring_top')];
[M1, M2, M3, L, theta_ring] = compute_initial_transformation(poses, ring_indices, lower_bound_fingers, upper_bound_fingers, 'ring');
phalanges{8}.local = M1; phalanges{9}.local = M2; phalanges{10}.local = M3;
phalanges{8}.length = L(1); phalanges{9}.length = L(2); phalanges{10}.length = L(3);

lower_bound_fingers(1:3) = -pi/6;
upper_bound_fingers(1:3) = pi/6;

pinky_indices = [names_map('pinky_base'), names_map('pinky_bottom'), names_map('pinky_middle'), names_map('pinky_top')];
[M1, M2, M3, L, theta_pinky] = compute_initial_transformation(poses, pinky_indices, lower_bound_fingers, upper_bound_fingers, 'pinky');
phalanges{5}.local = M1; phalanges{6}.local = M2; phalanges{7}.local = M3;
phalanges{5}.length = L(1); phalanges{6}.length = L(2); phalanges{7}.length = L(3);

%% Set parameters
parameters1(10:13) = theta_thumb(1:4); parameters2(10:13) = theta_thumb(5:8); parameters3(10:13) = theta_thumb(9:12); parameters4(10:13) = theta_thumb(13:16); parameters5(10:13) = theta_thumb(17:20);
parameters1(14:17) = theta_index(1:4); parameters2(14:17) = theta_index(5:8); parameters3(14:17) = theta_index(9:12); parameters4(14:17) = theta_index(13:16); parameters5(14:17) = theta_index(17:20);
parameters1(18:21) = theta_middle(1:4); parameters2(18:21) = theta_middle(5:8); parameters3(18:21) = theta_middle(9:12); parameters4(18:21) = theta_middle(13:16); parameters5(18:21) = theta_middle(17:20);
parameters1(22:25) = theta_ring(1:4); parameters2(22:25) = theta_ring(5:8); parameters3(22:25) = theta_ring(9:12); parameters4(22:25) = theta_ring(13:16); parameters5(22:25) = theta_ring(17:20);
parameters1(26:29) = theta_pinky(1:4); parameters2(26:29) = theta_pinky(5:8); parameters3(26:29) = theta_pinky(9:12); parameters4(26:29) = theta_pinky(13:16); parameters5(26:29) = theta_pinky(17:20);

%% Pose
Rx = @(alpha) [1, 0, 0; 0, cos(alpha), -sin(alpha); 0, sin(alpha), cos(alpha)];
Ry = @(alpha) [cos(alpha), 0, sin(alpha); 0, 1, 0; -sin(alpha), 0, cos(alpha)];
Rz = @(alpha)[cos(alpha), -sin(alpha), 0; sin(alpha), cos(alpha), 0; 0, 0, 1];

P = {parameters1; parameters2; parameters3; parameters4; parameters5};

%% Initialize rigid centers in pose 4
pose_id = 4;

for i = 1:length(phalanges)
    phalanges{i}.init_local = phalanges{i}.local;
end

disp(P{pose_id}(10:11)');
phalanges = htrack_move(P{pose_id}, dofs, phalanges);

phalanges = initialize_offsets(poses{pose_id}.centers, phalanges, names_map);

%figure; hold on; axis off; axis equal;
%display_skeleton(poses{pose_id}.centers, radii, blocks, [], false, 'g');
%display_result(poses{pose_id}.centers, [], [], blocks(1:29), radii, false, 1, 'big');

%% Rotate model
scaling_factor = 1.43;
theta = zeros(num_thetas, 1);
theta(10) =  0.5;
theta(11) = 0.5;
theta(12) = -0.2;
theta(13) = -0.2;
theta(4) = -0.4;
theta(5) = 2.7;

f  = 1.5 / scaling_factor;
radii{names_map('thumb_additional')} = f * 4.7;
radii{names_map('thumb_top')} = f * radii{names_map('thumb_top')};
radii{names_map('thumb_middle')} = f * radii{names_map('thumb_middle')};
radii{names_map('thumb_bottom')} = f * radii{names_map('thumb_bottom')};

[centers, radii, phalanges] = rotate_and_scale_initial_transformations(poses{pose_id}.centers, radii, blocks, phalanges, dofs, theta, scaling_factor, names_map);

%% Save the final model
output_path = '_my_hand/final/';
save([output_path, 'centers.mat'], 'centers');
save([output_path, 'radii.mat'], 'radii');
save([output_path, 'phalanges.mat'], 'phalanges');
save([output_path, 'dofs.mat'], 'dofs');

display_result(centers, [], [], blocks(1:28), radii, false, 1, 'big'); view([-180, -90]); camlight;

%% Find euler angles
T1 = phalanges{11}.local(1:3, 1:3);
euler_angles = rotm2eul(T1, 'ZYX');
alpha = zeros(3, 1);
alpha(1) = euler_angles(3);
alpha(2) = euler_angles(2);
alpha(3) = euler_angles(1);
T1_test = Rz(alpha(3)) * Ry(alpha(2)) * Rx(alpha(1));
disp([euler_angles(3), euler_angles(2), euler_angles(1)]);


%% Write model to cpp
I = zeros(length(phalanges), 4 * 4);
for i = 1:length(phalanges)
    I(i, :) = phalanges{i}.local(:)';
end
I = I';
num_centers = 34;
num_blocks = 28;
RAND_MAX = 32767;
R = zeros(1, num_centers);
C = zeros(D, num_centers);
B = RAND_MAX * ones(3, num_blocks);
scaling_factor = 1;
for j = 1:num_centers
    R(j) =  radii{j};
    C(:, j) = centers{j};
end
for j = 1:num_blocks
    for k = 1:length(blocks{j})
        B(k, j) = blocks{j}(k) - 1;
    end
end

path = 'C:\Developer\hmodel-cuda-build\data\hmodel\';
write_input_parameters_to_files(path, C, R, B, I);

% path = 'C:\Developer\hmodel-cuda-build\data\';
% write_input_parameters_to_files(path, C, R, B, I);

% my_keys = keys(names_map);
% for i = 1:length(my_keys)
%     disp([my_keys{i}, ' ', num2str(names_map(my_keys{i}) - 1)]);
% end
% 
% for i = 1:num_blocks
%     disp(blocks{i} - 1);
% end