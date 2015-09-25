function [indices, projections] = compute_projections_matlab_2D(points, centers, blocks, radii)

num_points = length(points);

indices = cell(num_points, 1);
block_indices = cell(num_points, 1);
min_distance = Inf * ones(num_points, 1);
projections = cell(num_points, 1);

for i = 1:num_points
    p = points{i};
    
    [index, q, ~, ~] = projection_2D(p, blocks{1}, radii, centers);
    indices{i} = index;
    projections{i} = q;
    
%     all_projections = cell(length(blocks), 1);
%     all_distances = zeros(length(blocks), 1);
%     all_indices = cell(length(blocks), 1);
%     all_block_indices = zeros(length(blocks), 1);
%     
%     for j = 1:length(blocks)
%         [index, q, ~, ~] = projection_2D(p, blocks{j}, radii, centers);
%         all_projections{j} = q;
%         all_distances(j) = norm(p - q);
%         all_indices{j} = index;
%         all_block_indices(j) = j;
%         
%         if norm(p - q) < min_distance(i)
%            min_distance(i) = norm(p - q);
%            indices{i} = index;
%            projections{i} = q;
%            block_indices{i} = j;
%         end
%         
%     end            
% 
%     
%     %% Compute insideness matrix
%     [intersecting_blocks_indices] = get_intersecting_blocks(points{i}, indices{i}, blocks, centers, radii);
%     insideness_matrix = zeros(length(intersecting_blocks_indices), length(intersecting_blocks_indices));
%     for k = 1:length(intersecting_blocks_indices)
%         for l = 1:length(intersecting_blocks_indices)
%             u = intersecting_blocks_indices(k);
%             v = intersecting_blocks_indices(l);
%             if u == v, continue; end
%             [~, ~, ~, is_inside] = projection_2D(all_projections{u}, blocks{v}, radii, centers);
%             insideness_matrix(k, l) = is_inside;
%         end
%     end
%     
%     insideness_vector = sum(insideness_matrix, 2);
%     min_element = min(insideness_vector);
%     
%     if (min_element > 0)
%         indices{i} = [];
%         projections{i} = [];
%         continue;
%     end
%     
%     best_blocks_indices = intersecting_blocks_indices(insideness_vector == min_element);   
%     
%     %% Choose the most outer projection
%     [~, min_best_block_index] = min(all_distances(best_blocks_indices));
%     min_index = best_blocks_indices(min_best_block_index);
%     indices{i} = all_indices{min_index};
%     projections{i} = all_projections{min_index};
%     block_indices{i} = all_block_indices(min_index);   
%     
%     if norm(points{i} - projections{i}) > 100
%         disp([i, norm(points{i} - projections{i})]);
%     end    
%    
end

% pose.indices = indices;
% pose.projections = projections;
% pose.block_indices = block_indices;
% 
% pose.all_projections = all_projections;


