function [points] = get_finger_points(theta, dofs, phalanges, display)

parameters = [0, 0, 0, 0, 0, 0, 0, 0, 0, theta'];
phalanges = htrack_move(parameters, dofs, phalanges);

start2 = transform([0; 0; 0], phalanges{2}.global);
end2 = transform([0; phalanges{2}.length; 0], phalanges{2}.global);

start3 = transform([0; 0; 0], phalanges{3}.global);
end3 = transform([0; phalanges{3}.length; 0], phalanges{3}.global);

start4 = transform([0; 0; 0], phalanges{4}.global);
end4 = transform([0; phalanges{4}.length; 0], phalanges{4}.global);

points = {start2, end2, end3, end4};

if (display)
    myline(start2, end2, 'b');
    myline(start3, end3, 'g');
    myline(start4, end4, 'r');
end
