function [f, J] = case1(p, c, r)

f  = @(c, r) p' * p - 2 * p' * c + c' * c - r * r;

df_dc = @(c, r) -2 * p' + 2 * c';
df_dr = @(c, r) - 2 * r;

J  = @(c, r) [df_dc(c, r), df_dr(c, r)];

% f_c = @(c) f(c, r);
% f_r = @(r) f(c, r);
% disp([gradient(f_c, c), gradient(f_r, r)]);
% disp(J(c, r));

f = f(c, r);
J = J(c, r);

