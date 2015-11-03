clear
data_path = '_data/htrack_model/joint_limits/';
mode = 'joint_limits';
skeleton = true;

%% Get model
segments = create_ik_model(mode);
[centers, radii, blocks, solid_blocks, attachments] = make_convolution_model(segments, mode);
if strcmp(mode, 'joint_limits'), 
    blocks{5} = [5, 6]; blocks{4} = [6, 8]; blocks{6} = [7, 8]; blocks{7} = [5, 7]; 
    solid_blocks{4} = [4, 5, 6, 7];
end

%% Create posed data
switch mode
    case 'finger'
        theta = zeros(8, 1); theta(4) = pi/5; theta(7) = pi/5; theta(8) = pi/5;
    case 'palm_finger'
        theta = zeros(10, 1); theta(8:10) = -pi/4;
    case 'hand'
        theta = zeros(26, 1); theta(23) = -pi/6; 
    case 'joint_limits'
        theta = zeros(14, 1); theta(8) = -0.6; theta(9) = 1; theta(12) = 0; theta(13) = 0; theta(14) = 0; 
end
[segments, joints] = pose_ik_model(segments, theta, false, mode);
[centers, radii, blocks, solid_blocks, attachments] = make_convolution_model(segments, mode);
if strcmp(mode, 'joint_limits'), 
    blocks{5} = [5, 6]; blocks{4} = [6, 8]; blocks{6} = [7, 8]; blocks{7} = [5, 7]; 
    solid_blocks{4} = [4, 5, 6, 7];
end

%% Display
if skeleton
    figure; axis equal; axis off; hold on;
    for i = 1:length(blocks),
        myline(centers{blocks{i}(1)}, centers{blocks{i}(2)}, 'k');
        if length(blocks{i}) == 3
            myline(centers{blocks{i}(1)}, centers{blocks{i}(3)}, 'k');
            myline(centers{blocks{i}(2)}, centers{blocks{i}(3)}, 'k');
        end
    end
    mypoints(centers, 'k');
else
    display_result_convtriangles(centers, [], [], blocks, radii, true); campos([10, 160, -1500]); camlight;
end

%% Save data
save([data_path, 'solid_blocks.mat'], 'solid_blocks');
save([data_path, 'centers.mat'], 'centers');
save([data_path, 'radii.mat'], 'radii');
save([data_path, 'blocks.mat'], 'blocks');
save([data_path, 'attachments.mat'], 'attachments');
