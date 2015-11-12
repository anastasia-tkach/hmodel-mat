function [f1, J1, f2, J2] = compute_energy_arap(centers, points, radii, blocks, solid_blocks, restpose_edges, edge_indices, settings, display)
D = settings.D;

%% Compute projections
if settings.D == 2, [model_indices, projections, ~] = compute_projections_matlab(points, centers, blocks, radii); end
if settings.D == 3, [model_indices, projections, ~] = compute_projections(points, centers, blocks, radii); end
if settings.skeleton, [model_indices, projections, ~] = compute_skeleton_projections(points, centers, blocks); end

%% Translations energy
[f1, J1] = jacobian_arap_translation(centers, radii, blocks, points, model_indices, points, D);
%if settings.skeleton, [f1, J1] = jacobian_arap_skeleton(centers, points, model_indices, points, D); end    

%% Rotations energy
[f2, J2] = jacobian_arap_rotation(centers, blocks, edge_indices, restpose_edges, solid_blocks, D);

%% Display
if display, 
    display_result_convtriangles(centers, points, projections, blocks, radii, true); 
    %campos([10, 160, -1500]); camlight;
    drawnow; 
end
