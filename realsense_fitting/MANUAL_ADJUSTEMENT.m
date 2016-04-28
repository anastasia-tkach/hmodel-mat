clc; clear; close all;
user_name = 'andrii';

input_path = 'C:/Developer/data/models/template/';
semantics_path = '_my_hand/semantics/';
load([semantics_path, 'fitting/names_map.mat']);
[centers, radii, blocks, ~, ~, mean_centers] = read_cpp_model(input_path);
disp('DEAL WITH MEAN CENTERS');

%% Uniform scaling

if strcmp(user_name, 'anastasia')
    vertical_scaling = 1;
    horisontal_scaling = 0.9;
    width_scaling = 0.94;
    
    thumb_1_scaling = 1;
    thumb_2_scaling = 1;
    thumb_3_scaling = 1;
    
    pinky_scaling = 1;
    
    thumb_rotation = 1;
end

if strcmp(user_name, 'andrii')
    vertical_scaling = 1.07;
    horisontal_scaling = 0.95;
    width_scaling = 1.12;
    
    thumb_1_length = 38;
    thumb_2_length = 34;
    thumb_3_length = 15;
    thumb_4_length = 21;
    
    index_1_length = 50;
    index_2_length = 26;
    index_3_length = 17;
    
    middle_1_length = 51;
    middle_2_length = 31;
    middle_3_length = 16;
    
    ring_1_length = 52;
    ring_2_length = 29;
    ring_3_length = 19;
    
    pinky_1_length = 40;
    pinky_2_length = 19;
    pinky_3_length = 14;
    
    thumb_rotation = 1;
end

T = diag([horisontal_scaling, vertical_scaling, 1]);
thumb_base_before = centers{names_map('thumb_base')};
for i = 1:length(centers)
    if i == names_map('thumb_bottom') || i == names_map('thumb_middle') || i == names_map('thumb_top') || i == names_map('thumb_additional')
        continue;
    end
    centers{i} = T * centers{i};
end

for i = 1:length(radii)
    radii{i} = width_scaling * radii{i};
end

centers{names_map('thumb_bottom')} = centers{names_map('thumb_bottom')}  - thumb_base_before + centers{names_map('thumb_base')};
centers{names_map('thumb_middle')} = centers{names_map('thumb_middle')}  - thumb_base_before + centers{names_map('thumb_base')};
centers{names_map('thumb_top')} = centers{names_map('thumb_top')}  - thumb_base_before + centers{names_map('thumb_base')};
centers{names_map('thumb_additional')} = centers{names_map('thumb_additional')}  - thumb_base_before + centers{names_map('thumb_base')};
centers{names_map('thumb_base')} = centers{names_map('thumb_base')} + 20 * [1; 0; 0];

%% Adjust up template transformations
[phalanges, dofs] = hmodel_parameters();
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
        phalanges{i}.local = makehgtform('axisrotate', [0; 1; 0], thumb_rotation);
    end
    % pinky base
    if i == 5
        R = makehgtform('axisrotate', [0; 1; 0], -pi/10);
        phalanges{i}.local(1:3, 1:3) = R(1:3, 1:3);
    end
    % ring base
    if i == 8
        R = makehgtform('axisrotate', [0; 1; 0], -pi/15);
        phalanges{i}.local(1:3, 1:3) = R(1:3, 1:3);
    end
    % middle base
    if i == 11
        R = makehgtform('axisrotate', [0; 1; 0], pi/20);
        phalanges{i}.local(1:3, 1:3) = R(1:3, 1:3);
    end
    % index base
    if i == 14
        R = makehgtform('axisrotate', [0; 1; 0], pi/10);
        phalanges{i}.local(1:3, 1:3) = R(1:3, 1:3);
    end
end

%% Re-compute initial transformations

%% Thumb
phalanges{2}.local(1:3, 4) = centers{names_map('thumb_base')} - centers{names_map('palm_back')};
% phalanges{3}.local(2, 4) = thumb_1_scaling * norm(centers{names_map('thumb_bottom')} - centers{names_map('thumb_base')});
% phalanges{4}.local(2, 4) = thumb_2_scaling * norm(centers{names_map('thumb_middle')} - centers{names_map('thumb_bottom')});
phalanges{3}.local(2, 4) = thumb_1_length;
phalanges{4}.local(2, 4) = thumb_2_length;
centers{names_map('thumb_top')} = centers{names_map('thumb_middle')} + thumb_3_length * phalanges{2}.local(1:3, 1:3) * [0; 1; 0];
centers{names_map('thumb_additional')} = centers{names_map('thumb_middle')} + thumb_4_length * phalanges{2}.local(1:3, 1:3) *  [0; 1; 0];

