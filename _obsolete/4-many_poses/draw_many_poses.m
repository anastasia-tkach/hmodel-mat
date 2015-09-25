clear all; close all;

pose_index = 5;


path = 'C:\Users\Anastasia\OneDrive\EPFL\Code\HandModel\data\finger_photo\';
picture = imread([path, '5.jpg']);

figure; hold on; axis equal;
imshow(picture);
P = [];
i = 0;
while(true)
    i = i + 1;
    [x, y, key] = ginput(1);
    P = [P; [x, y]];
    if (key == 3), break; end
    if (i > 1)
        line(P(i-1:i, 1), P(i-1:i, 2), 'lineWidth', 2, 'color', [0, 0.5, 0.9]);
    end
end
line([P(1, 1) P(end, 1)], [P(1, 2) P(end, 2)], 'lineWidth', 2, 'color', [0, 0.5, 0.9]);
save([path, 'P', num2str(pose_index), '.mat'], 'P');

load([path, 'P', num2str(pose_index)]);

%% Draw skeleton

num_centers = 4;
figure; axis equal; 
imshow(picture); hold on;
line(P(:, 1), P(:, 2), 'lineWidth', 2, 'color', [0, 0.5, 0.9]);
line([P(1, 1) P(end, 1)], [P(1, 2) P(end, 2)], 'lineWidth', 2, 'color', [0, 0.5, 0.9]);

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

save([path, 'R.mat'], 'R');
save([path, 'C', num2str(pose_index), '.mat'], 'C');