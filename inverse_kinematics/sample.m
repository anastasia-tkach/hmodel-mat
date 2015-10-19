function [model_points, segment_indices] = sample(T, settings)

model_points = zeros(0,3);
segment_indices   = zeros(0,1);
num_samples = T.samples_per_branch;

for i = 1:length(T.segments) - 1
    p1 = T.global_translation(T.segments{i}(1),:);
    p2 = T.global_translation(T.segments{i + 1}(1),:);
    
    points = [
        linspace(p1(1), p2(1),num_samples + 1);
        linspace(p1(2), p2(2),num_samples + 1);
        linspace(p1(3), p2(3),num_samples + 1)  
        ];
    points(:, 1) = []; % origin is not a sample
    
    model_points = [ model_points; points' ]; %#ok<AGROW>
    segment_indices  = [segment_indices; i * ones(num_samples,1) ]; %#ok<AGROW>
end