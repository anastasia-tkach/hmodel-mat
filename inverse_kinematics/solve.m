function new_thetas = solve(S, model_points, segment_indices, data_points, data_normals, lambda, settings)
num_model_points = size(model_points, 1);
J = zeros(num_model_points, settings.num_parameters);
F = zeros(num_model_points, 1);

%% Build the Jacobian matrix
for k = 1:num_model_points
    d = data_points(k,:)';
    m = model_points(k, :)';
    n = data_normals(k,:)';
    
    if settings.D == 3, n = (m - d) / norm(m - d); end
    
    j = zeros(3, settings.num_parameters);
    
    %% indexes of rotation-type dependencies
    for l = 1:length(S.kinematic_chain{segment_indices(k)})
        i = S.kinematic_chain{segment_indices(k)}(l); 
        v = S.axis(i, :);
        
        if i > settings.num_translations
            p = S.global_translation(i, :)';            
            j(:, i) = cross(v, m - p)';
        else
            %j(:, i) = v;
        end
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
delta_theta = LHS \ RHS;
disp(F' * F);

%% Compute the new thetas
new_thetas = S.thetas + delta_theta;
end