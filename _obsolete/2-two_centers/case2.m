% n = 2;
% p = rand(2, 1);
% c1 = rand(2, 1);
% c2 = rand(2, 1);
% r1 = rand(1);
% r2 = rand(1);

function [f, J, t, r] = case2(p, C, R)

r1 = R(1, :)';
r2 = R(2, :)';
c1 = C(1, :)';
c2 = C(2, :)';

n = length(c1);

u = @(c1, c2) c2 - c1;
v = @(c1) p - c1;
du_dc1 = -eye(n, n);
du_dc2 = eye(n, n);
dv_dc1 = -eye(n, n);
dv_dc2 = zeros(n, n);

%% t - closest point on the axis

tn = @(c1, c2) u(c1, c2)' * v(c1) * u(c1, c2);
dtn_dc1 = @(c1, c2) u(c1, c2) * u(c1, c2)' * dv_dc1 + u(c1, c2) * v(c1)' * du_dc1 + v(c1)' * u(c1, c2) * du_dc1; 
dtn_dc2 = @(c1, c2) u(c1, c2) * u(c1, c2)' * dv_dc2 + u(c1, c2) * v(c1)' * du_dc2 + v(c1)' * u(c1, c2) * du_dc2; 

td = @(c1, c2) u(c1, c2)' * u(c1, c2);
dtd_dc1 = @(c1, c2) 2 * u(c1, c2)' * du_dc1;
dtd_dc2 = @(c1, c2) 2 * u(c1, c2)' * du_dc2;

t = @(c1, c2) c1 + tn(c1, c2) / td(c1, c2);
dt_dc1 = @(c1, c2) eye(n, n) + (dtn_dc1(c1, c2) * td(c1, c2) - tn(c1, c2) * dtd_dc1(c1, c2)) / td(c1, c2) / td(c1, c2);
dt_dc2 = @(c1, c2) (dtn_dc2(c1, c2) * td(c1, c2) - tn(c1, c2) * dtd_dc2(c1, c2)) / td(c1, c2) / td(c1, c2);

%% r - the radius of the surface at t

rn1 = @(c1, c2, r1, r2) r2 * sqrt((t(c1, c2) - c1)' * (t(c1, c2) - c1));
rn2 = @(c1, c2, r1, r2) r1 * sqrt((c2 - t(c1, c2))' * (c2 - t(c1, c2)));
rn = @(c1, c2, r1, r2) rn1(c1, c2, r1, r2) + rn2(c1, c2, r1, r2);

drn1_dc1 = @(c1, c2, r1, r2)   r2 * (t(c1, c2) - c1)' * (dt_dc1(c1, c2) - eye(n, n)) / sqrt((t(c1, c2) - c1)' * (t(c1, c2) - c1));
drn2_dc1 = @(c1, c2, r1, r2)   r1 * (c2 - t(c1, c2))' * (- dt_dc1(c1, c2)) / sqrt((c2 - t(c1, c2))' * (c2 - t(c1, c2)));
drn_dc1 = @(c1, c2, r1, r2)  drn1_dc1(c1, c2, r1, r2) + drn2_dc1(c1, c2, r1, r2);

drn1_dc2 = @(c1, c2, r1, r2)   r2 * (t(c1, c2) - c1)' * (dt_dc2(c1, c2)) / sqrt((t(c1, c2) - c1)' * (t(c1, c2) - c1));
drn2_dc2 = @(c1, c2, r1, r2)   r1 * (c2 - t(c1, c2))' * (eye(n, n) - dt_dc2(c1, c2)) / sqrt((c2 - t(c1, c2))' * (c2 - t(c1, c2)));
drn_dc2 = @(c1, c2, r1, r2)  drn1_dc2(c1, c2, r1, r2) + drn2_dc2(c1, c2, r1, r2);
drn_dr1 = @(c1, c2, r1, r2) sqrt((c2 - t(c1, c2))' * (c2 - t(c1, c2)));
drn_dr2 = @(c1, c2, r1, r2) sqrt((t(c1, c2) - c1)' * (t(c1, c2) - c1));

rd = @(c1, c2) sqrt((c2 - c1)' * (c2 - c1));
drd_dc1 = @(c1, c2) - (c2 - c1)' /sqrt((c2 - c1)' * (c2 - c1));
drd_dc2 = @(c1, c2)  (c2 - c1)' /sqrt((c2 - c1)' * (c2 - c1));
drd_dr1 = @(c1, c2) 0;
drd_dr2 = @(c1, c2) 0;

r = @(c1, c2, r1, r2) rn(c1, c2, r1, r2) / rd(c1, c2);
dr_dc1 =  @(c1, c2, r1, r2) (drn_dc1(c1, c2, r1, r2) * rd(c1, c2) - rn(c1, c2, r1, r2) * drd_dc1(c1, c2)) / rd(c1, c2)^2;
dr_dc2 =  @(c1, c2, r1, r2) (drn_dc2(c1, c2, r1, r2) * rd(c1, c2) - rn(c1, c2, r1, r2) * drd_dc2(c1, c2)) / rd(c1, c2)^2;
dr_dr1 =  @(c1, c2, r1, r2) (drn_dr1(c1, c2, r1, r2) * rd(c1, c2) - rn(c1, c2, r1, r2) * drd_dr1(c1, c2)) / rd(c1, c2)^2;
dr_dr2 =  @(c1, c2, r1, r2) (drn_dr2(c1, c2, r1, r2) * rd(c1, c2) - rn(c1, c2, r1, r2) * drd_dr2(c1, c2)) / rd(c1, c2)^2;


%% The objective function
% (p - t)' * (p - t) - r * r

f = @(c1, c2, r1, r2)  p' * p - 2 * p' * t(c1, c2) + t(c1, c2)' * t(c1, c2) - r(c1, c2, r1, r2) * r(c1, c2, r1, r2);

df_dc1 = @(c1, c2, r1, r2) - 2 * p' * dt_dc1(c1, c2) + 2 * t(c1, c2)' * dt_dc1(c1, c2) - 2 * r(c1, c2, r1, r2) * dr_dc1(c1, c2, r1, r2);
df_dc2 = @(c1, c2, r1, r2) - 2 * p' * dt_dc2(c1, c2) + 2 * t(c1, c2)' * dt_dc2(c1, c2) - 2 * r(c1, c2, r1, r2) * dr_dc2(c1, c2, r1, r2);
df_dr1 = @(c1, c2, r1, r2) - 2 * r(c1, c2, r1, r2) * dr_dr1(c1, c2, r1, r2);
df_dr2 = @(c1, c2, r1, r2) - 2 * r(c1, c2, r1, r2) * dr_dr2(c1, c2, r1, r2);


J =  @(c1, c2, r1, r2) [df_dc1(c1, c2, r1, r2), df_dc2(c1, c2, r1, r2), df_dr1(c1, c2, r1, r2), df_dr2(c1, c2, r1, r2)];

% f_c1 = @(c1) f(c1, c2, r1, r2);
% f_c2 = @(c2) f(c1, c2, r1, r2);
% f_r1 = @(r1) f(c1, c2, r1, r2);
% f_r2 = @(r2) f(c1, c2, r1, r2);
% disp([gradient(f_c1, c1), gradient(f_c2, c2), gradient(f_r1, r1), gradient(f_r2, r2)]);
% disp(J(c1, c2, r1, r2));

f = f(c1, c2, r1, r2);
J = J(c1, c2, r1, r2);

t = t(c1, c2);
r = r(c1, c2, r1, r2);























