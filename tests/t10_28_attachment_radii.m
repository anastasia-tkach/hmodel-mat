% clear; clc; close all;
% settings.D = 3;
% D = settings.D;

%% Convolution segment
% C1 = 7 * rand(D, 1);
% C2 = 7 * rand(D, 1);
% C4 = 7 * rand(D, 1);
% alpha = rand; beta = rand;
% d = alpha + beta;
% alpha = alpha / d; beta = beta / d; 
% C3 = alpha * C1 + beta * C2;
% a = rand; b = rand;

%% Convolution triangle
% C1 = 7 * rand(D, 1);
% C2 = 7 * rand(D, 1);
% C3 = 7 * rand(D, 1);
% C5 = 7 * rand(D, 1);
% C6 = 7 * rand(D, 1);
% alpha = rand; beta = rand; gamma = rand;
% d = alpha + beta + gamma;
% alpha = alpha / d; beta = beta / d; gamma = gamma / d;
% C4 = alpha * C1 + beta * C2 + gamma * C3;
% 
% data_points{1} = 7 * rand(D, 1);

% data_points = cell(0, 1);
% for i = 1:100
%     data_points{i} = 7 * rand(D, 1);
% end
radii = {0.51; 0.50; 0.49; 1; 0.8; 0.6};

%% Set up data structures
% blocks = {[1, 2], [3, 4]};
% centers = {C1; C2; C3; C4};
blocks = {[1, 2, 3], [4, 5, 6]};
centers = {C1; C2; C3; C4; C5; C6};
solid_blocks = {1, 2};

%% Set up data structures
edge_indices = cell(length(blocks), 1);
restpose_edges = cell(length(blocks), 1);
k = 1;
for i = 1:length(blocks)
    index = nchoosek(blocks{i}, 2);
    for j = 1:size(index, 1)
        edge_indices{i}{j} = [index(j, :)];
        restpose_edges{k} = centers{edge_indices{i}{j}(2)} - centers{edge_indices{i}{j}(1)};
        k = k + 1;
    end
end
attachments = cell(length(centers), 1);
% attachments{3}.indices = [1, 2];
% attachments{3}.weights = [alpha, beta];

attachments{4}.indices = [1, 2, 3];
attachments{4}.weights = [alpha, beta, gamma];

% [model_indices, model_points, block_indices] = compute_projections(data_points, centers, blocks, radii);
% for i = 1:length(data_points)
%     if length(model_indices{i}) == 3
%         data_points = {data_points{i}};
%         break;
%     end
% end

%% Optimization
for i = 1:3
    %[model_indices, model_points, block_indices] = compute_skeleton_projections(data_points, centers, blocks);
    [model_indices, model_points, block_indices] = compute_projections(data_points, centers, blocks, radii);
    
    
    %% Display
    %figure; axis equal; axis off; hold on; set(gcf,'color','white');
    %mylines(model_points, data_points, [0.75, 0.75, 0.75]);
    %for j = 1:length(blocks), c1 = centers{blocks{j}(1)};  c2 = centers{blocks{j}(2)};
    %    scatter3(c1(1), c1(2), c1(3), 100, [0.1, 0.4, 0.7], 'o', 'filled'); scatter3(c2(1), c2(2), c2(3), 100, [0.1, 0.4, 0.7], 'o', 'filled');
    %    line([c1(1), c2(1)], [c1(2), c2(2)], [c1(3), c2(3)], 'color', [0.1, 0.4, 0.7], 'lineWidth', 6);
    %    if length(blocks{j}) == 3
    %        c3 = centers{blocks{j}(3)}; scatter3(c3(1), c3(2), c3(3), 100, [0.1, 0.4, 0.7], 'o', 'filled');
    %        line([c1(1), c3(1)], [c1(2), c3(2)], [c1(3), c3(3)], 'color', [0.1, 0.4, 0.7], 'lineWidth', 6);
    %        line([c2(1), c3(1)], [c2(2), c3(2)], [c2(3), c3(3)], 'color', [0.1, 0.4, 0.7], 'lineWidth', 6);
    %    end
    %end; mypoints(data_points, [0.9, 0.3, 0.5]);view(90, 0); drawnow;
    display_result_convtriangles(centers, data_points, model_points, blocks, radii, true); view([-47, 90]); camlight; drawnow;
    
    %% Compute jacobians
    %[f1, J1] = jacobian_arap_translation(centers, radii, blocks, data_points, model_indices, data_points, D);
    [f1, J1] = jacobian_arap_translation_attachment(centers, radii, blocks, model_points, model_indices, data_points, attachments, D);
    %[f1, J1] = jacobian_arap_translation_skeleton(centers, model_points, model_indices, data_points, D);
    %[f1, J1] = jacobian_arap_translation_skeleton_attachment(centers, model_points, model_indices, data_points, attachments, D);
    
    %[f2, J2] = jacobian_arap_rotation(centers, blocks, edge_indices, restpose_edges, solid_blocks, D);
    [f2, J2] = jacobian_arap_rotation_attachment(centers, blocks, edge_indices, restpose_edges, solid_blocks, attachments, D);
    
    %% Solve
    %J1(:, 1:3) = 0;
    %J2(:, 1:3) = 0;
    I = eye(D * length(centers), D * length(centers));
    w1 = 1; w2 = 10; damping = 0.001;
    LHS = damping * I + w1 * (J1' * J1) + w2 * (J2' * J2);
    RHS = w1 * (J1' * f1) + w2 * (J2' * f2);
    delta = - LHS \ RHS;
    
    %% Apply update
    for o = 1:length(centers)
        centers{o} = centers{o} + delta(D * o - D + 1:D * o);
    end
    %for o = 1:length(attachments)
        %if ~isempty(attachments{o})
            %centers{o} = zeros(D, 1);
            %for l = 1:length(attachments{o}.indices)
                %centers{o} = centers{o} + attachments{o}.weights(l) * centers{attachments{o}.indices(l)};
            %end
        %end
    %end
    disp([f1' * f1, f2' * f2]);
end






