clear
data_path = '_data/htrack_model/silhouette/';

mode = 'hand';
settings.fov = 15;
downscaling_factor = 3;
settings.H = 480/downscaling_factor;
settings.W = 636/downscaling_factor;
settings.D = 3;
settings.sparse_data = false;
settings.RAND_MAX = 32767;
side = 'front'; view_axis = 'Z';
closing_radius = 10;

%% Get model
segments = create_ik_model(mode);

[centers, radii, blocks, solid_blocks, attachments] = make_convolution_model(segments, mode);
display_result_convtriangles(centers, [], [], blocks, radii, true); campos([10, 160, -1500]); camlight;

%% Save data
save([data_path, 'solid_blocks.mat'], 'solid_blocks');
save([data_path, 'centers.mat'], 'centers');
save([data_path, 'radii.mat'], 'radii');
save([data_path, 'blocks.mat'], 'blocks');
save([data_path, 'attachments.mat'], 'attachments');
model_centers = centers;

%% Create posed data
theta = zeros(26, 1);
theta(1) = 70;
theta(2) = -40;
%theta([9, 13, 17, 21, 25]) = -pi/4;
%theta(1) = 0; theta(3) = 0; theta(4:5) = pi/9;
%theta(24:26) = -pi/6; 
%theta(16:18) = -pi/6;
%theta(6) = pi/50;

[segments, joints] = pose_ik_model(segments, theta, false, mode);
[centers, radii, blocks, solid_blocks, attachments] = make_convolution_model(segments, mode);

data_bounding_box = compute_model_bounding_box(centers, radii);
[raytracing_matrix, camera_axis, camera_center] = get_raytracing_matrix(centers, radii, data_bounding_box, view_axis, settings, side);       
rendered_model = render_tracking_model(centers, blocks, radii, raytracing_matrix, camera_center, settings);
[I, J] = find(rendered_model(:, :, 3) > - settings.RAND_MAX);
points = cell(length(I), 1);
for k = 1:length(I), points{k} = squeeze(rendered_model(I(k), J(k), :)); end

save([data_path, 'points.mat'], 'points');

%% Display
display_result_convtriangles(model_centers, [], [], blocks, radii, false);
mypoints(points, 'm');
view([-180, -90]); camlight;

