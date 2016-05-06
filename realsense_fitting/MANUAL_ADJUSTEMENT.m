clc; clear; close all;
user_name = 'thomas';

input_path = 'C:/Developer/data/models/template/';
semantics_path = '_my_hand/semantics/';
load([semantics_path, 'fitting/names_map.mat']);
[centers, radii, blocks, ~, ~, mean_centers] = read_cpp_model(input_path);
disp('DEAL WITH MEAN CENTERS');

thumb_rotation = 1;

%% Uniform scaling
if strcmp(user_name, 'anastasia')
    vertical_scaling = 1;
    horisontal_scaling = 0.83;
    width_scaling = 1.1;
end

if strcmp(user_name, 'andrii')    
    vertical_scaling = 1.12;
    horisontal_scaling = 1.05;
    width_scaling = 1.1;%1.4;  
end

if strcmp(user_name, 'thomas')
    vertical_scaling = 1.07;
    horisontal_scaling = 1;
    width_scaling = 1.02;  
    
    factor = 1;
end

Tv = diag([1, vertical_scaling, 1]);
Th = diag([horisontal_scaling, 1, 1]);
thumb_base_before = centers{names_map('thumb_base')};
for i = 1:length(centers)
    centers{i} = Tv * Th * centers{i};
end
for i = 1:length(radii)
    radii{i} = width_scaling * radii{i};
end

%% Non-uniform Anastasia
if strcmp(user_name, 'anastasia')
    thumb_1_length = norm(centers{names_map('thumb_base')} - centers{names_map('thumb_bottom')});
    thumb_2_length = norm(centers{names_map('thumb_bottom')} - centers{names_map('thumb_middle')});
    thumb_3_length = norm(centers{names_map('thumb_middle')} - centers{names_map('thumb_top')});
    thumb_4_length = norm(centers{names_map('thumb_middle')} - centers{names_map('thumb_additional')});
    
    index_1_length = norm(centers{names_map('index_base')} - centers{names_map('index_bottom')});
    index_2_length = norm(centers{names_map('index_bottom')} - centers{names_map('index_middle')});
    index_3_length = norm(centers{names_map('index_middle')} - centers{names_map('index_top')});
    
    middle_1_length = norm(centers{names_map('middle_base')} - centers{names_map('middle_bottom')});
    middle_2_length = norm(centers{names_map('middle_bottom')} - centers{names_map('middle_middle')});
    middle_3_length = norm(centers{names_map('middle_middle')} - centers{names_map('middle_top')});
    
    ring_1_length = norm(centers{names_map('ring_base')} - centers{names_map('ring_bottom')});
    ring_2_length = norm(centers{names_map('ring_bottom')} - centers{names_map('ring_middle')});
    ring_3_length = norm(centers{names_map('ring_middle')} - centers{names_map('ring_top')});
    
    pinky_1_length = norm(centers{names_map('pinky_base')} - centers{names_map('pinky_bottom')});
    pinky_2_length = norm(centers{names_map('pinky_bottom')} - centers{names_map('pinky_middle')});
    pinky_3_length = norm(centers{names_map('pinky_middle')} - centers{names_map('pinky_top')});
  
    thumb_rotation = 1;
    
    centers{names_map('thumb_base')} = centers{names_map('thumb_base')} + 10 * [1; 0; 0] + 7 * [0; 0; 1] + 7 * [0; 1; 0];
    centers{names_map('index_base')} = centers{names_map('index_base')} + 3 * [1; 0; 0];
    centers{names_map('pinky_base')} = centers{names_map('pinky_base')} - 2 * [0; 1; 0] -  1 * [1; 0; 0];
    
    centers{names_map('palm_index')} = centers{names_map('palm_index')} + 4 * [1; 0; 0];
    centers{names_map('palm_thumb')} = centers{names_map('palm_thumb')} + 4 * [1; 0; 0];
    
    radii{names_map('thumb_base')} = 27;
    radii{names_map('thumb_bottom')} = 18;
    radii{names_map('thumb_middle')} = 10;
    radii{names_map('index_top')} = 8;
    radii{names_map('index_middle')} = 8.7;
    radii{names_map('middle_top')} = 8;
    radii{names_map('middle_middle')} = 9;
    radii{names_map('ring_top')} = 7.5;
    radii{names_map('ring_middle')} = 8.2;
    radii{names_map('pinky_top')} = 7;
    radii{names_map('pinky_middle')} = 7.3;

    radii{names_map('thumb_base')} = 23;
    radii{names_map('thumb_bottom')} = 15;
end
   
