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
compute_attachments;
D = 3;
global_frame_indices = blocks{24};
initial_frames = compute_model_frames(centers, blocks, global_frame_indices);

%% Compute attachment weights
for i = 1:length(attachments)
    if isempty(attachments{i}), continue; end
    
    indices = blocks{attachments{i}.block_index};
    [~, projections, ~] = compute_skeleton_projections({centers{i}}, centers, {indices});
    attachments{i}.axis_projection = projections{1};   
    
    if length(indices) == 3
        P = [centers{indices(1)}'; centers{indices(2)}'; centers{indices(3)}'; attachments{i}.axis_projection'];
        attachments{i}.weights = [P(4,:),1]/[P(1:3,:),ones(3,1)];
    end
    if length(indices) == 2
        P = [centers{indices(1)}'; centers{indices(2)}'; attachments{i}.axis_projection'];
        attachments{i}.weights = [P(3,:),1]/[P(1:2,:),ones(2,1)];
    end
    
    attachments{i}.offset = centers{i}  - attachments{i}.axis_projection;
end

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
frames = compute_model_frames(centers, blocks, global_frame_indices);

%% Display results
display_skeleton(centers, radii, blocks, [], false);

%% Move attachments
for o = 1:length(attachments)
    if isempty(attachments{o}), continue; end
    attachments{o}.axis_projection = zeros(D, 1);
    indices = blocks{attachments{o}.block_index};
    for l = 1:length(indices)
        attachments{o}.axis_projection = attachments{o}.axis_projection + attachments{o}.weights(l) * centers{indices(l)};
    end
    rotation = find_svd_rotation(initial_frames{attachments{o}.block_index}, frames{attachments{o}.block_index});
    centers{o} = attachments{o}.axis_projection + rotation' * attachments{o}.offset;
end

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
