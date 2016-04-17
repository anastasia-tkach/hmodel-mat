semantics_path = '_my_hand/semantics/';
load([semantics_path, 'fitting/names_map.mat']);
load([semantics_path, 'fitting/blocks.mat'], 'blocks');
blocks = blocks(1:30);

%% Pose my hand model
my_hand_path = '_my_hand/final/';
load([my_hand_path, 'phalanges.mat'], 'phalanges');
load([my_hand_path, 'dofs.mat'], 'dofs');
load([my_hand_path, 'centers.mat']);
load([my_hand_path, 'radii.mat']);

num_theta = 29;
theta = zeros(num_theta, 1);
phalanges = initialize_offsets(centers, phalanges, names_map);
phalanges = htrack_move(theta, dofs, phalanges);
centers = update_centers(centers, phalanges, names_map);

theta(11) = pi/8; 
phalanges = htrack_move(theta, dofs, phalanges);
centers = update_centers(centers, phalanges, names_map);
% display_result(centers, [], [], blocks, radii, false, 1, 'big'); view([-180, -90]); camlight; drawnow;

%% Load user-specific model
input_path = 'realsense_fitting/andrii/final/';
load([input_path, 'poses.mat']);
load([input_path, 'radii.mat']);
load([input_path, 'blocks.mat']);



centers = poses{1}.centers;
data_points = poses{1}.points;

rotation_axis = [0; 0; 1];
rotation_angle = pi/15;
scaling_factor = 1.2321;
for i = 1:length(centers)
    centers{i} = scaling_factor * centers{i};
    radii{i} = scaling_factor * radii{i};
end
for i = 1:length(data_points)
    data_points{i} = scaling_factor * data_points{i};
end

R = makehgtform('axisrotate', rotation_axis, rotation_angle);
shift = centers{names_map('palm_back')};
for i = 1:length(centers)
    centers{i} = centers{i} - shift;
    centers{i} = transform(centers{i}, R);    
    
end
for i = 1:length(data_points)
    data_points{i} = data_points{i} -  shift;
    data_points{i} = transform(data_points{i}, R);
end

down = [0; -1; 0];
left = [1; 0; 0];
front = [0; 0; -1];

centers{names_map('pinky_base')} = centers{names_map('pinky_base')} - 3 * front;
centers{names_map('index_membrane')} = centers{names_map('index_membrane')} - 4 * front + 4 * left;
centers{names_map('middle_membrane')} = centers{names_map('middle_membrane')} - 5 * front + 4 * left;
centers{names_map('ring_membrane')} = centers{names_map('ring_membrane')} - 1 * front + 3 * left;
centers{names_map('palm_middle')} = centers{names_map('palm_middle')} + 4 * left;
centers{names_map('palm_pinky')} = centers{names_map('palm_pinky')} - 3 * front;
% figure; hold on; axis off; axis equal;
% display_skeleton(centers, radii, blocks, [], false, 'r');
display_result(centers, [], [], blocks, radii, false, 1, 'big'); %mypoints(data_points, [0.7, 0, 0.9]);
view([-180, -90]); camlight; drawnow;

%% Compute initial transformation
% Thumb
phalanges{2}.local(1:3, 4) = centers{names_map('thumb_base')} - centers{names_map('palm_back')};
phalanges{3}.local(2, 4) = norm(centers{names_map('thumb_bottom')} - centers{names_map('thumb_base')});
phalanges{4}.local(2, 4) = norm(centers{names_map('thumb_middle')} - centers{names_map('thumb_bottom')}); 

% Pinky
phalanges{5}.local(1:3, 4) = centers{names_map('pinky_base')} - centers{names_map('palm_back')};
phalanges{6}.local(2, 4) = norm(centers{names_map('pinky_bottom')} - centers{names_map('pinky_base')});
phalanges{7}.local(2, 4) = norm(centers{names_map('pinky_middle')} - centers{names_map('pinky_bottom')}); 

% Ring
phalanges{8}.local(1:3, 4) = centers{names_map('ring_base')} - centers{names_map('palm_back')};
phalanges{9}.local(2, 4) = norm(centers{names_map('ring_bottom')} - centers{names_map('ring_base')});
phalanges{10}.local(2, 4) = norm(centers{names_map('ring_middle')} - centers{names_map('ring_bottom')}); 

% Middle
phalanges{11}.local(1:3, 4) = centers{names_map('middle_base')} - centers{names_map('palm_back')};
phalanges{12}.local(2, 4) = norm(centers{names_map('middle_bottom')} - centers{names_map('middle_base')});
phalanges{13}.local(2, 4) = norm(centers{names_map('middle_middle')} - centers{names_map('middle_bottom')}); 

% Index
phalanges{14}.local(1:3, 4) = centers{names_map('index_base')} - centers{names_map('palm_back')};
phalanges{15}.local(2, 4) = norm(centers{names_map('index_bottom')} - centers{names_map('index_base')});
phalanges{16}.local(2, 4) = norm(centers{names_map('index_middle')} - centers{names_map('index_bottom')}); 

%% Pose
num_theta = 29;
theta = zeros(num_theta, 1);
phalanges = initialize_offsets(centers, phalanges, names_map);
phalanges = htrack_move(theta, dofs, phalanges);
[centers] = update_centers(centers, phalanges, names_map);

display_result(centers, [], [], blocks, radii, false, 1, 'big');
%mypoints(data_points, [0.7, 0, 0.9]);
view([-180, -90]); camlight; drawnow;

%% Write model
path = 'C:\Developer\hmodel-cuda-build\data\hmodel\';
write_cpp_model(path, centers, radii, blocks, phalanges);


