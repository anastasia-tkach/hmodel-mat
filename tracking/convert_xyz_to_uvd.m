function [uvd] = convert_xyz_to_uvd(tx, ty, fx, fy, xyz)

xyz(1, :) = xyz(1, :) ./ xyz(3, :);
xyz(2, :) = xyz(2, :) ./ xyz(3, :);
xyz(3, :) = xyz(3, :) ./ xyz(3, :);

x = xyz(1, :);
y = xyz(2, :);
z = xyz(3, :);

u =  fx * (x ./ z) + tx;
v = - fy * (y ./ z) + ty;
d = z;

uvd = [u; v; d];

