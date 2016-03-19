clc;
close all;
clear;
%% Synthetic data
[centers, radii, blocks] = get_random_convquad();
for i = 1:length(centers)
    centers{i} = centers{i} + [0; 0; 1];
end

%% Hand model
input_path = '_my_hand/tracking_initialization/';
semantics_path = '_my_hand/semantics/';
load([input_path, 'centers.mat']); load([input_path, 'radii.mat']);
load([semantics_path, 'tracking/blocks.mat']); [blocks] = reindex(radii, blocks);
load([semantics_path, 'palm_blocks.mat']);
load([semantics_path, 'fingers_blocks.mat']);
load([semantics_path, 'fingers_base_centers.mat']);
load([semantics_path, 'tracking/names_map.mat']);
load([semantics_path, 'tracking/named_blocks.mat']);


%% Topology change
palm_blocks = {[21,22,28], [28,22,26], [22,23,26], [26, 23, 25], [26, 20, 25], [23, 24, 25], [20, 25, 36], [20, 36, 19], ...
    [30,31,21], [21,22,31], [31,32,22], [22,23,32], [32,23,24], [32,24,33]};
fingers_blocks{5} = {[35,17], [17,18], [18,19]};

blocks = [fingers_blocks{1}, fingers_blocks{2}, fingers_blocks{3}, fingers_blocks{4}, fingers_blocks{5}, palm_blocks];
blocks = reindex(radii, blocks);
print_blocks_names(blocks, names_map);

%% Pose the model
[attachments, global_frame_indices, palm_centers_names, solid_blocks, elastic_blcks, parents] = get_semantic_structures(centers, blocks, names_map, named_blocks);
[attachments, ~] = initialize_attachments(centers, radii, blocks, centers, attachments, 'hand', global_frame_indices, names_map, palm_centers_names);
segments = initialize_ik_hmodel(centers, names_map);
theta = zeros(26, 1);
%theta = 0.1 * randn(26, 1);
%theta(4:6) = theta(4:6) * 2;
%[centers, joints] = pose_ik_hmodel(theta, centers, names_map, segments);
joints = joints_parameters(zeros(26, 1));
[centers] = pose_ik_hmodel(theta, centers, names_map, segments, joints);
[centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, 'hand', global_frame_indices, names_map, palm_centers_names);
[centers, ~, ~, attachments] = update_attachments(centers, blocks, centers, attachments, 'hand', global_frame_indices, names_map, palm_centers_names);

camera_ray = [0; 0; 1];

%% Adjust the model
D = 3;
% scaling_factor = 1.3553;
% for i = 1:length(centers)
%     centers{i} = scaling_factor * centers{i};
%     radii{i} = scaling_factor * radii{i};
% end
centers{names_map('thumb_fold')} = centers{names_map('thumb_fold')} + [-7; 2; 0];
centers{names_map('middle_membrane')} = centers{names_map('middle_membrane')} + [0; -3; 2];
centers{names_map('index_membrane')} = centers{names_map('index_membrane')} + [0; 0; -2];
radii{names_map('thumb_top')} = 0.9 * radii{names_map('thumb_top')};

%% Initial transformations to matrix form
%for i = 1:length(segments), disp([num2str(i - 1), ' ', segments{i}.name]); end
I = zeros(length(segments), 4 * 4);
for i = 1:length(segments)
    I(i, :) = segments{i}.local(:)';
end
I = I';
%% Model to matrix form
num_centers = 36;

RAND_MAX = 32767;
R = zeros(1, num_centers);
C = zeros(D, num_centers);
B = RAND_MAX * ones(3, length(blocks));
scaling_factor = 1;
for j = 1:num_centers
    R(j) =  radii{j}; 
    C(:, j) = centers{j}; 
end
for j = 1:length(blocks)
    for k = 1:length(blocks{j})
        B(k, j) = blocks{j}(k) - 1;
    end   
end
path = 'C:\Developer\hmodel-cuda-build\data\';
write_input_parameters_to_files(path, C, R, B, I);

%% Find outline
[final_outline] = find_model_outline(centers, radii, blocks, palm_blocks, fingers_blocks, fingers_base_centers, camera_ray, names_map, true, true);

return
%% Read data
fileID = fopen([path, 'O.txt'], 'r');
O = fscanf(fileID, '%f');
N = length(O)/3;
O = reshape(O, 3, N)';
cpp_outline = cell(N/3, 1);
for i = 1:N/3
    cpp_outline{i}.start = O(3 * (i - 1) + 1, :)';
    cpp_outline{i}.end = O(3 * (i - 1) + 2, :)';
    cpp_outline{i}.indices = O(3 * i, :);   
    if cpp_outline{i}.indices(2) == RAND_MAX
        cpp_outline{i}.indices = cpp_outline{i}.indices(1) + 1;        
    else
        cpp_outline{i}.indices = cpp_outline{i}.indices(1:2) + 1;
    end
    cpp_outline{i}.block = O(3 * i, 3) + 1;  
end
figure; hold on; axis off; axis equal;
for i = 1:length(cpp_outline)
    if length(cpp_outline{i}.indices) == 2
        myline(cpp_outline{i}.start, cpp_outline{i}.end, 'b');
    else
        draw_circle_sector_in_plane(centers{cpp_outline{i}.indices}, radii{cpp_outline{i}.indices}, camera_ray, cpp_outline{i}.start, cpp_outline{i}.end, 'b');
    end
end
%view([-180, -90]); camlight;

for i = 1:min(length(cpp_outline), length(final_outline))
    disp(['outline[', num2str(i - 1), ']']);    
    disp(['   indices = ' num2str(final_outline{i}.indices)]);
    disp(['   indices = ' num2str(cpp_outline{i}.indices)]);
    disp(['   start = ' num2str(final_outline{i}.start')]);
    disp(['   start = ' num2str(cpp_outline{i}.start')]);
    disp(['   end = ' num2str(final_outline{i}.end')]);
    disp(['   end = ' num2str(cpp_outline{i}.end')]);
    disp(['   block = ' num2str(final_outline{i}.block)]);
    disp(['   block = ' num2str(cpp_outline{i}.block)]);
    if final_outline{i}.block ~= cpp_outline{i}.block
        disp('diffent blocks');
    end
    disp(' ');
end
