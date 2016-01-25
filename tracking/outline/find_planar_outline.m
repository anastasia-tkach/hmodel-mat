function [outline] = find_planar_outline(centers, blocks, radii, verbose)

epsilon = 1e-9;

%% Flatten the model
blocks3D = blocks;
blocks = {};
for i = 1:length(blocks3D)
    indices = nchoosek(blocks3D{i}, 2);
    index1 = indices(:, 1); index2 = indices(:, 2);
    for j = 1:length(index1)
        blocks{end + 1} = [index1(j), index2(j)];
    end
end

%% Find intersections
[points, circles, segments] = find_outline_intersections(centers, radii, blocks);

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
while first || k ~= k_start;
    first = false;
    outline{count}.start = points{k}.value;
    %% Circle
    if type == 1
        outline{count}.indices = i;        
        [k, type, i, v] = find_closest_on_circle(circles, segments, points, i, k);
        %% Sement
    else
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
    
    if count == 100, break; end
end



%% Display planar outline
if ~verbose, return; end

figure; hold on; axis off; axis equal;
set(gcf,'color','w');
for i = 1:length(circles)
    if ~isstruct(circles{i}), continue; end
    draw_circle(circles{i}.center, circles{i}.radius, 'c');
end
for i = 1:length(segments)
    myline(segments{i}.t1, segments{i}.t2, 'c');
end

for i = 1:length(outline)
    if length(outline{i}.indices) == 2
        myline(outline{i}.start, outline{i}.end, 'm');
    else
        draw_circle_sector(circles{outline{i}.indices}.center, circles{outline{i}.indices}.radius, outline{i}.start, outline{i}.end, 'm')
    end
end

