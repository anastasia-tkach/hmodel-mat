function [sync_centers, parameters, phalanges] = optimize_theta(pose, radii, blocks, initial_rotations, names_map, real_membrane_offset, display)

[phalanges, dofs] = hmodel_parameters();

%{
display = true;
user_name = 'andrii';
stage = 1;
data_root = 'C:/Developer/data/MATLAB/';
input_path = [data_root, user_name, '/stage', num2str(stage), '/'];
semantics_path = '_my_hand/semantics/';
load([semantics_path, 'fitting/names_map.mat']);
load([input_path, 'initial/poses.mat']);
load([input_path, 'initial/radii.mat']);
load([input_path, 'initial/blocks.mat']);
load([input_path, 'initial/alpha.mat']);
load([data_root, '/real_membrane_offset.mat']);

[phalanges, dofs] = read_cpp_phalanges([input_path, '1/']);
%}

centers = pose.centers;
init_theta = pose.init_theta;
theta = pose.theta;

front = [0; 0; -1];
%% Unapply rigid degrees of freedom

Rx = makehgtform('axisrotate', [1; 0; 0], - init_theta(4));
Ry = makehgtform('axisrotate', [0; 1; 0], - init_theta(5));
Rz = makehgtform('axisrotate', [0; 0; 1], - init_theta(6));

init_transform =  Rz * Ry * Rx;
for i = 1:length(centers)
    centers{i} = transform(centers{i}, init_transform);
end

%% Assemble initial guess
trust_region = 0.2 * ones(4, 1);

% alpha_thumb = [alpha{2}; alpha{3}(2); alpha{4}(3)];
% alpha_index = [alpha{14}; alpha{15}(3); alpha{16}(3)];
% alpha_middle = [alpha{11}; alpha{12}(3); alpha{13}(3)];
% alpha_ring = [alpha{8}; alpha{9}(3); alpha{10}(3)];
% alpha_pinky = [alpha{5}; alpha{6}(3); alpha{7}(3)];

theta_0_thumb = theta(10:13);
theta_0_index = theta(14:17);
theta_0_middle = theta(18:21);
theta_0_ring = theta(22:25);
theta_0_pinky = theta(26:29);

% Thumb
lower_bound = theta_0_thumb - trust_region;
upper_bound = theta_0_thumb + trust_region;
thumb_indices = [names_map('thumb_base'), names_map('thumb_bottom'), names_map('thumb_middle'), names_map('thumb_top')];
[theta_thumb, M1, M2, M3, L] = optimize_theta_finger(centers, thumb_indices, lower_bound, upper_bound, initial_rotations(2:4), theta_0_thumb, 'thumb');
phalanges{2}.local = M1; phalanges{3}.local = M2; phalanges{4}.local = M3;
phalanges{2}.length = L(1); phalanges{3}.length = L(2); phalanges{4}.length = L(3);

% Index
lower_bound = theta_0_index - trust_region;
upper_bound = theta_0_index + trust_region;
index_indices = [names_map('index_base'), names_map('index_bottom'), names_map('index_middle'), names_map('index_top')];
[theta_index, M1, M2, M3, L] = optimize_theta_finger(centers, index_indices, lower_bound, upper_bound, initial_rotations(14:16), theta_0_index, 'finger');
phalanges{14}.local = M1; phalanges{15}.local = M2; phalanges{16}.local = M3;
phalanges{14}.length = L(1); phalanges{15}.length = L(2); phalanges{16}.length = L(3);

% Middle
lower_bound = theta_0_middle - trust_region;
upper_bound = theta_0_middle + trust_region;
middle_indices = [names_map('middle_base'), names_map('middle_bottom'), names_map('middle_middle'), names_map('middle_top')];
[theta_middle, M1, M2, M3, L] = optimize_theta_finger(centers, middle_indices, lower_bound, upper_bound, initial_rotations(11:13), theta_0_middle, 'finger');
phalanges{11}.local = M1; phalanges{12}.local = M2; phalanges{13}.local = M3;
phalanges{11}.length = L(1); phalanges{12}.length = L(2); phalanges{13}.length = L(3);

% Ring
lower_bound = theta_0_ring - trust_region;
upper_bound = theta_0_ring + trust_region;
ring_indices = [names_map('ring_base'), names_map('ring_bottom'), names_map('ring_middle'), names_map('ring_top')];
[theta_ring, M1, M2, M3, L] = optimize_theta_finger(centers, ring_indices, lower_bound, upper_bound, initial_rotations(8:10), theta_0_ring, 'finger');
phalanges{8}.local = M1; phalanges{9}.local = M2; phalanges{10}.local = M3;
phalanges{8}.length = L(1); phalanges{9}.length = L(2); phalanges{10}.length = L(3);

