function new_thetas = solve(S, model_points, block_indices, distances, NN, lambda)
    num_model_points = size(model_points, 1); 
    LHS = zeros(S.num_parameters, S.num_parameters);
    RHS = zeros(S.num_parameters, 1);

    %% Build the Jacobian matrix
    for k = 1:num_model_points
        d = distances(k,:)';
        n = NN(k,:)';
        
        J = zeros(3, S.num_parameters);
        
        %% indexes of rotation-type dependencies
        rot_demodel_points = block_indices(k):-1:4; 
        for i = rot_demodel_points
            s = model_points(k, :);
            p = S.joints_translation(i, :);
            v = S.joints_rotation(i, :);
            J(:, i) = cross(v, s - p)';
        end
        
        %% accumulate sides        
        %ntJ = n(1) * J(:,1) + n(2) * J(:,2) + n(3) * J(:,3); %<transposed err.
        J = n' * J;
        f = n' * d;
        LHS = LHS + J' * J;
        RHS = RHS + J' * f;
    end
    
    %% Solve for IK 
    I = eye(S.num_parameters, S.num_parameters);
    LHS = LHS + lambda^2 * I;
    delta_theta = (LHS \ RHS)';
    disp(delta_theta)
    
    %% Compute the new thetas
    new_thetas = S.joint_thetas + delta_theta;
end