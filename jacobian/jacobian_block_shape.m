function [f, df] = jacobian_ik_shape(ci, cj, ai, aj, di, dj)

D = length(ci);

variables = {'ci', 'cj', 'ai', 'aj'};

wi = [cos(ai); sin(ai)];
wj = [cos(aj); sin(aj)];

for v = 1:length(variables)
    variable = variables{v};
    
    switch variable
        case 'ci'
            dci = eye(D, D); dcj = zeros(D, D);
            dwi = zeros(D, D); dwj = zeros(D, D);
            ddi = zeros(1, D); ddj = zeros(1, D);
        case 'cj'
            dci = zeros(D, D); dcj = eye(D, D);
            dwi = zeros(D, D); dwj = zeros(D, D);
            ddi = zeros(1, D); ddj = zeros(1, D);
        case 'ai'
            dci = zeros(D, 1); dcj = zeros(D, 1);
            dwi = [-sin(ai); cos(ai)]; dwj = zeros(D, 1);
            ddi = zeros(1, 1); ddj = zeros(1, 1);
        case 'aj'
            dci = zeros(D, 1); dcj = zeros(D, 1);
            dwi = zeros(D, 1); dwj = [-sin(aj); cos(aj)];
            ddi = zeros(1, 1); ddj = zeros(1, 1);
    end
    
    %% e =  c + d * w;   
    [bi, dbi] = product_derivative(di, ddi, wi, dwi);
    [bj, dbj] = product_derivative(dj, ddj, wj, dwj);
    [ei, dei] = sum_derivative(ci, dci, bi, dbi);
    [ej, dej] = sum_derivative(cj, dcj, bj, dbj);
    
    %% f = (ei - ej) ' * (ei - ej)  
    [g, dg] = difference_derivative(ei, dei, ej, dej);
    [q, dq] = dot_derivative(g, dg, g, dg);
    
    f = q;    
    
    %% Store result
    switch variable
        case 'ci', df.dci = dq;
        case 'cj', df.dcj = dq;           
        case 'ai', df.dai = dq;
        case 'aj', df.daj = dq;
    end
end


