function [pose] = compute_correspondences(pose, children)

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
            
            u = centers{children{j}(k)} - centers{j};
            v = points{i} - centers{j};
            projection = u' * v / (u' * u);
            if projection <= 0,
                index = [j];
                t = centers{j};
            end
            if projection > 0 && projection <= 1
                index = [j, children{j}(k)];
                t = centers{j} + projection * (centers{children{j}(k)} - centers{j});
            end
            if projection > 1
                index = [children{j}(k)];
                t = centers{children{j}(k)};
            end
            
        end
        
        if norm(points{i} - t) < min_distance(i)
            min_distance(i) = norm(points{i} - t);
            I{i} = index;
            projections{i} = t;
        end
        
    end
end

pose.I = I;
pose.projections = projections;