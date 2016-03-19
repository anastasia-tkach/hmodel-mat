clear; close all;

D = 3;
semantics_path = '_my_hand/semantics/';
model_path = '_my_hand/fitting_result/';
data_path = '_my_hand/fitting_initialization/';

%% Load data
load([model_path, 'radii.mat']);
load([model_path, 'centers.mat']);

load([semantics_path, 'fitting/blocks.mat']);
load([semantics_path, 'fitting/names_map.mat']);
load([semantics_path, 'fitting/named_blocks.mat']);
load([semantics_path, 'palm_blocks.mat']);
load([semantics_path, 'fingers_blocks.mat']);

load([data_path, num2str(4), '_points.mat']);
data_points = points;

%% Topology change
palm_blocks = {[21,22,28], [28,22,26], [22,23,26], [26, 23, 25], [26, 20, 25], [23, 24, 25], [20, 25, 36], [20, 36, 19], ...
    [30,31,21], [21,22,31], [31,32,22], [22,23,32], [32,23,24], [32,24,33]};
fingers_blocks{5} = {[35,17], [17,18], [18,19]};

blocks = [fingers_blocks{1}, fingers_blocks{2}, fingers_blocks{3}, fingers_blocks{4}, fingers_blocks{5}, palm_blocks];
blocks = reindex(radii, blocks);

%% Projections
[model_indices, model_points, block_indices] = compute_projections(data_points, centers, blocks, radii);
%display_result(centers, data_points, model_points, blocks, radii, true, 0.8, 'big'); view([0, 90]);

%% Display mesh
% pose_id = 4;
% filename = [data_path, num2str(pose_id)', '.obj'];
% options.face_color = [0, 0.5, 0.5];
% [V, F] = readOBJ(filename);
% figure; plot_mesh(V, F, options);

%% Block - segment map
block_phalange_map = containers.Map('KeyType', 'uint32', 'ValueType', 'uint32');
block_phalange_map(0)= 6; % pinky_middle, pinky_top
block_phalange_map(1) = 5; % pinky_bottom, pinky_middle
block_phalange_map(2) =  4; % pinky_base, pinky_bottom
block_phalange_map(3) =  9; % ring_top, ring_middle
block_phalange_map(4) =  8; % ring_bottom, ring_middle
block_phalange_map(5) =  7; % ring_bottom, ring_base
block_phalange_map(6) =  12; % middle_top, middle_middle
block_phalange_map(7) =  11; % middle_bottom, middle_middle
block_phalange_map(8) =  10; % middle_bottom, middle_base
block_phalange_map(9) =  15; % index_middle, index_top
block_phalange_map(10) =  14; % index_bottom, index_middle
block_phalange_map(11) =  13; % index_base, index_bottom
block_phalange_map(12) =  3; % thumb_top, thumb_additional
block_phalange_map(13) =  3; % thumb_top, thumb_middle
block_phalange_map(14) =  2; % thumb_bottom, thumb_middle
block_phalange_map(22) =  1; % thumb_base, thumb_bottom, thumb_fold

block_phalange_map(15) = 0; % palm_right, palm_ring, palm_pinky
block_phalange_map(16) = 0; % palm_back, palm_right, palm_ring
block_phalange_map(17) = 0; % palm_back, palm_ring, palm_middle
block_phalange_map(18) = 0; % palm_back, palm_middle, palm_thumb
block_phalange_map(19) = 0; % palm_back, thumb_base, palm_thumb
block_phalange_map(20) = 0; % palm_middle, palm_index, palm_thumb
block_phalange_map(21) = 0; % thumb_base, thumb_fold, palm_thumb

block_phalange_map(23) = 7; % palm_pinky, ring_membrane, pinky_membrane
block_phalange_map(24) = 7; % palm_ring, palm_pinky, ring_membrane
block_phalange_map(25) = 10; % palm_ring, middle_membrane, ring_membrane
block_phalange_map(26) = 10; % palm_ring, palm_middle, middle_membrane
block_phalange_map(27) = 10; % palm_middle, palm_index, middle_membrane
block_phalange_map(28) = 10; % palm_index, middle_membrane, index_membrane

my_keys = keys(block_phalange_map);
my_values = values(block_phalange_map);
for i = 1:length(my_keys)
    my_keys{i} = my_keys{i} + 1;
    my_values{i} = my_values{i} + 1;
end
block_phalange_map = containers.Map(my_keys, my_values);

%% Initialize offsets
segments = initialize_ik_hmodel(centers, names_map);
offsets = cell(length(data_points), 1);
for i = 1:length(data_points)  
   s = block_phalange_map(block_indices{i});
   offsets{i} =  segments{s}.global(1:D, 1:D)' * (data_points{i} -  centers{names_map(segments{s}.name)});    
end

%% Pose the model

%theta = 0.2 * randn(26, 1);
theta = zeros(26, 1);
theta(12) = pi/6;
theta(13) = pi/6;
theta(16) = pi/6;
theta(17) = pi/6;
theta(20) = pi/6;
theta(21) = pi/6;
joints = joints_parameters(zeros(26, 1));
[centers, segments] = pose_ik_hmodel(theta, centers, names_map, segments, joints);
display_result(centers, data_points, model_points, blocks, radii, false, 0.8, 'big');
%mypoints(data_points, 'm');


%% Pose points
for i = 1:length(data_points)         
    s = block_phalange_map(block_indices{i});
    T = segments{s}.global(1:D, 1:D) * offsets{i};
    data_points{i} = centers{names_map(segments{s}.name)} + T;
end

mypoints(data_points, 'm');
V = zeros(length(data_points), D);
for i = 1:length(data_points)
    V(i, :) = data_points{i}';
end
%% Display mesh
pose_id = 4;
filename = [data_path, num2str(pose_id)', '.obj'];
options.face_color = [0, 0.8, 0.8];
[~, F] = readOBJ(filename);
figure; plot_mesh(V, F, options); hold on;
mypoints(data_points, 'k');
writeOBJ('C:\Users\tkach\Desktop\trail.obj', V, F);