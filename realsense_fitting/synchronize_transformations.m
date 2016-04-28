function [poses, alpha, phalanges] = synchronize_transformations(poses, radii, blocks, alpha, names_map, real_membrane_offset, display)

down = [0; -1; 0];
left = [1; 0; 0];
front = [0; 0; -1];

num_poses = length(poses);
num_alpha_thetas = 5 + num_poses * 4;

%% Unapply rigid degrees of freedom

%figure; axis off; axis equal; hold on;
for p = 1:num_poses
    Rx = makehgtform('axisrotate', [1; 0; 0], - poses{p}.init_theta(4));
    Ry = makehgtform('axisrotate', [0; 1; 0], - poses{p}.init_theta(5));
    Rz = makehgtform('axisrotate', [0; 0; 1], - poses{p}.init_theta(6));
    
    poses{p}.init_transform =  Rz * Ry * Rx;
    for i = 1:length(poses{p}.centers)
        poses{p}.centers{i} = transform(poses{p}.centers{i}, poses{p}.init_transform);
    end   
end

%% Rotate together
palm_indices = [names_map('palm_right'), names_map('palm_back'), names_map('palm_left'), ...
    names_map('palm_pinky'), names_map('palm_ring'), names_map('palm_middle'), names_map('palm_index'), names_map('palm_thumb'), ...
    names_map('pinky_base'), names_map('ring_base'), names_map('middle_base'), names_map('index_base'), names_map('thumb_base')];

reference_id = 1;
%figure; hold on; axis off; axis equal;
%display_skeleton(poses{reference_id}.centers, [], blocks, [], false, 'b');
for p = 1:num_poses
    if p == reference_id
        poses{p}.transform = eye(4, 4);
        continue;
    end
    P = cell(length(palm_indices), 1);
    Q = cell(length(palm_indices), 1);
    for i = 1:length(palm_indices)
        P{i} = poses{reference_id}.centers{palm_indices(i)};
        Q{i} = poses{p}.centers{palm_indices(i)};
    end
    [poses{p}.transform, ~] = find_rigid_transformation(P, Q, false);
    for i = 1:length(poses{p}.centers)
        poses{p}.centers{i} = transform(poses{p}.centers{i}, poses{p}.transform);
    end
    
    %display_skeleton(poses{reference_id}.centers, [], blocks, [], false, 'b');
    %display_skeleton(poses{p}.centers, [], blocks, [], false, 'b');
    
    %display_result(poses{p}.centers, [], [], blocks, radii, false, 0.9, 'big');
    %mypoints(poses{p}.points, [0.8, 0.1, 0.9]);
    %view([-180, -90]); camlight; drawnow;
end

%% Assemble initial guess
max_finger_tilt = 0.05;
trust_region = 0.05 * ones(num_alpha_thetas, 1);
max_negative_theta = -1.8;
% max_finger_tilt = 1;
% trust_region = 1 * ones(num_alpha_thetas, 1);
% trust_region(4:5) = 1;


