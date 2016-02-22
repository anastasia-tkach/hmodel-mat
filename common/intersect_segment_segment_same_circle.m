function [intersections] = intersect_segment_segment_same_circle(c, r, n, s1, e1, s2, e2)

v1 = s1(1:2) - c(1:2);
u1 = e1(1:2) - c(1:2);
alpha1 = atan2(v1(2), v1(1));
beta1 = atan2(u1(2), u1(1));
if alpha1 < 0, alpha1 = alpha1 + 2 * pi; end
if beta1 < 0, beta1 = beta1 + 2 * pi; end

v2 = s2(1:2) - c(1:2);
u2 = e2(1:2) - c(1:2);
alpha2 = atan2(v2(2), v2(1));
beta2 = atan2(u2(2), u2(1));
if alpha2 < 0, alpha2 = alpha2 + 2 * pi; end
if beta2 < 0, beta2 = beta2 + 2 * pi; end

arcs1 = {};
if alpha1 < beta1
    arcs1{end + 1} = [alpha1; beta1];
else
    arcs1{end + 1} = [0; beta1];
    arcs1{end + 1} = [alpha1; 2 * pi];
end

arcs2 = {};
if alpha2 < beta2
    arcs2{end + 1} = [alpha2; beta2];
else
    arcs2{end + 1} = [0; beta2];
    arcs2{end + 1} = [alpha2; 2 * pi];
end

intersections = {};
for i = 1:length(arcs1)
    for j = 1:length(arcs2)
        if max(arcs1{i}(1), arcs2{j}(1)) < min(arcs1{i}(2), arcs2{j}(2))
            gamma = max(arcs1{i}(1), arcs2{j}(1));
            delta = min(arcs1{i}(2), arcs2{j}(2));
            intersections{end + 1}.start = c(1:2) + r * [cos(gamma); sin(gamma)];
            intersections{end}.end = c(1:2) + r * [cos(delta); sin(delta)];
        end
    end
end

%% Display
return
figure; hold on; axis off; axis equal;
draw_circle_sector_in_plane(c, r, n, s1, e1, [0.75, 0.75, 0.75]);
draw_circle_sector_in_plane(c, r, n, s2, e2, 'c');
for i = 1:length(intersections)
    draw_circle_sector_in_plane(c, r, n, intersections{i}.start, intersections{i}.end, 'm');
end
mypoint(s1, [0.75, 0.75, 0.75]); mypoint(e1, [0.75, 0.75, 0.75]);
mypoint(s2, 'c'); mypoint(e2, 'c');