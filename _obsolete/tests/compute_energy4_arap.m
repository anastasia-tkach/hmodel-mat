function [f1, J1, f2, J2] = compute_energy4_arap(centers, points, pose, blocks, radii, solid_blocks, restpose_edges, edge_indices, settings, display)

D = settings.D;

%% Sample the model
[model_points, data_points] = sample_model(pose, radii, blocks, settings);

%% Compute projections
[model_indices, ~, ~] = compute_projections(model_points, centers, blocks, radii);

%[F, J] = jacobian_tracking(centers, radii, blocks, model_points, model_indices, data_points, settings.D);

%% Translations energy
[f1, J1] = jacobian_arap_translation(centers, radii, blocks, model_points, model_indices, data_points, D);
%if settings.skeleton, [f1, J1] = jacobian_arap_skeleton(centers, points, model_indices, points, D); end    

%% Rotations energy
[f2, J2] = jacobian_arap_rotation(centers, blocks, edge_indices, restpose_edges, solid_blocks, D);

%% Display
if (display)
    display_result_convtriangles(centers, points, [], blocks, radii, false);
    mypoints(points, [0.75, 0.75, 0.75]);
    mypoints(data_points, 'm');
    mylines(data_points, model_points, [0.1, 0.8, 0.8]);
    drawnow;
end

