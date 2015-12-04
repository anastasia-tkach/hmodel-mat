close all;
clear;
settings_default; 
data_path = 'tracking/test4/';
mode = 'my_hand';

%% Load data
load([data_path, 'radii.mat']); load([data_path, 'centers.mat']);
load([data_path, 'blocks.mat']); [blocks] = reindex(radii, blocks);

figure; axis off; axis equal; hold on;
display_skeleton(centers, radii, blocks, [], false, []);
view([180, -90]); camlight; drawnow;

%% Draw frames
compute_attachments;
names_map_keys = {'palm_pinky', 'palm_ring', 'palm_middle', 'palm_index', 'palm_thumb', 'palm_back', 'palm_attachment', 'palm_right', 'palm_back'};
[frames, global_frame, global_axis] = compute_model_frames(centers, blocks, mode, global_frame_indices, names_map, names_map_keys);
edge_indices = {[2, 1]; [3, 2]; [4, 3]; [6, 5]; [7, 6]; [8, 7]; [10, 9]; [11, 10]; [12, 11]; [14, 13]; [15, 14]; [16, 15]; [18, 17]; [19, 18]; [20, 19]};
%{
for i = 1:15
    factor = 10;
    myline(centers{edge_indices{i}(2)}, centers{edge_indices{i}(2)} + factor *  frames{i}(:, 1), 'r');
    myline(centers{edge_indices{i}(2)}, centers{edge_indices{i}(2)} + factor *  frames{i}(:, 2), 'r');
    myline(centers{edge_indices{i}(2)}, centers{edge_indices{i}(2)} + factor *  frames{i}(:, 3), 'r');
end
myline(centers{names_map('palm_back')}, centers{names_map('palm_back')} + factor * global_frame(:, 1), 'm');
myline(centers{names_map('palm_back')}, centers{names_map('palm_back')} + factor * global_frame(:, 2), 'm');
myline(centers{names_map('palm_back')}, centers{names_map('palm_back')} + factor * global_frame(:, 3), 'm');
%}

%% Compute fingers planes
finger_indices = {[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12], [13, 14, 15, 16]};
projections = cell(length(centers), 1);
plane_normals = cell(length(finger_indices), 1);
plane_origins = cell(length(finger_indices), 1);
for i = 1:length(finger_indices)
    points = cell(0, 1);
    for j = 1:length(finger_indices{i})
        points{j} = centers{finger_indices{i}(j)};
    end   
    [plane_normals{i}, plane_origins{i}, S] = affine_fit(points);
    %draw_plane(origin, normal, 'b', points); drawnow;
  
    %% Project joints on the plane
    for j = 1:length(finger_indices{i})
        projections{finger_indices{i}(j)} = project_point_on_plane(centers{finger_indices{i}(j)}, plane_origins{i}, plane_normals{i});
    end    
end
display_skeleton(centers, radii, blocks(1:15), [], false, 'm');

%% Create angles map
joint_axis_map = containers.Map();
joint_axis_map('pinky_middle_flexion') = {'pinky_bottom', 'pinky_middle', 'pinky_top'};
joint_axis_map('pinky_bottom_flexion') = {'pinky_base', 'pinky_bottom', 'pinky_middle'};
joint_axis_map('pinky_base_abduction_flexion') = {'palm_right', 'pinky_base', 'pinky_bottom'};

joint_axis_map('ring_middle_flexion') = {'ring_bottom', 'ring_middle', 'ring_top'};
joint_axis_map('ring_bottom_flexion') = {'ring_base', 'ring_bottom', 'ring_middle'};
joint_axis_map('ring_base_abduction_flexion') = {'paml_back', 'ring_base', 'ring_bottom'};

joint_axis_map('middle_middle_flexion') = {'middle_bottom', 'middle_middle', 'middle_top'};
joint_axis_map('middle_bottom_flexion') = {'middle_base', 'middle_bottom', 'middle_middle'};
joint_axis_map('middle_base_abduction_flexion') = {'middle_back', 'middle_base', 'middle_bottom'};

