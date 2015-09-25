function [pose] = compute_correspondences_tangent(pose, children, radii)

num_points = pose.num_points;
num_centers = pose.num_centers;
points = pose.points;
centers = pose.centers;


I = cell(num_points, 1);
min_distance = Inf * ones(num_points, 1);
projections = cell(num_points, 1);
index = cell(1, 1);

for i = 1:num_points
    
    for j = 1:num_centers
        
        for k = 1:length(children{j})
            
            [index, q, ~] = compute_correspondence(points{i}, centers{j}, centers{children{j}(k)}, radii{j}, ...
                radii{children{j}(k)}, j, children{j}(k));
        end
        
        if norm(points{i} - q) < min_distance(i)
            min_distance(i) = norm(points{i} - q);
            I{i} = index;
            projections{i} = q;
        end
        
    end
end

pose.I = I;
pose.projections = projections;