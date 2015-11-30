function [M, scaling] = find_rigid_transformation(p, q, is_scaled)

scaling = 1;
num_parameters = 7;
if ~is_scaled, num_parameters = 6; end

D = length(p{1});
M  = eye(D + 1, D + 1);
N = length(p);
for iter = 1:10
    F = zeros(N * D, 1);
    J = zeros(N * D, num_parameters);
    
    for i = 1:N
        F(D * (i - 1) + 1: D * i) = p{i} - q{i};
        J(D * (i - 1) + 1: D * i, 1:3) = -[0, q{i}(3), -q{i}(2); -q{i}(3), 0, q{i}(1); q{i}(2), -q{i}(1), 0];
        J(D * (i - 1) + 1: D * i, 4:6) = -eye(D, D);
        if is_scaled
            J(D * (i - 1) + 1: D * i, 7) = - 2 * q{i};
        end
    end
    
    x = (J' * J) \ (J' * F);   
   
    R = makehgtform('axisrotate', [1; 0; 0], -x(1)) * makehgtform('axisrotate', [0; 1; 0], -x(2)) * makehgtform('axisrotate', [0; 0; 3], -x(3));
    T = makehgtform('translate',  -x(4:6));    

    if is_scaled
        S = makehgtform('scale', 1/((x(7) + 1) * (x(7) + 1)));
        scaling = scaling * 1/((x(7) + 1) * (x(7) + 1));
    else
        S = eye(D + 1, D + 1);
    end   
    
    for i = 1:N
        q{i} = transform(q{i}, (T * S * R));
    end
    
    M = (T * S * R) * M;
    
%     figure; hold on; axis off; axis equal; set(gcf,'color','w');
%     mypoints(p, [0, 0.7, 1]);
%     mypoints(q, [0.65, 0.1, 0.5]);
%     mylines(p, q, [0.75, 0.75, 0.75]);    
end

