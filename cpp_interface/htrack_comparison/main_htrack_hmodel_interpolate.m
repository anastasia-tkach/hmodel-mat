close all; clear; clc;
semantics_path = '_my_hand/semantics/';
load([semantics_path, 'fitting/names_map.mat']);
names_map1 = names_map;
load([semantics_path, 'fitting/blocks.mat']);
blocks = blocks(1:28);

%% centers
translations = {};
centers = {};
translations{names_map('thumb_base')} = [20 10 -10];
translations{names_map('thumb_bottom')} = [0 45 0];
translations{names_map('thumb_middle')} = [0 25 0];
translations{names_map('thumb_top')} = [0 24 0];
centers{names_map('thumb_base')} = translations{names_map('thumb_base')};
centers{names_map('thumb_bottom')} = centers{names_map('thumb_base')} + translations{names_map('thumb_bottom')};
centers{names_map('thumb_middle')} = centers{names_map('thumb_bottom')} + translations{names_map('thumb_middle')};
centers{names_map('thumb_top')} = centers{names_map('thumb_middle')} + translations{names_map('thumb_top')};
centers{names_map('thumb_additional')} = centers{names_map('thumb_top')};

translations{names_map('pinky_base')} = [-30 80 0];
translations{names_map('pinky_bottom')} = [0 25 0];
translations{names_map('pinky_middle')} = [0 18 0];
translations{names_map('pinky_top')} = [0 12 0];
centers{names_map('pinky_base')} = translations{names_map('pinky_base')};
centers{names_map('pinky_bottom')} = centers{names_map('pinky_base')} + translations{names_map('pinky_bottom')};
centers{names_map('pinky_middle')} = centers{names_map('pinky_bottom')} + translations{names_map('pinky_middle')};
centers{names_map('pinky_top')} = centers{names_map('pinky_middle')} + translations{names_map('pinky_top')};

translations{names_map('ring_base')} = [-10 80 0];
translations{names_map('ring_bottom')} = [0 38 0];
translations{names_map('ring_middle')} = [0 22.8 0];
translations{names_map('ring_top')} = [0 15.2 0];
centers{names_map('ring_base')} = translations{names_map('ring_base')};
centers{names_map('ring_bottom')} = centers{names_map('ring_base')} + translations{names_map('ring_bottom')};
centers{names_map('ring_middle')} = centers{names_map('ring_bottom')} + translations{names_map('ring_middle')};
centers{names_map('ring_top')} = centers{names_map('ring_middle')} + translations{names_map('ring_top')};

translations{names_map('middle_base')} = [10 80 0];
translations{names_map('middle_bottom')} = [0 45 0];
translations{names_map('middle_middle')} = [0 24 0];
translations{names_map('middle_top')} = [0 16 0];
centers{names_map('middle_base')} = translations{names_map('middle_base')};
centers{names_map('middle_bottom')} = centers{names_map('middle_base')} + translations{names_map('middle_bottom')};
centers{names_map('middle_middle')} = centers{names_map('middle_bottom')} + translations{names_map('middle_middle')};
centers{names_map('middle_top')} = centers{names_map('middle_middle')} + translations{names_map('middle_top')};

translations{names_map('index_base')} = [30 80 0];
translations{names_map('index_bottom')} = [0 38 0];
translations{names_map('index_middle')} = [0 22.8 0];
translations{names_map('index_top')} = [0 15.2 0];
centers{names_map('index_base')} = translations{names_map('index_base')};
centers{names_map('index_bottom')} = centers{names_map('index_base')} + translations{names_map('index_bottom')};
centers{names_map('index_middle')} = centers{names_map('index_bottom')} + translations{names_map('index_middle')};
centers{names_map('index_top')} = centers{names_map('index_middle')} + translations{names_map('index_top')};

u = 41.6; d = 30; z = 10.8; a = 72;
centers{names_map('palm_index')} = a * [0, 1, 0] + u * [1, 0, 0] - z * [1, 0, 0];
centers{names_map('palm_pinky')} = a * [0, 1, 0] - u * [1, 0, 0] + z * [1, 0, 0];
centers{names_map('palm_left')} = d * [1, 0, 0] - z * [1, 0, 0];
centers{names_map('palm_right')} = - d * [1, 0, 0] + z * [1, 0, 0];

centers{names_map('palm_middle')} =  a * [0, 1, 0] + u/3 * [1, 0, 0] - 4 * [1, 0, 0];
centers{names_map('palm_ring')} =  a * [0, 1, 0] - u/3 * [1, 0, 0] + 4 * [1, 0, 0];
centers{names_map('palm_back')} =  [0, 0, 0];
centers{names_map('palm_thumb')} = centers{names_map('thumb_base')};

centers{names_map('pinky_membrane')} = centers{names_map('pinky_base')};
centers{names_map('ring_membrane')} = centers{names_map('ring_base')};
centers{names_map('middle_membrane')} = centers{names_map('middle_base')};
centers{names_map('index_membrane')} = centers{names_map('index_base')};

centers{names_map('thumb_fold')} =  centers{names_map('thumb_base')};

%% radii
radii = {};
radii{names_map('thumb_base')} = 17;
radii{names_map('thumb_bottom')} = 9.5;
radii{names_map('thumb_middle')} = 8.5;
radii{names_map('thumb_top')} = 7.5;

radii{names_map('pinky_base')} = 8.5;
radii{names_map('pinky_bottom')} = 7.7;
radii{names_map('pinky_middle')} = 6.6;
radii{names_map('pinky_top')} = 6.4;

radii{names_map('ring_base')} = 9;
radii{names_map('ring_bottom')} = 8.2;
radii{names_map('ring_middle')} = 7.1;
radii{names_map('ring_top')} = 6.4;

