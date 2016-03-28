function [first_points, second_points] = draw_segment(Vertices, Triangles)

%scatter3(Vertices(1, :), Vertices(2, :), Vertices(3, :), 3, 'b', 'fill')
%hold on;
first_points = {};
second_points = {};
first_indices = [1, 2, 3];
second_indices = [2, 3, 1];
for i = 1:size(Triangles)
    for j = 1:length(first_indices)
        first_points{i} = Vertices(:, Triangles(i, first_indices(j)));
        second_points{i} = Vertices(:, Triangles(i, second_indices(j)));
    end
    
    X = [Vertices(1, Triangles(k, :)), Vertices(1, Triangles(k, 1))];
    Y = [Vertices(2, Triangles(k, :)), Vertices(2, Triangles(k, 1))];
    Z = [Vertices(3, Triangles(k, :)), Vertices(3, Triangles(k, 1))];
    if rem(i, 2) == 0
        line(X, Y, Z, 'color', [196/255, 178/255, 190/255], 'lineWidth', 1);
        line(X, Y, Z, 'color', [181/255, 123/255, 154/255], 'lineWidth', 2);
    end
    % fill3(X, Y, Z, [209/255, 180/255, 189/255], 'edgeColor', [196/255, 153/255, 177/255], 'lineWidth', 2)
end

