function [] = display_energy3_3D(pose, blocks, radii, settings)

axis_to_view = containers.Map();
axis_to_view('X') = [-90, 0]; axis_to_view('Y') = [0, 0]; axis_to_view('Z') = [0, -90];

view_axes = {'X', 'Y', 'Z'};

display_result_convtriangles(pose, blocks, radii, false); camlight;
if settings.energy3x == true && settings.energy3y == false && settings.energy3z == false;
    view(axis_to_view('X'));
end
if settings.energy3x == false && settings.energy3y == true && settings.energy3z == false;
    view(axis_to_view('Y'));
end
if settings.energy3x == false && settings.energy3y == false && settings.energy3z == true;
    view(axis_to_view('Z'));
end

for v = 1:length(view_axes)
    
    view_axis = view_axes{v};
    
    switch view_axis
        case 'X'
            if (settings.energy3x == false), continue; end
            model_points = pose.model_points_X;
            closest_data_points = pose.closest_data_points_X;
        case 'Y'
            if (settings.energy3y == false), continue; end
            model_points = pose.model_points_Y;
            closest_data_points = pose.closest_data_points_Y;
        case 'Z'
            if (settings.energy3z == false), continue; end
            model_points = pose.model_points_Z;
            closest_data_points = pose.closest_data_points_Z;
    end
    %mypoints(pose.points, 'm');
    mypoints(model_points, 'b');
    mylines(closest_data_points, model_points, 'b');
    mypoints(closest_data_points, 'r');
end
