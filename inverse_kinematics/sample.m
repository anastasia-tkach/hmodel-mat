function [model_points, block_indices] = sample(T, settings)
model_points = zeros(0,3);
block_indices   = zeros(0,1);
num_samples = T.samples_per_branch;

for i = settings.num_translations + 1:settings.num_parameters-1
    p1 = T.global_translation(i+0,:);
    p2 = T.global_translation(i+1,:);
    
    c_eff = [
        linspace(p1(1), p2(1),num_samples + 1);
        linspace(p1(2), p2(2),num_samples+1);
        linspace(p1(3), p2(3),num_samples+1)  
        ];
    c_eff(:,1) = []; % origin is not a sample
    
    model_points = [ model_points; c_eff' ]; %#ok<AGROW>
    block_indices  = [ block_indices; i*ones(num_samples,1) ]; %#ok<AGROW>
end
