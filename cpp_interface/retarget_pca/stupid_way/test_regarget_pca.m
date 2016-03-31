script_prepare_models;

skip_palm_and_thumb = 5;
full_hand = true;

shift =  [0.36429; 15.74; -0.96717];
shift = shift + [0; 0; -4];
%shift = [0; 0; 0];
%% Reduce to fingers
%{
if ~full_hand
    segments = segments(11:13);
    segment{1}.parent_id = -1; segment{1}.kinematic_chain = [1, 2]; segment{1}.children_ids = 2;
    segment{2}.parent_id = 1; segment{2}.kinematic_chain = [1, 2, 3]; segment{2}.children_ids = 3;
    segment{3}.parent_id = 2; segment{3}.kinematic_chain = [1, 2, 3, 4]; segment{3}.children_ids = [];
    
    phalanges = phalanges(11:13);
    phalanges{1}.parent_id = -1; phalanges{1}.kinematic_chain = [1, 2]; phalanges{1}.children_ids = 2;
    phalanges{2}.parent_id = 1; phalanges{2}.kinematic_chain = [1, 2, 3]; phalanges{2}.children_ids = 3;
    phalanges{3}.parent_id = 2; phalanges{3}.kinematic_chain = [1, 2, 3, 4]; phalanges{3}.children_ids = [];
    
    dofs = dofs(18:21);
    dofs{1}.phalange_id = 1; dofs{2}.phalange_id = 1; dofs{3}.phalange_id = 2; dofs{4}.phalange_id = 3;
    skip_palm = 1; num_phalanges = 3; num_thetas = 4;
end
%}

theta = zeros(num_thetas, 1);
for i = 1:length(phalanges), phalanges{i}.init_local = phalanges{i}.local;  end
initial_segments = segments;
initial_phalanges = phalanges;

