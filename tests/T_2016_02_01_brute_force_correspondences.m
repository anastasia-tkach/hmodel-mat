clc;
D = 3;

%% Hand model
input_path = '_my_hand/tracking_initialization/';
semantics_path = '_my_hand/semantics/';
load([input_path, 'centers.mat']); load([input_path, 'radii.mat']);
load([semantics_path, 'tracking/blocks.mat']); [blocks] = reindex(radii, blocks);
load([semantics_path, 'palm_blocks.mat']);
load([semantics_path, 'fingers_blocks.mat']);
load([semantics_path, 'fingers_base_centers.mat']);
blocks = palm_blocks;
blocks = reindex(radii, blocks);

settings.fov = 15; downscaling_factor = 1;
settings.H = 480/downscaling_factor;
settings.W = 640/downscaling_factor;
settings.D = D; settings.RAND_MAX = 32767;
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
% display_result(centers, [], [], blocks, radii, true, 0.6, 'big');
% mypoints(tentative_points, 'm');

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

display_result(centers, data_points, model_points, blocks, radii, true, 0.6, 'big');
mypoints(computed_points, 'w');
mylines(data_points, computed_points, 'y');
view([-180, -90]); camlight;