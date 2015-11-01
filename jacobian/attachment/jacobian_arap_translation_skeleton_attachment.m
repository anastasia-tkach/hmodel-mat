function [F, Jc] = jacobian_arap_translation_skeleton_attachment(centers, model_points, model_indices, data_points, attachments, D)

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
    
    %% Set up the gradients
    
    gradients = get_parameters_gradients(index, attachments, length(p));
       
    if length(index) == 1
        c1 = centers{index(1)};
        [q, gradients] = jacobian_arap_point_attachment(q, c1, gradients);
    end
    
    if length(index) == 2
        c1 = centers{index(1)}; c2 = centers{index(2)};
        [q, gradients] = jacobian_arap_segment_attachment(q, c1, c2, gradients);
    end
    
    %if length(index) == 3
    %c1 = centers{index(1)}; c2 = centers{index(2)}; c3 = centers{index(3)};
    %[q, dq] = jacobian_arap_triangle(q, c1, c2, c3);
    %end
    
    %% Fill in the Jacobian
    F(D * i - D + 1:D * i) = (q - p);
    %if length(index) == 1
    %Jc(D * i - D + 1:D * i, D * index(1) - D + 1:D * index(1)) = dq.dc1;
    %end
    for j = 1:length(gradients)
        Jc(D * i - D + 1:D * i, D * gradients{j}.index - D + 1:D * gradients{j}.index) = gradients{j}.df;
    end
    %if length(index) == 3
    %index = abs(index);
    %Jc(D * i - D + 1:D * i, D * index(1) - D + 1:D * index(1)) = dq.dc1;
    %Jc(D * i - D + 1:D * i, D * index(2) - D + 1:D * index(2)) = dq.dc2;
    %Jc(D * i - D + 1:D * i, D * index(3) - D + 1:D * index(3)) = dq.dc3;
    %end
    
end

