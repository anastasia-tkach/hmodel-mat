RAND_MAX = 32767;
path = 'C:\Developer\hmodel-cuda-build\data\';

%% Read centers
fileID = fopen([path, '_C.txt'], 'r');
C = fscanf(fileID, '%f');
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
radii = cell(0, 1);
for i = 1:length(R);
    radii{end + 1} = R(i);
end
%% Read blocks
fileID = fopen([path, '_B.txt'], 'r');
B = fscanf(fileID, '%f');
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
fileID = fopen([path, '_Q.txt'], 'r');
Q = fscanf(fileID, '%f');
Q = reshape(Q, 3, length(Q)/3);
data_points = cell(0, 1);
model_points = cell(0, 1);
for i = 1:2:size(Q, 2);
    if all(Q(:, i) == [0; 0; 0]) || all(Q(:, i + 1) == [0; 0; 0]) 
        continue; 
    end
    data_points{end + 1} = Q(:, i) - mean_centers;
    model_points{end + 1} = Q(:, i + 1) - mean_centers;
end

%% Display
display_result(centers, data_points, model_points, blocks, radii, true, 0.8, 'big');
view([-180, -90]); camlight;