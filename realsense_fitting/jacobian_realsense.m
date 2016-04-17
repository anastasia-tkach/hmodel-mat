function [f, Jc, Jr] = jacobian_realsense(centers, radii, blocks, model_points, model_indices, block_indices, data_points, settings, fitting_type)

D = settings.D;

num_points = length(model_points);

if strcmp(fitting_type, 'point_to_plane')
    f = zeros(num_points, 1);
    Jc = zeros(num_points, length(centers) * D);
    Jr = zeros(num_points, length(centers));
end
if strcmp(fitting_type, 'point_to_point')
    f = zeros(D * num_points, 1);
    Jc = zeros(D * num_points, length(centers) * D);
    Jr = zeros(D * num_points, length(centers));
end

%% Compute tangent points
[tangent_gradients] = jacobian_tangent_planes(centers, blocks, radii, {'c1', 'c2', 'c3', 'r1', 'r2', 'r3'});
for i = 1:num_points
    q = model_points{i};
    p = data_points{i};
    index =  model_indices{i};
    b = block_indices{i};
    tangent_gradient = tangent_gradients{b};
    
    if isempty(index) || isempty(p) || isempty(q), continue; end
    
    if strcmp(fitting_type, 'point_to_point') && b == 29 || b == 30
        % do not use silhouette term for the wrist
        continue;
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
    
    
    if strcmp(fitting_type, 'point_to_plane')
        
        %% Reweight
        w = 1;
        %d = length(p - q);
        %w = (d + 1e-3)^(-0.5);
        %if (d > 1e-3)
        %    w = w * 3.5;
        %end
        
        %% Compute the cost function
        f(i) =  w * sqrt((p - q)' * (p - q));
        
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
    if strcmp(fitting_type, 'point_to_point')
        f(D * i - D + 1:D * i) = (q - p);
        
        if length(index) == 1
            Jc(D * i - D + 1:D * i, D * index(1) - D + 1:D * index(1)) = dq.dc1;
            Jr(D * i - D + 1:D * i, index(1)) = dq.dr1;
        end
        if length(index) == 2
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
end

