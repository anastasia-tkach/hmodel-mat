function [data_points, model_points] = read_cpp_correspondences(path, frame_number, mean_centers)

fileID = fopen([path, 'corresp-', num2str(frame_number), '.txt'], 'r');
Q = fscanf(fileID, '%f');
Q = reshape(Q, 3, length(Q)/3);
Q = Q';
N = size(Q, 1) / 2;
data_points = {};
model_points = {};

for k = 1:N
    if any(Q(2 * (k - 1) + 1, :) == -111), continue; end
    if any(Q(2 * (k - 1) + 1, :) == 0), continue; end
    data_points{end + 1} = Q(2 * (k - 1) + 1, :)' - mean_centers;
    model_points{end + 1} = Q(2 * k, :)' - mean_centers;
end
data_points = data_points';
model_points = model_points';