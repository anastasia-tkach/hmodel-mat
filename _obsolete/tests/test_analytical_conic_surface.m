clc; clear; close all;
path = ['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\data\convtriangles\'];
load([path, 'radii']);
load([path, 'blocks']);
load([path, 'centers']);

pose.centers = centers;
for j = 1:1%length(blocks)
    if length(blocks{j}) > 2, continue; end;
    
    c1 = centers{blocks{j}(1)};
    c2 = centers{blocks{j}(2)};
    r1 = radii{blocks{j}(1)};
    r2 = radii{blocks{j}(2)};
end

%% Draw convsegment
figure('units','normalized','outerposition',[0 0 1 1]); hold on; axis equal;
%draw_convsegment(blocks{1}, centers, radii, 'y');

draw_conic_surfaces_analytically(c1, c2, r1, r2);


