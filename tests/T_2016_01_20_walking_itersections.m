close all;
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

%% Find intersections
[points, circles, segments] = find_outline_intersections(centers, radii, blocks);

%% Display
figure; hold on; axis off; axis equal;
set(gcf,'color','w');
for i = 1:length(centers)
    draw_circle(centers{i}, radii{i}, 'b');
end
for i = 1:length(segments)
    myline(segments{i}.t1, segments{i}.t2, 'b');
end
for i = 1:length(points)
    if points{i}.type1 == 1 && points{i}.type2 == 1
        mypoint(points{i}.value, 'y');
    end
    if points{i}.type1 == 1 && points{i}.type2 == 2
        mypoint(points{i}.value, 'y');
    end
    if points{i}.type1 == 2 && points{i}.type2 == 2
        mypoint(points{i}.value, 'y');
    end
end

%% Find start
max_y = -Inf;
k = 0;
for i = 1:length(points)
    if points{i}.value(2) > max_y
        max_y = points{i}.value(2);
        k = i;
    end
end
disp('top points can be inside');
mypoint(points{k}.value, 'b');

outline = cell(0, 1);
count = 1;
u = [0; 1];
if points{k}.type1 == 1 && points{k}.type2 == 2
    p1 = points{k}.value;
    if abs(segments{points{k}.i2}.t1 - p1) < epsilon;
        p2 = segments{points{k}.i2}.t2;
    else
        p2 = segments{points{k}.i2}.t1;
    end
    mypoint(p1, 'k'); mypoint(p2, 'k');
    v = p2 - p1;
    alpha = myatan2(u, true);
    beta1 = myatan2(v, true);
    beta2 =  myatan2(-v, true);
    while beta1 < alpha
        beta1 = beta1 + 2 * pi;
    end
    while beta2 < alpha
        beta2 = beta2 + 2 * pi;
    end
    delta1 =  beta1 - alpha;
    delta2 =  beta2 - alpha;
    if delta2 < delta1
        disp('circle')
        i = points{k}.i1;
        type = 1;
        u = -v;
    else
        disp('segment');
        i = points{k}.i2;
        type = 2;
        u = v;
    end
end

%% Walk

if type == 1
    draw_circle(centers{i}, radii{i}, 'g');
    k = find_closest_on_circle(circles, centers, points, i, k);
    v = find_init_direction(points{k}, segments);
    mypoint(points{k}.value, 'k');
    %myvector(points{k}.value, v, 1, 'g');
end
if type == 2    
    v = find_init_direction(points{k}, segments); 
    min_delta = Inf;
    for j = 1:length(segments{i}.points)
        u = points{segments{i}.points(j)}.value - points{k}.value;
        delta = norm(u);
        if u' * v < 0, continue; end
        if delta > - epsilon && delta < epsilon, continue; end        
        if delta < min_delta
            min_delta = delta;
            k = segments{i}.points(j);
        end
    end 
    mypoint(points{k}.value, 'g');
end
