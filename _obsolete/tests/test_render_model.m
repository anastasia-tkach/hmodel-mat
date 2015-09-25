close all; clc; clear;
path = ['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\data\convtriangles\'];
load([path, 'radii']);
load([path, 'blocks']);
load([path, 'points']);
load([path, 'centers']);

[blocks] = reindex(radii, blocks);
block = blocks{1};

%%  Compute 
c1 = centers{block(1)}; c2 = centers{block(2)}; 
r1 = radii{block(1)}; r2 = radii{block(2)}; 


%% Draw convsegment
n = 60; min_x = 0; max_x = 1; min_y = 0; max_y = 1; min_z = 0; max_z = 1;
xm = linspace(min_x, max_x, n); ym = linspace(min_y, max_y, n); zm = linspace(min_z, max_z, n);
[x, y, z] = meshgrid(xm,ym,zm); N = numel(x);
points = [reshape(x, N, 1), reshape(y, N, 1), reshape(z, N, 1)];

distances = compute_distances_to_model(c1, c2, r1, r2, points');
distances = reshape(distances, size(x));

[faces, vertices] = isosurface(x, y, z, distances,0);

figure; hold on;
plot_mesh(vertices', fases');

figure; hold on;
color = 'c';
h = patch(isosurface(x, y, z, distances,0));
isonormals(x, y, z, distances, h);
set(h,'FaceColor',color,'EdgeColor','none');
alpha(0.3); grid off; view([1,1,1]);
axis equal; camlight; lighting gouraud;
