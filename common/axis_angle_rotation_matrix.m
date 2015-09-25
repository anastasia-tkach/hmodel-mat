function [R] = axis_angle_rotation_matrix(rotation_axis, alpha)

if strcmp(rotation_axis, 'x')
    R = [1, 0, 0;
        0, cos(alpha), -sin(alpha);
        0, sin(alpha), cos(alpha)];
end

if strcmp(rotation_axis, 'y')
    R = [cos(alpha), 0, sin(alpha);
        0, 1, 0;
        -sin(alpha), 0, cos(alpha)];
end

if strcmp(rotation_axis, 'z')
    R = [cos(alpha), -sin(alpha), 0;
        sin(alpha), cos(alpha), 0;
        0, 0, 1];
end
