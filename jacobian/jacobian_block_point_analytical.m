% clc; clear;
% D = 2;
% b1 = rand(D, 1);
% p = rand(D, 1);
% a1 = randn(1, 1) / pi;
% d1 = rand(1, 1);

function [f, df] = jacobian_ik_point_analytical(p, b1, d1, a1)

D = length(p);




arguments = 'c1, a1';
variables = {'c1', 'a1'};
%d1 = d1 * [1; 0];

b1_ = @(b1, a1)  b1;

R  = @(b1, a1)[cos(a1), -sin(a1); sin(a1), cos(a1)];
w1 = @(b1, a1) [cos(a1), -sin(a1); sin(a1), cos(a1)] * d1;

%% Compute function

c1 =  b1 + R(b1, a1) * d1;

%% Compute weight
theta_tilde = acos((c1 - b1)' * (p - b1) / norm(c1 - b1) / norm(p - b1));
beta = norm(d1);
alpha = d1' * (p - b1) / norm(d1) ;
sin_theta = alpha * sin(theta_tilde) / beta;
if sin_theta > 1, sin_theta = 1; end
theta = asin(sin_theta);
weight = theta / theta_tilde;
%weight = alpha / beta;
%weight = 1;

Jnumerical = [];
Janalytical = [];
for v = 1:length(variables)
    variable = variables{v};
    switch variable
        case 'c1'
            db1 = @(b1, a1) eye(D, D);  
            dw1 = @(b1, a1) zeros(D, D);
        case 'a1'
            db1 = @(b1, a1) zeros(D, 1);
            dw1 = @(b1, a1) [-sin(a1), - cos(a1); cos(a1), -sin(a1)] * d1;
    end
    
    %% c2 =  c1 + d * v;
    %[g, dg] = product_handle(d1_, dd1, w1, dw1, arguments);
    [q, dq] = sum_handle(b1_, db1, w1, dw1, arguments);
    
    O = q;
    dO = dq;   
    f = q(b1, a1);
    %% Display result
    switch variable
        case 'c1'            
            df.dc1 = dq(b1, a1);
            O = @(b1) O(b1, a1);
            Jnumerical = [Jnumerical, my_gradient(O, b1)];
            Janalytical = [Janalytical, dO(b1, a1)];
        case 'a1'            
            df.da1 = weight * dq(b1, a1);
            O = @(a1) O(b1, a1);
            Jnumerical = [Jnumerical, my_gradient(O, a1)];
            Janalytical = [Janalytical, dO(b1, a1)];
    end
end

% disp([c1 f]);
% Jnumerical
% Janalytical

%% Display linear approximation
% draw_circle(b1, norm(d1), 'g');
% myline(b1, p, 'c');
% l = p - d1 * (alpha - norm(d1)) / norm(d1);
% myline(p, l, 'c');
% myline(q(b1, a1), l, 'c');





