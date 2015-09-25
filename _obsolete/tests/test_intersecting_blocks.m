%% Initialize

close all; clc; clear;
path = ['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\data\convtriangles\'];
%path = ['C:\Users\', getenv('USERNAME'), '\Desktop\HandModel_24.07\data\convtriangles\'];
load([path, 'radii']);
load([path, 'blocks']);
load([path, 'points']);
load([path, 'centers']);

[blocks] = reindex(radii, blocks);

D = 3;
num_poses = 1;
p = 1;
total_num_points = 0;
cumsum_num_points = zeros(num_poses + 1, 1);
poses = cell(num_poses, 1);

poses{p}.num_points = length(points);

poses{p}.points = points;
poses{p}.centers = centers;
num_centers = length(centers);
poses{p}.num_centers = num_centers;

%% Display
poses{p} = compute_projections_convtriangles(poses{p}, blocks, radii);

display_result_convtriangles(poses{p}, blocks, radii, true);

colors = ['r', 'y', 'b'];
for j = 1:length(blocks)
    myline(poses{p}.points{1}, poses{p}.all_projections{j}, colors(j));
    mypoint(poses{p}.all_projections{j}, colors(j));
end

% myline(poses{p}.points{1}, poses{p}.projections{1},'k');
% mypoint(poses{p}.projections{1},'k');
mypoint(poses{p}.points{1},'k');