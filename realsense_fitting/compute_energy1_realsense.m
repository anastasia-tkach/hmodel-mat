function [pose] = compute_energy1_realsense(pose, radii, blocks, settings, display)

if settings.energy1 == false, return; end;

centers = pose.centers;
data_points = pose.points;

%% Compute projections
[model_indices, model_points, block_indices] = compute_projections(pose.points, pose.centers, blocks, radii); 

model_normals = compute_model_normals(centers, radii, blocks, data_points, model_indices);
camera_ray = [0; 0; 1];
for i = 1:length(model_points)
    if isempty(model_normals{i}), continue; end
    if camera_ray' * model_normals{i} > 0
        model_points{i} = [];
    end
end

%% Compute jacobian
[f, Jc, Jr] = jacobian_realsense(centers, radii, blocks, model_points, model_indices, block_indices, data_points, settings, 'point_to_plane');
pose.f1 = f; pose.Jc1 = Jc; pose.Jr1 = Jr;

%% Display results

if (display)
    if settings.D == 3
        display_result(centers, data_points, model_points, blocks, radii, true, 1, 'big');%mypoints(pose.points, 'm'); drawnow;
        %set(gcf, 'Name', ['energy 1, iter ', num2str(settings.iter)]);
        view([-180, -90]); camlight; drawnow;
    else
        display_result_2D(pose, blocks, radii, true); drawnow;
        set(gcf, 'Name', ['energy 1, iter ', num2str(settings.iter)]);
    end
end
