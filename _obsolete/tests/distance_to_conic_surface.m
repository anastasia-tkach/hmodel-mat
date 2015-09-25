function [index, q, s, is_inside, d] = distance_to_conic_surface(p, c1, c2, r1, r2, index1, index2)

if r2 > r1
    temp = r1; r1 = r2; r2 = temp;
    temp = c1; c1 = c2; c2 = temp;
    temp = index1; index1 = index2; index2 = temp;
end

%% Preliminary

[v1, v2, u1, u2] = tangent_points_convsegment(c1, c2, r1, r2, p);

%% Cases
index = [];

u = c2 - c1;
v = p - c1;

alpha = u' * v / (u' * u);
t = c1 + alpha * u;

omega = sqrt(u' * u - (r1 - r2)^2);
delta =  norm(p - t) * (r1 - r2) / omega;

%% Precompute  ends closest points
n = u / norm(u);
beta = asin((r1 - r2) /norm(c1 - c2));

k1 = project_point_on_plane(p, v1, n);
eta1 = r1 * sin(beta);
s1 = c1 + eta1 * n;
l1 = (k1 - s1) / norm(k1 - s1);
r1_tilde = r1 * cos(beta);
if (r1_tilde < norm(k1 - s1))
    q1 = s1 + l1 * r1_tilde;
else
    shift1 = eta1 * (r1_tilde - norm(s1 - k1)) / r1_tilde;
    q1 = k1 - shift1 * n;
end


k2 = project_point_on_plane(p, v2, n);
eta2 = r2 * sin(beta);
s2 = c2 + eta2 * n;
l2 = (k2 - s2) / norm(k2 - s2);
r2_tilde = r2 * cos(beta);
if (r2_tilde < norm(k2 - s2))
    q2 = s2 + l2 * r2_tilde;
else
    shift2 = eta2 * (r2_tilde - norm(s2 - k2)) / r2_tilde;
    q2 = k2 - shift2 * n;
end

%% Algorithm
if alpha <= 0
    s = s1; q =  q1;
    index = [index1];
end
if (alpha > 0 && alpha < 1)
    if (norm(c1 - t) < delta)
        s = s1; q = q1;
        index = [index1];
    end
end
if (alpha >= 1)
    if (norm(t - c2) > delta)
        s = s2; q = q2;
        index = [index2];
    end
    if norm(c1 - c2) < delta
        s = s1; q = q1;
        index = [index2];
    end
end

if isempty(index)
    s = t - delta * (c2 - c1) / norm(c2 - c1);
    gamma = (r1 - r2) * norm(c2 - t + delta * u / norm(u))/ sqrt(u' * u);
    q = s + (p - s) / norm(p - s) * (gamma + r2);
    index = [index1, index2];
end

%% Cheek is inside or outside
if  norm(p - s) - norm(q - s) > 10e-7
    is_inside = false;
else
    is_inside = true;
end

if norm(p - s) - norm(q - s) > 10e-7
    d = norm(p - q);
else
    d = -norm(p - q);
end

%% Display

% if length(index) == 2, return; end
% if index(1) == 1 && r1_tilde < norm(k1 - s1), return; end
% if index(1) == 2 && r2_tilde < norm(k2 - s2), return; end
% 
% mypoint(p, 'm');
% mypoint(q, 'r');
% % myline(p, q, 'm');
% myline(c1, c2, 'g');
% 
% if index(1) == index1
%     mypoint(s1, 'g');  
%     myline(k1, q1, 'r');
% end
% if index(1) == index2
%     mypoint(s2, 'g');  
%     myline(k2, q2, 'r');    
% end
% 





