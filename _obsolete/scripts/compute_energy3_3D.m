function [pose, f, Jc, Jr] = compute_energy3_3D(pose, radii, blocks, D)

centers = pose.centers;
num_points = length(pose.model_points);
f = zeros(num_points, 1);
Jc = zeros(num_points, length(centers) * D);
Jr = zeros(num_points, length(centers));

%% Compute tangent points
[tangent_gradients] = blocks_tangent_points_gradients(centers, blocks, radii, D);
for i = 1:num_points
        
    q = pose.model_points{i};
    p = pose.closest_data_points{i};
    index =  pose.model_indices{i};
    if isempty(index) || isempty(p), continue; end
    
    %% Determine current block
    if length(index) == 3
        for b = 1:length(blocks)
            if (length(blocks{b}) < 3), continue; end
            abs_index = [abs(index(1)), abs(index(2)), abs(index(3))];
            indicator = ismember(blocks{b}, abs_index);
            if sum(indicator) == 3, tangent_gradient = tangent_gradients{b}; break; end
        end
    end
    
    %% Compute gradients of the model point
    if length(index) == 1
        [q, dq.dc1, dq.dr1] = jacobian_sphere(q, centers{index(1)}, radii{index(1)});
        variables = {'c1', 'r1'};
    end
    if length(index) == 2
        [q, dq.dc1, dq.dc2, dq.dr1, dq.dr2] = jacobian_convsegment(q, centers{index(1)}, centers{index(2)}, radii{index(1)}, radii{index(2)});
        variables = {'c1', 'r1', 'c2', 'r2'};
    end
    if length(index) == 3
        v1 = tangent_gradient.v1; v2 = tangent_gradient.v2; v3 = tangent_gradient.v3;
        u1 = tangent_gradient.u1; u2 = tangent_gradient.u2; u3 = tangent_gradient.u3;
        Jv1 = tangent_gradient.Jv1; Jv2 = tangent_gradient.Jv2; Jv3 = tangent_gradient.Jv3;
        Ju1 = tangent_gradient.Ju1; Ju2 = tangent_gradient.Ju2; Ju3 = tangent_gradient.Ju3;
        if (index(1) > 0)
            [q, dq.dc1, dq.dc2, dq.dc3, dq.dr1, dq.dr2, dq.dr3] = jacobian_convtriangle(q, v1, v2, v3, Jv1, Jv2, Jv3, D);
        else
            [q, dq.dc1, dq.dc2, dq.dc3, dq.dr1, dq.dr2, dq.dr3] = jacobian_convtriangle(q, u1, u2, u3, Ju1, Ju2, Ju3, D);
        end
        variables = {'c1', 'r1', 'c2', 'r2', 'c3', 'r3'};
    end
    
    %% Compute the cost function
    f(i) =  sqrt((p - q)' * (p - q));
    for l = 1:length(variables)
        variable = variables{l};
        switch variable
            case 'c1', dq.dv = dq.dc1; case 'r1', dq.dv = dq.dr1;
            case 'c2', dq.dv = dq.dc2; case 'r2', dq.dv = dq.dr2;
            case 'c3', dq.dv = dq.dc3; case 'r3', dq.dv = dq.dr3;
        end
        df.dv = - (p - q)' * dq.dv / sqrt((p - q)' * (p - q));
        switch variable
            case 'c1', df.dc1 = df.dv; case 'r1', df.dr1 = df.dv;
            case 'c2', df.dc2 = df.dv; case 'r2', df.dr2 = df.dv;
            case 'c3', df.dc3 = df.dv; case 'r3', df.dr3 = df.dv;
        end
    end
    
    %% Fill in the Jacobian
    if length(index) == 1
        Jc(i, D * index(1) - D + 1:D * index(1)) = df.dc1;
        Jr(i, index(1)) = df.dr1;
    end
    if length(index) == 2
        Jc(i, D * index(1) - D + 1:D * index(1)) = df.dc1;
        Jc(i, D * index(2) - D + 1:D * index(2)) = df.dc2;
        Jr(i, index(1)) = df.dr1;
        Jr(i, index(2)) = df.dr2;
    end   
    if length(index) == 3
        Jc(i, D * abs(index(1)) - D + 1:D * abs(index(1))) = df.dc1;
        Jc(i, D * abs(index(2)) - D + 1:D * abs(index(2))) = df.dc2;
        Jc(i, D * abs(index(3)) - D + 1:D * abs(index(3))) = df.dc3;
        Jr(i, abs(index(1))) = df.dr1;
        Jr(i, abs(index(2))) = df.dr2;
        Jr(i, abs(index(3))) = df.dr3;
    end
    
end

pose.f3 = f;
pose.Jc3 = Jc;
pose.Jr3 = Jr;
