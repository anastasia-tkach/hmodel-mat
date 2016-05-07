function [] = send_neutral_results_to_cpp(poses, radii, blocks, names_map, scaling_factor)

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

%% Rotate final pose to initial position
Rx = makehgtform('axisrotate', [1; 0; 0], - final_pose.init_theta(4));
Ry = makehgtform('axisrotate', [0; 1; 0], - final_pose.init_theta(5));
Rz = makehgtform('axisrotate', [0; 0; 1], - final_pose.init_theta(6));    
final_pose.init_transform =  Rz * Ry * Rx;
for i = 1:length(final_pose.centers)
    final_pose.centers{i} = transform(final_pose.centers{i}, final_pose.init_transform);
end    

%% Adjust initial transformations
centers = final_pose.centers;
phalanges = final_pose.phalanges;
theta = final_pose.theta;

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
phalanges{13}.local(1:3, 1:3) = eye(3, 3); 

% Ring
phalanges{8}.local(1:3, 4) = centers{names_map('ring_base')} - centers{names_map('palm_back')};
phalanges{9}.local(2, 4) = norm(centers{names_map('ring_bottom')} - centers{names_map('ring_base')});
phalanges{10}.local(2, 4) = norm(centers{names_map('ring_middle')} - centers{names_map('ring_bottom')});

% Pinky
phalanges{5}.local(1:3, 4) = centers{names_map('pinky_base')} - centers{names_map('palm_back')};
phalanges{6}.local(2, 4) =  norm(centers{names_map('pinky_bottom')} - centers{names_map('pinky_base')});
phalanges{7}.local(2, 4) =  norm(centers{names_map('pinky_middle')} - centers{names_map('pinky_bottom')});

%% Put to initial pose
figure; hold on; axis off; axis equal;
display_skeleton(centers, [], blocks, [], false, 'b');

num_thetas = 29;
[~, dofs] = hmodel_parameters();
posed_phalanges = htrack_move(theta, dofs, phalanges);
posed_phalanges = initialize_offsets(centers, posed_phalanges, names_map);

posed_phalanges = htrack_move(zeros(num_thetas, 1), dofs, posed_phalanges);
centers = update_centers(centers, posed_phalanges, names_map);

%theta([10, 11, 14, 15, 18, 19, 22, 23, 26, 27]) = 0;
posed_phalanges = htrack_move(-theta, dofs, posed_phalanges);
centers = update_centers(centers, posed_phalanges, names_map);
display_skeleton(centers, [], blocks, [], false, 'r');


%% Adjust fingers
u = [0; 1; 0];
new_centers = centers;

new_centers{names_map('index_bottom')} = new_centers{names_map('index_base')} + norm(centers{names_map('index_base')} - centers{names_map('index_bottom')}) * u;
new_centers{names_map('index_middle')} = new_centers{names_map('index_bottom')} + norm(centers{names_map('index_bottom')} - centers{names_map('index_middle')}) * u;
new_centers{names_map('index_top')} = new_centers{names_map('index_middle')} + norm(centers{names_map('index_middle')} - centers{names_map('index_top')}) * u;

new_centers{names_map('middle_bottom')} = new_centers{names_map('middle_base')} + norm(centers{names_map('middle_base')} - centers{names_map('middle_bottom')}) * u;
new_centers{names_map('middle_middle')} = new_centers{names_map('middle_bottom')} + norm(centers{names_map('middle_bottom')} - centers{names_map('middle_middle')}) * u;
new_centers{names_map('middle_top')} = new_centers{names_map('middle_middle')} + norm(centers{names_map('middle_middle')} - centers{names_map('middle_top')}) * u;

new_centers{names_map('ring_bottom')} = new_centers{names_map('ring_base')} + norm(centers{names_map('ring_base')} - centers{names_map('ring_bottom')}) * u;
new_centers{names_map('ring_middle')} = new_centers{names_map('ring_bottom')} + norm(centers{names_map('ring_bottom')} - centers{names_map('ring_middle')}) * u;
new_centers{names_map('ring_top')} = new_centers{names_map('ring_middle')} + norm(centers{names_map('ring_middle')} - centers{names_map('ring_top')}) * u;

new_centers{names_map('pinky_bottom')} = new_centers{names_map('pinky_base')} + norm(centers{names_map('pinky_base')} - centers{names_map('pinky_bottom')}) * u;
new_centers{names_map('pinky_middle')} = new_centers{names_map('pinky_bottom')} + norm(centers{names_map('pinky_bottom')} - centers{names_map('pinky_middle')}) * u;
new_centers{names_map('pinky_top')} = new_centers{names_map('pinky_middle')} + norm(centers{names_map('pinky_middle')} - centers{names_map('pinky_top')}) * u;

centers = new_centers;

%% Adjust membranes
centers{names_map('thumb_fold')} = centers{names_map('thumb_bottom')} + 0.01 * rand;
centers{names_map('index_membrane')} = adjust_membrane(centers, radii, names_map, 'index_membrane', 'index_base', 'index_bottom');
centers{names_map('middle_membrane')} = adjust_membrane(centers, radii, names_map, 'middle_membrane', 'middle_base', 'middle_bottom');
centers{names_map('ring_membrane')} = adjust_membrane(centers, radii, names_map, 'ring_membrane', 'ring_base', 'ring_bottom');
centers{names_map('pinky_membrane')} = adjust_membrane(centers, radii, names_map, 'pinky_membrane', 'pinky_base', 'pinky_bottom');

%% Adjust wrist
%{
personal_scaling = 1;
centers{35} = centers{names_map('palm_back')} + personal_scaling * [12; -5; 0];
centers{36} = centers{names_map('palm_back')} + personal_scaling * [-8; -5; 0];
centers{37} = centers{names_map('palm_back')} + personal_scaling * [5; -60; 0];
centers{38} = centers{names_map('palm_back')} + personal_scaling * [-5; -60; 0];
%}
%{
centers(35:38) = poses{1}.initial_centers(35:38);
radii(35:38) = poses{1}.initial_radii(35:38);
%}

%% Display
figure; hold on; axis off; axis equal;
display_skeleton(centers, [], blocks, [], false, 'b');

%% Scale
num_phalanges = 17;
scaling_factor = 1/scaling_factor;
for i = 1:length(centers)
    centers{i} = scaling_factor * centers{i};
    radii{i} = scaling_factor * radii{i};
end
for i = 1:num_phalanges
    phalanges{i}.local(1:3, 4) = scaling_factor * phalanges{i}.local(1:3, 4);
end


%% Write model
write_cpp_model('C:/Developer/data/models/reverse/', centers, radii, blocks, phalanges);




