function [centers, radii] = find_htrack_hmodel_transformation(centers, radii, blocks, beta, names_map, verbose, D)

%% Manual scaling
scaling_factor = 27;
for i = 1:length(centers)
    centers{i} = centers{i} * scaling_factor + beta(1:3);
    radii{i} = radii{i} * scaling_factor;
end

%% Find scaling
htrack_pinky_indices = [9, 8, 7, 6];
htrack_ring_indices = [13, 12, 11, 10];
htrack_middle_indices = [17, 16, 15, 14];
htrack_index_indices = [21, 20, 19, 18]; 
htrack_thumb_indices = [5, 4, 3]; 
htrack_base_index = 1;
htrack_indices = [htrack_pinky_indices, htrack_ring_indices, htrack_middle_indices, htrack_index_indices, htrack_thumb_indices, htrack_base_index];

hmodel_pinky_indices = [names_map('pinky_top'), names_map('pinky_middle'), names_map('pinky_bottom'), names_map('palm_pinky')];
hmodel_ring_indices = [names_map('ring_top'), names_map('ring_middle'), names_map('ring_bottom'), names_map('palm_ring')];
hmodel_middle_indices = [names_map('middle_top'), names_map('middle_middle'), names_map('middle_bottom'), names_map('palm_middle')];
hmodel_index_indices = [names_map('index_top'), names_map('index_middle'), names_map('index_bottom'), names_map('palm_index')];
hmodel_thumb_indices = [names_map('thumb_top'), names_map('thumb_middle'), names_map('thumb_bottom')];
hmodel_base_index = names_map('palm_back');
hmodel_indices = [hmodel_pinky_indices, hmodel_ring_indices, hmodel_middle_indices, hmodel_index_indices, hmodel_thumb_indices, hmodel_base_index];
for i = 1:length(htrack_indices)
    p{i} = beta(D *(htrack_indices(i) - 1) + 1:D * htrack_indices(i));
    q{i} = centers{hmodel_indices(i)};
end

if verbose
    display_result(centers, [], [], blocks, radii, false, 0.3, 'none');
    display_skeleton(centers, radii, blocks, [], false, []);
    mypoints(p, 'r');
    mypoints(q, 'b');
    view([180, -90]); camlight; drawnow; 
end

[M, scaling] = find_rigid_transformation(p, q, true);
for i = 1:length(centers)
    centers{i} = transform(centers{i}, M);
    radii{i} = radii{i} * scaling;
end

%% Display
if verbose
    display_result(centers, [], [], blocks, radii, false, 0.3, 'none');
    display_skeleton(centers, radii, blocks, [], false, []);
    view([180, -90]); camlight; drawnow; 
end
