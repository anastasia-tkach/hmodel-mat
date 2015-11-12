% close all;
% clear
% D = 3; RAND_MAX = 32767;
% settings.fov = 15;
% downscaling_factor = 6;
% settings.H = 480/downscaling_factor;
% settings.W = 636/downscaling_factor;
% settings.D = D;
% settings.sparse_data = false;
% settings.RAND_MAX = 32767;
% settings.side = 'front';
% settings.view_axis = 'Z';
% closing_radius = 10;
% mode = 'synthetic';
% 
% %% Generate data
% [centers, radii, blocks] = get_random_convtriangle();
% edge_indices = {{[1, 2], [1, 3], [2, 3]}};
% for i = 1:length(radii), radii{i} = radii{i} * 0.5; end
% 
% % [centers, radii, blocks] = get_random_convsegment();
% % edge_indices = {{[1, 2]}};
% 
% data_bounding_box = compute_model_bounding_box(centers, radii);
% model_points  = [];
% [raytracing_matrix, ~, camera_center] = get_raytracing_matrix(centers, radii, data_bounding_box, settings.view_axis, settings, settings.side);
% rendered_model = render_tracking_model(centers, blocks, radii, raytracing_matrix, camera_center, settings);
% 
% [I, J] = find((rendered_model(:, :, 3) > - settings.RAND_MAX));
% N = length(model_points);
% model_points = [model_points; cell(length(I), 1)];
% for k = 1:length(I), model_points{N + k} = squeeze(rendered_model(I(k), J(k), :)); end
% data_points = model_points;
% 
% %% Generate model
% rotation_axis = randn(D, 1);
% rotation_angle = 0.2 * randn;
% translation_vector = - rand * [0; 0; 1];
% R = makehgtform('axisrotate', rotation_axis, rotation_angle);
% T = makehgtform('translate', translation_vector);
% for i = 1:length(centers)
%     centers{i} = transform(centers{i}, R);
%     centers{i} = transform(centers{i}, T);
% end
% tangent_points = blocks_tangent_points(centers, blocks, radii);
% 
% data_bounding_box = compute_data_bounding_box(data_points);
% solid_blocks = {[1]};
% k = 1;
% for i = 1:length(blocks)
%     index = nchoosek(blocks{i}, 2);
%     for j = 1:size(index, 1)
%         restpose_edges{k} = centers{edge_indices{i}{j}(2)} - centers{edge_indices{i}{j}(1)};
%         previous_rotations{k} = eye(3, 3);
%         k = k + 1;
%     end
% end
% initial_centers = centers;

%% Display
close all;
[raytracing_matrix, camera_axis, camera_center] = get_raytracing_matrix(centers, radii, data_bounding_box, settings.view_axis, settings,  settings.side);
rendered_model = render_tracking_model(centers, blocks, radii, raytracing_matrix, camera_center, settings);
[I, J] = find(rendered_model(:, :, 3) > - RAND_MAX);
model_points = cell(length(I), 1);
for k = 1:length(I), model_points{k} = squeeze(rendered_model(I(k), J(k), :)); end

display_result_convtriangles(centers, [], [], blocks, radii, false);
%mypoints(model_points, 'c');

[model_indices, model_points, block_indices] = compute_projections_matlab(data_points, centers, blocks, radii);
normals = compute_model_normals_temp(model_points, centers, blocks, radii);

myline(centers{1}, centers{2}, 'b');
myline(centers{1}, centers{3}, 'b');
myline(centers{3}, centers{2}, 'b');

view([-180, -90]); camlight; drawnow;

c = (centers{1} - centers{2}) / norm(centers{1} - centers{2});

new_model_points = [];
new_data_points = [];
for j = 1:length(data_points)
    d = data_points{j};
    m = model_points{j};
    n = normals{j};
    
    l = (camera_center - m) / norm(camera_center - m);
    
    if n' * l < 0        
        [index, q, s, is_inside] = projection(m, blocks{1}, radii, centers, tangent_points{1});
        
        if length(index) < 3, continue; end
        %mypoint(m, 'b');
        %mypoint(d, 'm');
        %myline(s, m, 'c');
          
%         %c = (centers{model_indices{j}(1)} - centers{model_indices{j}(2)}) / norm(centers{model_indices{j}(1)} - centers{model_indices{j}(2)});
%         
%         %% Find intersection of two planes
%         n1 = l; p1  = s;
%         n2 = c; p2 = s + ((m - s)' * c) * c;
%         A = [n1'; n2']; b = [n1' * p1; n2' * p2];
%         x = A\b;
%         a = cross(n1, n2) / norm(cross(n1, n2));
%         
%         %% Find line - circle intersection
%         b = x - p2;
%         r = norm(m - p2);
%         polynomial = [a' * a; 2 * b' * a; b' * b - r^2];
%         t = roots(polynomial);
%         
%         i1 = x + t(1) * a;
%         i2 = x + t(2) * a;
%         
%         if norm(d - i1) < norm(d - i2), i = i1;5
%         else i = i2; end
%         if ~isreal(i), continue; end
        
        new_model_points{end + 1} = m;
        new_data_points{end + 1} = d;
    else
        %new_model_points{end + 1} = m;
    end
end


mypoints(new_data_points, [0.65, 0.1, 0.5]);
mypoints(new_model_points, [0, 0.7, 1]);
%mylines(new_model_points, new_data_points, [0.75, 0.75, 0.75]);
view([-180, -90]); camlight; drawnow;

% myline(s, s + 0.5 * l, 'g');
% myline(m, s, 'k');
% myline(o, m, 'b');
% myline(o, i, 'r');
% myline(i, s, 'r');
