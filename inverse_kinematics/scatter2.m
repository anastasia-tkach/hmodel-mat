function h = scatter2( P, settings, varargin )

if settings.D == 2
    h = scatter( P(:,1), P(:,2), varargin{:} );
end

if settings.D == 3
    h = scatter3( P(:,1), P(:,2), P(:,3), varargin{:} );
end
