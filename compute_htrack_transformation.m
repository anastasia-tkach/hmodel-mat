%% Compute initial transformation for Htrack

theta = zeros(num_parameters, 1);
theta([9, 10, 12, 13, 14, 16, 17, 18, 20, 21, 22, 24, 25, 26]) = -pi/2;
segments = create_ik_model('hand');
for i = 1:length(segments)
    if i == 1 || i == 2 || i == 5 || i == 8 || i == 11 || i == 14, continue; end
    segments{i}.local(1:3, 1:3) = eye(3, 3);
end
[segments, ~] = pose_ik_model(segments, theta, verbose, 'hand');
[htrack_centers, htrack_radii, htrack_blocks, ~, ~] = make_convolution_model(segments, 'hand');
htrack_centers{25} = 0.5 * htrack_centers{23} + 0.5 * htrack_centers{24}; htrack_radii{25} = 0.5 * htrack_radii{23} + 0.5 * htrack_radii{24};
htrack_names_map = containers.Map();
htrack_names_map('HandPinky4') = 1; htrack_names_map('HandPinky3') = 2; htrack_names_map('HandPinky2') = 3; htrack_names_map('HandPinky1') = 4;
htrack_names_map('HandRing4') = 5; htrack_names_map('HandRing3') = 6; htrack_names_map('HandRing2') = 7; htrack_names_map('HandRing1') = 8;
htrack_names_map('HandMiddle4') = 9; htrack_names_map('HandMiddle3') = 10; htrack_names_map('HandMiddle2') = 11; htrack_names_map('HandMiddle1') = 12;
htrack_names_map('HandIndex4') = 13; htrack_names_map('HandIndex3') = 14; htrack_names_map('HandIndex2') = 15; htrack_names_map('HandIndex1') = 16;
htrack_names_map('HandThumb4') = 17; htrack_names_map('HandThumb3') = 18; htrack_names_map('HandThumb2') = 19; htrack_names_map('HandThumb1') = 20;
htrack_names_map('Hand') = 25;

%display_result(htrack_centers, [], [], htrack_blocks, htrack_radii, true, 0.5, 'big');
%mypoints(htrack_centers(1:5), 'r');
%campos([10, 160, -1500]); camlight; drawnow;

%% Compute palm frame
[palm_frame, palm_translation] = compute_principle_axis(htrack_centers(21:24), false);

%% Compute thumb frame
thumb_joints = {htrack_centers{htrack_names_map('HandThumb1')}, htrack_centers{htrack_names_map('HandThumb2')}, ...
    htrack_centers{htrack_names_map('HandThumb3')}, htrack_centers{htrack_names_map('HandThumb4')}};
[thumb_frame, thumb_translation] = compute_principle_axis(thumb_joints, false);
n = thumb_frame(:, 3);
u = htrack_centers{htrack_names_map('HandThumb2')} - htrack_centers{htrack_names_map('HandThumb1')};
v = cross(n, u);
n = cross(v, u);
thumb_frame(:, 1) = v/norm(v); thumb_frame(:, 2) = u/norm(u); thumb_frame(:, 3) = n / norm(n);

%% Align frames
if thumb_frame(:, 1)' * palm_frame(:, 1) < 0
    palm_frame(:, 1) = - palm_frame(:, 1);    
end
if thumb_frame(:, 2)' * palm_frame(:, 2) < 0
    palm_frame(:, 2) = - palm_frame(:, 2);    
end
palm_frame(:, 3) = cross(palm_frame(:, 1), palm_frame(:, 2));

%% Display
% myvector(htrack_centers{htrack_names_map('Hand')}, palm_frame(:, 1), 20, 'r');
% myvector(htrack_centers{htrack_names_map('Hand')}, palm_frame(:, 2), 20, 'g');
% myvector(htrack_centers{htrack_names_map('Hand')}, palm_frame(:, 3), 20, 'b');

% myvector(htrack_centers{htrack_names_map('HandThumb1')}, thumb_frame(:, 1), 20, 'r');
% myvector(htrack_centers{htrack_names_map('HandThumb1')}, thumb_frame(:, 2), 20, 'g');
% myvector(htrack_centers{htrack_names_map('HandThumb1')}, thumb_frame(:, 3), 20, 'b');

