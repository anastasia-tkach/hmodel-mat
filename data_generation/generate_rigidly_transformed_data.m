close all;

D = 3;
%% Hand model

model_path = '_data/my_hand/model/';
data_path = '_data/my_hand/trial1/';
load([model_path, 'centers.mat']);
load([model_path, 'radii.mat']);
load([model_path, 'blocks.mat']);
load([model_path, 'solids.mat']);

display_result_convtriangles(centers, [], [], blocks, radii, true); campos([10, 160, -1500]); camlight;

%% Generate model
% rotation_axis = randn(D, 1);
% rotation_angle = 0 * randn;
% translation_vector = 4 * randn(D, 1);
% R = makehgtform('axisrotate', rotation_axis, rotation_angle);
% T = makehgtform('translate', translation_vector);
for i = 1:length(centers)
    centers{i} = transform(centers{i}, R);
    centers{i} = transform(centers{i}, T);
end

%display_result_convtriangles(centers, [], [], blocks, radii, true); campos([10, 160, -1500]); camlight;
points = generate_convtriangles_points(centers, blocks, radii);
mypoints(points, 'm');

save([model_path, 'points.mat'], 'points');
normals = [];
save([model_path, 'normals.mat'], 'normals');
