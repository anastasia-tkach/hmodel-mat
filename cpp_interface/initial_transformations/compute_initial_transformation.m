function [M1, M2, M3, L, theta] = compute_initial_transformation(poses, indices, lb, ub, figure_title)

D = 3;
num_poses = length(poses);

Rx = @(alpha) [1, 0, 0; 0, cos(alpha), -sin(alpha); 0, sin(alpha), cos(alpha)];
Ry = @(alpha) [cos(alpha), 0, sin(alpha); 0, 1, 0; -sin(alpha), 0, cos(alpha)];
Rz = @(alpha)[cos(alpha), -sin(alpha), 0; sin(alpha), cos(alpha), 0; 0, 0, 1];

u = [0; 1; 0];

P1 = cell(4, 1);
P2 = cell(4, 1);
P3 = cell(4, 1);
P4 = cell(4, 1);
P5 = cell(4, 1);
for i = 1:length(indices)
    P1{i} = poses{1}.centers{indices(i)};
    P2{i} = poses{2}.centers{indices(i)};
    P3{i} = poses{3}.centers{indices(i)};
    P4{i} = poses{4}.centers{indices(i)};
    P5{i} = poses{5}.centers{indices(i)};
end

num_alpha_thetas = 5 + num_poses * 4;

%% Length and initial translations
L = zeros(num_poses, length(indices) - 1);
for i = 1:length(indices) - 1
    for p = 1:num_poses
        L(p, i) = norm(poses{p}.centers{indices(i)} - poses{p}.centers{indices(i + 1)});
    end
end
L = mean(L);
t1 = zeros(3, 1);
for p = 1:num_poses
    t1 = t1 + poses{p}.centers{indices(1)};
end
t1 = t1 / num_poses;
t2 = L(1) * u;
t3 = L(2) * u;

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

%% Pose 2
RA2 = @(alpha_theta) Rx(alpha_theta(11)) * Rz(alpha_theta(10));
RB2 =  @(alpha_theta) Rx(alpha_theta(12));
RC2 =  @(alpha_theta) Rx(alpha_theta(13));
Q22 = @(alpha_theta) t1 + T1(alpha_theta) * RA2(alpha_theta) * L(1) * u;
Q23 = @(alpha_theta) t1 + T1(alpha_theta) * RA2(alpha_theta) * (t2 + T2(alpha_theta) * RB2(alpha_theta) * L(2) * u);
Q24 = @(alpha_theta) t1 + T1(alpha_theta) * RA2(alpha_theta) * (t2 + T2(alpha_theta) * RB2(alpha_theta) * (t3 + T3(alpha_theta) * RC2(alpha_theta) * L(3) * u));

%% Pose 3
RA3 = @(alpha_theta) Rx(alpha_theta(15)) * Rz(alpha_theta(14));
RB3 =  @(alpha_theta) Rx(alpha_theta(16));
RC3 =  @(alpha_theta) Rx(alpha_theta(17));
Q32 = @(alpha_theta) t1 + T1(alpha_theta) * RA3(alpha_theta) * L(1) * u;
Q33 = @(alpha_theta) t1 + T1(alpha_theta) * RA3(alpha_theta) * (t2 + T2(alpha_theta) * RB3(alpha_theta) * L(2) * u);
Q34 = @(alpha_theta) t1 + T1(alpha_theta) * RA3(alpha_theta) * (t2 + T2(alpha_theta) * RB3(alpha_theta) * (t3 + T3(alpha_theta) * RC3(alpha_theta) * L(3) * u));

%% Pose 4
RA4 = @(alpha_theta) Rx(alpha_theta(19)) * Rz(alpha_theta(18));
RB4 =  @(alpha_theta) Rx(alpha_theta(20));
RC4 =  @(alpha_theta) Rx(alpha_theta(21));
Q42 = @(alpha_theta) t1 + T1(alpha_theta) * RA4(alpha_theta) * L(1) * u;
Q43 = @(alpha_theta) t1 + T1(alpha_theta) * RA4(alpha_theta) * (t2 + T2(alpha_theta) * RB4(alpha_theta) * L(2) * u);
Q44 = @(alpha_theta) t1 + T1(alpha_theta) * RA4(alpha_theta) * (t2 + T2(alpha_theta) * RB4(alpha_theta) * (t3 + T3(alpha_theta) * RC4(alpha_theta) * L(3) * u));

%% Pose 5
RA5 = @(alpha_theta) Rx(alpha_theta(23)) * Rz(alpha_theta(22));
RB5 =  @(alpha_theta) Rx(alpha_theta(24));
RC5 =  @(alpha_theta) Rx(alpha_theta(25));
Q52 = @(alpha_theta) t1 + T1(alpha_theta) * RA5(alpha_theta) * L(1) * u;
Q53 = @(alpha_theta) t1 + T1(alpha_theta) * RA5(alpha_theta) * (t2 + T2(alpha_theta) * RB5(alpha_theta) * L(2) * u);
Q54 = @(alpha_theta) t1 + T1(alpha_theta) * RA5(alpha_theta) * (t2 + T2(alpha_theta) * RB5(alpha_theta) * (t3 + T3(alpha_theta) * RC5(alpha_theta) * L(3) * u));

