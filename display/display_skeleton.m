function [] = display_skeleton(centers, radii, blocks, points, display_data, edge_color)

D = length(centers{1});
if isempty(edge_color), edge_color = [0.1, 0.4, 0.7]; end

%figure; axis off; axis equal; hold on;
for i = 1:36
    draw_sphere(centers{i}, radii{i}, 'c');
end
if display_data, mypoints(points, 'b'); end
for i = 1:length(blocks)
    
    %if length(blocks{i}) == 2 && i > 15, continue; end
    
    indices = nchoosek(blocks{i}, 2);
    index1 = indices(:, 1); index2 = indices(:, 2);
    for j = 1:length(index1),
        c1 = centers{index1(j)};
        c2 = centers{index2(j)};
        
        if D == 3
            scatter3(c1(1), c1(2), c1(3), 50, edge_color, 'o', 'filled');
            scatter3(c2(1), c2(2), c2(3), 50, edge_color, 'o', 'filled');
            line([c1(1), c2(1)], [c1(2), c2(2)], [c1(3), c2(3)], 'color', edge_color, 'lineWidth', 7);
        end
        
        if D == 2
            scatter(c1(1), c1(2), 50, edge_color, 'o', 'filled');
            scatter(c2(1), c2(2), 50, edge_color, 'o', 'filled');
            line([c1(1), c2(1)], [c1(2), c2(2)], 'color', edge_color, 'lineWidth', 4);
        end
    end
end