clc;
D = 3;
c1 = 0.5 * rand(D ,1);
c2 = 0.5 * rand(D ,1);
p = rand(D, 1);

% function [f, df] = jacobian_arap_segment(p, c1, c2)
D = length(p);
u = c2 - c1;
v = p - c1;
alpha = u' * v / (u' * u);
q = c1 + alpha * u;
disp(q);

arguments = 'c1, c2';
variables = {'c1', 'c2'};
p_ = @(c1, c2) p;
c1_ = @(c1, c2) c1;
c2_ = @(c1, c2) c2;


Jnumerical = [];
Janalytical = [];

for var = 1:length(variables)
    variable = variables{var};
    switch variable
        case 'c1', dc1= @(c1, c2) eye(D, D); dc2 = @(c1, c2) zeros(D, D);           
            dp = @(c1, c2) zeros(D, D);
        case 'c2',  dc1= @(c1, c2) zeros(D, D); dc2 = @(c1, c2) eye(D, D);          
            dp = @(c1, c2) zeros(D, D);       
    end
    
    %% u =  c2 - c1; v =  p - c1;
    [u, du] = difference_handle(c2_, dc2, c1_, dc1, arguments);
    [v, dv] = difference_handle(p_, dp, c1_, dc1, arguments);
    
    %% q - closest point on the axis, q = c1 + alpha * u;
    [s, ds] = dot_handle(u, du, v, dv, arguments);
    [tn, dtn] = product_handle(s, ds, u, du, arguments);
    [uu, duu] = dot_handle(u, du, u, du, arguments);
    [b, db] = ratio_handle(tn, dtn, uu, duu, arguments);
    [q, dq] =  sum_handle(c1_, dc1, b, db, arguments);
   
    O = q;
    dO = dq;
    %% Display result
    switch variable
        case 'c1'
            O = @(c1) O(c1, c2);
            Jnumerical = [Jnumerical, my_gradient(O, c1)];
            Janalytical = [Janalytical, dO(c1, c2)];
        case 'c2'
            O = @(c2) O(c1, c2);
            Jnumerical = [Jnumerical, my_gradient(O, c2)];
            Janalytical = [Janalytical, dO(c1, c2)];
    end
end
O(c2)
Jnumerical
Janalytical










