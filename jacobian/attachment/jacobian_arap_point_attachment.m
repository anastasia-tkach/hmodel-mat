function [f, gradients] = jacobian_arap_point_attachment(p, c1, gradients)

f = c1;
for var = 1:length(gradients)    
    dc1 = gradients{var}.dc1;   
    gradients{var}.df = dc1;
end

