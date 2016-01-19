function [] = display_invalid_blocks(centers, radii, blocks, invalid_blocks)

valid_color = [0.1, 0.4, 0.7];
invalid_color = [0.9, 0.1, 0.3];

%% Draw skeleton
figure; axis off; axis equal; hold on;
for i = 1:length(blocks)
    if length(blocks{i}) == 2 && i > 15, continue; end
    indices = nchoosek(blocks{i}, 2);
    index1 = indices(:, 1); index2 = indices(:, 2);
    for j = 1:length(index1),
        c1 = centers{index1(j)};
        c2 = centers{index2(j)};
        scatter3(c1(1), c1(2), c1(3), 50, valid_color, 'o', 'filled');
        scatter3(c2(1), c2(2), c2(3), 50, valid_color, 'o', 'filled');
        line([c1(1), c2(1)], [c1(2), c2(2)], [c1(3), c2(3)], 'color', valid_color, 'lineWidth', 6);
    end
end

%% Draw invalib block
for i = 1:length(invalid_blocks)
    indices = nchoosek(invalid_blocks{i}, 2);
    index1 = indices(:, 1); index2 = indices(:, 2);
    for j = 1:length(index1),
        c1 = centers{index1(j)};
        c2 = centers{index2(j)};
        scatter3(c1(1), c1(2), c1(3), 50, valid_color, 'o', 'filled');
        scatter3(c2(1), c2(2), c2(3), 50, valid_color, 'o', 'filled');
        line([c1(1), c2(1)], [c1(2), c2(2)], [c1(3), c2(3)], 'color', invalid_color, 'lineWidth', 6);
    end
    for j = 1:length(invalid_blocks{i})
         draw_sphere(centers{invalid_blocks{i}(j)}, radii{invalid_blocks{i}(j)}, 'c');
    end
end
drawnow;