alpha_theta_0_thumb = zeros(num_alpha_thetas, 1);
alpha_theta_0_index = zeros(num_alpha_thetas, 1);
alpha_theta_0_middle = zeros(num_alpha_thetas, 1);
alpha_theta_0_ring = zeros(num_alpha_thetas, 1);
alpha_theta_0_pinky = zeros(num_alpha_thetas, 1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%alpha_theta_0_thumb(1:5) = [alpha{2}; alpha{3}(3); alpha{4}(3)];
alpha_theta_0_thumb(1:5) = [alpha{2}; alpha{3}(2); alpha{4}(3)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
alpha_theta_0_index(1:5) = [alpha{14}; alpha{15}(3); alpha{16}(3)];
alpha_theta_0_middle(1:5) = [alpha{11}; alpha{12}(3); alpha{13}(3)];
alpha_theta_0_ring(1:5) = [alpha{8}; alpha{9}(3); alpha{10}(3)];
alpha_theta_0_pinky(1:5) = [alpha{5}; alpha{6}(3); alpha{7}(3)];

for p = 1:num_poses
    indices = 5 + (4 * (p - 1) + 1:4 * p);
    alpha_theta_0_thumb(indices) = poses{p}.theta(10:13);
    alpha_theta_0_index(indices) = poses{p}.theta(14:17);
    alpha_theta_0_middle(indices) = poses{p}.theta(18:21);
    alpha_theta_0_ring(indices) = poses{p}.theta(22:25);
    alpha_theta_0_pinky(indices) = poses{p}.theta(26:29);
end

[phalanges, dofs] = hmodel_parameters();
for i = 1:length(phalanges)
    phalanges{i}.local = eye(4, 4);
    phalanges{i}.length = 0;
end

% Thumb
lower_bound = alpha_theta_0_thumb - trust_region;
upper_bound = alpha_theta_0_thumb + trust_region;
lower_bound(5) = max(lower_bound(5), -max_finger_tilt);
upper_bound(5) = min(upper_bound(5), max_finger_tilt);
thumb_indices = [names_map('thumb_base'), names_map('thumb_bottom'), names_map('thumb_middle'), names_map('thumb_top')];
[M1, M2, M3, L, alpha_thumb, theta_thumb] = compute_initial_transformation_many_poses(poses, thumb_indices, lower_bound, upper_bound, alpha_theta_0_thumb, 'thumb');
phalanges{2}.local = M1; phalanges{3}.local = M2; phalanges{4}.local = M3;
phalanges{2}.length = L(1); phalanges{3}.length = L(2); phalanges{4}.length = L(3);

% Index
lower_bound = alpha_theta_0_index - trust_region;
upper_bound = alpha_theta_0_index + trust_region;
lower_bound(4:5) = max(lower_bound(4:5), -max_finger_tilt);
upper_bound(4:5) = min(upper_bound(4:5), max_finger_tilt);
index_indices = [names_map('index_base'), names_map('index_bottom'), names_map('index_middle'), names_map('index_top')];
[M1, M2, M3, L, alpha_index, theta_index] = compute_initial_transformation_many_poses(poses, index_indices, lower_bound, upper_bound, alpha_theta_0_index, 'finger');
%alpha_index = alpha_theta_0_index(1:5);
%theta_index = alpha_theta_0_index(6:end);
phalanges{14}.local = M1; phalanges{15}.local = M2; phalanges{16}.local = M3;
phalanges{14}.length = L(1); phalanges{15}.length = L(2); phalanges{16}.length = L(3);

% Middle
lower_bound = alpha_theta_0_middle - trust_region;
upper_bound = alpha_theta_0_middle + trust_region;
lower_bound(4:5) = max(lower_bound(4:5), -max_finger_tilt);
upper_bound(4:5) = min(upper_bound(4:5), max_finger_tilt);
middle_indices = [names_map('middle_base'), names_map('middle_bottom'), names_map('middle_middle'), names_map('middle_top')];
[M1, M2, M3, L, alpha_middle, theta_middle] = compute_initial_transformation_many_poses(poses, middle_indices, lower_bound, upper_bound, alpha_theta_0_middle, 'finger');
% alpha_middle = alpha_theta_0_middle(1:5);
% theta_middle = alpha_theta_0_middle(6:end);
phalanges{11}.local = M1; phalanges{12}.local = M2; phalanges{13}.local = M3;
phalanges{11}.length = L(1); phalanges{12}.length = L(2); phalanges{13}.length = L(3);

% Ring
lower_bound = alpha_theta_0_ring - trust_region;
upper_bound = alpha_theta_0_ring + trust_region;
lower_bound(4:5) = max(lower_bound(4:5), -max_finger_tilt);
upper_bound(4:5) = min(upper_bound(4:5), max_finger_tilt);
ring_indices = [names_map('ring_base'), names_map('ring_bottom'), names_map('ring_middle'), names_map('ring_top')];
[M1, M2, M3, L, alpha_ring, theta_ring] = compute_initial_transformation_many_poses(poses, ring_indices, lower_bound, upper_bound, alpha_theta_0_ring, 'finger');
% alpha_ring = alpha_theta_0_ring(1:5);
% theta_ring = alpha_theta_0_ring(6:end);
phalanges{8}.local = M1; phalanges{9}.local = M2; phalanges{10}.local = M3;
phalanges{8}.length = L(1); phalanges{9}.length = L(2); phalanges{10}.length = L(3);

% Pinky
lower_bound = alpha_theta_0_pinky - trust_region;
upper_bound = alpha_theta_0_pinky + trust_region;
lower_bound(4:5) = max(lower_bound(4:5), -max_finger_tilt);
upper_bound(4:5) = min(upper_bound(4:5), max_finger_tilt);
pinky_indices = [names_map('pinky_base'), names_map('pinky_bottom'), names_map('pinky_middle'), names_map('pinky_top')];
[M1, M2, M3, L, alpha_pinky, theta_pinky] = compute_initial_transformation_many_poses(poses, pinky_indices, lower_bound, upper_bound, alpha_theta_0_pinky, 'finger');
% alpha_pinky = alpha_theta_0_pinky(1:5);
% theta_pinky = alpha_theta_0_pinky(6:end);
phalanges{5}.local = M1; phalanges{6}.local = M2; phalanges{7}.local = M3;
phalanges{5}.length = L(1); phalanges{6}.length = L(2); phalanges{7}.length = L(3);

%% Set parameters
parameters = cell(num_poses, 1);
for p = 1:num_poses
    indices = 4 * (p - 1) + 1:4 * p;
    parameters{p}(10:13) = theta_thumb(indices);
    parameters{p}(14:17) = theta_index(indices);
    parameters{p}(18:21) = theta_middle(indices);
    parameters{p}(22:25) = theta_ring(indices);
    parameters{p}(26:29) = theta_pinky(indices);
    
    %parameters{p}([16, 17, 20, 21, 24, 25, 28, 29]) = max(parameters{p}([16, 17, 20, 21, 24, 25, 28, 29]), max_negative_theta);
    %parameters{p}([16, 17, 20, 21, 24, 25, 28, 29]) = max(parameters{p}([16, 17, 20, 21, 24, 25, 28, 29]), max_negative_theta);
end

%% Save
% Thumb
alpha{2} = alpha_thumb(1:3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%alpha{3}(3) = alpha_thumb(4);
alpha{3}(2) = alpha_thumb(4);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
alpha{4}(3) = alpha_thumb(5);
% Index
alpha{14} = alpha_index(1:3);
alpha{15}(3) = alpha_index(4);
alpha{16}(3) = alpha_index(5);
% Middle
alpha{11} = alpha_middle(1:3);
alpha{12}(3) = alpha_middle(4);
alpha{13}(3) = alpha_middle(5);
% Ring
alpha{8} = alpha_ring(1:3);
alpha{9}(3) = alpha_ring(4);
alpha{10}(3) = alpha_ring(5);
% Pinky
alpha{5} = alpha_pinky(1:3);
alpha{6}(3) = alpha_pinky(4);
alpha{7}(3) = alpha_pinky(5);

for p = 1:num_poses
    poses{p}.theta = parameters{p}';
    
    poses{p}.sync_centers = cell(length(poses{p}.centers), 1);
    phalanges_i = htrack_move(parameters{p}, dofs, phalanges);
    % Thumb
    poses{p}.sync_centers{names_map('thumb_bottom')} = transform([0; 0; 0], phalanges_i{3}.global);
    poses{p}.sync_centers{names_map('thumb_middle')} = transform([0; 0; 0], phalanges_i{4}.global);
    poses{p}.sync_centers{names_map('thumb_top')} = transform([0; phalanges_i{4}.length; 0], phalanges_i{4}.global);
    thumb_additional_length = norm(poses{p}.centers{names_map('thumb_additional')} - poses{p}.centers{names_map('thumb_middle')});
    poses{p}.sync_centers{names_map('thumb_additional')} = transform([0; thumb_additional_length; 0], phalanges_i{4}.global);
    poses{p}.sync_centers{names_map('thumb_fold')} = project_point_on_triangle(poses{p}.centers{names_map('thumb_fold')}, ...
        poses{p}.centers{names_map('palm_thumb')}, poses{p}.centers{names_map('thumb_base')}, poses{p}.centers{names_map('thumb_bottom')});
    
    % Index
    poses{p}.sync_centers{names_map('index_bottom')} = transform([0; 0; 0], phalanges_i{15}.global);
    poses{p}.sync_centers{names_map('index_middle')} = transform([0; 0; 0], phalanges_i{16}.global);
    poses{p}.sync_centers{names_map('index_top')} = transform([0; phalanges_i{16}.length; 0], phalanges_i{16}.global);  
    l = poses{p}.centers{names_map('index_bottom')} - poses{p}.centers{names_map('index_base')};
    q = poses{p}.centers{names_map('index_base')} + real_membrane_offset(1) * l / norm(l);
    poses{p}.sync_centers{names_map('index_membrane')} =  q + (0.5 * radii{names_map('index_base')} + 0.5 * radii{names_map('index_bottom')} -  radii{names_map('index_membrane')}) ...
        * phalanges{14}.local(1:3, 1:3) * (front);
    % Middle
    poses{p}.sync_centers{names_map('middle_bottom')} = transform([0; 0; 0], phalanges_i{12}.global);
    poses{p}.sync_centers{names_map('middle_middle')} = transform([0; 0; 0], phalanges_i{13}.global);
    poses{p}.sync_centers{names_map('middle_top')} = transform([0; phalanges_i{13}.length; 0], phalanges_i{13}.global);  
    l = poses{p}.centers{names_map('middle_bottom')} - poses{p}.centers{names_map('middle_base')};
    q = poses{p}.centers{names_map('middle_base')} + real_membrane_offset(2) * l / norm(l);
    poses{p}.sync_centers{names_map('middle_membrane')} = q + (0.5 * radii{names_map('middle_base')} + 0.5 * radii{names_map('middle_bottom')} - radii{names_map('middle_membrane')}) ...
        * phalanges{11}.local(1:3, 1:3) * (front);
    % Ring
    poses{p}.sync_centers{names_map('ring_bottom')} = transform([0; 0; 0], phalanges_i{9}.global);
    poses{p}.sync_centers{names_map('ring_middle')} = transform([0; 0; 0], phalanges_i{10}.global);
    poses{p}.sync_centers{names_map('ring_top')} = transform([0; phalanges_i{10}.length; 0], phalanges_i{10}.global);    
    l = poses{p}.centers{names_map('ring_bottom')} - poses{p}.centers{names_map('ring_base')};
    q = poses{p}.centers{names_map('ring_base')} + real_membrane_offset(3) * l / norm(l);
    poses{p}.sync_centers{names_map('ring_membrane')} = q + (0.5 * radii{names_map('ring_base')} + 0.5 * radii{names_map('ring_bottom')} - radii{names_map('ring_membrane')}) ...
        * phalanges{8}.local(1:3, 1:3) * (front);
    % Pinky
    poses{p}.sync_centers{names_map('pinky_bottom')} = transform([0; 0; 0], phalanges_i{6}.global);
    poses{p}.sync_centers{names_map('pinky_middle')} = transform([0; 0; 0], phalanges_i{7}.global);
    poses{p}.sync_centers{names_map('pinky_top')} = transform([0; phalanges_i{7}.length; 0], phalanges_i{7}.global);
    l = poses{p}.centers{names_map('pinky_bottom')} - poses{p}.centers{names_map('pinky_base')};
    q = poses{p}.centers{names_map('pinky_base')} + real_membrane_offset(3) * l / norm(l);
    poses{p}.sync_centers{names_map('pinky_membrane')} = q + (0.5 * radii{names_map('pinky_base')} + 0.5 * radii{names_map('pinky_bottom')} - radii{names_map('pinky_membrane')}) ...
        * phalanges{5}.local(1:3, 1:3) * (front);
    
    % Display
    % mypoints(poses{p}.sync_centers, 'c');
end

%% Display rotated
%{
if (display)
    for p = 1:num_poses
        phalanges_i = htrack_move(parameters{p}, dofs, phalanges);
        points = {};
        for i = 2:length(phalanges) - 3
            base = transform([0; 0; 0], phalanges_i{i}.global);
            tip = transform([0; phalanges_i{i}.length; 0], phalanges_i{i}.global);
            points{end + 1} = base; points{end + 1} = tip;
        end
        figure; hold on; axis off; axis equal;
        display_skeleton(poses{p}.centers, [], blocks, [], false, 'b');
        for i = 1:length(points)/2
            myline(points{2 * (i - 1) + 1}, points{2 * i}, 'm');
        end
    end
end
%}

%% Rotate back
for p = 1:num_poses
    
    %% Unrotate from adjustment
    for i = 1:length(poses{p}.centers)
        poses{p}.centers{i} = transform(poses{p}.centers{i}, inv(poses{p}.transform));
        if ~isempty(poses{p}.sync_centers{i})
            poses{p}.sync_centers{i} = transform(poses{p}.sync_centers{i}, inv(poses{p}.transform));
        end
    end
    
    %% Unrotate to initial position
    for i = 1:length(poses{p}.centers)
        poses{p}.centers{i} = transform(poses{p}.centers{i}, inv(poses{p}.init_transform));
        if ~isempty(poses{p}.sync_centers{i})
            poses{p}.sync_centers{i} = transform(poses{p}.sync_centers{i}, inv(poses{p}.init_transform));
        end
    end
    
    if (display)
        figure; hold on; axis off; axis equal;
        display_skeleton(poses{p}.centers, [], blocks, [], false, 'b');
        mypoints(poses{p}.sync_centers, 'r', 50);
    end
end

