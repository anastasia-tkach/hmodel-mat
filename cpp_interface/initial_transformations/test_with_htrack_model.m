
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

%% Extract Euler angles

% T1
T1 = phalanges{2}.local(1:3, 1:3);
euler_angles = rotm2eul(T1, 'ZYX');
alpha = zeros(3, 1);
alpha(1) = euler_angles(3);
alpha(2) = euler_angles(2);
alpha(3) = euler_angles(1);
T1_test = Rz(alpha(3)) * Ry(alpha(2)) * Rx(alpha(1));

% T2
T2 = phalanges{3}.local(1:3, 1:3);
euler_angles = rotm2eul(T2, 'ZYZ');
beta = euler_angles(1);
T2_test = Rz(beta);

% T3
T3 = phalanges{4}.local(1:3, 1:3);
euler_angles = rotm2eul(T3, 'ZYZ');
gamma = euler_angles(1);
T3_test = Rz(gamma);

u = [0; 1; 0];
L = [phalanges{2}.length; phalanges{3}.length; phalanges{4}.length];

theta1 = rand(4, 1);
theta2 = rand(4, 1);
theta3 = rand(4, 1);
theta4 = rand(4, 1);
theta5 = rand(4, 1);

figure; hold on; axis off; axis equal;
[P1] = get_finger_points(theta1, dofs, phalanges, true);
[P2] = get_finger_points(theta2, dofs, phalanges, true);
[P3] = get_finger_points(theta3, dofs, phalanges, true);
[P4] = get_finger_points(theta4, dofs, phalanges, true);
[P5] = get_finger_points(theta5, dofs, phalanges, true);

alpha_theta_true = [alpha; beta; gamma; theta1; theta2; theta3; theta4; theta5];

t1 = phalanges{2}.local(1:3, 4);
t2 = phalanges{3}.local(1:3, 4);
t3 = phalanges{4}.local(1:3, 4);

%% Initial transformations
T1 = @(alpha_theta) Rz(alpha_theta(3)) * Ry(alpha_theta(2)) * Rx(alpha_theta(1));
T2 = @(alpha_theta) Rz(alpha_theta(4));
T3 = @(alpha_theta) Rz(alpha_theta(5));

%% Pose 1
RA1 = @(alpha_theta) Rx(alpha_theta(7)) * Rz(alpha_theta(6));
RB1 =  @(alpha_theta) Rx(alpha_theta(8));
RC1 =  @(alpha_theta) Rx(alpha_theta(9));
Q12 = @(alpha_theta) t1 + T1(alpha_theta) * RA1(alpha_theta) * L(1) * u;
Q13 = @(alpha_theta) t1 + T1(alpha_theta) * RA1(alpha_theta) * (t2 + T2(alpha_theta) * RB1(alpha_theta) * L(2) * u);
Q14 = @(alpha_theta) t1 + T1(alpha_theta) * RA1(alpha_theta) * (t2 + T2(alpha_theta) * RB1(alpha_theta) * (t3 + T3(alpha_theta) * RC1(alpha_theta) * L(3) * u));

% disp([P1{2}, Q12(alpha_theta_true)]);
% disp([P1{3}, Q13(alpha_theta_true)]);
% disp([P1{4}, Q14(alpha_theta_true)]);

%% Pose 2
RA2 = @(alpha_theta) Rx(alpha_theta(11)) * Rz(alpha_theta(10));
RB2 =  @(alpha_theta) Rx(alpha_theta(12));
RC2 =  @(alpha_theta) Rx(alpha_theta(13));
Q22 = @(alpha_theta) t1 + T1(alpha_theta) * RA2(alpha_theta) * L(1) * u;
Q23 = @(alpha_theta) t1 + T1(alpha_theta) * RA2(alpha_theta) * (t2 + T2(alpha_theta) * RB2(alpha_theta) * L(2) * u);
Q24 = @(alpha_theta) t1 + T1(alpha_theta) * RA2(alpha_theta) * (t2 + T2(alpha_theta) * RB2(alpha_theta) * (t3 + T3(alpha_theta) * RC2(alpha_theta) * L(3) * u));

