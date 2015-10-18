function [f, df] = jacobian_arap_point(p, c1)

D = length(p);
f = c1;
df.dc1 = eye(D, D);

