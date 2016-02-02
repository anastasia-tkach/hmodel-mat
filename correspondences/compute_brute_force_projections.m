function [model_points] = compute_brute_force_projections(centers, radii, blocks, data_points)

settings.fov = 15; downscaling_factor = 2;
settings.H = 480/downscaling_factor;
settings.W = 640/downscaling_factor;
settings.D = 3; settings.RAND_MAX = 32767;
settings.side = 'front'; settings.view_axis = 'Z';


%% Render the data
data_bounding_box = compute_model_bounding_box(centers, radii);
[raytracing_matrix, ~, camera_center] = get_raytracing_matrix(centers, radii, data_bounding_box, settings.view_axis, settings, settings.side);
[rendered_model, ~] = render_tracking_model(centers, blocks, radii, raytracing_matrix, camera_center, settings);
[I, J] = find((rendered_model(:, :, 3) > - settings.RAND_MAX));
tentative_points  = cell(length(I), 1);
for k = 1:length(I),
    tentative_points{k} = squeeze(rendered_model(I(k), J(k), :));
end

%% Compute the closest point
model_points = cell(length(data_points), 1);
for i = 1:length(data_points)
    min_distance = Inf;
    for j = 1:length(tentative_points)
        distance = norm(data_points{i} - tentative_points{j});
        if distance < min_distance
            min_distance = distance;
            model_points{i} = tentative_points{j};
        end
    end
end
