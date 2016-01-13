path = 'C:\Users\tkach\OneDrive\EPFL\Code\HModel\display\opengl-renderer-vs\Input\';
close all;
%% Generate model

%{
[centers1, radii1, blocks1] = get_random_convtriangle();
[centers2, radii2, blocks2] = get_random_convsegment(D);
blocks2{1} = blocks2{1} + length(centers{1});
centers = [centers1; centers2];
radii = [radii1; radii2];
blocks = [blocks1; blocks2];

%}

data_path = 'C:\Users\tkach\OneDrive\EPFL\Code\HModel\_my_hand\fitting_result\';
load([data_path, 'radii.mat']);
load([data_path, 'blocks.mat']); [blocks] = reindex(radii, blocks);
load([data_path, 'centers.mat']);
load([data_path, 'points.mat']);

sum_centers = zeros(3, 1);
for i = 1:length(centers)
    sum_centers = sum_centers + centers{i};
end
mean_centers = sum_centers ./ length(centers);
for i = 1:length(centers)
    centers{i} = centers{i} - mean_centers;
end
for i = 1:length(points)   
    points{i} = points{i} - mean_centers;
end

[model_indices, model_points, ~] = compute_projections(points, centers, blocks, radii);
display_result(centers, points, model_points, blocks, radii, true, 0.5, 'big');

%% Put data in matrix form
D = 3;
RAND_MAX = 32767;
R = zeros(length(radii), 1);
C = zeros(length(centers), D);
B = RAND_MAX * ones(length(blocks), 3);
T = RAND_MAX * ones(length(blocks), 6 * D);
P = zeros(length(points), D);
M = zeros(length(model_points), D);
tangent_points = blocks_tangent_points(centers, blocks, radii);
for j = 1:length(points)  
    P(j, :) = points{j}';
    if ~isempty(model_points{j})
        M(j, :) = model_points{j}';
    else 
        M(j, :) = points{j}';
    end   
end
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

%% Write input data
write_input_parameters_to_files(path, C, R, B, T, P, M);
