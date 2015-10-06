
close all; clear;
data_path = '_data/implicit_skinning/';
p = 3;

%% Set the topological structure
num_blocks = 29; num_centers = 30;
blocks = cell(num_blocks, 1);
if (p == 1), radii = cell(num_centers, 1);
else load([data_path, 'radii.mat']);end

blocks{1} = [1, 2]; blocks{2} = [2, 3];
blocks{3} = [3, 4]; blocks{4} = [5, 6];
blocks{5} = [6, 7]; blocks{6} = [7, 8];
blocks{7} = [9, 10]; blocks{8} = [10, 11];
blocks{9} = [11, 12]; blocks{10} = [13, 14];
blocks{11} = [14, 15]; blocks{12} = [15, 16];
blocks{13} = [17, 18]; blocks{14} = [18, 19];

blocks{15} = [19, 20, 21]; blocks{16} = [4, 22, 23];
blocks{17} = [4, 8, 22]; blocks{18} = [8, 12, 22];
blocks{19} = [12, 20, 22]; blocks{20} = [12, 16, 20];
blocks{21} = [16, 20, 21];

blocks{22} = [20, 22, 25]; blocks{23} = [22, 23, 24];
blocks{24} = [22, 24, 25]; blocks{25} = [24, 25, 27];
blocks{26} = [24, 26, 27]; blocks{27} = [4, 8, 28];
blocks{28} = [8, 12, 29]; blocks{29} = [12, 16, 30];

%% New topology
num_blocks = 38; num_centers = 49; num_solids = 8;
blocks = cell(num_blocks, 1);
solids = cell(num_solids, 1);

blocks{1} = [1, 3, 4]; blocks{2} = [3, 4, 6]; blocks{3} = [3, 5, 6]; blocks{4} = [5, 6, 7];
blocks{5} = [8, 10, 11]; blocks{6} = [10, 11, 13]; blocks{7} = [10, 12, 13]; blocks{8} = [12, 13, 14];
blocks{9} = [15, 17, 18]; blocks{10} = [17, 18, 20]; blocks{11} = [17, 19, 20]; blocks{12} = [19, 20, 21]; 
blocks{13} = [22, 24, 25]; blocks{14} = [24, 25, 27]; blocks{15} = [24, 26, 27]; blocks{16} = [26, 27, 28];
blocks{17} = [29, 31, 32]; blocks{18} = [31, 32, 34]; blocks{19} = [31, 33, 34]; blocks{20} = [33, 34, 35];

blocks{21} = [7, 36, 39]; blocks{22} = [36, 37, 39]; blocks{23} = [37, 39, 40]; blocks{24} = [37, 38, 40]; blocks{25} = [38, 40, 41]; blocks{26} = [28, 38, 41];

blocks{27} = [39, 40, 42]; blocks{28} = [40, 42, 43]; blocks{29} = [40, 41, 43]; blocks{30} = [41, 43, 44];

blocks{31} = [7, 42]; blocks{32} = [14, 49]; blocks{33} = [21, 49]; blocks{34} = [28, 44]; blocks{35} = [43, 49];

blocks{36} = [43, 45, 46]; blocks{37} = [45, 46, 48]; blocks{38} = [45, 47, 48];


solids{1} = [3, 4, 5, 6];
solids{2} = [10, 11, 12, 13];
solids{3} = [17, 18, 19, 20];
solids{4} = [24, 25, 26, 27];
solids{5} = [31, 32, 33, 34];
solids{6} = [39, 40, 42, 43];
solids{7} = [40, 41, 43, 44];
solids{8} = [45, 46, 47, 48];

%% Read the data


name = [num2str(p), '.obj'];
filename = [data_path, name];

if (strcmp(name(end-2:end), 'ply'))
    [V, F] = readPLY(filename);
end
if (strcmp(name(end-2:end), 'obj'))
    [V, F] = readOBJ(filename);
