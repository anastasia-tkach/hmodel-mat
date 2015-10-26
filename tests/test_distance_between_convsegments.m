% clear;
% D = 3;
% close all;
% [centers1, radii1, blocks1] = get_random_convsegment();
% [centers2, radii2, blocks2] = get_random_convsegment();
% for i = 1:length(radii1)
%     radii1{i} = radii1{i} * 0.5;
%     radii2{i} = radii2{i} * 0.5;
% end
% centers = [centers1; centers2]; radii = [radii1; radii2];

centers1 = centers(1:2); centers2 = centers(3:4); 
radii1 = radii(1:2); radii2 = radii(3:4);

c1 = centers1{1}; c2 = centers1{2}; c3 = centers2{1}; c4 = centers2{2};
r1 = radii1{1}; r2 = radii1{2}; r3 = radii2{1}; r4 = radii2{2};


figure; hold on;
display_result_convtriangles(centers1, [], [], blocks1, radii1, true);
display_result_convtriangles(centers2, [], [], blocks1, radii2, true);


%% Sample one segment
for t = 1:1
    [p, surface_p, q, surface_q] = get_collision_constraints_convsegments(centers, radii, [1, 2], [3, 4]);
    [surface_p, surface_q]    
    
    myline(p, q, 'k');
    mypoint(surface_p, 'm'); mypoint(surface_q, 'm');
    model_points = {surface_p};
    data_points = {surface_q};
    [model_indices, ~, ~] = compute_projections(model_points, centers1, blocks1, radii1);
    
    %% Compute normal
    [indices, projections, ~] = compute_projections(data_points, centers2, blocks2, radii2);
    normals = compute_model_normals_temp(data_points, centers2, blocks2, radii2); n = normals{1};
    myline(surface_q, surface_q + 0.1 * n, 'g');
    
    
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
    
    %% Display results
    figure; hold on;
    display_result_convtriangles(centers1, [], [], blocks1, radii1, true);
    display_result_convtriangles(centers2, [], [], blocks1, radii2, true);
    myline(centers1{1}, centers1{2}, 'b'); myline(centers2{1}, centers2{2}, 'b');
    
end



















