function [] = draw_simple_pose_3D()
close all;
num_centers = 4;
centers = cell(num_centers, 1);
radii = cell(num_centers, 1);
figure; hold on;
for i = 1:num_centers
    
    %% Frontal projection
    subplot(1, 2, 1); axis equal; hold on;
    xlim([0, 1]); ylim([0, 1]);
    [x, y] = ginput(1);
    scatter(x, y, 50, 'm', 'filled');
    line([x, x], [y - 1, y + 1],'color', 'm', 'lineWidth', 3);
    xlim([0, 1]); ylim([0, 1]);
    
    p0 = [x, y, 0];
    [xr, yr] = ginput(1);
    r = norm([x - xr, y - yr]);
    radii{i} = r;
    draw_circle([x, y], r, [0, 0.9, 0.6]);
    
    
    %% Vertical projection
    subplot(1, 2, 2); axis equal;  hold on;
    xlim([0, 1]); ylim([0, 1]);
    line([0, 100], [y, y], 'color', 'm', 'lineWidth', 3);
    xlim([0, 1]); ylim([0, 1]);
    
    [a, b] = ginput(1);
    centers{i} = [x; y; a];
    hold on; scatter(a, b, 50, 'm', 'filled');
    draw_circle([a, b], r, [0, 0.9, 0.6]);  
    
end

%% Final result
points = {};
segments = cell(num_centers-1, 1);
k = 1;
for i = 1:num_centers - 1
    mesh = generate_segment_mesh(centers{i}, centers{i + 1}, radii{i}, radii{i + 1});
    segments{i} = mesh;
end

%figure; hold on; axis equal;
for i = 1:num_centers - 1
    %draw_mesh(segments{i}, [0, 0, 1], 'b');
    for j = 1:size(mesh.vertices, 1)
        points{k} = segments{i}.vertices(j, :)';
        k = k + 1;
    end
end

% Remove data from interior
invalid_indices = [];
k = 1;
for i = 1:length(points)
    p = points{i};
    for s = 1:num_centers - 1
        c1 = centers{s};
        c2 = centers{s + 1};
        r1 = radii{s};
        r2 = radii{s + 1};
        [d, t, r] = point_to_segment_distance(p, c1, c2, r1, r2);
        if d < 0.99 * r
            invalid_indices = [invalid_indices, i];
        end
    end
end
points(invalid_indices) = [];

save('C:\Users\Anastasia\OneDrive\EPFL\Code\HandModel\data\simple_3d\points', 'points');

figure; hold on; axis equal;
for i = 1:length(points)
    scatter3(points{i}(1), points{i}(2), points{i}(3), 30, [0, 0.9, 0.6], 'filled');
end