%% Non-uniform Andrii
if strcmp(user_name, 'andrii')
    thumb_1_length = 1.12 * 33;
    thumb_2_length = 1.12 * 32;
    thumb_3_length = 1.12 * 28;
    thumb_4_length = 1.12 * 37;
    
    index_1_length = 50;
    index_2_length = 24;
    index_3_length = 21;
    
    middle_1_length = 51;
    middle_2_length = 29;
    middle_3_length = 20;
    
    ring_1_length = 45;
    ring_2_length = 26;
    ring_3_length = 22;
    
    pinky_1_length = 33;
    pinky_2_length = 23;
    pinky_3_length = 20;
    
    thumb_rotation = 1;
    
    radii{names_map('thumb_base')} = 27;
    radii{names_map('thumb_bottom')} = 18;
end

%% Non-uniform Thomas
if strcmp(user_name, 'thomas')    
    thumb_1_length = factor * norm(centers{names_map('thumb_base')} - centers{names_map('thumb_bottom')});
    thumb_2_length = factor * norm(centers{names_map('thumb_bottom')} - centers{names_map('thumb_middle')});
    thumb_3_length = factor * norm(centers{names_map('thumb_middle')} - centers{names_map('thumb_top')});
    thumb_4_length = factor * norm(centers{names_map('thumb_middle')} - centers{names_map('thumb_additional')});
    
    index_1_length = norm(centers{names_map('index_base')} - centers{names_map('index_bottom')});
    index_2_length = norm(centers{names_map('index_bottom')} - centers{names_map('index_middle')});
    index_3_length = norm(centers{names_map('index_middle')} - centers{names_map('index_top')});
    
    middle_1_length = norm(centers{names_map('middle_base')} - centers{names_map('middle_bottom')});
    middle_2_length = norm(centers{names_map('middle_bottom')} - centers{names_map('middle_middle')});
    middle_3_length = norm(centers{names_map('middle_middle')} - centers{names_map('middle_top')});
    
    ring_1_length = norm(centers{names_map('ring_base')} - centers{names_map('ring_bottom')});
    ring_2_length = norm(centers{names_map('ring_bottom')} - centers{names_map('ring_middle')});
    ring_3_length = norm(centers{names_map('ring_middle')} - centers{names_map('ring_top')});
    
    pinky_1_length = norm(centers{names_map('pinky_base')} - centers{names_map('pinky_bottom')});
    pinky_2_length = norm(centers{names_map('pinky_bottom')} - centers{names_map('pinky_middle')});
    pinky_3_length = norm(centers{names_map('pinky_middle')} - centers{names_map('pinky_top')});
end
    
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
        R = makehgtform('axisrotate', [0; 1; 0], -pi/15);
        phalanges{i}.local(1:3, 1:3) = R(1:3, 1:3);
    end
    % ring base
    if i == 8
        R = makehgtform('axisrotate', [0; 1; 0], -pi/30);
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
phalanges{3}.local(2, 4) = thumb_1_length;
phalanges{4}.local(2, 4) = thumb_2_length;
centers{names_map('thumb_top')} = centers{names_map('thumb_middle')} + thumb_3_length * phalanges{2}.local(1:3, 1:3) * [0; 1; 0];
centers{names_map('thumb_additional')} = centers{names_map('thumb_middle')} + thumb_4_length * phalanges{2}.local(1:3, 1:3) *  [0; 1; 0];

%% Index
phalanges{14}.local(1:3, 4) = centers{names_map('index_base')} - centers{names_map('palm_back')};
phalanges{15}.local(2, 4) = index_1_length;
phalanges{16}.local(2, 4) = index_2_length;
centers{names_map('index_top')} = centers{names_map('index_middle')} + index_3_length * [0; 1; 0];

%% Middle
phalanges{11}.local(1:3, 4) = centers{names_map('middle_base')} - centers{names_map('palm_back')};
phalanges{12}.local(2, 4) = middle_1_length;
phalanges{13}.local(2, 4) = middle_2_length;
centers{names_map('middle_top')} = centers{names_map('middle_middle')} + middle_3_length * [0; 1; 0];

%% Ring
phalanges{8}.local(1:3, 4) = centers{names_map('ring_base')} - centers{names_map('palm_back')};
phalanges{9}.local(2, 4) = ring_1_length;
phalanges{10}.local(2, 4) = ring_2_length;
centers{names_map('ring_top')} = centers{names_map('ring_middle')} + ring_3_length * [0; 1; 0];

%% Pinky
phalanges{5}.local(1:3, 4) = centers{names_map('pinky_base')} - centers{names_map('palm_back')};
phalanges{6}.local(2, 4) = pinky_1_length;
phalanges{7}.local(2, 4) = pinky_2_length;
centers{names_map('pinky_top')} = centers{names_map('pinky_middle')} + pinky_3_length * [0; 1; 0];

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







