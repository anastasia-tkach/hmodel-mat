close all
epsilon = 1e-9;
[centers, radii, blocks] = get_random_convquad();

centers3D = centers;
blocks3D = blocks;
blocks = {};
for i = 1:length(blocks3D)
    indices = nchoosek(blocks3D{i}, 2);
    index1 = indices(:, 1); index2 = indices(:, 2);
    for j = 1:length(index1)
        blocks{end + 1} = [index1(j), index2(j)];
    end
end

for i = 1:length(centers)
    centers{i} = centers{i}(1:2);
end

points = cell(0, 1);
circles_map = cell(length(centers), 1);
count = 1;
for i = 1:length(blocks)
    [l1, l2, r1, r2] = get_tangents(centers{blocks{i}(1)}, centers{blocks{i}(2)}, radii{blocks{i}(1)}, radii{blocks{i}(2)});
    if isempty(l1), continue; end
    
    %% Store l1/l2
    points{count}.start = l1;
    points{count}.end = l2;
    points{count}.indices = [blocks{i}(1), blocks{i}(2)];
    points{count}.end_index = count + 1;
    circles_map{blocks{i}(1)} = [circles_map{blocks{i}(1)}, count];
    count = count + 1;
    
    points{count}.start = l2;
    points{count}.end = l1;
    points{count}.indices = [blocks{i}(2), blocks{i}(1)];
    points{count}.end_index = count - 1;
    circles_map{blocks{i}(2)} = [circles_map{blocks{i}(2)}, count];
    count = count + 1;
    
    %% Store r1/r2
    points{count}.start = r1;
    points{count}.end = r2;
    points{count}.indices = [blocks{i}(1), blocks{i}(2)];
    points{count}.end_index = count + 1;
    circles_map{blocks{i}(1)} = [circles_map{blocks{i}(1)}, count];
    count = count + 1;
    
    points{count}.start = r2;
    points{count}.end = r1;
    points{count}.indices = [blocks{i}(2), blocks{i}(1)];
    points{count}.end_index = count - 1;
    circles_map{blocks{i}(2)} = [circles_map{blocks{i}(2)}, count];
    count = count + 1;
    
end

%% Find the top point
max_y = -Inf;
ip_next = 0;
for i = 1:length(points)
    if points{i}.start(2) > max_y
        max_y = points{i}.start(2);
        ip_next = i;
    end
    
end
%% Display
figure; hold on; axis off; axis equal;
for i = 1:length(centers)
    draw_circle(centers{i}, radii{i}, 'c');
end
for i = 1:length(points)
    myline(points{i}.start, points{i}.end, 'g');
end
mypoint(points{ip_next}.start, 'm');

%% Traverse the projection
num_iters = 10;
start_iter = 1;
outline = cell(length(num_iters));

v = points{ip_next}.end - points{ip_next}.start;
if atan2(v(1), v(2)) < atan2(-v(1), -v(2))
    ip_next = points{ip_next}.end_index;
    outline{1} = points{ip_next};
    myline(outline{end}.start, outline{end}.end, 'm');
end
for iter = start_iter:num_iters
    ip = ip_next;
    min_delta = Inf;
    c = points{ip}.indices(1);
    
    v = points{ip}.start - centers{c};
    %myvector(centers{c}, v, 1, 'c')
    alpha = atan2(v(2), v(1));
    if alpha < 0, alpha = alpha + 2 * pi; end
    disp(alpha * 180 / pi);
    for i = 1:length(circles_map{c})
        u = points{circles_map{c}(i)}.start - centers{c};
        %myvector(centers{c}, u, 1, 'y')
        beta = atan2(u(2), u(1));
        while beta < alpha
            beta = beta + 2 * pi; 
        end
        disp(beta * 180 / pi);
        delta =  beta - alpha;
        if delta > - epsilon && delta < epsilon, continue; end
        if delta < min_delta            
            min_delta = delta;
            ip_next = circles_map{c}(i);
        end
    end
    
    outline{end + 1}.start = points{ip}.start;
    outline{end}.end = points{ip_next}.start;
    outline{end}.indices = c;
    draw_circle_sector(centers{outline{end}.indices}, radii{outline{end}.indices}, outline{end}.start, outline{end}.end, 'm')
    
    outline{end + 1}.start = points{ip_next}.start;
    outline{end}.end = points{ip_next}.end;
    outline{end}.indices = points{ip_next}.indices;
    myline(outline{end}.start, outline{end}.end, 'm');
    ip_next = points{ip_next}.end_index;

end

for i = 1:length(outline)
    if isempty(outline{i}), continue; end
    if length(outline{i}.indices) == 2
        myline(outline{i}.start, outline{i}.end, 'm');
    else
        draw_circle_sector(centers{outline{i}.indices}, radii{outline{i}.indices}, outline{i}.start, outline{i}.end, 'm')
    end
end
