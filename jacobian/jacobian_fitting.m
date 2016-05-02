function [f, Jc, Jr] = jacobian_fitting(centers, radii, blocks, model_points, model_indices, block_indices, data_points, settings)

D = settings.D;

%disp('loading fist skip blocks');
load('_my_hand/semantics/fist_skip_blocks_indices');

num_points = length(model_points);
f = zeros(num_points, 1);
Jc = zeros(num_points, length(centers) * D);
Jr = zeros(num_points, length(centers));

%% Compute tangent points
[tangent_gradients] = jacobian_tangent_planes(centers, blocks, radii, {'c1', 'c2', 'c3', 'r1', 'r2', 'r3'});
for i = 1:num_points
    
    if settings.p == 5 && any(ismember(block_indices{i}, fist_skip_blocks_indices)), continue; end
    
    q = model_points{i};
    p = data_points{i};
    index =  model_indices{i};
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
        variables = {'c1', 'r1'};
        [q, dq] = jacobian_sphere(q, centers{index(1)}, radii{index(1)}, variables);
        
    end
    if length(index) == 2
        variables = {'c1', 'c2', 'r1', 'r2'};
        [q, dq] = jacobian_convsegment(q, centers{index(1)}, centers{index(2)}, radii{index(1)}, radii{index(2)}, variables);
    end
    if length(index) == 3
        variables = {'c1', 'c2', 'c3', 'r1', 'r2', 'r3'};
        v1 = tangent_gradient.v1; v2 = tangent_gradient.v2; v3 = tangent_gradient.v3;
        u1 = tangent_gradient.u1; u2 = tangent_gradient.u2; u3 = tangent_gradient.u3;
        Jv1 = tangent_gradient.Jv1; Jv2 = tangent_gradient.Jv2; Jv3 = tangent_gradient.Jv3;
        Ju1 = tangent_gradient.Ju1; Ju2 = tangent_gradient.Ju2; Ju3 = tangent_gradient.Ju3;
        if (index(1) > 0)
            [q, dq] = jacobian_convtriangle(q, v1, v2, v3, Jv1, Jv2, Jv3, variables);
        else
            [q, dq] = jacobian_convtriangle(q, u1, u2, u3, Ju1, Ju2, Ju3, variables);
        end
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

