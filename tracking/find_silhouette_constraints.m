function [closest_data_points, model_points_2D, data_points_2D] = find_silhouette_constraints(...
    model_points, back_map_for_rendered_data, rendered_data, P, view_axis)

%% Inpaint
I = back_map_for_rendered_data(:, :, 1);
[H, W] = size(rendered_data);
for h = 1:H
    for w = 1:W
        if rendered_data(h, w) == 0; continue; end
        if I(h, w) ~= 0; continue; end
        [u, v] = inpainting_inner_loop(I, h, w);
        back_map_for_rendered_data(h, w, :) = back_map_for_rendered_data(h + u, w + v, :);
    end
end

%% Compute distance transform
[distance_transform] = dtform(double(rendered_data));
[~, gradient_directions] = imgradient(distance_transform);

%% Compute projection
closest_data_points = cell(length(model_points), 1);
model_points_2D = cell(length(model_points), 1);
data_points_2D = cell(length(model_points), 1);

A = P(:, 1:3); b = P(:, 4);
for i = 1:length(model_points)
    q = model_points{i};
    n = A * q + b;
    n1 = n(1); n2 = n(2); n3 = n(3);
    if strcmp(view_axis, 'Y'), mx = n1/n3;
    else mx = W - n1/n3; end
    my = n2/n3; m = [mx; my];
    x = round(m(1)); y = round(m(2));
    
    model_points_2D{i} = [x; y];
    
    if x < 1 || y < 1 || x > W || y > H
        closest_data_points{i} = [];
        continue;
    end
    if (rendered_data(y, x) == 1)
        closest_data_points{i} = [];
        continue;
    else
        count = 0;
        while(rendered_data(y, x) == 0) && count < 10;
            delta_x = round(distance_transform(y, x) * cosd(gradient_directions(y, x)));
            delta_y = round(distance_transform(y, x) * sind(gradient_directions(y, x)));
            x = x - delta_x;
            y = y + delta_y;
            count = count + 1;
        end
    end
    
    data_points_2D{i} = [x; y];
    
    point = squeeze(back_map_for_rendered_data(y, x, :));
    if sum(abs(point)) == 0, continue; end
    closest_data_points{i} = point;
%     switch view_axis
%         case 'X'
%             closest_data_points{i}(1) = q(1);
%         case 'Y'
%             closest_data_points{i}(2) = q(2);
%         case 'Z'
%             closest_data_points{i}(3) = q(3);
%     end
end

