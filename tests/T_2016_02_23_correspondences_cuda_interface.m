close all;
clc;
clear;
D = 3;
debug = false;
with_outline = true;

%% Input data
input_path = '_my_hand/tracking_initialization/'; semantics_path = '_my_hand/semantics/';
load([semantics_path, 'tracking/names_map.mat']); load([semantics_path, 'tracking/named_blocks.mat']);
load([input_path, 'centers.mat']); load([input_path, 'radii.mat']);
load([semantics_path, 'tracking/blocks.mat']); [blocks] = reindex(radii, blocks);
load([semantics_path, 'palm_blocks.mat']); load([semantics_path, 'fingers_blocks.mat']);
load([semantics_path, 'fingers_base_centers.mat']); fingers_base_centers(5) = 20;

%% Pose the model
[attachments, global_frame_indices, palm_centers_names, solid_blocks, elastic_blcks, parents] = get_semantic_structures(centers, blocks, names_map, named_blocks);
[attachments, ~] = initialize_attachments(centers, radii, blocks, centers, attachments, 'hand', global_frame_indices, names_map, palm_centers_names);
segments = initialize_ik_hmodel(centers, names_map);
theta = 0.2 * randn(26, 1);
[centers, joints] = pose_ik_hmodel(theta, centers, names_map, segments);
[centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, 'hand', global_frame_indices, names_map, palm_centers_names);
[centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, 'hand', global_frame_indices, names_map, palm_centers_names);

%% Rotate model
%rotation_axis = randn(D, 1);
%rotation_angle = 1 * randn;
%R = makehgtform('axisrotate', rotation_axis, rotation_angle);
%for i = 1:length(centers)
%    centers{i} = transform(centers{i}, R);
%end

%% Topology change
palm_blocks = {[21,22,28], [28,22,26], [22,23,26], [26, 23, 25], [26, 20, 25], [23, 24, 25], [20, 25, 36], [20, 36, 19], ...
    [30,31,21], [21,22,31], [31,32,22], [22,23,32], [32,23,24], [32,24,33]};
fingers_blocks{5} = {[35,17], [17,18], [18,19]};
fingers_base_centers(5) = 19;

blocks = [fingers_blocks{1}, fingers_blocks{2}, fingers_blocks{3}, fingers_blocks{4}, fingers_blocks{5}, palm_blocks];

%% Initialization
blocks = reindex(radii, blocks);
data_points = generate_depth_data_synthetic(centers, radii, blocks);
camera_ray = [0; 0; 1];

%% Reduce data
% i = randi([1, length(data_points)], 1, 1);
% data_points = {data_points{i}};
% b = randi([16, 29], 1, 1);
% blocks = {blocks{b}};

%% Write the data to files
D = 3;
RAND_MAX = 32767;
R = zeros(1, length(radii));
C = zeros(D, length(centers));
B = RAND_MAX * ones(3, length(blocks));
P = zeros(D, length(data_points));
for j = 1:length(data_points)
    P(:, j) = data_points{j}; 
end
for j = 1:length(radii)
    R(j) = radii{j}; 
    C(:, j) = centers{j}; 
end
for j = 1:length(blocks)
    for k = 1:length(blocks{j})
        B(k, j) = blocks{j}(k) - 1;
    end   
end
path = 'C:\Developer\hmodel-cuda-build\data\';
write_input_parameters_to_files(path, C, R, B, P);

%% Read cpp output
fileID = fopen([path, 'Q.txt'], 'r');
Q = fscanf(fileID, '%f');
Q = reshape(Q, 3, length(Q)/3);
cpp_points = cell(length(data_points), 1);
for i = 1:size(Q, 2);
    if Q(1, i) ~= RAND_MAX
        cpp_points{i} = Q(:, i);
    end
end


%% Get neighbors map
C = 50;
neighbors = containers.Map('KeyType', 'uint32', 'ValueType', 'any');
% Neighbors of each center
for i = 1:length(centers)
    neighbors_list = [];
    for j = 1:length(blocks)
        if ismember(i, blocks{j})
            neighbors_list(end + 1) = j;
        end
    end
    neighbors(i) = neighbors_list;
end
% Neighbors of each edge
for i = 1:length(blocks)
    pairs = nchoosek(blocks{i}, 2);
    for j = 1:size(pairs, 1)
        indices = pairs(j, :);
        neighbors_list = [];
        for k = 1:length(blocks)
            if all(ismember(indices, blocks{k}))
                neighbors_list(end + 1) = k;
            end
        end
        neighbors(indices(1) * C + indices(2)) = neighbors_list;
    end
end

%% Get cuda neighbors map
neighbors_array = -1 * ones(length(blocks) * 6 * 6, 1);
for i = 1:length(blocks)
    count = 1;
    % neighbors of each center
    for j = 1:length(blocks{i})
        neighbors_list = [];
        n = 1;
        for k = 1:length(blocks)
            if ismember(blocks{i}(j), blocks{k})
                neighbors_array(6 * 6 * (i - 1) + 6 * (count - 1) + n) = k;
                n = n + 1;
            end
        end
        count = count + 1;
    end
    % neighbors of each edge
    pairs = nchoosek(blocks{i}, 2);
    for j = 1:size(pairs, 1)
        indices = pairs(j, :);
        n = 1;
        for k = 1:length(blocks)
            if all(ismember(indices, blocks{k}))
                neighbors_array(6 * 6 * (i - 1) + 6 * (count - 1) + n) = k;
            end
        end
        count = count + 1;
    end
end

%% Compute projections
tangent_points = blocks_tangent_points(centers, blocks, radii);

model_points = cell(length(data_points), 1);
axis_points = cell(length(data_points), 1);
model_indices = cell(length(data_points), 1);
b = cell(length(data_points), 1);
for i = 1:length(data_points)
    p = data_points{i};
    [model_points{i}, model_indices{i}, axis_points{i}, block_indices{i}, ~] = ...
        projeciton_group(p, centers, radii, blocks, tangent_points, neighbors, neighbors_array, camera_ray, false, debug);
end

%% Replace by outline if closer
if with_outline
[outline] = find_model_outline(centers, radii, blocks, palm_blocks, fingers_blocks, fingers_base_centers, camera_ray, names_map, false);
[outline_indices, outline_points] = compute_projections_outline(data_points, outline, centers, radii, camera_ray);
for i = 1:length(data_points)
    if isempty(model_points{i}), continue; end
    if norm(data_points{i} - outline_points{i}) < norm(data_points{i} - model_points{i})
        model_points{i} = outline_points{i};
        model_indices{i} = outline_indices{i};
    end
end
end

%% Display
display_result(centers, [], [], blocks, radii, false, 0.6, 'big');
data_color = [0, 1, 1];
model_color = 'm';
%mypoints(outline_points, 'm');
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
view([-180, -90]); camlight;

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
mypoints(inside_points, 'b');

%% Compare matlab and cpp
for i = 1:length(model_points)
    
    if isempty(cpp_points{i})
        if all(~isinf(model_points{i}))
            disp('different nan');
        end
    else
        if (norm(model_points{i} - cpp_points{i})) > 1e-3
            mypoint(cpp_points{i}, 'k');
            disp([model_points{i}'; cpp_points{i}']);
            disp('different');
        end
    end
end



