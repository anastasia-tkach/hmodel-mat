clear;
close all;
set_path;
absolute_path = ['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\'];
data_path = [absolute_path, '_data\convtriangles\'];
load([data_path, 'radii']);
load([data_path, 'blocks']);

D = 3;
num_poses = 1;
num_centers = length(radii);
num_links = sum(cellfun('length', blocks));
num_parameters = D * num_centers * num_poses + num_centers;

poses = cell(num_poses, 1);
for p = 1:num_poses
    load([data_path, 'points']);
    load([data_path, 'centers']);
    poses{p}.num_points = length(points);
    poses{p}.points = points;
    poses{p}.centers = centers;
    poses{p}.num_centers = num_centers;
    poses{p}.data_bounding_box = compute_data_bounding_box(poses{p}.points);
end
p = 1;
%display_result_convtriangles(poses{p}, blocks, radii, true); camlight;
[poses{p}.indices, poses{p}.projections, poses{p}.block_indices] = compute_projections(poses{p}.points, poses{p}.centers, blocks, radii);
display_result_convtriangles(poses{p}, blocks, radii, true); camlight; hold on;
return
pose = poses{p};

%% Compute projections
num_points = pose.num_points;
points = pose.points;

indices = cell(num_points, 1);
block_indices = cell(num_points, 1);
min_distance = Inf * ones(num_points, 1);
projections = cell(num_points, 1);

tangent_points = blocks_tangent_points(pose.centers, blocks, radii);

last_point = [0; 0; 0];
for i = 1:num_points
    
    p = points{i};    
    all_projections = cell(length(blocks), 1);
    all_distances = zeros(length(blocks), 1);
    all_indices = cell(length(blocks), 1);
    all_block_indices = zeros(length(blocks), 1);    
    for j = 1:length(blocks)
        [index, q, ~, ~] = projection(p, blocks{j}, radii, pose.centers, tangent_points{j});
        all_projections{j} = q;
        all_distances(j) = norm(p - q);
        all_indices{j} = index;
        all_block_indices(j) = j;
        
        if norm(p - q) < min_distance(i)
            min_distance(i) = norm(p - q);
            indices{i} = index;
            projections{i} = q;
            block_indices{i} = j;
        end        
    end
    %% Compute insideness matrix
    [intersecting_blocks_indices] = get_intersecting_blocks(points{i}, indices{i}, blocks, pose.centers, radii);
    insideness_matrix = zeros(length(intersecting_blocks_indices), length(intersecting_blocks_indices));
    for k = 1:length(intersecting_blocks_indices)
        for l = 1:length(intersecting_blocks_indices)
            u = intersecting_blocks_indices(k);
            v = intersecting_blocks_indices(l);
            if u == v, continue; end
            [~, ~, ~, is_inside] = projection(all_projections{u}, blocks{v}, radii, pose.centers, tangent_points{v});
            insideness_matrix(k, l) = is_inside;
        end
    end    
    insideness_vector = sum(insideness_matrix, 2);
    min_element = min(insideness_vector);
    
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     if ~all(indices{i} == [1])
%         indices{i} = [];
%         projections{i} = [];
%         continue;
%     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    mypoint(points{i}, 'm');
    if (min_element > 0)
        indices{i} = [];
        projections{i} = [];
        continue;
    end
    
    best_blocks_indices = intersecting_blocks_indices(insideness_vector == min_element);
    
    %% Choose the most outer projection
    [~, min_best_block_index] = min(all_distances(best_blocks_indices));
    min_index = best_blocks_indices(min_best_block_index);
    indices{i} = all_indices{min_index};
    projections{i} = all_projections{min_index};
    block_indices{i} = all_block_indices(min_index);
    
    if norm(points{i} - projections{i}) > 100
        disp([i, norm(points{i} - projections{i})]);
    end
    
end
pose.indices = indices;
pose.projections = projections;
pose.block_indices = block_indices;
pose.all_projections = all_projections;


%% Display
display_result_convtriangles(pose, blocks, radii, true); camlight;