function [] = display_two_centers(P, C, R)

figure; hold on; axis equal;
xlim([0 1]);
ylim([0 1]);
line(P(:, 1), P(:, 2), 'lineWidth', 2, 'color', [0, 0.5, 0.9]);
line([P(1, 1) P(end, 1)], [P(1, 2) P(end, 2)], 'lineWidth', 2, 'color', [0, 0.5, 0.9]);
for i = 1:2
    scatter(C(i, 1), C(i, 2), 30, 'r', 'filled');
    draw_circle(C(i, :), R(i), [0, 0.8, 0.7]);
end
line(C(:, 1), C(:, 2), 'lineWidth', 2, 'color', [0, 0.8, 0.7]);
draw_tangents(R, C);