% Pinky
lower_bound = theta_0_pinky - trust_region;
upper_bound = theta_0_pinky + trust_region;
pinky_indices = [names_map('pinky_base'), names_map('pinky_bottom'), names_map('pinky_middle'), names_map('pinky_top')];
[theta_pinky, M1, M2, M3, L] = optimize_theta_finger(centers, pinky_indices, lower_bound, upper_bound, initial_rotations(5:7), theta_0_pinky, 'finger');
phalanges{5}.local = M1; phalanges{6}.local = M2; phalanges{7}.local = M3;
phalanges{5}.length = L(1); phalanges{6}.length = L(2); phalanges{7}.length = L(3);

%% Set parameters
parameters = zeros(29, 1);
parameters(10:13) = theta_thumb;
parameters(14:17) = theta_index;
parameters(18:21) = theta_middle;
parameters(22:25) = theta_ring;
parameters(26:29) = theta_pinky;

%% Clip parameters
% thumb abduction
if parameters(10) < -0.75, parameters(10) = -0.75; end
if parameters(10) >  0.2, parameters(10) = 0.2; end
% thumb flexion 1
if parameters(11) < -0.3, parameters(11) = -0.3; end	
if parameters(11) > 1.8, parameters(11) = 1.8; end
% thumb flexion 2
if parameters(12) < -0.35, parameters(12) = -0.35; end	
if parameters(12) > 1.70, parameters(12) = 1.70; end
% thumb flexion 3
if parameters(13) < -0.35, parameters(13) = -0.35; end	
if parameters(13) > 1.50, parameters(13) = 1.50; end

% index abductions
if parameters(14) < -0.50, parameters(14) = -0.50; end	
if parameters(14) > 0.35, parameters(14) = 0.35; end
% index flexion 1
if parameters(15) < -2.00, parameters(15) = -2.00; end	
if parameters(15) > 1.00, parameters(15) = 1.00; end
% index flexion 2
if parameters(16) < -2.00, parameters(16) = -2.00; end	
if parameters(16) > 0.30, parameters(16) = 0.30; end
% index flexion 3
if parameters(17) < -2.00, parameters(17) = -2.00; end	
if parameters(17) > 0.30, parameters(17) = 0.30; end

%middle abduction
if parameters(18) < -0.50, parameters(18) = -0.50; end	
if parameters(18) > 0.25, parameters(18) = 0.25; end
% middle flexion 1
if parameters(19) < -2.00, parameters(19) = -2.00; end	
if parameters(19) > 1.00, parameters(19) = 1.00; end
% middle flexion 2
if parameters(20) < -2.00, parameters(20) = -2.00; end	
if parameters(20) > 0.30, parameters(20) = 0.30; end
% middle flexion 3
if parameters(21) < -2.00, parameters(21) = -2.00; end	
if parameters(21) > 0.30, parameters(21) = 0.30; end

% ring abduction
if parameters(22) < -0.20, parameters(22) = -0.20; end	
if parameters(22) > 0.30, parameters(22) = 0.30; end
% ring flexion 1
if parameters(23) < -2.00, parameters(23) = -2.00; end	
if parameters(23) > 1.00, parameters(23) = 1.00; end
% ring flexion 2
if parameters(24) < -2.00, parameters(24) = -2.00; end
if parameters(24) > 0.30, parameters(24) = 0.30; end
% ring flexion 3
if parameters(25) < -2.00, parameters(25) = -2.00; end	
if parameters(25) > 0.30, parameters(25) = 0.3; end

% pinky abduction
if parameters(26) < -0.30, parameters(26) = -0.30; end   
if parameters(26) > 0.60, parameters(26) = 0.60; end
% pinky flexion 1
if parameters(27) < -2.00, parameters(27) = -2.00; end
if parameters(27) > 1.00, parameters(27) = 1.00; end
% pinky flexion 2
if parameters(28) < -2.00, parameters(28) = -2.00; end	
if parameters(28) > 0.30, parameters(28) = 0.30; end
% pinky flexion 3
if parameters(29) < -2.00, parameters(29) = -2.00; end	
if parameters(29) > 0.30, parameters(29) = 0.30; end

%% Rewrite data
transformations_indices = [1, 17, 18, 19];
for i = 1:length(transformations_indices)
    phalanges{transformations_indices(i)}.local = initial_rotations{transformations_indices(i)};
end

