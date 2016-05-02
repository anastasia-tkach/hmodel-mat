function [f, Jc, Jr] = jacobian_fitting_normal(centers, radii, blocks, model_points, model_indices, block_indices, data_points, settings)

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
    
    q = model_points{i};
    p = data_points{i};
    index =  model_indices{i};
    
    if settings.p == 5 && any(ismember(block_indices{i}, fist_skip_blocks_indices)), continue; end
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
    
  
    %% Fill in the Jacobian
    f(D * i - D + 1:D * i) = (q - p);
   
    if length(index) == 1
        Jc(D * i - D + 1:D * i, D * index(1) - D + 1:D * index(1)) = dq.dc1;
        Jr(D * i - D + 1:D * i, index(1)) = dq.dr1;
    end
    if length(index) == 2%
        Jc(D * i - D + 1:D * i, D * index(1) - D + 1:D * index(1)) = dq.dc1;
        Jc(D * i - D + 1:D * i, D * index(2) - D + 1:D * index(2)) = dq.dc2;
        Jr(D * i - D + 1:D * i, index(1)) = dq.dr1;
        Jr(D * i - D + 1:D * i, index(2)) = dq.dr2;
    end
    if length(index) == 3
        index = abs(index);
        Jc(D * i - D + 1:D * i, D * index(1) - D + 1:D * index(1)) = dq.dc1;
        Jc(D * i - D + 1:D * i, D * index(2) - D + 1:D * index(2)) = dq.dc2;
        Jc(D * i - D + 1:D * i, D * index(3) - D + 1:D * index(3)) = dq.dc3;
        Jr(D * i - D + 1:D * i, index(1)) = dq.dr1;
        Jr(D * i - D + 1:D * i, index(2)) = dq.dr2;
        Jr(D * i - D + 1:D * i, index(3)) = dq.dr3;
    end
    
end

