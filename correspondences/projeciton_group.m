function [model_point, model_index, axis_point, block_index, min_distance] = projeciton_group(p, centers, radii, blocks, tangent_points, neighbors, neighbors_array, camera_ray, verbose, debug)
C = 50;
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
    
    if debug
        disp(j-1);
        disp(projections{j}');
        disp(skeleton{j}');
        disp(indices{j}-1);
        disp(' ');
    end
    
end

%% Find the answer
for j = 1:length(indices)
    distance = sign(norm(p - skeleton{j}) - norm(projections{j} - skeleton{j})) * norm(p - projections{j});
    %if length(indices{j}) == 3
    %   if verbose
    %       myline(centers{indices{j}(1)}, centers{indices{j}(2)}, 'r');
    %       myline(centers{indices{j}(1)}, centers{indices{j}(3)}, 'r');
    %       myline(centers{indices{j}(2)}, centers{indices{j}(3)}, 'r');
    %   end
    %end
    if length(indices{j}) == 2 || length(indices{j}) == 1
        %% Old way
        %is_closest = true;
        %for k = 1:length(blocks)
        %  if all(ismember(indices{j}, blocks{k}))
        %      if ~all(ismember(indices{k}, indices{j}))
        %          is_closest = false;
        %      end
        %  end
        %end
        %if is_closest == false, continue; end
        
        %% New way
        %key = 0; for k = 1:length(indices{j}), key = C * key + indices{j}(k); end
        %neighbors_list = neighbors(key);
        %neighbors_list2 = get_neighbors(j, blocks{j}, indices{j}, neighbors_array);
        %for k = 1:length(neighbors_list)
        %    if ~all(ismember(indices{neighbors_list(k)}, indices{j})), continue; end
        %end
        
        %if verbose
        %   if length(indices{j}) == 2, myline(centers{indices{j}(1)}, centers{indices{j}(2)}, 'r');
        %   else scatter3(centers{indices{j}(1)}(1), centers{indices{j}(1)}(2), centers{indices{j}(1)}(3), 50, 'r', 'o', 'filled'); end
        %end
    end
    
    %% Find min distance
    if distance < min_distance
        model_index = indices{j};
        model_point = projections{j};
        axis_point = skeleton{j};
        min_distance = distance;
        block_index = j;
    end
end

if verbose
    scatter3(axis_point(1), axis_point(2), axis_point(3), 50, 'k', 'o', 'filled');
    scatter3(p(1), p(2), p(3), 50, 'm', 'o', 'filled');
    scatter3(model_point(1), model_point(2),model_point(3), 50, 'b', 'o', 'filled');
    myline(p, axis_point, 'k');
end

if (debug)
    disp('BEFORE');
    disp(block_index-1);
    disp(model_point');
    disp(axis_point');
    disp(model_index-1);
    disp(' ');
end

%% Deal with backfacing by closest triangles
if camera_ray' * (model_point - axis_point) / norm(model_point - axis_point) < 0
    return;
end
%disp('backfacing');
%min_distance = inf;
%model_point = [inf; inf; inf];
%for k = 1:length(blocks)
%   if length(blocks{k}) == 2, continue; end
%   if all(ismember(model_index, blocks{k}))
%      v1 = tangent_points{k}.v1; v2 = tangent_points{k}.v2; v3 = tangent_points{k}.v3;
%      q = project_point_on_triangle(p, v1, v2, v3);
%      distance = norm(p - q);
%      if distance < min_distance
%          min_distance = distance;
%          model_point = q;
%          model_index =  blocks{k};
%          block_index = k;
%      end
%   end
%end
if length(blocks{block_index}) == 3
    f1 = false; f2 = false;
    if  camera_ray' * tangent_points{block_index}.n < 0
        v1 = tangent_points{block_index}.v1;
        v2 = tangent_points{block_index}.v2;
        v3 = tangent_points{block_index}.v3;
        q1 = project_point_on_triangle(p, v1, v2, v3);
        f1 = true;
    end
    if  camera_ray' * tangent_points{block_index}.m < 0
        v1 = tangent_points{block_index}.u1;
        v2 = tangent_points{block_index}.u2;
        v3 = tangent_points{block_index}.u3;
        q2 = project_point_on_triangle(p, v1, v2, v3);
        f2 = true;
    end
    if f1 && f2
        if norm(p - q1) < norm(p - q2),
            model_point = q1;
        else
            model_point = q2;
        end
    end
    if f1 && ~f2
        model_point = q1;
    end
    if f2 && ~f1
        model_point = q2;
    end
    if ~f1 && ~f2
        model_point = [inf; inf; inf];
    end   
else
    model_point = [inf; inf; inf];
end


if (debug)
    disp('MIN');
    disp(block_index-1);
    disp(model_point');
    disp(axis_point');
    disp(model_index-1);
    disp(' ');
end
