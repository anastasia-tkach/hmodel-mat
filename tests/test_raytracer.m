clear; clc; close all;
absolute_path = ['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\'];
data_path = [absolute_path, '_data\convtriangles\'];
load([data_path, 'radii']);
load([data_path, 'blocks']);

D = 3;
num_poses = 1;
num_centers = length(radii);
num_parameters = D * num_centers * num_poses + num_centers;

p = 1;
load([data_path, 'points']);
load([data_path, 'centers']);
poses{p}.num_points = length(points);
poses{p}.points = points;
poses{p}.centers = centers;
poses{p}.num_centers = num_centers;

total_num_points = 0; cumsum_num_points = zeros(num_poses + 1, 1);
total_num_points = total_num_points + poses{p}.num_points;
cumsum_num_points(p + 1) = cumsum_num_points(p) + poses{p}.num_points;

D = render_model(centers, blocks, radii);
skip = 3;
figure; imshow(D(1:skip:end, 1:skip:end), []);





