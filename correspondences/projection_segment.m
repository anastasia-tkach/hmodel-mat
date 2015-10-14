function [index, s] = projection_segment(p, c1, c2, index1, index2)

index = [];

u = c2 - c1;
v = p - c1;

alpha = u' * v / (u' * u);

if alpha <= 0
    s = c1;
    index = [index1];
end
if (alpha >= 1)    
    s = c2;
    index = [index2];    
end

if isempty(index)
    s = c1 + alpha * u;
    index = [index1, index2];
end



