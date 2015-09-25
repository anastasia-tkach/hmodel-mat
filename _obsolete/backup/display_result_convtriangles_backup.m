function [] = display_result_convtriangles(pose, blocks, radii, display_data)

centers = pose.centers;

%% Generating the volumetric domain data:
n = 60;

[min_x, min_y, min_z, max_x, max_y, max_z] = compute_bounding_box(centers, radii);
xm = linspace(min_x, max_x, n);
ym = linspace(min_y, max_y, n);
zm = linspace(min_z, max_z, n);
[x, y, z] = meshgrid(xm,ym,zm);
N = numel(x);
points = [reshape(x, N, 1), reshape(y, N, 1), reshape(z, N, 1)];
distances = zeros(N, 1);
figure('units','normalized','outerposition',[0 0 1 1]); hold on;

tangent_points = blocks_tangent_points(pose.centers, blocks, radii);

%neighbours = 1:25;%[8, 9, 14:24];

for i = 1:length(blocks)
    %if ~ismember(i, neighbours), continue; end
    if length(blocks{i}) == 3
        c1 = pose.centers{blocks{i}(1)}; c2 = pose.centers{blocks{i}(2)}; c3 = pose.centers{blocks{i}(3)};
        r1 = radii{blocks{i}(1)}; r2 = radii{blocks{i}(2)}; r3 = radii{blocks{i}(3)};
        v1 = tangent_points{i}.v1; v2 = tangent_points{i}.v2; v3 = tangent_points{i}.v3;
        u1 = tangent_points{i}.u1; u2 = tangent_points{i}.u2; u3 = tangent_points{i}.u3;
        distances = distance_to_model_convtriangle(c1, c2, c3, r1, r2, r3, v1, v2, v3, u1, u2, u3, points');
    end
    
    if length(blocks{i}) == 2
        c1 = pose.centers{blocks{i}(1)}; c2 = pose.centers{blocks{i}(2)};
        r1 = radii{blocks{i}(1)}; r2 = radii{blocks{i}(2)};
        distances = distance_to_model_convsegment(c1, c2, r1, r2, points');
    end
    
    distances = reshape(distances, size(x));
    
    %% Making the 3D graph of the 0-level surface of the 4D function "fun":
    color = [0.2, 0.8, 0.8];
    
    %if i == 1, color = 'r'; end;
    %if i == 2, color = 'y'; end;
    %if i == 3, color = 'b'; end;        
    
    h = patch(isosurface(x, y, z, distances,0));
    isonormals(x, y, z, distances, h);
    set(h,'FaceColor',color,'EdgeColor','none', 'FaceAlpha', 0.3);
    
    %% Aditional graphic details:
    
    grid off; view([1,1,1]);
    axis equal;
    camlight;
    lighting gouraud;
end

%% Display data
if isfield(pose, 'indices');
    
    skip = 10;
    if (display_data > 0)
        P = [];
        Q = [];
        for i = 1:skip:length(pose.points)
            
            %is_neighbour = false;
            %for n = 1:length(neighbours)
                
            %    if all(ismember(pose.block_indices{i}, neighbours(n)))
                    %is_neighbour = true;
            %    end
            %end
            %if is_neighbour == false, continue; end
            
            if ~isempty(pose.indices{i})
                P = [P; pose.points{i}'];
                Q = [Q; pose.projections{i}'];
            end
        end
        
        if ~isempty(P), scatter3(P(:, 1), P(:, 2), P(:, 3), 20, [0, 0.7, 0.6], 'filled', 'm'); end;
        if (display_data == 1)
            for i = 1:size(P, 1)
                line([P(i, 1), Q(i, 1)], [P(i, 2), Q(i, 2)], [P(i, 3), Q(i, 3)], 'lineWidth', 2, 'color', [0, 0.4, 0.4]);
            end        
            if ~isempty(Q), scatter3(Q(:, 1), Q(:, 2), Q(:, 3), 20, [0, 0.4, 0.4], 'filled'); end;
        end
    end 
end

drawnow