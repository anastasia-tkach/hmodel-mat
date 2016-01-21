function [v] = find_init_direction(point, segments)
epsilon = 1e-9;
segment_id = point.i2;
p1 = point.value;
if abs(segments{segment_id}.t1 - p1) < epsilon
    p2 = segments{segment_id}.t2;
else p2 = segments{segment_id}.t1;
end
v = p2 - p1;