%Data = Data(300:20:10000, :);
MData = zeros(size(Data));
tic
for index = 1:length(Data);
    disp(index);
    %% Pose
    %index = randi([1, length(Data)], 1);
    alpha = Data(index, :)';
    alpha = [zeros(9, 1); alpha];
    segments = htrack_move(alpha, joints, initial_segments);
    %segments = htrack_move(alpha, joints, initial_phalanges);
    
    %% Reset pose        
    phalanges = htrack_move(theta, dofs, initial_phalanges);
    
    %% Get htrack joint locations
    htrack_joints = {};
    phalange_indices = [];
    num_points = 10;
    for i = skip_palm_and_thumb:num_phalanges
        start_point = segments{i}.global(1:3, 4);
        end_point = transform([0; segments{i}.length; 0], segments{i}.global);
        
        x = linspace(start_point(1), end_point(1), num_points);
        y = linspace(start_point(2), end_point(2), num_points);
        z = linspace(start_point(3), end_point(3), num_points);
        for j = 1:num_points
            htrack_joints{end + 1} = [x(j); y(j); z(j)] - shift;
            phalange_indices(end + 1) = i;
        end
    end    
   
        
    num_iters = 40;
    X = zeros(length(htrack_joints), 3);
    for i = 1:length(htrack_joints), X(i, :) = htrack_joints{i}; end
    kd_tree = KDTreeSearcher(X);
    history = zeros(num_iters, 1);
    for iter = 1:num_iters
        %disp(iter);
        %% Create model-data correspondences
        hmodel_joints = {};
        for i = skip_palm_and_thumb:num_phalanges
            start_point = phalanges{i}.global(1:3, 4);
            end_point = transform([0; phalanges{i}.length; 0], phalanges{i}.global);
            
            x = linspace(start_point(1), end_point(1), num_points);
            y = linspace(start_point(2), end_point(2), num_points);
            z = linspace(start_point(3), end_point(3), num_points);
            
            if (i ~= 2 && i ~= 5 && i ~= 8 && i ~= 11 && i ~= 14)
                for j = 1:num_points
                    hmodel_joints{end + 1} = [x(j); y(j); z(j)];
                end
            else
                new_num_points = num_points + 3;
                x = linspace(start_point(1), end_point(1), new_num_points);
                y = linspace(start_point(2), end_point(2), new_num_points);
                z = linspace(start_point(3), end_point(3), new_num_points);
                for j = 4:new_num_points
                    hmodel_joints{end + 1} = [x(j); y(j); z(j)];
                end
            end
        end
        %Y = zeros(length(hmodel_joints), 3);
        %for i = 1:length(hmodel_joints), Y(i, :) = hmodel_joints{i}; end
        %closest_indices = knnsearch(kd_tree, Y);
        %Y = Y(closest_indices, :);
        %for i = 1:length(hmodel_joints), hmodel_joints{i} = Y(i, :)'; end 
        
        %% Display
        if false
            figure; hold on; axis off; axis equal; set(gcf,'color','w');
            if full_hand
                display_skeleton(centers, radii, blocks, [], false, [0.1, 0.4, 0.7]);
            else
                for i = skip_palm:num_phalanges
                    start_point = phalanges{i}.global(1:3, 4);
                    end_point = transform([0; phalanges{i}.length; 0], phalanges{i}.global);
                    myline(start_point, end_point, [0.1, 0.4, 0.7]);
                end
            end
            for j = 1:length(htrack_joints)
                myline(htrack_joints{j}, hmodel_joints{j}, [0.75, 0.75, 0.75]);
            end
            mypoints(htrack_joints, [0.9, 0.3, 0.5]);
            mypoints(hmodel_joints, [0.1, 0.8, 0.7]);
            view([-180, -90]);
            drawnow;
        end
        
        %% Solve IK & apply
        [F, J] = jacobian_retargeting(phalanges, dofs, hmodel_joints, htrack_joints, phalange_indices);
        if full_hand, J(:, 1:13) = 0; end
        %% Solve for IK
        %damping = 300000 * ones(num_thetas, 1);
        damping = 30000 * ones(num_thetas, 1);        
        LHS = (J' * J) + diag(damping);
        RHS = J'  * F;
        delta_theta = LHS \ RHS;
        
        theta = theta + delta_theta;
        theta(theta > 2 * pi) = theta(theta > 2 * pi) - 2 * pi;
        
        history(iter) = F' * F;
        
        %% Pose the model
        for i = 1:length(phalanges), phalanges{i}.local = phalanges{i}.init_local; end
        phalanges = htrack_move(theta, dofs, phalanges);
        if full_hand
            centers = update_centers(centers, phalanges, names_map);
        end
        
    end
    MData(index, :) = theta(10:end);
    %% Display result
   
    if rem(index, 1000) == 0
       %disp(toc);
       hmodel_joints = {};
        for i = skip_palm_and_thumb:num_phalanges
            start_point = phalanges{i}.global(1:3, 4);
            end_point = transform([0; phalanges{i}.length; 0], phalanges{i}.global);
            
            x = linspace(start_point(1), end_point(1), num_points);
            y = linspace(start_point(2), end_point(2), num_points);
            z = linspace(start_point(3), end_point(3), num_points);
            
            if (i ~= 2 && i ~= 5 && i ~= 8 && i ~= 11 && i ~= 14)
                for j = 1:num_points
                    hmodel_joints{end + 1} = [x(j); y(j); z(j)];
                end
            else
                new_num_points = num_points + 3;
                x = linspace(start_point(1), end_point(1), new_num_points);
                y = linspace(start_point(2), end_point(2), new_num_points);
                z = linspace(start_point(3), end_point(3), new_num_points);
                for j = 4:new_num_points
                    hmodel_joints{end + 1} = [x(j); y(j); z(j)];
                end
            end
        end
        %Y = zeros(length(hmodel_joints), 3);
        %for i = 1:length(hmodel_joints), Y(i, :) = hmodel_joints{i}; end
        %closest_indices = knnsearch(kd_tree, Y);
        %Y = Y(closest_indices, :);
        %for i = 1:length(hmodel_joints), hmodel_joints{i} = Y(i, :)'; end 
        
        %% Display
        if true
            figure; hold on; axis off; axis equal; set(gcf,'color','w');
            if full_hand
                display_skeleton(centers, radii, blocks, [], false, [0.1, 0.4, 0.7]);
            else
                for i = skip_palm:num_phalanges
                    start_point = phalanges{i}.global(1:3, 4);
                    end_point = transform([0; phalanges{i}.length; 0], phalanges{i}.global);
                    myline(start_point, end_point, [0.1, 0.4, 0.7]);
                end
            end
            for j = 1:length(htrack_joints)
                myline(htrack_joints{j}, hmodel_joints{j}, [0.75, 0.75, 0.75]);
            end
            mypoints(htrack_joints, [0.9, 0.3, 0.5]);
            mypoints(hmodel_joints, [0.1, 0.8, 0.7]);
            view([-180, -90]);           
            figure;
            plot(2:num_iters, history(2:end), 'lineWidth', 2);
            drawnow;
        end
    end
    %disp(theta(14:end)');
end

save MData MData;

















