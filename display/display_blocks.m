function [] = display_blocks(centers, points, projections, blocks, radii, display_data)

%% Generating the volumetric domain data:
n = 70; color = double([234; 189; 157]./255);

model_bounding_box = compute_model_bounding_box(centers, radii);
xm = linspace(model_bounding_box.min_x, model_bounding_box.max_x, n);
ym = linspace(model_bounding_box.min_y, model_bounding_box.max_y, n);
zm = linspace(model_bounding_box.min_z, model_bounding_box.max_z, n);
[x, y, z] = meshgrid(xm,ym,zm);
N = numel(x);
P = [reshape(x, N, 1), reshape(y, N, 1), reshape(z, N, 1)];
distances = zeros(N, 1);

figure; hold on;
%figure('units','normalized','outerposition',[0 0 1 1]); hold on;

tangent_points = blocks_tangent_points(centers, blocks, radii);

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
    
    %% Making the 3D graph of the 0-level surface of the 4D function "fun":
    distances = reshape(distances, size(x));
    h = patch(isosurface(x, y, z, distances,0));
    isonormals(x, y, z, distances, h);
    set(h,'FaceColor',color,'EdgeColor','none', 'FaceAlpha', 0.3);
    grid off; view([-1, -1, -1]); axis equal; lighting gouraud; axis off; material([0.4, 0.6, 0.1, 5, 1.0]); camlight;
end

%% Display data
if (display_data)
    mypoints(points, 'm');
    if ~isempty(projections)
        back_projections = cell(size(projections));
        for i = 1:length(projections)
            if ~isempty(projections{i}), back_projections{i} = projections{i} - (points{i} - projections{i}); end
        end
        mypoints(projections, [0.1, 0.8, 0.8]);
        mylines(points, projections, [0.1, 0.8, 0.8]);
    end
end
