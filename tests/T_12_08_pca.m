close all;
clear;
settings_default;
data_path = 'tracking/test4/';
mode = 'my_hand';

%% Load data
load([data_path, 'radii.mat']); 
load([data_path, 'centers.mat']);
load([data_path, 'blocks.mat']); 
load([data_path, 'theta.mat']);
theta_htrack = theta;

[blocks] = reindex(radii, blocks);

%% Real theta
figure; axis off; axis equal; hold on;
display_skeleton(centers, radii, blocks, [], false, []);
segments = create_ik_model('hand'); [segments, joints] = pose_ik_model(segments, theta_htrack, true, 'hand');

%% Found theta
figure; axis off; axis equal; hold on;
display_skeleton(centers, radii, blocks, [], false, []);
view([180, -90]); camlight; drawnow;

%% Draw frames
compute_attachments;
names_map_keys = {'palm_pinky', 'palm_ring', 'palm_middle', 'palm_index', 'palm_thumb', 'palm_back', 'palm_attachment', 'palm_right', 'palm_back'};
[frames, global_frame, global_axis] = compute_model_frames(centers, blocks, mode, global_frame_indices, names_map, names_map_keys);
palm_vertical = global_frame(:, 1);
palm_horisontal = global_frame(:, 2);
palm_normal = global_frame(:, 3);

%% Compute fingers planes
joint_angles_semantics;
projections = centers;
plane_normals = cell(length(keys(fingers_map)), 1);
plane_origins = cell(length(keys(fingers_map)), 1);
for i = 1:length(finger_names)
    finger = fingers_map(finger_names{i});
    points = cell(0, 1);
    for j = 1:length(finger.indices)
        points{j} = centers{finger.indices(j)};
    end
    a = palm_vertical;
    b = palm_horisontal;
    A = zeros(length(finger.indices) - 1, 3);
    for j = 1:length(finger.indices) - 1
        A(j, :) = centers{finger.indices(j)}' - centers{finger.indices(4)}';
    end
    
    N = 60;
    objective = zeros(N, 1);
    min_objective = Inf;
    min_x = zeros(D, 1);
    min_t = 0;
    angles = linspace(0, pi, N);
    for t = 1:length(angles)
        x = a * sin(angles(t)) + b * cos(angles(t));
        f = A * x;
        if f' * f < min_objective
            min_objective = f' * f;
            min_x = x;
            min_t = t;
        end
        %myline(centers{finger.indices(4)}, centers{finger.indices(4)} + 15 * x, 'g');
        %draw_plane(centers{finger.indices(4)}, x, 'm', points);
    end
    plane_normals{i} = min_x;
    if plane_normals{i}' * palm_horisontal < 0,  plane_normals{i} = - plane_normals{i}; end;
    plane_origins{i} = centers{finger.indices(4)};
    draw_plane(plane_origins{i}, plane_normals{i}, 'm', points);
    
    %% Project joints on the plane
    for j = 1:length(finger.indices)
        projections{finger.indices(j)} = project_point_on_plane(centers{finger.indices(j)}, plane_origins{i}, plane_normals{i});
    end
end
display_skeleton(projections, radii, blocks(1:12), [], false, 'm');
myline(centers{names_map('palm_back')}, centers{names_map('palm_back')} + 30 * palm_vertical, 'r');
myline(centers{names_map('palm_back')}, centers{names_map('palm_back')} + 30 * palm_horisontal, 'r');

%% Display rectified
figure; axis off; axis equal; hold on;
display_skeleton(projections, radii, blocks, [], false, []);
view([180, -90]); camlight; drawnow;

theta_hmodel = theta_htrack;
for i = 1:length(finger_names)
    
    finger = fingers_map(finger_names{i});
    
    %% Base abduction
    bottom_joint_projection = project_point_on_plane(projections{names_map(finger.base_flexion{2})}, projections{names_map(finger.base_flexion{1})}, palm_horisontal);
    a = bottom_joint_projection - projections{names_map(finger.base_flexion{1})};
    b = projections{names_map(finger.base_flexion{2})} - projections{names_map(finger.base_flexion{1})};
    theta_hmodel(finger.base_abduction_dof) = signed_angle_between_vectors(a, b, palm_normal);
    
    %myline(projections{names_map(finger.base_flexion{1})}, bottom_joint_projection, 'c');
    
    %% Base flexion
    a = palm_vertical;
    b = bottom_joint_projection - centers{names_map(finger.base_flexion{1})};
    theta_hmodel(finger.base_flexion_dof) = signed_angle_between_vectors(a, b, palm_horisontal);
    
    %% Bottom flexion
    a = projections{names_map(finger.bottom_flexion{2})} - projections{names_map(finger.bottom_flexion{1})};
    b = projections{names_map(finger.bottom_flexion{3})} - projections{names_map(finger.bottom_flexion{2})};
    theta_hmodel(finger.bottom_flexion_dof) = signed_angle_between_vectors(a, b, plane_normals{i});
    
    %% Middle flexion
    a = projections{names_map(finger.middle_flexion{2})} - projections{names_map(finger.middle_flexion{1})};
    b = projections{names_map(finger.middle_flexion{3})} - projections{names_map(finger.middle_flexion{2})};
    theta_hmodel(finger.middle_flexion_dof) = signed_angle_between_vectors(a, b, plane_normals{i});
