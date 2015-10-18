function [T] = initialize(settings)

%% Parameters
T.n_segs   = 3;    % number of segments
T.n_joints = 4;    % origin is not really a joint as it's always in ZERO

%% TX TY YZ R0 R1 R2 R3
T.thetas = zeros(settings.num_parameters,1);
T.local_translation = zeros(settings.num_parameters,3);
T.global_translation = zeros(settings.num_parameters,3);
T.axis = zeros(settings.num_parameters,3);

%% Set joints length
T.local_translation(settings.num_translations + 1:end, 1) = 1;

%% JOINT VECTORS
T.axis(1:settings.num_translations, :) = eye(3); % euclidean basis for translation
if settings.D == 2
    T.axis(settings.num_translations + 1:end, 3) = 1;
end
if settings.D == 3
    T.axis(settings.num_translations + 1, :) = [0, 0, 1];
    T.axis(settings.num_translations + 2, :) = [0, 0, 1];
    T.axis(settings.num_translations + 3, :) = [0, 0, 1];
end


%% INSTANTIATE
T = pose(T, [0,0,0], [0,0,0], settings);
end