end
%figure; hold on; plot_mesh(V', F');
V = [V(:, 3), V(:, 1), V(:, 2)];
N = per_vertex_normals(V, F);
mesh.normals = N;
mesh.vertices = V;
mesh.triangles = F;
bb = bounding_box(mesh.vertices);
min_x = min(bb(:, 1)); max_x = max(bb(:, 1));
min_y = min(bb(:, 2)); max_y = max(bb(:, 2));
min_z = min(bb(:, 3)); max_z = max(bb(:, 3));

%% Uncomment this part to save the images
% figure; scatter(mesh.vertices(:, 1), mesh.vertices(:, 2), 5, [0, 0, 0], 'filled')
% hold on; axis equal; xlim([min_x, max_x]); ylim([min_y, max_y]); axis off; 
% set(gca,'position',[0 0 1 1],'units','normalized');
% print([data_path, 'frontal.png'],'-dpng'); close;
% 
% figure; scatter(mesh.vertices(:, 3), mesh.vertices(:, 2),  5, [0, 0, 0], 'filled')
% hold on; axis equal; xlim([min_z, max_z]); ylim([min_y, max_y]); axis off; 
% set(gca,'position',[0 0 1 1],'units','normalized');
% print([data_path, 'vertical.png'],'-dpng'); close;
% return;

%% To draw the initial blocks on the image with a sketch, comment the previous part

frontal = imread([data_path, num2str(p), '_frontal.png']);
frontal = 255 - rgb2gray(frontal);
frontal_column_indices = sum(frontal, 1) > 0;
frontal_row_indices = sum(frontal, 2) > 0;
frontal = frontal(frontal_row_indices, frontal_column_indices);
frontal = 255 - frontal;

vertical = imread([data_path, num2str(p), '_vertical.png']);
vertical = 255 - vertical(:, :, 2);
vertical_column_indices = sum(vertical, 1) > 0;
vertical_row_indices = sum(vertical, 2) > 0;
vertical = vertical(vertical_row_indices, vertical_column_indices);
vertical = 255 - vertical;

frontal = imresize(frontal, size(vertical, 1) / size(frontal, 1), 'bicubic');
vertical = [vertical, 255 * ones(size(vertical, 1), size(frontal, 2) - size(vertical, 2))];

%% Initialize the model

figure('units','normalized','outerposition',[0 0 1 1]);
set(gca,'position',[0 0 1 1],'units','normalized');

subplot(1, 2, 1); imshow(frontal);
hold on; axis equal tight;

subplot(1, 2, 2); imshow(vertical);
hold on; axis equal tight; 

[centers, radii] = click_centers(p, radii, 0, size(vertical, 2));

%% Rescale centers
factor = (max_y - min_y) /size(frontal, 1);
for i = 1:length(centers)
    centers{i} = centers{i} * factor;
    centers{i}(2) = size(frontal, 1) * factor  - centers{i}(2);
    centers{i} = centers{i} + [min_x; min_y; min_z];
    if (p == 1)
        radii{i} = radii{i} * factor;
    end
end

%% Display
figure; hold on; axis equal;
scatter3(mesh.vertices(:, 1), mesh.vertices(:, 2), mesh.vertices(:, 3), 1, [1, 0.5, 0], 'filled');
for i = 1:length(centers)
    mypoint(centers{i}, 'g');
end

%% Save the results
points = cell(size(mesh.vertices, 1), 1);
normals = cell(size(mesh.normals, 1), 1);
for i = 1:size(mesh.vertices, 1)
    points{i} = mesh.vertices(i, :)';
    normals{i} = mesh.normals(i, :)';
end

save([data_path, num2str(p), '_points.mat'], 'points');
save([data_path, num2str(p), '_centers.mat'], 'centers');
save([data_path, num2str(p), '_normals.mat'], 'normals');
if (p == 1)
    save([data_path, 'radii.mat'], 'radii');
	save([data_path, 'blocks.mat'], 'blocks');
    save([data_path, 'solids.mat'], 'solids');
end






