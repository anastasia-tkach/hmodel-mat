function [distances] = distance_to_model_convsegment_matlab(c1, c2, r1, r2, P)

distances = zeros(length(P), 1);
for i = 1:length(P)
    p = P(:, i);
    [~, q, ~, is_inside] = projection_convsegment(p, c1, c2, r1, r2, 1, 2);  
    distances(i) = norm(p - q);
    if is_inside
        distances(i) = - distances(i);
    end
end