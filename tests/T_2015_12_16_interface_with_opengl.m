close all; clear;
path = 'C:\Users\tkach\OneDrive\EPFL\Code\HModel\display\opengl-renderer-vs\Input\Htrack\';
%% Generate model

%{
[centers1, radii1, blocks1] = get_random_convtriangle();
[centers2, radii2, blocks2] = get_random_convsegment(D);
blocks2{1} = blocks2{1} + length(centers{1});
centers = [centers1; centers2];
radii = [radii1; radii2];
blocks = [blocks1; blocks2];

%}

%% Htrack model
% D = 3;
% mode = 'hand';
% num_parameters = 26;
% segments = create_ik_model(mode);
% theta = zeros(num_parameters, 1);
% [posed_segments, joints] = pose_ik_model(segments, theta, false, mode);
% num_centers = 24;
% centers = cell(num_centers, 1);
% radii = cell(num_centers, 1);
% 
% K = [7, 6, 5, 10, 9, 8, 13, 12, 11, 16, 15, 14, 4, 3, 2, 1];
% 
% count = 1;
% for k = 1:length(K)
%     i = K(k);
%     centers{count} = segments{i}.global(1:D, D + 1) + segments{i}.global(1:D, 1:D) * segments{i}.length * [0; 1; 0];    
%     radii{count} = segments{i}.radius2 + randn/1000;
%     count = count + 1;
%     if rem(k, 3) == 0 || k == 16
%         centers{count} = segments{i}.global(1:D, D + 1);
%         radii{count} = segments{i}.radius1 + randn/1000;
%         count = count + 1;
%     end
% end
% 
% centers{23} = centers{21} + 20 * segments{1}.global(1:D, 1:D) * [1; 0; 0];
% centers{24} = centers{22} + 20 * segments{1}.global(1:D, 1:D) * [1; 0; 0];
% centers{21} = centers{21} - 20 * segments{1}.global(1:D, 1:D) * [1; 0; 0];
% centers{22} = centers{22} - 20 * segments{1}.global(1:D, 1:D) * [1; 0; 0];
% radii{23} = 0.3 * radii{21} + randn/1000; 
% radii{24} = 0.3 * radii{22} + randn/1000;
% radii{21} = 0.3 * radii{21} + randn/1000; 
% radii{22} = 0.3 * radii{22} + randn/1000;
% 
% blocks = {[1, 2], [2, 3], [3, 4], [5, 6], [6, 7], [7, 8], [9, 10], [10, 11], [11, 12]...
%     [13, 14], [14, 15], [15, 16], [17, 18], [18, 19], [19, 20], [21, 22, 23], [22, 23, 24]};
% blocks = reindex(radii, blocks);
% 
% %display_result(centers, [], [], blocks, radii, false, 1, 'big');
% %view([-180, -90]); camlight;
% %[centers, radii, blocks, solid_blocks] = make_convolution_model(posed_segments, mode);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% centers = {};
% centers{end + 1} = [-55.4231 64.2556 402.393]';
% centers{end + 1} = [-50.657 53.2428 402.346]';
% centers{end + 1} = [-43.4804 36.7711  401.26]';
% centers{end + 1} = [-30  10 400]';
% centers{end + 1} = [-27.6096 83.7989 395.866]';
% centers{end + 1} = [-23.5874 69.1777 396.906]';
% centers{end + 1} = [-18.4539 47.0126 398.388]';
% centers{end + 1} = [-10  10 400]';
% centers{end + 1} = [7.96594 89.2418 390.301]';
% centers{end + 1} = [8.38911 73.2785 391.299]';
% centers{end + 1} = [9.02386 49.3336 392.795]';
% centers{end + 1} = [ 10  10 400]';
% centers{end + 1} = [41.6905 84.9159 395.782]';
% centers{end + 1} = [39.5994 69.8633 396.078]';
% centers{end + 1} = [36.4628 47.2845 396.522]';
% centers{end + 1} = [ 30  10 400]';
% centers{end + 1} = [ 74.1252 -3.46622  375.903]';
% centers{end + 1} = [ 63.9524 -14.9993  380.319]';
% centers{end + 1} = [ 48.6933 -32.2989  386.943]';
% centers{end + 1} = [ 20 -60 390]';
% centers{end + 1} = [    -20 1.90935     400]';
% centers{end + 1} = [-20 -70 400]';
% centers{end + 1} = [     20 1.90935     400]';
% centers{end + 1} = [ 20 -70 400]';
% radii = {};
% radii{end + 1} = 6.4;
% radii{end + 1} = 6.40018;
% radii{end + 1} = 7.20006;
% radii{end + 1} = 8.00027;
% radii{end + 1} = 6.40019;
% radii{end + 1} = 6.40016;
% radii{end + 1} = 7.20011;
% radii{end + 1} = 8.00029;
% radii{end + 1} = 6.40027;
% radii{end + 1} = 6.40024;
% radii{end + 1} = 7.20006;
% radii{end + 1} = 8.00028;
% radii{end + 1} = 6.40023;
% radii{end + 1} = 6.40017;
% radii{end + 1} = 7.2001;
% radii{end + 1} = 8;
% radii{end + 1} = 6.40003;
% radii{end + 1} = 7.20012;
% radii{end + 1} = 8.00005;
% radii{end + 1} = 13.6001;
% radii{end + 1} = 10.8;
% radii{end + 1} = 10.8;
% radii{end + 1} = 10.8;
% radii{end + 1} = 11.8;
% 
% blocks = {};
% blocks{end + 1} = [    1     0 ];
% blocks{end + 1} = [    2     1]; 
% blocks{end + 1} = [    3     2]; 
%     blocks{end + 1} =[ 4     5 ];
%     blocks{end + 1} = [6     5]; 
%     blocks{end + 1} =[ 7     6]; 
%     blocks{end + 1} = [8     9]; 
%    blocks{end + 1} =[ 10     9]; 
%    blocks{end + 1} = [11    10]; 
%    blocks{end + 1} = [12    13]; 
%    blocks{end + 1} =[ 14    13]; 
%    blocks{end + 1} =[ 15    14]; 
%    blocks{end + 1} = [17    16]; 
%    blocks{end + 1} = [18    17]; 
%    blocks{end + 1} = [19    18]; 
% blocks{end + 1} = [22 20 21];
% blocks{end + 1} = [22 23 21];
% for i = 1:length(blocks)
%     for j = 1:length(blocks{i})
%         blocks{i}(j) = blocks{i}(j) + 1;
%     end
% end

%% Convolution model

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


display_result(centers, [], [], blocks, radii, false, 0.7, 'none');
view([-180, -90]); camlight; drawnow;


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
end
for j = 1:length(model_points)
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
