function [pose] = compute_energy3_3D_all_axis(pose, blocks, radii, settings, display)
D = settings.D;
view_axes = {'X', 'Y', 'Z'};
for v = 1:D
    view_axis = view_axes{v};
    switch(view_axis)
        case 'X', if settings.energy3x == false; continue; end
        case 'Y', if settings.energy3y == false; continue; end
        case 'Z', if settings.energy3z == false; continue; end
    end
    
    %% Render model and data
    [raytracing_matrix, camera_axis, camera_center] = get_raytracing_matrix(pose.centers, radii, pose.data_bounding_box, view_axis, settings);
    if D == 3
        [pose] = render_model(pose, blocks, radii, raytracing_matrix, camera_center, settings);
        [pose] = render_data(pose, camera_axis, camera_center, view_axis, pose.closing_radius{v}, settings);
        
        %% Get wrong model points
        RAND_MAX = 32767;
        [I, J] = find((pose.rendered_model(:, :, 3) > - RAND_MAX) & (pose.rendered_data == 0));
        pose.model_points = cell(length(I), 1);
        for k = 1:length(I), pose.model_points{k} = squeeze(pose.rendered_model(I(k), J(k), :)); end
    else
        [pose] = render_model_2D(pose, blocks, radii, raytracing_matrix, camera_center, settings);
        [pose] = render_data_2D(pose, camera_axis, camera_center, view_axis, settings);
        
        %% Get wrong model points
        RAND_MAX = 32767;
        I = find((pose.rendered_model(:, 2) > - RAND_MAX) & (pose.rendered_data == 0));
        pose.model_points = cell(length(I), 1);
        for k = 1:length(I)
            pose.model_points{k} = squeeze(pose.rendered_model(I(k), :));
        end
        
        %% Display projected model and data
        % display_result_2D(pose, blocks, radii, false); mypoints(pose.model_points, 'm'); mypoints(pose.points, 'c');
    end
    
    %% Compute correspondences
    [pose.model_indices, pose.model_projections, ~] = compute_projections(pose.model_points, pose.centers, blocks, radii);
    
    [pose] = find_closest_data_points(pose, view_axis, settings);
    
    %% Display
    if D == 3 && display
        RAND_MAX = 32767;
        rendered_intersection = zeros(size(pose.rendered_model));
        rendered_intersection(:, :, 1) = (pose.rendered_model(:, :, 3) > -RAND_MAX);
        rendered_intersection(:, :, 2) = pose.rendered_data;
        figure; imshow(rendered_intersection); drawnow;
        set(gcf, 'Name', ['energy 3, iter ', num2str(settings.iter)]);
    end
    
    %% Compute energy
    [pose, f, Jc, Jr] = compute_energy3_3D(pose, radii, blocks, D);
    
    switch(view_axis)
        case 'X', pose.f3x = f; pose.Jc3x = Jc; pose.Jr3x = Jr;
        case 'Y', pose.f3y = f; pose.Jc3y = Jc; pose.Jr3y = Jr;
        case 'Z', pose.f3z = f; pose.Jc3z = Jc; pose.Jr3z = Jr;
    end
    %% Store
    switch(view_axis)
        case 'X'
            pose.model_points_X = pose.model_points;
            pose.closest_data_points_X = pose.closest_data_points;
        case 'Y'
            pose.model_points_Y = pose.model_points;
            pose.closest_data_points_Y = pose.closest_data_points;
        case 'Z'
            pose.model_points_Z = pose.model_points;
            pose.closest_data_points_Z = pose.closest_data_points;
    end
end
