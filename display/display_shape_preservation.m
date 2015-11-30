function [] = display_shape_preservation(centers, edge_indices, restpose_edges)

restpose_length = zeros(length(restpose_edges), 1);
current_length = zeros(length(restpose_edges), 1);
k = 1;
for i = 1:length(edge_indices)
    for j = 1:length(edge_indices{i})
        index1 = edge_indices{i}{j}(1); index2 = edge_indices{i}{j}(2);
        current_length(k) = norm(centers{index2} - centers{index1}) / norm(restpose_edges{k});
        restpose_length(k) = 1;
        k = k + 1;
    end
end
figure; hold on; axis off; set(gcf,'color','w');
stem(restpose_length, 'filled', 'color', [0, 0.7, 1], 'lineWidth', 2);
stem(current_length, 'filled', 'color', [0.65, 0.1, 0.5], 'lineWidth', 2);
ylim([0, 3]); drawnow;