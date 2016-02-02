function [q, s, index] = project_skewed_point_on_segment(p, c1, c2, r1, r2, index1, index2)

x = c2 - c1;
alpha = x' * (p - c1) / (x' * x);
t = c1 + alpha * x;
omega = sqrt(x' * x - (r1 - r2)^2);
delta =  norm(p - t) * (r1 - r2) / omega;
s = t - delta * x / norm(x);

if is_point_on_segment(c1, c2, s)
    gamma = (r1 - r2) * norm(c2 - t + delta * x / norm(x))/ sqrt(x' * x);
    q = s + (p - s) / norm(p - s) * (gamma + r2);      
    index = [index1, index2];
else
    if norm(p - c1) < norm(p - c2)
        s = c1; 
        q = c1 + r1 * (p - c1) / norm(p - c1);
        index = index1;
    else
        s = c2;
        q = c2 + r2 * (p - c2) / norm(p - c2);
        index = index2;
    end
end

