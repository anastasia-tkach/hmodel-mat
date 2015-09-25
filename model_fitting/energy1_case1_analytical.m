%function [] = energy1_case1_analytical(p, c, r)

D = 3;
% c = rand(D, 1);
% p = rand(D, 1);
% r = rand(1, 1);

arguments = 'c, r';
variables = {'c', 'r'};
Jnumerical = [];
Janalytical = [];
p_ = @(c, r) p;
c_ = @(c, r) c;
r_ = @(c, r) r;

for v = 1:length(variables)
    variable = variables{v};
    switch variable
        case 'c'
            dc = @(c, r) eye(D, D);
            dr = @(c, r) zeros(1, D);
            dp = @(c, r) zeros(D, D);
        case 'r'
            dc = @(c, r) zeros(D, 1);
            dr = @(c, r) 1;
            dp = @(c, r) zeros(D, 1);
    end
    
    [m, dm] = difference_handle(p_, dp, c_, dc, arguments);
    [n, dn] = normalize_handle(m, dm, arguments);
    [l, dl] = product_handle(r_, dr, n, dn, arguments);
    [q, dq] = sum_handle(c_, dc, l, dl, arguments);
    
    %% Display result
    switch variable
        case 'c'
            q = @(c) q(c, r);
            Jnumerical = [Jnumerical, my_gradient(q, c)];
            Janalytical = [Janalytical, dq(c, r)];        
        case 'r'
            q = @(r) q(c, r);
            Jnumerical = [Jnumerical, my_gradient(q, r)];
            Janalytical = [Janalytical, dq(c, r)];        
    end
end
disp(Jnumerical)
disp(Janalytical)

