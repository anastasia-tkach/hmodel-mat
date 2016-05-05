function [pose] = compute_energy4_realsense(pose, radii, blocks, settings, display)

D = settings.D;
centers = pose.centers;
points = pose.points;
data_bounding_box = pose.data_bounding_box;

closing_radius = 2;
dialation_radius = 2;

%% Render model and data
[raytracing_matrix, camera_axis, camera_center] = ...
    get_raytracing_matrix(centers, radii, data_bounding_box, settings.view_axis, settings, settings.side);

[rendered_data, back_map_for_rendered_data, P] = ...
    render_tracking_data(points, camera_axis, camera_center, settings.view_axis, closing_radius, dialation_radius, settings);

rendered_model = render_tracking_model(centers, blocks, radii, raytracing_matrix, camera_center, settings);

[I, J] = find((rendered_model(:, :, 3) > - settings.RAND_MAX) & (rendered_data == 0));
model_points = cell(length(I), 1);
for k = 1:length(I), model_points{k} = squeeze(rendered_model(I(k), J(k), :)); end

[model_indices, ~, block_indices] = compute_projections(model_points, centers, blocks, radii);

[closest_data_points, model_points_2D, data_points_2D] = find_silhouette_constraints(model_points, back_map_for_rendered_data, rendered_data, P, settings.view_axis);

%% Compute camera ray normals
camera_ray_normals = cell(length(model_points), 1);
for i = 1:length(model_points)
    m = model_points{i};
    d =  closest_data_points{i};
    if isempty(m) || isempty(d), continue; end
    q = project_point_on_line(m, d, camera_center);
    camera_ray_normals{i} = (q - m) / norm(q - m);
end

%% Compute Jacobian
[f, Jc, Jr] = jacobian_realsense(centers, radii, blocks, model_points, model_indices, block_indices, closest_data_points, settings, 'point_to_point');

[fn, Jcn, Jrn] = compute_normal_distance(centers, camera_ray_normals, f, Jc, Jr, settings.D);
pose.f4 = fn; pose.Jc4 = Jcn; pose.Jr4 = Jrn;

%% Display
if (display)
    
    %% 2D  
    %{
    rendered_intersection = zeros(size(rendered_model));
    rendered_intersection(:, :, 3) = (rendered_model(:, :, 3) > -settings.RAND_MAX);
    rendered_intersection(:, :, 1) = rendered_data;
    figure; imshow(rendered_intersection); hold on;
    mypoints(model_points_2D, [0, 0.7, 1]);
    mypoints(data_points_2D, [1, 0.7, 0.1]);   
    %}
    %% 3D
    correspondences = cell(length(closest_data_points));
    for i = 1:length(model_points)
        if isempty(camera_ray_normals{i}) || isempty(model_points{i}), continue; end
        if (fn(i) == 0), continue; end
        correspondences{i} = model_points{i} + fn(i) * camera_ray_normals{i};
    end
    
    camera_directions = cell(length(model_points), 1);
    for i = 1:length(model_points)
        if isempty(model_points{i}), continue; end
        camera_directions{i} = camera_center - model_points{i};
        camera_directions{i} = camera_directions{i} / norm(camera_directions{i});
    end
    
    display_result(centers, points, [], blocks, radii, true, 0.5, 'big');
    mypoints(model_points, 'y');
    mypoints(correspondences, 'k');
    mylines(model_points, correspondences, 'r');
    myvectors(correspondences, camera_directions, 5, 'c');
    view([-180, -90]); camlight; drawnow;
end

