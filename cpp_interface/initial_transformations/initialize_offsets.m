function [phalanges] = initialize_offsets(centers, phalanges, names_map)
D = 3;
for i = 1:length(phalanges)
    if isfield(phalanges{i}, 'rigid_names')  
        for j = 1:length(phalanges{i}.rigid_names)
            phalanges{i}.offsets{j} =  phalanges{i}.global(1:D, 1:D)' * (centers{names_map(phalanges{i}.rigid_names{j})} -  centers{names_map(phalanges{i}.name)});
        end
    end
end