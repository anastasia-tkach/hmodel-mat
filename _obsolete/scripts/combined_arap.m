function [f1, J1, f2, J2, f3, J3] = combined_arap(pose, centers, points, radii, blocks, solid_blocks, restpose_edges, edge_indices, settings, display)
D = settings.D;

%% Data - model
[model_indices, projections, ~] = compute_projections(points, centers, blocks, radii); 
[f1, J1] = jacobian_arap_translation(centers, radii, blocks, points, model_indices, points, D);

%% Model - data
[model_points, data_points] = sample_model(pose, radii, blocks, settings);
[model_indices, ~, ~] = compute_projections(model_points, centers, blocks, radii);
[f2, J2] = jacobian_arap_translation(centers, radii, blocks, model_points, model_indices, data_points, D);

%% Rotations energy
[f3, J3] = jacobian_arap_rotation(centers, blocks, edge_indices, restpose_edges, solid_blocks, D);

%% Display
if display, 
    display_result_convtriangles(centers, points, projections, blocks, radii, true); 
    drawnow; 
end

%% Display
if (display)
    display_result_convtriangles(centers, points, [], blocks, radii, false);
    mypoints(points, [0.75, 0.75, 0.75]);
    mypoints(data_points, 'm');
    mylines(data_points, model_points, [0.1, 0.8, 0.8]);
    drawnow;
end