
clear; clc; close;
D = 3;
[phalanges, dofs] = thumb_parameters();

%% Generate test
Rx = @(alpha) [1, 0, 0;
    0, cos(alpha), -sin(alpha);
    0, sin(alpha), cos(alpha)];

Ry = @(alpha) [cos(alpha), 0, sin(alpha);
    0, 1, 0
    -sin(alpha), 0, cos(alpha)];

Rz = @(alpha)[cos(alpha), -sin(alpha), 0;
    sin(alpha), cos(alpha), 0;
    0, 0, 1];

T = phalanges{2}.local(1:3, 1:3);
euler_angles = rotm2eul(T, 'ZYX');
alpha = zeros(3, 1);
alpha(1) = euler_angles(3);
alpha(2) = euler_angles(2);
alpha(3) = euler_angles(1);
T2 = Rz(alpha(3)) * Ry(alpha(2)) * Rx(alpha(1));

u = [1; 0; 0];

theta1 = rand(2, 1);
theta2 = rand(2, 1);
theta3 = rand(2, 1);
theta4 = rand(2, 1);
theta5 = rand(2, 1);
theta6 = rand(2, 1);

figure; hold on; axis off; axis equal; hold on;
[n1, points1] = get_finger_plane([theta1; 1; 1], dofs, phalanges, true);
[n2, points2] = get_finger_plane([theta2; 1; 1], dofs, phalanges, true);
[n3, points3] = get_finger_plane([theta3; 1; 1], dofs, phalanges, true);
[n4, points4] = get_finger_plane([theta4; 1; 1], dofs, phalanges, true);
[n5, points5] = get_finger_plane([theta5; 1; 1], dofs, phalanges, true);
[n6, points6] = get_finger_plane([theta5; 1; 1], dofs, phalanges, true);

alpha_theta_true = [alpha; theta1; theta2; theta3; theta4; theta5; theta6];

T = @(alpha_theta) Rz(alpha_theta(3)) * Ry(alpha_theta(2)) * Rx(alpha_theta(1));
R1 = @(alpha_theta) Rx(alpha_theta(5)) * Rz(alpha_theta(4));
R2 = @(alpha_theta) Rx(alpha_theta(7)) * Rz(alpha_theta(6));
R3 = @(alpha_theta) Rx(alpha_theta(9)) * Rz(alpha_theta(8));
R4 = @(alpha_theta) Rx(alpha_theta(11)) * Rz(alpha_theta(10));
R5 = @(alpha_theta) Rx(alpha_theta(13)) * Rz(alpha_theta(12));
R6 = @(alpha_theta) Rx(alpha_theta(15)) * Rz(alpha_theta(14));

m1 = @(alpha_theta) T(alpha_theta) * R1(alpha_theta) * u;
m2 = @(alpha_theta) T(alpha_theta) * R2(alpha_theta) * u;
m3 = @(alpha_theta) T(alpha_theta) * R3(alpha_theta) * u;
m4 = @(alpha_theta) T(alpha_theta) * R4(alpha_theta) * u;
m5 = @(alpha_theta) T(alpha_theta) * R5(alpha_theta) * u;
m6 = @(alpha_theta) T(alpha_theta) * R6(alpha_theta) * u;

if (n1' * m1(alpha_theta_true) < 0), n1 = -n1; end
if (n2' * m2(alpha_theta_true) < 0), n2 = -n2; end
if (n3' * m3(alpha_theta_true) < 0), n3 = -n3; end
if (n4' * m4(alpha_theta_true) < 0), n4 = -n4; end
if (n5' * m5(alpha_theta_true) < 0), n5 = -n5; end
if (n6' * m6(alpha_theta_true) < 0), n6 = -n6; end

% m4 = T(alpha_theta_true) * R4(alpha_theta_true) * u;
% disp([n4, m4]);
% parameters = [0, 0, 0, 0, 0, 0, 0, 0, 0, theta1', 1, 1];
% phalanges = htrack_move(parameters, dofs, phalanges);
% myvector(phalanges{2}.global(1:3, 4), n4, 10, 'k');
% myvector(phalanges{2}.global(1:3, 4), m4, 10, 'm');

f = @(alpha_theta) [n1 - m1(alpha_theta); n2 - m2(alpha_theta); n3 - m3(alpha_theta); n4 - m4(alpha_theta); n5 - m5(alpha_theta); n6 - m6(alpha_theta)];
disp(f(alpha_theta_true));
alpha_theta0 = rand(length(alpha_theta_true), 1);
[alpha_theta_ls, resnorm] = lsqnonlin(f, alpha_theta0, -pi/2 * ones(length(alpha_theta_true), 1), pi/2 * ones(length(alpha_theta_true), 1));

disp([alpha_theta_true, alpha_theta_ls])

phalanges = htrack_move(zeros(13, 1), dofs, phalanges);
draw_plane(phalanges{2}.global(1:3, 4), m1(alpha_theta_ls), 'm', points1);
draw_plane(phalanges{2}.global(1:3, 4), m2(alpha_theta_ls), 'm', points2);
draw_plane(phalanges{2}.global(1:3, 4), m3(alpha_theta_ls), 'm', points3);
draw_plane(phalanges{2}.global(1:3, 4), m4(alpha_theta_ls), 'm', points4);
draw_plane(phalanges{2}.global(1:3, 4), m5(alpha_theta_ls), 'm', points5);
draw_plane(phalanges{2}.global(1:3, 4), m6(alpha_theta_ls), 'm', points6);