% disp([P2{2}, Q22(alpha_theta_true)]);
% disp([P2{3}, Q23(alpha_theta_true)]);
% disp([P2{4}, Q24(alpha_theta_true)]);

%% Pose 3
RA3 = @(alpha_theta) Rx(alpha_theta(15)) * Rz(alpha_theta(14));
RB3 =  @(alpha_theta) Rx(alpha_theta(16));
RC3 =  @(alpha_theta) Rx(alpha_theta(17));
Q32 = @(alpha_theta) t1 + T1(alpha_theta) * RA3(alpha_theta) * L(1) * u;
Q33 = @(alpha_theta) t1 + T1(alpha_theta) * RA3(alpha_theta) * (t2 + T2(alpha_theta) * RB3(alpha_theta) * L(2) * u);
Q34 = @(alpha_theta) t1 + T1(alpha_theta) * RA3(alpha_theta) * (t2 + T2(alpha_theta) * RB3(alpha_theta) * (t3 + T3(alpha_theta) * RC3(alpha_theta) * L(3) * u));

% disp([P3{2}, Q32(alpha_theta_true)]);
% disp([P3{3}, Q33(alpha_theta_true)]);
% disp([P3{4}, Q34(alpha_theta_true)]);

%% Pose 4
RA4 = @(alpha_theta) Rx(alpha_theta(19)) * Rz(alpha_theta(18));
RB4 =  @(alpha_theta) Rx(alpha_theta(20));
RC4 =  @(alpha_theta) Rx(alpha_theta(21));
Q42 = @(alpha_theta) t1 + T1(alpha_theta) * RA4(alpha_theta) * L(1) * u;
Q43 = @(alpha_theta) t1 + T1(alpha_theta) * RA4(alpha_theta) * (t2 + T2(alpha_theta) * RB4(alpha_theta) * L(2) * u);
Q44 = @(alpha_theta) t1 + T1(alpha_theta) * RA4(alpha_theta) * (t2 + T2(alpha_theta) * RB4(alpha_theta) * (t3 + T3(alpha_theta) * RC4(alpha_theta) * L(3) * u));

% disp([P4{2}, Q42(alpha_theta_true)]);
% disp([P4{3}, Q43(alpha_theta_true)]);
% disp([P4{4}, Q44(alpha_theta_true)]);

%% Pose 5
RA5 = @(alpha_theta) Rx(alpha_theta(23)) * Rz(alpha_theta(22));
RB5 =  @(alpha_theta) Rx(alpha_theta(24));
RC5 =  @(alpha_theta) Rx(alpha_theta(25));
Q52 = @(alpha_theta) t1 + T1(alpha_theta) * RA5(alpha_theta) * L(1) * u;
Q53 = @(alpha_theta) t1 + T1(alpha_theta) * RA5(alpha_theta) * (t2 + T2(alpha_theta) * RB5(alpha_theta) * L(2) * u);
Q54 = @(alpha_theta) t1 + T1(alpha_theta) * RA5(alpha_theta) * (t2 + T2(alpha_theta) * RB5(alpha_theta) * (t3 + T3(alpha_theta) * RC5(alpha_theta) * L(3) * u));

% disp([P5{2}, Q52(alpha_theta_true)]);
% disp([P5{3}, Q53(alpha_theta_true)]);
% disp([P5{4}, Q54(alpha_theta_true)]);

%% Objective function
f = @(alpha_theta) [
    P1{2} - Q12(alpha_theta); P1{3} - Q13(alpha_theta); P1{4} - Q14(alpha_theta); ... 
    P2{2} - Q22(alpha_theta); P2{3} - Q23(alpha_theta); P2{4} - Q24(alpha_theta); ... 
    P3{2} - Q32(alpha_theta); P3{3} - Q33(alpha_theta); P3{4} - Q34(alpha_theta); ... 
    P4{2} - Q42(alpha_theta); P4{3} - Q43(alpha_theta); P4{4} - Q44(alpha_theta); ... 
    P5{2} - Q52(alpha_theta); P5{3} - Q53(alpha_theta); P5{4} - Q54(alpha_theta)];

