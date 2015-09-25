function [indices, closest_projection, block_index]  = compute_projections_inner_loop(p, blocks, tangent_points, radii, centers)

min_distance = Inf;
all_projections = cell(length(blocks), 1);
all_distances = zeros(length(blocks), 1);
all_indices = cell(length(blocks), 1);
all_block_indices = zeros(length(blocks), 1);

for j = 1:length(blocks)
    [index, q, ~, ~] = projection(p, blocks{j}, radii, centers, tangent_points{j});
    all_projections{j} = q;
    all_distances(j) = norm(p - q);
    all_indices{j} = index;
    all_block_indices(j) = j;
    
    if norm(p - q) < min_distance
        min_distance = norm(p - q);
        indices = index;
        closest_projection = q;
        block_index = j;
    end    
end

%% Compute insideness matrix
[intersecting_blocks_indices] = get_intersecting_blocks(p, indices, blocks, centers, radii);
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
    indices = [];
    closest_projection = [];
    return;
end

best_blocks_indices = intersecting_blocks_indices(insideness_vector == min_element);

%% Choose the most outer projection
[~, min_best_block_index] = min(all_distances(best_blocks_indices));
min_index = best_blocks_indices(min_best_block_index);
indices = all_indices{min_index};
closest_projection = all_projections{min_index};
block_index = all_block_indices(min_index);

