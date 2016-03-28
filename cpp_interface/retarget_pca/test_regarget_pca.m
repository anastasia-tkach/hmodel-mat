%% Load HModel
clc; close all; clear;
input_path = '_my_hand/final/';
semantics_path = '_my_hand/semantics/';
load([semantics_path, 'fitting/names_map.mat']);
load([semantics_path, 'fitting/blocks.mat'], 'blocks');
load([input_path, 'centers.mat'], 'centers');
load([input_path, 'radii.mat'], 'radii');
load([input_path, 'phalanges.mat'], 'phalanges');
load([input_path, 'dofs.mat'], 'dofs');

% display_result(centers, [], [], blocks(1:29), radii, false, 0.6, 'big');
% view([-180, -90]); camlight;

%% Load HTrack
num_thetas = 29;
num_phalanges = 16;
n = 20; m = 2; p = 6;

load Data;  Data = Data(:, p + 1:end);
mu = mean(Data)';
Data = bsxfun(@minus, Data, mu');  X = Data;
Sigma = (X' * X) / size(X, 1); [U, S, V] = svd(Sigma); s = diag(S); s = diag(s(1:m));
P = U(:, 1:m); Xp = P' * X';

scaling_factor = 0.75;
[segments, joints, triangles] = htrack_parameters(scaling_factor);
for i = 1:length(phalanges)
    if i > num_phalanges, continue; end
    phalanges{i}.kinematic_chain = segments{i}.kinematic_chain;    
end

%% Pose
%theta = [0.2245, 0.6083, -0.1260, -1.0965, -0.1580, -1.0081, -0.6572, -1.0159, -0.2056, 0.0670, -1.1924, -0.9529, -0.2882, -1.2361, -0.5992, -0.1336, 0.0659, -0.8790, -1.6130, -1.9549]';
%theta = theta - mu;
%theta = [zeros(9, 1); theta];
theta = rand(num_thetas, 1);
theta(1:9) = 0;
%segments = htrack_move(theta, joints, segments);

%% Test with hmodel
%theta = zeros(num_thetas, 1);
%theta(24) = -pi/3;
segments = htrack_move(theta, joints, phalanges);

%% Display
%display_htrack(segments, triangles, 'none');

%% Get htrack joint locations
% htrack_joints = cell(19, 1);
% phalange_indices = zeros(19, 1);
% num_points = 10;
% for i = 2:num_phalanges
%     base_name = phalanges{i}.name;
%     if strfind(base_name, 'base'), continue; end
%     htrack_joints{names_map(base_name)} = segments{i}.global(1:3, 4);
%     phalange_indices(names_map(base_name)) = i;
%     if isfield(phalanges{i}, 'rigid_names')
%         for j = 1:length(phalanges{i}.rigid_names)
%             name = phalanges{i}.rigid_names{j};
%             if strfind(name, 'top')
%                 u = segments{i}.length * [0; 1; 0];
%                 htrack_joints{names_map(name)} = transform(u, segments{i}.global);
%                 phalange_indices(names_map(name)) = i;
%                 
%                 phalanges{i}.length = norm(centers{names_map(name)} - centers{names_map(base_name)});
%             end
%         end
%     end
% end


htrack_joints = {};
phalange_indices = {};
num_points = 10;
for i = 2:num_phalanges
    base_name = phalanges{i}.name;
    if strfind(base_name, 'base'), continue; end
    htrack_joints{end + 1} = segments{i}.global(1:3, 4);
    phalange_indices(names_map(base_name)) = i;
    if isfield(phalanges{i}, 'rigid_names')
        for j = 1:length(phalanges{i}.rigid_names)
            name = phalanges{i}.rigid_names{j};
            if strfind(name, 'top')
                u = segments{i}.length * [0; 1; 0];
                htrack_joints{names_map(name)} = transform(u, segments{i}.global);
                phalange_indices(names_map(name)) = i;
                
                phalanges{i}.length = norm(centers{names_map(name)} - centers{names_map(base_name)});
            end
        end
    end
end

%% Run ik
for i = 1:length(phalanges)
    phalanges{i}.init_local = phalanges{i}.local;
    if i <= num_phalanges
        phalanges{i}.kinematic_chain = segments{i}.kinematic_chain;
    end
end

num_iters = 35;
history = zeros(num_iters, 1);
theta = zeros(num_thetas, 1);
for iter = 1:num_iters
    %% Create model-data correspondences
    
    hmodel_joints = cell(num_phalanges, 1);
    for i = 2:num_phalanges
        base_name = phalanges{i}.name;
        if strfind(base_name, 'base'), continue; end
        hmodel_joints{names_map(base_name)} = phalanges{i}.global(1:3, 4);
        if isfield(phalanges{i}, 'rigid_names')
            for j = 1:length(phalanges{i}.rigid_names)
                name = phalanges{i}.rigid_names{j};
                if strfind(name, 'top')
                    %l = norm(centers{names_map(name)} - centers{names_map(base_name)});
                    hmodel_joints{names_map(name)} = transform([0; phalanges{i}.length; 0], phalanges{i}.global);
                end
            end
        end
    end
    %hmodel_joints = hmodel_joints(7);
    
    %% Display
    if true
        figure; hold on; axis off; axis equal; set(gcf,'color','w');
        display_skeleton(centers, radii, blocks, [], false, 'b');
        for j = 1:length(htrack_joints)
            myline(htrack_joints{j}, hmodel_joints{j}, [0.75, 0.75, 0.75]);
        end
        mypoints(htrack_joints, 'm');
        mypoints(hmodel_joints, 'g');
        %view([90, 0]);
    end
    
    %% Solve IK & apply
    
    [F, J] = jacobian_retargeting(phalanges, dofs, hmodel_joints, htrack_joints, phalange_indices);
    
    %% Solve for IK
    damping = 5000 * ones(num_thetas, 1); % look an cppd
    damping(1:3) = 10;
    damping(4:6) = 500000;
    I = eye(num_thetas, num_thetas);

    J(:, 1:9) = 0;
    LHS = (J' * J) + diag(damping);
    RHS = J'  * F;
    delta_theta = LHS \ RHS;
    
    theta = theta + delta_theta;
    history(iter) = F' * F;
    
    %% Pose the model
    for i = 1:length(phalanges), phalanges{i}.local = phalanges{i}.init_local; end
    phalanges = htrack_move(theta, dofs, phalanges);
    centers = update_centers(centers, phalanges, names_map);
    
end

 hmodel_joints = cell(num_phalanges, 1);
    for i = 2:num_phalanges
        base_name = phalanges{i}.name;
        if strfind(base_name, 'base'), continue; end
        hmodel_joints{names_map(base_name)} = phalanges{i}.global(1:3, 4);
        if isfield(phalanges{i}, 'rigid_names')
            for j = 1:length(phalanges{i}.rigid_names)
                name = phalanges{i}.rigid_names{j};
                if strfind(name, 'top')                    
                    hmodel_joints{names_map(name)} = transform([0; phalanges{i}.length; 0], phalanges{i}.global);
                end
            end
        end
    end
figure; hold on; axis off; axis equal; set(gcf,'color','w');
display_skeleton(centers, radii, blocks, [], false, 'b');
for j = 1:length(htrack_joints)
    myline(htrack_joints{j}, hmodel_joints{j}, [0.75, 0.75, 0.75]);
end
mypoints(htrack_joints, 'm');
mypoints(hmodel_joints, 'g');
%view([90, 0]);
figure; hold on; plot(1:num_iters, history, 'lineWidth', 2);






















