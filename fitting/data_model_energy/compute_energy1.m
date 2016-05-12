function [pose] = compute_energy1(pose, radii, blocks, settings, pose_id, display)

if settings.energy1 == false, return; end;

%% Compute projections
if settings.D == 2, [pose.indices, pose.projections, pose.block_indices] = compute_projections_matlab(pose.points, pose.centers, blocks, radii); end
if settings.D == 3, [pose.indices, pose.projections, pose.block_indices] = compute_projections(pose.points, pose.centers, blocks, radii); end

centers = pose.centers;
model_points = pose.points;
model_indices = pose.indices;
data_points = pose.points;

%% Compute jacobian
[f, Jc, Jr] = jacobian_fitting(centers, radii, blocks, model_points, model_indices, pose.block_indices, data_points, settings);
pose.f1 = f; pose.Jc1 = Jc; pose.Jr1 = Jr;

%% Display results

if (display)
    if settings.D == 3
        display_result(pose.centers, pose.points, pose.projections, blocks, radii, false, 1, 'big'); 
        mypoints(pose.points, [179, 81, 109]/255, 1);
        
        if pose_id == 1, view([148, 7.264]); end
        if pose_id == 2, view([150,  -2.7356]); end
        if pose_id == 3, view([-2.662, 11.761]); end
        if pose_id == 4, view([47, 33.264]); end
        xlim([ -4 4]); ylim([-5 5]); zlim([-4 4]);
        if pose_id == 4,  xlim([ -2 2]); end
        %camlight;
        drawnow;
        print(['C:/Developer/data/MATLAB/photoscan_fitting/pose', num2str(pose_id), '_iter', num2str(settings.iter)],'-dpng', '-r300');
    else
        display_result_2D(pose, blocks, radii, true); drawnow;
        set(gcf, 'Name', ['energy 1, iter ', num2str(settings.iter)]);
    end
end
