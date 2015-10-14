clear; clc;
D = 2;
ci = rand(D, 1);
cj = rand(D, 1);
ai = randn(1, 1)/pi;
aj = randn(1, 1)/pi;
di = rand;
dj = rand;
%function [f, df] = jacobian_ik_shape_analytical(ci, cj, ai, aj, di, dj)

arguments = 'ci, cj, ai, aj';
variables = {'ci', 'cj', 'ai', 'aj'};

ci_ = @(ci, cj, ai, aj) ci;
cj_ = @(ci, cj, ai, aj) cj;
di_ = @(ci, cj, ai, aj) di;
dj_ = @(ci, cj, ai, aj) dj;
wi = @(ci, cj, ai, aj) [cos(ai); sin(ai)];
wj = @(ci, cj, ai, aj) [cos(aj); sin(aj)];

%% Compute function
Ri = [cos(ai), -sin(ai); sin(ai), cos(ai)];
Rj = [cos(aj), -sin(aj); sin(aj), cos(aj)];
bi = di * Ri * [1; 0];
bj = dj * Rj * [1; 0];
ei =  ci + bi;
ej =  cj + bj;
f = (ei - ej)' * (ei - ej);
disp(f);

Jnumerical = [];
Janalytical = [];
for v = 1:length(variables)
    variable = variables{v};
    switch variable
        case 'ci'
            dci = @(ci, cj, ai, aj) eye(D, D);
            dcj = @(ci, cj, ai, aj) zeros(D, D);
            dwi = @(ci, cj, ai, aj) zeros(D, D);
            dwj = @(ci, cj, ai, aj) zeros(D, D);
            ddi = @(ci, cj, ai, aj) zeros(1, D);
            ddj = @(ci, cj, ai, aj) zeros(1, D);
        case 'cj'
            dci = @(ci, cj, ai, aj) zeros(D, D);
            dcj = @(ci, cj, ai, aj) eye(D, D);
            dwi = @(ci, cj, ai, aj) zeros(D, D);
            dwj = @(ci, cj, ai, aj) zeros(D, D);
            ddi = @(ci, cj, ai, aj) zeros(1, D);
            ddj = @(ci, cj, ai, aj) zeros(1, D);
        case 'ai'
            dci = @(ci, cj, ai, aj) zeros(D, 1);
            dcj = @(ci, cj, ai, aj) zeros(D, 1);
            dwi = @(ci, cj, ai, aj) [-sin(ai); cos(ai)];
            dwj = @(ci, cj, ai, aj) zeros(D, 1);
            ddi = @(ci, cj, ai, aj) zeros(1, 1);
            ddj = @(ci, cj, ai, aj) zeros(1, 1);
        case 'aj'
            dci = @(ci, cj, ai, aj) zeros(D, 1);
            dcj = @(ci, cj, ai, aj) zeros(D, 1);
            dwi = @(ci, cj, ai, aj) zeros(D, 1);
            dwj = @(ci, cj, ai, aj) [-sin(aj); cos(aj)];
            ddi = @(ci, cj, ai, aj) zeros(1, 1);
            ddj = @(ci, cj, ai, aj) zeros(1, 1);
    end
    
    %% c2 =  c + d * w;
    
    [bi, dbi] = product_handle(di_, ddi, wi, dwi, arguments);
    [bj, dbj] = product_handle(dj_, ddj, wj, dwj, arguments);
    [ei, dei] = sum_handle(ci_, dci, bi, dbi, arguments);
    [ej, dej] = sum_handle(cj_, dcj, bj, dbj, arguments);
    
    %% f = (ei - ej) ' * (ei - ej)  
    [g, dg] = difference_handle(ei, dei, ej, dej, arguments);
    [q, dq] = dot_handle(g, dg, g, dg, arguments);
    
    O = q;
    dO = dq;
    
    %% Display result
    switch variable
        case 'ci'
            O = @(ci) O(ci, cj, ai, aj);
            Jnumerical = [Jnumerical, my_gradient(O, ci)];
            Janalytical = [Janalytical, dO(ci, cj, ai, aj)];
        case 'cj'
            O = @(cj) O(ci, cj, ai, aj);
            Jnumerical = [Jnumerical, my_gradient(O, cj)];
            Janalytical = [Janalytical, dO(ci, cj, ai, aj)];
        case 'ai'
            O = @(ai) O(ci, cj, ai, aj);
            Jnumerical = [Jnumerical, my_gradient(O, ai)];
            Janalytical = [Janalytical, dO(ci, cj, ai, aj)];
        case 'aj'
            O = @(aj) O(ci, cj, ai, aj);
            Jnumerical = [Jnumerical, my_gradient(O, aj)];
            Janalytical = [Janalytical, dO(ci, cj, ai, aj)];
    end
end
O(aj)
Jnumerical
Janalytical

