function [Fn, Jn] = jacobian_silhouette(centers, radii, blocks,  model_points, model_indices, data_points, data_normals, attachments, settings)

D = settings.D;

[F, J] = jacobian_arap_translation_attachment(centers, radii, blocks, ...
    model_points, model_indices, data_points, attachments, D);

Fn = zeros(length(data_normals), 1); Jn = zeros(length(data_normals), D * length(centers));
for i = 1:length(data_normals)
    if isempty(data_normals{i}), continue; end
    Fn(i) = data_normals{i}' * F(D * (i - 1) + 1:D * i);
    Jn(i, :) = data_normals{i}' * J(D * (i - 1) + 1:D * i, :);
end