D = 3;
[centers, radii, blocks] = get_random_convtriangle();
%[centers, radii, blocks] = get_random_convsegment();


n = 60; color = [0.2, 0.8, 0.8];
model_bounding_box = compute_model_bounding_box(centers, radii);
xm = linspace(model_bounding_box.min_x, model_bounding_box.max_x, n);
ym = linspace(model_bounding_box.min_y, model_bounding_box.max_y, n);
zm = linspace(model_bounding_box.min_z, model_bounding_box.max_z, n);
[x, y, z] = meshgrid(xm,ym,zm);
N = numel(x);
P = [reshape(x, N, 1), reshape(y, N, 1), reshape(z, N, 1)];
distances = zeros(N, 1);
tangent_points = blocks_tangent_points(centers, blocks, radii);

figure; hold on;
for i = 1:length(blocks)
    if length(blocks{i}) == 2
        c1 = centers{blocks{i}(1)}; c2 = centers{blocks{i}(2)};
        r1 = radii{blocks{i}(1)}; r2 = radii{blocks{i}(2)};
        distances = distance_to_model_convsegment(c1, c2, r1, r2, P');
        %distances = distance_to_model_convsegment_matlab(c1, c2, r1, r2, P');
    end
    if length(blocks{i}) == 3
        c1 = centers{blocks{i}(1)}; c2 = centers{blocks{i}(2)}; c3 = centers{blocks{i}(3)};
        r1 = radii{blocks{i}(1)}; r2 = radii{blocks{i}(2)}; r3 = radii{blocks{i}(3)};
        v1 = tangent_points{i}.v1; v2 = tangent_points{i}.v2; v3 = tangent_points{i}.v3;
        u1 = tangent_points{i}.u1; u2 = tangent_points{i}.u2; u3 = tangent_points{i}.u3;
        distances = distance_to_model_convtriangle(c1, c2, c3, r1, r2, r3, v1, v2, v3, u1, u2, u3, P');
        %distances = distance_to_model_convtriangle_matlab(c1, c2, c3, r1, r2, r3, v1, v2, v3, u1, u2, u3, P');
    end
    distances = reshape(distances, size(x));
    %% Making the 3D graph of the 0-level surface of the 4D function "fun":
    h = patch(isosurface(x, y, z, distances,0));
    isonormals(x, y, z, distances, h);
    set(h,'FaceColor',color,'EdgeColor','none', 'FaceAlpha', 1);
    grid off; view([1,1,1]); axis equal; camlight; lighting gouraud; axis off;
end


%% Gradients at random point
p = rand(D, 1);

[tangent_gradients] = jacobian_tangent_planes(centers, blocks, radii, {'c1', 'c2', 'c3', 'r1', 'r2', 'r3'});
[index, q, ~, is_inside] = projection(p, blocks{1}, radii, centers, tangent_points{1});

if length(index) == 1
    variables = {'c1'};
    [q, dq] = jacobian_sphere(q, centers{index(1)}, radii{index(1)}, variables);    
end
if length(index) == 2
    variables = {'c1', 'c2'};
    [q, dq] = jacobian_convsegment(q, centers{index(1)}, centers{index(2)}, radii{index(1)}, radii{index(2)}, variables);
end
if length(index) == 3
    variables = {'c1', 'c2', 'c3'};
    v1 = tangent_gradients{1}.v1; v2 = tangent_gradients{1}.v2; v3 = tangent_gradients{1}.v3;
    u1 = tangent_gradients{1}.u1; u2 = tangent_gradients{1}.u2; u3 = tangent_gradients{1}.u3;
    Jv1 = tangent_gradients{1}.Jv1; Jv2 = tangent_gradients{1}.Jv2; Jv3 = tangent_gradients{1}.Jv3;
    Ju1 = tangent_gradients{1}.Ju1; Ju2 = tangent_gradients{1}.Ju2; Ju3 = tangent_gradients{1}.Ju3;
    if (index(1) > 0)
        [q, dq] = jacobian_convtriangle(q, v1, v2, v3, Jv1, Jv2, Jv3, variables);
    else
        [q, dq] = jacobian_convtriangle(q, u1, u2, u3, Ju1, Ju2, Ju3, variables);
    end
end