% myvector(htrack_centers{htrack_names_map('HandThumb1')}, thumb_frame(:, 1), 20, 'r');
% myvector(htrack_centers{htrack_names_map('HandThumb1')}, thumb_frame(:, 2), 20, 'g');
% myvector(htrack_centers{htrack_names_map('HandThumb1')}, thumb_frame(:, 3), 20, 'b');

% R = find_svd_rotation(palm_frame, thumb_frame); % thumb_frame = R' * palm_frame
% correct_frame = segments{2}.local(1:D, 1:D)' * palm_frame;

% myvector(htrack_centers{htrack_names_map('HandThumb1')}, correct_frame(:, 1), 20, 'm');
% myvector(htrack_centers{htrack_names_map('HandThumb1')}, correct_frame(:, 2), 20, 'y');
% myvector(htrack_centers{htrack_names_map('HandThumb1')}, correct_frame(:, 3), 20, 'c');

%% Rest-pose model
segments = create_ik_model('hand');
for i = 1:length(segments)
    if i == 1 || i == 2 || i == 5 || i == 8 || i == 11 || i == 14, continue; end
    segments{i}.local(1:3, 1:3) = eye(3, 3);
end
initial_segments = segments;
[segments, ~] = pose_ik_model(segments, zeros(num_parameters, 1), verbose, 'hand');
[htrack_centers, htrack_radii, htrack_blocks, ~, ~] = make_convolution_model(segments, 'hand');
up = [0; 1; 0];
htrack_centers{25} = 0.5 * htrack_centers{23} + 0.5 * htrack_centers{24}; htrack_radii{25} = 0.5 * htrack_radii{23} + 0.5 * htrack_radii{24};
for i = 1:length(segments)
    segments{i}.local = eye(D + 1, D + 1);
end

%% Compute local transformation
for i = 1:length(segments)
    
    p = segments{i}.parent_id;
    c = segments{i}.children_ids;
    
    if isempty(p), continue; end
    
    if isempty(c)
        child_name = segments{i}.end_name;
    else
        child_name = segments{c}.name;
    end
    v = htrack_centers{htrack_names_map(child_name)} - htrack_centers{htrack_names_map(segments{i}.name)};
    if length(segments{i}.kinematic_chain) == 8
        R = vrrotvec2mat(vrrotvec(up, v));
        if strcmp(segments{i}.name, 'HandThumb1')
            R = find_svd_rotation(palm_frame, thumb_frame);
        end
    elseif length(segments{i}.kinematic_chain) > 8
        u = htrack_centers{htrack_names_map(segments{i}.name)} - htrack_centers{htrack_names_map(segments{p}.name)};
        R = vrrotvec2mat(vrrotvec(u, v));
    end
    segments{i}.local(1:D, 1:D) = R;
    
    segments = update_transform(segments, i);
    
    t = htrack_centers{htrack_names_map(segments{i}.name)} - htrack_centers{htrack_names_map(segments{p}.name)};
    T = segments{p}.global(1:D, 1:D)' * t;
    segments{i}.local(1:D, D + 1) = T;
end
for i = 1:length(segments), disp(segments{i}.name); disp([initial_segments{i}.local segments{i}.local]); end

%% Recompute centers positions
[segments, ~] = pose_ik_model(segments, theta, verbose, 'hand');
for i = 1:length(segments)
    htrack_centers{htrack_names_map(segments{i}.name)} = segments{i}.global(1:D, D + 1);
    if isfield(segments{i}, 'end_name')
        htrack_centers{htrack_names_map(segments{i}.end_name)} = ...
            htrack_centers{htrack_names_map(segments{i}.name)} + segments{i}.global(1:D, 1:D) * segments{i}.length * up;
    end
end

display_result(htrack_centers, [], [], htrack_blocks, htrack_radii, true, 1, 'big');
mypoints(htrack_centers(1:5), 'r');
campos([10, 160, -1500]); camlight; drawnow;

