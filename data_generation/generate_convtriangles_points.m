function [points] = generate_convtriangles_points(centers, blocks, radii, N)

D = length(centers{1});

%N = 2000000; % palm_finger
%N = 500000; % finger
%N = 3000000; % hand
%N = 40000; % synthetic
model_bounding_box = compute_model_bounding_box(centers, radii);
x = model_bounding_box.min_x + (model_bounding_box.max_x - model_bounding_box.min_x) * rand(N, 1);
y = model_bounding_box.min_y + (model_bounding_box.max_y - model_bounding_box.min_y) * rand(N, 1);

if D == 3
    z = model_bounding_box.min_z + (model_bounding_box.max_z - model_bounding_box.min_z) * rand(N, 1);
    points = [x, y, z];
    tangent_points = blocks_tangent_points(centers, blocks, radii);
end
if D == 2
    points = [x, y];
end

min_distances = Inf * ones(N, 1);

for i = 1:length(blocks)
    if length(blocks{i}) == 3
        c1 = centers{blocks{i}(1)}; c2 = centers{blocks{i}(2)}; c3 = centers{blocks{i}(3)};
        r1 = radii{blocks{i}(1)}; r2 = radii{blocks{i}(2)}; r3 = radii{blocks{i}(3)};
        v1 = tangent_points{i}.v1; v2 = tangent_points{i}.v2; v3 = tangent_points{i}.v3;
        u1 = tangent_points{i}.u1; u2 = tangent_points{i}.u2; u3 = tangent_points{i}.u3;
        distances = distance_to_model_convtriangle(c1, c2, c3, r1, r2, r3, v1, v2, v3, u1, u2, u3, points');
    end
    if length(blocks{i}) == 2
        c1 = centers{blocks{i}(1)}; c2 = centers{blocks{i}(2)};
        r1 = radii{blocks{i}(1)}; r2 = radii{blocks{i}(2)};
        distances = distance_to_model_convsegment(c1, c2, r1, r2, points');
    end
    if length(blocks{i}) == 1
        c1 = centers{blocks{i}(1)};
        r1 = radii{blocks{i}(1)};
        distances = distance_to_model_sphere(c1, r1, points');
    end
    
    min_distances = min(min_distances, distances);
end

distances = min_distances;

valid_indices = abs(distances) < 0.005;
valid_indices = find(valid_indices);
valid_points = cell(length(valid_indices), 1);
for i = 1:length(valid_indices)
    valid_points{i} = points(valid_indices(i), :)';
end

% figure; hold on; axis equal;
% P = zeros(length(valid_points), 3);
% for i = 1:length(valid_points)
%     P(i, :) = valid_points{i}';
% end
% scatter3(P(:, 1), P(:, 2), P(:, 3), 30, [0, 0.7, 0.6], 'filled', 'm');
points = valid_points;



