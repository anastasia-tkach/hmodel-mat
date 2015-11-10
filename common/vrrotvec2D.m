function [theta] = vrrotvec2D(a, b)

rotation = @(x) [cos(x), -sin(x); sin(x), cos(x)];

theta = acos(a' * b / norm(a) / norm(b));
if norm(b / norm(b) - rotation(theta) * a / norm(a)) > 1e-10,
    theta = - theta; 
end