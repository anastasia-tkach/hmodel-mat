clear all; close all;
figure; hold on; axis equal;
%% Draw shape

xlim([0 1]);
ylim([0 1]);
P = [];
i = 0;
while(true)
    i = i + 1;
    [x, y, key] = ginput(1);
    P = [P; [x, y]];
    if (key == 3), break; end
    if (i > 1)
        line(P(i-1:i, 1), P(i-1:i, 2), 'lineWidth', 2);
    end
end
line([P(1, 1) P(end, 1)], [P(1, 2) P(end, 2)], 'lineWidth', 2);

%% Draw skeleton

num_centers = 4;
% figure; axis equal; hold on;
% line(P(:, 1), P(:, 2), 'lineWidth', 2, 'color', [0, 0.5, 0.9]);
% line([P(1, 1) P(end, 1)], [P(1, 2) P(end, 2)], 'lineWidth', 2, 'color', [0, 0.5, 0.9]);

C = [];
R = [];

for i = 1:num_centers;
    [cx, cy] = ginput(1);
    C = [C; [cx cy]];
    scatter(cx, cy, 20, [0, 0.9, 0.6], 'filled');
    [tx, ty] = ginput(1);
    R = [R; norm(C(i, :)' - [tx; ty])];
    draw_circle(C(i, :), R(i),  [0, 0.9, 0.6]);
    
end

for i = 1:num_centers - 1;
    line(C(i:i + 1, 1), C(i:i + 1, 2), 'lineWidth', 2, 'color', [0, 0.8, 0.7]);
    draw_tangents(R(i:i + 1), C(i:i + 1, :), [0, 0.8, 0.7]);
end

num_points = size(P, 1);
radii = cell(num_centers, 1);
points = cell(size(P, 1), 1);
centers = cell(num_centers, 1);
for i = 1:num_centers
    radii{i} = R(i);
end
for i = 1:num_centers
    centers{i} = C(i, :)';
end
for i = 1:num_points
   points{i} = P(i, :)';
end
% save('C:\Users\Anastasia\OneDrive\EPFL\Code\HandModel\data\generated_2D\points', 'points');
% save('C:\Users\Anastasia\OneDrive\EPFL\Code\HandModel\data\generated_2D\centers', 'centers');
% save('C:\Users\Anastasia\OneDrive\EPFL\Code\HandModel\data\generated_2D\radii', 'radii');
save('C:\Users\tkach\OneDrive\EPFL\Code\HandModel\data\generated_2D\points', 'points');
save('C:\Users\tkach\OneDrive\EPFL\Code\HandModel\data\generated_2D\centers', 'centers');
save('C:\Users\tkach\OneDrive\EPFL\Code\HandModel\data\generated_2D\radii', 'radii');