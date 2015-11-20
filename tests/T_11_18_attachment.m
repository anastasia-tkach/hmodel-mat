close all;

D = 3;

%% Synthetic data
% [centers, radii, blocks] = get_random_convtriangle();
% radii{1} = 0.19; radii{2} = 0.2; radii{3} = 0.21;
% 
% centers{4} = mean([centers{1}, centers{2}, centers{3}], 2);
% centers{5} = centers{4} + 2 * cross(centers{2} - centers{1}, centers{3} - centers{1});
% radii{4} = 0.15; radii{5} = 0.1;
% blocks{2} = [4, 5];
% attachments{4}.block_index = 1;
% attachments{5}.block_index = 1;
%global_frame_indices = blocks{1};

%% Hand model

model_path = '_data/my_hand/model/';
data_path = '_data/my_hand/trial1/';
load([model_path, 'centers.mat']);
load([model_path, 'radii.mat']);
load([model_path, 'blocks.mat']);
load([model_path, 'solids.mat']);

compute_attachments;
attachments = initialize_attachments(centers, centers, blocks, attachments, global_frame_indices);
initial_centers = centers;

%% Generate model
rotation_axis = randn(D, 1);
rotation_angle = 10 * randn;
translation_vector = - rand * [0; 0; 1];
R = makehgtform('axisrotate', rotation_axis, rotation_angle);
T = makehgtform('translate', translation_vector);
for i = 1:length(centers)
    centers{i} = transform(centers{i}, R);
    centers{i} = transform(centers{i}, T);
end

display_skeleton(centers, radii, blocks, [], false);

[centers, rotation] = update_attachments(centers, centers, blocks, attachments, global_frame_indices);

T2 = T;
T2(1:3, 4) = - T(1:3, 4);
R2 = eye(4, 4); 
R2(1:3, 1:3) = rotation;
for i = 1:length(centers)
    centers{i} = transform(centers{i}, T2);
    centers{i} = transform(centers{i}, R2);    
end

%% Display results
display_skeleton(centers, radii, blocks, [], false);
% myline(centers{1}, centers{1} +   0.3 * initial_frames{1}(:, 1), 'm');
% myline(centers{1}, centers{1} +   0.3 * initial_frames{1}(:, 2), 'm');
% myline(centers{1}, centers{1} +   0.3 * initial_frames{1}(:, 3), 'm');
display_skeleton(initial_centers, radii, blocks, [], false);
% myline(initial_centers{1}, initial_centers{1} +  0.3 * initial_frames{1}(:, 1), 'm');
% myline(initial_centers{1}, initial_centers{1} +  0.3 * initial_frames{1}(:, 2), 'm');
% myline(initial_centers{1}, initial_centers{1} +  0.3 * initial_frames{1}(:, 3), 'm');

for i = 1:length(centers)
    disp([initial_centers{i}'; centers{i}']);
end