radii{names_map('middle_base')} = 9;
radii{names_map('middle_bottom')} = 8.2;
radii{names_map('middle_middle')} = 7.1;
radii{names_map('middle_top')} = 6.4;

radii{names_map('index_base')} = 9;
radii{names_map('index_bottom')} = 8.2;
radii{names_map('index_middle')} = 7.1;
radii{names_map('index_top')} = 6.4;

radii{names_map('palm_pinky')} = z + 0.001 * randn;
radii{names_map('palm_ring')} = 1.3 * z + 0.001 * randn;
radii{names_map('palm_middle')} = 1.3 * z + 0.001 * randn;
radii{names_map('palm_index')} = z + 0.001 * randn;

radii{names_map('palm_thumb')} = 3;
radii{names_map('palm_back')} = 1.2 * z + 0.001 * randn;
radii{names_map('palm_right')} = z + 0.001 * randn;
radii{names_map('palm_left')} = z + 0.001 * randn;

radii{names_map('pinky_membrane')} = 2;
radii{names_map('ring_membrane')} = 2;
radii{names_map('middle_membrane')} = 2;
radii{names_map('index_membrane')} = 2;

radii{names_map('thumb_additional')} = 7.4;
radii{names_map('thumb_fold')} = 5;

for i = 1:length(centers)
    centers{i} = centers{i}';
end

input_path = 'C:/Developer/data/models/anastasia/';
[hmodel_centers, hmodel_radii, blocks, ~, phalanges, ~] = read_cpp_model(input_path);
centers(35:38) = hmodel_centers(35:38);
radii(35:38) = hmodel_radii(35:38);

%% Intepolate
interplated_radii = cell(length(centers), 1);
interplated_centers = cell(length(centers), 1);
num_frames = 5; i = 4; % i = 1 - hmodel, i = 5 - htrack

for o = 1:length(centers)
    d1 = hmodel_centers{o};
    d2 = centers{o};
    interplated_centers{o} = d1 + (i - 1) * (d2 - d1)/(num_frames - 1);
    
    d1 = hmodel_radii{o};
    d2 = radii{o};
    interplated_radii{o} = d1 + (i - 1) * (d2 - d1)/(num_frames - 1);
end
centers = interplated_centers;
radii = interplated_radii;
figure; hold on; axis off; axis equal;
display_skeleton(centers, [], blocks, [], false, 'r');

%% Get phalanges
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

%% Pose
num_thetas = 29;
[~, dofs] = hmodel_parameters();
theta = zeros(num_thetas, 1);
posed_phalanges = htrack_move(theta, dofs, phalanges);
posed_phalanges = initialize_offsets(centers, posed_phalanges, names_map);
posed_phalanges = htrack_move(zeros(num_thetas, 1), dofs, posed_phalanges);
centers = update_centers(centers, posed_phalanges, names_map);

n = norm(centers{names_map('thumb_top')} - centers{names_map('thumb_middle')});
d = norm(centers{names_map('thumb_middle')} - centers{names_map('thumb_bottom')});
centers{names_map('thumb_top')} = centers{names_map('thumb_middle')} + n / d * (centers{names_map('thumb_middle')} - centers{names_map('thumb_bottom')});

n = norm(centers{names_map('thumb_additional')} - centers{names_map('thumb_middle')});
d = norm(centers{names_map('thumb_middle')} - centers{names_map('thumb_bottom')});
centers{names_map('thumb_additional')} = centers{names_map('thumb_middle')} + n / d * (centers{names_map('thumb_middle')} - centers{names_map('thumb_bottom')});

n = norm(centers{names_map('index_top')} - centers{names_map('index_middle')});
d = norm(centers{names_map('index_middle')} - centers{names_map('index_bottom')});
centers{names_map('index_top')} = centers{names_map('index_middle')} + n / d * (centers{names_map('index_middle')} - centers{names_map('index_bottom')});

n = norm(centers{names_map('middle_top')} - centers{names_map('middle_middle')});
d = norm(centers{names_map('middle_middle')} - centers{names_map('middle_bottom')});
centers{names_map('middle_top')} = centers{names_map('middle_middle')} + n / d * (centers{names_map('middle_middle')} - centers{names_map('middle_bottom')});

n = norm(centers{names_map('ring_top')} - centers{names_map('ring_middle')});
d = norm(centers{names_map('ring_middle')} - centers{names_map('ring_bottom')});
centers{names_map('ring_top')} = centers{names_map('ring_middle')} + n / d * (centers{names_map('ring_middle')} - centers{names_map('ring_bottom')});

n = norm(centers{names_map('pinky_top')} - centers{names_map('pinky_middle')});
d = norm(centers{names_map('pinky_middle')} - centers{names_map('pinky_bottom')});
centers{names_map('pinky_top')} = centers{names_map('pinky_middle')} + n / d * (centers{names_map('pinky_middle')} - centers{names_map('pinky_bottom')});

num_thetas = 29;
[~, dofs] = hmodel_parameters();
theta = zeros(num_thetas, 1);
posed_phalanges = htrack_move(theta, dofs, phalanges);
posed_phalanges = initialize_offsets(centers, posed_phalanges, names_map);
posed_phalanges = htrack_move(zeros(num_thetas, 1), dofs, posed_phalanges);
centers = update_centers(centers, posed_phalanges, names_map);
figure; hold on; axis off; axis equal;
display_skeleton(centers, [], blocks, [], false, 'b');

%% Display result
% display_result(centers, [], [], blocks, radii, false, 1, 'big');
% view([-180, -90]);
% camlight; drawnow;

write_cpp_model(['C:/Developer/data/models/htrack/'], centers, radii, blocks, phalanges);




