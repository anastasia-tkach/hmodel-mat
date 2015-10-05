% clc; clear; D = 3;
% while(true)
%     c1 = rand(D, 1); c2 = rand(D, 1); c3 = rand(D, 1);
%     x1 = rand(1, 1); x2 = rand(1, 1); x3 = rand(1, 1); x = [x1, x2, x3];
%     [r1, i1] = max(x); [r3, i3] = min(x); x([i1, i3]) = 0; r2 = max(x);
%     if norm(c1 - c2) > r1 && norm(c1 - c3) > r1 &&  norm(c2 - c3) > r2, break; end
% end
% p = rand(D, 1); index = -1;

function [f, Jc1, Jr1, Jc2, Jr2, Jc3, Jr3] = energy1_case3_numerical(p, v1, v2, v3, Jv1, Jv2, Jv3, D)

%% Compute the gradient analytically
% function [f, Jc1, Jr1, Jc2, Jr2, Jc3, Jr3] = energy1_case3(p, v1, v2, v3, Jv1, Jv2, Jv3, c1, c2, c3, r1, r2, r3, index, D)
% energy1_case3_analytical(p, c1, c2, c3, r1, r2, r3, index, D);

%% Compute the gradient numerically
variables = {'c1', 'c2', 'c3', 'r1', 'r2', 'r3'};

[q, dq_dc1, dq_dc2, dq_dc3, dq_dr1, dq_dr2, dq_dr3] = jacobian_convtriangle(p, v1, v2, v3, Jv1, Jv2, Jv3, D);

for v = 1:length(variables)
    variable = variables{v};
    switch variable
        case 'c1'
            dq = dq_dc1; dp =  zeros(D, D);
        case 'c2'
            dq = dq_dc2; dp =  zeros(D, D);
        case 'c3'
            dq = dq_dc3; dp =  zeros(D, D);
        case 'r1'
            dq = dq_dr1; dp =  zeros(D, 1);
        case 'r2'
            dq = dq_dr2; dp =  zeros(D, 1);
        case 'r3'
            dq = dq_dr3; dp =  zeros(D, 1);
    end
      
    % f = norm(p - t)
    [O1, dO1] = difference_derivative(p, dp, q, dq);
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












