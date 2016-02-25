function [index, q, s, tangent_points] = projection_convtriangle_frontfacing(p, c1, c2, c3, r1, r2, r3, block, tangent_points, camera_ray)

%% Compute skewed distance to triangle

index = block;
l = cross(c2 - c1, c3 - c1); l = l/norm(l);
f1 = false; f2 = false;
if camera_ray' * tangent_points.n < 0    
    n = tangent_points.n; v1 = tangent_points.v1; v2 = tangent_points.v2; v3 = tangent_points.v3;
    if l' * n < 0, l = -l; end
    cos_alpha = l' * n;    
    distance = (p - c1)' * l;
    distance = distance / cos_alpha;
    s1 = p - n * distance;    
    if is_point_in_triangle(s1, c1, c2, c3)
        q1 = project_point_on_triangle(p, v1, v2, v3);
        f1 = true;         
    end
end

if camera_ray' * tangent_points.m < 0
    n = tangent_points.m; v1 = tangent_points.u1; v2 = tangent_points.u2; v3 = tangent_points.u3;
    if l' * n < 0, l = -l; end
    cos_alpha = l' * n;    
    distance = (p - c1)' * l;
    distance = distance / cos_alpha;
    s2 = p - n * distance;    
    if is_point_in_triangle(s2, c1, c2, c3)
        q2 = project_point_on_triangle(p, v1, v2, v3);
        f2 = true; 
    end
end

if f1 && f2
   disp('both frontfacing');
   if norm(p - q1) < norm(p - q2)
       q = q1; s = s1;
   else
       q = q2; s = s2;
   end
   return;
end
if f1 && ~f2
    q = q1; s = s1;
    return;
end
if f2 && ~f1
    q = q2; s = s2;
    return;
end

%% Compute skewed distance to segments
[q12, s12, index12] = project_skewed_point_on_segment(p, c1, c2, r1, r2, block(1), block(2));
[q13, s13, index13] = project_skewed_point_on_segment(p, c1, c3, r1, r3, block(1), block(3));
[q23, s23, index23] = project_skewed_point_on_segment(p, c2, c3, r2, r3, block(2), block(3));

%% Supress sphere projections corresponding to non-existing surface
if (length(index12) == 1 && (length(index23) == 2 || index12(1) ~= index23(1))) && ...
   (length(index12) == 1 && (length(index13) == 2 || index12(1) ~= index13(1)))
    s12 = [inf; inf; inf];
end

if (length(index23) == 1 && (length(index12) == 2 || index23(1) ~= index12(1))) ...
        && (length(index23) == 1 && (length(index13) == 2 || index23(1) ~= index13(1)))
    s23 = [inf; inf; inf];
end

if (length(index13) == 1 && (length(index12) == 2 || index13(1) ~= index12(1))) ...
        && (length(index13) == 1 && (length(index23) == 2 || index13(1) ~= index23(1)))
    s13 = [inf; inf; inf];
end

d12 = sign(norm(p - s12) - norm(q12 - s12)) * norm(p - q12);
d13 = sign(norm(p - s13) - norm(q13 - s13)) * norm(p - q13);
d23 = sign(norm(p - s23) - norm(q23 - s23)) * norm(p - q23);

s = {s12, s13, s23};
q = {q12, q13, q23};
index = {index12, index13, index23};
[~, k] = min([d12, d13, d23]);
s = s{k};
index = index{k};
q = q{k};