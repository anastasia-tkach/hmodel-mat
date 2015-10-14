clc; clear;
D = 2;
c1 = rand(D, 1);
p = rand(D, 1);
r2 = rand(1, 1);
a1 = randn(1, 1) / pi;
d = rand(1, 1);

%function [f, df] = jacobian_ik_offset_sphere(p, b, r, d, a, variables)

arguments = 'c1, a1';
variables = {'c1', 'a1'};

p_ = @(c1, a1)  p;
c1_ = @(c1, a1)  c1;
r2_ = @(c1, a1)  r2;
a1_ = @(c1, a1)  a1;
d_ = @(c1, a1)  d;

R  = @(c1, a1)[cos(a1), -sin(a1); sin(a1), cos(a1)];
w = @(c1, a1) [cos(a1); sin(a1)];

%% Compute function

c2 =  c1 + d * R(c1, a1) * [1; 0];
m = p - c2;
n = m / norm(m);
l = r2 * n;
q = c2 + l;
disp(q)

Jnumerical = [];
Janalytical = [];
for v = 1:length(variables)
    variable = variables{v};
    switch variable
        case 'c1'
            dc1 = @(c1, a1) eye(D, D);
            da1 = @(c1, a1) zeros(1, D);
            dr2 = @(c1, a1) zeros(1, D);
            dp = @(c1, a1) zeros(D, D);
            dd = @(c1, a1) zeros(1, D);
            dw = @(c1, a1) zeros(D, D);
        case 'a1'
            dc1 = @(c1, a1) zeros(D, 1);
            da1 = @(c1, a1) 1;
            dr2 = @(c1, a1) zeros(1, 1);
            dp = @(c1, a1) zeros(D, 1);
            dd = @(c1, a1) 0;
            dw = @(c1, a1) [-sin(a1); cos(a1)];
    end
    
    %% c2 =  c1 + d * v;
    [b, db] = product_handle(d_, dd, w, dw, arguments);
    [c2, dc2] = sum_handle(c1_, dc1, b, db, arguments);
    [m, dm] = difference_handle(p_, dp, c2, dc2, arguments);
    [n, dn] = normalize_handle(m, dm, arguments);
    [l, dl] = product_handle(r2_, dr2, n, dn, arguments);
    [q, dq] = sum_handle(c2, dc2, l, dl, arguments);
    
    O = q;
    dO = dq;   
    
    %% Display result
    switch variable
        case 'c1'
            O = @(c1) O(c1, a1);
            Jnumerical = [Jnumerical, my_gradient(O, c1)];
            Janalytical = [Janalytical, dO(c1, a1)];
        case 'a1'
            O = @(a1) O(c1, a1);
            Jnumerical = [Jnumerical, my_gradient(O, a1)];
            Janalytical = [Janalytical, dO(c1, a1)];
    end
end
O(a1)
Jnumerical
Janalytical

%% Draw result
% close all;
% figure; axis equal; hold on; axis off;
% myline(c1, c2, 'g');
% myline(p, c2, 'm');
% mypoint(c1, 'r');
% mypoint(c2, 'b');
% draw_circle(c2, r, 'g');
% mypoint(p, 'k');
% mypoint(q, 'w');


