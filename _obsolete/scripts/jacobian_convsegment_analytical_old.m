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

function [q, dq_dc1, dq_dc2, dq_dr1, dq_dr2] = jacobian_convsegment_analytical(p, c1, c2, r1, r2)
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

u = @(c1, c2) c2 - c1;
v = @(c1) p - c1;
du_dc1 = -eye(n, n);
du_dc2 = eye(n, n);
dv_dc1 = -eye(n, n);
dv_dc2 = zeros(n, n);

%% t - closest point on the axis
% t = c1 + alpha * u;

tn = @(c1, c2) u(c1, c2)' * v(c1) * u(c1, c2);
dtn_dc1 = @(c1, c2) u(c1, c2) * u(c1, c2)' * dv_dc1 + u(c1, c2) * v(c1)' * du_dc1 + v(c1)' * u(c1, c2) * du_dc1;
dtn_dc2 = @(c1, c2) u(c1, c2) * u(c1, c2)' * dv_dc2 + u(c1, c2) * v(c1)' * du_dc2 + v(c1)' * u(c1, c2) * du_dc2;

td = @(c1, c2) u(c1, c2)' * u(c1, c2);
dtd_dc1 = @(c1, c2) 2 * u(c1, c2)' * du_dc1;
dtd_dc2 = @(c1, c2) 2 * u(c1, c2)' * du_dc2;

t = @(c1, c2) c1 + tn(c1, c2) / td(c1, c2);
dt_dc1 = @(c1, c2) eye(n, n) + (dtn_dc1(c1, c2) * td(c1, c2) - tn(c1, c2) * dtd_dc1(c1, c2)) / td(c1, c2) / td(c1, c2);
dt_dc2 = @(c1, c2) (dtn_dc2(c1, c2) * td(c1, c2) - tn(c1, c2) * dtd_dc2(c1, c2)) / td(c1, c2) / td(c1, c2);

