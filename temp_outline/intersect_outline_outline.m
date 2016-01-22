function [t1, t2] = intersect_outline_outline(centers, radii, outline1, outline2)

t1 = []; t2 = [];

if length(outline1.indices) == 1 && length(outline2.indices) == 1
    c1 = centers{outline1.indices}(1:2);
    r1 = radii{outline1.indices};
    p1 = outline1.start;
    q1 = outline1.end;
    c2 = centers{outline2.indices}(1:2);
    r2 = radii{outline2.indices};
    p2 = outline2.start;
    q2 = outline2.end;
    [t1, t2] = intersect_arc_arc(c1, r1, p1, q1, c2, r2, p2, q2);
end
if length(outline1.indices) == 1 && length(outline2.indices) == 2
    c = centers{outline1.indices}(1:2);
    r = radii{outline1.indices};
    a = outline1.start;
    b = outline1.end;
    p = outline2.start;
    q = outline2.end;
    [t1, t2] = intersect_arc_segment(p, q, c, r, a, b);   
end
if length(outline1.indices) == 2 && length(outline2.indices) == 1
    c = centers{outline2.indices}(1:2);
    r = radii{outline2.indices};
    a = outline2.start;
    b = outline2.end;
    p = outline1.start;
    q = outline1.end;
    [t1, t2] = intersect_arc_segment(p, q, c, r, a, b);    
end
if length(outline1.indices) == 2 && length(outline2.indices) == 2
    a = outline1.start;
    b = outline1.end;
    c = outline2.start;
    d = outline2.end;
    t1 = intersect_segment_segment(a, b, c, d);    
end