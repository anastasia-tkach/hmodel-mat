function [points] = sample_skeleton(centers, blocks)

samples = zeros(0,3);
num_samples = 15;

for i = 1:length(blocks)
    p1 = centers{blocks{i}(1)};
    p2 = centers{blocks{i}(2)};
    
    s = [
        linspace(p1(1), p2(1),num_samples + 1);
        linspace(p1(2), p2(2),num_samples + 1);
        linspace(p1(3), p2(3),num_samples + 1)  
        ];
    %s(:, 1) = []; % origin is not a sample
    
    samples = [ samples; s' ]; %#ok<AGROW>
    %block_indices  = [block_indices; i * ones(num_samples,1) ]; %#ok<AGROW>
end

points = cell(length(samples), 1);
for i = 1:length(samples)
    points{i} = samples(i, :)';
end

