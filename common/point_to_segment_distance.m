function [d, t, r] = point_to_segment_distance(p, c1, c2, r1, r2)

u = c2 - c1;
v = p - c1;

q = u' * v / (u' * u);

if q <= 0
    d = norm(p - c1);
    t = c1;
    r = r1;
end
if q > 0 && q < 1
    d = norm(p - c1 - q * (c2 - c1));
    t = c1 + q * u;
    r = (norm(c2 - t) * r1 + norm(t - c1) * r2) / norm(c2 - c1);
end
if q >= 1
    d = norm(p - c2);
    t = c2;
    r = r2;
end

%figure; axis equal; hold on;
% line([c1(1), c2(1)], [c1(2), c2(2)], [c1(3), c2(3)]);
% line([p(1), t(1)], [p(2), t(2)], [p(3), t(3)]);