%disp(f(alpha_theta_true));

alpha_theta0 = rand(length(alpha_theta_true), 1);
lb = -pi/2 * ones(length(alpha_theta_true), 1);
ub = pi/2 * ones(length(alpha_theta_true), 1);
lb(4:5) = - pi/7; ub(4:5) = pi/7;

[alpha_theta_ls] = lsqnonlin(f, alpha_theta0, lb, ub);

%disp([alpha_theta_true, alpha_theta_ls])

mypoint(Q12(alpha_theta_ls), 'k'); mypoint(Q13(alpha_theta_ls), 'k'); mypoint(Q14(alpha_theta_ls), 'k'); 
mypoint(Q22(alpha_theta_ls), 'k'); mypoint(Q23(alpha_theta_ls), 'k'); mypoint(Q24(alpha_theta_ls), 'k'); 
mypoint(Q32(alpha_theta_ls), 'k'); mypoint(Q33(alpha_theta_ls), 'k'); mypoint(Q34(alpha_theta_ls), 'k');
mypoint(Q42(alpha_theta_ls), 'k'); mypoint(Q43(alpha_theta_ls), 'k'); mypoint(Q44(alpha_theta_ls), 'k'); 
mypoint(Q52(alpha_theta_ls), 'k'); mypoint(Q53(alpha_theta_ls), 'k'); mypoint(Q54(alpha_theta_ls), 'k'); 

%% Test pose

theta_test = rand(4, 1);
T1_ls = T1(alpha_theta_ls);
T2_ls = T2(alpha_theta_ls);
T3_ls = T3(alpha_theta_ls);

[P] = get_finger_points(theta_test, dofs, phalanges, true);
RA = @(theta) Rx(theta(2)) * Rz(theta(1));
RB =  @(theta) Rx(theta(3));
RC =  @(theta) Rx(theta(4));
Q2 = @(theta) t1 + T1_ls * RA(theta) * L(1) * u;
Q3 = @(theta) t1 + T1_ls * RA(theta) * (t2 + T2_ls * RB(theta) * L(2) * u);
Q4 = @(theta) t1 + T1_ls * RA(theta) * (t2 + T2_ls * RB(theta) * (t3 + T3_ls * RC(theta) * L(3) * u));

f = @(theta) [P{2} - Q2(theta); P{3} - Q3(theta); P{4} - Q4(theta)];

%disp(f(theta_test));

theta0 = rand(length(theta_test), 1);
lb = -pi/2 * ones(length(theta_test), 1);
ub = pi/2 * ones(length(theta_test), 1);
[theta_ls] = lsqnonlin(f, theta0, lb, ub);

mypoint(Q2(theta_ls), 'y'); mypoint(Q3(theta_ls), 'y'); mypoint(Q4(theta_ls), 'y'); hold on;

%% Posing
M1 = eye(D + 1, D + 1);
M1(1:3, 1:3) = T1(alpha_theta_ls);
M1(1:3, 4) = t1;

M2 = eye(D + 1, D + 1);
M2(1:3, 1:3) = T2(alpha_theta_ls);
M2(1:3, 4) = t2;

M3 = eye(D + 1, D + 1);
M3(1:3, 1:3) = T3(alpha_theta_ls);
M3(1:3, 4) = t3;

phalanges{2}.local = M1;
phalanges{3}.local = M2;
phalanges{4}.local = M3;

points = get_finger_points(alpha_theta_ls(6:9), dofs, phalanges, false);
mypoints(points, 'm');
points = get_finger_points(alpha_theta_ls(10:13), dofs, phalanges, false);
mypoints(points, 'm');
points = get_finger_points(alpha_theta_ls(14:17), dofs, phalanges, false);
mypoints(points, 'm');
points = get_finger_points(alpha_theta_ls(18:21), dofs, phalanges, false);
mypoints(points, 'm');
points = get_finger_points(alpha_theta_ls(22:25), dofs, phalanges, false);
mypoints(points, 'm');

