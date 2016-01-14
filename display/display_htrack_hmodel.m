function [] = display_htrack_hmodel(centers, radii, blocks, data_points, input_path, settings)

%% Start OpenGL .exe
if settings.opengl
    code_path = 'C:\Users\tkach\OneDrive\EPFL\Code\HModel\';
    fileexe_path = 'display\opengl-renderer-vs\Release\';
    cd(fileexe_path);
    system_command_string = [code_path, fileexe_path, 'opengl-renderer.exe', ' &'];
    system (system_command_string);
    cd(code_path);
end

if settings.verbose    
    load([input_path, 'theta.mat']);
    segments = create_ik_model('hand');
    [segments, ~] = pose_ik_model(segments, theta, false, 'hand');
    [htrack_centers, htrack_radii, htrack_blocks, ~, ~] = make_convolution_model(segments, 'hand');
    display_result(htrack_centers, [], [], htrack_blocks, htrack_radii, false, 0.8, 'big');
    mypoints(data_points, [0.65, 0.1, 0.5]);
    view([180, -90]); camlight; drawnow;
end

if settings.opengl
    display_opengl(centers, [], [], [], blocks, radii, false, 1);
else
    if settings.verbose 
        display_result(centers, data_points, [], blocks, radii, true, 0.9, 'big');
        mypoints(data_points, [0.65, 0.1, 0.5]);
        view([180, -90]); camlight; drawnow;
    end
end