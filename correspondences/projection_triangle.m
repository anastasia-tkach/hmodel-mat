function [index, q] = projection_triangle(p, c1, c2, c3, index1, index2, index3)

%% Compute projection to a convtriangle
[q, index] = closest_point_in_triangle_mex(c1, c2, c3, p, index1, index2, index3);



