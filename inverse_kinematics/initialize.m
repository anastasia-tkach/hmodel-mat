function [T] = initialize(T, settings)

T.thetas = zeros(settings.num_parameters,1);
T.local_translation = zeros(settings.num_parameters,3);
T.global_translation = zeros(settings.num_parameters,3);
T.axis = zeros(settings.num_parameters,3);

%% Joint vectors
T.axis(1:settings.num_translations, :) = eye(3, 3); % euclidean basis for translation
if settings.D == 2
    T.axis(settings.num_translations + 1:end, 3) = 1;
    T.local_translation(settings.num_translations + 2:end, 1) = 1;
end
if settings.D == 3
    T.axis(1:settings.num_translations, :) = eye(3, 3);
    for i = 1:length(T.segments)
        T.axis(T.segments{i}(1):T.segments{i}(3), :) = eye(3, 3);
        if i > 1, T.local_translation(T.segments{i}(1), 1) = 1; end
    end
end

%% INSTANTIATE
T.thetas = zeros(settings.num_parameters, 1);
T = pose(T, settings.num_translations + 1, settings);
end