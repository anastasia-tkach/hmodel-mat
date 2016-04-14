clc; clear; close all;
RAND_MAX = 32767;
camera_ray = [0; 0; 1];
path = 'C:\Developer\hmodel-cuda-build\data\';

[centers, radii, blocks, theta, mean_centers] = read_cpp_model(path);
[data_points, model_points] = read_cpp_correspondences(path, mean_centers);

display_result(centers, data_points, model_points, blocks, radii, true, 0.7, 'big');
%figure; hold on; axis off; axis equal;
%mypoints(cpp_data_points, 'm');
%mypoints(cpp_model_points, 'b');
view([-180, -90]); camlight;