clear; close all;
D = 3;
N = 7;
p = cell(N, 1);
q = cell(N, 1);
for i = 1:N
    p{i} = rand(D, 1);
    q{i} = p{i};
end

rotation_axis = randn(D, 1); rotation_angle = randn;
translation_vector = randn(D, 1);
scaling_vector = 2 * rand;

R_ = makehgtform('axisrotate', rotation_axis, rotation_angle);
T_ = makehgtform('translate', translation_vector);
S_ = makehgtform('scale', scaling_vector);

for i = 1:length(q)
    q{i} = transform(q{i}, T_ * S_ * R_);
end

figure; hold on; axis off; axis equal; set(gcf,'color','w');
mypoints(p, [0, 0.7, 1]);
mypoints(q, [0.65, 0.1, 0.5]);
mylines(p, q, [0.75, 0.75, 0.75]);

% M  = eye(D + 1, D + 1);
% N = length(p);
% for iter = 1:10
%     F = zeros(N * D, 1);
%     J = zeros(N * D, 7);
%
%     for i = 1:N
%         F(D * (i - 1) + 1: D * i) = p{i} - q{i};
%         J(D * (i - 1) + 1: D * i, 1:3) = -[0, q{i}(3), -q{i}(2); -q{i}(3), 0, q{i}(1); q{i}(2), -q{i}(1), 0];
%         J(D * (i - 1) + 1: D * i, 4:6) = -eye(D, D);
%         J(D * (i - 1) + 1: D * i, 7) = - 2 * q{i};
%     end
%
%     x = (J' * J) \ (J' * F);
%
%     R = makehgtform('axisrotate', [1; 0; 0], -x(1)) * makehgtform('axisrotate', [0; 1; 0], -x(2)) * makehgtform('axisrotate', [0; 0; 3], -x(3));
%     T = makehgtform('translate',  -x(4:6));
%     S = makehgtform('scale', 1/((x(7) + 1) * (x(7) + 1)));
%
%
%     for i = 1:N
%         q{i} = transform(q{i}, (T * S * R));
%     end
%
%     M = (T * S * R) * M;
%
%     figure; hold on; axis off; axis equal; set(gcf,'color','w');
%     mypoints(p, [0, 0.7, 1]);
%     mypoints(q, [0.65, 0.1, 0.5]);
%     mylines(p, q, [0.75, 0.75, 0.75]);
% end

[M] = find_rigid_transformation(p, q, true);

for i = 1:length(q)
    q{i} = transform(q{i}, M);
end
figure; hold on; axis off; axis equal; set(gcf,'color','w');
mypoints(p, [0, 0.7, 1]);
mypoints(q, [0.65, 0.1, 0.5]);
mylines(p, q, [0.75, 0.75, 0.75]);

disp(inv(M))
disp(T_ * S_ * R_)