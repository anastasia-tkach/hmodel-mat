function [F, J] = assemble_energy(poses, num_centers, num_parameters, D,  energy_id, to_compute)

if to_compute == false
    F = 0; J = 0; return;
end

num_poses = length(poses);
total_num_points = 0;
cumsum_num_points = zeros(num_poses + 1, 1);
switch energy_id
    case '1'
        for p = 1:num_poses
            total_num_points = total_num_points + length(poses{p}.f1);
            cumsum_num_points(p + 1) = cumsum_num_points(p) + length(poses{p}.f1);
        end
    case '3x'
        for p = 1:num_poses
            total_num_points = total_num_points + length(poses{p}.f3x);
            cumsum_num_points(p + 1) = cumsum_num_points(p) + length(poses{p}.f3x);
        end
    case '3y'
        for p = 1:num_poses
            total_num_points = total_num_points + length(poses{p}.f3y);
            cumsum_num_points(p + 1) = cumsum_num_points(p) + length(poses{p}.f3y);
        end
    case '3z'
        for p = 1:num_poses
            total_num_points = total_num_points + length(poses{p}.f3z);
            cumsum_num_points(p + 1) = cumsum_num_points(p) + length(poses{p}.f3z);
        end
end

%% Assemble overall linear system
F = zeros(total_num_points, 1);
J = zeros(total_num_points, num_parameters);
num_poses = length(poses);
for p = 1:length(poses)
    switch energy_id
        case '1',
            f = poses{p}.f1;
            Jc = poses{p}.Jc1;
            Jr = poses{p}.Jr1;
        case '3x'
            f = poses{p}.f3x;
            Jc = poses{p}.Jc3x;
            Jr = poses{p}.Jr3x;
        case '3y'
            f = poses{p}.f3y;
            Jc = poses{p}.Jc3y;
            Jr = poses{p}.Jr3y;
        case '3z'
            f = poses{p}.f3z;
            Jc = poses{p}.Jc3z;
            Jr = poses{p}.Jr3z;
    end
    
    J(cumsum_num_points(p) + 1:cumsum_num_points(p + 1), D * num_centers * (p - 1) + 1:D * num_centers * p) = Jc;
    J(cumsum_num_points(p) + 1:cumsum_num_points(p + 1), D * num_centers * num_poses + 1:end) = Jr;
    F(cumsum_num_points(p) + 1:cumsum_num_points(p + 1)) = f;
end


