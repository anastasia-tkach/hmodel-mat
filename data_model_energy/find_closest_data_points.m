function [pose] = find_closest_data_points(pose, view_axis, settings)
D = settings.D;

%% Inpaint
I = pose.back_map_for_rendered_data(:, :, 1);
[H, W] = size(pose.rendered_data);
for h = 1:H
    for w = 1:W
        if pose.rendered_data(h, w) == 0; continue; end
        if I(h, w) ~= 0; continue; end
        [u, v] = inpainting_inner_loop(I, h, w);
        pose.back_map_for_rendered_data(h, w, :) = pose.back_map_for_rendered_data(h + u, w + v, :);
    end
end
%% Compute projection
pose.closest_data_points = cell(length(pose.model_points), 1);

pose.model_points_2D = cell(length(pose.model_points), 1);
pose.data_points_2D = cell(length(pose.model_points), 1);

A = pose.P(:, 1:3); b = pose.P(:, 4);
for i = 1:length(pose.model_points)
    q = pose.model_points{i};
    n = A * q + b;
    n1 = n(1); n2 = n(2); n3 = n(3);
    if strcmp(view_axis, 'Y'), mx = n1/n3;
    else mx = W - n1/n3; end
    my = n2/n3; m = [mx; my];
    x = round(m(1)); y = round(m(2));
    
    pose.model_points_2D{i} = [x; y];
    
    if x < 1 || y < 1 || x > W || y > H
        pose.closest_data_points{i} = [];
        continue;
    end
    if (pose.rendered_data(y, x) == 1)
        pose.closest_data_points{i} = [];
        continue;
    else
        count = 0;
        while(pose.rendered_data(y, x) == 0) && count < 10;
            delta_x = round(pose.distance_transform(y, x) * cosd(pose.gradient_directions(y, x)));
            delta_y = round(pose.distance_transform(y, x) * sind(pose.gradient_directions(y, x)));
            x = x - delta_x;
            y = y + delta_y;
            count = count + 1;
        end
    end
    
    pose.data_points_2D{i} = [x; y];
    
    point = squeeze(pose.back_map_for_rendered_data(y, x, :));
    if sum(abs(point)) == 0, continue; end
    pose.closest_data_points{i} = point;
%     switch view_axis
%         case 'X'
%             pose.closest_data_points{i}(1) = q(1);
%         case 'Y'
%             pose.closest_data_points{i}(2) = q(2);
%         case 'Z'
%             pose.closest_data_points{i}(3) = q(3);
%     end
end

