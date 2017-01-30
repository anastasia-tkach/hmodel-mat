function [rotated] = rotate_around_axis(rotaxis, original, alpha)

% alpha = pi/8;
% rotaxis = rand(3, 1);
% rotaxis = rotaxis / norm(rotaxis);
% original = [rotaxis(2), -rotaxis(1), 0];
% original = original / norm(original);
% origin = [0; 0; 0];

% rotaxis = rotated_frame{2};
% original = rotated_frame{1}; 

rotaxis = rotaxis / norm(rotaxis);
original = original / norm(original);

inplane = cross(rotaxis, original);
inplane = inplane / norm(inplane);
rotated = sin(alpha) * inplane + cos(alpha) * original;

rotated = rotated / norm(rotated); 

% figure; hold on;
% myline(origin, rotaxis, 'r');
% myline(origin, original, 'b');
% myline(origin, inplane, 'y');
% myline(origin, rotated, 'm');
% axis equal;



