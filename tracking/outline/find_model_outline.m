function [outline3D] = find_model_outline(centers, radii, blocks, palm_blocks, fingers_blocks, fingers_base_centers, camera_ray, verbose)

%% Compute palm outline
[palm_outline] = find_planar_outline(centers, palm_blocks, radii, verbose);

final_outline = [];
for f = 1:length(fingers_blocks)
    %% Compute finger outline
    [finger_outline] = find_planar_outline(centers, fingers_blocks{f}, radii, verbose);
    
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

%% Find 3D outline
[outline3D] = find_3D_outline(centers, final_outline);

%% Display
if ~verbose, return; end

display_result(centers, [], [], blocks, radii, false, 0.5, 'small');

for i = 1:length(outline3D)
    if length(outline3D{i}.indices) == 2
        myline(outline3D{i}.start, outline3D{i}.end, 'm');
    else
        draw_circle_sector_in_plane(centers{outline3D{i}.indices}, radii{outline3D{i}.indices}, camera_ray, outline3D{i}.start, outline3D{i}.end, 'm');
    end
end

view([0, 90]);
