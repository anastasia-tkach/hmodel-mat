clear
data_path = '_data/htrack_model/collision_palm/';
mode = 'hand';
skeleton = false;

%% Get model
segments = create_ik_model(mode);
[centers, radii, blocks, solid_blocks, attachments] = make_convolution_model(segments, mode);

%% Collisions
theta = zeros(26, 1); theta(24) = -2*pi/3; theta(25:26) = -pi/2;
[segments, joints] = pose_ik_model(segments, theta, false, mode);
[centers, radii, blocks, solid_blocks] = make_convolution_model(segments, mode);

%% Save data
save([data_path, 'solid_blocks.mat'], 'solid_blocks');
save([data_path, 'centers.mat'], 'centers');
save([data_path, 'radii.mat'], 'radii');
save([data_path, 'blocks.mat'], 'blocks');
save([data_path, 'attachments.mat'], 'attachments');
display_result_convtriangles(centers, [], [], blocks, radii, true); campos([10, 160, -1500]); camlight;
