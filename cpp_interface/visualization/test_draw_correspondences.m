clc; clear; close all;
RAND_MAX = 32767;
camera_ray = [0; 0; 1];
path = 'C:\Developer\hmodel-cuda-build\data\';

%% Read centers
fileID = fopen([path, '_C.txt'], 'r');
C = fscanf(fileID, '%f');
C = C(2:end);
C = reshape(C, 3, length(C)/3);
centers = cell(0, 1);
mean_centers = [0; 0; 0];
for i = 1:size(C, 2);
    centers{end + 1} = C(:, i);
    mean_centers = mean_centers + centers{end};
end
mean_centers = mean_centers ./ length(centers);
for i = 1:length(centers)
    centers{i} = centers{i} - mean_centers;
end
%% Read radii
fileID = fopen([path, '_R.txt'], 'r');
R = fscanf(fileID, '%f');
R = R(2:end);
radii = cell(0, 1);
for i = 1:length(R);
    radii{end + 1} = R(i);
end
%% Read blocks
fileID = fopen([path, '_B.txt'], 'r');
B = fscanf(fileID, '%f');
B = B(2:end);
B = reshape(B, 3, length(B)/3);
blocks = cell(0, 1);
for i = 1:size(B, 2);
    if B(3, i) == RAND_MAX
        blocks{end + 1} = B(1:2, i) + 1;
    else
        blocks{end + 1} = B(:, i) + 1;
    end
end
blocks = reindex(radii, blocks);

%% Read correspondences
fileID = fopen([path, '_M.txt'], 'r');
Q = fscanf(fileID, '%f');
Q = reshape(Q, 3, length(Q)/3);
Q = Q';
N = size(Q, 1) / 2;
cpp_data_points = {};
cpp_model_points = {};

for k = 1:N
    if any(Q(2 * (k - 1) + 1, :) == -111), continue; end
    if any(Q(2 * (k - 1) + 1, :) == 0), continue; end
    cpp_data_points{end + 1} = Q(2 * (k - 1) + 1, :)' - mean_centers;
    cpp_model_points{end + 1} = Q(2 * k, :)' - mean_centers;
end
cpp_data_points = cpp_data_points';
cpp_model_points = cpp_model_points';
%display_result(centers, cpp_data_points, cpp_model_points, blocks, radii, false, 0.7, 'big');
figure; hold on; axis off; axis equal;
mypoints(cpp_data_points, 'm');
%mypoints(cpp_model_points, 'b');
view([-180, -90]); camlight;