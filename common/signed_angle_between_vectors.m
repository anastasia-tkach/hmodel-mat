function [angle] = signed_angle_between_vectors(a, b, n)

angle = atan2(norm(cross(a,b)), dot(a,b));
if cross(a, b)' * n < 0
   angle = -angle;
end