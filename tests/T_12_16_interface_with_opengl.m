path = 'C:\Users\tkach\Desktop\sphere3d-build\Input\';
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

data_path = 'tracking/rectified/';
load([data_path, 'radii.mat']);
load([data_path, 'blocks.mat']); [blocks] = reindex(radii, blocks);
load([data_path, 'centers.mat']);

sum_centers = zeros(3, 1);
for i = 1:length(centers)
    sum_centers = sum_centers + centers{i};
end
mean_centers = sum_centers ./ length(centers);
for i = 1:length(centers)
    centers{i} = centers{i} - mean_centers;
end

display_result(centers, [], [], blocks, radii, false, 0.5);
mypoint([0; 0; 0], 'r');
%% Put data in matrix form
D = 3;
RAND_MAX = 32767;
R = zeros(length(radii), 1);
C = zeros(length(centers), D);
B = RAND_MAX * ones(length(blocks), 3);
T = RAND_MAX * ones(length(blocks), 6 * D);
tangent_points = blocks_tangent_points(centers, blocks, radii);
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
write_input_parameters_to_files(path, C, R, B, T);
