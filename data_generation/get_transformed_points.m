function [points] = get_transformed_points(centers, blocks, radii, factor, num_samples)

D = length(centers{1});
rotation = @(x) [cos(x), -sin(x); sin(x), cos(x)];

rotation_angle = factor * randn;
translation_vector = factor * randn(D, 1);

if D == 3
    rotation_axis = randn(D, 1);
    R = makehgtform('axisrotate', rotation_axis, rotation_angle);
    T = makehgtform('translate', translation_vector);
end
if D == 2
    R = eye(D + 1, D + 1);
    R(1:D, 1:D) = rotation(rotation_angle);
    T = eye(D + 1, D + 1);
    T(1:D, D + 1) = translation_vector;    
end
for i = 1:length(centers)
    centers{i} = transform(centers{i}, R);
    centers{i} = transform(centers{i}, T);
end

points = generate_convtriangles_points(centers, blocks, radii, num_samples);