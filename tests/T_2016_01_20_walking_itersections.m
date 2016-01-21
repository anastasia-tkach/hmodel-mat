close all;

[centers, radii, blocks] = get_random_convquad();
for i = 1:length(centers)
    centers{i} = centers{i} + [0; 0; 1];
end
camera_center = [0; 0; 0];
camera_ray = [0; 0; 1];


[outline, segments] = find_planar_outline(centers, blocks, radii);

display_result(centers, [], [], blocks, radii, false, 0.5, 'small');
%% Compute 3D outline
for i = 1:length(outline)
    if length(outline{i}.indices) == 2
        c1 = centers{outline{i}.indices(1)};
        c2 = centers{outline{i}.indices(2)};
        alpha = norm(outline{i}.t1 - outline{i}.start) / norm(outline{i}.t1 - outline{i}.t2);
        z_start = c1(3) * (1 - alpha) + c2(3) * alpha;
        alpha = norm(outline{i}.t1 - outline{i}.end) / norm(outline{i}.t1 - outline{i}.t2);
        z_end = c1(3) * (1 - alpha) + c2(3) * alpha;       
        outline{i}.start = [outline{i}.start; z_start];
        outline{i}.end = [outline{i}.end; z_end];
    else
        z_start = centers{outline{i}.indices(1)}(3);
        z_end = centers{outline{i}.indices(1)}(3);
        outline{i}.start = [outline{i}.start; z_start];
        outline{i}.end = [outline{i}.end; z_end];
    end   
end
for i = 1:length(outline)
    if length(outline{i}.indices) == 2
        myline(outline{i}.start, outline{i}.end, 'm');
    else
        draw_circle_sector_in_plane(centers{outline{i}.indices}, radii{outline{i}.indices}, camera_ray, outline{i}.t1, outline{i}.t2, 'm');
    end
end

view([0, 90]);