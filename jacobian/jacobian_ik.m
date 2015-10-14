function [F, Jc, Ja] = jacobian_ik(centers, radii, distances, angles, blocks, block_indices, model_points, model_indices, data_points, base_indices, D)
num_rotations = 1;
num_points = length(model_points);
% F = zeros(num_points, 1);
% Jc = zeros(num_points, length(blocks) * D);
% Ja = zeros(num_points, length(blocks) * num_rotations);

F = zeros(num_points * D, 1);
Jc = zeros(num_points * D, length(blocks) * D);
Ja = zeros(num_points * D, length(blocks) * num_rotations);

%% Compute tangent points
%[tangent_gradients] = jacobian_tangent_planes(centers, blocks, radii, {'c1', 'c2', 'c3'});
for i = 1:num_points
    
    q = model_points{i};
    p = data_points{i};
    center_index =  model_indices{i};
    block_index = block_indices{i};
    if isempty(center_index) || isempty(p), continue; end
    
    %% Compute gradients of the model point
    if length(center_index) == 1
        c1 = centers{base_indices{center_index(1)}};
        r1 = radii{center_index(1)};
        d1 = centers{center_index(1)} - centers{base_indices{center_index(1)}};
        %a1 = angles{block_indices{i}};
        a1 = 0;
        variables = {'c1', 'a1'};
        %[q, dq] = jacobian_ik_sphere(q, c1, r1, d1, angles{block_indices{i}}, variables);
        [q, dq] = jacobian_ik_point_analytical(p, c1, d1, a1);
        
    end
    if length(center_index) == 2
        variables = {'c1', 'c2', 'a1', 'a2'};
        c1 = centers{base_indices{center_index(1)}};
        r1 = radii{center_index(1)};
        d1 = norm(centers{base_indices{center_index(1)}} - centers{center_index(1)});
        c2 = centers{base_indices{center_index(2)}};
        r2 = radii{center_index(2)};
        d2 = norm(centers{base_indices{center_index(2)}} - centers{center_index(2)});
        [q, dq] = jacobian_ik_convsegment(q, centers{center_index(1)}, centers{center_index(2)}, radii{center_index(1)}, radii{center_index(2)}, variables);
    end
    
    if length(center_index) == 3
        continue;
    end
    %if length(center_index) == 3
    %variables = {'c1', 'c2', 'c3'};
    %v1 = tangent_gradient.v1; v2 = tangent_gradient.v2; v3 = tangent_gradient.v3;
    %u1 = tangent_gradient.u1; u2 = tangent_gradient.u2; u3 = tangent_gradient.u3;
    %Jv1 = tangent_gradient.Jv1; Jv2 = tangent_gradient.Jv2; Jv3 = tangent_gradient.Jv3;
    %Ju1 = tangent_gradient.Ju1; Ju2 = tangent_gradient.Ju2; Ju3 = tangent_gradient.Ju3;
    %if (center_index(1) > 0)
    %    [q, dq] = jacobian_convtriangle(q, v1, v2, v3, Jv1, Jv2, Jv3, variables);
    %else
    %    [q, dq] = jacobian_convtriangle(q, u1, u2, u3, Ju1, Ju2, Ju3, variables);
    %end
    %end
    
    %% Compute the cost function
    F(D * i - D + 1:D * i) = (q - p);
%     F(i) =  sqrt((p - q)' * (p - q));
%         for l = 1:length(variables)
%             variable = variables{l};
%             switch variable
%                 case 'c1', dq.dv = dq.dc1;
%                 case 'a1', dq.dv = dq.da1;
%             end
%             df.dv = - (p - q)' * dq.dv / sqrt((p - q)' * (p - q));
%             switch variable
%                 case 'c1', df.dc1 = df.dv;
%                 case 'a1', df.da1 = df.dv;
%             end
%         end
    
    %% Fill in the Jacobian
    if length(center_index) == 1
%         Jc(i, D * block_index - D + 1:D * block_index) = df.dc1;
%         if center_index(1) ~= blocks{block_indices{i}}(1)
%         Ja(i, block_index) = df.da1;
%         end
        Jc(D * i - D + 1:D * i, D * block_index - D + 1:D * block_index) = dq.dc1;
        if center_index(1) ~= blocks{block_indices{i}}(1)
            Ja(D * i - D + 1:D * i, block_index) = dq.da1;
        end
    end
    %if length(center_index) == 2
    %Jc(i, D * center_index(1) - D + 1:D * center_index(1)) = df.dc1;
    %Jc(i, D * center_index(2) - D + 1:D * center_index(2)) = df.dc2;
    %end
    %if length(center_index) == 3
    %Jc(i, D * abs(center_index(1)) - D + 1:D * abs(center_index(1))) = df.dc1;
    %Jc(i, D * abs(center_index(2)) - D + 1:D * abs(center_index(2))) = df.dc2;
    %Jc(i, D * abs(center_index(3)) - D + 1:D * abs(center_index(3))) = df.dc3;
    %end
    
end

