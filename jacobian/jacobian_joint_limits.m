function [f3, J3] = jacobian_joint_limits(centers, rotations, edge_indices, edge_ids, restpose_edges, initial_edges, parents, limits, attachments, D)

rotation = @(x) [cos(x), -sin(x); sin(x), cos(x)];
Rx  = @(x) [1, 0, 0; 0, cos(x), -sin(x); 0, sin(x), cos(x)];
Ry = @(x) [cos(x), 0, sin(x); 0, 1, 0; -sin(x), 0, cos(x)];
Rz = @(x) [cos(x), -sin(x), 0; sin(x), cos(x), 0; 0, 0, 1];

%% Joint limits
limits_rotations = cell(length(rotations), 1);

for i = 1:length(edge_indices)
    if isempty(parents{i}), continue; end
    parent_rotation = rotations{edge_ids(parents{i})};
    child_rotation =  rotations{edge_ids(i)};
    parent_edge = parent_rotation * restpose_edges{edge_ids(parents{i})};
    child_edge = child_rotation * restpose_edges{edge_ids(i)};
    
    if D == 2
        G = rotation(vrrotvec2D(parent_edge, initial_edges{edge_ids(parents{i})}));
        rotated_parent_edge = G * parent_edge; rotated_child_edge = G * child_edge;
        
        theta = vrrotvec2D(rotated_parent_edge, rotated_child_edge);
        if theta > limits{i}.theta_min && theta < limits{i}.theta_max, continue; end
        
        theta_limited = max(theta, limits{i}.theta_min);
        theta_limited = min(theta_limited, limits{i}.theta_max);
        limits_rotations{edge_ids(i)} = G' * rotation(theta_limited) * rotation(theta)' * G * rotations{edge_ids(i)};
    end
    
    if D == 3
        if isempty(limits{i}), continue; end
        
        
        %% Find global rotation
%                 a = initial_edges{edge_ids(parents{i})} / norm(initial_edges{edge_ids(parents{i})});
%                 b = initial_edges{19} / norm(initial_edges{19});
%                 u = parent_edge/norm(parent_edge);
%                 v = rotations{19} * restpose_edges{19} / norm(restpose_edges{19});
%                 F = [a'; b']; E = [u'; v'];
%                 S = E' * F;
%                 [U, ~, V] = svd(S);
%                 G = V * U';
%                 if det(G) < 0, U(:, D) = -  U(:, D); G = V * U'; end
        
        %% Unapply global rotation
        initial = [0; 1; 0];
        G = vrrotvec2mat(vrrotvec(parent_edge, initial));
        
        rotated_parent_edge = G * parent_edge;
        rotated_child_edge = G * child_edge;
        R = vrrotvec2mat(vrrotvec(rotated_child_edge, rotated_parent_edge));
        
        %JB = vrrotvec2mat(vrrotvec([0; 1; 0], GA' * edge3))
        %I = vrrotvec2mat(vrrotvec(initial_edges{edge_ids(i)}, initial_edges{edge_ids(parents{i})}));
        %R = R * I';
        %R = R * I' * J';
        %R = R * J' * I';
        
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
        
        %% Initial rotation
        
        %% R' = Rx(theta(1)) * Rz(theta(2)) * Ry(theta(3));
        if i < 4, disp(['i = ', num2str(i)]); disp(theta); end
        limits_rotations{edge_ids(i)} = G' * Rx(theta_limited(1)) * Rz(theta_limited(2)) *  Ry(theta_limited(3)) * ...
            Ry(theta(3))' * Rz(theta(2))' * Rx(theta(1))' * G * rotations{edge_ids(i)};
    end
    
end

%% Join limits energy

k = 0;
f3 = zeros(2, 1);
J3 = zeros(2, length(centers) * D);
for i = 1:length(edge_indices)
    for j = 1:length(edge_indices{i})
        k = k + 1;
        if isempty(limits_rotations{k}), continue; end
        
        index1 = edge_indices{i}{j}(1);
        index2 = edge_indices{i}{j}(2);
        b = centers{index1}; c = centers{index2};
        e = limits_rotations{k} * restpose_edges{k};
        %f3(D * (k - 1) + 1: D * k) = c - b - e;
        %J3(D * (k - 1) + 1: D * k, D * (index1 - 1) + 1:D * index1) = -eye(D, D);
        %J3(D * (k - 1) + 1: D * k, D * (index2 - 1) + 1:D * index2) = eye(D, D);
        
        gradients = get_parameters_gradients([index1, index2], attachments, D);
        f3(D * (k - 1) + 1: D * k) = c - b - e;
        for l = 1:length(gradients)
            J3(D * (k - 1) + 1: D * k, D * (gradients{l}.index - 1) + 1:D * gradients{l}.index) = gradients{l}.dc2 - gradients{l}.dc1;
        end
        
        
    end
end

