%%
format shortg;
clear; clc; close all;
settings.mode = 'fitting';
settings_default;
downscaling_factor = 4;
settings.H = 480/downscaling_factor;
settings.W = 640/downscaling_factor;

%{
    From previou5s experience
    - Do not set w2 high, it interferes with other energies
    - Set w5 quite high
%}
w1 = 4;
w2 = 0.1; %0.02
w4 = 16;
w5 = 10; % 100
w7 = 600;
w8 = 0.01;
settings.damping = damping;
settings.w1 = w1; settings.w2 = w2; settings.w3 = w3;
settings.w4 = w4; settings.w5 = w5; settings.w7 = w7; settings.w8 = w8;
settings.energy7 = false;
settings.discard_threshold = 0.5;
settings.block_safety_factor = 1.3;

data_root = 'C:/Developer/data/MATLAB/';
load([data_root, '/stage.mat']);
load([data_root, '/user_name.mat']);
load([data_root, '/real_membrane_offset.mat']);
load([data_root, '/real_phalanges_length.mat']);
input_path = [data_root, user_name, '/stage', num2str(stage), '/initial/'];
output_path = [data_root, user_name, '/stage', num2str(stage), '/final/'];
semantics_path = '_my_hand/semantics/';

%% Load input
load([input_path, 'blocks.mat']);
load([input_path, 'poses.mat']);
load([input_path, 'radii.mat']);
load([input_path, 'alpha.mat']);
load([input_path, 'phalanges.mat']);
%poses = poses(4);

load([semantics_path, 'fitting/names_map.mat']);
solid_blocks = {
    % fingers
    [names_map('pinky_top'), names_map('pinky_middle')]; [names_map('pinky_middle'), names_map('pinky_bottom')]; [names_map('pinky_bottom'), names_map('pinky_base')];
    [names_map('ring_top'), names_map('ring_middle')]; [names_map('ring_middle'), names_map('ring_bottom')]; [names_map('ring_bottom'), names_map('ring_base')];
    [names_map('middle_top'), names_map('middle_middle')]; [names_map('middle_middle'), names_map('middle_bottom')]; [names_map('middle_bottom'), names_map('middle_base')];
    [names_map('index_top'), names_map('index_middle')]; [names_map('index_middle'), names_map('index_bottom')]; [names_map('index_bottom'), names_map('index_base')];
    % thumb
    [names_map('thumb_additional'), names_map('thumb_top')]; [names_map('thumb_top'), names_map('thumb_middle')];
    [names_map('thumb_middle'), names_map('thumb_bottom')]; [names_map('thumb_bottom'), names_map('thumb_base'), names_map('thumb_fold')];
    % palm
    [names_map('palm_right'), names_map('palm_back'), names_map('palm_left'), ...
    names_map('palm_pinky'), names_map('palm_ring'), names_map('palm_middle'), names_map('palm_index'), names_map('palm_thumb'), ...
    names_map('pinky_base'), names_map('ring_base'), names_map('middle_base'), names_map('index_base'), names_map('thumb_base')];
    % wrist
    [names_map('wrist_top_left'), names_map('wrist_top_right'), names_map('wrist_bottom_left'), names_map('wrist_bottom_right')];
    %{
    % membranes
    [names_map('palm_pinky'), names_map('pinky_membrane')];
    [names_map('palm_ring'), names_map('ring_membrane')];
    [names_map('palm_middle'), names_map('middle_membrane')];
    [names_map('palm_index'), names_map('index_membrane')];
    %}
    };
for i = 1:length(radii)
    radii{i} = radii{i} + 0.01 * randn;
end

[blocks] = reindex(radii, blocks);
num_centers = length(radii); num_poses = length(poses);

for p = 1:length(poses)
    poses{p}.data_bounding_box = compute_data_bounding_box(poses{p}.points);
    poses{p}.init_centers = poses{p}.centers;
end
history{1}.poses = poses; history{1}.radii = radii;

%% Optimizaion

settings.num_centers = num_centers;
settings.solid_blocks = solid_blocks;
settings.names_map = names_map;
settings.real_membrane_offset = real_membrane_offset;
settings.real_phalanges_length = real_phalanges_length;

X0 = zeros(num_poses * D * num_centers + num_centers, 1);
Xl = -inf * ones(num_poses * D * num_centers + num_centers, 1);
Xu = inf * ones(num_poses * D * num_centers + num_centers, 1);
num_poses = length(poses);
for p = 1:num_poses
    c = zeros(num_centers * D, 1);
    for o = 1:num_centers
        c(D * o - D + 1:D * o) = poses{p}.centers{o};
    end
    X0(D * num_centers * (p - 1) + 1:D * num_centers * p) = c;
    
end
for o = 1:num_centers
    X0(D * num_poses * num_centers + o) = radii{o};
    if o < 20
        Xl(D * num_poses * num_centers + o) = 0.95 * radii{o};        
        Xu(D * num_poses * num_centers + o) = 1.1 * radii{o};
    else
        Xl(D * num_poses * num_centers + o) = 0.7 * radii{o};
        Xu(D * num_poses * num_centers + o) = 1.3 * radii{o};
    end
end

options = optimoptions(@lsqnonlin, 'Algorithm', 'levenberg-marquardt', 'InitDamping', 0.1, 'Jacobian','on', 'MaxIter', 100);
iter = 1;
save poses poses;
save alpha alpha;
save phalanges phalanges;
save iter iter;
X = lsqnonlin(@(X) energies_lsqnonlin(X, blocks, settings), X0, Xl, Xu, options);

%% Load result
D = 3;
load X;
load phalanges;
num_centers = settings.num_centers;
num_poses = length(poses);
for p = 1:num_poses
    c = X(D * num_centers * (p - 1) + 1:D * num_centers * p);
    for o = 1:num_centers
        poses{p}.centers{o} = c(D * o - D + 1:D * o);
    end
end
for o = 1:num_centers
    radii{o} = X(D * num_poses * num_centers + o);
end
for p = 1:num_poses
    shift = poses{p}.centers{settings.names_map('palm_back')};
    for i = 1:length(poses{p}.centers)
        poses{p}.centers{i} = poses{p}.centers{i} - shift;
    end
    for i = 1:length(poses{p}.points)
        poses{p}.points{i} = poses{p}.points{i} - shift;
    end
end

%% Display
for p = 1:length(poses)
    %[poses{p}.indices, poses{p}.projections, poses{p}.block_indices] = compute_projections(poses{p}.points, poses{p}.centers, blocks, radii);
    %display_result(poses{p}.centers, poses{p}.points, poses{p}.projections, blocks, radii, true, 1, 'big');
    %view([-180, -90]); camlight; drawnow;    
    display_result(poses{p}.centers, [], [], blocks, radii, false, 0.9, 'big');
    mypoints(poses{p}.points, [0.8, 0.1, 0.9]);
    view([-180, -90]); camlight; drawnow;    
    %figure; axis off; axis equal; hold on;
    %display_skeleton(poses{p}.centers, radii, blocks, poses{p}.points, false, []);
end

%% Store the results
save([output_path, 'poses.mat'], 'poses');
save([output_path, 'radii.mat'], 'radii');
save([output_path, 'blocks.mat'], 'blocks');
save([output_path, 'alpha.mat'], 'alpha');
save([output_path, 'phalanges.mat'], 'phalanges');

% Send data to hmodel-cpp
send_results_to_cpp(poses, radii, blocks, phalanges, names_map);
