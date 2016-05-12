function [] = display_skeleton(centers, radii, blocks, points, display_data, edge_color, transparency)

D = length(centers{1});
if isempty(edge_color), edge_color = [0.1, 0.4, 0.7]; end

%% Draw spheres
%{
for i = 1:length(centers)
    draw_sphere(centers{i}, radii{i}, edge_color, transparency);
end
%}

%% Draw edges
if display_data, mypoints(points, 'b'); end
for i = 1:length(blocks)
%for i = 1:14  
    %if length(blocks{i}) == 2 && i > 15, continue; end
    
    indices = nchoosek(blocks{i}, 2);
    index1 = indices(:, 1); index2 = indices(:, 2);
    for j = 1:length(index1),
        c1 = centers{index1(j)};
        c2 = centers{index2(j)};
        
        if D == 3
            scatter3(c1(1), c1(2), c1(3), 11, edge_color, 'o', 'filled');
            scatter3(c2(1), c2(2), c2(3), 11, edge_color, 'o', 'filled');
            line([c1(1), c2(1)], [c1(2), c2(2)], [c1(3), c2(3)], 'color', edge_color, 'lineWidth', 2);
        end
        
        if D == 2
            scatter(c1(1), c1(2), 50, edge_color, 'o', 'filled');
            scatter(c2(1), c2(2), 50, edge_color, 'o', 'filled');
            line([c1(1), c2(1)], [c1(2), c2(2)], 'color', edge_color, 'lineWidth', 4);
        end
    end
end