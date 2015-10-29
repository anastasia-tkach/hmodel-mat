clc;
D = 3;

c2 = 0.5 * rand(D ,1);
p = rand(D, 1);
alpha = rand;
beta = 1 - alpha;
c1a = 0.5 * rand(D ,1);
c1b = 0.5 * rand(D, 1);

%function [f, df] = jacobian_arap_segment_attachment_analytical(p, c1, c2)
c1 = alpha * c1a + beta * c1b;
D = length(p);
u = c2 - c1;
v = p - c1;
delta = u' * v / (u' * u);
q = c1 + delta * u;
disp(q);

arguments = 'c1a, c1b, c2';
variables = {'c1a', 'c1b', 'c2'};

p_ = eval(['@(', arguments, ') p']);
c1a_ = eval(['@(', arguments, ') c1a']);
c1b_ = eval(['@(', arguments, ') c1b']);
c2_ = eval(['@(', arguments, ') c2']);

alpha_ = eval(['@(', arguments, ') alpha']);
dalpha = eval(['@(', arguments, ')  zeros(1, D)']);
beta_ = eval(['@(', arguments, ') beta']);
dbeta = eval(['@(', arguments, ')  zeros(1, D)']);
dp = eval(['@(', arguments, ')  zeros(D, D)']);

Jnumerical = [];
Janalytical = [];

for var = 1:length(variables)
    variable = variables{var};
    switch variable
        case 'c1a'
            dc1a = eval(['@(', arguments, ')  eye(D, D)']);
            dc1b = eval(['@(', arguments, ')  zeros(D, D)']);
            dc2 = eval(['@(', arguments, ')  zeros(D, D)']);
        case 'c1b'
            dc1a = eval(['@(', arguments, ')  zeros(D, D)']);
            dc1b = eval(['@(', arguments, ')  eye(D, D)']);
            dc2 = eval(['@(', arguments, ')  zeros(D, D)']);
        case 'c2'
            dc1a = eval(['@(', arguments, ')  zeros(D, D)']);
            dc1b = eval(['@(', arguments, ')  zeros(D, D)']);
            dc2 = eval(['@(', arguments, ')  eye(D, D)']);
    end
    
    [a, da] = product_handle(alpha_, dalpha, c1a_, dc1a, arguments);
    [b, db] = product_handle(beta_, dbeta, c1b_, dc1b, arguments);
    [c1_, dc1] = sum_handle(a, da, b, db, arguments);
    
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
        case 'c1a'
            O = eval(['@(c1a) O(', arguments, ')']);
            Jnumerical = [Jnumerical, my_gradient(O, c1a)];
            Janalytical = [Janalytical, eval(['dO(', arguments, ')'])];
        case 'c1b'
            O = eval(['@(c1b) O(', arguments, ')']);
            Jnumerical = [Jnumerical, my_gradient(O, c1b)];
            Janalytical = [Janalytical, eval(['dO(', arguments, ')'])];
        case 'c2'
            O = eval(['@(c2) O(', arguments, ')']);
            Jnumerical = [Jnumerical, my_gradient(O, c2)];
            Janalytical = [Janalytical, eval(['dO(', arguments, ')'])];
    end
end
disp(O(c2));

centers{1} = c1; centers{2} = c2;
centers{3} = c1a; centers{4} = c1b;
gradients = cell(0, 1);
index = [1, 2];
attachments = cell(length(centers), 1);
attachments{1}.indices = [3, 4];
attachments{1}.weights = [alpha, beta];
% c1
attachment = attachments{index(1)};
if isempty(attachment)
    gradient.dc1 = eye(D, D); gradient.dc2 = zeros(D, D);
    gradient.index = index(1);
    gradients{end + 1} = gradient;
    c1 = centers{index(1)};
else
    c1 = zeros(D, 1);
    for l = 1:length(attachment.indices)
        gradient.dc1 = attachment.weights(l) * eye(D, D);
        gradient.dc2 = zeros(D, D);
        gradient.index = attachment.indices(l);
        gradients{end + 1} = gradient;
        c1 = c1 + attachment.weights(l) * centers{attachment.indices(l)};
    end
end
%c2
attachment = attachments{index(2)};
if isempty(attachment)
    gradient.dc1 = zeros(D, D); gradient.dc2 = eye(D, D);
    gradient.index = index(2);
    gradients{end + 1} = gradient;
    c2 = centers{index(2)};
else
    c1 = zeros(D, 1);
    for l = 1:length(attachment.indices)
        gradient.dc1 = zeros(D, D);
        gradient.dc2 = attachment.weights(l) * eye(D, D);
        gradient.index = attachment.indices(l);
        gradients{end + 1} = gradient;
        c2 = c2 + attachment.weights(l) * centers{attachment.indices(l)};
    end
end
[f, gradients] = jacobian_arap_segment_attachment(p, c1, c2, variables, gradients);


disp(f);

disp(Jnumerical);
disp(Janalytical);
J = [];
for i = 1:length(gradients)
    J = [J, gradients{i}.df];
end
disp(J);













