load ('E:\Data\MATLAB\photoscan_fitting\fitted_poses\poses.mat');
load ('E:\Data\MATLAB\photoscan_fitting\fitted_poses\radii.mat');
load ('E:\Data\MATLAB\photoscan_fitting\fitted_poses\blocks.mat');

for p = 1:length(poses)
    %[poses{p}.indices, poses{p}.projections, poses{p}.block_indices] = compute_projections(poses{p}.points, poses{p}.centers, blocks, radii);
    display_result(poses{p}.centers, [], [], blocks, radii, false, 1, 'big');
    mypoints(poses{p}.points, [179, 81, 109]/255, 8);
    
    if p == 1, zoom(2); view([148, 7.264]); end
    if p == 2, zoom(2.3); view([150,  -2.7356]); end
    if p == 3, zoom(2); view([-2.662, 11.761]); end
    if p == 4, zoom(2.2); view([47, 33.264]); end

    drawnow;
end