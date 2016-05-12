function [phalanges, dofs] = get_phalanges_from_centers(centers, phalanges, names_map)

%% Adjust initial transformations
[~, dofs] = hmodel_parameters();

% Thumb
phalanges{2}.local(1:3, 4) = centers{names_map('thumb_base')} - centers{names_map('palm_back')};
phalanges{3}.local(2, 4) = norm(centers{names_map('thumb_bottom')} - centers{names_map('thumb_base')});
phalanges{4}.local(2, 4) = norm(centers{names_map('thumb_middle')} - centers{names_map('thumb_bottom')});

% Index
phalanges{14}.local(1:3, 4) = centers{names_map('index_base')} - centers{names_map('palm_back')};
phalanges{15}.local(2, 4) = norm(centers{names_map('index_bottom')} - centers{names_map('index_base')});
phalanges{16}.local(2, 4) = norm(centers{names_map('index_middle')} - centers{names_map('index_bottom')});

% Middle
phalanges{11}.local(1:3, 4) = centers{names_map('middle_base')} - centers{names_map('palm_back')};
phalanges{12}.local(2, 4) = norm(centers{names_map('middle_bottom')} - centers{names_map('middle_base')});
phalanges{13}.local(2, 4) = norm(centers{names_map('middle_middle')} - centers{names_map('middle_bottom')});
phalanges{13}.local(1:3, 1:3) = eye(3, 3);

% Ring
phalanges{8}.local(1:3, 4) = centers{names_map('ring_base')} - centers{names_map('palm_back')};
phalanges{9}.local(2, 4) = 0.9 * (norm(centers{names_map('ring_bottom')} - centers{names_map('ring_base')}));
phalanges{10}.local(2, 4) = norm(centers{names_map('ring_middle')} - centers{names_map('ring_bottom')});

% Pinky
phalanges{5}.local(1:3, 4) = centers{names_map('pinky_base')} - centers{names_map('palm_back')};
phalanges{6}.local(2, 4) =  norm(centers{names_map('pinky_bottom')} - centers{names_map('pinky_base')});
phalanges{7}.local(2, 4) =  norm(centers{names_map('pinky_middle')} - centers{names_map('pinky_bottom')});