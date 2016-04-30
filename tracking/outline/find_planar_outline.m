function [outline] = find_planar_outline(centers, blocks, blocks_indices, radii, verbose)

epsilon = 1e-9;

%% Find intersections
[points, circles, segments] = find_outline_intersections(centers, radii, blocks, blocks_indices);

%% Find start
up = [0; 1];
max_y = -Inf;
for j = 1:length(circles)
    if isempty(circles{j}), continue; end
    if circles{j}.center(2) + circles{j}.radius > max_y
        max_y = circles{j}.center(2) + circles{j}.radius;
        p = circles{j}.center + circles{j}.radius * up;
        i = j;
    end
end

if (max_y == -Inf)
    max_radius = 0;
    for j = 1:length(blocks_indices)
       block = blocks{blocks_indices(j)};
       for k = 1:length(block)
           if radii{block(k)} > max_radius
               max_radius = radii{block(k)};
               i = block(k);
               circles{i}.points = [];
               circles{i}.center = centers{i}(1:2);
               circles{i}.radius = radii{i};
               circles{i}.block = blocks_indices(j);
               p = circles{i}.center + circles{i}.radius * up;
           end
       end       
    end
end

min_delta = Inf;
v = p - circles{i}.center;
alpha_before = myatan2(v);
for j = 1:length(circles{i}.points)
    alpha = alpha_before;
    u = points{circles{i}.points(j)}.value - circles{i}.center;
    beta = myatan2(u);
    if alpha < beta,
        alpha = alpha + 2 * pi;
    end
    delta =  alpha - beta;
    if delta > - epsilon && delta < epsilon, continue; end
    if delta < min_delta
        min_delta = delta;
        k = circles{i}.points(j);
    end
end


%% Walk
outline = cell(0, 1);
count = 1; first = true; k_start = k; type = 1;
while first || k ~= k_start  
    first = false;
    
    if isempty(points)
        outline{count}.start = circles{i}.center + circles{i}.radius * up;
        outline{count}.indices = i;   
        outline{count}.block = circles{i}.block;
        outline{count}.end = circles{i}.center + circles{i}.radius * up;
        break;
    end
    
    outline{count}.start = points{k}.value;

    %% Circle
    if type == 1
        outline{count}.indices = i;   
        outline{count}.block = circles{i}.block;
        [k, type, i, v] = find_closest_on_circle(circles, segments, points, i, k);
        %% Sement
    else
        outline{count}.block = segments{i}.block;
        if (circles{segments{i}.indices(1)}.center - circles{segments{i}.indices(2)}.center)' * v > 0
            outline{count}.indices = segments{i}.indices;
            outline{count}.t1 = segments{i}.t1;
            outline{count}.t2 = segments{i}.t2;
        else
            outline{count}.indices = [segments{i}.indices(2), segments{i}.indices(1)];
            outline{count}.t1 = segments{i}.t2;
            outline{count}.t2 = segments{i}.t1;
        end        
        [k, type, i, v] = find_closest_on_segment(segments, points, i, k, v);  
    end
    outline{count}.end = points{k}.value;
    count = count + 1;    
    
    %print_outline(outline, count - 1);
    
    if count == 100, break; end
end


%% Display planar outline
if ~verbose, return; end

%figure; hold on; axis off; axis equal;
set(gcf,'color','w');
line_width = 4;
for i = 1:length(segments)
    myline(segments{i}.t1, segments{i}.t2, [124, 190, 184]/255, line_width);
end
for i = 1:length(circles)
    if ~isstruct(circles{i}), continue; end
    draw_circle(circles{i}.center, circles{i}.radius, [62, 127, 130]/210, line_width);
end


for i = 1:length(outline)
    if length(outline{i}.indices) == 2
        myline(outline{i}.start, outline{i}.end, [179, 81, 109]/255, line_width);
    else
        draw_circle_sector(circles{outline{i}.indices}.center, circles{outline{i}.indices}.radius, outline{i}.start, outline{i}.end, [179, 81, 109]/255, line_width)
    end
end

end

% function print_outline(outline, i)
% %for i = 1:length(outline)
%     disp(['outline[', num2str(i - 1), ']']);
%     if length(outline{i}.indices) == 2
%         disp(['   t1 = ' num2str(outline{i}.t1')]);
%         disp(['   t2 = ' num2str(outline{i}.t2')]);
%     end
%     disp(['   indices = ' num2str(outline{i}.indices - 1)]);
%     disp(['   start = ' num2str(outline{i}.start')]);
%     disp(['   end = ' num2str(outline{i}.end')]);
%     disp(' ');
% %end
% end
% 
% 
% function print_outline(outline)
% for i = 1:length(outline)
%     disp(['outline[', num2str(i - 1), ']']);
%     if length(outline{i}.indices) == 2
%         disp(['   t1 = ' num2str(outline{i}.t1')]);
%         disp(['   t2 = ' num2str(outline{i}.t2')]);
%     end
%     disp(['   indices = ' num2str(outline{i}.indices - 1)]);
%     disp(['   start = ' num2str(outline{i}.start')]);
%     disp(['   end = ' num2str(outline{i}.end')]);
%     disp(' ');
% end
% end
