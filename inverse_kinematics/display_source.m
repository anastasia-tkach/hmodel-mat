function [h_src, h_src_p, h_corresp] = display_source(h_src, h_src_p, h_corresp, S, T, settings)

%% Display correspondences
model_points = sample(S, settings);
closest_data_indices = T.kdtree.knnsearch(model_points); 
if ~isempty(h_corresp), delete(h_corresp); end;
h_corresp = edge2(model_points, T.points(closest_data_indices, :), settings, 'color', [0.8, 0.8, 0.8]);

%% Display model
if ~isempty(h_src), delete(h_src); end;
if ~isempty(h_src_p), delete(h_src_p); end;
h_src = draw(S, settings, 'color', S.color, 'linewidth', 5);

if settings.D == 2
    h_src_p = plot(S.global_translation(:,1), S.global_translation(:,2),'.','markersize',50,'color',S.color);
end
if settings.D == 3
    h_src_p = plot3(S.global_translation(:,1), S.global_translation(:,2), S.global_translation(:,3), '.','markersize',50,'color',S.color);
end

