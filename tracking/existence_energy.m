function [F, J] = existence_energy(centers, radii, blocks, attachments, settings)

D = settings.D;

factor = 1.3;

num_constaints = 2;
F  = zeros(num_constaints, 1);
J = zeros(num_constaints, length(centers) * D);

count = 1;
for b = 1:length(blocks)
    
    %% Tangent cone
    indices = nchoosek(blocks{b}, 2);
    index1 = indices(:, 1);
    index2 = indices(:, 2);
    for i = 1:length(index1)
        [r1, max_index] = max([radii{index1(i)}, radii{index2(i)}]);
        [r2, min_index] = min([radii{index1(i)}, radii{index2(i)}]);
        indices = [index1(i), index2(i)]; i1 = indices(max_index); i2 = indices(min_index);
        c1 = centers{i1}; c2 = centers{i2};
        if norm(c1 - c2) - factor * (r1 - r2) > 0,
            continue;
        end
        
        gradients = get_parameters_gradients([i1, i2], attachments, D, 'tracking');
        [f, gradients] = jacobian_tangent_cone_existence_attachment(c1, c2, r1, r2, factor, gradients);
        
        F(count) = f;
        for j = 1:length(gradients)
            J(count, D * gradients{j}.index - D + 1:D * gradients{j}.index) = gradients{j}.df;
        end
        count = count + 1;
    end
    
    %% Tangent plane
    if length(blocks{b}) == 3
        indices = nchoosek(blocks{b}, 2);
        index1 = indices(:, 1);
        index2 = indices(:, 2);
        
        for i = 1:length(index1)
            [r1, max_index] = max([radii{index1(i)}, radii{index2(i)}]);
            [r2, min_index] = min([radii{index1(i)}, radii{index2(i)}]);
            indices = [index1(i), index2(i)]; i1 = indices(max_index); i2 = indices(min_index);
            i3 = sum([blocks{b}(1), blocks{b}(2), blocks{b}(3)]) - i1 - i2; r3 = radii{i3};
            c1 = centers{i1}; c2 = centers{i2}; c3 = centers{i3};
            
            %% Compute objective function
            z = c1 + (c2 - c1) * r1 / (r1 - r2);
            gamma = (c2 - c1)' * (c3 - c1) / ((c2 - c1)' * (c2 - c1)); t = c1 + gamma * (c2 - c1);
            if (t - c1)' * (z - c1) > 0 && norm(t - c1) > norm(z - c1), t = c1 + (z - c1) + (z - t); end
            delta_r = norm(c2 - t) * (r1 - r2) / norm(c2 - c1);
            if (t - c1)' * (c2 - c1) > 0 && norm(t - c1) > norm(c2 - c1), delta_r = -delta_r; end
            r_tilde = delta_r + r2; beta = asin((r1 - r2) / norm(c2 - c1));
            r = r_tilde/cos(beta); eta = r3 + norm(c3 - t); f = eta - factor * r;
            if f > 0, continue; end
            
            %% Compute gradient
            gradients = get_parameters_gradients([i1, i2, i3], attachments, D, 'tracking');
            [f, gradients] = jacobian_tangent_plane_existence_attachment(c1, c2, c3, r1, r2, r3, factor, gradients);
            
            F(count) = f;
            for j = 1:length(gradients)
                J(count, D * gradients{j}.index - D + 1:D * gradients{j}.index) = gradients{j}.df;
            end
            count = count + 1;
        end
    end
end






