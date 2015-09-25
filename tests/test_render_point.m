close all; 
H = 480;
W = 640;

fov = 15;
camera_center = [0; 1; -1];
camera_axis = [0; 0; 1];
camera_axis = camera_axis / norm(camera_axis);

%% Define the XYZ location of a point with respect to camera
% X = 2*(rand-0.5);   
% Y = 2*(rand-0.5);  
X =  1;
Y =  1;
M = [X; Y; 10];
M = M + camera_center;
%% This creates the rendered image of the point
figure('Position',[100 100 W H]);
plot3(M(1), M(2), M(3),'.');
camproj('perspective'); axis image; axis off;
set(gca, 'Units', 'pixels', 'Position', [1 1 W H]);
set(gcf, 'Color', [1 1 1]); 
camva(fov); 
campos(camera_center);  
camtarget(camera_axis);  

F = getframe(gcf);    
I = rgb2gray(F.cdata);    
% figure, imshow(I,[]), impixelinfo;

%% Plot in 3d
figure; hold on; axis equal;
mypoint(M, 'b');
mypoint(camera_center, 'r');
offset = (M - camera_center)' * camera_axis;
Q = camera_center + offset  * camera_axis;
Q1 = W / H * offset * tand(fov/2) * [1; 0; 0];
Q2 = - W / H * offset * tand(fov/2) * [1; 0; 0];
Q3 = offset * tand(fov/2) * [0; 1; 0];
Q4 = - offset * tand(fov/2) * [0; 1; 0];
myline(camera_center, Q, 'r');
myline(camera_center, Q + Q1, 'b');
myline(camera_center, Q + Q2, 'b');
myline(camera_center, Q + Q3, 'b');
myline(camera_center, Q + Q4, 'b');
myline(Q + Q1 + Q3, Q + Q1 + Q4, 'g');
myline(Q + Q1 + Q3, Q + Q2 + Q3, 'g');
myline(Q + Q2 + Q3, Q + Q2 + Q4, 'g');
myline(Q + Q2 + Q4, Q + Q1 + Q4, 'g');

%% Detect the centroid of the point in the rendered image
region = regionprops(I<255);
disp('Point detected at: '), disp(region.Centroid);




%% Calculate where I expect the point to appear
focal = h/2/tand(fov/2);
% x = focal * M(1)/M(3) + w/2 + 0.5;
% y = focal * M(2)/M(3) + h/2 + 0.5;
M = M - camera_center;
%M = [M; 1];

a = camera_axis; b = [0; 0; 1];
%R = vrrotvec2mat(vrrotvec(a, b));
%t = camera_center;
%R = eye(3, 3);
%t = zeros(3, 1);
%K = [R, -t];
A = [focal 0       W/2 + 0.5;
     0     focal   H/2 + 0.5;
     0     0       1];
P = A;
m = P * M;
m = m ./ m(3);

disp('Point should be at: '); disp([m(1), m(2)]);