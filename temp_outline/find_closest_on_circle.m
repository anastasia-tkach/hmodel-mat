function [k_next, type_next, i_next, v_next] = find_closest_on_circle(circles, centers, segments, points, i, k)

%% Find next point
epsilon = 1e-9;
min_delta = Inf;
v = points{k}.value - centers{i};
alpha = myatan2(v);
for j = 1:length(circles{i}.points)
    u = points{circles{i}.points(j)}.value - centers{i};
    beta = myatan2(u);
    if beta < alpha, beta = beta + 2 * pi; end
    delta =  beta - alpha;
    if delta > - epsilon && delta < epsilon, continue; end
    if delta < min_delta
        min_delta = delta;
        k_next = circles{i}.points(j);
        u_next = u;
    end
end

%% Find the type of the next primitive
if points{k_next}.i1 == i && points{k_next}.type1 == 1
    type_next = points{k_next}.type2;
    i_next = points{k_next}.i2;
else
    type_next = points{k_next}.type1;
    i_next = points{k_next}.i1;
end

%% Find direction
% If it is a tangency point
if ismember(i, segments{i_next}.indices),
    p1 = points{k_next}.value;
    if abs(segments{i_next}.t1 - p1) < epsilon;
        p2 = segments{i_next}.t2;
    else
        p2 = segments{i_next}.t1;
    end
    v_next = p2 - p1;
% If it is an intersection point
else    
    beta = myatan2(u_next);
    beta = beta + 1e-5;
    w = [cos(beta); sin(beta)];
    tangent = w - u_next/norm(u_next);
    v = segments{i_next}.t2 - segments{i_next}.t1;
    v_next = pick_closest_direction(tangent, v, 'clockwise');
end

