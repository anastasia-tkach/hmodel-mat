function [f, df] = jacobian_tangent_cone_existence_analytical(c1, c2, r1, r2, factor, variables, arguments)

D = length(c1);

c1_ = @(c1, c2, r1, r2) c1;
c2_ = @(c1, c2, r1, r2) c2;
r1_ = @(c1, c2, r1, r2) r1;
r2_ = @(c1, c2, r1, r2) r2;
factor = @(c1, c2, r1, r2) factor;
dfactor = @(c1, c2, r1, r2) 0;

Jnumerical = [];
Janalytical = [];

for var = 1:length(variables)
    variable = variables{var};
    switch variable
        case 'c1', dc1= @(c1, c2, r1, r2) eye(D, D); dc2 = @(c1, c2, r1, r2) zeros(D, D);
            dr1 = @(c1, c2, r1, r2) zeros(1, D); dr2 = @(c1, c2, r1, r2) zeros(1, D);
        case 'c2',  dc1= @(c1, c2, r1, r2) zeros(D, D); dc2 = @(c1, c2, r1, r2) eye(D, D);
            dr1 = @(c1, c2, r1, r2) zeros(1, D); dr2 = @(c1, c2, r1, r2) zeros(1, D);
        case 'r1', dc1= @(c1, c2, r1, r2) zeros(D, 1); dc2 = @(c1, c2, r1, r2) zeros(D, 1);
            dr1 = @(c1, c2, r1, r2) 1; dr2 = @(c1, c2, r1, r2) 0;
        case 'r2', dc1= @(c1, c2, r1, r2) zeros(D, 1); dc2 = @(c1, c2, r1, r2) zeros(D, 1);
            dr1 = @(c1, c2, r1, r2) 0; dr2 = @(c1, c2, r1, r2) 1;
    end
    
    %% norm(c1 - c2) - factor * (r1 - r2) = 0;
    [a, da] = difference_handle(c1_, dc1, c2_, dc2, arguments);
    [b, db] = norm_handle(a, da, arguments);
    [c, dc] = difference_handle(r1_, dr1, r2_, dr2, arguments);
    [d, dd] = product_handle(factor, dfactor, c, dc, arguments);
    [r, dr] = difference_handle(b, db, d, dd, arguments);
    
    O = r;
    dO = dr;
    
    %% Display result
    switch variable
        case 'c1'
            O = @(c1) O(c1, c2, r1, r2);
            Jnumerical = [Jnumerical, my_gradient(O, c1)];
            Janalytical = [Janalytical, dO(c1, c2, r1, r2)];
        case 'c2'
            O = @(c2) O(c1, c2, r1, r2);
            Jnumerical = [Jnumerical, my_gradient(O, c2)];
            Janalytical = [Janalytical, dO(c1, c2, r1, r2)];
        case 'r1'
            O = @(r1) O(c1, c2, r1, r2);
            Jnumerical = [Jnumerical, my_gradient(O, r1)];
            Janalytical = [Janalytical, dO(c1, c2, r1, r2)];
        case 'r2'
            O = @(r2) O(c1, c2, r1, r2);
            Jnumerical = [Jnumerical, my_gradient(O, r2)];
            Janalytical = [Janalytical, dO(c1, c2, r1, r2)];
    end
    
    r = r(c1, c2, r1, r2);
    dr = dr(c1, c2, r1, r2);
    f = r;
    switch variable
        case 'c1', df.dc1 = dr;
        case 'c2', df.dc2 = dr;
        case 'r1', df.dr1 = dr;
        case 'r2', df.dr2 = dr;
    end
end
%O(r2)
%Jnumerical
%Janalytical
