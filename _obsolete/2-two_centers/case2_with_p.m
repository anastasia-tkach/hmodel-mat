%function [] = case2(p, R, C)

load R;
load P;
load C;
p = P(1, :)';
r1 = R(1, :)';
r2 = R(2, :)';
c1 = C(1, :)';
c2 = C(2, :)';
n = 2;
p = rand(2, 1);
c1 = rand(2, 1);
c2 = rand(2, 1);
r1 = rand(1);
r2 = rand(1);

u = @(c1, c2) c2 - c1;
v = @(c1, p) p - c1;
du_dc1 = -eye(n, n);
du_dc2 = eye(n, n);
du_dp = zeros(n, n);
dv_dc1 = -eye(n, n);
dv_dc2 = zeros(n, n);
dv_dp = eye(n, n);

%% t - closest point on the axis

tn = @(c1, c2, p) u(c1, c2)' * v(c1, p) * u(c1, c2);
dtn_dc1 = @(c1, c2, p) u(c1, c2) * u(c1, c2)' * dv_dc1 + u(c1, c2) * v(c1, p)' * du_dc1 + v(c1, p)' * u(c1, c2) * du_dc1; 
dtn_dc2 = @(c1, c2, p) u(c1, c2) * u(c1, c2)' * dv_dc2 + u(c1, c2) * v(c1, p)' * du_dc2 + v(c1, p)' * u(c1, c2) * du_dc2; 
dtn_dp = @(c1, c2, p) u(c1, c2) * u(c1, c2)' * dv_dp + u(c1, c2) * v(c1, p)' * du_dp + v(c1, p)' * u(c1, c2) * du_dp; 

td = @(c1, c2, p) u(c1, c2)' * u(c1, c2);
dtd_dc1 = @(c1, c2, p) 2 * u(c1, c2)' * du_dc1;
dtd_dc2 = @(c1, c2, p) 2 * u(c1, c2)' * du_dc2;
dtd_dp = @(c1, c2, p) 2 * u(c1, c2)' * du_dp;

t = @(c1, c2, p) c1 + tn(c1, c2, p) / td(c1, c2, p);
dt_dc1 = @(c1, c2, p) eye(n, n) + (dtn_dc1(c1, c2, p) * td(c1, c2, p) - tn(c1, c2, p) * dtd_dc1(c1, c2, p)) / td(c1, c2, p) / td(c1, c2, p);
dt_dc2 = @(c1, c2, p) (dtn_dc2(c1, c2, p) * td(c1, c2, p) - tn(c1, c2, p) * dtd_dc2(c1, c2, p)) / td(c1, c2, p) / td(c1, c2, p);
dt_dp = @(c1, c2, p) (dtn_dp(c1, c2, p) * td(c1, c2, p) - tn(c1, c2, p) * dtd_dp(c1, c2, p)) / td(c1, c2, p) / td(c1, c2, p);

%% r - the radius of the surface at t

rn1 = @(c1, c2, r1, r2, p) r2 * sqrt((t(c1, c2, p) - c1)' * (t(c1, c2, p) - c1));
rn2 = @(c1, c2, r1, r2, p) r1 * sqrt((c2 - t(c1, c2, p))' * (c2 - t(c1, c2, p)));
rn = @(c1, c2, r1, r2, p) rn1(c1, c2, r1, r2, p) + rn2(c1, c2, r1, r2, p);

drn1_dc1 = @(c1, c2, r1, r2, p)   r2 * (t(c1, c2, p) - c1)' * (dt_dc1(c1, c2, p) - eye(n, n)) / sqrt((t(c1, c2, p) - c1)' * (t(c1, c2, p) - c1));
drn2_dc1 = @(c1, c2, r1, r2, p)   r1 * (c2 - t(c1, c2, p))' * (- dt_dc1(c1, c2, p)) / sqrt((c2 - t(c1, c2, p))' * (c2 - t(c1, c2, p)));
drn_dc1 = @(c1, c2, r1, r2, p)  drn1_dc1(c1, c2, r1, r2, p) + drn2_dc1(c1, c2, r1, r2, p);

drn1_dc2 = @(c1, c2, r1, r2, p)   r2 * (t(c1, c2, p) - c1)' * (dt_dc2(c1, c2, p)) / sqrt((t(c1, c2, p) - c1)' * (t(c1, c2, p) - c1));
drn2_dc2 = @(c1, c2, r1, r2, p)   r1 * (c2 - t(c1, c2, p))' * (eye(n, n) - dt_dc2(c1, c2, p)) / sqrt((c2 - t(c1, c2, p))' * (c2 - t(c1, c2, p)));
drn_dc2 = @(c1, c2, r1, r2, p)  drn1_dc2(c1, c2, r1, r2, p) + drn2_dc2(c1, c2, r1, r2, p);

drn1_dp = @(c1, c2, r1, r2, p)   r2 * (t(c1, c2, p) - c1)' * dt_dp(c1, c2, p) / sqrt((t(c1, c2, p) - c1)' * (t(c1, c2, p) - c1));
drn2_dp = @(c1, c2, r1, r2, p)   - r1 * (c2 - t(c1, c2, p))' * dt_dp(c1, c2, p) / sqrt((c2 - t(c1, c2, p))' * (c2 - t(c1, c2, p)));
drn_dp = @(c1, c2, r1, r2, p)  drn1_dp(c1, c2, r1, r2, p) + drn2_dp(c1, c2, r1, r2, p);

drn_dr1 = @(c1, c2, r1, r2, p) sqrt((c2 - t(c1, c2, p))' * (c2 - t(c1, c2, p)));
drn_dr2 = @(c1, c2, r1, r2, p) sqrt((t(c1, c2, p) - c1)' * (t(c1, c2, p) - c1));


rd = @(c1, c2, r1, r2, p) sqrt((c2 - c1)' * (c2 - c1));
drd_dc1 = @(c1, c2, r1, r2, p) ... 

rn = @(r2) rn(c1, c2, r1, r2, p);
d_num = gradient(rn, r2)
drn_dr2(c1, c2, r1, r2, p)

%% 

% f = @(x) sqrt(x' * x); 
% df = @(x)  x' * dx / sqrt(x' * x); 
% df_num = gradient(f, x)
% df(x)


