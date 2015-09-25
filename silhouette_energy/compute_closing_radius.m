function [poses] = compute_closing_radius(poses, radii, settings)
D = settings.D;
if D == 2
    return
end

view_axes = {'X', 'Y', 'Z'};
for p = 1:length(poses)
    poses{p}.num_pixels = 0;
    for v = 1:length(view_axes)
        view_axis = view_axes{v};
        [~, camera_axis, camera_center] = get_raytracing_matrix(poses{p}.centers, radii, poses{p}.data_bounding_box, view_axis, settings);
        closing_radius = 0;
        poses{p} = render_data(poses{p}, camera_axis, camera_center, view_axis, closing_radius, settings);
        rendered_data = poses{p}.rendered_data;
        closing_radius = 2;
        while closing_radius < 60
            silhouette = imclose(rendered_data, strel('disk', closing_radius, 0));
            connected_components = bwconncomp(silhouette);
            if (connected_components.NumObjects == 1), break; end
            closing_radius =  closing_radius * 2;
        end
        while closing_radius >= 1
            silhouette = imclose(rendered_data, strel('disk', closing_radius, 0));
            % figure; imshow(silhouette); drawnow;
            connected_components = bwconncomp(silhouette);
            if (connected_components.NumObjects > 1), break; end
            closing_radius =  closing_radius - 2;
        end
        closing_radius = closing_radius + 2;
        silhouette = imclose(rendered_data, strel('disk', closing_radius, 0));
        poses{p}.closing_radius{v} = closing_radius;
        poses{p}.num_pixels = poses{p}.num_pixels + sum(silhouette(:));
        %% Display results
%         silhouette = imfill(silhouette);
%         silhouette_and_data = zeros(settings.H, settings.W, 3);
%         silhouette_and_data(:, :, 3) = silhouette;
%         silhouette_and_data(:, :, 1) = rendered_data;
%         figure; imshow(silhouette_and_data); drawnow;
    end
end



