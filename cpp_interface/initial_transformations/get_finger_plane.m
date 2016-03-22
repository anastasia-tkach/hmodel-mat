function [n, points] = get_finger_plane(theta, dofs, phalanges, display)

parameters = [0, 0, 0, 0, 0, 0, 0, 0, 0, theta'];
phalanges = htrack_move(parameters, dofs, phalanges);

start2 = transform([0; 0; 0], phalanges{2}.global);
end2 = transform([0; phalanges{2}.length; 0], phalanges{2}.global);

start3 = transform([0; 0; 0], phalanges{3}.global);
end3 = transform([0; phalanges{3}.length; 0], phalanges{3}.global);

start4 = transform([0; 0; 0], phalanges{4}.global);
end4 = transform([0; phalanges{4}.length; 0], phalanges{4}.global);

points = {start2, end2, end3, end4};
[n, p, ~] = affine_fit(points);

if (display)
    %figure; hold on; axis off; axis equal;
    myline(start2, end2, 'b');
    myline(start3, end3, 'g');
    myline(start4, end4, 'r');
    draw_plane(p, n, 'c', points);
end