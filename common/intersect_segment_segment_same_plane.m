function [i] = intersect_segment_segment_same_plane(p1, p2, q1, q2)

r = p2 - p1;
s = q2 - q1;

t = cross(q1 - p1, s) ./ cross(r, s);

t = mean(t);

if t >= 0 && t <= 1
    i = p1 + t * r;
else
    i = [inf; inf; inf];
end

% figure; hold on; axis off; axis equal;
% myline(p1, p2, 'b');
% myline(q1, q2, 'c');
% mypoint(i, 'm');