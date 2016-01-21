function [t1, t2] = intersect_circle_segment(p, q, c, r)


k = (p(2) - q(2)) / (p(1) - q(1));
b = p(2) - k * p(1);
[x, y] = intersect_circle_line(k, b, c(1), c(2), r); 
t1 = [x(1); y(1)];
t2 = [x(2); y(2)];

if any(isnan(t1)) || ~is_point_on_segment(p, q, t1), t1 = []; end
if any(isnan(t2)) || ~is_point_on_segment(p, q, t2), t2 = []; end

%% Display
% figure; hold on; axis off; axis equal;
% myline(p, q, 'b');
% draw_circle(c, r, 'c');
% mypoint(t1, 'm');
% mypoint(t2, 'm');


end

function [result] = is_point_on_segment(a, b, c)
    result = false;
    v = (b - a)' * (c - a);
    if v < 0
        return
    end
    if v > (b - a)' * (b - a);
        return
    end
    result = true;
end