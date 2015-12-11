function [Fn, Jcn, Jrn] = compute_normal_distance(centers, data_normals, F, Jc, Jr, D)

Fn = zeros(length(data_normals), 1);
Jcn = zeros(length(data_normals), D * length(centers));
Jrn = zeros(length(data_normals), length(centers));
for i = 1:length(data_normals)
    Fn(i) = data_normals{i}' * F(D * (i - 1) + 1:D * i);
    Jcn(i, :) = data_normals{i}' * Jc(D * (i - 1) + 1:D * i, :);
    if ~isempty(Jr)
        Jrn(i, :) = data_normals{i}' * Jr(D * (i - 1) + 1:D * i, :);
    end
end