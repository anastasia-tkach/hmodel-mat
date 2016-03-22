clc;
%close all;
%clear;

%% Load previous model
input_path = '_my_hand/tracking_initialization/';
semantics_path = '_my_hand/semantics/';
load([input_path, 'centers.mat']);
load([input_path, 'radii.mat']);
load([semantics_path, 'tracking/blocks.mat']);
[blocks] = reindex(radii, blocks);
load([semantics_path, 'fingers_blocks.mat']);
load([semantics_path, 'tracking/names_map.mat']);

%% Topology change
palm_blocks = {[21,22,28], [28,22,26], [22,23,26], [26, 23, 25], [26, 20, 25], [23, 24, 25], [20, 25, 36], [20, 36, 19], ...
    [30,31,21], [21,22,31], [31,32,22], [22,23,32], [32,23,24], [32,24,33]};
fingers_blocks{5} = {[35,17], [17,18], [18,19]};
blocks = [fingers_blocks{1}, fingers_blocks{2}, fingers_blocks{3}, fingers_blocks{4}, fingers_blocks{5}, palm_blocks];
blocks = reindex(radii, blocks);
%print_blocks_names(blocks, names_map);

%% Adjust the model
D = 3;
scaling_factor = 1;
for i = 1:length(centers)
    centers{i} = scaling_factor * centers{i};
    radii{i} = scaling_factor * radii{i};
end
centers{names_map('thumb_fold')} = centers{names_map('thumb_fold')} + [-7; 2; 0];
centers{names_map('middle_membrane')} = centers{names_map('middle_membrane')} + [0; -3; 2];
centers{names_map('index_membrane')} = centers{names_map('index_membrane')} + [0; 0; -2];
radii{names_map('thumb_top')} = 0.9 * radii{names_map('thumb_top')};

%% Initial transformations to matrix form
segments = initialize_ik_hmodel(centers, names_map);
I = zeros(length(segments), 4 * 4);
for i = 1:length(segments)
    I(i, :) = segments{i}.local(:)';
end
I = I';

%% Model to matrix form
num_centers = 36;
RAND_MAX = 32767;
R = zeros(1, num_centers);
C = zeros(D, num_centers);
B = RAND_MAX * ones(3, length(blocks));
scaling_factor = 1;
for j = 1:num_centers
    R(j) =  radii{j};
    C(:, j) = centers{j};
end
for j = 1:length(blocks)
    for k = 1:length(blocks{j})
        B(k, j) = blocks{j}(k) - 1;
    end
end

display_result(centers, [], [], blocks, radii, false, 1, 'none');

%% Write the matrices
path = 'C:\Developer\hmodel-cuda-build\data\';
write_input_parameters_to_files(path, C, R, B, I);