end

segments = create_ik_model('hand'); [segments, joints] = pose_ik_model(segments, theta_htrack, true, 'hand');

%% Apply PCA
m = 2; p = 10;
load Data
flexion_indices = [13:14, 17:18, 21:22, 25:26];
%flexion_indices = [12:14, 16:18, 20:22, 24:26];
Data = Data(:, flexion_indices);

mu = mean(Data)';
Data = bsxfun(@minus, Data, mu');
X = Data;
Sigma = (X' * X) / size(X, 1);
[U, S, V] = svd(Sigma);
s = diag(S);

s = diag(s(1:m));
P = U(:, 1:m);
Xp = P' * X';

theta_tilda = P' * (theta_htrack(flexion_indices) - mu);
theta_flexion = P*theta_tilda + mu;
new_theta_htrack = theta_htrack;
new_theta_htrack(flexion_indices) = theta_flexion;

new_theta_hmodel = theta_hmodel;
new_theta_hmodel(flexion_indices) = theta_flexion;

%% Recreate the pose
new_centers = centers;
for i = 1:length(finger_names)
    
    finger = fingers_map(finger_names{i});
    
    %% Base flexion
    axis_angle = [palm_horisontal; new_theta_hmodel(finger.base_flexion_dof)];
    R = vrrotvec2mat(axis_angle);
    b = R * palm_vertical;
    
    %% Base abduction
    a = palm_normal - (b' * palm_normal) * b; a = a/norm(a);
    axis_angle = [a; new_theta_hmodel(finger.base_abduction_dof)];
    R = vrrotvec2mat(axis_angle);
    b = R * b;
    
    new_centers{names_map(finger.base_flexion{2})} = new_centers{names_map(finger.base_flexion{1})} + ...
        norm(centers{names_map(finger.base_flexion{2})} - centers{names_map(finger.base_flexion{1})}) * b;
    
    %% Correct plane    
    plane_normals{i} = cross(palm_normal, b);
    
    %% Bottom flexion
    a = new_centers{names_map(finger.bottom_flexion{2})} - new_centers{names_map(finger.bottom_flexion{1})};
    axis_angle = [plane_normals{i}; new_theta_hmodel(finger.bottom_flexion_dof)];
    R = vrrotvec2mat(axis_angle);
    b = R * a / norm(a);
    new_centers{names_map(finger.bottom_flexion{3})} = new_centers{names_map(finger.bottom_flexion{2})} + ...
        norm(centers{names_map(finger.bottom_flexion{3})} - centers{names_map(finger.bottom_flexion{2})}) * b;
    
    %% Middle flexion
    a = new_centers{names_map(finger.middle_flexion{2})} - new_centers{names_map(finger.middle_flexion{1})};
    axis_angle = [plane_normals{i}; new_theta_hmodel(finger.middle_flexion_dof)];
    R = vrrotvec2mat(axis_angle);
    b = R * a / norm(a);
    new_centers{names_map(finger.middle_flexion{3})} = new_centers{names_map(finger.middle_flexion{2})} + ...
        norm(centers{names_map(finger.middle_flexion{3})} - centers{names_map(finger.middle_flexion{2})}) * b;
    
end
figure; axis off; axis equal; hold on;
display_skeleton(new_centers, radii, blocks, [], false, []);
for i = 1:length(plane_normals)
    finger = fingers_map(finger_names{i});
    points = cell(0, 1);
    for j = 1:length(finger.indices)
        points{j} = new_centers{finger.indices(j)};
    end
    %draw_plane(plane_origins{i}, plane_normals{i}, 'm', points);
end
view([180, -90]); camlight; drawnow;
segments = create_ik_model('hand'); [segments, joints] = pose_ik_model(segments, new_theta_htrack, true, 'hand');

