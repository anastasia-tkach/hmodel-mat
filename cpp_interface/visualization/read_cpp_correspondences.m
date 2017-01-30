function [data_points, model_points] = read_cpp_correspondences(path, mean_centers, frame_number)

%% Data points
fileID = fopen([path, 'correspondences_data_points-', num2str(frame_number), '.txt'], 'r');
P = fscanf(fileID, '%f');
P = reshape(P, 3, length(P)/3);
P = P';
N = size(P, 1);
data_points = {};


for k = 1:N
    if any(P(k, :) == 0), continue; end
    data_points{end + 1} = P(k, :)' - mean_centers;
end
data_points = data_points';


%% Model points
fileID = fopen([path, 'correspondences_model_points-', num2str(frame_number), '.txt'], 'r');
P = fscanf(fileID, '%f');
P = reshape(P, 3, length(P)/3);
P = P';
N = size(P, 1);
 
model_points = {};
for k = 1:N
    if any(P(k, :) == 0), continue; end
    model_points{end + 1} = P(k, :)' - mean_centers;
end
model_points = model_points';