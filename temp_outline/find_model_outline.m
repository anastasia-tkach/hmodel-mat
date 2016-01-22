function [final_outline] = find_model_outline(centers, radii, blocks, palm_blocks, fingers_blocks, fingers_base_centers, camera_ray, verbose)

%% Compute palm outline
[palm_outline] = find_planar_outline(centers, palm_blocks, radii, false);

palm_outline_indicator = ones(length(palm_outline), 1);
new_palm_outline = palm_outline;

final_outline = cell(0, 1);
for f = 1:length(fingers_blocks)
    %% Compute finger outline
    [finger_outline] = find_planar_outline(centers, fingers_blocks{f}, radii, false);

    %% Find base position on the outline
    for i = 1:length(finger_outline)
        if finger_outline{i}.indices == fingers_base_centers(f)
            start = i; break;
        end
    end
    
    %% Find intersection    
    for i = start:length(finger_outline)
        for j = 1:length(palm_outline)
            [t1, t2] = intersect_outline_outline(centers, radii, finger_outline{i}, palm_outline{j});
            if ~isempty(t1) || ~isempty(t2)
                if ~isempty(t1), t = t1; end
                if ~isempty(t2), t = t2; end
                finger_outline(start + 1:i - 1) = [];
                finger_outline{i}.start = t;
                j1 = j; tj1 = t;
                break;
            end
        end
    end
    for i = start:-1:1
        for j = 1:length(palm_outline)
            [t1, t2] = intersect_outline_outline(centers, radii, finger_outline{i}, palm_outline{j});
            if ~isempty(t1) || ~isempty(t2)
                if ~isempty(t1), t = t1; end
                if ~isempty(t2), t = t2; end
                finger_outline(i + 1:start) = [];
                finger_outline{i}.end = t;
                j2 = j; tj2 = t;
                break;
            end
        end
    end
    final_outline = [final_outline, finger_outline];
    
    %% Erase palm outline    
    i1 = j1;
    i2 = j2;
    if j2 < j1, i2 = j2 + length(palm_outline); end
    d1 = i2 - j1;
    if j1 < j2, i1 = j1 + length(palm_outline); end
    d2 = i1 - j2;
    if d1 < d2
        palm_outline_indicator(j1 + 1:min(i2 - 1, length(palm_outline))) = 0;
        if i2 > length(palm_outline), palm_outline_indicator(1:j2 - 1) = 0; end
        new_palm_outline{j1}.end = tj1;
        new_palm_outline{j2}.start = tj2;
    end
    if d2 < d2
        palm_outline_indicator(j2 + 1:min(i1 - 1, length(palm_outline))) = 0;
        if i1 > length(palm_outline), palm_outline_indicator(1:j1 - 1) = 0; end
        new_palm_outline{j2}.end = tj2;
        new_palm_outline{j1}.start = tj1;
    end
end

for i = 1:length(new_palm_outline)
    if palm_outline_indicator(i) == 1
        final_outline = [final_outline, new_palm_outline{i}];
    end
end

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
