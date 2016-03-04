function [points, circles, segments] = find_outline_intersections(centers, radii, blocks, blocks_indices)

%% Circle-segment tangency
circles = cell(length(centers), 1);
%for i = 1:length(circles), circles{i}.points = []; end
segments = cell(0, 1);
points = cell(0, 1);
count = 1;
for b = 1:length(blocks_indices)
    block = blocks{blocks_indices(b)};
    if length(block) == 3
        c1 = centers{block(1)}; c2 = centers{block(2)}; c3 = centers{block(3)};
        r1 = radii{block(1)}; r2 = radii{block(2)}; r3 = radii{block(3)};
        
        [lt1, lt2, rt1, rt2] = get_tangents(c1, c2, r1, r2);
        if ~isempty(lt1) && ~isempty(lt2) && ~isempty(rt1) && ~isempty(rt2)
            d1 = point_to_segment(c3(1:2), lt1, lt2);
            d2 = point_to_segment(c3(1:2), rt1, rt2);
            if d1 > d2,
                [points, segments, circles, count] = ...
                    store_circle_segment_tangents(centers, radii, block(1), block(2), points, segments, circles, lt1, lt2, count, blocks_indices(b));
            else
                [points, segments, circles, count] = ...
                    store_circle_segment_tangents(centers, radii, block(1), block(2), points, segments, circles, rt1, rt2, count, blocks_indices(b));
            end
        end
        
        [lt1, lt2, rt1, rt2] = get_tangents(c1, c3, r1, r3);
        if ~isempty(lt1) && ~isempty(lt2) && ~isempty(rt1) && ~isempty(rt2)
            d1 = point_to_segment(c2(1:2), lt1, lt2);
            d2 = point_to_segment(c2(1:2), rt1, rt2);
            if d1 > d2,
                [points, segments, circles, count] = ...
                    store_circle_segment_tangents(centers, radii, block(1), block(3), points, segments, circles, lt1, lt2, count, blocks_indices(b));
            else
                [points, segments, circles, count] = ...
                    store_circle_segment_tangents(centers, radii, block(1), block(3), points, segments, circles, rt1, rt2, count, blocks_indices(b));
            end
        end
        
        [lt1, lt2, rt1, rt2] = get_tangents(c2, c3, r2, r3);
        if ~isempty(lt1) && ~isempty(lt2) && ~isempty(rt1) && ~isempty(rt2)
            d1 = point_to_segment(c1(1:2), lt1, lt2);
            d2 = point_to_segment(c1(1:2), rt1, rt2);
            if d1 > d2,
                [points, segments, circles, count] = ...
                    store_circle_segment_tangents(centers, radii, block(2),block(3), points, segments, circles, lt1, lt2, count, blocks_indices(b));
            else
                [points, segments, circles, count] = ...
                    store_circle_segment_tangents(centers, radii, block(2),block(3), points, segments, circles, rt1, rt2, count, blocks_indices(b));
            end
        end
    end
    
    if length(block) == 2
        [lt1, lt2, rt1, rt2] = get_tangents(centers{block(1)}, centers{block(2)}, radii{block(1)}, radii{block(2)});
        if ~isempty(lt1) && ~isempty(lt2) && ~isempty(rt1) && ~isempty(rt2)
            [points, segments, circles, count] = ...
                store_circle_segment_tangents(centers, radii, block(1), block(2), points, segments, circles, lt1, lt2, count, blocks_indices(b));
            [points, segments, circles, count] = ...
                store_circle_segment_tangents(centers, radii, block(1), block(2), points, segments, circles, rt1, rt2, count, blocks_indices(b));
        end
    end
end

% print_points(points);
% print_segments(segments);
% print_circles(circles);

%% Circle-circle intersections
for i = 1:length(circles)
    if ~isstruct(circles{i}), continue; end;
    for j = i + 1:length(circles)
        if ~isstruct(circles{j}), continue; end;
        [t1, t2] = intersect_circle_circle(circles{i}.center, circles{i}.radius, circles{j}.center, circles{j}.radius);
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

