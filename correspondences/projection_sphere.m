function [index, q, s, is_inside] = projection_sphere(p, c, r, index)

s = c;
q =  c + r * (p - c) / norm(p - c);

%% Cheek is inside or outside
if  norm(p - s) - norm(q - s) > 10e-7 || norm(p - s) == norm(q - s)
    is_inside = false;
else
    is_inside = true;
end

