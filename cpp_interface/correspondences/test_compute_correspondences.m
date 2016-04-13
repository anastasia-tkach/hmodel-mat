clc; clear; close all;
RAND_MAX = 32767;
with_outline = true;
path = 'C:\Developer\hmodel-cuda-build\data\';

%% Semantics
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


%% Initialization
blocks = reindex(radii, blocks);
data_points = generate_depth_data_synthetic(centers, radii, blocks);
camera_ray = [0; 0; 1];

%% Reduce data
% i = randi([1, length(data_points)], 1, 1);
% data_points = {data_points{i}};
% b = randi([16, 29], 1, 1);
% blocks = {blocks{b}};

%% Compute projections
tangent_points = blocks_tangent_points(centers, blocks, radii);

model_points = cell(length(data_points), 1);
axis_points = cell(length(data_points), 1);
model_indices = cell(length(data_points), 1);
b = cell(length(data_points), 1);
for i = 1:length(data_points)
    p = data_points{i};
    [model_points{i}, model_indices{i}, axis_points{i}, block_indices{i}, ~] = ...
        projeciton_group(p, centers, radii, blocks, tangent_points, [], [], camera_ray, false, false);
end

%% Replace by outline if closer
if with_outline
    [outline] = find_model_outline(centers, radii, blocks, palm_blocks, fingers_blocks, camera_ray, names_map, false, true);
    [outline_indices, outline_points, outline_blocks_indices, outline_axis_points] = compute_projections_outline(data_points, outline, centers, radii, camera_ray);
    for i = 1:length(data_points)
        if isempty(model_points{i}), continue; end
        if norm(data_points{i} - outline_points{i}) < norm(data_points{i} - model_points{i})
            model_points{i} = outline_points{i};
            model_indices{i} = outline_indices{i};
            block_indices{i} = outline_blocks_indices{i};
            axis_points{i} = outline_axis_points{i};
        end
    end
end

%% Display
display_result(centers, [], [], blocks, radii, false, 0.6, 'big');
view([-180, -90]); camlight;
data_color = [0, 1, 1];
model_color = 'm';
mypoints(data_points, data_color);
mypoints(model_points, model_color);
mylines(data_points, model_points, [0.6, 0.6, 0.6]);
if with_outline
    for i = 1:length(outline)
        if length(outline{i}.indices) == 2
            myline(outline{i}.start, outline{i}.end, 'y');
        else
            draw_circle_sector_in_plane(centers{outline{i}.indices}, radii{outline{i}.indices}, camera_ray, outline{i}.start, outline{i}.end, 'y');
        end
    end
end

%% Check if inside
tangent_points = blocks_tangent_points(centers, blocks, radii);
inside_points = cell(length(model_points), 1);
for i = 1:length(model_points)
    if isempty(model_points{i}), continue; end
    p = model_points{i};
    for j = 1:length(blocks)
        [index, q, s, is_inside] = projection(p, blocks{j}, radii, centers, tangent_points{j});
        if is_inside
            if abs((norm(p - s) - norm(q - s))) > 1
                inside_points{i} = p;
                disp('inside');
            end
        end
    end
end
mypoints(inside_points, 'g');


