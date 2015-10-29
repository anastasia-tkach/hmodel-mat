function [centers, radii, blocks, solid_blocks, attachments] = make_convolution_model(segments, mode)

blocks = {0, 1};
centers = cell(0, 1);
radii = cell(0, 1);
attachments = cell(0, 1);

%% Finger model
if strcmp(mode, 'finger')
    for i = 1:length(segments)
        V = transform(segments{i}.V, segments{i}.global);
        centers{i} = V(:, end - 1);
        radii{i} = segments{i}.radius1 + randn/1000;
    end
    centers{4} =  V(:, end);
    radii{4} = segments{3}.radius2 + randn/1000;
    blocks = {[1, 2]; [2, 3]; [3, 4]};
    blocks = reindex(radii, blocks);
    solid_blocks = {[1], [2], [3]};
    return
end

%% Full hand model
for i = 1:length(segments)
    V = transform(segments{i}.V, segments{i}.global);
    centers{2 + 2 * (i - 1) + 1} = V(:, end - 1);
    centers{2 + 2 * i} = V(:, end);
    radii{2 + 2 * (i - 1) + 1} = segments{i}.radius1 + randn/1000;
    radii{2 + 2 * i} = segments{i}.radius2 + randn/1000;
    blocks{1 + i} = [2 + 2 * (i - 1) + 1, 2 + 2 * i];
end
radii{1} = 0.3 * radii{3} + randn/1000; radii{2} = 0.3 * radii{4} + randn/1000;
radii{3} = 0.3 * radii{3} + randn/1000; radii{4} = 0.3 * radii{4} + randn/1000;
centers{1} = centers{3} - 25 * [1; 0; 0];
centers{2} = centers{4} - 25 * [1; 0; 0];
centers{3} = centers{3} + 25 * [1; 0; 0];
centers{4} = centers{4} + 25 * [1; 0; 0];
blocks{1} = [1, 2, 3]; blocks{2} = [2, 3, 4];

switch mode
    case 'palm_finger'
        J = [10, 8, 6, 5, 4, 2, 3, 1];
        new_centers = cell(0, 1); new_radii = cell(0, 1);
        for i = 1:length(J)
            new_centers{i} = centers{J(i)};
            new_radii{i} = radii{J(i)};
        end
        blocks = {[1, 2], [2, 3], [3, 4], [5, 6, 7], [6, 7, 8]};
        centers = new_centers; radii = new_radii;
        blocks = reindex(radii, blocks);
        solid_blocks = {[1], [2], [3], [4, 5]};
        
        %% Attachments
        attachments = cell(length(centers), 1);
        attachments{4}.indices = [5, 6];
        
    case 'hand'
        J = [16, 14, 12, 11, 22, 20, 18, 17, 28, 26, 24, 23, 34, 32, 30, 29, 10, 8, 6, 5, 4, 2, 3, 1];
        new_centers = {}; new_radii = {};
        for i = 1:length(J)
            new_centers{i} = centers{J(i)};
            new_radii{i} = radii{J(i)};
        end
        blocks = {[1, 2], [2, 3], [3, 4], [5, 6], [6, 7], [7, 8], [9, 10], [10, 11], [11, 12]...
            [13, 14], [14, 15], [15, 16], [17, 18], [18, 19], [19, 20], [21, 22, 23], [22, 23, 24]};
        
        centers = new_centers; radii = new_radii;
        blocks = reindex(radii, blocks);
        
        solid_blocks = {[1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16, 17]};
        
        %% Attachments
        attachments = cell(length(centers), 1);
        
        attachments{4}.indices = [21, 22]; %attachments{4}.weights = [0.05, 0.95];
        attachments{8}.indices = [21, 22]; %attachments{8}.weights = [0.34, 0.66];
        attachments{12}.indices = [21, 22]; %attachments{12}.weights = [0.66, 0.34];
        attachments{16}.indices = [21, 22]; %attachments{16}.weights = [0.95, 0.05];
        attachments{20}.indices = [22, 23]; %attachments{20}.weights = [0.1, 0.9];
        
end

for i = 1:length(attachments)
    if isempty(attachments{i}), continue; end
    [~, projections, ~] = compute_skeleton_projections({centers{i}}, centers, {attachments{i}.indices});
    attachments{i}.axis_projection = projections{1};
    beta  = norm(attachments{i}.axis_projection - centers{attachments{i}.indices(1)}) / ...
        norm(centers{attachments{i}.indices(2)} - centers{attachments{i}.indices(1)});
    alpha  = norm(attachments{i}.axis_projection - centers{attachments{i}.indices(2)}) /...
        norm(centers{attachments{i}.indices(2)} - centers{attachments{i}.indices(1)});
    attachments{i}.weights = [alpha, beta];
    attachments{i}.offset =  centers{i}  - attachments{i}.axis_projection;
    attachments{i}.direction = (centers{attachments{i}.indices(2)} - centers{attachments{i}.indices(1)}) / ...
        norm(centers{attachments{i}.indices(2)} - centers{attachments{i}.indices(1)});
end

D = length(centers{1});
for o = 1:length(attachments)
    if isempty(attachments{o}), continue; end
    attachments{o}.axis_projection = zeros(D, 1);
    for l = 1:length(attachments{o}.indices)
        attachments{o}.axis_projection = attachments{o}.axis_projection + attachments{o}.weights(l) * centers{attachments{o}.indices(l)};
    end
    direction = (centers{attachments{o}.indices(2)} - centers{attachments{o}.indices(1)}) / ...
        norm(centers{attachments{o}.indices(2)} - centers{attachments{o}.indices(1)});
    rotation = vrrotvec2mat(vrrotvec(attachments{o}.direction, direction));
    centers{o} = attachments{o}.axis_projection + rotation * attachments{o}.offset;
end
