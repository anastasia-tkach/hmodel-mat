function [k_next, type_next, i_next, v_next] = find_closest_on_segment(segments, points, i, k, v)

%% Find next point
epsilon = 1e-9;
min_delta = Inf;
for j = 1:length(segments{i}.points)
    w = points{segments{i}.points(j)}.value - points{k}.value;
    delta = norm(w);
    if w' * v < 0, continue; end
    if delta > - epsilon && delta < epsilon, continue; end
    if delta < min_delta
        min_delta = delta;
        k_next = segments{i}.points(j);
        u = w;
    end
end

%% Find the type of the next primitive
if points{k_next}.i1 == i && points{k_next}.type1 == 2
    type_next = points{k_next}.type2;
    i_next = points{k_next}.i2;
else
    type_next = points{k_next}.type1;
    i_next = points{k_next}.i1;
end

%% Find direction 
if type_next == 1
    v_next = u;
end
if type_next == 2
    v = segments{i_next}.t2 - segments{i_next}.t1;
    v_next = pick_closest_direction(u, v, 'clockwise');
end
