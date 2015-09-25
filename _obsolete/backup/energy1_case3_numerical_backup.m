% clc; clear; D = 3;
% while(true)
%     c1 = rand(D, 1); c2 = rand(D, 1); c3 = rand(D, 1);
%     x1 = rand(1, 1); x2 = rand(1, 1); x3 = rand(1, 1); x = [x1, x2, x3];
%     [r1, i1] = max(x); [r3, i3] = min(x); x([i1, i3]) = 0; r2 = max(x);
%     if norm(c1 - c2) > r1 && norm(c1 - c3) > r1 &&  norm(c2 - c3) > r2, break; end
% end
% p = rand(D, 1); index = -1;

function [f, Jc1, Jr1, Jc2, Jr2, Jc3, Jr3] = energy1_case3_numerical_backup(p, v1, v2, v3, Jv1, Jv2, Jv3, D)

%% Compute the gradient analytically
% function [f, Jc1, Jr1, Jc2, Jr2, Jc3, Jr3] = energy1_case3(p, v1, v2, v3, Jv1, Jv2, Jv3, c1, c2, c3, r1, r2, r3, index, D)
% energy1_case3_analytical(p, c1, c2, c3, r1, r2, r3, index, D);

%% Compute the gradient numerically
variables = {'c1', 'c2', 'c3', 'r1', 'r2', 'r3'};
%Jnumerical = [];

for v = 1:length(variables)
    variable = variables{v};
    switch variable
        case 'c1'
            dv1 = Jv1.dc1; dv2 = Jv2.dc1; dv3 = Jv3.dc1; dp =  zeros(D, D);
        case 'c2'
            dv1 = Jv1.dc2; dv2 = Jv2.dc2; dv3 = Jv3.dc2; dp =  zeros(D, D);
        case 'c3'
            dv1 = Jv1.dc3; dv2 = Jv2.dc3; dv3 = Jv3.dc3; dp =  zeros(D, D);
        case 'r1'
            dv1 = Jv1.dr1; dv2 = Jv2.dr1; dv3 = Jv3.dr1; dp =  zeros(D, 1);
        case 'r2'
            dv1 = Jv1.dr2; dv2 = Jv2.dr2; dv3 = Jv3.dr2; dp =  zeros(D, 1);
        case 'r3'
            dv1 = Jv1.dr3; dv2 = Jv2.dr3; dv3 = Jv3.dr3; dp =  zeros(D, 1);
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
    [t, dt] = difference_derivative(p, dp, O1, dO1);
    
    % f = norm(p - t)
    [O1, dO1] = difference_derivative(p, dp, t, dt);
    [f, df] = norm_derivative(O1, dO1);
    
    switch variable
        case 'c1', Jc1 = df;
        case 'c2', Jc2 = df;
        case 'c3', Jc3 = df;            
        case 'r1', Jr1 = df;
        case 'r2', Jr2 = df;
        case 'r3', Jr3 = df; 
    end     
    %Jnumerical = [Jnumerical, df];
end
%disp(Jnumerical);












