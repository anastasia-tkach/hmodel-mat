%% Reduce size

centers = centers([20, 19, 26, 25]);
radii = radii([20, 19, 26, 25]);
solid_blocks = {} ;
parents = {[2], []};
blocks = {[1, 2], [1, 3, 4]};
global_frame_indices = [1, 3, 4];
attachments = cell(length(centers), 1);

centers = centers([20, 26, 25]);
radii = radii([20, 26, 25]);
solid_blocks = {} ;
parents = {[]};
blocks = {[1, 2, 3]};
global_frame_indices = [1, 2, 3];
attachments = cell(length(centers), 1);

data_points = generate_convtriangles_points(centers, blocks, radii, 400000);
rotation_axis = randn(D, 1); rotation_angle = 0.6 * randn; translation_vector = 0.5 * randn(D, 1);
save rotation_axis rotation_axis; save rotation_angle rotation_angle; save translation_vector translation_vector;
load rotation_axis; load rotation_angle; load translation_vector;
R = makehgtform('axisrotate', rotation_axis, rotation_angle);
T = makehgtform('translate', translation_vector);
for i = 1:length(centers)
   centers{i} = transform(centers{i}, R);
   centers{i} = transform(centers{i}, T);
end
