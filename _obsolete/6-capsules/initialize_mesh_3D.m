close all;
mesh = cylinders_model();

draw_projected_mesh(mesh, 'XY');

[x, y] = ginput(1);
scatter(x, y, 50, 'm', 'filled');
line([x, x], [y - 50, y + 50],'color', 'm', 'lineWidth', 3);
p0 = [x, y, 0];
vertical_crossection_mesh(mesh, p0);
line([0, 100], [y, y], 'color', 'm', 'lineWidth', 3);
[a, b] = ginput(1);
hold on; scatter(a, b, 50, 'm', 'filled');

%% Display results in two projections
figure; draw_mesh(mesh, [1, 0, 0], 'b');
scatter3(x, a, y, 50, 'm', 'filled');
figure; draw_mesh(mesh, [0, 0, 1], 'b');
scatter3(x, y, a, 50, 'm', 'filled');