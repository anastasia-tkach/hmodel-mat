function [q] = project_point_on_segment(p, c1, c2)
u = c2 - c1;
v = p - c1;

alpha = u' * v / (u' * u);

if alpha <= 0
    q = c1;
end
if alpha > 0 && alpha < 1
    q = c1 + alpha * u;
end
if alpha >= 1    
    q = c2;
end