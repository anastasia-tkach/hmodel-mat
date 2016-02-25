
debug = false;
topology_change = true;

if ~debug
    %close all;
    clc;
    %clear;
    D = 3;
    
    %% Input data
    input_path = '_my_hand/tracking_initialization/'; semantics_path = '_my_hand/semantics/';
    load([semantics_path, 'tracking/names_map.mat']); load([semantics_path, 'tracking/named_blocks.mat']);
    load([input_path, 'centers.mat']); load([input_path, 'radii.mat']);
    load([semantics_path, 'tracking/blocks.mat']); [blocks] = reindex(radii, blocks);
    load([semantics_path, 'palm_blocks.mat']); load([semantics_path, 'fingers_blocks.mat']);
    load([semantics_path, 'fingers_base_centers.mat']); fingers_base_centers(5) = 20;
    %palm_blocks = [palm_blocks, fingers_blocks{5}([4, 5, 6, 7])];
    
    %% Pose the model
    [attachments, global_frame_indices, palm_centers_names, solid_blocks, elastic_blcks, parents] = get_semantic_structures(centers, blocks, names_map, named_blocks);
    [attachments, ~] = initialize_attachments(centers, radii, blocks, centers, attachments, 'hand', global_frame_indices, names_map, palm_centers_names);
    segments = initialize_ik_hmodel(centers, names_map);
    theta = 0 * randn(26, 1);
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
    if topology_change
        palm_blocks = {[21,22,28], [28,22,26], [22,23,26], [26, 23, 25], [26, 20, 25], [23, 24, 25], [20, 25, 36], [20, 36, 19], ...
            [30,31,21], [21,22,31], [31,32,22], [22,23,32], [32,23,24], [32,24,33]};
        fingers_blocks{5} = {[35,17], [17,18], [18,19]};
        fingers_base_centers(5) = 19;
        
    end
    blocks = [fingers_blocks{1}, fingers_blocks{2}, fingers_blocks{3}, fingers_blocks{4}, fingers_blocks{5}, palm_blocks];
    
    %% Initialization
    blocks = reindex(radii, blocks);    
    data_points = generate_depth_data_synthetic(centers, radii, blocks);
    camera_ray = [0; 0; 1];    
    initial_blocks = blocks;
    init_data_points = data_points;
    verbose = false;
end

if debug
    for i = 10:length(inside_points)
        if ~isempty(inside_points{i})
            data_points = {data_points{i}};
            break;
        end
    end;
    verbose = true;
    blocks = palm_blocks(4:5);
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

tangent_points = blocks_tangent_points(centers, blocks, radii);
tic
model_points = cell(length(data_points), 1);
axis_points = cell(length(data_points), 1);
model_indices = cell(length(data_points), 1);
discarded_points = cell(length(data_points), 1);
for i = 1:length(data_points)
    p = data_points{i};
    [model_points{i}, model_indices{i}, axis_points{i}, ~] = projeciton_group(p, centers, radii, blocks, tangent_points, neighbors, camera_ray, debug);
end
disp(toc)

%% Replace by outline if closer
palm_blocks = [palm_blocks, fingers_blocks{1}{3}, fingers_blocks{2}{3}, fingers_blocks{3}{3}, fingers_blocks{4}{3}];
fingers_blocks{1} = fingers_blocks{1}(1:2); fingers_blocks{2} = fingers_blocks{2}(1:2);
fingers_blocks{3} = fingers_blocks{3}(1:2); fingers_blocks{4} = fingers_blocks{4}(1:2);
fingers_base_centers(1) = 3; fingers_base_centers(2) = 7; fingers_base_centers(3) = 11;
fingers_base_centers(4) = 15; fingers_base_centers(5) = 19;
[outline] = find_model_outline(centers, radii, blocks, palm_blocks, fingers_blocks, fingers_base_centers, camera_ray, names_map, false);
[outline_indices, outline_points] = compute_projections_outline(data_points, outline, centers, radii, camera_ray);
for i = 1:length(data_points)
    if isempty(model_points{i}), continue; end
    if norm(data_points{i} - outline_points{i}) < norm(data_points{i} - model_points{i})
        model_points{i} = outline_points{i};
        model_indices{i} = outline_indices{i};
    end
end

%% Display
display_result(centers, data_points, model_points, blocks, radii, false, 0.6, 'big');
%display_skeleton(centers, radii, blocks, [], false, []); view([-180, -90]); camlight; return;
data_color = [0, 1, 1];
model_color = 'm';
mypoints(data_points, data_color);
mypoints(model_points, model_color);
mylines(data_points, model_points, [0.6, 0.6, 0.6]);
mypoints(discarded_points, 'k');
for i = 1:length(outline)
    if length(outline{i}.indices) == 2
        myline(outline{i}.start, outline{i}.end, 'y');
    else
        draw_circle_sector_in_plane(centers{outline{i}.indices}, radii{outline{i}.indices}, camera_ray, outline{i}.start, outline{i}.end, 'y');
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

%% Brute-force projections
% [brute_force_points] = compute_brute_force_projections(centers, radii, blocks, data_points);
% mypoints(brute_force_points, 'y');
% mylines(brute_force_points, data_points, 'r')
