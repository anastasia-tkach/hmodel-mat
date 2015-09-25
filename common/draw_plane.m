function [x, y, z] = draw_plane(point, normal, color, bounding_box)

d = -point' * normal;

num = 60;

if normal(1) ~= 0
    ym = linspace(bounding_box.min_y, bounding_box.max_y, num);
    zm = linspace(bounding_box.min_z, bounding_box.max_z, num);    
    [y, z] = meshgrid(ym, zm);    
    x = (-normal(2) * y - normal(3) * z - d)/normal(1);
end

if normal(2) ~= 0
    xm = linspace(bounding_box.min_x, bounding_box.max_x, num);
    zm = linspace(bounding_box.min_z, bounding_box.max_z, num);    
    [x, z] = meshgrid(xm, zm);    
    y = (-normal(1) * x - normal(3) * z - d)/normal(2);
end

if (normal(3) ~= 0)
    xm = linspace(bounding_box.min_x, bounding_box.max_x, num);
    ym = linspace(bounding_box.min_y, bounding_box.max_y, num);    
    [x, y] = meshgrid(xm, ym);    
    z = (-normal(1) * x - normal(2) * y - d)/normal(3);
end

surf(x, y, z, 'EdgeColor', 'none', 'FaceColor', color, 'FaceAlpha', 0.5);