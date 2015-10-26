data_path = '_data/htrack_model/rotation_experiments/';
skeleton = true; mode = 'finger';
load([data_path, 'blocks.mat']); 
load([data_path, 'centers.mat']);

%% Display
figure; axis equal; axis off; hold on; set(gcf,'color','white');
for j = 1:length(blocks), c1 = centers{blocks{j}(1)};  c2 = centers{blocks{j}(2)};
    scatter3(c1(1), c1(2), c1(3), 100, [0.1, 0.4, 0.7], 'o', 'filled'); scatter3(c2(1), c2(2), c2(3), 100, [0.1, 0.4, 0.7], 'o', 'filled');
    line([c1(1), c2(1)], [c1(2), c2(2)], [c1(3), c2(3)], 'color', [0.1, 0.4, 0.7], 'lineWidth', 6);
end; 
view(90, 0); drawnow;

%% Segment 1
i = 0; segments = {};
i = i + 1;
segments{i}.parent_id = 0;
segments{i}.children_ids = [2];
segments{i}.local = eye(4, 4);
segments{i}.kinematic_chain = [];

%% Segment 2
i = i + 1;
segments{i}.parent_id = 1;
segments{i}.children_ids = [3];
segments{i}.local = eye(4, 4);
segments{i}.kinematic_chain = [1];

%% Segment 3
i = i + 1;
segments{i}.parent_id = 2;
segments{i}.children_ids = [];
segments{i}.local = eye(4, 4);
segments{i}.kinematic_chain = [2];

%% Set restpose segment
initial = [0; 1; 0];
for i = 1:length(segments)
    segments{i}.restpose = norm(centers{blocks{i}(2)} - centers{blocks{i}(1)}) * initial;
end


for i = 1:length(segments)
    e = centers{blocks{i}(2)} - centers{blocks{i}(1)};
    segments{i}.global = vrrotvec2mat(vrrotvec(initial, e));
end


segments{2}.local = segments{1}.global' * segments{2}.global;
segments{3}.local = segments{2}.global' * segments{3}.global;
