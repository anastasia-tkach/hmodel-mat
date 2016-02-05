function [distance] = compute_signed_distance(p, q, s, insideness)

distance = norm(p - q);

if  norm(p - s) - norm(q - s) > 10e-7 || abs(norm(p - s) - norm(q - s)) < 10e-10
    if ~isempty(insideness) && insideness == true
        distance = -distance;
    end
    return
else
    distance = -distance;
end