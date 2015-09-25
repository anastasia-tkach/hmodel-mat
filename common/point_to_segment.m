function [d] = point_to_segment(p, c1, c2)

u = c2 - c1;
v = p - c1;

q = u' * v / (u' * u);

if q <= 0
    d = norm(p - c1);
end
if q > 0 && q < 1
    d = norm(p - c1 - q * (c2 - c1));
end
if q >= 1
    d = norm(p - c2);
end
