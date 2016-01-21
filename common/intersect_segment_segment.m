function [t] = intersect_segment_segment(a, b, c, d)

% figure; hold on; axis off; axis equal;
% myline(a, b, 'b');
% myline(c, d, 'b');

x1 = a(1); y1 = a(2);
x2 = b(1); y2 = b(2);
x3 = c(1); y3 = c(2);
x4 = d(1); y4 = d(2);

d = (x1-x2)*(y3-y4) - (y1-y2)*(x3-x4);
if (d == 0)
    t = [];
else    
    xi = ((x3-x4)*(x1*y2-y1*x2)-(x1-x2)*(x3*y4-y3*x4))/d;
    yi = ((y3-y4)*(x1*y2-y1*x2)-(y1-y2)*(x3*y4-y3*x4))/d;
    t  = [xi; yi];
    if (xi < min(x1, x2) || xi > max(x1, x2)), t = []; end
    if (xi < min(x3, x4) || xi > max(x3, x4)), t = []; end
end

% mypoint(t, 'm');