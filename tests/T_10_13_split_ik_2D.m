clear; clc; close all;
settings.D = 2;
D = settings.D;
c1 = 7 * rand(D, 1);
c2 = 7 * rand(D, 1);
c3 = 7 * rand(D, 1);
r1 = rand(1,  1);
r2 = rand(1, 1);
r3 = rand(1, 1);
p = 7 * rand(D, 1);

skeleton = true;

%% Set up data structures
blocks{1} = [1, 2];
blocks{2} = [2, 3];
centers = {c1; c2; c3};
radii = {r1; r2; r3};
points{1} = p;

num_rotations = 1;

initial = [1; 0];
R  = @(x) [cos(x), -sin(x); sin(x), cos(x)];

%% Change data structure
[blocks] = reindex(radii, blocks);
num_blocks = length(blocks);
split_centers = cell(num_blocks, 1);
split_blocks = cell(num_blocks, 1);
split_radii = cell(num_blocks, 1);
count = 1;

connections = cell(length(centers), 1);
base_indices = cell(length(centers), 1);

for i = 1:num_blocks
    split_centers{i} = centers{blocks{i}(1)};
    split_radii{i} = radii{blocks{i}(1)};
    split_blocks{i} = i;
    base_indices{i} = i;
    connections{blocks{i}(1)} = [connections{blocks{i}(1)}, i];
    for j = 2:length(blocks{i})
        split_centers{num_blocks + count} = centers{blocks{i}(j)};
        split_radii{num_blocks + count} = radii{blocks{i}(j)};
        split_blocks{i} = [split_blocks{i}, num_blocks + count];
        connections{blocks{i}(j)} = [connections{blocks{i}(j)}, num_blocks + count];
        base_indices{num_blocks + count} = i;
        count = count + 1;
    end
end
squeezed_connections = {};
count = 1;
for i = 1:length(connections)
    if length(connections{i}) > 1
        squeezed_connections{count} = connections{i};
        count = count + 1;
    end
end
connections = squeezed_connections;




