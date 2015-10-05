function [pose] = display_result_convtriangles(pose, blocks, radii, display_data)

centers = pose.centers;

%% Generating the volumetric domain data:
n = 70; color = double([234; 189; 157]./255);

model_bounding_box = compute_model_bounding_box(centers, radii);
xm = linspace(model_bounding_box.min_x, model_bounding_box.max_x, n);
ym = linspace(model_bounding_box.min_y, model_bounding_box.max_y, n);
zm = linspace(model_bounding_box.min_z, model_bounding_box.max_z, n);
[x, y, z] = meshgrid(xm,ym,zm);
N = numel(x);
points = [reshape(x, N, 1), reshape(y, N, 1), reshape(z, N, 1)];
distances = zeros(N, 1);

figure; hold on;
%figure('units','normalized','outerposition',[0 0 1 1]); hold on;

tangent_points = blocks_tangent_points(pose.centers, blocks, radii);
RAND_MAX = 32767;
min_distances = RAND_MAX * ones(N, 1);

for i = 1:length(blocks)
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
    min_distances = min(min_distances, distances);
end

%% Making the 3D graph of the 0-level surface of the 4D function "fun":
min_distances = reshape(min_distances, size(x));
h = patch(isosurface(x, y, z, min_distances,0));
isonormals(x, y, z, min_distances, h);
set(h,'FaceColor',color,'EdgeColor','none', 'FaceAlpha', 1);
grid off; view([-1, -1, -1]); axis equal; camlight; lighting gouraud; axis off; material([0.4, 0.6, 0.1, 5, 1.0]);

%% Display data


if (display_data)
    mypoints(pose.points, 'm');
    pose.back_projections = cell(size(pose.projections));
    for i = 1:length(pose.projections)
         if ~isempty(pose.projections{i}), pose.back_projections{i} = pose.projections{i} - (pose.points{i} - pose.projections{i}); end
    end
    mypoints(pose.projections, [0.1, 0.8, 0.8]);
    mypoints(pose.back_projections, [0.6, 0.6, 0.6]);
    mylines(pose.points, pose.projections, [0.1, 0.8, 0.8]);  
    mylines(pose.back_projections, pose.projections, [0.6, 0.6, 0.6]);   
end

%% Set the axis limits
if (~isfield(pose, 'limits'))
    pose.limits.xlim = xlim; pose.limits.ylim = ylim; pose.limits.zlim = zlim;
else
    xlim(pose.limits.xlim); ylim(pose.limits.ylim); zlim(pose.limits.zlim);
end
set(gcf,'color','w');

%% Old Display Data
% if isfield(pose, 'indices');
%     k = 0;
%     P = zeros(length(pose.points), 3);
%     Q = zeros(length(pose.points), 3);
%     L = zeros(length(pose.points)*3, 3);
%     for i = 1:skip:length(pose.points)
%         if ~isempty(pose.indices{i})
%             k = k + 1;
%             P(k, :) =  pose.points{i}';
%             Q(k, :) = pose.projections{i}';
%             L(3 * (k - 1) + 1, :) = pose.points{i}';
%             L(3 * (k - 1) + 2, :) = pose.projections{i}';
%             L(3 * (k - 1) + 3, :) = [NaN, NaN, NaN];
%         end
%     end
%     if (k > 0)
%         P = P(1:k, :); Q = Q(1:k, :); L = L(1:3*k, :);
%         scatter3(Q(:, 1), Q(:, 2), Q(:, 3), 10, [0.1, 0.8, 0.8], 'filled', 'o');
%         scatter3(P(:, 1), P(:, 2), P(:, 3), 10, 'filled', 'o', 'm');
%         line(L(1:3*k, 1), L(1:3*k, 2), L(1:3*k, 3), 'lineWidth', 2, 'color', [0.1, 0.8, 0.8]);
%     end
% else
%     k = 0;
%     P = zeros(length(pose.points), 3);
%     for i = 1:skip:length(pose.points)
%         k = k + 1;
%         P(k, :) =  pose.points{i}';
%     end
%     P = P(1:k, :);
%     scatter3(P(:, 1), P(:, 2), P(:, 3), 10, 'filled', 'o', 'm');
% end
