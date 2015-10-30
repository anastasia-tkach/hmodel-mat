function [F, Jc] = jacobian_arap_translation_attachment(centers, radii, blocks, model_points, model_indices, data_points, attachments, D)

num_points = length(model_points);
F = zeros(num_points * D, 1);
Jc = zeros(num_points * D, length(centers) * D);

%% Compute tangent points
[tangent_gradients] = jacobian_tangent_planes_attachment(centers, blocks, radii, attachments);
for i = 1:num_points
    
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
    gradients = get_parameters_gradients(index, attachments, length(q));
    if length(index) == 1
        [q, gradients] = jacobian_sphere_attachment(q, centers{index(1)}, radii{index(1)}, gradients);
    end
    if length(index) == 2
        [q, gradients] = jacobian_convsegment_attachment(q, centers{index(1)}, centers{index(2)}, radii{index(1)}, radii{index(2)}, gradients);
    end
    if length(index) == 3
        if (index(1) > 0), [q, gradients] = jacobian_convtriangle_attachment(q, tangent_gradient, gradients, 'v');
        else [q, gradients] = jacobian_convtriangle_attachment(q, tangent_gradient, gradients, 'u'); end
    end
    
    %% Fill in the Jacobian
    F(D * i - D + 1:D * i) = (q - p);
    for j = 1:length(gradients)
        Jc(D * i - D + 1:D * i, D * gradients{j}.index - D + 1:D * gradients{j}.index) = gradients{j}.df;
    end
    
end

