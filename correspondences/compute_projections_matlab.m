function [indices, projections, block_indices] = compute_projections_matlab(points, centers, blocks, radii)
RAND_MAX = 32767;
num_points = length(points);

indices = cell(num_points, 1);
block_indices = cell(num_points, 1);
min_distance = Inf * ones(num_points, 1);
projections = cell(num_points, 1);

tangent_points = blocks_tangent_points(centers, blocks, radii);

for i = 1:num_points
    if (i == 2463)
        disp(' ');
    end
    p = points{i};
    
    all_projections = cell(length(blocks), 1);
    all_distances = -RAND_MAX * ones(length(blocks), 1);
    all_indices = cell(length(blocks), 1);
    all_block_indices = zeros(length(blocks), 1);
    
    for j = 1:length(blocks)
        [index, q, ~, is_inside] = projection(p, blocks{j}, radii, centers, tangent_points{j});
        all_projections{j} = q;
        all_distances(j) = norm(p - q);
        if is_inside == 1, all_distances(j) = - norm(p - q); end
        all_indices{j} = index;
        all_block_indices(j) = j;
        
        if all_distances(j) < min_distance(i)
            min_distance(i) = all_distances(j);
            indices{i} = index;
            projections{i} = q;
            block_indices{i} = j;
        end
        
    end
    
    
    %% Compute insideness matrix
    [intersecting_blocks_indices] = get_intersecting_blocks(points{i}, indices{i}, blocks, centers, radii);
    insideness_matrix = zeros(length(intersecting_blocks_indices), length(intersecting_blocks_indices));
    for k = 1:length(intersecting_blocks_indices)
        for l = 1:length(intersecting_blocks_indices)
            u = intersecting_blocks_indices(k);
            v = intersecting_blocks_indices(l);
            if u == v, continue; end
            [~, ~, ~, is_inside] = projection(all_projections{u}, blocks{v}, radii, centers, tangent_points{v});
            insideness_matrix(k, l) = is_inside;
        end
    end
    
    insideness_vector = sum(insideness_matrix, 2);
    min_element = min(insideness_vector);
   
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
    
    %if norm(points{i} - projections{i}) > 100
        %disp([i, norm(points{i} - projections{i})]);
    %end
    
end


