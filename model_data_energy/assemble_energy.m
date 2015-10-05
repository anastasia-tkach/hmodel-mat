function [F, J] = assemble_energy(poses, num_centers, num_parameters, energy_id, settings)

D = settings.D;


for p = 1:length(poses)
    switch energy_id
        case '1',
            if settings.energy1 == false, F = 0; J = 0; return; end
            poses{p}.f = poses{p}.f1;
            poses{p}.Jc = poses{p}.Jc1;
            if strcmp(settings.mode, 'fitting'), poses{p}.Jr = poses{p}.Jr1; end
        case '3x'
            if settings.energy3x == false, F = 0; J = 0; return; end
            poses{p}.f = poses{p}.f3x;
            poses{p}.Jc = poses{p}.Jc3x;
            if strcmp(settings.mode, 'fitting'), poses{p}.Jr = poses{p}.Jr3x; end
        case '3y'
            if settings.energy3y == false, F = 0; J = 0; return; end
            poses{p}.f = poses{p}.f3y;
            poses{p}.Jc = poses{p}.Jc3y;
            if strcmp(settings.mode, 'fitting'), poses{p}.Jr = poses{p}.Jr3y; end
        case '3z'
            if settings.energy3z == false, F = 0; J = 0; return; end
            poses{p}.f = poses{p}.f3z;
            poses{p}.Jc = poses{p}.Jc3z;
            if strcmp(settings.mode, 'fitting'), poses{p}.Jr = poses{p}.Jr3z; end
        case '4'
            if settings.energy4 == false, F = 0; J = 0; return; end
            poses{p}.f = poses{p}.f4;
            poses{p}.Jc = poses{p}.Jc4;
            if strcmp(settings.mode, 'fitting'), poses{p}.Jr = poses{p}.Jr4; end
        case '5'
            if settings.energy5 == false, F = 0; J = 0; return; end
            poses{p}.f = poses{p}.f5;
            poses{p}.Jc = poses{p}.Jc5;
            if strcmp(settings.mode, 'fitting'), poses{p}.Jr = poses{p}.Jr5; end
    end
end

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
    if strcmp(settings.mode, 'fitting')
        J(cumsum_num_points(p) + 1:cumsum_num_points(p + 1), D * num_centers * num_poses + 1:end) = poses{p}.Jr;
    end
    F(cumsum_num_points(p) + 1:cumsum_num_points(p + 1)) = poses{p}.f;
end


