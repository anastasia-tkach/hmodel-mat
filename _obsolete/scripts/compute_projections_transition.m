function [indices, projections, block_indices] = compute_projections_transition(points, centers, blocks, radii)

num_points = length(points);

indices = cell(num_points, 1);
block_indices = cell(num_points, 1);
projections = cell(num_points, 1);

tangent_points = blocks_tangent_points(centers, blocks, radii);

for i = 1:num_points
    p = points{i};
    [indices{i}, projections{i}, block_indices{i}]  = compute_projections_inner_loop(p, blocks, tangent_points, radii, centers);
end



