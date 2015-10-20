function [F, Jc] = jacobian_arap_translation_skeleton(centers, model_points, model_indices, data_points, D)

num_points = length(model_points);
F = zeros(num_points * D, 1);
Jc = zeros(num_points * D, length(centers) * D);

%% Compute tangent points

for i = 1:num_points
    
    q = model_points{i};
    p = data_points{i};
    index =  model_indices{i};
    if isempty(index) || isempty(p), continue; end
    
    %% Compute gradients of the model point
    if length(index) == 1
        c1 = centers{index(1)};
        [q, dq] = jacobian_arap_point(p, c1);        
    end
    if length(index) == 2
        c1 = centers{index(1)}; c2 = centers{index(2)};
        [q, dq] = jacobian_arap_segment(q, c1, c2);
    end    
    if length(index) == 3
        c1 = centers{index(1)}; c2 = centers{index(2)}; c3 = centers{index(3)};
        [q, dq] = jacobian_arap_triangle(p, c1, c2, c3);
    end
    
    %% Fill in the Jacobian
    F(D * i - D + 1:D * i) = (q - p);
    if length(index) == 1
        Jc(D * i - D + 1:D * i, D * index(1) - D + 1:D * index(1)) = dq.dc1;
    end
    if length(index) == 2
        Jc(D * i - D + 1:D * i, D * index(1) - D + 1:D * index(1)) = dq.dc1;
        Jc(D * i - D + 1:D * i, D * index(2) - D + 1:D * index(2)) = dq.dc2;
    end
    if length(index) == 3
        index = abs(index);
        Jc(D * i - D + 1:D * i, D * index(1) - D + 1:D * index(1)) = dq.dc1;
        Jc(D * i - D + 1:D * i, D * index(2) - D + 1:D * index(2)) = dq.dc2;
        Jc(D * i - D + 1:D * i, D * index(3) - D + 1:D * index(3)) = dq.dc3;
    end
    
end

