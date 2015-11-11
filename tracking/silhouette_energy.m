function [Fn, Jn] = silhouette_energy(centers, radii, blocks, points, data_bounding_box, settings)
closing_radius = 2;
D = settings.D;

%% Render model and datas
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

%display_result_convtriangles(centers, points, [], blocks, radii, true);
%mypoints(model_points, [0, 0.7, 1]);
%mypoints(closest_data_points, [0.4, 0, 0.4]);
%view([-180, -90]); camlight; drawnow;

%% Move behind the data silhouette
attachments = cell(length(centers), 1);
[F, J] = jacobian_arap_translation_attachment(centers, radii, blocks, ...
    model_points, model_indices, closest_data_points, attachments, settings.D);

normals = cell(length(model_points), 1);
for i = 1:length(model_points)
    if i == 670
        disp(' ')
    end
    m = model_points{i};
    d =  closest_data_points{i};
    if isempty(m) || isempty(d), continue; end
    q = project_point_on_line(m, d, camera_center);
    normals{i} = (q - m) / norm(q - m);
end

Fn = zeros(length(normals), 1); Jn = zeros(length(normals), D * length(centers));
for i = 1:length(normals)
    if isempty(normals{i}), continue; end
    Fn(i) = normals{i}' * F(D * (i - 1) + 1:D * i);
    Jn(i, :) = normals{i}' * J(D * (i - 1) + 1:D * i, :);
end