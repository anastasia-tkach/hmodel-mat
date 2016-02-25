function [q, s] = project_skewed_point_on_triangle(p, c1, c2, c3, tangent_points, camera_ray)

verbose = false;

% if camera_ray' * tangent_points.n < 0
%     n = tangent_points.n;
%     v1 = tangent_points.v1; v2 = tangent_points.v2; v3 = tangent_points.v3;
% else if camera_ray' * tangent_points.m < 0
%     n = tangent_points.m;
%     v1 = tangent_points.u1; v2 = tangent_points.u2; v3 = tangent_points.u3;
%     tangent_points.v1 = v1; tangent_points.v2 = v2; tangent_points.v3 = v3;
%     else
%         q = [];
%         s = [];
%         index = [];
%         return;
%     end
% end

%% Compute skewed distance to triangle
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
end
if f1 && ~f2
    q = q1; s = s1;
end
if f2 && ~f1
    q = q2; s = s2;
end
if ~f1 && ~f2   
    q = []; s = [];
end

