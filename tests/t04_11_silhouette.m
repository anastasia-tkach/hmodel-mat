clear;
D = 3;
[centers, radii, blocks] = get_random_convsegment();
points = generate_convtriangles_points(centers, blocks, radii);

rotation_axis = randn(D, 1); rotation_angle = randn;
translation_vector = rand(D, 1);
R = makehgtform('axisrotate', rotation_axis, rotation_angle);
T = makehgtform('translate', translation_vector);

for i = 1:length(centers)
    centers{i} = transform(centers{i}, R);
    centers{i} = transform(centers{i}, T);
end

display_result_convtriangles(centers, points, [], blocks, radii, true);