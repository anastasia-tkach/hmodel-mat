function [i]  = ray_triangle_intersection (p0, p1, p2, o, d)
% Ray/triangle intersection using the algorithm proposed by Möller and Trumbore (1997).
%
% Input:
%    o : origin.
%    d : direction.
%    p0, p1, p2: vertices of the triangle.
% Output:
%    flag: (0) Reject, (1) Intersect.
%    u,v: barycentric coordinates.
%    t: distance from the ray origin.
% Author:
%    Jesus Mena

epsilon = 0.00001;

e1 = p1-p0;
e2 = p2-p0;
q  = cross(d,e2);
a  = dot(e1,q); % determinant of the matrix M

if (a>-epsilon && a<epsilon)
    % the vector is parallel to the plane (the intersection is at infinity)
    i = Inf * ones(3, 1);
    return;
end;

f = 1/a;
s = o-p0;
u = f*dot(s,q);

if (u<0.0)
    % the intersection is outside of the triangle
    i = Inf * ones(3, 1);
    return;
end;

r = cross(s,e1);
v = f*dot(d,r);

if (v<0.0 || u+v>1.0)
    % the intersection is outside of the triangle
    i = Inf * ones(3, 1);
    return;
end;

t = f*dot(e2,r); % verified!
i = o + t * d;
return;
end