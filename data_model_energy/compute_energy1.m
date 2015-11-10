function [pose] = compute_energy1(pose, radii, blocks, settings, display)

if settings.energy1 == false, return; end;

%% Compute projections
if settings.D == 2, [pose.indices, pose.projections, pose.block_indices] = compute_projections_matlab(pose.points, pose.centers, blocks, radii); end
if settings.D == 3, [pose.indices, pose.projections, pose.block_indices] = compute_projections(pose.points, pose.centers, blocks, radii); end

centers = pose.centers;
model_points = pose.points;
model_indices = pose.indices;
data_points = pose.points;

%% Compute jacobian
switch settings.mode
    case 'fitting'
        [f, Jc, Jr] = jacobian_fitting(centers, radii, blocks, model_points, model_indices, data_points, settings.D);
        pose.f1 = f; pose.Jc1 = Jc; pose.Jr1 = Jr;
    case 'tracking'
        [f, Jc] = jacobian_tracking(centers, radii, blocks, model_points, model_indices, data_points, settings.D);
        pose.f1 = f; pose.Jc1 = Jc;
end

%% Display results


if (display)
    if settings.D == 3
        display_result_convtriangles(pose.centers, pose.points, pose.projections, blocks, radii, true); drawnow;%mypoints(pose.points, 'm'); drawnow;
        set(gcf, 'Name', ['energy 1, iter ', num2str(settings.iter)]);
    else
        display_result_2D(pose, blocks, radii, true); drawnow;
        set(gcf, 'Name', ['energy 1, iter ', num2str(settings.iter)]);
    end
end
