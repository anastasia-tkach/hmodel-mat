function [index, q, s, is_inside] = projection_2D(p, block, radii, centers)

c1 = centers{block(1)}; c2 = centers{block(2)};
r1 = radii{block(1)}; r2 = radii{block(2)};
index1 = block(1); index2 = block(2);
[index, q, s, is_inside] = projection_convsegment_2D(p, c1, c2, r1, r2, index1, index2);
