function [q, dq_dc1, dq_dr1] = jacobian_sphere_analytical(p, c1, r1)

D = 3;
% c = rand(D, 1);
% p = rand(D, 1);
% r = rand(1, 1);

arguments = 'c1, r1';
variables = {'c1', 'r1'};
p_ = @(c1, r1) p;
c1_ = @(c1, r1) c1;
r1_ = @(c1, r1) r1;

for v = 1:length(variables)
    variable = variables{v};
    switch variable
        case 'c1'
            dc1 = @(c1, r1) eye(D, D);
            dr1 = @(c1, r1) zeros(1, D);
            dp = @(c1, r1) zeros(D, D);
        case 'r1'
            dc1 = @(c1, r1) zeros(D, 1);
            dr1 = @(c1, r1) 1;
            dp = @(c1, r1) zeros(D, 1);
    end
    
    [m, dm] = difference_handle(p_, dp, c1_, dc1, arguments);
    [n, dn] = normalize_handle(m, dm, arguments);
    [l, dl] = product_handle(r1_, dr1, n, dn, arguments);
    [q, dq] = sum_handle(c1_, dc1, l, dl, arguments);
    
    %% Display result
    switch variable
        case 'c1'
            dq_dc1 = dq;
        case 'r1'
            dq_dr1 = dq;
    end
end


