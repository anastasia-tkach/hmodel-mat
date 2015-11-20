function [silhouette_data_points, silhouette_model_points, silhouette_data_normals, silhouette_model_indices, silhouette_block_indices] = ...
    compute_silhouette_projections(centers, blocks, radii, points, data_bounding_box, settings)

closing_radius = 2;

%% Render model and datas
[raytracing_matrix, camera_axis, camera_center] = ...
    get_raytracing_matrix(centers, radii, data_bounding_box, settings.view_axis, settings, settings.side);
[rendered_data, back_map_for_rendered_data, P] = ...
    render_tracking_data(points, camera_axis, camera_center, settings.view_axis, closing_radius, settings);

rendered_model = render_tracking_model(centers, blocks, radii, raytracing_matrix, camera_center, settings);

%% Find silhouette model points
[I, J] = find((rendered_model(:, :, 3) > - settings.RAND_MAX) & (rendered_data == 0));
silhouette_model_points = cell(length(I), 1);
for k = 1:length(I), silhouette_model_points{k} = squeeze(rendered_model(I(k), J(k), :)); end

[silhouette_model_indices, ~, silhouette_block_indices] = compute_projections(silhouette_model_points, centers, blocks, radii);

%% Find closest data points
[silhouette_data_points, model_points_2D, data_points_2D] = find_silhouette_constraints(silhouette_model_points, back_map_for_rendered_data, rendered_data, P, settings.view_axis);

%% Compute silhouette_data_normals
silhouette_data_normals = cell(length(silhouette_model_points), 1);
for i = 1:length(silhouette_model_points)
    m = silhouette_model_points{i};
    d =  silhouette_data_points{i};
    if isempty(m) || isempty(d), continue; end
    q = project_point_on_line(m, d, camera_center);
    silhouette_data_normals{i} = (q - m) / norm(q - m);
end