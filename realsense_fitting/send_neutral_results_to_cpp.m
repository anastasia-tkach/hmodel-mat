function [] = send_neutral_results_to_cpp(poses, radii, blocks, names_map, scaling_factor, user_name)

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
phalanges{9}.local(2, 4) = 0.9 * (norm(centers{names_map('ring_bottom')} - centers{names_map('ring_base')}));
phalanges{10}.local(2, 4) = norm(centers{names_map('ring_middle')} - centers{names_map('ring_bottom')});

% Pinky
phalanges{5}.local(1:3, 4) = centers{names_map('pinky_base')} - centers{names_map('palm_back')};
phalanges{6}.local(2, 4) =  norm(centers{names_map('pinky_bottom')} - centers{names_map('pinky_base')});
phalanges{7}.local(2, 4) =  norm(centers{names_map('pinky_middle')} - centers{names_map('pinky_bottom')});

centers{names_map('thumb_additional')} = centers{names_map('thumb_middle')} + 0.9 * (centers{names_map('thumb_additional')} - centers{names_map('thumb_middle')});

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

if strcmp(user_name, 'andrii');
    centers{names_map('middle_membrane')} = centers{names_map('middle_membrane')} + 5 * [0; 1; 0];
    centers{names_map('palm_middle')} = centers{names_map('palm_middle')} - 5 * [0; 1; 0];
    radii{names_map('thumb_top')} = 0.95 * radii{names_map('thumb_top')};
    radii{names_map('thumb_additional')} = 1.05 * radii{names_map('thumb_additional')};
    centers{names_map('wrist_bottom_right')} = centers{names_map('wrist_bottom_right')} + 6 * [0; 0; 1] - 6 * [0; 1; 0];
    radii{names_map('wrist_bottom_right')}  = 0.9 * radii{names_map('wrist_bottom_right')};
end

if strcmp(user_name, 'thomas');
    centers{names_map('palm_index')} = centers{names_map('palm_index')} - 4 * [1; 0; 0];
    centers{names_map('palm_thumb')} = centers{names_map('palm_thumb')} + 3 * [0; 1; 0] + 2 * [1; 0; 0];
    centers{names_map('wrist_bottom_right')} = centers{names_map('wrist_bottom_right')} - 15 * [0; 1; 0] + 3 * [1; 0; 0];
    centers{names_map('wrist_bottom_left')} = centers{names_map('wrist_bottom_left')} - 20 * [0; 1; 0] - 3 * [1; 0; 0];
    radii{names_map('thumb_additional')} = 0.95 * radii{names_map('thumb_additional')};
    radii{names_map('thumb_top')} = 0.95 * radii{names_map('thumb_top')};
    radii{names_map('middle_top')} = 0.92 * radii{names_map('middle_top')};
    radii{names_map('index_top')} = 0.95 * radii{names_map('index_top')};
end

if strcmp(user_name, 'pei-i');
    radii{names_map('thumb_top')} = 0.93 * radii{names_map('thumb_top')};
    radii{names_map('thumb_additional')} = 0.93 * radii{names_map('thumb_additional')};
end

%% Adjust radii
if strcmp(user_name, 'andrii') 
    factor = 1;
end
if strcmp(user_name, 'thomas') 
    factor = 1;
end
if strcmp(user_name, 'pei-i') 
    factor = 1;
end
radii{names_map('thumb_base')} = factor * radii{names_map('thumb_base')};
radii{names_map('thumb_bottom')} = factor * radii{names_map('thumb_bottom')};
radii{names_map('thumb_middle')} = factor * radii{names_map('thumb_middle')};
radii{names_map('thumb_top')} = factor * radii{names_map('thumb_top')};
radii{names_map('thumb_additional')} = factor * radii{names_map('thumb_additional')};
radii{names_map('index_top')} = factor * radii{names_map('index_top')};
radii{names_map('index_middle')} = factor * radii{names_map('index_middle')};
radii{names_map('index_base')} = factor * radii{names_map('index_base')};
radii{names_map('middle_top')} = factor * radii{names_map('middle_top')};
radii{names_map('middle_middle')} = factor * radii{names_map('middle_middle')};
radii{names_map('middle_base')} = factor * radii{names_map('middle_base')};
radii{names_map('ring_top')} = factor * radii{names_map('ring_top')};
radii{names_map('ring_middle')} = factor * radii{names_map('ring_middle')};
radii{names_map('ring_base')} = factor * radii{names_map('ring_base')};
radii{names_map('pinky_top')} = factor * radii{names_map('pinky_top')};
radii{names_map('pinky_middle')} = factor * radii{names_map('pinky_middle')};
radii{names_map('pinky_base')} = factor * radii{names_map('pinky_base')};


%% Display
figure; hold on; axis off; axis equal;
display_skeleton(centers, [], blocks, [], false, 'b');


%% Scale
num_phalanges = 17;
if strcmp(user_name, 'andrii')    
    scaling_factor = 0.78;
end
if strcmp(user_name, 'thomas')    
    scaling_factor = 0.79;
end
if strcmp(user_name, 'pei-i')    
    scaling_factor = 0.8;
end
scaling_factor = 1/scaling_factor;
for i = 1:length(centers)
    centers{i} = scaling_factor * centers{i};
    radii{i} = scaling_factor * radii{i};
end
for i = 1:num_phalanges
    phalanges{i}.local(1:3, 4) = scaling_factor * phalanges{i}.local(1:3, 4);
end


%% Write model
write_cpp_model(['C:/Developer/data/models/', user_name, '/'], centers, radii, blocks, phalanges);




