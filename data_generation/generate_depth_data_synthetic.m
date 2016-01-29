function [data_points] = generate_depth_data_synthetic(centers, radii, blocks)

D = 3; 
settings.fov = 15;
downscaling_factor = 10;
settings.H = 480/downscaling_factor;
settings.W = 640/downscaling_factor;
settings.D = D;
settings.sparse_data = false;
settings.RAND_MAX = 32767;
settings.side = 'front';
settings.view_axis = 'Z';


%% Shift the data w.r.t. model
rotation_axis = randn(D, 1);
rotation_angle = 0.2 * randn;
% hand model
translation_vector = 10 + 0.5 * rand * [0; 0; 1];
% syntetic
% translation_vector = 0.5 * rand * [0; 0; 1];
R = makehgtform('axisrotate', rotation_axis, rotation_angle);
T = makehgtform('translate', translation_vector);
for i = 1:length(centers)
    centers{i} = transform(centers{i}, R);
    centers{i} = transform(centers{i}, T);
end

%% Render the data
data_bounding_box = compute_model_bounding_box(centers, radii);

[raytracing_matrix, ~, camera_center] = get_raytracing_matrix(centers, radii, data_bounding_box, settings.view_axis, settings, settings.side);
[rendered_model, I] = render_tracking_model(centers, blocks, radii, raytracing_matrix, camera_center, settings);

[I, J] = find((rendered_model(:, :, 3) > - settings.RAND_MAX));

data_points  = cell(length(I), 1);
for k = 1:length(I),
    data_points{k} = squeeze(rendered_model(I(k), J(k), :));
end

