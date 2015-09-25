
close all; clear;
p = 5;

%% Set the topological structure

num_blocks = 26;
num_centers = 26;
blocks = cell(num_blocks, 1);
joints = cell(num_centers, 1);
if (p == 1)
    radii = cell(num_centers, 1);
else
    load([path, 'radii.mat']);
end

blocks{1} = [1, 2]; blocks{2} = [2, 3];
blocks{3} = [3, 4]; blocks{4} = [5, 6];
blocks{5} = [6, 7]; blocks{6} = [7, 8];
blocks{7} = [9, 10]; blocks{8} = [10, 11];
blocks{9} = [11, 12]; blocks{10} = [13, 14];
blocks{11} = [14, 15]; blocks{12} = [15, 16];
blocks{13} = [17, 18]; blocks{14} = [18, 19];
blocks{15} = [19, 20]; blocks{16} = [21, 4, 8];
blocks{17} = [22, 21, 8]; blocks{18} = [22, 8, 12];
blocks{19} = [22, 12, 20]; blocks{20} = [20, 12, 16];
blocks{21} = [23, 21, 22]; blocks{22} = [24, 23, 22];
blocks{23} = [24, 22, 20]; blocks{24} = [25, 23, 26];
blocks{25} = [26, 23, 24];

joints{1} = ''; joints{2} = 'revolute'; joints{3} = 'revolute'; joints{4} = 'spherical';
joints{5} = ''; joints{6} = 'revolute'; joints{7} = 'revolute'; joints{8} = 'spherical';
joints{9} = ''; joints{10} = 'revolute'; joints{11} = 'revolute'; joints{12} = 'spherical';
joints{13} = ''; joints{14} = 'revolute'; joints{15} = 'revolute'; joints{16} = 'spherical';
joints{17} = ''; joints{18} = 'revolute'; joints{19} = 'revolute'; joints{20} = 'spherical';
joints{21} = ''; joints{22} = ''; joints{23} = ''; joints{24} = ''; joints{25} = ''; joints{26} = '';


%% Read the data

path = ['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\_data\robert_wang\'];
name = [num2str(p), '.obj'];
filename = [path, name];

if (strcmp(name(end-2:end), 'ply'))
    [V, F] = readPLY(filename);
end
if (strcmp(name(end-2:end), 'obj'))
    [V, F] = readOBJ(filename);
end
%figure; hold on; plot_mesh(V', F');
V = [V(:, 3), V(:, 1), V(:, 2)];
mesh.vertices = V;
mesh.triangles = F;
bb = bounding_box(mesh.vertices);
min_x = min(bb(:, 1)); max_x = max(bb(:, 1));
min_y = min(bb(:, 2)); max_y = max(bb(:, 2));
min_z = min(bb(:, 3)); max_z = max(bb(:, 3));

%% Uncomment this part to save the images
% figure; scatter(mesh.vertices(:, 1), mesh.vertices(:, 2), 1, [1, 0.5, 0], 'filled')
% hold on; axis equal; xlim([min_x, max_x]); ylim([min_y, max_y]); axis off; 
% set(gca,'position',[0 0 1 1],'units','normalized');
% print([path, 'frontal.png'],'-dpng'); close;
% 
% figure; scatter(mesh.vertices(:, 3), mesh.vertices(:, 2), 1, [1, 0.5, 0], 'filled')
% hold on; axis equal; xlim([min_z, max_z]); ylim([min_y, max_y]); axis off; 
% set(gca,'position',[0 0 1 1],'units','normalized');
% print([path, 'vertical.png'],'-dpng'); close;
% return;

%% To draw the initial blocks on the image with a sketch, comment the previous part

frontal = imread([path, num2str(p), '_frontal.png']);
frontal = 255 - frontal(:, :, 2);
frontal_column_indices = sum(frontal, 1) > 0;
frontal_row_indices = sum(frontal, 2) > 0;
frontal = frontal(frontal_row_indices, frontal_column_indices);
frontal = 255 - frontal;

vertical = imread([path, num2str(p), '_vertical.png']);
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

[centers, blocks, radii] = click_centers(p, radii, blocks, 0, size(vertical, 2));

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
for i = 1:size(mesh.vertices, 1)
    points{i} = mesh.vertices(i, :)';
end

save([path, num2str(p), '_points.mat'], 'points');
save([path, num2str(p), '_centers.mat'], 'centers');
if (p == 1)
    save([path, 'radii.mat'], 'radii');
	save([path, 'blocks.mat'], 'blocks');
end






