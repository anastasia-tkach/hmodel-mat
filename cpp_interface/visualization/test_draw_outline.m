clc; clear; close all;
RAND_MAX = 32767;
camera_ray = [0; 0; 1];
path = 'C:\Developer\hmodel-cuda-build\data\';

%% Read centers
fileID = fopen([path, '_C.txt'], 'r');
C = fscanf(fileID, '%f');
C = C(2:end);
C = reshape(C, 3, length(C)/3);
centers = cell(0, 1);
mean_centers = [0; 0; 0];
for i = 1:size(C, 2);
    centers{end + 1} = C(:, i);
    mean_centers = mean_centers + centers{end};
end
mean_centers = mean_centers ./ length(centers);
for i = 1:length(centers)
    centers{i} = centers{i} - mean_centers;
end
%% Read radii
fileID = fopen([path, '_R.txt'], 'r');
R = fscanf(fileID, '%f');
R = R(2:end);
radii = cell(0, 1);
for i = 1:length(R);
    radii{end + 1} = R(i);
end
%% Read blocks
fileID = fopen([path, '_B.txt'], 'r');
B = fscanf(fileID, '%f');
B = B(2:end);
B = reshape(B, 3, length(B)/3);
blocks = cell(0, 1);
for i = 1:size(B, 2);
    if B(3, i) == RAND_MAX
        blocks{end + 1} = B(1:2, i) + 1;
    else
        blocks{end + 1} = B(:, i) + 1;
    end
end
blocks = reindex(radii, blocks);

%% Read semantics
input_path = '_my_hand/final/';
semantics_path = '_my_hand/semantics/';
load([semantics_path, 'fitting/names_map.mat']);
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

display_result(centers, [], [], blocks, radii, false, 1, 'big');
view([-180, -90]);

%% Find outline
[final_outline] = find_model_outline(centers, radii, blocks, palm_blocks, fingers_blocks, camera_ray, names_map, true, true);


