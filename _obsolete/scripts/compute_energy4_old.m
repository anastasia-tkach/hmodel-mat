function [pose] = compute_energy4(pose, blocks, radii, settings, display)

if settings.energy4 == false
    return
end

D = settings.D;
H = settings.H;
W = settings.W;
RAND_MAX = settings.RAND_MAX;

view_axes = {'X', 'Y', 'Z'};
pose.model_points  = [];
for v = 1:D
    
    view_axis = view_axes{v};
    
    for side = {'front', 'back'}
        
        %% Render model and data
        [raytracing_matrix, ~, camera_center] = get_raytracing_matrix(pose.centers, radii, pose.data_bounding_box, view_axis, settings, side);
        pose = render_model(pose, blocks, radii, raytracing_matrix, camera_center, settings);
        %% Get model points
        
        [I, J] = find((pose.rendered_model(:, :, 3) > - RAND_MAX));
        N = length(pose.model_points);
        pose.model_points = [pose.model_points; cell(length(I), 1)];
        for k = 1:length(I),
            pose.model_points{N + k} = squeeze(pose.rendered_model(I(k), J(k), :));
        end
    end
    
end

[pose.model_indices, pose.model_projections, ~] = compute_projections(pose.model_points, pose.centers, blocks, radii);

pose.closest_data_points = cell(length(pose.model_points), 1);
for i = 1:length(pose.model_points)
    p = pose.model_points{i};
    index = knnsearch(pose.kdtree, p', 'K', 1);
    q = pose.points{index}; n = pose.normals{index};
    pose.closest_data_points{i} = p + (q - p)' * n * n;
    %pose.closest_data_points{i} = pose.points{index};
end

%% Display
if (display)
    display_result_convtriangles(pose, blocks, radii, false);
    %mypoints(pose.points, [1, 0.5, 0]);
    %myvectors(pose.points, pose.normals, 1, 'r');
    mypoints(pose.closest_data_points, 'm');
    mypoints(pose.model_points, 'b');
    mylines(pose.closest_data_points, pose.model_points, 'g');
    drawnow;
end


[pose, f, Jc, Jr] = compute_energy3_3D(pose, radii, blocks, D);

pose.f4 = f;
pose.Jc4 = Jc;
pose.Jr4 = Jr;
