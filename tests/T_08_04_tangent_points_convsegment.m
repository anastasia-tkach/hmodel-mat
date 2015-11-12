function [v1, v2, u1, u2] = tangent_points_convsegment(c1, c2, r1, r2, p)

beta = acos((r1 - r2) /norm(c1 - c2));
rotaxis = cross(c1 - c2, c1 - p);
l = rotate_around_axis(rotaxis, c2 - c1, beta);
v1 = c1 + r1 * l;
v2 = c2 + r2 * l;

l = rotate_around_axis(rotaxis, c2 - c1, -beta);
u1 = c1 + r1 * l;
u2 = c2 + r2 * l;

if norm(v1 - p) > norm(u1 - p)
    temp = v1; v1 = u1;  u1 = temp;   
    temp = v2; v2 = u2;  u2 = temp; 
end