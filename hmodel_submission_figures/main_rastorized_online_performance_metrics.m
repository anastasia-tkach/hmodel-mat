clc; clear; close all;
RAND_MAX = 32767;
camera_ray = [0; 0; 1];
input_path = 'C:/Users/tkach/Desktop/Rastorization/Figure11/calib4/';


%% Cpp correspondences
frame = 390;

% [centers, radii, blocks, ~, ~, mean_centers] = read_cpp_model(input_path, frame);
% display_result(centers, [], [], blocks, radii, true, 0.7, 'big');
% mypoints(continuous_model_points, 'b');

mean_centers = [0; 0; 0];
%[data_points, continuous_model_points] = read_cpp_correspondences(input_path, frame, mean_centers);


%% Rastorized corresondences

filename = [input_path, 'depth-', sprintf('%07d', frame), '.png']; D = imread(filename);
filename = [input_path, 'mask-', sprintf('%07d', frame), '.png']; M = imread(filename);
D(M == 0) = 0;
iproj = [0.00348117, 0, -0.556987; 0, 0.00348117, -0.41774; 0, 0, 1];
height = 240;
width = 320;


data_points = {};
for i = 1:height
    for j = 1:width
        if D(height - i + 1, j)  ~= 0
            depth = double(D(height - i + 1, j));
            uvd = [(j - 1) * depth; (i - 1) * depth; depth];
            data_points{end + 1} = iproj * uvd;
        end
    end
end

filename = [input_path, 'model-', sprintf('%07d', frame), '.png']; Q = imread(filename);
rastorized_model_points = {};
for i = 1:height
    for j = 1:width
        if Q(height - i + 1, j)  < RAND_MAX
            depth = double(Q(height - i + 1, j));
            uvd = [(j - 1) * depth; (i - 1) * depth; depth];
            rastorized_model_points{end + 1} = iproj * uvd;
        end
    end
end

%% Read model
%[E_rastorized, E_continuous, rastorized_model_points] = compute_rastorized_E3D_metric(data_points, rastorized_model_points, continuous_model_points);
figure; hold on; axis off; axis equal;
%mypoints(data_points, 'k');
%mypoints(continuous_model_points, 'b');
mypoints(rastorized_model_points,  [0, 0.7, 1]);
%mylines(rastorized_model_points, continuous_model_points, [0.75, 0.75, 0.75]);

%{
for i = 1:length(data_points)
    if norm(rastorized_model_points{i} - continuous_model_points{i}) > 3
        Dc = norm(data_points{i} - continuous_model_points{i});
        Dr = norm(data_points{i} - rastorized_model_points{i});
        %if Dc > Dr
            mypoint(data_points{i}, 'k');
            myline(data_points{i}, continuous_model_points{i}, [0.75, 0, 0.75]);
            myline(data_points{i}, rastorized_model_points{i}, [0, 0.75, 0.75]);
        %end
    end
end
%}

view([-180, -90]); camlight;
