clc; clear; close all;
RAND_MAX = 32767;
camera_ray = [0; 0; 1];
path = 'C:\Users\tkach\Desktop\Correspondences\';
frame_number = 0;

[centers, radii, blocks, ~, ~, mean_centers] = read_cpp_model(path, frame_number);
%mean_centers = [0; -70; 400];
[data_points, model_points] = read_cpp_correspondences(path, mean_centers, frame_number);

display_result(centers, data_points, model_points, blocks, radii, true, 1, 'big');
% figure; hold on; axis off; axis equal;
% mypoints(data_points, 'm');
% mypoints(model_points, 'b');
view([-180, -90]); camlight;