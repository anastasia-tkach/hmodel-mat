function [data_points] = get_sensor_points(sensor_path, K)

tx = 640 / 4; ty = 480 / 4; fx = 287.26; fy = 287.26;
filename = [sensor_path, sprintf('%3.7d', K-1), '.png']; D = imread(filename);
filename = [sensor_path, 'mask_', sprintf('%3.7d', K-1), '.png']; M = imread(filename);
D(M == 0) = 0;
[U, V] = meshgrid(1:size(D, 2), 1:size(D, 1));
UVD = zeros(size(D, 1), size(D, 2), 3);
UVD(:, :, 1) = U; UVD(:, :, 2) = V; UVD(:, :, 3) = D;
uvd = reshape(UVD, size(UVD, 1) * size(UVD, 2), 3)';
I = convert_uvd_to_xyz(tx, ty, fx, fy, uvd);

data_points = {};
for i = 1:size(I, 2)
    if ~any(isnan(I(:, i))), data_points{end + 1} = I(:, i); end
end

%% Filter datapoints
figure; axis off; axis equal; hold on;
mypoints(data_points, 'r');
depth_image = reshape(I, 3, ty * 2, tx * 2);
depth_image = shiftdim(depth_image, 1);
depth = depth_image(:, :, 3);
max_depth = max(depth(:));
depth = depth ./ max_depth;
depth = bfilter2(depth, 5, [2 0.1]);
depth = depth .* max_depth;
depth_image(:, :, 3) = depth;
depth_image = shiftdim(depth_image, 2);
I2 = reshape(depth_image, 3, ty * 2 * tx * 2);

data_points = {};
for i = 1:size(I2, 2)
    if ~any(isnan(I2(:, i)))
        data_points{end + 1} = I2(:, i);
    end
end
mypoints(data_points, 'b');