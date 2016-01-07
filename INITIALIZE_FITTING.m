close all; clear;
data_path = '_data/my_hand/initialized/';
pose_id = 2;
pose2;
skeleton8;


%% Build the data structures
for i = 1:length(named_blocks)
    blocks{i} = [];
    for j = 1:length(named_blocks{i})
        key = named_blocks{i}(j);
        blocks{i} = [blocks{i}, names_map(key{1})];
    end
end
for i = 1:length(names_map_keys)
    key = names_map_keys{i}; 
    centers{i} = centers_map(key);
    radii{i} = radii_map(key) + randn * 5e-3;
end

%% Describe solid blocks
named_solid_blocks_indices = {};
% named_solid_blocks_indices{end + 1} = {
%     {'wrist_top_left', 'wrist_bottom_left', 'wrist_top_right'}, ...
%     {'wrist_bottom_left', 'wrist_top_right', 'wrist_bottom_right'}, ...
%     {'wrist_top_left', 'wrist_top_right', 'palm_back'}};
% named_solid_blocks_indices{end + 1} = {{'ring_membrane', 'middle_membrane', 'palm_ring'}, ...
%    {'palm_ring', 'palm_middle', 'middle_membrane'}};
named_solid_blocks_indices{end + 1} = {
    {'middle_base', 'palm_attachment'}, ...
    {'ring_base', 'palm_attachment'}, ...
    ... % {'palm_middle', 'palm_thumb', 'palm_back'}, ...
    ... % {'palm_thumb', 'thumb_base', 'palm_back'}, ...
	{'palm_middle', 'thumb_base', 'palm_back'}, ...
	{'palm_middle', 'palm_index', 'thumb_base'}, ...
    {'palm_right', 'palm_ring', 'palm_back'}, ...
    {'palm_ring', 'palm_middle', 'palm_back'}};

solid_blocks_indices = cell(length(named_solid_blocks_indices), 1);
solid_indicator = zeros(length(blocks), 1);
for i = 1:length(named_solid_blocks_indices)
    solid_blocks_indices{i} = [];
    for j = 1:length(named_solid_blocks_indices{i})
        current_name = sort(named_solid_blocks_indices{i}{j});
        
        for index = 1:length(named_blocks)
            block_name = sort(named_blocks{index});
            if length(current_name) ~= length(block_name), continue; end
            is_equal = true;
            for k = 1:length(current_name)
                if ~strcmp(current_name{k}, block_name{k}), is_equal = false; end
            end
            if is_equal == true
                solid_blocks_indices{i} = [solid_blocks_indices{i}, index];
                solid_indicator(index) = 1;
                break;
            end
            
        end
        
    end
end


%% Describe elastic blocks
named_elastic_blocks = {};
named_elastic_blocks{end + 1} = {'pinky_membrane', 'ring_membrane', 'palm_pinky'};
named_elastic_blocks{end + 1} = {'palm_pinky', 'palm_ring', 'ring_membrane'};
named_elastic_blocks{end + 1} = {'ring_membrane', 'middle_membrane', 'palm_ring'};
named_elastic_blocks{end + 1} = {'palm_ring', 'palm_middle', 'middle_membrane'};
named_elastic_blocks{end + 1} = {'middle_membrane', 'palm_middle', 'palm_index'};
named_elastic_blocks{end + 1} = {'middle_membrane', 'palm_index', 'index_membrane'};
named_elastic_blocks{end + 1} = {'thumb_membrane', 'palm_thumb', 'thumb_base'};
named_elastic_blocks{end + 1} = {'wrist_top_left', 'wrist_bottom_left', 'wrist_top_right'};
named_elastic_blocks{end + 1} = {'wrist_bottom_left', 'wrist_top_right', 'wrist_bottom_right'};

for i = 1:length(named_elastic_blocks)
    
    current_name = sort(named_elastic_blocks{i});
    
    for index = 1:length(named_blocks)
        block_name = sort(named_blocks{index});
        if length(current_name) ~= length(block_name), continue; end
        is_equal = true;
        for k = 1:length(current_name)
            if ~strcmp(current_name{k}, block_name{k}), is_equal = false; end
        end
        if is_equal == true            
            solid_indicator(index) = -1;
            break;
        end        
    end    
end

%% Get final solid blocks
single_solid_blocks_indices = {};
for i = 1:length(solid_indicator)
    if solid_indicator(i) == 0
        single_solid_blocks_indices = [single_solid_blocks_indices, {i}];
    end
end
solid_blocks_indices = [single_solid_blocks_indices'; solid_blocks_indices];

%% Get points and normals
filename = ['_data/my_hand/', num2str(pose_id)', '.obj'];
[V, F] = readOBJ(filename);
N = per_vertex_normals(V, F);
for i = 1:size(V, 1)
    points{i} = V(i, :)';
    normals{i} = N(i, :)';
end

%% Display
figure; axis off; axis equal; hold on;
display_skeleton(centers, radii, blocks, [], false, []);
% for i = [4, 8, 12, 16, 17:length(centers)]
%     draw_sphere(centers{i}, radii{i}, 'c');
% end
mypoints(points, [0.65, 0.1, 0.5]);

%% Save the results
save([data_path, num2str(pose_id), '_points.mat'], 'points');
save([data_path, num2str(pose_id), '_centers.mat'], 'centers');
save([data_path, num2str(pose_id), '_normals.mat'], 'normals');
save([data_path, num2str(pose_id), '_radii.mat'], 'radii');
blocks = blocks';
save([data_path, 'blocks.mat'], 'blocks');
save([data_path, 'solid_blocks_indices.mat'], 'solid_blocks_indices');
save([data_path, 'names_map.mat'], 'names_map');
save([data_path, 'named_blocks.mat'], 'named_blocks');

