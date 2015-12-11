function [poses, radii] = adjust_poses_scales(poses, blocks, verbose)

%% Compute scales
num_finger_segments = 15;
if verbose, figure; hold on; end
for p = 1:length(poses)
    poses{p}.edges_length = zeros(num_finger_segments, 1);
    for i =  1:num_finger_segments
        poses{p}.edges_length(i) = norm(poses{p}.centers{blocks{i}(2)} - poses{p}.centers{blocks{i}(1)});
    end
    poses{p}.scaling_factor = trimmean(poses{1}.edges_length ./ poses{p}.edges_length, 33);
    disp(poses{p}.scaling_factor);
    if verbose, stem(poses{p}.edges_length, 'filled', 'lineWidth', 2); end
end
for p = 1:length(poses)
    for i =  1:length(poses{p}.centers)
        poses{p}.centers{i} = poses{p}.scaling_factor * poses{p}.centers{i};
        poses{p}.radii{i} = poses{p}.scaling_factor * poses{p}.radii{i};
    end
    for i = 1:length(poses{p}.points)
        poses{p}.points{i} = poses{p}.scaling_factor * poses{p}.points{i};
    end
end
radii = cell(length(poses{1}.centers), 1);
for i = 1:length(radii)
    radii{i} = 0;
    for p = 1:length(poses)
        radii{i} = radii{i} + poses{p}.radii{i};
    end
    radii{i} = radii{i} / length(poses);
end
for p = 1:length(poses)
    poses{p} = rmfield(poses{p}, 'radii');
    poses{p} = rmfield(poses{p}, 'scaling_factor');
end

%% Display results
if verbose
    figure; hold on;
    for p = 1:length(poses)
        poses{p}.edges_length = zeros(num_finger_segments, 1);
        for i =  1:num_finger_segments
            poses{p}.edges_length(i) = norm(poses{p}.centers{blocks{i}(2)} - poses{p}.centers{blocks{i}(1)});
        end
        stem(poses{p}.edges_length, 'filled', 'lineWidth', 2);
        poses{p} = rmfield(poses{p}, 'edges_length');
    end
    
    for p = 1:length(poses)
        figure; axis off; axis equal; hold on;
        display_skeleton(poses{p}.centers, radii, blocks, [], false, []);
        mypoints(poses{p}.points, 'b');
        for i = 1:length(poses{p}.centers)
            draw_sphere(poses{p}.centers{i}, radii{i}, 'c');
        end
    end
end

