set_path; 
%close all; clc; clear; D = 3;
% absolute_path = ['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\'];
% data_path = [absolute_path, '_data\convtriangles\hand\'];
% load([data_path, 'radii']);
% load([data_path, 'blocks']);
% load([data_path, 'points']);
% load([data_path, 'centers']);
num_points = length(points);
% pose.centers = centers;
%tangent_points = blocks_tangent_points(pose.centers, blocks, radii);
tangent_points = blocks_tangent_points(poses{p}.centers, blocks, radii);
centers = poses{p}.centers;
points = poses{p}.points;

%% Put data in matrix form
RAND_MAX = 32767;
R = zeros(length(radii), 1);
C = zeros(length(centers), D);
B = RAND_MAX * ones(length(blocks), 3);
T = RAND_MAX * ones(length(blocks), 6 * D);
for j = 1:length(radii)
    R(j) = radii{j};
    C(j, :) = centers{j}';
end
for j = 1:length(blocks)
    for k = 1:length(blocks{j})
        B(j, k) = blocks{j}(k) - 1;
    end
    if ~isempty(tangent_points{j})
        T(j, 1:3) = tangent_points{j}.v1';
        T(j, 4:6) = tangent_points{j}.v2';
        T(j, 7:9) = tangent_points{j}.v3';
        T(j, 10:12) = tangent_points{j}.u1';
        T(j, 13:15) = tangent_points{j}.u2';
        T(j, 16:18) = tangent_points{j}.u3';
    end
end

N = 500;
i = randi([1 num_points], N, 1);
i = 717;
N = 1;
P =  zeros(N, D);
for j = 1:N
    P(j, :) = points{i(j)}';
end
points = points(i);
num_points = length(points);
write_input_parameters_to_files(P, R, C, B, T);

%% Call
[indices0, projections0, block_indices0] = compute_projections_transition(points, centers, blocks, radii);


[indices, projections, block_indices] = compute_projections(points, centers, blocks, radii);



for i = 1:length(indices)
    disp([indices0{i}'; indices{i}']);
end

for i = 1:length(projections)
    disp([projections0{i}'; projections{i}']);
end
disp([block_indices0 block_indices]);





