function [] = send_results_to_cpp(poses, radii, blocks, phalanges, names_map)

% input_path = 'C:/Developer/data/MATLAB/anastasia/stage1/final/';
% semantics_path = '_my_hand/semantics/';
% load([semantics_path, 'fitting/names_map.mat']);
% load([input_path, 'poses.mat']);
% load([input_path, 'radii.mat']);
% load([input_path, 'blocks.mat']);
% load([input_path, 'alpha.mat']);
% load([input_path, 'phalanges.mat']);

%% Write model to cpp
final_id = 1;
final_pose = poses{final_id};
reference_id = 1;
reference_pose = poses{reference_id};

%% Rotate final pose to initial position
Rx = makehgtform('axisrotate', [1; 0; 0], - final_pose.init_theta(4));
Ry = makehgtform('axisrotate', [0; 1; 0], - final_pose.init_theta(5));
Rz = makehgtform('axisrotate', [0; 0; 1], - final_pose.init_theta(6));    
final_pose.init_transform =  Rz * Ry * Rx;
for i = 1:length(final_pose.centers)
    final_pose.centers{i} = transform(final_pose.centers{i}, final_pose.init_transform);
end    
%% Rotate reference pose to initial position
Rx = makehgtform('axisrotate', [1; 0; 0], - reference_pose.init_theta(4));
Ry = makehgtform('axisrotate', [0; 1; 0], - reference_pose.init_theta(5));
Rz = makehgtform('axisrotate', [0; 0; 1], - reference_pose.init_theta(6));    
reference_pose.init_transform =  Rz * Ry * Rx;
for i = 1:length(reference_pose.centers)
    reference_pose.centers{i} = transform(reference_pose.centers{i}, reference_pose.init_transform);
end  

%% Rotate final pose to reference pose
palm_indices = [names_map('palm_right'), names_map('palm_back'), names_map('palm_left'), ...
    names_map('palm_pinky'), names_map('palm_ring'), names_map('palm_middle'), names_map('palm_index'), names_map('palm_thumb'), ...
    names_map('pinky_base'), names_map('ring_base'), names_map('middle_base'), names_map('index_base'), names_map('thumb_base')];


if (reference_id ~= final_id)
    P = cell(length(palm_indices), 1);
    Q = cell(length(palm_indices), 1);
    for i = 1:length(palm_indices)
        P{i} = reference_pose.centers{palm_indices(i)};
        Q{i} = final_pose.centers{palm_indices(i)};
    end
    [final_pose.transform, ~] = find_rigid_transformation(P, Q, false);
    for i = 1:length(final_pose.centers)
        final_pose.centers{i} = transform(final_pose.centers{i}, final_pose.transform);
    end
end

%% Move palm_back to zero
% shift = final_pose.centers{names_map('palm_back')};
% for i = 1:length(final_pose.centers)
%     final_pose.centers{i} = final_pose.centers{i} - shift;
% end

% figure; hold on; axis off; axis equal;
% display_skeleton(poses{reference_id}.centers, [], blocks, [], false, 'b');
% display_skeleton(final_pose.centers, [], blocks, [], false, 'r');


%display_result(final_pose.centers, [], [], blocks, radii, false, 1, 'big');
%view([-180, -90]); camlight; drawnow;
figure; hold on; axis off; axis equal;
display_skeleton(final_pose.centers, [], blocks, [], false, 'b');

num_thetas = 29;
theta = zeros(num_thetas, 1);
[~, dofs] = hmodel_parameters();
phalanges = htrack_move(final_pose.theta, dofs, phalanges);
phalanges = initialize_offsets(final_pose.centers, phalanges, names_map);

theta = zeros(num_thetas, 1);
phalanges = htrack_move(theta, dofs, phalanges);
final_pose.centers = update_centers(final_pose.centers, phalanges, names_map);

final_pose.theta([10, 11, 14, 15, 18, 19, 22, 23, 26, 27]) = 0;
phalanges = htrack_move(-final_pose.theta, dofs, phalanges);
final_pose.centers = update_centers(final_pose.centers, phalanges, names_map);

%display_result(final_pose.centers, [], [], blocks, radii, false, 1, 'big');
%view([-180, -90]); camlight; drawnow;
display_skeleton(final_pose.centers, [], blocks, [], false, 'r');

%% Scale
num_phalanges = 17;
scaling_factor = 1/0.811646;
for i = 1:length(final_pose.centers)
    final_pose.centers{i} = scaling_factor * final_pose.centers{i};
    radii{i} = scaling_factor * radii{i};
end
for i = 1:num_phalanges
    phalanges{i}.local(1:3, 4) = scaling_factor * phalanges{i}.local(1:3, 4);
end

%% Write model
write_cpp_model('C:/Developer/data/models/anonymous/', final_pose.centers, radii, blocks, phalanges);

% D = 3;
% I = zeros(length(phalanges), 4 * 4);
% for i = 1:length(phalanges)
%     I(i, :) = phalanges{i}.local(:)';
% end
% I = I';
% num_centers = 38;
% num_blocks = 30;
% RAND_MAX = 32767;
% R = zeros(1, num_centers);
% C = zeros(D, num_centers);
% B = RAND_MAX * ones(3, num_blocks);
% for j = 1:num_centers
%     R(j) =  radii{j};
%     C(:, j) = final_pose.centers{j};
% end
% for j = 1:num_blocks
%     for k = 1:length(blocks{j})
%         B(k, j) = blocks{j}(k) - 1;
%     end
% end
% path = 'C:/Developer/data/models/andrii/';
% write_input_parameters_to_files(path, C, R, B, I);




