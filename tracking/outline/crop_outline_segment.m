function [final_outline] = crop_outline_segment(t, c1, c2, r1, r2, final_outline)

[t1, ~, t2, ~] = get_tangents(c1, c2, r1, r2);
P = {final_outline.start, final_outline.end};
Q = {t1, t2};
min_distance = inf;
for p = 1:2
    for q = 1:2
        if norm(P{p} - Q{q}) < min_distance
            min_distance = norm(P{p} - Q{q});
            outline = final_outline;
            if p == 1, outline.start = t; end
            if p == 2, outline.end = t; end
        end
    end
end
final_outline = outline;