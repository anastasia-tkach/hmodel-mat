clc; close all; clear; D = 3;
data_path = '_data/htrack_model/joint_limits_hand/';
mode = 'hand';
skeleton = true;

%% Get model
segments = create_ik_model(mode);

% a = [0; 1; 0];
% for i = 1:length(segments)
%     A = segments{i}.local(1:3, 1:3);
%     b = A * a;
%     B = vrrotvec2mat(vrrotvec(a, b));
%     segments{i}.local(1:3, 1:3) = B;
%     segments{i}.global(1:3, 1:3) = B;
% end

% for i = 1:length(segments)
%     if i == 1 || i == 2 || i == 5 || i == 8 || i == 11 || i == 14, continue; end
%     segments{i}.local(1:3, 1:3) = eye(3, 3);
% end
theta = zeros(26, 1);
[segments, joints] = pose_ik_model(segments, theta, false, mode);

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
        theta = 0 * ones(26, 1);
        theta(25:26) = pi/3;
        theta(4:6) = pi/3;
        theta(19) = pi/3;
        %theta([9, 13, 17, 21, 25]) = -pi/24;
    case 'joint_limits'
        theta = zeros(14, 1); 
        theta([8, 9, 12]) = -0.6; 
        theta(7) = 1;
        theta(4:5) = 0.5;
        theta(11) = 1;
end
[segments, joints] = pose_ik_model(segments, theta, false, mode);
[centers, radii, blocks, solid_blocks, attachments] = make_convolution_model(segments, mode);
if strcmp(mode, 'joint_limits'),
    blocks{5} = [5, 6]; blocks{4} = [6, 8]; blocks{6} = [7, 8]; blocks{7} = [5, 7];
    solid_blocks{4} = [4, 5, 6, 7];
end
if skeleton && strcmp(mode, 'hand')
    blocks{16} = [23, 21]; blocks{17} = [23, 24]; blocks{18} = [24, 22]; blocks{19} = [21, 22]; 
    solid_blocks = {};
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
    campos([10, 160, -1500]); camlight; drawnow;
else
    display_result_convtriangles(centers, [], [], blocks, radii, true); campos([10, 160, -1500]); camlight;
end

%% Save data
%restpose_centers = centers;
%save([data_path, 'restpose_centers.mat'], 'restpose_centers');
save([data_path, 'solid_blocks.mat'], 'solid_blocks');
save([data_path, 'centers.mat'], 'centers');
save([data_path, 'radii.mat'], 'radii');
save([data_path, 'blocks.mat'], 'blocks');
save([data_path, 'attachments.mat'], 'attachments');
