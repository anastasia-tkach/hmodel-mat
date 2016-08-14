%clc; clear; close all;
RAND_MAX = 32767;
camera_ray = [0; 0; 1];
input_path = 'E:/Data/msr_comparison/';


%% Continious correspondences
frame = 2345;
%{
[centers, radii, blocks, ~, ~, mean_centers] = read_cpp_model(input_path, frame);
display_result(centers, [], [], blocks, radii, true, 0.7, 'big');
mypoints(continuous_model_points, 'b');
mean_centers = [0; 0; 0];
[data_points, continuous_model_points] = read_cpp_correspondences(input_path, frame, mean_centers);
%}


%% Load data
filename = [input_path, 'Depth/depth-', sprintf('%07d', frame), '.png']; D = imread(filename);
filename = [input_path, 'Mask/mask-', sprintf('%07d', frame), '.png']; M = imread(filename);

%% Load rastorized model
%filename = [input_path, 'Tkach_2016/model-', sprintf('%07d', frame), '.png']; Q = imread(filename);
%filename = [input_path, 'Taylor_Cropped/model-', sprintf('%07d', frame), '.png']; Q = imread(filename);
%filename = [input_path, 'Sharp_Cropped/model-', sprintf('%07d', frame), '.png']; Q = imread(filename);

%filename = [input_path, 'Taylor_2016/', num2str(frame), '-Rendered depth---image.png']; Q = imread(filename);
%filename = [input_path, 'Sharp_2015/', num2str(frame), '-Rendered depth---image.png']; Q = imread(filename);


D(M == 0) = 0;
iproj = [0.00348117, 0, -0.556987; 0, 0.00348117, -0.41774; 0, 0, 1];
height = 240;
width = 320;

%% Get data points
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

%% Get model points
rastorized_model_points = {};
for i = 1:height
    for j = 1:width
        if Q(height - i + 1, j)  < 5000
            depth = double(Q(height - i + 1, j));
            uvd = [(j - 1) * depth; (i - 1) * depth; depth];
            rastorized_model_points{end + 1} = iproj * uvd;
        end
    end
end

%% Compute the metrics
[E_rastorized, E_continuous, closest_model_points] = compute_rastorized_E3D_metric(data_points, rastorized_model_points, []);
disp(E_rastorized);
figure; hold on; axis off; axis equal;
mypoints(data_points,  [0.7, 0.0, 0.3]);
mypoints(closest_model_points,  [0, 0.7, 1]);
mylines(closest_model_points, data_points, [0.75, 0.75, 0.75]);

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

%view([-180, -90]); camlight;
