function [tangent_gradients] = jacobian_tangent_planes_attachment(centers, blocks, radii, attachments)
if length(centers{1}) == 2, return; end

tangent_gradients = cell(length(blocks), 1);

for i = 1:length(blocks)
    
    if length(blocks{i}) == 3
        
        c1 = centers{blocks{i}(1)};
        c2 = centers{blocks{i}(2)};
        c3 = centers{blocks{i}(3)};
        
        r1 = radii{blocks{i}(1)};
        r2 = radii{blocks{i}(2)};
        r3 = radii{blocks{i}(3)};
        
        gradients = get_parameters_gradients(blocks{i}, attachments, length(c1));
        [v1, v2, v3, u1, u2, u3, gradients] = jacobian_tangent_plane_attachment(c1, c2, c3, r1, r2, r3, gradients);
        
        tangent_gradients{i}.v1 = v1;
        tangent_gradients{i}.v2 = v2;
        tangent_gradients{i}.v3 = v3;        
        tangent_gradients{i}.u1 = u1;
        tangent_gradients{i}.u2 = u2;
        tangent_gradients{i}.u3 = u3;  
        
        tangent_gradients{i}.gradients = gradients;
       
    end
end
