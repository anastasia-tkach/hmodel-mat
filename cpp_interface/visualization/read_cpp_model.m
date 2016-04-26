function [centers, radii, blocks, theta, mean_centers] = read_cpp_model(path)

RAND_MAX = 32767;

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

%% Read theta
if exist([path, '_T.txt'], 'file')
    fileID = fopen([path, '_T.txt'], 'r');
    T = fscanf(fileID, '%f');
    T = T(2:end);
    theta = zeros(length(T), 1);
    for i = 1:length(T);
        theta(i) = T(i);
    end
else
    disp('no thetas in the folder');
    theta = zeros(29, 1);
end