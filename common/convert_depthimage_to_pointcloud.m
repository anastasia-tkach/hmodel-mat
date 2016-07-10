function [points] = convert_depthimage_to_pointcloud(D)

RAND_MAX = 32767;
tx = 320 / 4; ty = 240 / 4; fx = 287.26; fy = 287.26;

[U, V] = meshgrid(1:size(D, 2), 1:size(D, 1));
UVD = zeros(size(D, 1), size(D, 2), 3);
UVD(:, :, 1) = U; UVD(:, :, 2) = V; UVD(:, :, 3) = D;
uvd = reshape(UVD, size(UVD, 1) * size(UVD, 2), 3)';
I = convert_uvd_to_xyz(tx, ty, fx, fy, uvd);
points = {};
indices = {};
for i = 1:size(I, 2)
    if I(3, i) ~= RAND_MAX && ~any(isnan(I(:, i)))
        points{end + 1} = I(:, i);
        indices{end + 1} = i;
    end
end
