function [Fn, Jn] = collisions_energy(centers, radii, blocks, attachments, adjacency_matrix, settings)

D = settings.D;

%% Find max. penetration
tangent_points = blocks_tangent_points(centers, blocks, radii);

data_points = cell(0, 1); model_points = cell(0, 1);
data_normals = cell(0, 1); model_indices = cell(0, 1);
k = 1;
for i = 1:14%length(blocks)-1
    for j = i + 1:15%length(blocks)
        if adjacency_matrix(i, j), continue; end
        
        [p, surface_p, q, surface_q, is_colliding] = get_collision_constraints_convtriangles(centers, radii, blocks{i}, blocks{j}, tangent_points{j});
        if ~is_colliding, continue; end
        
        data_point = (surface_p + surface_q) / 2;
        
        model_points{k} = surface_p; data_points{k} = data_point;       
        normal = compute_model_normals_temp(centers, {blocks{j}}, radii, {surface_q}, []); data_normals{k} = normal{1};
        
        [model_index, ~, ~] = compute_projections({model_points{k}}, centers, {blocks{i}}, radii); model_indices{k} = model_index{1};
        k = k + 1;
        
        model_points{k} = surface_q; data_points{k} = data_point;
        normal = compute_model_normals_temp(centers, {blocks{i}}, radii, {surface_p}, []); data_normals{k} = normal{1};
        
        [model_index, ~, ~] = compute_projections({model_points{k}}, centers, {blocks{j}}, radii); model_indices{k} = model_index{1};
        k = k + 1;
        
        %% Only one block moves
        %{
        model_points{k} = surface_p; data_points{k} = surface_q;
        normal = compute_model_normals_temp({data_points{k}}, centers, {blocks{j}}, radii); data_normals{k} = normal{1};
        [model_index, ~, ~] = compute_projections({model_points{k}}, centers, {blocks{i}}, radii); model_indices{k} = model_index{1};
        k = k + 1;
        %}
        
        %% Display collision
        %{
        mypoints(centers, 'b');
        myline(centers{blocks{i}(1)}, centers{blocks{i}(2)}, 'b'); myline(centers{blocks{j}(1)}, centers{blocks{j}(2)}, 'b');
        if length(blocks{i}) == 3
          myline(centers{blocks{i}(1)}, centers{blocks{i}(3)}, 'b'); myline(centers{blocks{i}(2)}, centers{blocks{i}(3)}, 'b');
        end
        if length(blocks{j}) == 3
          myline(centers{blocks{j}(1)}, centers{blocks{j}(3)}, 'b'); myline(centers{blocks{j}(2)}, centers{blocks{j}(3)}, 'b');
        end
        myline(p, q, 'k'); mypoint(model_points{k - 1}, 'm'); mypoint(data_points{k - 1}, [0.7, 0.2, 1]);
        myline(data_points{k - 1}, data_points{k - 1} + 10 *
        data_normals{k - 1}, 'g'); drawnow;
        %}
        
    end
end

%% Avoid collision: move the point surface_p to the location surface_q
[F, J] = jacobian_arap_translation_attachment(centers, radii, blocks, model_points, model_indices, data_points, attachments, settings.D);
Fn = zeros(length(data_normals), 1); Jn = zeros(length(data_normals), D * length(centers));
for i = 1:length(data_normals)
    Fn(i) = data_normals{i}' * F(D * (i - 1) + 1:D * i);
    Jn(i, :) = data_normals{i}' * J(D * (i - 1) + 1:D * i, :);
end