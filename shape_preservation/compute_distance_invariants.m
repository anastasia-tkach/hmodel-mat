function [pose] = compute_distance_invariants(pose, blocks)

pose.invariants = [];
for b = 1:length(blocks)
    indices = nchoosek(blocks{b}, 2);
    index1 = indices(:, 1);
    index2 = indices(:, 2);
    for l = 1:length(index1)
        i = index1(l);
        j = index2(l);
        distance = norm(pose.centers{i} - pose.centers{j});
        pose.invariants = [pose.invariants; distance];
    end
end

