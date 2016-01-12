function [F, J] = assemble_energy(poses, energy_id, settings)

D = settings.D;
num_centers = length(poses{1}.centers);
num_parameters = D * num_centers * length(poses) + num_centers;

for p = 1:length(poses)
    switch energy_id
        case '1',
            if settings.energy1 == false, F = 0; J = 0; return; end
            poses{p}.f = poses{p}.f1;
            poses{p}.Jc = poses{p}.Jc1;
            poses{p}.Jr = poses{p}.Jr1;
        case '3'
            if settings.energy3 == false, F = 0; J = 0; return; end
            poses{p}.f = poses{p}.f3;
            poses{p}.Jc = poses{p}.Jc3;
            poses{p}.Jr = poses{p}.Jr3;
        case '4'
            if settings.energy4 == false, F = 0; J = 0; return; end
            poses{p}.f = poses{p}.f4;
            poses{p}.Jc = poses{p}.Jc4;
            poses{p}.Jr = poses{p}.Jr4;
        case '5'
            if settings.energy5 == false, F = 0; J = 0; return; end
            poses{p}.f = poses{p}.f5;
            poses{p}.Jc = poses{p}.Jc5;
            poses{p}.Jr = poses{p}.Jr5;
        case '6'
            if settings.energy6 == false, F = 0; J = 0; return; end
            poses{p}.f = poses{p}.f6;
            poses{p}.Jc = poses{p}.Jc6;
            poses{p}.Jr = poses{p}.Jr6;
    end
end

%% Compute cumsum
num_poses = length(poses);
total_num_points = 0;
cumsum_num_points = zeros(num_poses + 1, 1);
for p = 1:num_poses
    total_num_points = total_num_points + length(poses{p}.f);
    cumsum_num_points(p + 1) = cumsum_num_points(p) + length(poses{p}.f);
end

%% Assemble overall linear system
F = zeros(total_num_points, 1);
J = zeros(total_num_points, num_parameters);
num_poses = length(poses);
for p = 1:length(poses)
    J(cumsum_num_points(p) + 1:cumsum_num_points(p + 1), D * num_centers * (p - 1) + 1:D * num_centers * p) = poses{p}.Jc;
    J(cumsum_num_points(p) + 1:cumsum_num_points(p + 1), D * num_centers * num_poses + 1:end) = poses{p}.Jr;
    F(cumsum_num_points(p) + 1:cumsum_num_points(p + 1)) = poses{p}.f;
end


