function [f3, J3] = jacobian_joint_limits_new(centers, blocks, restpose_edges, rotations, limits, parents, attachments, global_frame_indices, names_map, D)

Rx  = @(x) [1, 0, 0; 0, cos(x), -sin(x); 0, sin(x), cos(x)];
Ry = @(x) [cos(x), 0, sin(x); 0, 1, 0; -sin(x), 0, cos(x)];
Rz = @(x) [cos(x), -sin(x), 0; sin(x), cos(x), 0; 0, 0, 1];


%% Htrack data
%{
switch mode
    case 'joint_limits'
        edge_indices = {[2, 1], [3, 2], [4, 3], [8, 6], [5, 6], [7, 8], [5, 7]};
        e = [0; 1; 0]; f = [-1; 0; 0];
        a = (centers{6} - centers{8}) / norm(centers{6} - centers{8});
        b = (centers{7} - centers{8}) / norm(centers{7} - centers{8});
        finger_indices = {[1, 2, 3, 4]};
    case 'hand'
        edge_indices = {[2, 1]; [3, 2]; [4, 3]; [6, 5]; [7, 6]; [8, 7]; [10, 9]; [11, 10]; [12, 11]; [14, 13]; ...
            [15, 14]; [16, 15]; [18, 17]; [19, 18]; [20, 19]; [21, 23]; [22, 24]; [23, 24]; [21, 22]};
        edges = cell(length(blocks), 1);
        
        for i = 1:length(blocks)
            %c = centers{edge_indices{i}};
            %d = centers{edge_indices{i}};
            %edges{i} = d - c;
            edges{i} = rotations{i} * restpose_edges{i};
        end
        a = edges{16} / norm(edges{16});
        b = edges{17} / norm(edges{17});
        finger_indices = {[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12], [13, 14, 15]};
        %finger_indices = {[13, 14, 15]};
end
%}

edge_indices = {[2, 1]; [3, 2]; [4, 3]; [6, 5]; [7, 6]; [8, 7]; [10, 9]; [11, 10]; [12, 11]; [14, 13]; [15, 14]; [16, 15]; [18, 17]; [19, 18]; [20, 19]};
edges = cell(length(blocks), 1);
for i = 1:length(blocks)
    edges{i} = rotations{i} * restpose_edges{i};
end
% a = edges{16} / norm(edges{16});
% b = edges{17} / norm(edges{17});
finger_indices = {[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12], [13, 14, 15]};
global_frame = find_frame(centers(global_frame_indices), 0);
palm_up_direction = 1/2 * (centers{names_map('palm_middle')} - centers{names_map('palm_back')}) / norm(centers{names_map('palm_middle')} - centers{names_map('palm_back')}) + ...
    1/2 * (centers{names_map('palm_ring')} - centers{names_map('palm_back')}) / norm(centers{names_map('palm_ring')} - centers{names_map('palm_back')});
palm_horis_direction = cross(global_frame(:, 3), palm_up_direction);

% display_skeleton(centers, [], blocks, [], false);
% factor = 20;
% myline(centers{names_map('palm_back')}, centers{names_map('palm_back')} + factor * global_frame(:, 1), 'g');
% myline(centers{names_map('palm_back')}, centers{names_map('palm_back')} + factor * global_frame(:, 2), 'g');
% myline(centers{names_map('palm_back')}, centers{names_map('palm_back')} + factor * global_frame(:, 3), 'g');
% myline(centers{names_map('palm_back')}, centers{names_map('palm_back')} + factor * palm_horis_direction, 'r');

%% Joint limits
projections = cell(length(centers), 1);

for i = 1:length(finger_indices)
    points = cell(0, 1);
    for j = 1:length(finger_indices{i})
        points{j} = edges{finger_indices{i}(j)};
    end
    points{end + 1} = [0; 0; 0];
    [normal, origin, S] = affine_fit(points);
    
    if abs(S(2, 2) / S(3, 3)) < 1e-2, continue; end
    if abs(S(2, 2) / S(3, 3)) < 1e-2, continue; end
    
    %% Adjust normal
    %{
    axis_angle = vrrotvec(palm_horis_direction, normal);
    if axis_angle(4) > pi/2,
        normal = - normal;
        axis_angle = vrrotvec(palm_horis_direction, normal);
    end
    if i ~= 5 && axis_angle(4) > pi/8
        R1 = vrrotvec2mat(axis_angle);
        axis_angle(4) = pi/8;
        R2 = vrrotvec2mat(axis_angle);
        normal = R2 * R1' * normal;
    end
    %}
  
    %% Project joints on the plane
    for j = 1:length(finger_indices{i})
        projections{finger_indices{i}(j)} = project_point_on_plane(edges{finger_indices{i}(j)}, origin, normal);
    end
    
end

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
        %{
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
        %}
        limits_rotations{i} = vrrotvec2mat(vrrotvec(restpose_edges{i}, projections{i}));
    end
end

%% Join limits energy

f3 = zeros(2, 1);
J3 = zeros(2, length(centers) * D);
for i = 1:length(blocks)
    
    if isempty(limits_rotations{i}), continue; end
    index1 = edge_indices{i}(1);
    index2 = edge_indices{i}(2);
    b = centers{index1}; c = centers{index2};
    e = limits_rotations{i} * restpose_edges{i};
    
    gradients = get_parameters_gradients([index1, index2], attachments, D, 'tracking');
    f3(D * (i - 1) + 1: D * i) = c - b - e;
    for l = 1:length(gradients)
        J3(D * (i - 1) + 1: D * i, D * (gradients{l}.index - 1) + 1:D * gradients{l}.index) = gradients{l}.dc2 - gradients{l}.dc1;
    end
    
end

