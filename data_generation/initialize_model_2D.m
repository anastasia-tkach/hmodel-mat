
close all; clear;
p = 1;

%% Set the topological structure
path = ['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HModel\_data\silhouettes_2D\'];
name = 'convsegment';
switch name
    case 'dolphin'
        filename = 'dolphin.png';
        num_blocks = 14;
        num_centers = 15;
        blocks = cell(num_blocks, 1);
        blocks{1} = [1, 2]; blocks{2} = [2, 3]; blocks{3} = [3, 4]; blocks{4} = [4, 5];
        blocks{5} = [5, 6]; blocks{6} = [6, 7];  blocks{7} = [6, 8]; blocks{8} = [7, 9];
        blocks{9} = [8, 10]; blocks{10} = [4, 14]; blocks{11} = [14, 15];
        blocks{12} = [3, 11]; blocks{13} = [11, 12]; blocks{14} = [12, 13];
    case 'convsegment'
        filename = 'convsegment.png';
        num_blocks = 1;
        num_centers = 2;
        blocks = cell(num_blocks, 1);
        blocks{1} = [1, 2];
end


joints = cell(num_centers, 1);
if (p == 1)
    radii = cell(num_centers, 1);
else
    load([path, 'radii.mat']);
end

%% Read the data

silhouette = rgb2gray(imread([path, filename]));
silhouette = imresize(silhouette, 0.3);
silhouette = 255 - silhouette;
column_indices = sum(silhouette, 1) > 0;
row_indices = sum(silhouette, 2) > 0;
silhouette = silhouette(row_indices, column_indices);
silhouette = 255 - silhouette;

binary_mask = zeros(size(silhouette));
binary_mask(silhouette < 255) = 1;
boundary_indices = bwboundaries(binary_mask);
boundary_indices = boundary_indices{1};
points = cell(length(boundary_indices), 1);
for i = 1:length(boundary_indices)
    points{i} = [boundary_indices(i, 2); boundary_indices(i, 1)];
end

%% Initialize the model

figure('units','normalized','outerposition',[0 0 1 1]);
set(gca,'position',[0 0 1 1],'units','normalized');
imshow(silhouette);
hold on; axis equal tight;
centers = cell(length(radii), 1);
for k = 1:length(centers)
    [x, y] = ginput(1);
    centers{k} = [x; y];
    hold on; mypoint(centers{k}, 'm');
    if (p == 1)
        [xr, yr] = ginput(1);
        r = norm([x - xr, y - yr]);
        radii{k} = r;
        draw_circle(centers{k}, radii{k}, [1, 0.7, 0]);
    end
end

%% Display
figure; hold on; axis equal;
mypoints(points, 'k');
for i = 1:length(centers)
    mypoint(centers{i}, 'g');
end

%% Save the results
save([path, num2str(p), '_points.mat'], 'points');
save([path, num2str(p), '_centers.mat'], 'centers');
if (p == 1)
    save([path, 'radii.mat'], 'radii');
    save([path, 'blocks.mat'], 'blocks');
end






