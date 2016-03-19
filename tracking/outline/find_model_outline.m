function [outline3D] = find_model_outline(centers, radii, blocks, palm_blocks, fingers_blocks, fingers_base_centers, camera_ray, names_map, verbose, hmodel_model)

fingers_base_centers(1) = 3; fingers_base_centers(2) = 7; fingers_base_centers(3) = 11;
fingers_base_centers(4) = 15; fingers_base_centers(5) = 19;

if (hmodel_model)
    palm_blocks = [palm_blocks, fingers_blocks{1}{3}, fingers_blocks{2}{3}, fingers_blocks{3}{3}, fingers_blocks{4}{3}];
    fingers_blocks{1} = fingers_blocks{1}(1:2); fingers_blocks{2} = fingers_blocks{2}(1:2);
    fingers_blocks{3} = fingers_blocks{3}(1:2); fingers_blocks{4} = fingers_blocks{4}(1:2);

    palm_blocks_indices = [];
    
    for i = 1:length(palm_blocks)
        for j = 1:length(blocks)
            if length(palm_blocks{i}) ~= length(blocks{j}), continue; end
            if all(ismember(palm_blocks{i}, blocks{j}))
                palm_blocks_indices(end + 1) = j;
            end
        end
    end
    fingers_blocks_indices = {};
    for f = 1:length(fingers_blocks)
        finger_blocks_indices = [];
        for i = 1:length(fingers_blocks{f})
            for j = 1:length(blocks)
                if length(fingers_blocks{f}{i}) ~= length(blocks{j}), continue; end
                if all(ismember(fingers_blocks{f}{i}, blocks{j}))
                    finger_blocks_indices(end + 1) = j;
                end
            end
        end
        fingers_blocks_indices{end + 1} = finger_blocks_indices;
    end
    
else
    palm_blocks_indices = [3, 6, 9, 12, 15, 16, 17];    
    fingers_blocks_indices = {};
    fingers_blocks_indices{end + 1} = [1; 2];
    fingers_blocks_indices{end + 1} = [4; 5];    
    fingers_blocks_indices{end + 1} = [7; 8];
    fingers_blocks_indices{end + 1} = [10; 11];
    fingers_blocks_indices{end + 1} = [13; 14];
end

%% Compute palm outline
[palm_outline] = find_planar_outline(centers, blocks, palm_blocks_indices, radii, false);

final_outline = [];
for f = 1:length(fingers_blocks_indices)
    %% Compute finger outline
    [finger_outline] = find_planar_outline(centers, blocks, fingers_blocks_indices{f}, radii, false);
    
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
            finger_outline{end}.block = finger_outline{finger_index}.block;
        end
    end
    
    if palm_index ~= -1, palm_outline(palm_index) = []; end
    if finger_index ~= -1, finger_outline(finger_index) = []; end
    
    final_outline = [final_outline, finger_outline];
    
    
end
final_outline = [final_outline, palm_outline];

if (hmodel_model)
    [final_outline] = adjust_fingers_outline(centers, radii, final_outline, names_map);
end

%% Find 3D outline
[outline3D] = find_3D_outline(centers, final_outline);

%% Display
if ~verbose, return; end

display_result(centers, [], [], blocks, radii, false, 0.9, 'big');
%figure; hold on; axis off; axis equal;
for i = 1:length(outline3D)
    if length(outline3D{i}.indices) == 2
        myline(outline3D{i}.start, outline3D{i}.end, 'm');
    else
        draw_circle_sector_in_plane(centers{outline3D{i}.indices}, radii{outline3D{i}.indices}, camera_ray, outline3D{i}.start, outline3D{i}.end, 'm');
    end
end

view([-180, -90]); camlight;

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
