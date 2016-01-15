function [F, J] = jacobian_ik(segments, joints, model_points, data_points, segment_indices, settings)
num_model_points = size(model_points, 1);
J = zeros(num_model_points, length(joints));
F = zeros(num_model_points, 1);

%% Build the Jacobian matrix
for k = 1:num_model_points
    d = data_points{k};
    m = model_points{k};
    %n = data_normals{k};
    
    if isempty(m) || norm(m - d) == 0, continue; end
    n = (m - d) / norm(m - d); % model normal
    
    j = zeros(3, length(joints));
    
    segment = segments{segment_indices(k)};
    for l = 1:length(segment.kinematic_chain)
        joint_id = segment.kinematic_chain(l);
        segment_id = joints{joint_id}.segment_id;
        switch joints{joint_id}.axis
            case 'X'
                u = [1; 0; 0];
            case 'Y'
                u = [0; 1; 0];
            case 'Z'
                u = [0; 0; 1];
        end        
        p = segments{segment_id}.global(1:3, 4);
        T = segments{segment_id}.global;
        v = T * [u; 1]; v = v(1:3) / v(4);
        v = v - p;
        
        switch joints{joint_id}.type
            case 'R'
                j(:, joint_id) = cross(v, m - p)';
            case 'T'
                j(:, joint_id) = v;
        end
    end
    
    %% indexes of rotation-type dependencies
    %for l = 1:length(S.kinematic_chain{segment_indices(k)})
    %    i = S.kinematic_chain{segment_indices(k)}(l);
    %    v = S.axis(i, :);
    %
    %    if i > settings.num_translations
    %        p = S.global_translation(i, :)';
    %        j(:, i) = cross(v, m - p)';
    %    else
    %        j(:, i) = v;
    %    end
    %end
    
    %% accumulate sides
    J(k, :) = n' * j;
    F(k) = n' * (d - m);
end
