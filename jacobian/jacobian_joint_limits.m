function [f3, J3] = jacobian_joint_limits(centers, rotations, edge_indices, edge_ids, restpose_edges, parents, limits, D)

rotation = @(x) [cos(x), -sin(x); sin(x), cos(x)];
Rx  = @(x) [1, 0, 0; 0, cos(x), -sin(x); 0, sin(x), cos(x)];
Ry = @(x) [cos(x), 0, sin(x); 0, 1, 0; -sin(x), 0, cos(x)];
Rz = @(x) [cos(x), -sin(x), 0; sin(x), cos(x), 0; 0, 0, 1];
initial = [0; 1; 0];

%% Joint limits
limits_rotations = cell(length(rotations), 1);

for i = 1:length(edge_indices)
    if isempty(parents{i}), continue; end
    parent_rotation = rotations{edge_ids(parents{i})};
    child_rotation =  rotations{edge_ids(i)};
    parent_edge = parent_rotation * restpose_edges{edge_ids(parents{i})};
    child_edge = child_rotation * restpose_edges{edge_ids(i)};
    
    if D == 2
        theta = acos(parent_edge' * child_edge / norm(parent_edge) / norm(child_edge));
        if norm(child_edge / norm(child_edge) - rotation(theta) * parent_edge / norm(parent_edge)) > 1e-10, theta = - theta; end
        if theta > 0.01, limits_rotations{edge_ids(i)} = rotations{edge_ids(parents{i})}; end
    end
    
    if D == 3
        if isempty(limits{i}), continue; end
        
        parent_rotation = vrrotvec2mat(vrrotvec(parent_edge, initial));
        parent_edge = parent_rotation * parent_edge;
        child_edge = parent_rotation * child_edge;
        R = vrrotvec2mat(vrrotvec(child_edge, parent_edge));
        
        theta = SpinCalc('DCMtoEA132', R, 1e-10, 0) / 180 * pi;
        for h = 1:3, if abs(theta(h)) > pi, theta(h) = theta(h) - 2 * pi; end; end
        
        theta_limited = max(theta, limits{i}.theta_min);
        theta_limited = min(theta_limited, limits{i}.theta_max);
        
        %% R' = Rx(theta(1)) * Rz(theta(2)) * Ry(theta(3));
        disp(['i = ', num2str(i)]); disp(theta);
        limits_rotations{edge_ids(i)} = rotations{edge_ids(i)} *  parent_rotation' * ...
            Rx(theta_limited(1)) * Rz(theta_limited(2)) *  Ry(theta_limited(3)) * ...
            Ry(theta(3))' * Rz(theta(2))' * Rx(theta(1))' * parent_rotation;
    end
    
end
disp(' ');

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
        f3(D * (k - 1) + 1: D * k) = c - b - e;
        J3(D * (k - 1) + 1: D * k, D * (index1 - 1) + 1:D * index1) = -eye(D, D);
        J3(D * (k - 1) + 1: D * k, D * (index2 - 1) + 1:D * index2) = eye(D, D);
        
    end
end

