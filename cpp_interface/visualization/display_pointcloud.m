%clc; clear; close all;
RAND_MAX = 32767;
camera_ray = [0; 0; 1];
frame = 3;

%% Load rastorized model

filename = ['E:\Data\sensor-sequences\teaser_short\depth-', sprintf('%07d', frame), '.png'];
%filename = 'C:/Users/tkach/Desktop/color.png';
Q = imread(filename);


%D(M == 0) = 0;
iproj = [0.00348117, 0, -0.556987; 0, 0.00348117, -0.41774; 0, 0, 1];
height = 240;
width = 320;


%% Get model points
model_points = {};
for i = 1:height
    for j = 1:width
        if Q(height - i + 1, j)  < 5000
            depth = double(Q(height - i + 1, j));
            uvd = [(j - 1) * depth; (i - 1) * depth; depth];
            model_points{end + 1} = iproj * uvd;
        end
    end
end

%% Display
figure; hold on; axis off; axis equal;
mypoints(model_points,  [0, 0.7, 1], 5);

