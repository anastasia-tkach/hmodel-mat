close all; clear;
pose_id = 1;
data_path = 'C:/Users/tkach/OneDrive/EPFL/Code/HModel/_data/my_hand/trial1/';

%% Read the centers locations
pose1;
skeleton6;

%% Build the data structures
for i = 1:length(named_blocks)
    blocks{i} = [];
    for j = 1:length(named_blocks{i})
        key = named_blocks{i}(j);
        blocks{i} = [blocks{i}, names_map(key{1})];
    end
end
solids = {};
for i = 1:length(named_solids)
    solids{i} = [];
    for j = 1:length(named_solids{i})
        key = named_solids{i}(j);
        solids{i} = [solids{i}, names_map(key{1})];
    end
end
for i = 1:length(names_map_keys)
    key = names_map_keys{i}; 
    centers{i} = centers_map(key);
    radii{i} = radii_map(key) + randn * 5e-3;
end

%% Get points and normals
[V, F] = readOBJ(filename);
N = per_vertex_normals(V, F);
for i = 1:size(V, 1)
    points{i} = V(i, :)';
    normals{i} = N(i, :)';
end

%% Display
figure; axis off; axis equal; hold on;
for i = 1:length(centers)
    draw_sphere(centers{i}, radii{i}, 'c');
end
%mypoints(points, 'b');
for i = 1:length(blocks)
    indices = nchoosek(blocks{i}, 2);
    index1 = indices(:, 1); 
    index2 = indices(:, 2);
    for j = 1:length(index1)
        myline(centers{index1(j)}, centers{index2(j)}, [0.8, 0, 0.7]); 
    end
end
view([140, 42]);

%% Display
% centers = values(centers_map);
% figure; axis off; axis equal; hold on;
% mypoints(points, 'b');
% for i = 1:length(centers)
%     mypoint(centers{i}, 'm');
% end

%% Save the results
save([data_path, num2str(pose_id), '_points.mat'], 'points');
save([data_path, num2str(pose_id), '_centers.mat'], 'centers');
save([data_path, num2str(pose_id), '_normals.mat'], 'normals');
save([data_path, 'radii.mat'], 'radii');
solids = solids'; blocks = blocks';
save([data_path, 'blocks.mat'], 'blocks');
save([data_path, 'solids.mat'], 'solids');
save([data_path, 'names_map.mat'], 'names_map');
save([data_path, 'named_blocks.mat'], 'named_blocks');

