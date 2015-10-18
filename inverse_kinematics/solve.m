function new_thetas = solve(S, model_points, block_indices, data_points, data_normals, lambda, settings)
num_model_points = size(model_points, 1);
J = zeros(num_model_points, settings.num_parameters);
F = zeros(num_model_points, 1);

%% Build the Jacobian matrix
for k = 1:num_model_points
    d = data_points(k,:)';
    m = model_points(k, :)';
    n = data_normals(k,:)';
    
    if settings.D == 3, n = m - d / norm(m - d); end
    
    j = zeros(3, settings.num_parameters);
    
    %% indexes of rotation-type dependencies
    rot_demodel_points = block_indices(k):-1:4;
    for i = rot_demodel_points        
        p = S.global_translation(i, :)';
        v = S.axis(i, :);
        j(:, i) = cross(v, m - p)';
    end
    
    %% accumulate sides
    J(k, :) = n' * j;
    F(k) = n' * (d - m);
    if settings.D  == 3
    end
end

%% Solve for IK
I = eye(settings.num_parameters, settings.num_parameters);
LHS = J' * J + lambda^2 * I;
RHS = J' * F;
delta_theta = (LHS \ RHS)';
disp(F' * F);

%% Compute the new thetas
new_thetas = S.thetas + delta_theta;
end