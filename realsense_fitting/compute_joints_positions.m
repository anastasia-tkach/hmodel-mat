function [centers] = compute_joints_positions(centers, phalanges, theta, names_map, init_centers)
D = 3;

num_phalanges = 17;
for i = 1:num_phalanges
    centers{names_map(phalanges{i}.name)} = phalanges{i}.global(1:D, D + 1);
    if isfield(phalanges{i}, 'rigid_names')
        for j = 1:length(phalanges{i}.rigid_names)
            index = names_map(phalanges{i}.rigid_names{j});
            t = phalanges{i}.global(1:D, 1:D) * phalanges{i}.offsets{j};
            centers{index} = centers{names_map(phalanges{i}.name)} + t;
        end
    end
end

u = [0; 1; 0];
Rx = @(alpha) [1, 0, 0; 0, cos(alpha), -sin(alpha); 0, sin(alpha), cos(alpha)];
Rz = @(alpha)[cos(alpha), -sin(alpha), 0; sin(alpha), cos(alpha), 0; 0, 0, 1];

thumb_indices = [names_map('thumb_base'), names_map('thumb_bottom'), names_map('thumb_middle'), names_map('thumb_top')];
index_indices = [names_map('index_base'), names_map('index_bottom'), names_map('index_middle'), names_map('index_top')];
middle_indices = [names_map('middle_base'), names_map('middle_bottom'), names_map('middle_middle'), names_map('middle_top')];
ring_indices = [names_map('ring_base'), names_map('ring_bottom'), names_map('ring_middle'), names_map('ring_top')];
pinky_indices = [names_map('pinky_base'), names_map('pinky_bottom'), names_map('pinky_middle'), names_map('pinky_top')];

fingers_indices = {thumb_indices; index_indices; middle_indices; ring_indices; pinky_indices};
phalanges_indices = {2:4, 14:16, 11:13, 8:10, 5:7};
dofs_indices = {10:13, 14:17, 18:21, 22:25, 26:29};

for f = 1:length(fingers_indices)
    centers_indices = fingers_indices{f};
    L = zeros(length(centers_indices) - 1, 1);
    for i = 1:length(centers_indices) - 1
        L(i) = norm(init_centers{centers_indices(i)} - init_centers{centers_indices(i + 1)});
    end
    t1 = init_centers{centers_indices(1)};
    t2 = L(1) * u;
    t3 = L(2) * u;
    T1 = phalanges{phalanges_indices{f}(1)}.init_local(1:3, 1:3);
    T2 = phalanges{phalanges_indices{f}(2)}.init_local(1:3, 1:3);
    T3 = phalanges{phalanges_indices{f}(3)}.init_local(1:3, 1:3);
    RA = Rx(theta(dofs_indices{f}(2))) * Rz(theta(dofs_indices{f}(1)));
    RB = Rx(theta(dofs_indices{f}(3)));
    RC = Rx(theta(dofs_indices{f}(4)));

    M = phalanges{1}.global;
    c2 = t1 + T1 * RA * L(1) * u;
    c3 = t1 + T1 * RA * (t2 + T2 * RB * L(2) * u);
    c4 = t1 + T1 * RA * (t2 + T2 * RB * (t3 + T3 * RC * L(3) * u));
    centers{centers_indices(2)} = transform(c2, M);
    centers{centers_indices(3)} = transform(c3, M);
    centers{centers_indices(4)} = transform(c4, M);
end



