%% Load HModel
clc;  clear;
input_path = '_my_hand/final/';
semantics_path = '_my_hand/semantics/';
load([semantics_path, 'fitting/names_map.mat']);
load([semantics_path, 'fitting/blocks.mat'], 'blocks');
load([input_path, 'centers.mat'], 'centers');
load([input_path, 'radii.mat'], 'radii');
load([input_path, 'phalanges.mat'], 'phalanges');
load([input_path, 'dofs.mat'], 'dofs');

num_thetas = 29;
num_phalanges = 17;

%% Read cpp data
path = 'C:\Developer\hmodel-cuda-build\data\';

%[cpp_centers, cpp_radii, cpp_blocks, theta, mean_centers] = read_cpp_model(path);
%[data_points, model_points] = read_cpp_correspondences(path, mean_centers);
theta = zeros(num_thetas, 1);
mean_centers = [0; 0; 0];

%% Prepare model
% phalanges{2}.local = [-0.305523 0.319439 0.897003 11.9827; -0.766703 0.4761 -0.430691 4.77063; -0.564642 -0.819321 0.0994552 -8.82215; 0 0 0 1];
% phalanges{5}.local = [-0.900232 -0.384875 0.203599 -22.3011; -0.395267 0.918495 -0.0114239 55.3039; -0.182608 -0.0907602 -0.978988 8.49853; 0 0 0 1];
% phalanges{8}.local = [ -0.98734 -0.158012 0.0138762 -7.30926; -0.15862 0.983554 -0.0863733 60.5; 0 -0.0874808 -0.996166 13.3052; 0 0 0 1];
% phalanges{11}.local = [ -0.992608 -0.0159037 -0.120316 10.0192; -0.0199468 0.999274 0.0324749 65.167; 0.119712 0.0346348 -0.992204 12.9937; 0 0 0 1];
% phalanges{14}.local = [-0.958713 0.152076 -0.240296 31.2899; 0.135245 0.987147 0.0851439 62.6124; 0.250155 0.0491297 -0.966958 6.51402; 0 0 0 1];
phalanges{17}.local = eye(4, 4); phalanges{17}.global = eye(4, 4);
% scaling_factor = 0.811646;
% for i = 1:length(centers)
%     centers{i} = scaling_factor * centers{i};
%     radii{i} = scaling_factor * radii{i};
% end
% for i = 1:num_phalanges
%     phalanges{i}.local(1:3, 4) = scaling_factor * phalanges{i}.local(1:3, 4);
% end

% phalanges = htrack_move(theta, dofs, phalanges);
% centers = update_centers(centers, phalanges, names_map);

centers{35} = centers{names_map('palm_back')} + [5; -10; 0];
centers{36} = centers{names_map('palm_back')} + [-5; -10; 0];
centers{37} = centers{names_map('palm_back')} + [5; -50; 0];
centers{38} = centers{names_map('palm_back')} + [-5; -50; 0];

phalanges = initialize_offsets(centers, phalanges, names_map);
for i = 1:length(phalanges), phalanges{i}.init_local = phalanges{i}.local; end

%display_result(centers, data_points, model_points, blocks, radii, true, 1, 'big'); %view([-180, -90]); camlight;

figure; hold on; axis off; axis equal;

% blocks = blocks(1:28);
% blocks{29} = [26, 37];

[posed_centers] = pose_hand_model(theta, dofs, phalanges, centers, names_map, mean_centers);
display_skeleton(posed_centers, radii, blocks, [], false, 'b');

%% Pose model
for i = -1.5:0.3:1.5
    theta(8) = i;
    theta(9) = 0;
    [posed_centers] = pose_hand_model(theta, dofs, phalanges, centers, names_map, mean_centers);
    display_skeleton(posed_centers, radii, blocks, [], false, 'b');
end
% rot_axis = transform(dofs{8}.axis', phalanges{17}.init_local);
% myvector(posed_centers{names_map('palm_back')}, rot_axis, 30, 'r');

for i = -1.5:0.3:1.5
    theta(8) = 0;
    theta(9) = i;    
    [posed_centers] = pose_hand_model(theta, dofs, phalanges, centers, names_map, mean_centers);
    display_skeleton(posed_centers, radii, blocks, [], false, 'r');
end


%% Display skeletons
% figure; hold on; axis off; axis equal;
% display_skeleton(cpp_centers, cpp_radii, cpp_blocks, [], false, 'm');
% for i = 1:length(centers), centers{i} = centers{i} - mean_centers; end
% display_skeleton(centers, radii, blocks, [], false, 'b');