%% Optimization
history = {};
iter = 0;
num_iter = 4;
while true
    iter = iter + 1;
    
    if skeleton, [model_indices, projections, block_indices] = compute_skeleton_projections(points, split_centers, split_blocks, split_radii);
    else
        if settings.D == 2, [model_indices, projections, block_indices] = compute_projections_matlab(points, split_centers, split_blocks, split_radii); end
    end
    
    if length(model_indices{1}) == 2 || model_indices{1}(1) == split_blocks{block_indices{1}}(1)
        model_indices{1}
        disp('retry')
        points{1} = 10 * rand(D, 1);
        p = points{1};
        iter = iter - 1;
        continue;
    end
    
    %if (iter <= num_iter)      
    figure; hold on; axis equal; axis off;
        %display_result_2D(pose, split_blocks, split_radii, true); drawnow;
        for i = 1:length(split_blocks)
            %draw_circle(split_centers{split_blocks{i}(1)}, split_radii{split_blocks{i}(1)}, 'b');
            %draw_circle(split_centers{split_blocks{i}(2)}, split_radii{split_blocks{i}(2)}, 'b');
            myline(split_centers{split_blocks{i}(1)}, split_centers{split_blocks{i}(2)}, 'b');
            for j = 1:length(split_blocks{i})
                mypoint(split_centers{split_blocks{i}(j)}, 'b');
            end
        end
        myline(points{1}, projections{1}, 'g');
        mypoint(points{1}, 'm');
        mypoint(projections{1}, 'g');
        %xlimit = xlim; ylimit = ylim;
        %xlim(xlimit + [-0.5, 0.5]); ylim(ylimit + [-0.5, 0.5]);
        waitforbuttonpress;
        
    %end
    if (iter > num_iter) break; end
    
    %% Compute new parametrization
    angles = cell(2, 1);
    distances = cell(2, 1);
    for i = 1:length(split_blocks)
        u = split_centers{split_blocks{i}(2)} - split_centers{split_blocks{i}(1)};
        distances{i} = norm(u);
        u = u / norm(u);
        angles{i}  = atan2(u(2), u(1));
    end
    
    [F, Jc, Ja] = jacobian_ik(split_centers, split_radii, distances, angles, split_blocks, block_indices, points, model_indices, points, base_indices, D);    
    J = [Jc, Ja];
    
    
    I = 0.1 * ones(D * num_blocks + num_rotations * num_blocks, 1);
    %I(1:D * num_blocks) = 0.1; I(D * num_blocks + 1:end) = 2;
    I = diag(I);
    
    delta = - ((J' * J) + I ) \ (J' * F);

    %% Apply update
    for o = 1:num_blocks
        split_centers{o} = split_centers{o} + delta(D * o - D + 1:D * o);
    end
    for o = 1:num_blocks % rewrite for 3 rotations
        angles{o} = angles{o} + delta(D * num_blocks + o);
    end
    for o = 1:length(split_blocks) % rewrite for 3 rotations
        split_centers{split_blocks{o}(2)} =  split_centers{o} + distances{o} * R(angles{o}) * initial;
    end
    %disp(['energy = ', num2str(F' * F)]);
    
    %% Display
    %     if (iter < num_iter)
    %         pose.points = points;
    %         pose.centers = split_centers;
    %         figure; axis equal; axis off; hold on;
    %         %display_result_2D(pose, split_blocks, split_radii, true); drawnow;
    %         for i = 1:length(split_blocks)
    %             %draw_circle(split_centers{split_blocks{i}(1)}, split_radii{split_blocks{i}(1)}, 'b');
    %             %draw_circle(split_centers{split_blocks{i}(2)}, split_radii{split_blocks{i}(2)}, 'b');
    %             myline(split_centers{split_blocks{i}(1)}, split_centers{split_blocks{i}(2)}, 'b');
    %             for j = 1:length(split_blocks{i})
    %                 mypoint(split_centers{split_blocks{i}(j)}, 'b');
    %             end
    %         end
    %         mypoint(points{1}, 'm');
    %         xlim(xlimit + [-0.5, 0.5]); ylim(ylimit + [-0.5, 0.5]);
    %         waitforbuttonpress;
    %     end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %% Add topological constraints
    %     num_connections = length(connections);
    %     F = zeros(num_connections, 1);
    %     Jc = zeros(num_connections, num_blocks * D);
    %     Ja = zeros(num_connections, num_blocks * num_rotations);
    %     for o = 1:length(connections) % rewrite for 3D
    %         indexi = connections{o}(1);
    %         indexj = connections{o}(2);
    %         ci = split_centers{base_indices{indexi}};
    %         cj = split_centers{base_indices{indexj}};
    %         ui = split_centers{indexi} - split_centers{base_indices{indexi}}; di = norm(ui);
    %         uj = split_centers{indexj} - split_centers{base_indices{indexj}}; dj = norm(uj);
    %         ui = ui / norm(ui); ai = atan2(ui(2), ui(1));
    %         uj = uj / norm(uj); aj = atan2(uj(2), uj(1));
    %         if di == 0, ai = 0; end
    %         if dj == 0, aj = 0; end
    %         [f, df] = jacobian_ik_shape(ci, cj, ai, aj, di, dj);
    %
    %         F(o) = f;
    %         Jc(o, D * base_indices{indexi} - D + 1:D * base_indices{indexi}) = df.dci;
    %         Jc(o, D * base_indices{indexj} - D + 1:D * base_indices{indexj}) = df.dcj;
    %         Ja(o, base_indices{indexi}) = df.dai;
    %         Ja(o, base_indices{indexj}) = df.daj;
    %     end
    %     J = [Jc, Ja];
    %     I = ones(D * num_blocks + num_rotations * num_blocks, 1);
    %     I = diag(I);
    %     delta = - ((J' * J) + I ) \ (J' * F);
    %
    %     %% Apply update
    %     for o = 1:num_blocks
    %         split_centers{o} = split_centers{o} + delta(D * o - D + 1:D * o);
    %     end
    %     for o = 1:num_blocks % rewrite for 3 rotations
    %         angles{o} = angles{o} + delta(D * num_blocks + o);
    %     end
    %     for o = 1:length(split_blocks) % rewrite for 3 rotations5
    %         split_centers{split_blocks{o}(2)} =  split_centers{o} + distances{o} * R(angles{o}) * initial;
    %     end
    %
    disp(['energy = ', num2str(F' * F)]);
    
    
end





