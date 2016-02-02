function [i] = intersect_triangle_segment(v1, v2, v3, p1, p2)

[i, ~]  = ray_triangle_intersection (v1, v2, v3, p1, (p2 - p1)/norm(p2 - p1));

if ~is_point_on_segment(p1, p2, i);
    i = [inf; inf; inf];
end


%% Display

% figure; hold on; axis off; axis equal;
% myline(v1, v2, 'b');
% myline(v1, v3, 'b');
% myline(v3, v2, 'b');
% mypoint(p1, 'm');
% 
% myline(p1, p2, 'm');
% if result
%     mypoint(i, 'k');
% end

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