function [points, circles, segments] = find_outline_intersections(centers, radii, blocks)

%% Circle-segment tangency
circles = cell(length(centers), 1);
for i = 1:length(circles), circles{i}.points = []; end
segments = cell(0, 1);
points = cell(0, 1);
count = 1;
for i = 1:length(blocks)
    [l1, l2, r1, r2] = get_tangents(centers{blocks{i}(1)}, centers{blocks{i}(2)}, radii{blocks{i}(1)}, radii{blocks{i}(2)});
    if isempty(l1), continue; end
    
    %% Store l1/l2
    points{count}.value = l1;
    points{count}.i1 = blocks{i}(1);
    points{count}.type1 = 1;
    points{count}.i2 = (count + 1)/2;
    points{count}.type2 = 2;
    circles{blocks{i}(1)}.points = [circles{blocks{i}(1)}.points, count];
    count = count + 1;
    
    points{count}.value = l2;
    points{count}.i1 = blocks{i}(2);
    points{count}.type1 = 1;
    points{count}.i2 = count/2;
    points{count}.type2 = 2;
    circles{blocks{i}(2)}.points = [circles{blocks{i}(2)}.points, count];
    count = count + 1;
    
    k = (count - 1)/2;
    segments{k}.t1 = l1;
    segments{k}.t2 = l2;
    segments{k}.indices = [blocks{i}(1), blocks{i}(2)];
    segments{k}.points = [count - 2, count - 1];    
        
    %% Store r1/r2
    points{count}.value = r1;
    points{count}.i1 = blocks{i}(1);
    points{count}.type1 = 1;
    points{count}.i2 = (count + 1)/2;
    points{count}.type2 = 2;
    circles{blocks{i}(1)}.points = [circles{blocks{i}(1)}.points, count];
    count = count + 1;
    
    points{count}.value = r2;
    points{count}.i1 = blocks{i}(2);
    points{count}.type1 = 1;
    points{count}.i2 = count/2;
    points{count}.type2 = 2;
    circles{blocks{i}(2)}.points = [circles{blocks{i}(2)}.points, count];
    count = count + 1;
    
    k = (count - 1)/2;
    segments{k}.t1 = r1;
    segments{k}.t2 = r2;
    segments{k}.indices = [blocks{i}(1), blocks{i}(2)];
    segments{k}.points = [count - 2, count - 1];
end

%% Circle-circle intersections
for i = 1:length(centers)    
    for j = i + 1:length(centers)       
        [t1, t2] = intersect_circle_circle(centers{i}, radii{i}, centers{j}, radii{j});
        if isempty(t1), continue; end
        points{count}.value = t1;
        points{count}.i1 = i;
        points{count}.type1 = 1;
        points{count}.i2 = j;
        points{count}.type2 = 1;
        
        circles{i}.points = [circles{i}.points, count];
        circles{j}.points = [circles{j}.points, count];
        count = count + 1;
        
        points{count}.value = t2;
        points{count}.i1 = i;
        points{count}.type1 = 1;
        points{count}.i2 = j;
        points{count}.type2 = 1;
        circles{i}.points = [circles{i}.points, count];
        circles{j}.points = [circles{j}.points, count];
        count = count + 1;
    end
end

%% Circle-segment intersecitons
for i = 1:length(centers)
    for j = 1:length(segments)
        if ismember(i, segments{j}.indices), continue; end
        [t1, t2] = intersect_circle_segment(segments{j}.t1, segments{j}.t2, centers{i}, radii{i});
        if ~isempty(t1),
            points{count}.value = t1;
            points{count}.i1 = i;
            points{count}.type1 = 1;
            points{count}.i2 = j;
            points{count}.type2 = 2;
            circles{i}.points = [circles{i}.points, count];
            segments{j}.points = [segments{j}.points, count];
            count = count + 1;
        end
        
        if ~isempty(t2),
            points{count}.value = t2;
            points{count}.i1 = i;
            points{count}.type1 = 1;
            points{count}.i2 = j;
            points{count}.type2 = 2;
            circles{i}.points = [circles{i}.points, count];
            segments{j}.points = [segments{j}.points, count];
            count = count + 1;
        end
    end
end

%% Segment-segment intersection
for i = 1:length(segments)
    for j = i + 1:length(segments)
        t = intersect_segment_segment(segments{i}.t1, segments{i}.t2, segments{j}.t1, segments{j}.t2);
        if isempty(t), continue; end
        points{count}.value = t;
        points{count}.i1 = i;
        points{count}.type1 = 2;
        points{count}.i2 = j;
        points{count}.type2 = 2;
        segments{i}.points = [segments{i}.points, count];
        segments{j}.points = [segments{j}.points, count];
        count = count + 1;
    end
end



