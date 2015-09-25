clear, clc

P1=[0 0 0]';
P2=[0 1 0]';
P3=[0.5 0.5 1]';

p0=[0 0 0.5]';
n=[0 0 1]';

[ is_intersect, intersection_coordinates ] = intersect_plane_triangle ( n, p0, P1, P2, P3);

figure; hold on;
fill3([P1(1) P2(1) P3(1)], [P1(2) P2(2) P3(2)], [P1(3) P2(3) P3(3)], 'b')
plane = createPlane(p0',n'); 
hpl = drawPlane3d(plane,'r');
scatter3(intersection_coordinates(1, :), intersection_coordinates(2, :), intersection_coordinates(3, :), 50, 'y', 'filled');
plot3(intersection_coordinates(1,:),intersection_coordinates(2,:),intersection_coordinates(3,:),'k','Linewidth',2)
daspect([1 1 1]); axis('vis3d')
set(gcf,'Renderer','OpenGL');

