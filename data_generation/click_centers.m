function [centers, radii] = click_centers(p, radii, min_z, max_z)

subplot(1, 2, 1); hold on;
centers = cell(length(radii), 1);
for k = 1:length(centers)
    [x, y] = ginput(1);
    centers{k} = [x; y];
    hold on; mypoint(centers{k}, 'm');
    if (p == 1)
        [xr, yr] = ginput(1);
        r = norm([x - xr, y - yr]);
        radii{k} = r;
        draw_circle(centers{k}, radii{k}, [1, 0.7, 0]);
    end
    
end


for k = 1:length(centers)
    subplot(1, 2, 1); hold on; draw_circle([centers{k}(1), centers{k}(2)], radii{k}, [0, 0.5, 0.5]);
    subplot(1, 2, 2); hold on; line([min_z, max_z], [centers{k}(2), centers{k}(2)], 'color', [0, 0.5, 0.5], 'lineWidth', 2, 'lineStyle', '-.');
    [z, w] = ginput(1);
    centers{k} = [centers{k}; z];
    scatter(z, w, 50, 'm', 'filled');
    draw_circle([centers{k}(3), centers{k}(2)], radii{k}, [1, 0.7, 0]);
    subplot(1, 2, 1); hold on; draw_circle(centers{k}, radii{k}, [1, 0.7, 0]);
    subplot(1, 2, 2); hold on; line([min_z, max_z], [centers{k}(2), centers{k}(2)], 'color', [0.8, 0.8, 0.8], 'lineWidth', 2, 'lineStyle', '-.');
end





