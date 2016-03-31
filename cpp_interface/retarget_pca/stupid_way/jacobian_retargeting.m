function [F, J] = jacobian_retargeting(phalanges, dofs, model_points, data_points, phalange_indices)
num_model_points = length(model_points);
J = zeros(num_model_points, length(dofs));
F = zeros(num_model_points, 1);

%% Build the Jacobian matrix
for k = 1:num_model_points
    d = data_points{k};
    m = model_points{k};
    
    if isempty(m) || norm(m - d) == 0, continue; end
    n = (d - m) / norm(m - d);
    
    j = zeros(3, length(dofs));
    
    phalange = phalanges{phalange_indices(k)};
    
    for i = 1:length(phalange.kinematic_chain)
       
        dof_id = phalange.kinematic_chain(i);
        phalange_id = dofs{dof_id}.phalange_id;
        u = dofs{dof_id}.axis';
        p = phalanges{phalange_id}.global(1:3, 4);
        T = phalanges{phalange_id}.global;
        v = T * [u; 1]; v = v(1:3) / v(4);
        v = v - p;
        
        switch dofs{dof_id}.type
            case 0
                j(:, dof_id) = cross(v, m - p)';
                %break;
            case 1
                j(:, dof_id) = u;
                %break;
        end
    end
    
    
    %% accumulate sides
    J(k, :) = n' * j;
    F(k) = n' * (d - m);
end






