clc; clear; close all;

input_path = 'C:/Developer/data/models/anonymous/stage1/';

[centers, radii, blocks, theta, template_phalanges, mean_centers] = read_cpp_model(input_path);

for i = 1:length(template_phalanges)
    template_phalanges{i}.local = template_phalanges{i}.local';
end

%% Set up template transformations
for i = 1:length(template_phalanges)  
    %M = phalanges{i}.local(1:3, 1:3);
    %euler_angles = rotm2eul(M, 'ZYX');
    % pinky base
    if i == 5 
        R = makehgtform('axisrotate', [0; 1; 0], -pi/5);
        template_phalanges{i}.local(1:3, 1:3) = R(1:3, 1:3);  
    end
    % ring base
    if i == 8
        R = makehgtform('axisrotate', [0; 1; 0], -pi/10);
        template_phalanges{i}.local(1:3, 1:3) = R(1:3, 1:3);    
    end
    % middle base
    if i == 11
        R = makehgtform('axisrotate', [0; 1; 0], pi/20);
        template_phalanges{i}.local(1:3, 1:3) = R(1:3, 1:3);    
    end
    % index base
    if i == 14
        R = makehgtform('axisrotate', [0; 1; 0], pi/10);
        template_phalanges{i}.local(1:3, 1:3) = R(1:3, 1:3);    
    end
end

semantics_path = '_my_hand/semantics/';
load([semantics_path, 'fitting/names_map.mat']);

centers{names_map('index_top')} = centers{names_map('index_middle')} + norm(centers{names_map('index_top')} - centers{names_map('index_middle')}) * [0; 1; 0];
centers{names_map('middle_top')} = centers{names_map('middle_middle')} + norm(centers{names_map('middle_top')} - centers{names_map('middle_middle')}) * [0; 1; 0];
centers{names_map('ring_top')} = centers{names_map('ring_middle')} + norm(centers{names_map('ring_top')} - centers{names_map('ring_middle')}) * [0; 1; 0];
centers{names_map('pinky_top')} = centers{names_map('pinky_middle')} + norm(centers{names_map('pinky_top')} - centers{names_map('pinky_middle')}) * [0; 1; 0];

[phalanges, dofs] = hmodel_parameters();
for i = 1:length(phalanges)
    phalanges{i}.local = template_phalanges{i}.local;
end
theta = zeros(29, 1);
phalanges = htrack_move(theta, dofs, phalanges);
phalanges = initialize_offsets(centers, phalanges, names_map);
phalanges = htrack_move(theta, dofs, phalanges);
centers = update_centers(centers, phalanges, names_map);


write_cpp_model('C:/Developer/data/models/anonymous/', centers, radii, blocks, phalanges);







