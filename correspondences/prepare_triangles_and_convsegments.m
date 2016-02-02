function [blocks, tangent_points, unique_indices] = prepare_triangles_and_convsegments(centers, blocks, radii, camera_ray)

%% List the primitives
tangent_points3D = blocks_tangent_points(centers, blocks, radii);
blocks3D = blocks;
blocks = {}; tangent_points = {};
count = 1;

for i = 1:length(blocks3D)
    if length(blocks3D{i}) == 2
        blocks{count} = blocks3D{i};
        count = count + 1;
    end
    
    %% Check if front-facing
    if length(blocks3D{i}) == 3
        indices = nchoosek(blocks3D{i}, 2);
        index1 = indices(:, 1); index2 = indices(:, 2);
        counts = [count, count + 1, count + 2];
        
        for j = 1:length(index1)
            blocks{count} = [index1(j), index2(j)];
            tangent_points{count}.triangles = [];
            switch j
                case 1, tangent_points{count}.segments = [count + 1, count + 2];
                case 2, tangent_points{count}.segments = [count - 1, count + 1];
                case 3, tangent_points{count}.segments = [count - 2, count - 1];
            end
            count = count + 1;
        end
        
        n = tangent_points3D{i}.v1 - centers{blocks3D{i}(1)};
        if n' * camera_ray < 0
            blocks{count} = blocks3D{i};
            tangent_points{count}.v1 = tangent_points3D{i}.v1;
            tangent_points{count}.v2 = tangent_points3D{i}.v2;
            tangent_points{count}.v3 = tangent_points3D{i}.v3;
            tangent_points{count}.n = n/norm(n);
            for k = counts, tangent_points{k}.triangles = [tangent_points{k}.triangles; count]; end
            count = count + 1;
        end
        
        n = tangent_points3D{i}.u1 - centers{blocks3D{i}(1)};
        if n' * camera_ray < 0
            blocks{count} = -blocks3D{i};
            tangent_points{count}.v1 = tangent_points3D{i}.u1;
            tangent_points{count}.v2 = tangent_points3D{i}.u2;
            tangent_points{count}.v3 = tangent_points3D{i}.u3;
            tangent_points{count}.n = n/norm(n);
            for k = counts, tangent_points{k}.triangles = [tangent_points{k}.triangles; count]; end
            count = count + 1;
        end
    end
end

unique_indicator = ones(length(blocks), 1);
for i = 1:length(blocks)
    for j = i + 1:length(blocks)
        if length(blocks{i})  ~= length(blocks{j}), continue; end
        if all(blocks{i} == blocks{j})
            unique_indicator(j) = 0;
        end
    end
end
unique_indices = find(unique_indicator);