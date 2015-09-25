function [xy_distances, yz_distances, distances] = silhouette_convtriangles(pose, blocks, radii, n)

centers = pose.centers;

%% Generating the volumetric domain data:

model_bounding_box = compute_model_bounding_box(centers, radii);

xm = linspace(model_bounding_box.min_x, model_bounding_box.max_x, n);
ym = linspace(model_bounding_box.min_y, model_bounding_box.max_y, n);
zm = linspace(model_bounding_box.min_z, model_bounding_box.max_z, n);

[x, y, z] = meshgrid(xm,ym,zm); N = numel(x);
points = [reshape(x, N, 1), reshape(y, N, 1), reshape(z, N, 1)];

tangent_points = blocks_tangent_points(pose.centers, blocks, radii);

min_xy_distances = Inf * ones(n ,n);
min_yz_distances = Inf * ones(n ,n);

for i = 1:length(blocks)
    if length(blocks{i}) == 3
        c1 = pose.centers{blocks{i}(1)}; c2 = pose.centers{blocks{i}(2)}; c3 = pose.centers{blocks{i}(3)};
        r1 = radii{blocks{i}(1)}; r2 = radii{blocks{i}(2)}; r3 = radii{blocks{i}(3)};
        v1 = tangent_points{i}.v1; v2 = tangent_points{i}.v2; v3 = tangent_points{i}.v3;
        u1 = tangent_points{i}.u1; u2 = tangent_points{i}.u2; u3 = tangent_points{i}.u3;
        distances = distance_to_model_convtriangle(c1, c2, c3, r1, r2, r3, v1, v2, v3, u1, u2, u3, points');
    end
    
    if length(blocks{i}) == 2
        c1 = pose.centers{blocks{i}(1)}; c2 = pose.centers{blocks{i}(2)};
        r1 = radii{blocks{i}(1)}; r2 = radii{blocks{i}(2)};
        distances = distance_to_model_convsegment(c1, c2, r1, r2, points');
    end
    
    distances = reshape(distances, size(x));
    
    xy_distances = min(distances, [], 3);
    min_xy_distances = min(min_xy_distances, xy_distances);
    
    yz_distances = shiftdim(distances, 2);
    yz_distances = min(yz_distances, [], 3);
    min_yz_distances = min(min_yz_distances, yz_distances);        
end


xy_distances = min_xy_distances;
yz_distances = min_yz_distances;

