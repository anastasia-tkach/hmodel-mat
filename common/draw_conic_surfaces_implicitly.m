function [] = draw_conic_surfaces_implicitly(block, centers, radii, color)

% clc; clear; close all;
% path = ['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\data\convtriangles\'];
% load([path, 'radii']);
% load([path, 'blocks']);
% load([path, 'centers']);
% pose.centers = centers;
% block = blocks{1};
% color = 'c';

n = 40;

[min_x, min_y, min_z, max_x, max_y, max_z] = compute_bounding_box(centers, radii);
xm = linspace(min_x, max_x, n);
ym = linspace(min_y, max_y, n);
zm = linspace(min_z, max_z, n);
[x, y, z] = meshgrid(xm,ym,zm);
N = numel(x);
c1 = centers{block(1)}; c2 = centers{block(2)};
r1 = radii{block(1)}; r2 = radii{block(2)};

% figure('units','normalized','outerposition',[0 0 1 1]); hold on;
% draw_convsegment(block, centers, radii, color);
% for i = 1:500
%     p = [min_x + rand * (max_x - min_x); min_y + rand * (max_y - min_y); min_z + rand * (max_z - min_z)];
%     [index, q, s, is_inside, d] = distance_to_conic_surface(p, c1, c2, r1, r2, 1, 2);
% end

distances = zeros(N, 1);
points = [reshape(x, N, 1), reshape(y, N, 1), reshape(z, N, 1)];
for i = 1:N
   p = points(i, :)';    
   [~, ~, ~, ~, distances(i)] = distance_to_conic_surface(p, c1, c2, r1, r2, 1, 2);
end
distances = reshape(distances, size(x));

% figure('units','normalized','outerposition',[0 0 1 1]); hold on;
h = patch(isosurface(x, y, z, distances,0));
isonormals(x, y, z, distances, h);
set(h,'FaceColor',color,'EdgeColor','none', 'FaceAlpha', 0.5);

grid off; view([1,1,1]);
axis equal; camlight;
lighting gouraud;
myline(c1, c2, 'b');

