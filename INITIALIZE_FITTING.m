close all; clear;
output_path = '_my_hand/fitting_initialization/';
semantics_path = '_my_hand/semantics/';
pose_id = 4;
pose4;
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

%% Get named blocks
SEMANTICS;

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
filename = [output_path, num2str(pose_id)', '.obj'];
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
save([output_path, num2str(pose_id), '_points.mat'], 'points');
save([output_path, num2str(pose_id), '_centers.mat'], 'centers');
save([output_path, num2str(pose_id), '_normals.mat'], 'normals');
save([output_path, num2str(pose_id), '_radii.mat'], 'radii');

save([semantics_path, 'fitting/blocks.mat'], 'blocks');
save([semantics_path, 'fitting/names_map.mat'], 'names_map');
save([semantics_path, 'fitting/named_blocks.mat'], 'named_blocks');

save([semantics_path, 'smooth_blocks.mat'], 'smooth_blocks');
save([semantics_path, 'solid_blocks.mat'], 'solid_blocks');
save([semantics_path, 'tangent_blocks.mat'], 'tangent_blocks');
save([semantics_path, 'tangent_spheres.mat'], 'tangent_spheres');
%save([data_path, 'solid_blocks_indices.mat'], 'solid_blocks_indices');

save([semantics_path, 'named_elastic_blocks.mat'], 'named_elastic_blocks');
save([semantics_path, 'named_solid_blocks.mat'], 'named_solid_blocks');

