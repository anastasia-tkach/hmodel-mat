function [f, gradients] = jacobian_convtriangle_attachment(p, tangent_gradient, gradients, mode)

D = length(p);
dp = zeros(D, D);

switch mode
    case 'v'
        v1 = tangent_gradient.v1;
        v2 = tangent_gradient.v2;
        v3 = tangent_gradient.v3;
    case 'u'
        v1 = tangent_gradient.u1;
        v2 = tangent_gradient.u2;
        v3 = tangent_gradient.u3;
end

for var = 1:length(tangent_gradient.gradients)
    switch mode
        case 'v'
            dv1 = tangent_gradient.gradients{var}.dv1;
            dv2 = tangent_gradient.gradients{var}.dv2;
            dv3 = tangent_gradient.gradients{var}.dv3;
        case 'u'
            dv1 = tangent_gradient.gradients{var}.du1;
            dv2 = tangent_gradient.gradients{var}.du2;
            dv3 = tangent_gradient.gradients{var}.du3;
    end
    
    % m = cross(v1 - v2, v1 - v3);
    [O1, dO1] = difference_derivative(v1, dv1, v2, dv2);
    [O2, dO2] = difference_derivative(v1, dv1, v3, dv3);
    [m, dm] = cross_derivative(O1, dO1, O2, dO2);
    
    % m = m / norm(m);
    [m, dm] = normalize_derivative(m, dm);
    
    % distance = (p - v1)' * m;
    [O1, dO1] = difference_derivative(p, dp, v1, dv1);
    [distance, ddistance] = dot_derivative(O1, dO1, m, dm);
    
    % t = p - distance * m;
    [O1, dO1] = product_derivative(distance, ddistance, m, dm);
    [q, dq] = difference_derivative(p, dp, O1, dO1);
    
    %% Store result
    f = q;
    gradients{var}.df = dq;
end