%% Solve
f = @(alpha_theta) [
    P1{2} - Q12(alpha_theta); P1{3} - Q13(alpha_theta); P1{4} - Q14(alpha_theta); ... 
    P2{2} - Q22(alpha_theta); P2{3} - Q23(alpha_theta); P2{4} - Q24(alpha_theta); ... 
    P3{2} - Q32(alpha_theta); P3{3} - Q33(alpha_theta); P3{4} - Q34(alpha_theta); ... 
    P4{2} - Q42(alpha_theta); P4{3} - Q43(alpha_theta); P4{4} - Q44(alpha_theta); ... 
    P5{2} - Q52(alpha_theta); P5{3} - Q53(alpha_theta); P5{4} - Q54(alpha_theta)];

%disp(f(alpha_theta_true));5

alpha_theta0 = (lb + ub) / 2 + 0.1 * rand(num_alpha_thetas, 1);
%alpha_theta0 = ub + 0.1 * rand(num_alpha_thetas, 1);

[alpha_theta_ls] = lsqnonlin(f, alpha_theta0, lb, ub);

%disp(alpha_theta_ls(1:5)');
%disp([alpha_theta_true, alpha_theta_ls])

%% Build initial transformations matrices

if strcmp(figure_title, 'thumb')
    %0.6089;  -1.1076; -0.3581   
    alpha_theta_ls(2) = -0.7;    
    disp(alpha_theta_ls(1:3)');
end

M1 = eye(D + 1, D + 1);
M1(1:3, 1:3) = T1(alpha_theta_ls);
M1(1:3, 4) = t1;

M2 = eye(D + 1, D + 1);
M2(1:3, 1:3) = T2(alpha_theta_ls);
M2(1:3, 4) = t2;

M3 = eye(D + 1, D + 1);
M3(1:3, 1:3) = T3(alpha_theta_ls);
M3(1:3, 4) = t3;

theta = alpha_theta_ls(6:end);

%% Display
return;
figure; hold on; axis off; axis equal;
for p = 1:num_poses
    for i = 1:length(indices) - 1
        myline(poses{p}.centers{indices(i)},  poses{p}.centers{indices(i + 1)}, 'm');
    end
end
for i = 1:length(indices)
    mypoint(P1{i}, 'r');
    mypoint(P2{i}, 'r');
    mypoint(P3{i}, 'r');
    mypoint(P4{i}, 'r');
    mypoint(P5{i}, 'r');
end
mypoint(Q12(alpha_theta_ls), 'k'); mypoint(Q13(alpha_theta_ls), 'k'); mypoint(Q14(alpha_theta_ls), 'k'); 
mypoint(Q22(alpha_theta_ls), 'k'); mypoint(Q23(alpha_theta_ls), 'k'); mypoint(Q24(alpha_theta_ls), 'k'); 
mypoint(Q32(alpha_theta_ls), 'k'); mypoint(Q33(alpha_theta_ls), 'k'); mypoint(Q34(alpha_theta_ls), 'k');
mypoint(Q42(alpha_theta_ls), 'k'); mypoint(Q43(alpha_theta_ls), 'k'); mypoint(Q44(alpha_theta_ls), 'k'); 
mypoint(Q52(alpha_theta_ls), 'k'); mypoint(Q53(alpha_theta_ls), 'k'); mypoint(Q54(alpha_theta_ls), 'k'); 

myline(P1{2}, Q12(alpha_theta_ls), [0.75, 0.75, 0.75]);
myline(P1{3}, Q13(alpha_theta_ls), [0.75, 0.75, 0.75]); 
myline(P1{4}, Q14(alpha_theta_ls), [0.75, 0.75, 0.75]);
myline(P2{2}, Q22(alpha_theta_ls), [0.75, 0.75, 0.75]);
myline(P2{3}, Q23(alpha_theta_ls), [0.75, 0.75, 0.75]);
myline(P2{4}, Q24(alpha_theta_ls), [0.75, 0.75, 0.75]);
myline(P3{2}, Q32(alpha_theta_ls), [0.75, 0.75, 0.75]);
myline(P3{3}, Q33(alpha_theta_ls), [0.75, 0.75, 0.75]);
myline(P3{4}, Q34(alpha_theta_ls), [0.75, 0.75, 0.75]);
myline(P4{2}, Q42(alpha_theta_ls), [0.75, 0.75, 0.75]);
myline(P4{3}, Q43(alpha_theta_ls), [0.75, 0.75, 0.75]);
myline(P4{4}, Q44(alpha_theta_ls), [0.75, 0.75, 0.75]);
myline(P5{2}, Q52(alpha_theta_ls), [0.75, 0.75, 0.75]);
myline(P5{3}, Q53(alpha_theta_ls), [0.75, 0.75, 0.75]);
myline(P5{4}, Q54(alpha_theta_ls), [0.75, 0.75, 0.75]);

title(figure_title);
