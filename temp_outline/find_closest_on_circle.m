function [k] = find_closest_on_circle(circles, centers, points, i, k)
epsilon = 1e-9;
min_delta = Inf;
v = points{k}.value - centers{i};
mypoint(points{k}.value, 'r');
alpha = myatan2(v, true);
for j = 1:length(circles{i}.points)
    u = points{circles{i}.points(j)}.value - centers{i};
    beta = myatan2(u, true);
    if beta < alpha, beta = beta + 2 * pi; end
    delta =  beta - alpha;
    if delta > - epsilon && delta < epsilon, continue; end
    disp(delta * 180 / pi);
    if delta < min_delta
        min_delta = delta;
        k = circles{i}.points(j);
    end
end