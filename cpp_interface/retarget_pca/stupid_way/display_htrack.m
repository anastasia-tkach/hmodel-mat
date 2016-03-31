function [] = display_htrack(segments, triangles, figure_mode)

num_phalanges = 16;

if strcmp(figure_mode, 'small')
    figure; hold on;
end
if strcmp(figure_mode, 'big')
    figure('units','normalized','outerposition',[0.0 0.085 1 0.873]);
end
hold on; axis off; axis equal; set(gcf,'color','w');

for j = 1:num_phalanges
    Vertices = transform(segments{j}.V, segments{j}.global);
    
    for i = 1:size(triangles)
        k = i;
        X = [Vertices(1, triangles(k, :)), Vertices(1, triangles(k, 1))];
        Y = [Vertices(2, triangles(k, :)), Vertices(2, triangles(k, 1))];
        Z = [Vertices(3, triangles(k, :)), Vertices(3, triangles(k, 1))];
        if rem(i, 2) == 0
            line(X, Y, Z, 'color', [181/255, 123/255, 154/255], 'lineWidth', 1);
        end
        % fill3(X, Y, Z, [209/255, 180/255, 189/255], 'edgeColor', [196/255, 153/255, 177/255], 'lineWidth', 2)
    end
    
end