function [distances] = distance_to_model_sphere(c, r, P)

distances = zeros(length(P), 1);
for i = 1:length(P)
    p = P(:, i);
    distances(i) = norm(p - c) - r;    
end
