%% Display projections
xm = linspace(min_x, max_x, n);
ym = linspace(min_y, max_y, n);
[x, y] = meshgrid(xm,ym);
figure; contourf(x, y, xy_distances, 1, 'edgeColor', 'none');
colormap([0 0.6 0.7; 1, 1, 1]);

zm = linspace(min_z, max_z, n);
[z, y] = meshgrid(zm,ym);
figure; contourf(z, y, yz_distances', 1, 'edgeColor', 'none');
colormap([0 0.6 0.7; 1, 1, 1]);
