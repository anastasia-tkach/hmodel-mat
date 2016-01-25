function [centers, radii, M, scaling] = align_restpose_hmodel_with_htrack(centers, radii, blocks, names_map, num_parameters)

D = 3;
verbose = false;

sensor_path = 'C:/Users/tkach/Desktop/training/';
output_path = '_my_hand/tracking_initialization/';

[beta, ~] = load_htrack_data(sensor_path, output_path, 1, D);
theta = zeros(num_parameters, 1); gamma = beta;
for i = 1:length(beta)/D, gamma(D * (i - 1) + 1:D * i) = beta(D * (i - 1) + 1:D * i) - beta(1:3); end
segments = create_ik_model('hand');
[segments, ~] = pose_ik_model(segments, theta, verbose, 'hand');
[htrack_centers, ~, ~, ~, ~] = make_convolution_model(segments, 'hand');
[centers, radii, M, scaling] = find_htrack_hmodel_transformation(centers, radii, blocks, gamma, names_map, verbose, D);
key_points_names = {'palm_pinky', 'palm_ring', 'palm_middle', 'palm_index', 'palm_back', 'palm_attachment', 'palm_right', 'palm_back', 'palm_left'};
[centers, ~] = aling_htrack_hmodel_frames(centers, radii, blocks, theta, htrack_centers, names_map, key_points_names, verbose, D);