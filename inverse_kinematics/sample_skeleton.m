function [points] = sample_skeleton(centers, blocks)

samples = zeros(0,3);
num_samples = 15;

for i = 1:length(blocks)
    index = nchoosek(blocks{i}, 2);
    for j = 1:size(index, 1)
        p1 = centers{index(j, 1)};
        p2 = centers{index(j, 2)};
        
        s = [
            linspace(p1(1), p2(1),num_samples + 1);
            linspace(p1(2), p2(2),num_samples + 1);
            linspace(p1(3), p2(3),num_samples + 1)
            ];
        %s(:, 1) = []; % origin is not a sample
        
        samples = [ samples; s' ]; %#ok<AGROW>
    end
end

points = cell(length(samples), 1);
for i = 1:length(samples)
    points{i} = samples(i, :)';
end

