function [] = draw_data_3D(P)

scatter3(P(:, 1), P(:, 2), P(:, 3), 30, [0, 0.7, 0.6], 'filled');
