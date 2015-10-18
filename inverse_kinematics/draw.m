function h = draw(T, settings, varargin)
h = [];

X = T.global_translation(settings.num_translations + 1:end, 1);
Y = T.global_translation(settings.num_translations + 1:end, 2);

if settings.D == 2
    h(end+1) = line(X, Y, varargin{:});
    h(end+1) = plot(X, Y, '.k','markersize',10);
end

if settings.D == 3
    Z = T.global_translation(settings.num_translations + 1:end, 3);
    h(end+1) = line(X, Y, Z, varargin{:});
    h(end+1) = plot3(X, Y, Z, '.k','markersize',10);
end

end