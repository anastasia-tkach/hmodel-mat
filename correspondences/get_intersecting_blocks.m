function [intersecting_blocks_indices] = get_intersecting_blocks(p, index, blocks, centers, radii)


if length(index) > 1
    distances = zeros(length(index), 1);
    for i = 1:length(index)
        distances(i) = abs(norm(p - centers{abs(index(i))}) - radii{i});
    end    
    [~, min_index] = min(distances);
    index = abs(index(min_index));
end

intersecting_blocks_indices = [];
for j = 1:length(blocks)
    if ismember(index, blocks{j})
        intersecting_blocks_indices = [intersecting_blocks_indices, j];
    end
end