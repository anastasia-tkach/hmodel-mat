function [pose] = display_result_2D(pose, blocks, radii, display_data)
D = 2;
centers = pose.centers;

%% Generating the volumetric domain data:
n = 150; color = [0.2, 0.8, 0.8];

model_bounding_box = compute_model_bounding_box(centers, radii);
xm = linspace(model_bounding_box.min_x, model_bounding_box.max_x, n);
ym = linspace(model_bounding_box.min_y, model_bounding_box.max_y, n);
[x, y] = meshgrid(xm,ym);
N = numel(x);
points = [reshape(x, N, 1), reshape(y, N, 1)];
figure; hold on;
%figure('units','normalized','outerposition',[0 0 1 1]); hold on;

composition = Inf * ones(N, 1);
for i = 1:length(blocks)
    c1 = pose.centers{blocks{i}(1)}; c2 = pose.centers{blocks{i}(2)};
    r1 = radii{blocks{i}(1)}; r2 = radii{blocks{i}(2)};
    distances = distance_to_model_convsegment(c1, c2, r1, r2, points');
    composition = min(distances, composition);
end

composition = reshape(composition, size(x));
colormap([0 0.6 0.7; 1, 1, 1]); caxis([-1 1]);
contourf(x, y, composition, 1000, 'edgeColor', 'none');
grid off; axis equal; axis off;

%% Display data
if (display_data)
    skip = 1;
    if isfield(pose, 'indices');
        k = 0;
        P = zeros(length(pose.points), D);
        Q = zeros(length(pose.points), D);
        L = zeros(length(pose.points)*3, D);
        for i = 1:skip:length(pose.points)
            if ~isempty(pose.indices{i})
                k = k + 1;
                P(k, :) =  pose.points{i}';
                Q(k, :) = pose.projections{i}';
                L(3 * (k - 1) + 1, :) = pose.points{i}';
                L(3 * (k - 1) + 2, :) = pose.projections{i}';
                L(3 * (k - 1) + 3, :) = [NaN, NaN];
            end
        end
        if (k > 0)
            P = P(1:k, :); Q = Q(1:k, :); L = L(1:3*k, :);
            %scatter(Q(:, 1), Q(:, 2), 10, [0.1, 0.8, 0.8], 'filled', 'o');
            scatter(P(:, 1), P(:, 2), 10, 'filled', 'o', 'm');
            line(L(:, 1), L(:, 2), 'lineWidth', 2, 'color', [0.1, 0.8, 0.8]);
        end
    else
        k = 0;
        P = zeros(length(pose.points), D);
        for i = 1:skip:length(pose.points)
            k = k + 1;
            P(k, :) =  pose.points{i}';
        end
        P = P(1:k, :);
        scatter(P(:, 1), P(:, 2), 10, 'filled', 'o', 'm');
    end
end

%% Set the axis limits
if (~isfield(pose, 'limits'))
    pose.limits.xlim = xlim; pose.limits.ylim = ylim; 
else
    xlim(pose.limits.xlim); ylim(pose.limits.ylim); 
end

