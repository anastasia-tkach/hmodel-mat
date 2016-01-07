%{
The signed rotation angle between two vectors only makes sence of we have a
notion of direction, like plane normal or something. Otherwise, there is
two sides to look from which give the angles (alpha) and (pi - alpha)
%}

clc; clear;

axis = randn(3, 1); axis = axis/norm(axis);

initial_angle = randn;
axis_angle = [axis; initial_angle];
R = vrrotvec2mat(axis_angle);
 
normal = axis;

%% Create vectors
%{
The vectors should be orthogonal to the rotation axis, otherwise 
there will be another rotation axis corresponding smaller rotaion angle
%}
a = randn(3, 1);
a = a - (axis' * a) * axis;
b = R * a;

found_angle = atan2(norm(cross(a,b)), dot(a,b));
if cross(a, b)' * normal < 0
   found_angle = -found_angle;
end

initial_angle 
found_angle