phalanges_i = htrack_move(parameters, dofs, phalanges);
sync_centers = cell(length(centers), 1);
%% Thumb
sync_centers{names_map('thumb_base')} = centers{names_map('thumb_base')};
sync_centers{names_map('thumb_bottom')} = transform([0; 0; 0], phalanges_i{3}.global);
sync_centers{names_map('thumb_middle')} = transform([0; 0; 0], phalanges_i{4}.global);
sync_centers{names_map('thumb_top')} = transform([0; phalanges_i{4}.length; 0], phalanges_i{4}.global);
thumb_additional_length = norm(centers{names_map('thumb_additional')} - centers{names_map('thumb_middle')});
sync_centers{names_map('thumb_additional')} = transform([0; thumb_additional_length; 0], phalanges_i{4}.global);
% sync_centers{names_map('thumb_fold')} = project_point_on_triangle(centers{names_map('thumb_fold')}, ...
%     centers{names_map('palm_thumb')}, centers{names_map('thumb_base')}, centers{names_map('thumb_bottom')});

%% Index
sync_centers{names_map('index_base')} = centers{names_map('index_base')};
sync_centers{names_map('index_bottom')} = transform([0; 0; 0], phalanges_i{15}.global);
sync_centers{names_map('index_middle')} = transform([0; 0; 0], phalanges_i{16}.global);
sync_centers{names_map('index_top')} = transform([0; phalanges_i{16}.length; 0], phalanges_i{16}.global);
% l = centers{names_map('index_bottom')} - centers{names_map('index_base')};
% q = centers{names_map('index_base')} + real_membrane_offset(1) * l / norm(l);
% sync_centers{names_map('index_membrane')} =  q + (0.5 * radii{names_map('index_base')} + 0.5 * radii{names_map('index_bottom')} -  radii{names_map('index_membrane')}) ...
%     * phalanges{14}.local(1:3, 1:3) * (front);
%% Middle
sync_centers{names_map('middle_base')} = centers{names_map('middle_base')};
sync_centers{names_map('middle_bottom')} = transform([0; 0; 0], phalanges_i{12}.global);
sync_centers{names_map('middle_middle')} = transform([0; 0; 0], phalanges_i{13}.global);
sync_centers{names_map('middle_top')} = transform([0; phalanges_i{13}.length; 0], phalanges_i{13}.global);
% l = centers{names_map('middle_bottom')} - centers{names_map('middle_base')};
% q = centers{names_map('middle_base')} + real_membrane_offset(2) * l / norm(l);
% sync_centers{names_map('middle_membrane')} = q + (0.5 * radii{names_map('middle_base')} + 0.5 * radii{names_map('middle_bottom')} - radii{names_map('middle_membrane')}) ...
%     * phalanges{11}.local(1:3, 1:3) * (front);
%% Ring
sync_centers{names_map('ring_base')} = centers{names_map('ring_base')};
sync_centers{names_map('ring_bottom')} = transform([0; 0; 0], phalanges_i{9}.global);
sync_centers{names_map('ring_middle')} = transform([0; 0; 0], phalanges_i{10}.global);
sync_centers{names_map('ring_top')} = transform([0; phalanges_i{10}.length; 0], phalanges_i{10}.global);
% l = centers{names_map('ring_bottom')} - centers{names_map('ring_base')};
% q = centers{names_map('ring_base')} + real_membrane_offset(3) * l / norm(l);
% sync_centers{names_map('ring_membrane')} = q + (0.5 * radii{names_map('ring_base')} + 0.5 * radii{names_map('ring_bottom')} - radii{names_map('ring_membrane')}) ...
%     * phalanges{8}.local(1:3, 1:3) * (front);
%% Pinky
sync_centers{names_map('pinky_base')} = centers{names_map('pinky_base')};
sync_centers{names_map('pinky_bottom')} = transform([0; 0; 0], phalanges_i{6}.global);
sync_centers{names_map('pinky_middle')} = transform([0; 0; 0], phalanges_i{7}.global);
sync_centers{names_map('pinky_top')} = transform([0; phalanges_i{7}.length; 0], phalanges_i{7}.global);
% l = centers{names_map('pinky_bottom')} - centers{names_map('pinky_base')};
% q = centers{names_map('pinky_base')} + real_membrane_offset(3) * l / norm(l);
%sync_centers{names_map('pinky_membrane')} = q + (0.5 * radii{names_map('pinky_base')} + 0.5 * radii{names_map('pinky_bottom')} - radii{names_map('pinky_membrane')}) ...
%    * phalanges{5}.local(1:3, 1:3) * (front);

%% Unrotate to initial position
for i = 1:length(centers)
    centers{i} = transform(centers{i}, inv(init_transform));
    if ~isempty(sync_centers{i})
        sync_centers{i} = transform(sync_centers{i}, inv(init_transform));
    end
end

% for i = 1:length(sync_centers)
%     if ~isempty(sync_centers{i})
%         centers{i} = sync_centers{i};
%     end
% end

if (display)
    figure; hold on; axis off; axis equal;
    display_skeleton(centers, [], blocks, [], false, 'b');
    mypoints(sync_centers, 'r', 50);
    drawnow;
end

