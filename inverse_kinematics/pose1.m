function [T] = pose(T, i, settings)
%thetas(1:settings.num_translations)  = translation;
%thetas(settings.num_translations + 1: settings.num_parameters) = rotation;
if settings.D == 2, T.thetas(settings.D + 1) = 0; end

frame = makehgtform('translate', T.thetas(1:settings.num_translations)); % root translation

for i = settings.num_translations + 1:settings.num_parameters    
    frame = frame * makehgtform('axisrotate', T.axis(i,:), T.thetas(i - 1));
    frame = frame * makehgtform('translate',  T.local_translation(i,:));
    T.global_translation(i,:) = frame(1:settings.num_translations, end);
end
