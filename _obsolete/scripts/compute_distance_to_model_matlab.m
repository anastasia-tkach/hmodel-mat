function distance = compute_distance_to_model_matlab(p, c1, c2, r1, r2, index1, index2)

[~, q, s] = compute_correspondence(p, c1, c2, r1, r2, index1, index2);
if (norm(p - s) >= norm(q - s))
    distance = norm(p - q);
else
    distance = - norm(p - q);
end