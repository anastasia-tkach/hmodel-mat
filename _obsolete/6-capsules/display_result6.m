function [] = display_result(pose, children, radii)

num_centers = pose.num_centers;
centers = pose.centers;

%% Generating the volumetric domain data:
n = 50;

model_bounding_box = compute_model_bounding_box(num_centers, centers, radii);
xm = linspace(model_bounding_box.min_x, model_bounding_box.max_x, n);
ym = linspace(model_bounding_box.min_y, model_bounding_box.max_y, n);
zm = linspace(model_bounding_box.min_z, model_bounding_box.max_z, n);
[x, y, z] = meshgrid(xm,ym,zm);

figure; hold on;

for j = 1:num_centers - 1
    c1 = centers{j};
    c2 = centers{children{j}(1)};
    r1 = radii{j};
    r2 = radii{children{j}(1)};    
    if r2 > r1
        temp = r1; r1 = r2; r2 = temp;        
        temp = c1; c1 = c2; c2 = temp;
    end
    N = numel(x);
    points = [reshape(x, N, 1), reshape(y, N, 1), reshape(z, N, 1)];
    distances = compute_distances_to_model(c1, c2, r1, r2, points');
    distances = reshape(distances, size(x));    
    
    %% Making the 3D graph of the 0-level surface of the 4D function "fun":
    color = 'c';
    h = patch(isosurface(x, y, z, distances,0));
    isonormals(x, y, z, distances, h);
    set(h,'FaceColor',color,'EdgeColor','none');
    
    %% Aditional graphic details:
    alpha(0.7); grid on; view([1,1,1]);
    axis equal; camlight; lighting gouraud;
    
end

%% Display data
P = zeros(length(pose.points), 3);
Q = zeros(length(pose.points), 3);
for i = 1:length(pose.points)
    P(i, :) = pose.points{i}';
    Q(i, :) = pose.projections{i}';
end
for i = 1:length(pose.points)
    line([P(i, 1), Q(i, 1)], [P(i, 2), Q(i, 2)], [P(i, 3), Q(i, 3)], 'lineWidth', 2, 'color', [0, 0.7, 0.7]);
end
scatter3(P(:, 1), P(:, 2), P(:, 3), 30, [0, 0.7, 0.6], 'filled', 'm');
%scatter3(Q(:, 1), Q(:, 2), Q(:, 3), 30, [0, 0.7, 0.6], 'filled', 'c');

drawnow

