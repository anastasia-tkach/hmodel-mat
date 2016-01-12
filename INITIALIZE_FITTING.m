close all; clear;
data_path = '_data/my_hand/initialized/';
pose_id = 5;
pose5;
skeleton9;


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

%% Solid blocks
named_solid_blocks = {};
% named_solid_blocks_indices{end + 1} = {
%     {'wrist_top_left', 'wrist_bottom_left', 'wrist_top_right'}, ...
%     {'wrist_bottom_left', 'wrist_top_right', 'wrist_bottom_right'}, ...
%     {'wrist_top_left', 'wrist_top_right', 'palm_back'}};
% named_solid_blocks_indices{end + 1} = {{'ring_membrane', 'middle_membrane', 'palm_ring'}, ...
%    {'palm_ring', 'palm_middle', 'middle_membrane'}};
named_solid_blocks{end + 1} = {
    {'middle_base', 'palm_attachment'}, ...
    {'ring_base', 'palm_attachment'}, ...
    ... % {'palm_middle', 'palm_thumb', 'palm_back'}, ...
    ... % {'palm_thumb', 'thumb_base', 'palm_back'}, ...
	{'palm_middle', 'thumb_base', 'palm_back'}, ...
	{'palm_middle', 'palm_index', 'thumb_base'}, ...
    {'palm_right', 'palm_ring', 'palm_back'}, ...
    {'palm_ring', 'palm_middle', 'palm_back'}};


%% Elastic blocks
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

%% Phantom blocks
named_phantom_blocks = {};
named_phantom_blocks{end + 1} = {'pinky_base', 'palm_pinky', 'pinky_membrane'};
named_phantom_blocks{end + 1} = {'ring_base', 'palm_ring', 'ring_membrane'};
named_phantom_blocks{end + 1} = {'middle_base', 'palm_middle', 'middle_membrane'};
named_phantom_blocks{end + 1} = {'index_base', 'palm_index', 'index_membrane'};

named_phantom_blocks{end + 1} = {'thumb_bottom', 'thumb_membrane'};

named_phantom_blocks{end + 1} = {'palm_index', 'palm_left', 'palm_thumb'};

named_phantom_blocks{end + 1} = {'palm_index', 'palm_left', 'palm_thumb'};

named_phantom_blocks{end + 1} = {'palm_attachment', 'palm_right'};
named_phantom_blocks{end + 1} = {'palm_attachment', 'palm_left'};
named_phantom_blocks{end + 1} = {'palm_attachment', 'palm_back'};

%% Smooth blocks
named_smooth_blocks = {};
named_smooth_blocks{end + 1} = {'middle_membrane', 'palm_middle', 'palm_index'};
named_smooth_blocks{end + 1} = {'middle_membrane', 'palm_index', 'index_membrane'};
named_smooth_blocks{end + 1} = {'palm_index', 'palm_middle', 'palm_left'};

named_smooth_blocks{end + 1} = {'palm_pinky', 'palm_ring', 'palm_right'};
named_smooth_blocks{end + 1} = {'palm_right', 'palm_ring', 'palm_back'};
named_smooth_blocks{end + 1} = {'palm_ring', 'palm_middle', 'palm_back'};
named_smooth_blocks{end + 1} = {'palm_middle', 'palm_left', 'palm_back'};
named_smooth_blocks{end + 1} = {'pinky_membrane', 'ring_membrane', 'palm_pinky'};
named_smooth_blocks{end + 1} = {'palm_pinky', 'palm_ring', 'ring_membrane'};
named_smooth_blocks{end + 1} = {'ring_membrane', 'middle_membrane', 'palm_ring'};
named_smooth_blocks{end + 1} = {'palm_ring', 'palm_middle', 'middle_membrane'};

named_smooth_blocks{end + 1} = {'wrist_top_left', 'wrist_bottom_left', 'wrist_top_right'};
named_smooth_blocks{end + 1} = {'wrist_bottom_left', 'wrist_top_right', 'wrist_bottom_right'};

%% Tangent blocks-spheres pairs
named_tangent_blocks = {};
named_tangent_spheres = {};

named_tangent_blocks{end + 1} = {'palm_pinky', 'palm_ring', 'palm_right'};
named_tangent_spheres{end + 1} = 'pinky_base';

named_tangent_blocks{end + 1} = {'palm_pinky', 'palm_ring', 'palm_right'};
named_tangent_spheres{end + 1} = 'ring_base';

named_tangent_blocks{end + 1} = {'palm_ring', 'palm_middle', 'palm_back'};
named_tangent_spheres{end + 1} = 'ring_base';

named_tangent_blocks{end + 1} = {'palm_ring', 'palm_middle', 'palm_back'};
named_tangent_spheres{end + 1} = 'middle_base';

named_tangent_blocks{end + 1} = {'palm_index', 'palm_middle', 'palm_left'};
named_tangent_spheres{end + 1} = 'middle_base';

named_tangent_blocks{end + 1} = {'palm_index', 'palm_middle', 'palm_left'};
named_tangent_spheres{end + 1} = 'index_base';

% named_tangent_blocks{end + 1} = {'palm_index', 'palm_middle', 'palm_left'};
% named_tangent_spheres{end + 1} = 'palm_thumb';

%% Get unnamed blocks
solid_blocks = get_solid_blocks(blocks, names_map, named_blocks, named_solid_blocks, named_elastic_blocks, named_phantom_blocks);
smooth_blocks = get_smooth_blocks(blocks, named_blocks, named_smooth_blocks);
tangent_blocks = get_smooth_blocks(blocks, named_blocks, named_tangent_blocks);
tangent_spheres = zeros(length(named_tangent_spheres), 1);
for i = 1:length(named_tangent_spheres)
    key = named_tangent_spheres(i);
    tangent_spheres(i) = names_map(key{1});
end

blocks = blocks';

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
%mypoints(points, [0.65, 0.1, 0.5]);

%% Save the results
save([data_path, num2str(pose_id), '_points.mat'], 'points');
save([data_path, num2str(pose_id), '_centers.mat'], 'centers');
save([data_path, num2str(pose_id), '_normals.mat'], 'normals');
save([data_path, num2str(pose_id), '_radii.mat'], 'radii');

save([data_path, 'blocks.mat'], 'blocks');
save([data_path, 'smooth_blocks.mat'], 'smooth_blocks');
save([data_path, 'solid_blocks.mat'], 'solid_blocks');
save([data_path, 'tangent_blocks.mat'], 'tangent_blocks');
save([data_path, 'tangent_spheres.mat'], 'tangent_spheres');
%save([data_path, 'solid_blocks_indices.mat'], 'solid_blocks_indices');
save([data_path, 'names_map.mat'], 'names_map');
save([data_path, 'named_blocks.mat'], 'named_blocks');

