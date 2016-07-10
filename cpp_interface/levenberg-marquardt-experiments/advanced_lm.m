
opts = optimoptions(@lsqnonlin,'Jacobian', 'on',  'Algorithm', 'levenberg-marquardt', 'InitDamping', 1);

x0 = [1; 1];
[x,resnorm,res,eflag,output2] = lsqnonlin(@myfun,x0,[],[],opts);

%% my LM

version = 1;
disp('my implementation')
x = x0;
delta = [1; 1];
iter = 1;
nu = 2;

[F, J] = myfun(x);

if version == 1
    tau = 1e-3;
    lambda = tau * max(diag(J' * J));
else
    lambda = 1;
end


while norm(delta) > 1e-4  
    if version == 1
        LHS = J' * J + lambda * eye(size(J' * J));
        rhs = J' * F;
        delta =  - LHS \ rhs;
        x_new = x + delta;
        
        [F_new, J_new] = myfun(x_new);
        denom = -delta' * J' * F - 1/2 * delta' * J' * J * delta;
        rho = (F' * F - F_new' * F_new) / denom;
        if rho > 0
            x = x_new;
            J = J_new;
            F = F_new;
            nu = 2;
            lambda = lambda * max([1/3, 1 - (2 * rho - 1)^3]);
            disp(x');
        else
            disp(['update rejected  ', num2str(x_new')]);
            nu = nu * 2;
            lambda = lambda * nu;
        end
    else
        [F, J] = myfun(x);
        LHS = J' * J + lambda * diag(diag(J' * J));       
        rhs = J' * F;
        delta =  - LHS \ rhs;
        x = x + delta;
        disp(x');
    end
    
    iter = iter + 1;
end

disp(['num iters = ', num2str(iter)]);