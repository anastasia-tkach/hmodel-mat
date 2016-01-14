function [] = display_opengl(centers, points, model_points, outside_points, blocks, radii, display_points, face_alpha)

[blocks] = reindex(radii, blocks);

path = 'C:\Users\tkach\OneDrive\EPFL\Code\HModel\display\opengl-renderer-vs\Input\';

scaling_factor = 27;
for i = 1:length(centers)
    centers{i} = centers{i} / scaling_factor;
    radii{i} = radii{i} / scaling_factor;
end

sum_centers = zeros(3, 1);
for i = 1:length(centers)
    sum_centers = sum_centers + centers{i};
end
mean_centers = sum_centers ./ length(centers);
for i = 1:length(centers)
    centers{i} = centers{i} - mean_centers;
end
for i = 1:length(points)   
    points{i} = points{i} / scaling_factor - mean_centers;
end
for i = 1:length(model_points)   
    if ~isempty(model_points{i})
        model_points{i} = model_points{i} / scaling_factor - mean_centers;
    end
end
for i = 1:length(outside_points)   
    if ~isempty(outside_points{i})
        outside_points{i} = outside_points{i} / scaling_factor - mean_centers;
    end
end

%% Put data in matrix form
D = 3;
RAND_MAX = 32767;
R = zeros(length(radii), 1);
C = zeros(length(centers), D);
B = RAND_MAX * ones(length(blocks), 3);
T = RAND_MAX * ones(length(blocks), 6 * D);
P = zeros(length(points), D);
M = zeros(length(model_points), D);
O = zeros(length(outside_points), D);
tangent_points = blocks_tangent_points(centers, blocks, radii);
for j = 1:length(points)  
    P(j, :) = points{j}';  
end
for j = 1:length(model_points)  
    if ~isempty(model_points{j})
        M(j, :) = model_points{j}';
    else 
        M(j, :) = points{j}';
    end   
end
for j = 1:length(outside_points)      
    O(j, :) = outside_points{j}';    
end
for j = 1:length(radii)
    R(j) = radii{j};
    C(j, :) = centers{j}';
end
for j = 1:length(blocks)
    for k = 1:length(blocks{j})
        B(j, k) = blocks{j}(k) - 1;
    end
    if ~isempty(tangent_points{j})
        T(j, 1:3) = tangent_points{j}.v1';
        T(j, 4:6) = tangent_points{j}.v2';
        T(j, 7:9) = tangent_points{j}.v3';
        T(j, 10:12) = tangent_points{j}.u1';
        T(j, 13:15) = tangent_points{j}.u2';
        T(j, 16:18) = tangent_points{j}.u3';
    end
end

%% Get timestamp
time = clock();
seconds = time(end);
fid = fopen([path, 'timestamp', '.txt'],'wt');
fprintf(fid,'%f\n', seconds);
fclose(fid);

%% Write input data
write_input_parameters_to_files(path, C, R, B, T, P, M, O);

