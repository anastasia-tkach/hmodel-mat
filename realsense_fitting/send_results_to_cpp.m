function [] = send_results_to_cpp(poses, radii, blocks, names_map)

%{
clear;
input_path = 'C:/Developer/data/MATLAB/andrii/stage1/final/';
semantics_path = '_my_hand/semantics/';
load([semantics_path, 'fitting/names_map.mat']);
load([input_path, 'poses.mat']);
load([input_path, 'radii.mat']);
load([input_path, 'blocks.mat']);
%}


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

%% Adjust initial transformations
centers = final_pose.centers;
theta = final_pose.theta;
phalanges = final_pose.phalanges;
% Thumb
phalanges{2}.local(1:3, 4) = centers{names_map('thumb_base')} - centers{names_map('palm_back')};
phalanges{3}.local(2, 4) = norm(centers{names_map('thumb_bottom')} - centers{names_map('thumb_base')});
phalanges{4}.local(2, 4) = norm(centers{names_map('thumb_middle')} - centers{names_map('thumb_bottom')});

% Index
phalanges{14}.local(1:3, 4) = centers{names_map('index_base')} - centers{names_map('palm_back')};
phalanges{15}.local(2, 4) = norm(centers{names_map('index_bottom')} - centers{names_map('index_base')});
phalanges{16}.local(2, 4) = norm(centers{names_map('index_middle')} - centers{names_map('index_bottom')});

% Middle
phalanges{11}.local(1:3, 4) = centers{names_map('middle_base')} - centers{names_map('palm_back')};
phalanges{12}.local(2, 4) = norm(centers{names_map('middle_bottom')} - centers{names_map('middle_base')});
phalanges{13}.local(2, 4) = norm(centers{names_map('middle_middle')} - centers{names_map('middle_bottom')});

% Ring
phalanges{8}.local(1:3, 4) = centers{names_map('ring_base')} - centers{names_map('palm_back')};
phalanges{9}.local(2, 4) = norm(centers{names_map('ring_bottom')} - centers{names_map('ring_base')});
phalanges{10}.local(2, 4) = norm(centers{names_map('ring_middle')} - centers{names_map('ring_bottom')});

% Pinky
phalanges{5}.local(1:3, 4) = centers{names_map('pinky_base')} - centers{names_map('palm_back')};
phalanges{6}.local(2, 4) =  norm(centers{names_map('pinky_bottom')} - centers{names_map('pinky_base')});
phalanges{7}.local(2, 4) =  norm(centers{names_map('pinky_middle')} - centers{names_map('pinky_bottom')});

%% Move palm_back to zero
%{
shift = final_pose.centers{names_map('palm_back')};
for i = 1:length(final_pose.centers)
    final_pose.centers{i} = final_pose.centers{i} - shift;
end
%}

figure; hold on; axis off; axis equal;
display_skeleton(centers, [], blocks, [], false, 'b');

num_thetas = 29;
[~, dofs] = hmodel_parameters();
phalanges = htrack_move(theta, dofs, phalanges);
phalanges = initialize_offsets(centers, phalanges, names_map);

phalanges = htrack_move(zeros(num_thetas, 1), dofs, phalanges);
centers = update_centers(centers, phalanges, names_map);

%%%final_pose.theta([10, 11, 14, 15, 18, 19, 22, 23, 26, 27]) = 0;
phalanges = htrack_move(-theta, dofs, phalanges);
centers = update_centers(centers, phalanges, names_map);
display_skeleton(centers, [], blocks, [], false, 'r');

%% Adjust membranes
centers{names_map('thumb_fold')} = centers{names_map('thumb_bottom')} + 0.01 * rand;

%% Scale
num_phalanges = 17;
scaling_factor = 1/0.811646;
for i = 1:length(centers)
    centers{i} = scaling_factor * centers{i};
    radii{i} = scaling_factor * radii{i};
end
for i = 1:num_phalanges
    phalanges{i}.local(1:3, 4) = scaling_factor * phalanges{i}.local(1:3, 4);
end

%% Write model
write_cpp_model('C:/Developer/data/models/anonymous/', centers, radii, blocks, phalanges);




