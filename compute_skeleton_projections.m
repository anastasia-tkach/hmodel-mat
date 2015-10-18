function [indices, projections, block_indices] = compute_skeleton_projections(points, centers, blocks)
RAND_MAX = 32767;
num_points = length(points);

indices = cell(num_points, 1);
block_indices = cell(num_points, 1);
min_distance = RAND_MAX * ones(num_points, 1);
projections = cell(num_points, 1);

for i = 1:num_points
    
    p = points{i};
    
    all_projections = cell(length(blocks), 1);
    all_distances = -RAND_MAX * ones(length(blocks), 1);
    all_indices = cell(length(blocks), 1);
    all_block_indices = zeros(length(blocks), 1);
    
    for j = 1:length(blocks)
        
        %% Compute skeleton projections
        block = blocks{j};
        
        if length(block) == 2
            c1 = centers{block(1)}; c2 = centers{block(2)};
            index1 = block(1); index2 = block(2);
            [index, q] = projection_segment(p, c1, c2, index1, index2);
        end
        if length(block) == 3
            c1 = centers{block(1)}; c2 = centers{block(2)}; c3 = centers{block(3)};
            index1 = block(1); index2 = block(2); index3 = block(3);
            [index, q] = projection_triangle(p, c1, c2, c3, index1, index2, index3);
        end
        
        %% Find closest projection
        all_projections{j} = q;
        all_distances(j) = norm(p - q);
        all_indices{j} = index;
        all_block_indices(j) = j;
        
        if all_distances(j) < min_distance(i)
            min_distance(i) = all_distances(j);
            indices{i} = index;
            projections{i} = q;
            block_indices{i} = j;
        end
    end
    
end


