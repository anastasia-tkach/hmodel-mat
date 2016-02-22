function [model_point, model_index, axis_point, min_distance] = projeciton_group(p, centers, radii, blocks, tangent_points, camera_ray, verbose)

if verbose
    figure; hold on; axis off; axis equal;
    display_skeleton(centers, radii, blocks, [], false, []);
    mypoint(p, 'k');
end

min_distance = inf;
skeleton = cell(length(blocks), 1);
indices = cell(length(blocks), 1);
projections = cell(length(blocks), 1);
for j = 1:length(blocks)
    
    %% Convtriangle
    if length(blocks{j}) == 3
        c1 = centers{blocks{j}(1)}; c2 = centers{blocks{j}(2)}; c3 = centers{blocks{j}(3)};
        r1 = radii{blocks{j}(1)}; r2 = radii{blocks{j}(2)}; r3 = radii{blocks{j}(3)};
        [indices{j}, projections{j}, skeleton{j}, tangent_points{j}] =...
            projection_convtriangle_frontfacing(p, c1, c2, c3, r1, r2, r3, blocks{j}, tangent_points{j}, camera_ray);
    end
    
    %% Convsegment
    if length(blocks{j}) == 2
        c1 = centers{blocks{j}(1)}; c2 = centers{blocks{j}(2)};
        r1 = radii{blocks{j}(1)}; r2 = radii{blocks{j}(2)};
        [q, s, index] = project_skewed_point_on_segment(p, c1, c2, r1, r2, blocks{j}(1), blocks{j}(2));
        skeleton{j} = s;
        indices{j} = index;
        projections{j} = q;
    end
    
end

%% Find the answer
for j = 1:length(indices)
    
    distance = sign(norm(p - skeleton{j}) - norm(projections{j} - skeleton{j})) * norm(p - projections{j});
    if length(indices{j}) == 3
        if verbose
            myline(centers{indices{j}(1)}, centers{indices{j}(2)}, 'r');
            myline(centers{indices{j}(1)}, centers{indices{j}(3)}, 'r');
            myline(centers{indices{j}(2)}, centers{indices{j}(3)}, 'r');
        end
    end
    if length(indices{j}) == 2 || length(indices{j}) == 1
        is_closest = true;
        for k = 1:length(blocks)
            if all(ismember(indices{j}, blocks{k}))
                if ~all(ismember(indices{k}, indices{j}))
                    is_closest = false;
                end
            end
        end
        if is_closest == false, continue; end
        if verbose
            if length(indices{j}) == 2, myline(centers{indices{j}(1)}, centers{indices{j}(2)}, 'r');
            else scatter3(centers{indices{j}(1)}(1), centers{indices{j}(1)}(2), centers{indices{j}(1)}(3), 50, 'r', 'o', 'filled'); end
        end
    end
    
    %% Find min distance
    if distance < min_distance
        model_index = indices{j};
        model_point = projections{j};
        axis_point = skeleton{j};
        min_distance = distance;
    end
end

if verbose
    scatter3(axis_point(1), axis_point(2), axis_point(3), 50, 'k', 'o', 'filled');
    scatter3(p(1), p(2), p(3), 50, 'm', 'o', 'filled');
    scatter3(model_point(1), model_point(2),model_point(3), 50, 'b', 'o', 'filled');
    myline(p, axis_point, 'k');
end

%% Deal with backfacing by closest triangles
if camera_ray' * (model_point - axis_point) / norm(model_point - axis_point) > 0
    min_distance = inf;
    model_point = [inf; inf; inf];
    for k = 1:length(blocks)
        if length(blocks{k}) == 2, continue; end
        if all(ismember(model_index, blocks{k}))
            v1 = tangent_points{k}.v1; v2 = tangent_points{k}.v2; v3 = tangent_points{k}.v3;
            q = project_point_on_triangle(p, v1, v2, v3);
            distance = norm(p - q);
            if distance < min_distance
                min_distance = distance;
                model_point = q;
                model_index =  blocks{k};
            end
        end
    end
end
