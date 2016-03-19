clc;
%close all;
clear;
theta = zeros(26, 1);
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
% palm_blocks = {[21,22,28], [28,22,26], [22,23,26], [26, 23, 25], [26, 20, 25], [23, 24, 25], [20, 25, 36], [20, 36, 19], ...
%     [30,31,21], [21,22,31], [31,32,22], [22,23,32], [32,23,24], [32,24,33]};
% fingers_blocks{5} = {[35,17], [17,18], [18,19]};

% blocks = [fingers_blocks{1}, fingers_blocks{2}, fingers_blocks{3}, fingers_blocks{4}, fingers_blocks{5}, palm_blocks];
% blocks = reindex(radii, blocks);
% figure; hold on; axis off; axis equal;
% display_skeleton(centers, radii, blocks, [], false, 'r');

%% Pose the model
segments = initialize_ik_hmodel(centers, names_map);
%theta = 0.2 * randn(26, 1);
%theta(1:6) = 0;
theta(7:end) = -pi/8;
theta(4) = pi/2;
joints = joints_parameters(zeros(26, 1));
[centers] = pose_ik_hmodel(theta, centers, names_map, segments, joints);

%% Display result
% figure; hold on; axis off; axis equal; display_skeleton(centers, radii, blocks, [], false, []);
% return
display_result(centers, [], [], blocks, radii, false, 0.8, 'big');
view([-180, -90]); camlight;
