%clc; clear; close all;

input_path = 'C:/Developer/data/models/anastasia/';

[centers, radii, blocks, theta, ~, mean_centers] = read_cpp_model(input_path);

T = diag([1.2, 1, 1]);
for i = 1:length(centers)
    centers{i} = T * centers{i};
    radii{i} = radii{i} * 1.05;
end

semantics_path = '_my_hand/semantics/';
load([semantics_path, 'fitting/names_map.mat']);
[phalanges, dofs] = hmodel_parameters();

%% Adjust fingers bases
down = [0; -1; 0];
left = [1; 0; 0];
front = [0; 0; -1];
centers{names_map('middle_base')} = centers{names_map('middle_base')} + 4 * left;
centers{names_map('ring_base')} = centers{names_map('ring_base')} + 3 * left;
centers{names_map('palm_middle')} = centers{names_map('palm_middle')} + 7 * left;
centers{names_map('palm_ring')} = centers{names_map('palm_ring')} + 4 * left;

%% Set up template transformations
for i = 1:length(phalanges)   
    phalanges{i}.local = eye(4, 4);
    % thumb base
    if i == 2       
        Rx = makehgtform('axisrotate', [1; 0; 0], pi);
        Rz = makehgtform('axisrotate', [0; 0; 1], pi/2);    
        phalanges{i}.local = Rz * Rx;
    end
    % thumb bottom
    if i == 3
        phalanges{i}.local = makehgtform('axisrotate', [0; 1; 0], pi/3); 
    end
    % pinky base
    if i == 5 
        phalanges{i}.local = makehgtform('axisrotate', [0; 1; 0], -pi/5);  
    end
    % ring base
    if i == 8
        phalanges{i}.local = makehgtform('axisrotate', [0; 1; 0], -pi/10);    
    end
    % middle base
    if i == 11
        phalanges{i}.local = makehgtform('axisrotate', [0; 1; 0], pi/20);    
    end
    % index base
    if i == 14
        phalanges{i}.local = makehgtform('axisrotate', [0; 1; 0], pi/10);    
    end
end
% Thumb
factor = 0.9;
phalanges{2}.local(1:3, 4) = factor * (centers{names_map('thumb_base')} - centers{names_map('palm_back')});
phalanges{3}.local(2, 4) = factor * norm(centers{names_map('thumb_bottom')} - centers{names_map('thumb_base')});
phalanges{4}.local(2, 4) = factor * norm(centers{names_map('thumb_middle')} - centers{names_map('thumb_bottom')});
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
phalanges{6}.local(2, 4) = norm(centers{names_map('pinky_bottom')} - centers{names_map('pinky_base')});
phalanges{7}.local(2, 4) = norm(centers{names_map('pinky_middle')} - centers{names_map('pinky_bottom')});

%% Tips locations
centers{names_map('thumb_additional')} = centers{names_map('thumb_middle')} + norm(centers{names_map('thumb_additional')} - centers{names_map('thumb_middle')}) * phalanges{2}.local(1:3, 1:3) *  [0; 1; 0];
centers{names_map('thumb_top')} = centers{names_map('thumb_middle')} + norm(centers{names_map('thumb_top')} - centers{names_map('thumb_middle')}) *  phalanges{2}.local(1:3, 1:3) * [0; 1; 0];
centers{names_map('index_top')} = centers{names_map('index_middle')} + norm(centers{names_map('index_top')} - centers{names_map('index_middle')}) * [0; 1; 0];
centers{names_map('middle_top')} = centers{names_map('middle_middle')} + norm(centers{names_map('middle_top')} - centers{names_map('middle_middle')}) * [0; 1; 0];
centers{names_map('ring_top')} = centers{names_map('ring_middle')} + norm(centers{names_map('ring_top')} - centers{names_map('ring_middle')}) * [0; 1; 0];
centers{names_map('pinky_top')} = centers{names_map('pinky_middle')} + norm(centers{names_map('pinky_top')} - centers{names_map('pinky_middle')}) * [0; 1; 0];

centers{names_map('thumb_fold')} = centers{names_map('thumb_bottom')} + 0.3 * radii{names_map('thumb_bottom')} * ...
    (centers{names_map('thumb_fold')} - centers{names_map('thumb_bottom')}) / norm(centers{names_map('thumb_fold')} - centers{names_map('thumb_bottom')});

%% Pose
num_thetas = 29;
theta = zeros(num_thetas, 1);
phalanges = htrack_move(theta, dofs, phalanges);
phalanges = initialize_offsets(centers, phalanges, names_map);
for i = 1:length(phalanges), phalanges{i}.init_local = phalanges{i}.local; end

theta = zeros(num_thetas, 1);
theta(10) = -0.3;
phalanges = htrack_move(theta, dofs, phalanges);
centers = update_centers(centers, phalanges, names_map);

%% Adjust membranes
q = project_point_on_segment(centers{names_map('pinky_membrane')}, centers{names_map('pinky_base')}, centers{names_map('pinky_bottom')});
centers{names_map('pinky_membrane')} = q + (0.5 * radii{names_map('pinky_base')} + 0.5 * radii{names_map('pinky_bottom')} - radii{names_map('pinky_membrane')}) * front;

q = project_point_on_segment(centers{names_map('ring_membrane')}, centers{names_map('ring_base')}, centers{names_map('ring_bottom')});
centers{names_map('ring_membrane')} = q + (0.5 * radii{names_map('ring_base')} + 0.5 * radii{names_map('ring_bottom')} - radii{names_map('ring_membrane')}) * front;

q = project_point_on_segment(centers{names_map('middle_membrane')}, centers{names_map('middle_base')}, centers{names_map('middle_bottom')});
centers{names_map('middle_membrane')} = q + (0.5 * radii{names_map('middle_base')} + 0.5 * radii{names_map('middle_bottom')} - radii{names_map('middle_membrane')}) * front;

q = project_point_on_segment(centers{names_map('index_membrane')}, centers{names_map('index_base')}, centers{names_map('index_bottom')});
centers{names_map('index_membrane')} = q + (0.5 * radii{names_map('index_base')} + 0.5 * radii{names_map('index_bottom')} - radii{names_map('index_membrane')}) * front;

centers{names_map('thumb_fold')} = project_point_on_triangle(centers{names_map('thumb_fold')}, centers{names_map('palm_thumb')}, centers{names_map('thumb_base')}, centers{names_map('thumb_bottom')});

phalanges = initialize_offsets(centers, phalanges, names_map);
centers = update_centers(centers, phalanges, names_map);

%% Display
% display_result(centers, [], [], blocks, radii, false, 1, 'big');
% view([-180, -90]); camlight; drawnow;

figure; hold on; axis off; axis equal;
display_skeleton(centers, [], blocks, [], false, 'b');

%% Explore thumb poses
% figure; hold on; axis off; axis equal;
% for i = -1.5:0.3:1.5
%     theta(10) = i;
%     theta(11) = 0;
%     [posed_centers] = pose_hand_model(theta, dofs, phalanges, centers, names_map, [0; 0; 0]);
%     display_skeleton(posed_centers, radii, blocks, [], false, 'b');
% end
% 
% figure; hold on; axis off; axis equal;
% for i = -1.5:0.3:1.5
%     theta(10) = -0.6;
%     theta(11) = i;    
%     [posed_centers] = pose_hand_model(theta, dofs, phalanges, centers, names_map, [0; 0; 0]);
%     display_skeleton(posed_centers, radii, blocks, [], false, 'r');
% end

write_cpp_model('C:/Developer/data/models/template/', centers, radii, blocks, phalanges);







