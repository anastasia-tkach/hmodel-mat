function [M1, M2, M3, L, alpha, theta] = compute_initial_transformation_many_poses(poses, indices, lb, ub, alpha_theta0, figure_title)

D = 3;
num_poses = length(poses);

Rx = @(alpha) [1, 0, 0; 0, cos(alpha), -sin(alpha); 0, sin(alpha), cos(alpha)];
Ry = @(alpha) [cos(alpha), 0, sin(alpha); 0, 1, 0; -sin(alpha), 0, cos(alpha)];
Rz = @(alpha)[cos(alpha), -sin(alpha), 0; sin(alpha), cos(alpha), 0; 0, 0, 1];

u = [0; 1; 0];

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

%% Poses
RA = cell(num_poses, 1);
RB = cell(num_poses, 1);
RC = cell(num_poses, 1);
Q2 = cell(num_poses, 1);
Q3 = cell(num_poses, 1);
Q4 = cell(num_poses, 1);
for p = 1:length(poses)
    start = 5 + 4 * (p - 1) + 1;
    RA{p} = @(alpha_theta) Rx(alpha_theta(start + 1)) * Rz(alpha_theta(start));
    RB{p} =  @(alpha_theta) Rx(alpha_theta(start + 2));
    RC{p} =  @(alpha_theta) Rx(alpha_theta(start + 3));
    Q2{p} = @(alpha_theta) t1 + T1(alpha_theta) * RA{p}(alpha_theta) * L(1) * u;
    Q3{p} = @(alpha_theta) t1 + T1(alpha_theta) * RA{p}(alpha_theta) * (t2 + T2(alpha_theta) * RB{p}(alpha_theta) * L(2) * u);
    Q4{p} = @(alpha_theta) t1 + T1(alpha_theta) * RA{p}(alpha_theta) * (t2 + T2(alpha_theta) * RB{p}(alpha_theta) * (t3 + T3(alpha_theta) * RC{p}(alpha_theta) * L(3) * u));
end

P = cell(length(poses), 1);
for p = 1:length(poses)
    P{p} = cell(4, 1);
    for i = 1:length(indices)
        P{p}{i} = poses{p}.centers{indices(i)};
    end
end

%% Solve
f = @(alpha_theta) [];
for p = 1:num_poses
    f  = @(alpha_theta) [f(alpha_theta); P{p}{2} - Q2{p}(alpha_theta); P{p}{3} - Q3{p}(alpha_theta); P{p}{4} - Q4{p}(alpha_theta)];
end

[alpha_theta_ls] = lsqnonlin(f, alpha_theta0, lb, ub);
disp(alpha_theta_ls(1:5)');

%% Build initial transformations matrices
M1 = eye(D + 1, D + 1);
M1(1:3, 1:3) = T1(alpha_theta_ls);
M1(1:3, 4) = t1;

M2 = eye(D + 1, D + 1);
M2(1:3, 1:3) = T2(alpha_theta_ls);
M2(1:3, 4) = t2;

M3 = eye(D + 1, D + 1);
M3(1:3, 1:3) = T3(alpha_theta_ls);
M3(1:3, 4) = t3;

alpha = alpha_theta_ls(1:5);
theta = alpha_theta_ls(6:end);



