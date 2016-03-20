% l1 = rand();
% l2 = rand();
% l3 = rand();
% alpha = randn(3, 1);
% theta = randn(4, 1);
clear; clc;

[phalanges, dofs] = thumb_parameters();

theta = [0.2, 0.5, 1, 1];
parameters = [0, 0, 0, 0, 0, 0, 0, 0, 0, theta];
phalanges = htrack_move(parameters, dofs, phalanges);

% for i = 1:length(phalanges)
%     disp(i);    
%     disp('global  = ');
%     disp(phalanges{i}.global);
% end

%% Display
start2 = transform([0; 0; 0], phalanges{2}.global);
end2 = transform([0; phalanges{2}.length; 0], phalanges{2}.global);

start3 = transform([0; 0; 0], phalanges{3}.global);
end3 = transform([0; phalanges{3}.length; 0], phalanges{3}.global);

start4 = transform([0; 0; 0], phalanges{4}.global);
end4 = transform([0; phalanges{4}.length; 0], phalanges{4}.global);

figure; hold on; axis off; axis equal;
myline(start2, end2, 'b');
myline(start3, end3, 'g');
myline(start4, end4, 'r');









