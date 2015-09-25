function [f, Jc, Jr] = energy1_case1(p, c, r)

% f  = @(c, r) p' * p - 2 * p' * c + c' * c - r * r;

% df_dc = @(c, r) -2 * p' + 2 * c';
% df_dr = @(c, r) - 2 * r;

% f = f(c, r);
% Jc = df_dc(c, r);
% Jr = df_dr(c, r);

[q, dq_dc, dq_dr] = jacobian_sphere(p, c, r);

f =  sqrt((p - q)' * (p - q));
df_dc =  - (p - q)' * dq_dc / sqrt((p - q)' * (p - q));
df_dr =  - (p - q)' * dq_dr / sqrt((p - q)' * (p - q));

Jc =  df_dc;
Jr = df_dr;



