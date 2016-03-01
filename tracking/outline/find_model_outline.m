function [outline3D] = find_model_outline(centers, radii, blocks, palm_blocks, fingers_blocks, fingers_base_centers, camera_ray, names_map, verbose)

palm_blocks = [palm_blocks, fingers_blocks{1}{3}, fingers_blocks{2}{3}, fingers_blocks{3}{3}, fingers_blocks{4}{3}];
fingers_blocks{1} = fingers_blocks{1}(1:2); fingers_blocks{2} = fingers_blocks{2}(1:2);
fingers_blocks{3} = fingers_blocks{3}(1:2); fingers_blocks{4} = fingers_blocks{4}(1:2);
fingers_base_centers(1) = 3; fingers_base_centers(2) = 7; fingers_base_centers(3) = 11;
fingers_base_centers(4) = 15; fingers_base_centers(5) = 19;

 %print_blocks(fingers_blocks{5});

%% Compute palm outline
[palm_outline] = find_planar_outline(centers, palm_blocks, radii, false);

final_outline = [];
for f = 1:length(fingers_blocks)
    %% Compute finger outline
    [finger_outline] = find_planar_outline(centers, fingers_blocks{f}, radii, false);
    
    %print_outline(finger_outline);
    
    %% Find common outline between palm and finger
    finger_index = -1; palm_index = -1;
    for i = 1:length(finger_outline)
        if finger_outline{i}.indices == fingers_base_centers(f)
            finger_index = i;
            break;
        end
    end
    for i = 1:length(palm_outline)
        if palm_outline{i}.indices == fingers_base_centers(f)
            palm_index = i;
            break;
        end
    end    
    if palm_index ~= -1 && finger_index ~= -1        
        intersections = intersect_segment_segment_same_circle(centers{palm_outline{palm_index}.indices}, radii{palm_outline{palm_index}.indices}, camera_ray, ...
            palm_outline{palm_index}.start, palm_outline{palm_index}.end, finger_outline{finger_index}.start, finger_outline{finger_index}.end);        
        for k = 1:length(intersections)
            intersections{k}.indices = fingers_base_centers(f);
            finger_outline{end + 1} = intersections{k};
        end
    end        
   
    if palm_index ~= -1, palm_outline(palm_index) = []; end
    if finger_index ~= -1, finger_outline(finger_index) = []; end
    
    final_outline = [final_outline, finger_outline];
    
   
end
final_outline = [final_outline, palm_outline];

[final_outline] = adjust_fingers_outline(centers, radii, final_outline, names_map);

%% Find 3D outline
[outline3D] = find_3D_outline(centers, final_outline);

%% Display
if ~verbose, return; end

%display_result(centers, [], [], blocks, radii, false, 0.5, 'small');
figure; hold on; axis off; axis equal;
for i = 1:length(outline3D)
    if length(outline3D{i}.indices) == 2
        myline(outline3D{i}.start, outline3D{i}.end, 'm');
    else
        draw_circle_sector_in_plane(centers{outline3D{i}.indices}, radii{outline3D{i}.indices}, camera_ray, outline3D{i}.start, outline3D{i}.end, 'm');
    end
end

view([0, 90]);

end

function []  = print_blocks(blocks)
for i = 1:length(blocks)
    if length(blocks{i}) == 2
        a = [blocks{i}(1) - 1, blocks{i}(2) - 1, 32767];
    end
    if length(blocks{i}) == 3
        a = [blocks{i}(1) - 1, blocks{i}(2) - 1,  blocks{i}(3) - 1];
    end
    disp(['palm_blocks.push_back(ivec3(', num2str(a(1)), ', ', num2str(a(2)), ', ', num2str(a(3)), '));']);
end
end


function print_outline(outline)
for i = 1:length(outline)
    disp(['outline[', num2str(i - 1), ']']);
    if length(outline{i}.indices) == 2
        disp(['   t1 = ' num2str(outline{i}.t1')]);
        disp(['   t2 = ' num2str(outline{i}.t2')]);
    end
    disp(['   indices = ' num2str(outline{i}.indices - 1)]);
    disp(['   start = ' num2str(outline{i}.start')]);
    disp(['   end = ' num2str(outline{i}.end')]);
    disp(' ');
end
end
