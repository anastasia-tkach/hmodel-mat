clear; close all; clc
 
D = 3;
c1 = rand(D, 1);
c1 = [0; 0; 0];
c2 = rand(D, 1);
d = norm(c2 - c1);
initial = [1; 0; 0];

R = vrrotvec2mat(vrrotvec(initial, c2 - c1));
c2_ = c1 + d * R * initial;

euler_anlges = rotm2eul(R);

Rz = eul2rotm([euler_anlges(1), 0, 0]);
Ry = eul2rotm([0, euler_anlges(2), 0]);
Rx = eul2rotm([0, 0, euler_anlges(3)]);

R_ = Rz * Ry * Rx;
c2_ = c1 + d * R_ * initial;
[c2, c2_]

return





%% Compute euler angles
Rz_matlab = eul2rotm([theta(1), 0, 0]);
Ry_matlab = eul2rotm([0, theta(2), 0]);
Rx_matlab = eul2rotm([0, 0, theta(3)]);
R_test = eul2rotm(theta'); 
R_matlab = Rz_matlab * Ry_matlab * Rx_matlab;
c2 = c1 + R_matlab *  d * initial;

Rx  = @(x) [1, 0, 0;
    0, cos(x), -sin(x);
    0, sin(x), cos(x)];

Ry = @(x) [cos(x), 0, sin(x);
    0, 1, 0;
    -sin(x), 0, cos(x)];

Rz = @(x) [cos(x), -sin(x), 0;
    sin(x), cos(x), 0;
    0, 0, 1];

R = Rz(theta(1)) * Ry(theta(2)) * Rx(theta(3));

R  - R_test