% print_points(points);
% print_segments(segments);
% print_circles(circles);

%% Circle-segment intersecitons
for i = 1:length(circles)
    if ~isstruct(circles{i}), continue; end
    for j = 1:length(segments)
        if ismember(i, segments{j}.indices), continue; end
        %if i == 18 && j == 1
        %   disp (' ');
        %end
        [t1, t2] = intersect_circle_segment(segments{j}.t1, segments{j}.t2, circles{i}.center, circles{i}.radius);
        if ~isempty(t1),
            points{count}.value = t1;
            points{count}.i1 = i;
            points{count}.type1 = 1;
            points{count}.i2 = j;
            points{count}.type2 = 2;
            circles{i}.points = [circles{i}.points, count];
            segments{j}.points = [segments{j}.points, count];           
            %disp(count - 1); print_points(points(count));
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
            %disp(count - 1); print_points(points(count));
            count = count + 1;           
        end
    end
end

% print_points(points);
% print_segments(segments);
% print_circles(circles);

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

% print_points(points);
% print_segments(segments);
% print_circles(circles);

end

function [points, segments, circles, count] = store_circle_segment_tangents(centers, radii, i1, i2, points, segments, circles, t1, t2, count, b)

%% Store l1/l2
points{count}.value = t1;
points{count}.i1 = i1;
points{count}.type1 = 1;
points{count}.i2 = (count + 1)/2;
points{count}.type2 = 2;
if ~isfield(circles{i1}, 'points'), circles{i1}.points = []; end
circles{i1}.points = [circles{i1}.points, count];
circles{i1}.center = centers{i1}(1:2);
circles{i1}.radius = radii{i1};
circles{i1}.block = b;
count = count + 1;

points{count}.value = t2;
points{count}.i1 = i2;
points{count}.type1 = 1;
points{count}.i2 = count/2;
points{count}.type2 = 2;
if ~isfield(circles{i2}, 'points'), circles{i2}.points = []; end
circles{i2}.points = [circles{i2}.points, count];
circles{i2}.center = centers{i2}(1:2);
circles{i2}.radius = radii{i2};
circles{i2}.block = b;
count = count + 1;

k = (count - 1)/2;
segments{k}.t1 = t1;
segments{k}.t2 = t2;
segments{k}.indices = [i1, i2];
segments{k}.points = [count - 2, count - 1];
segments{k}.block = b;
end

function print_points(points)
disp('POINTS');
for i = 1:length(points)
    disp(['points[', num2str(i - 1), ']']);
    disp(['   value = ' num2str(points{i}.value')]);
    disp(['   type1 = ' num2str(points{i}.type1 - 1)]);
    disp(['   type2 = ' num2str(points{i}.type2 - 1)]);
    disp(['   i1 = ' num2str(points{i}.i1 - 1)]);
    disp(['   i2 = ' num2str(points{i}.i2 - 1)]);
    disp(' ');
end
end

function print_segments(segments)
disp('SEGMENTS');
for i = 1:length(segments)
    disp(['segments[', num2str(i - 1), ']']);
    disp(['   t1 = ' num2str(segments{i}.t1')]);
    disp(['   t2 = ' num2str(segments{i}.t2')]);
    disp(['   indices = ' num2str(segments{i}.indices - 1)]);
    disp(['   points = ' num2str(segments{i}.points - 1)]);
    disp(' ');
end
end


function print_circles(circles)
disp('CIRCLES');
for i = 1:length(circles)
    if isempty(circles{i}), continue; end
    disp(['circles[', num2str(i - 1), ']']);
    disp(['   center = ' num2str(circles{i}.center')]);
    disp(['   radius = ' num2str(circles{i}.radius)]);
    disp(['   points = ' num2str(circles{i}.points - 1)]);
    disp(' ');
end
end

