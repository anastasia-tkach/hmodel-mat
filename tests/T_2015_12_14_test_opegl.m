clc; close all;
window_left = 0;
window_bottom = 0;
window_width = 1024;
window_height = 768;
fovy = 45;
aspect = window_width / window_height;
zNear = 0.1;
zFar = 10.0;
camera_center = [2.0, 2.0, 2.0];
image_center = [0.0, 0.0, 0.0];
camera_up = [0.0, 0.0, 1.0];

%{
world_positions = [
    -1, -1, 0;
    1, -1, 0;
    -1, 1, 0;
    1, 1, 0];
%}
world_positions =  [1, 1, 1];
N = size(world_positions, 1);

%% Projection matrix
f = 1/tand(fovy/2);
projection = [
    f/aspect, 0, 0, 0;
    0, f, 0, 0;
    0, 0, (zFar + zNear)/(zNear - zFar), (2 * zFar * zNear)/(zNear - zFar),
    0, 0, -1, 0];

%% View matrix
% image_center = [0, 0, 1];
% camera_center = [0, 0, 0];
% camera_up = [0, 1, 0];
f = image_center - camera_center; f = f/norm(f);
u = camera_up / norm(camera_up);
s = cross(f, u); s = s/norm(s);
u = cross(s, f);

view = zeros(4, 4);
view(1, :) = [s, - dot(s, camera_center)];
view(2, :) = [u, - dot(u, camera_center)];
view(3, :) = [- f, dot(f, camera_center)];
view(4, :) = [0, 0, 0 1];

%% Project GPP spec 2.1 p.41-...
model = eye(4, 4);
MVP = projection * model * view;
gl_positions = zeros(N, 4);
for i = 1:N
    gl_positions(i, :) = (MVP * [world_positions(i, :)'; 1.0])';
end

% get clip coorditanes
clip_positions = zeros(N, 3);
for i = 1:N
    clip_positions(i, :) = (gl_positions(i, 1:3) ./ gl_positions(i, 4))';
end

% apply the viewport transformation
n = 0; % specifies the mapping of the near clipping plane to window coordinates
f = 1; % specifies the mapping of the far clipping plane to window coordinates
ox = window_left + window_width/2;
oy = window_bottom + window_height/2;
window_positions = zeros(N, 3);
for i = 1:N
    xd = clip_positions(i, 1);
    yd = clip_positions(i, 2);
    zd = clip_positions(i, 3);
    window_positions(i, 1) = xd * window_width / 2 + ox;
    window_positions(i, 2) = yd * window_height / 2 + oy;
    window_positions(i, 3) = zd * (f - n) / 2 + (n + f) / 2;
end

final_positions = zeros(N, 2);
for i = 1:N
    final_positions(i, :) = uint32(window_positions(i, 1:2));
end

% figure; hold on; axis off; axis equal;
% imshow(ones(window_height, window_width));
% myline(final_positions(1, :), final_positions(2, :), 'r');
% myline(final_positions(3, :), final_positions(4, :), 'r');
% myline(final_positions(1, :), final_positions(3, :), 'r');
% myline(final_positions(2, :), final_positions(4, :), 'r');

%% Unproject
winx = final_positions(1, 1); 
winy = final_positions(1, 2); 

viewport = [0, 0; window_width, window_height];
A = projection * model * view;
M = inv(A);

%% First ray point
winz = 0;
in = zeros(4, 1);
in(1) = (winx - window_left) / window_width * 2.0 - 1.0;
in(2) = (winy - window_bottom) / window_height * 2.0 - 1.0;
in(3) = 2.0*winz - 1.0;
in(4) = 1.0;
out  = M * in;
out(4) = 1.0 / out(4);
out = out(1:3) * out(4);
p1 = out;
%% Second ray point
winz = 1;
in = zeros(4, 1);
in(1) = (winx - window_left) / window_width * 2.0 - 1.0;
in(2) = (winy - window_bottom) / window_height * 2.0 - 1.0;
in(3) = 2.0*winz - 1.0;
in(4) = 1.0;
out  = M * in;
out(4) = 1.0 / out(4);
out = out(1:3) * out(4);
p2 = out;
%% Draw
figure; hold on; axis off; axis equal;
mypoint(camera_center, 'b');
myline(p1, p2, 'r');
myline(p1, camera_center, 'g');
