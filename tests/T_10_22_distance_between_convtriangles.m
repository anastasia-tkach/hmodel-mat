clear;
D = 3;
close all;
[centers1, radii1, blocks1] = get_random_convsegment();
[centers2, radii2, blocks2] = get_random_convsegment();
%[centers1, radii1, blocks1] = get_random_convtriangle();
%[centers2, radii2, blocks2] = get_random_convtriangle();
for i = 1:length(radii1), radii1{i} = radii1{i} * 0.5; end
for i = 1:length(radii2), radii2{i} = radii2{i} * 0.5; end
a = rand; b = rand; c = rand;
d = a + b + c; a = a/d; b = b/d; c = c/d;
original_centers1 = centers1;
% close all;
% centers1 = original_centers1;

tangent_points = blocks_tangent_points([centers1; centers2], {[1:length(centers1)], ...
    [length(centers1) + 1: length(centers1) + length(centers2)]}, [radii1; radii2]);

for iter = 1:2
    
    %% Display
    display_result_convtriangles([centers1; centers2], [], [], {[1:length(centers1)], ...
        [length(centers1) + 1: length(centers1) + length(centers2)]}, [radii1; radii2], true);
    %myline(centers1{1}, centers1{2}, 'b'); myline(centers2{1}, centers2{2}, 'b');
    %if length(centers1) == 3
    %    myline(centers1{1}, centers1{3}, 'b'); myline(centers1{2}, centers1{3}, 'b');
    %end
    %if length(centers2) == 3
    %    myline(centers2{1}, centers2{3}, 'b'); myline(centers2{2}, centers2{3}, 'b');
    %end
    %myline(p, q, 'k'); mypoint(surface_p, 'm'); mypoint(surface_q, 'm');
    %myline(surface_q, surface_q + 0.1 * n, 'g');
    %drawnow;
    
    %% Find max. penetration
    normal2 = [];
    [p, surface_p, q, surface_q, is_colliding] = get_collision_constraints_convtriangles([centers1; centers2], [radii1; radii2], ...
        [1:length(centers1)], [length(centers1) + 1: length(centers1) + length(centers2)], tangent_points{2});
    if is_colliding == false, continue; end
    model_points = {surface_p}; data_points = {surface_q};
    
    %% Compute normal
    normals = compute_model_normals_temp(data_points, centers2, blocks2, radii2); n = normals{1};
    
    %% Avoid collision: move the point surface_p to the location surface_q
    [model_indices, ~, ~] = compute_projections(model_points, centers1, blocks1, radii1)
    [F, J] = jacobian_arap_translation(centers1, radii1, blocks1, model_points, model_indices, data_points, D);
    
    F = n' * F;
    J = n' * J;
    
    I = eye(D * length(centers1), D * length(centers1));
    damping = 0.01;
    LHS = damping * I + J' * J;
    rhs = J' * F;
    delta = -  LHS \ rhs;
    
    %% Apply update
    for o = 1:length(centers1), centers1{o} = centers1{o} + delta(D * o - D + 1:D * o); end
    
end
























