function [] = display_result(centers, points, projections, blocks, radii, display_data, face_alpha, figure_mode)

%% Generating the volumetric domain data:
n = 50; color = double([240; 189; 157]./255);

model_bounding_box = compute_model_bounding_box(centers, radii);
xm = linspace(model_bounding_box.min_x, model_bounding_box.max_x, n);
ym = linspace(model_bounding_box.min_y, model_bounding_box.max_y, n);
zm = linspace(model_bounding_box.min_z, model_bounding_box.max_z, n);
[x, y, z] = meshgrid(xm,ym,zm);
N = numel(x);
P = [reshape(x, N, 1), reshape(y, N, 1), reshape(z, N, 1)];
distances = zeros(N, 1);

if strcmp(figure_mode, 'small')
    figure; hold on;
end
if strcmp(figure_mode, 'big')
    figure('units','normalized','outerposition',[0.0 0.085 1 0.873]); hold on;
end
set(gcf,'color','w');

tangent_points = blocks_tangent_points(centers, blocks, radii);
RAND_MAX = 32767;
min_distances = RAND_MAX * ones(N, 1);

for i = 1:length(blocks)
    if length(blocks{i}) == 3
        c1 = centers{blocks{i}(1)}; c2 = centers{blocks{i}(2)}; c3 = centers{blocks{i}(3)};
        r1 = radii{blocks{i}(1)}; r2 = radii{blocks{i}(2)}; r3 = radii{blocks{i}(3)};
        v1 = tangent_points{i}.v1; v2 = tangent_points{i}.v2; v3 = tangent_points{i}.v3;
        u1 = tangent_points{i}.u1; u2 = tangent_points{i}.u2; u3 = tangent_points{i}.u3;
        distances = distance_to_model_convtriangle(c1, c2, c3, r1, r2, r3, v1, v2, v3, u1, u2, u3, P');
    end
    
    if length(blocks{i}) == 2
        c1 = centers{blocks{i}(1)}; c2 = centers{blocks{i}(2)};
        r1 = radii{blocks{i}(1)}; r2 = radii{blocks{i}(2)};
        distances = distance_to_model_convsegment(c1, c2, r1, r2, P');
    end
    if length(blocks{i}) == 1
        c1 = centers{blocks{i}(1)};
        r1 = radii{blocks{i}(1)};
        distances = distance_to_model_sphere(c1, r1, P');
    end
    min_distances = min(min_distances, distances);
end

%% Making the 3D graph of the 0-level surface of the 4D function "fun":
min_distances = reshape(min_distances, size(x));
h = patch(isosurface(x, y, z, min_distances,0));
isonormals(x, y, z, min_distances, h);
set(h,'FaceColor',color,'EdgeColor','none', 'FaceAlpha', face_alpha);

grid off; axis equal; lighting gouraud; axis off; 
%material([0.92, 0.12, 0.05, 5, 0]); 
%material([0.69, 0.35, 0.1, 5, 1.0]); 
material([0.6, 0.4, 0.1, 5, 1.0]); 

view([-1, -1, -1]); 
if ~strcmp(figure_mode, 'none')
    camlight; 
end
view([+1, +1, +1]);
if ~strcmp(figure_mode, 'none')
    camlight; 
end

%% Display data
data_color = [0.65, 0.1, 0.5];
model_color = [0, 0.7, 1];
lines_color = [0.6, 0.6, 0.6];
if (display_data)
    mypoints(points, data_color);
    if ~isempty(projections)
        back_projections = cell(size(projections));
        for i = 1:length(projections)
            if ~isempty(projections{i}), back_projections{i} = projections{i} - (points{i} - projections{i}); end
        end
        mypoints(projections, model_color);
        mylines(points, projections, [0.1, 0.8, 0.8]);
        %mypoints(back_projections, lines_color);
        %mylines(back_projections, projections, lines_color);
    end
end

return
%% Specify surface types
for i = 1:length(blocks)
    if length(blocks{i}) == 3
        v1 = tangent_points{i}.v1; v2 = tangent_points{i}.v2; v3 = tangent_points{i}.v3;
        u1 = tangent_points{i}.u1; u2 = tangent_points{i}.u2; u3 = tangent_points{i}.u3;
        draw_triangle(v1, v2, v3, 'y');  
        draw_triangle(u1, u2, u3, 'y');  
    end 
end
for i = 1:length(blocks)
    for j = 1:length(blocks{i})
        c1 = centers{blocks{i}(j)};
        r1 = radii{blocks{i}(j)};
        draw_sphere(c1, r1, 'g');  
    end
end

