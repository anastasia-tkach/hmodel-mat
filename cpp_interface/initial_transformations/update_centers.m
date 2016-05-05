function [centers] = update_centers(centers, phalanges, names_map)
D = 3;
num_phalanges = 17;
for i = 1:num_phalanges
    centers{names_map(phalanges{i}.name)} = phalanges{i}.global(1:D, D + 1);    
    if isfield(phalanges{i}, 'rigid_names')
        for j = 1:length(phalanges{i}.rigid_names)
            index = names_map(phalanges{i}.rigid_names{j});
            t = phalanges{i}.global(1:D, 1:D) * phalanges{i}.offsets{j};
            centers{index} = centers{names_map(phalanges{i}.name)} + t;
        end
    end
end