%% Index
phalanges{14}.local(1:3, 4) = centers{names_map('index_base')} - centers{names_map('palm_back')};
% phalanges{15}.local(2, 4) = norm(centers{names_map('index_bottom')} - centers{names_map('index_base')});
% phalanges{16}.local(2, 4) = norm(centers{names_map('index_middle')} - centers{names_map('index_bottom')});
phalanges{15}.local(2, 4) = index_1_length;
phalanges{16}.local(2, 4) = index_2_length;
centers{names_map('index_top')} = centers{names_map('index_middle')} + index_3_length * [0; 1; 0];

%% Middle
phalanges{11}.local(1:3, 4) = centers{names_map('middle_base')} - centers{names_map('palm_back')};
% phalanges{12}.local(2, 4) = norm(centers{names_map('middle_bottom')} - centers{names_map('middle_base')});
% phalanges{13}.local(2, 4) = norm(centers{names_map('middle_middle')} - centers{names_map('middle_bottom')});
phalanges{12}.local(2, 4) = middle_1_length;
phalanges{13}.local(2, 4) = middle_2_length;
centers{names_map('middle_top')} = centers{names_map('middle_middle')} + middle_3_length * [0; 1; 0];

%% Ring
phalanges{8}.local(1:3, 4) = centers{names_map('ring_base')} - centers{names_map('palm_back')};
% phalanges{9}.local(2, 4) = norm(centers{names_map('ring_bottom')} - centers{names_map('ring_base')});
% phalanges{10}.local(2, 4) = norm(centers{names_map('ring_middle')} - centers{names_map('ring_bottom')});
phalanges{9}.local(2, 4) = ring_1_length;
phalanges{10}.local(2, 4) = ring_2_length;
centers{names_map('ring_top')} = centers{names_map('ring_middle')} + ring_3_length * [0; 1; 0];

%% Pinky
phalanges{5}.local(1:3, 4) = centers{names_map('pinky_base')} - centers{names_map('palm_back')};
% phalanges{6}.local(2, 4) = pinky_scaling * norm(centers{names_map('pinky_bottom')} - centers{names_map('pinky_base')});
% phalanges{7}.local(2, 4) = pinky_scaling * norm(centers{names_map('pinky_middle')} - centers{names_map('pinky_bottom')});
phalanges{6}.local(2, 4) = pinky_1_length;
phalanges{7}.local(2, 4) = pinky_2_length;
centers{names_map('pinky_top')} = centers{names_map('pinky_middle')} + pinky_3_length * [0; 1; 0];

% centers{names_map('thumb_additional')} = centers{names_map('thumb_middle')} + thumb_3_scaling * norm(centers{names_map('thumb_additional')} - centers{names_map('thumb_middle')}) * phalanges{2}.local(1:3, 1:3) *  [0; 1; 0];
% centers{names_map('thumb_top')} = centers{names_map('thumb_middle')} + thumb_3_scaling * norm(centers{names_map('thumb_top')} - centers{names_map('thumb_middle')}) *  phalanges{2}.local(1:3, 1:3) * [0; 1; 0];
% centers{names_map('index_top')} = centers{names_map('index_middle')} + norm(centers{names_map('index_top')} - centers{names_map('index_middle')}) * [0; 1; 0];
% centers{names_map('middle_top')} = centers{names_map('middle_middle')} + norm(centers{names_map('middle_top')} - centers{names_map('middle_middle')}) * [0; 1; 0];
% centers{names_map('ring_top')} = centers{names_map('ring_middle')} + norm(centers{names_map('ring_top')} - centers{names_map('ring_middle')}) * [0; 1; 0];
% centers{names_map('pinky_top')} = centers{names_map('pinky_middle')} + pinky_scaling * norm(centers{names_map('pinky_top')} - centers{names_map('pinky_middle')}) * [0; 1; 0];

theta = zeros(29, 1);
phalanges = htrack_move(theta, dofs, phalanges);
phalanges = initialize_offsets(centers, phalanges, names_map);
theta = zeros(29, 1); theta(10) = -0.3;
phalanges = htrack_move(theta, dofs, phalanges);
centers = update_centers(centers, phalanges, names_map);

%% Pass to cpp
figure; hold on; axis off; axis equal;
display_skeleton(centers, [], blocks, [], false, 'b');

write_cpp_model('C:/Developer/data/models/anonymous/', centers, radii, blocks, phalanges);







