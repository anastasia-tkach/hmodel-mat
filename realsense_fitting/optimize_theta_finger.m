function [theta_ls, M1, M2, M3, L] = optimize_theta_finger(centers, indices, lb, ub, alpha, theta0, type)

D = 3;
Rx = @(alpha) [1, 0, 0; 0, cos(alpha), -sin(alpha); 0, sin(alpha), cos(alpha)];
Ry = @(alpha) [cos(alpha), 0, sin(alpha); 0, 1, 0; -sin(alpha), 0, cos(alpha)];
Rz = @(alpha)[cos(alpha), -sin(alpha), 0; sin(alpha), cos(alpha), 0; 0, 0, 1];

u = [0; 1; 0];


%% Length and initial translations
L = zeros(length(indices) - 1, 1);
for i = 1:length(indices) - 1    
    L(i) = norm(centers{indices(i)} - centers{indices(i + 1)});
end
t1 = centers{indices(1)};
t2 = L(1) * u;
t3 = L(2) * u;

%% Initial transformations
T1 = Rz(alpha(3)) * Ry(alpha(2)) * Rx(alpha(1));
if strcmp(type, 'thumb')
    T2 = Ry(alpha(4));
end
if strcmp(type, 'finger')
    T2 = Rz(alpha(4));
end
T3 = Rz(alpha(5));

%% Poses
RA = @(theta) Rx(theta(2)) * Rz(theta(1));
RB =  @(theta) Rx(theta(3));
RC =  @(theta) Rx(theta(4));
Q2 = @(theta) t1 + T1 * RA(theta) * L(1) * u;
Q3 = @(theta) t1 + T1 * RA(theta) * (t2 + T2 * RB(theta) * L(2) * u);
Q4 = @(theta) t1 + T1 * RA(theta) * (t2 + T2 * RB(theta) * (t3 + T3 * RC(theta) * L(3) * u));

P = cell(4, 1);
for i = 1:length(indices)
        P{i} = centers{indices(i)};
end

%% Solve
f  = @(theta) [P{2} - Q2(theta); P{3} - Q3(theta); P{4} - Q4(theta)];

options = optimoptions(@lsqnonlin, 'display','off');
[theta_ls] = lsqnonlin(f, theta0, lb, ub, options);

%% Update initial tranformations
M1 = eye(D + 1, D + 1);
M1(1:3, 1:3) = T1;
M1(1:3, 4) = t1;

M2 = eye(D + 1, D + 1);
M2(1:3, 1:3) = T2;
M2(1:3, 4) = t2;

M3 = eye(D + 1, D + 1);
M3(1:3, 1:3) = T3;
M3(1:3, 4) = t3;
