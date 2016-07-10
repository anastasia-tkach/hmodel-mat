%clc; clear; close all;
RAND_MAX = 32767;
camera_ray = [0; 0; 1];
path = 'C:\Users\tkach\Desktop\';

[centers, radii, blocks, ~, ~, mean_centers] = read_cpp_model(path);
[data_points, model_points] = read_cpp_correspondences(path, mean_centers);

%display_result(centers, data_points, model_points, blocks, radii, true, 0.7, 'big');
figure; hold on; axis off; axis equal;
mypoints(data_points, 'm');
mypoints(model_points, 'b');
view([-180, -90]); camlight;