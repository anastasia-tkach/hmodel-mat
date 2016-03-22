clc; clear; close all;
RAND_MAX = 32767;
camera_ray = [0; 0; 1];
path = 'C:\Developer\hmodel-cuda-build\data\';
path = 'C:\Users\tkach\OneDrive\EPFL\Code\HModel\cpp_interface\retarget_pca\';

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

display_result(centers, [], [], blocks, radii, false, 1, 'big');
return;

%% Read cpp outline;
fileID = fopen([path, 'O.txt'], 'r');
O = fscanf(fileID, '%f');
N = length(O)/3;
O = reshape(O, 3, N)';
cpp_outline = cell(N/3, 1);
for i = 1:N/3
    cpp_outline{i}.start = O(3 * (i - 1) + 1, :)' - mean_centers;
    cpp_outline{i}.end = O(3 * (i - 1) + 2, :)' - mean_centers;
    cpp_outline{i}.indices = O(3 * i, :);   
    if cpp_outline{i}.indices(2) == RAND_MAX
        cpp_outline{i}.indices = cpp_outline{i}.indices(1) + 1;        
    else
        cpp_outline{i}.indices = cpp_outline{i}.indices(1:2) + 1;
    end
    cpp_outline{i}.block = O(3 * i, 3) + 1;  
end
figure; hold on; axis off; axis equal;
for i = 1:length(cpp_outline)
    if length(cpp_outline{i}.indices) == 2
        myline(cpp_outline{i}.start, cpp_outline{i}.end, 'm');
    else
        draw_circle_sector_in_plane(centers{cpp_outline{i}.indices}, radii{cpp_outline{i}.indices}, camera_ray, cpp_outline{i}.start, cpp_outline{i}.end, 'm');
    end
end

%% Compute matlab outline
[final_outline] = find_model_outline(centers, radii, blocks, [], [], [], camera_ray, [], false, false);

figure; hold on; axis off; axis equal;
for i = 1:length(final_outline)
    if length(final_outline{i}.indices) == 2
        myline(final_outline{i}.start, final_outline{i}.end, 'b');
    else
        draw_circle_sector_in_plane(centers{final_outline{i}.indices}, radii{final_outline{i}.indices}, camera_ray, final_outline{i}.start, final_outline{i}.end, 'b');
    end
end

%% Read htrack correspondences
fileID = fopen([path, '_Q.txt'], 'r');
Q = fscanf(fileID, '%f');
Q = reshape(Q, 3, length(Q)/3);
data_points = cell(0, 1);
htrack_points = cell(0, 1);
hmodel_points = cell(0, 1);
for i = 1:2:size(Q, 2);
    if all(Q(:, i) == [0; 0; 0]) || all(Q(:, i + 1) == [0; 0; 0]) 
        continue; 
    end
    if all(Q(:, i) == [-111; -111; -111]) || all(Q(:, i + 1) == [-111; -111; -111]) 
        continue; 
    end
    data_points{end + 1} = Q(:, i) - mean_centers;
    htrack_points{end + 1} = Q(:, i + 1) - mean_centers;
end
display_result(centers, data_points, htrack_points, blocks, radii, true, 0.8, 'big');
view([-180, -90]); camlight;

%% Read hmodel correspondences
fileID = fopen([path, '_M.txt'], 'r');
M = fscanf(fileID, '%f');
M = reshape(M, 3, length(M)/3);
mdata_points = cell(0, 1);
hmodel_points = cell(0, 1);
for i = 1:2:size(M, 2);
    if all(M(:, i) == [0; 0; 0]) || all(M(:, i + 1) == [0; 0; 0]) 
        continue; 
    end
    if all(M(:, i) == [-111; -111; -111]) || all(M(:, i + 1) == [-111; -111; -111]) 
        continue; 
    end
    mdata_points{end + 1} = M(:, i) - mean_centers;
    hmodel_points{end + 1} = M(:, i + 1) - mean_centers;
end
display_result(centers, mdata_points, hmodel_points, blocks, radii, true, 0.8, 'big');
view([-180, -90]); camlight;


%% Print outlines
return
for i = 1:min(length(cpp_outline), length(final_outline))
    disp(['outline[', num2str(i - 1), ']']);    
    disp(['   indices = ' num2str(final_outline{i}.indices)]);
    disp(['   indices = ' num2str(cpp_outline{i}.indices)]);
    disp(['   start = ' num2str(final_outline{i}.start')]);
    disp(['   start = ' num2str(cpp_outline{i}.start')]);
    disp(['   end = ' num2str(final_outline{i}.end')]);
    disp(['   end = ' num2str(cpp_outline{i}.end')]);
    disp(['   block = ' num2str(final_outline{i}.block)]);
    disp(['   block = ' num2str(cpp_outline{i}.block)]);
    if final_outline{i}.block ~= cpp_outline{i}.block
        disp('diffent blocks');
    end
    disp(' ');
end