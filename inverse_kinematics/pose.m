function [T] = pose(T, translation, rotation, settings)
thetas(1:settings.num_translations)  = translation;
thetas(settings.num_translations + 1: settings.num_translations + settings.num_rotations) = rotation;

if settings.D == 2, thetas(settings.D + 1) = 0; end
thetas(settings.num_parameters) = 0; 

T.thetas = thetas; 
frame = makehgtform('translate', T.thetas(1:settings.num_translations)); % root translation

for i = settings.num_translations + 1:settings.num_parameters
    T.global_translation(i,:) = frame(1:settings.num_translations, end);
    frame = frame * makehgtform('axisrotate', T.axis(i,:), T.thetas(i));
    frame = frame * makehgtform('translate',  T.local_translation(i,:));
end
end