%% omega - lenght of the tangent
% omega = sqrt(u' * u - (r1 - r2)^2);

omega2 = @(c1, c2, r1, r2) u(c1, c2)' * u(c1, c2) - (r1 - r2)^2;
domega2_dc1 =  @(c1, c2, r1, r2) 2 * u(c1, c2)' * du_dc1;
domega2_dc2 =  @(c1, c2, r1, r2) 2 * u(c1, c2)' * du_dc2;
domega2_dr1 =  @(c1, c2, r1, r2) -2 * (r1- r2);
domega2_dr2 =  @(c1, c2, r1, r2) 2 * (r1- r2);

omega = @(c1, c2, r1, r2) sqrt(omega2(c1, c2, r1, r2));
domega_dc1 =  @(c1, c2, r1, r2) domega2_dc1(c1, c2, r1, r2) / 2 / sqrt(omega2(c1, c2, r1, r2));
domega_dc2 =  @(c1, c2, r1, r2) domega2_dc2(c1, c2, r1, r2) / 2 / sqrt(omega2(c1, c2, r1, r2));
domega_dr1 =  @(c1, c2, r1, r2) domega2_dr1(c1, c2, r1, r2) / 2 / sqrt(omega2(c1, c2, r1, r2));
domega_dr2 =  @(c1, c2, r1, r2) domega2_dr2(c1, c2, r1, r2) / 2 / sqrt(omega2(c1, c2, r1, r2));

%% delta - size of the correction
% delta =  norm(p - t) * (r1 - r2) / omega;

deltanum =  @(c1, c2, r1, r2) sqrt((p - t(c1, c2))' * (p - t(c1, c2))) * (r1 - r2);
ddeltanum_dc1 =  @(c1, c2, r1, r2) - (p - t(c1, c2))' * dt_dc1(c1, c2) /sqrt((p - t(c1, c2))' * (p - t(c1, c2))) * (r1 - r2);
ddeltanum_dc2 =  @(c1, c2, r1, r2) - (p - t(c1, c2))' * dt_dc2(c1, c2) /sqrt((p - t(c1, c2))' * (p - t(c1, c2))) * (r1 - r2);
ddeltanum_dr1 =  @(c1, c2, r1, r2) sqrt((p - t(c1, c2))' * (p - t(c1, c2)));
ddeltanum_dr2 =  @(c1, c2, r1, r2) -sqrt((p - t(c1, c2))' * (p - t(c1, c2)));

delta = @(c1, c2, r1, r2) deltanum(c1, c2, r1, r2) / omega(c1, c2, r1, r2);
ddelta_dc1 =  @(c1, c2, r1, r2) (ddeltanum_dc1(c1, c2, r1, r2) * omega(c1, c2, r1, r2) - ...
    deltanum(c1, c2, r1, r2) * domega_dc1(c1, c2, r1, r2)) / omega(c1, c2, r1, r2)^2;
ddelta_dc2 =  @(c1, c2, r1, r2) (ddeltanum_dc2(c1, c2, r1, r2) * omega(c1, c2, r1, r2) - ...
    deltanum(c1, c2, r1, r2) * domega_dc2(c1, c2, r1, r2)) / omega(c1, c2, r1, r2)^2;
ddelta_dr1 =  @(c1, c2, r1, r2) (ddeltanum_dr1(c1, c2, r1, r2) * omega(c1, c2, r1, r2) - ...
    deltanum(c1, c2, r1, r2) * domega_dr1(c1, c2, r1, r2)) / omega(c1, c2, r1, r2)^2;
ddelta_dr2 =  @(c1, c2, r1, r2) (ddeltanum_dr2(c1, c2, r1, r2) * omega(c1, c2, r1, r2) - ...
    deltanum(c1, c2, r1, r2) * domega_dr2(c1, c2, r1, r2)) / omega(c1, c2, r1, r2)^2;

%% w - correction vector
%w = delta * u / norm(u);
wnum = @(c1, c2, r1, r2) u(c1, c2) * delta(c1, c2, r1, r2); 
dwnum_dc1 = @(c1, c2, r1, r2) u(c1, c2) * ddelta_dc1(c1, c2, r1, r2) + du_dc1 * delta(c1, c2, r1, r2);
dwnum_dc2 = @(c1, c2, r1, r2) u(c1, c2) * ddelta_dc2(c1, c2, r1, r2) + du_dc2 * delta(c1, c2, r1, r2);
dwnum_dr1 = @(c1, c2, r1, r2) u(c1, c2) * ddelta_dr1(c1, c2, r1, r2);
dwnum_dr2 = @(c1, c2, r1, r2) u(c1, c2) * ddelta_dr2(c1, c2, r1, r2);

wdenum = @(c1, c2) sqrt(u(c1, c2)' * u(c1, c2));
dwdenum_dc1 = @(c1, c2) u(c1, c2)' * du_dc1/ sqrt(u(c1, c2)' * u(c1, c2));
dwdenum_dc2 = @(c1, c2) u(c1, c2)' * du_dc2/ sqrt(u(c1, c2)' * u(c1, c2));

w =  @(c1, c2, r1, r2)  wnum(c1, c2, r1, r2) / wdenum(c1, c2);
dw_dc1 =  @(c1, c2, r1, r2)  (dwnum_dc1(c1, c2, r1, r2) * wdenum(c1, c2) - ...
    wnum(c1, c2, r1, r2) * dwdenum_dc1(c1, c2)) /  wdenum(c1, c2)^2;
dw_dc2 =  @(c1, c2, r1, r2)  (dwnum_dc2(c1, c2, r1, r2) * wdenum(c1, c2) - ...
    wnum(c1, c2, r1, r2) * dwdenum_dc2(c1, c2)) /  wdenum(c1, c2)^2;
dw_dr1 =  @(c1, c2, r1, r2)  dwnum_dr1(c1, c2, r1, r2) / wdenum(c1, c2);
dw_dr2 =  @(c1, c2, r1, r2)  dwnum_dr2(c1, c2, r1, r2) / wdenum(c1, c2);

%% s - corrected point on the axis
% s = t - w
s = @(c1, c2, r1, r2) t(c1, c2) - w(c1, c2, r1, r2);
ds_dc1 = @(c1, c2, r1, r2) dt_dc1(c1, c2) - dw_dc1(c1, c2, r1, r2);
ds_dc2 = @(c1, c2, r1, r2) dt_dc2(c1, c2) - dw_dc2(c1, c2, r1, r2);
ds_dr1 = @(c1, c2, r1, r2) - dw_dr1(c1, c2, r1, r2);
ds_dr2 = @(c1, c2, r1, r2) - dw_dr2(c1, c2, r1, r2);

%% gamma - correction in the direction orthogonal to cone surface
% gamma = (r1 - r2) * norm(c2 - t + w)/ norm(u);

gammafactor = @(c1, c2, r1, r2) sqrt((c2 - t(c1, c2) + w(c1, c2, r1, r2))' * (c2 - t(c1, c2) + w(c1, c2, r1, r2)));
dgammafactor_dc1 =  @(c1, c2, r1, r2) (c2 - t(c1, c2) + w(c1, c2, r1, r2))' * (-dt_dc1(c1, c2) + dw_dc1(c1, c2, r1, r2)) / ...
    sqrt((c2 - t(c1, c2) + w(c1, c2, r1, r2))' * (c2 - t(c1, c2) + w(c1, c2, r1, r2)));
dgammafactor_dc2 =  @(c1, c2, r1, r2) (c2 - t(c1, c2) + w(c1, c2, r1, r2))' * (eye(n, n) - dt_dc2(c1, c2) + dw_dc2(c1, c2, r1, r2)) / ...
    sqrt((c2 - t(c1, c2) + w(c1, c2, r1, r2))' * (c2 - t(c1, c2) + w(c1, c2, r1, r2)));
dgammafactor_dr1 =  @(c1, c2, r1, r2) (c2 - t(c1, c2) + w(c1, c2, r1, r2))' * dw_dr1(c1, c2, r1, r2) / ...
    sqrt((c2 - t(c1, c2) + w(c1, c2, r1, r2))' * (c2 - t(c1, c2) + w(c1, c2, r1, r2)));
dgammafactor_dr2 =  @(c1, c2, r1, r2) (c2 - t(c1, c2) + w(c1, c2, r1, r2))' * dw_dr2(c1, c2, r1, r2) / ...
    sqrt((c2 - t(c1, c2) + w(c1, c2, r1, r2))' * (c2 - t(c1, c2) + w(c1, c2, r1, r2)));

gammanum = @(c1, c2, r1, r2) (r1 - r2) * gammafactor(c1, c2, r1, r2);
dgammanum_dc1 = @(c1, c2, r1, r2) (r1 - r2) * dgammafactor_dc1(c1, c2, r1, r2);
dgammanum_dc2 = @(c1, c2, r1, r2) (r1 - r2) * dgammafactor_dc2(c1, c2, r1, r2);
dgammanum_dr1 = @(c1, c2, r1, r2) gammafactor(c1, c2, r1, r2) + (r1 - r2) * dgammafactor_dr1(c1, c2, r1, r2);
dgammanum_dr2 = @(c1, c2, r1, r2) - gammafactor(c1, c2, r1, r2) + (r1 - r2) * dgammafactor_dr2(c1, c2, r1, r2);

gammadenum = @(c1, c2) sqrt(u(c1, c2)' * u(c1, c2));
dgammadenum_dc1 = @(c1, c2) u(c1, c2)' * du_dc1/ sqrt(u(c1, c2)' * u(c1, c2));
dgammadenum_dc2 = @(c1, c2) u(c1, c2)' * du_dc2/ sqrt(u(c1, c2)' * u(c1, c2));

gamma = @(c1, c2, r1, r2) gammanum(c1, c2, r1, r2) / gammadenum(c1, c2);
dgamma_dc1 = @(c1, c2, r1, r2) (dgammanum_dc1(c1, c2, r1, r2) * gammadenum(c1, c2) - ...
    gammanum(c1, c2, r1, r2) * dgammadenum_dc1(c1, c2)) / gammadenum(c1, c2)^2;
dgamma_dc2 = @(c1, c2, r1, r2) (dgammanum_dc2(c1, c2, r1, r2) * gammadenum(c1, c2) - ...
    gammanum(c1, c2, r1, r2) * dgammadenum_dc2(c1, c2)) / gammadenum(c1, c2)^2;
dgamma_dr1 = @(c1, c2, r1, r2) dgammanum_dr1(c1, c2, r1, r2) / gammadenum(c1, c2);
dgamma_dr2 = @(c1, c2, r1, r2) dgammanum_dr2(c1, c2, r1, r2) / gammadenum(c1, c2);

%% q - the point on the model surface
% q = s + (p - s) / norm(p - s) * (gamma + r2);

qdenum = @(c1, c2, r1, r2) sqrt((p - s(c1, c2, r1, r2))' * (p - s(c1, c2, r1, r2)));
dqdenum_dc1 = @(c1, c2, r1, r2) - (p - s(c1, c2, r1, r2))'* ds_dc1(c1, c2, r1, r2) / sqrt((p - s(c1, c2, r1, r2))' * (p - s(c1, c2, r1, r2)));
dqdenum_dc2 = @(c1, c2, r1, r2) - (p - s(c1, c2, r1, r2))'* ds_dc2(c1, c2, r1, r2) / sqrt((p - s(c1, c2, r1, r2))' * (p - s(c1, c2, r1, r2)));
dqdenum_dr1 = @(c1, c2, r1, r2) - (p - s(c1, c2, r1, r2))'* ds_dr1(c1, c2, r1, r2) / sqrt((p - s(c1, c2, r1, r2))' * (p - s(c1, c2, r1, r2)));
dqdenum_dr2 = @(c1, c2, r1, r2) - (p - s(c1, c2, r1, r2))'* ds_dr2(c1, c2, r1, r2) / sqrt((p - s(c1, c2, r1, r2))' * (p - s(c1, c2, r1, r2)));

qfactor = @(c1, c2, r1, r2) (p - s(c1, c2, r1, r2)) / qdenum(c1, c2, r1, r2);
dqfactor_dc1 = @(c1, c2, r1, r2) (- ds_dc1(c1, c2, r1, r2) * qdenum(c1, c2, r1, r2) -...
    (p - s(c1, c2, r1, r2)) * dqdenum_dc1(c1, c2, r1, r2)) / qdenum(c1, c2, r1, r2)^2;
dqfactor_dc2 = @(c1, c2, r1, r2) (- ds_dc2(c1, c2, r1, r2) * qdenum(c1, c2, r1, r2) -...
    (p - s(c1, c2, r1, r2)) * dqdenum_dc2(c1, c2, r1, r2)) / qdenum(c1, c2, r1, r2)^2;
dqfactor_dr1 = @(c1, c2, r1, r2) (- ds_dr1(c1, c2, r1, r2) * qdenum(c1, c2, r1, r2) -...
    (p - s(c1, c2, r1, r2)) * dqdenum_dr1(c1, c2, r1, r2)) / qdenum(c1, c2, r1, r2)^2;
dqfactor_dr2 = @(c1, c2, r1, r2) (- ds_dr2(c1, c2, r1, r2) * qdenum(c1, c2, r1, r2) -...
    (p - s(c1, c2, r1, r2)) * dqdenum_dr2(c1, c2, r1, r2)) / qdenum(c1, c2, r1, r2)^2;

q = @(c1, c2, r1, r2) s(c1, c2, r1, r2) + qfactor(c1, c2, r1, r2) * (gamma(c1, c2, r1, r2) + r2);
dq_dc1 = @(c1, c2, r1, r2) ds_dc1(c1, c2, r1, r2) + dqfactor_dc1(c1, c2, r1, r2) * (gamma(c1, c2, r1, r2) + r2) + ...
    qfactor(c1, c2, r1, r2) * (dgamma_dc1(c1, c2, r1, r2));
dq_dc2 = @(c1, c2, r1, r2) ds_dc2(c1, c2, r1, r2) + dqfactor_dc2(c1, c2, r1, r2) * (gamma(c1, c2, r1, r2) + r2) + ...
    qfactor(c1, c2, r1, r2) * (dgamma_dc2(c1, c2, r1, r2));
dq_dr1 = @(c1, c2, r1, r2) ds_dr1(c1, c2, r1, r2) + dqfactor_dr1(c1, c2, r1, r2) * (gamma(c1, c2, r1, r2) + r2) + ...
    qfactor(c1, c2, r1, r2) * (dgamma_dr1(c1, c2, r1, r2));
dq_dr2 = @(c1, c2, r1, r2) ds_dr2(c1, c2, r1, r2) + dqfactor_dr2(c1, c2, r1, r2) * (gamma(c1, c2, r1, r2) + r2) + ...
    qfactor(c1, c2, r1, r2) * (dgamma_dr2(c1, c2, r1, r2) + 1);

% q = @(c1) q(c1, c2, r1, r2);
% disp(my_gradient(q, c1));
% disp(dq_dc1(c1, c2, r1, r2));




