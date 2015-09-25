function [pose] = compute_energy3(pose, blocks, radii, settings, display)
D = settings.D;
H = settings.H;
W = settings.W;

view_axes = {'X', 'Y', 'Z'};
for v = 1:D
    
    view_axis = view_axes{v};
    
    switch(view_axis)
        case 'X'
            if settings.energy3x == false; continue; end
        case 'Y'
            if settings.energy3y == false; continue; end
        case 'Z'
            if settings.energy3z == false; continue; end
    end
    
    %% Render model and data
    [raytracing_matrix, camera_axis, camera_center] = get_raytracing_matrix(pose.centers, radii, pose.data_bounding_box, view_axis, settings);
    if D == 2
        [pose] = render_model_2D(pose, blocks, radii, raytracing_matrix, camera_center, settings);
        [pose] = render_data_2D(pose, camera_axis, camera_center, view_axis, settings);
        
        %% Get wrong model points
        RAND_MAX = 32767;
        I = find((pose.rendered_model(:, 2) > - RAND_MAX) & (pose.rendered_data == 0));
        pose.model_points = cell(length(I), 1);
        for k = 1:length(I)
            pose.model_points{k} = squeeze(pose.rendered_model(I(k), :))';
        end
    end
    if D == 3
        [pose] = render_model(pose, blocks, radii, raytracing_matrix, camera_center, settings);
        [pose] = render_data(pose, camera_axis, camera_center, view_axis, pose.closing_radius{v}, settings);
        
        %% Get wrong model points
        RAND_MAX = 32767;
        [I, J] = find((pose.rendered_model(:, :, 3) > - RAND_MAX) & (pose.rendered_data == 0));
        pose.model_points = cell(length(I), 1);
        for k = 1:length(I), pose.model_points{k} = squeeze(pose.rendered_model(I(k), J(k), :)); end
    end
    
    
    %% Compute correspondences
    
    if D == 2, [pose.model_indices, pose.model_projections, ~] = compute_projections_matlab(pose.model_points, pose.centers, blocks, radii); end
    if D == 3, [pose.model_indices, pose.model_projections, ~] = compute_projections(pose.model_points, pose.centers, blocks, radii); end
    
    %% Compute energy
    if (D == 3), [pose, f, Jc, Jr] = compute_energy3_given_axis(pose, radii, blocks, view_axis, settings); end
    if (D == 2), [pose, f, Jc, Jr] = compute_energy3_2D(pose, radii, blocks, view_axis, settings); end
    
    %% Display
    if D == 2 && display
        display_result_2D(pose, blocks, radii, false); mypoints(pose.points, 'c');
        mypoints(pose.model_points, 'm'); drawnow;
        set(gcf, 'Name', ['energy 3, iter ', num2str(settings.iter)]);
        %switch view_axis
        %case 'X'
        %field  = zeros(H, length(pose.model_points), 3);
        %field(:, :, 2) = repmat((pose.rendered_model(:, 2) > -RAND_MAX), 1, length(pose.model_points));
        %field(:, :, 3) = repmat(pose.rendered_data, 1, length(pose.model_points)); figure; imshow(field); hold on;
        %for i = 1:length(pose.model_points)
        %mypoint([i; pose.model_points_2D{i}], 'b'); mypoint([i; pose.model_projections_2D{i}], 'm');
        %myline([i; pose.model_points_2D{i}], [i; pose.model_projections_2D{i}], 'r');
        %end
        %case 'Y'
        %field  = zeros(length(pose.model_points), H, 3);
        %field(:, :, 2) = repmat((pose.rendered_model(:, 2) > -RAND_MAX)', length(pose.model_points), 1);
        %field(:, :, 3) = repmat(pose.rendered_data', length(pose.model_points), 1); figure; imshow(field); hold on;
        %for i = 1:length(pose.model_points)
        %mypoint([pose.model_points_2D{i}; i], 'b'); mypoint([pose.model_projections_2D{i}; i], 'm');
        %myline([pose.model_points_2D{i}; i], [pose.model_projections_2D{i}; i], 'r');
        %end
        %end
    end
    if D == 3 && display
        RAND_MAX = 32767;
        rendered_intersection = zeros(size(pose.rendered_model));
        rendered_intersection(:, :, 1) = (pose.rendered_model(:, :, 3) > -RAND_MAX);
        rendered_intersection(:, :, 2) = pose.rendered_data;
        figure; imshow(rendered_intersection); hold on; axis equal;
        set(gcf, 'Name', ['energy 3, iter ', num2str(settings.iter)]);        
        mypoints(pose.model_points_2D, 'm');        
        mylines(pose.model_points_2D, pose.model_projections_2D, 'w');
        mypoints(pose.model_projections_2D, 'b'); drawnow; 
    end
    
    switch(view_axis)
        case 'X', pose.f3x = f; pose.Jc3x = Jc; pose.Jr3x = Jr;
        case 'Y', pose.f3y = f; pose.Jc3y = Jc; pose.Jr3y = Jr;
        case 'Z', pose.f3z = f; pose.Jc3z = Jc; pose.Jr3z = Jr;
    end
    
    %% Store
    switch(view_axis)
        case 'X'
            pose.rendered_model_X = pose.rendered_model;
            pose.rendered_data_X = pose.rendered_data;
            pose.model_points_2D_X = pose.model_points_2D;
            pose.model_projections_2D_X = pose.model_projections_2D;
        case 'Y'
            pose.rendered_model_Y = pose.rendered_model;
            pose.rendered_data_Y = pose.rendered_data;
            pose.model_points_2D_Y = pose.model_points_2D;
            pose.model_projections_2D_Y = pose.model_projections_2D;
        case 'Z'
            pose.rendered_model_Z = pose.rendered_model;
            pose.rendered_data_Z = pose.rendered_data;
            pose.model_points_2D_Z = pose.model_points_2D;
            pose.model_projections_2D_Z = pose.model_projections_2D;
    end
    
end
