function [f, Jc1, Jr1, Jc2, Jr2] = energy1_case2_numerical(p, c1, c2, r1, r2)

[q, dq_dc1, dq_dc2, dq_dr1, dq_dr2] = jacobian_convsegment(p, c1, c2, r1, r2);

%% Final result
% f = sqrt((p - q)' * (p - q))
f =  sqrt((p - q)' * (p - q));
df_dc1 =  - (p - q)' * dq_dc1 / sqrt((p - q)' * (p - q));
df_dc2 =  - (p - q)' * dq_dc2 / sqrt((p - q)' * (p - q));
df_dr1 =  - (p - q)' * dq_dr1 / sqrt((p - q)' * (p - q));
df_dr2 =  - (p - q)' * dq_dr2 / sqrt((p - q)' * (p - q));

Jc1 =  df_dc1;
Jr1 = df_dr1;
Jc2 = df_dc2;
Jr2 = df_dr2;

%[f, Jc1, Jr1, Jc2, Jr2] = energy1_case2_analytical(p, c1, c2, r1, r2);





