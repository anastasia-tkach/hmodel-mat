clear
data_path = '_data/htrack_model/joint_limits_hand/';
mode = 'hand';
skeleton = false;

%% Get model
segments = create_ik_model(mode);
[centers, radii, blocks, solid_blocks, attachments] = make_convolution_model(segments, mode);
if strcmp(mode, 'joint_limits'), 
    blocks{4} = [5, 6]; blocks{5} = [6, 8]; blocks{6} = [7, 8]; blocks{7} = [5, 7]; 
    solid_blocks{4} = [4, 5, 6, 7];
end
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
%display_result_convtriangles(centers, [], [], blocks, radii, true); campos([10, 160, -1500]); camlight;

%% Create posed data
switch mode
    case 'finger'
        theta = zeros(8, 1); theta(4) = pi/5; theta(7) = pi/5; theta(8) = pi/5;
    case 'palm_finger'
        theta = zeros(10, 1); theta(8:10) = -pi/4;
    case 'hand'
        theta = zeros(26, 1); %theta(3) = 10; theta(5) = pi/3; theta(24:26) = -pi/6; theta(8:10) = -pi/6;
    case 'joint_limits'
        theta = zeros(12, 1); theta(4) = pi/6; theta(10) = pi/6;
end
[segments, joints] = pose_ik_model(segments, theta, false, mode);
[centers, radii, blocks, solid_blocks, attachments] = make_convolution_model(segments, mode);
if strcmp(mode, 'joint_limits'), 
    blocks{4} = [5, 6]; blocks{5} = [6, 8]; blocks{6} = [7, 8]; blocks{7} = [5, 7]; 
    solid_blocks{4} = [4, 5, 6, 7];
end
%save([data_path, 'centers.mat'], 'centers');
if skeleton
    points = sample_skeleton(centers, blocks);
    mypoints(points, 'm'); view(90, 0); drawnow;
    save([data_path, 'points.mat'], 'points');
    normals = cell(length(points), 1); save([data_path, 'normals.mat'], 'normals');    
    return
end

points = generate_convtriangles_points(centers, blocks, radii);
display_result_convtriangles(centers, [], [], blocks, radii, true); campos([10, 160, -1500]); camlight;

%% Find normals, method 1
[indices, projections, ~] = compute_projections(points, centers, blocks, radii);
tangent_points = blocks_tangent_points(centers, blocks, radii);
normals = cell(length(points), 1);
tangent_point = [];
for i = 1:length(points)
    p = points{i};
    if length(indices{i}) == 1
        index = indices{i}(1);
        c1 = centers{index}; r1 = radii{index}; s = c1;
        q = c1 + r1 * (p - c1) / norm(p - c1);
    else
        if length(indices{i}) == 3
            for b = 1:length(blocks)
                if (length(blocks{b}) < 3), continue; end
                abs_index = [abs(indices{i}(1)), abs(indices{i}(2)), abs(indices{i}(3))];
                indicator = ismember(blocks{b}, abs_index);
                if sum(indicator) == 3
                    tangent_point = tangent_points{b};
                    break;
                end
            end
            indices{i} = abs_index;
        end
        [~, q, s, ~] = projection(p, indices{i}, radii, centers, tangent_point);
    end
    normals{i} = (q - s) / norm(q - s);
    %mypoint(q, 'm'); mypoint(s, 'b'); myline(q, s, 'b');
end

mypoints(points, 'm'); myvectors(points, normals, 4, 'b');
save([data_path, 'normals.mat'], 'normals');
save([data_path, 'points.mat'], 'points');


