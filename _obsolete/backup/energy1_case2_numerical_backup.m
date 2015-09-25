% clc;
% n = 3;
% while(true)
%     c1 = 0.5 * rand(n ,1);
%     c2 = 0.5 * rand(n ,1);
%     x1 = rand(1 ,1);
%     x2 = rand(1 ,1);
%     r1 = max(x1, x2);
%     r2 = min(x1, x2);
%     p = rand(n, 1);
%     if norm(c1 - c2) > r1
%         break;
%     end
% end

function [f, Jc1, Jr1, Jc2, Jr2] = energy1_case2_numerical_backup(p, c1, c2, r1, r2)
% u = c2 - c1;
% v = p - c1;
% alpha = u' * v / (u' * u);
% t = c1 + alpha * u;
% omega = sqrt(u' * u - (r1 - r2)^2);
% delta =  norm(p - t) * (r1 - r2) / omega;
% w = u * delta/ norm(u);
% s = t - w;
% gamma = (r1 - r2) * norm(c2 - t + w)/ norm(u);
% q = s + (p - s) / norm(p - s) * (gamma + r2);
% disp(q);

%% Derivation

n = length(c1);

u =  c2 - c1;
v =  p - c1;
du_dc1 = -eye(n, n);
du_dc2 = eye(n, n);
dv_dc1 = -eye(n, n);
dv_dc2 = zeros(n, n);

%% t - closest point on the axis
% t = c1 + alpha * u;

tn =  u' * v * u;
dtn_dc1 =  u * u' * dv_dc1 + u * v' * du_dc1 + v' * u * du_dc1;
dtn_dc2 =  u * u' * dv_dc2 + u * v' * du_dc2 + v' * u * du_dc2;

td =  u' * u;
dtd_dc1 =  2 * u' * du_dc1;
dtd_dc2 =  2 * u' * du_dc2;

t =  c1 + tn / td;
dt_dc1 =  eye(n, n) + (dtn_dc1 * td - tn * dtd_dc1) / td / td;
dt_dc2 =  (dtn_dc2 * td - tn * dtd_dc2) / td / td;

%% omega - lenght of the tangent
% omega = sqrt(u' * u - (r1 - r2)^2);

omega2 =  u' * u - (r1 - r2)^2;
domega2_dc1 =   2 * u' * du_dc1;
domega2_dc2 =   2 * u' * du_dc2;
domega2_dr1 =   -2 * (r1- r2);
domega2_dr2 =   2 * (r1- r2);

omega =  sqrt(omega2);
domega_dc1 =   domega2_dc1 / 2 / sqrt(omega2);
domega_dc2 =   domega2_dc2 / 2 / sqrt(omega2);
domega_dr1 =   domega2_dr1 / 2 / sqrt(omega2);
domega_dr2 =   domega2_dr2 / 2 / sqrt(omega2);

%% delta - size of the correction
% delta =  norm(p - t) * (r1 - r2) / omega;

deltanum =   sqrt((p - t)' * (p - t)) * (r1 - r2);
ddeltanum_dc1 =   - (p - t)' * dt_dc1 /sqrt((p - t)' * (p - t)) * (r1 - r2);
ddeltanum_dc2 =   - (p - t)' * dt_dc2 /sqrt((p - t)' * (p - t)) * (r1 - r2);
ddeltanum_dr1 =   sqrt((p - t)' * (p - t));
ddeltanum_dr2 =   -sqrt((p - t)' * (p - t));

delta =  deltanum / omega;
ddelta_dc1 =   (ddeltanum_dc1 * omega - ...
    deltanum * domega_dc1) / omega^2;
ddelta_dc2 =   (ddeltanum_dc2 * omega - ...
    deltanum * domega_dc2) / omega^2;
ddelta_dr1 =   (ddeltanum_dr1 * omega - ...
    deltanum * domega_dr1) / omega^2;
ddelta_dr2 =   (ddeltanum_dr2 * omega - ...
    deltanum * domega_dr2) / omega^2;

%% w - correction vector
%w = delta * u / norm(u);
wnum =  u * delta; 
dwnum_dc1 =  u * ddelta_dc1 + du_dc1 * delta;
dwnum_dc2 =  u * ddelta_dc2 + du_dc2 * delta;
dwnum_dr1 =  u * ddelta_dr1;
dwnum_dr2 =  u * ddelta_dr2;

wdenum =  sqrt(u' * u);
dwdenum_dc1 =  u' * du_dc1/ sqrt(u' * u);
dwdenum_dc2 =  u' * du_dc2/ sqrt(u' * u);

w =    wnum / wdenum;
dw_dc1 =    (dwnum_dc1 * wdenum - ...
    wnum * dwdenum_dc1) /  wdenum^2;
dw_dc2 =    (dwnum_dc2 * wdenum - ...
    wnum * dwdenum_dc2) /  wdenum^2;
dw_dr1 =    dwnum_dr1 / wdenum;
dw_dr2 =    dwnum_dr2 / wdenum;

%% s - corrected point on the axis
% s = t - w
s =  t - w;
ds_dc1 =  dt_dc1 - dw_dc1;
ds_dc2 =  dt_dc2 - dw_dc2;
ds_dr1 =  - dw_dr1;
ds_dr2 =  - dw_dr2;

%% gamma - correction in the direction orthogonal to cone surface
% gamma = (r1 - r2) * norm(c2 - t + w)/ norm(u);

gammafactor =  sqrt((c2 - t + w)' * (c2 - t + w));
dgammafactor_dc1 =   (c2 - t + w)' * (-dt_dc1 + dw_dc1) / ...
    sqrt((c2 - t + w)' * (c2 - t + w));
dgammafactor_dc2 =   (c2 - t + w)' * (eye(n, n) - dt_dc2 + dw_dc2) / ...
    sqrt((c2 - t + w)' * (c2 - t + w));
dgammafactor_dr1 =   (c2 - t + w)' * dw_dr1 / ...
    sqrt((c2 - t + w)' * (c2 - t + w));
dgammafactor_dr2 =   (c2 - t + w)' * dw_dr2 / ...
    sqrt((c2 - t + w)' * (c2 - t + w));

gammanum =  (r1 - r2) * gammafactor;
dgammanum_dc1 =  (r1 - r2) * dgammafactor_dc1;
dgammanum_dc2 =  (r1 - r2) * dgammafactor_dc2;
dgammanum_dr1 =  gammafactor + (r1 - r2) * dgammafactor_dr1;
dgammanum_dr2 =  - gammafactor + (r1 - r2) * dgammafactor_dr2;

gammadenum =  sqrt(u' * u);
dgammadenum_dc1 =  u' * du_dc1/ sqrt(u' * u);
dgammadenum_dc2 =  u' * du_dc2/ sqrt(u' * u);

gamma =  gammanum / gammadenum;
dgamma_dc1 =  (dgammanum_dc1 * gammadenum - ...
    gammanum * dgammadenum_dc1) / gammadenum^2;
dgamma_dc2 =  (dgammanum_dc2 * gammadenum - ...
    gammanum * dgammadenum_dc2) / gammadenum^2;
dgamma_dr1 =  dgammanum_dr1 / gammadenum;
dgamma_dr2 =  dgammanum_dr2 / gammadenum;

%% q - the point on the model surface
% q = s + (p - s) / norm(p - s) * (gamma + r2);

qdenum =  sqrt((p - s)' * (p - s));
dqdenum_dc1 =  - (p - s)'* ds_dc1 / sqrt((p - s)' * (p - s));
dqdenum_dc2 =  - (p - s)'* ds_dc2 / sqrt((p - s)' * (p - s));
dqdenum_dr1 =  - (p - s)'* ds_dr1 / sqrt((p - s)' * (p - s));
dqdenum_dr2 =  - (p - s)'* ds_dr2 / sqrt((p - s)' * (p - s));

qfactor =  (p - s) / qdenum;
dqfactor_dc1 =  (- ds_dc1 * qdenum -...
    (p - s) * dqdenum_dc1) / qdenum^2;
dqfactor_dc2 =  (- ds_dc2 * qdenum -...
    (p - s) * dqdenum_dc2) / qdenum^2;
dqfactor_dr1 =  (- ds_dr1 * qdenum -...
    (p - s) * dqdenum_dr1) / qdenum^2;
dqfactor_dr2 =  (- ds_dr2 * qdenum -...
    (p - s) * dqdenum_dr2) / qdenum^2;

q =  s + qfactor * (gamma + r2);
dq_dc1 =  ds_dc1 + dqfactor_dc1 * (gamma + r2) + ...
    qfactor * (dgamma_dc1);
dq_dc2 =  ds_dc2 + dqfactor_dc2 * (gamma + r2) + ...
    qfactor * (dgamma_dc2);
dq_dr1 =  ds_dr1 + dqfactor_dr1 * (gamma + r2) + ...
    qfactor * (dgamma_dr1);
dq_dr2 =  ds_dr2 + dqfactor_dr2 * (gamma + r2) + ...
    qfactor * (dgamma_dr2 + 1);


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