joint_axis_map('index_middle_flexion') = {'index_bottom', 'index_middle', 'index_top'};
joint_axis_map('index_bottom_flexion') = {'index_base', 'index_bottom', 'index_middle'};
joint_axis_map('index_base_abduction_flexion') = {'thumb_base', 'index_base', 'index_bottom'};

joint_indices_map = containers.Map();
joint_indices_map('pinky_middle_flexion') = 26;
joint_indices_map('pinky_bottom_flexion') = 25;
joint_indices_map('pinky_base_abduction_flexion') = [23, 24];

joint_indices_map('ring_middle_flexion') = 22;
joint_indices_map('ring_bottom_flexion') = 21;
joint_indices_map('ring_base_abduction_flexion') = [19, 20];

joint_indices_map('middle_middle_flexion') = 18;
joint_indices_map('middle_bottom_flexion') = 17;
joint_indices_map('middle_base_abduction_flexion') = [15, 16];

joint_indices_map('index_middle_flexion') = 14;
joint_indices_map('index_bottom_flexion') = 13;
joint_indices_map('index_base_abduction_flexion') = [11, 12];

theta = zeros(20, 1);
joint_axis_keys = keys(joint_axis_map);
for i = 1:length(joint_axis_keys)
    key = joint_axis_keys{i};    
    if strfind(key, 'abduction')
        
    else
        a = projections(
    end
end

%% 
return
 
limits_rotations = cell(length(blocks), 1);
for i = 1:length(blocks)
    if isempty(limits{i}), continue; end
    if rem(i, 3) == 0
        continue; 
        u = (edges{i}) / norm(edges{i});
        v = b;
        v = (v - (u' * v) * u) / norm(v - (u' * v) * u);
        G = fit_svd_rotation([e'; f'], [a'; b']);
        
        R = fit_svd_rotation([(G * a)'; (G * b)'], [(G * u)'; (G * v)']);
        theta = SpinCalc('DCMtoEA132', R, 1e-10, 0) / 180 * pi;
        for h = 1:3, if abs(theta(h)) > pi, theta(h) = theta(h) - 2 * pi; end; end
        
        
        joint_limits_violation = false;
        for h = 1:length(theta)
            if theta(h) < limits{i}.theta_min(h) || theta(h) > limits{i}.theta_max(h)
                joint_limits_violation = true;
            end
        end
        
        if joint_limits_violation == false, continue; end
        
        theta_limited = max(theta, limits{i}.theta_min);
        theta_limited = min(theta_limited, limits{i}.theta_max);
        
        limits_rotations{i} = G' * Rx(theta_limited(1)) * Rz(theta_limited(2)) *  Ry(theta_limited(3)) * ...
            Ry(theta(3))' * Rz(theta(2))' * Rx(theta(1))' * G * rotations{i};
        
    else
        if isempty(projections{i}), continue; end
        
        axis_angle = vrrotvec(projections{parents{i}}, projections{i});
        if axis_angle(1:3) * palm_horis_direction > 0
            axis_angle = -axis_angle;
        end
        R1 = vrrotvec2mat(axis_angle);
        theta = axis_angle(4);
        theta_limited = max(theta, limits{i}.theta_min(2));
        theta_limited = min(theta_limited, limits{i}.theta_max(2));
        
        if (theta > limits{i}.theta_max(1) || theta < limits{i}.theta_min(1))
            axis_angle(4) = theta_limited;
            R2 = vrrotvec2mat(axis_angle);
            limits_rotations{i} = R2 * R1' * vrrotvec2mat(vrrotvec(restpose_edges{i}, projections{i}));
        else
            limits_rotations{i} = vrrotvec2mat(vrrotvec(restpose_edges{i}, projections{i}));
        end
        
        limits_rotations{i} = vrrotvec2mat(vrrotvec(restpose_edges{i}, projections{i}));
    end
end