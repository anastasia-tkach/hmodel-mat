function [Fn, Jn, model_points] = silhouette_energy(centers, radii, blocks, points, data_bounding_box, settings)
closing_radius = 2;
D = settings.D;

%% Render model and data
[raytracing_matrix, camera_axis, camera_center] = ...
    get_raytracing_matrix(centers, radii, data_bounding_box, settings.view_axis, settings, settings.side);

[rendered_data, back_map_for_rendered_data, P] = ...
    render_tracking_data(points, camera_axis, camera_center, settings.view_axis, closing_radius, settings);

rendered_model = render_tracking_model(centers, blocks, radii, raytracing_matrix, camera_center, settings);

[I, J] = find((rendered_model(:, :, 3) > - settings.RAND_MAX) & (rendered_data == 0));
model_points = cell(length(I), 1);
for k = 1:length(I), model_points{k} = squeeze(rendered_model(I(k), J(k), :)); end

[model_indices, ~, ~] = compute_projections(model_points, centers, blocks, radii);

[closest_data_points, model_points_2D, data_points_2D] = find_silhouette_constraints(model_points, back_map_for_rendered_data, rendered_data, P, settings.view_axis);

%% Display
% rendered_intersection = zeros(size(rendered_model));
% rendered_intersection(:, :, 3) = (rendered_model(:, :, 3) > -settings.RAND_MAX);
% rendered_intersection(:, :, 1) = rendered_data;
% figure; imshow(rendered_intersection); hold on;
% mypoints(model_points_2D, [0, 0.7, 1]);
% mypoints(data_points_2D, [1, 0.7, 0.1]);

%% Move behind the data silhouette
attachments = cell(length(centers), 1);
[F, J] = jacobian_arap_translation_attachment(centers, radii, blocks, ...
    model_points, model_indices, closest_data_points, attachments, settings.D);

normals = cell(length(model_points), 1);
for i = 1:length(model_points)
    m = model_points{i};
    d =  closest_data_points{i};
    if isempty(m) || isempty(d), continue; end
    q = project_point_on_line(m, d, camera_center);
    normals{i} = (q - m) / norm(q - m);
end

%% Normal distance
[Fn, Jn, ~] = compute_normal_distance(centers, normals, F, J, [], D);

%% Display

if ~settings.verbose, return; end

correspondences = cell(length(closest_data_points));
for i = 1:length(model_points)
    if isempty(normals{i}) || isempty(model_points{i}), continue; end
    correspondences{i} = model_points{i} + Fn(i) * normals{i};
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
mypoints(closest_data_points, [0.4, 0, 0.4]);
mylines(closest_data_points, model_points, 'g');
mylines(model_points, correspondences, 'r');
myvectors(closest_data_points, camera_directions, 5, 'c');
myvectors(correspondences, camera_directions, 5, 'c');
view([-180, -90]); camlight; drawnow;

