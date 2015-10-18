function h = edge2(p1, p2, settings, varargin)
% the transpose are for when A,B are matrixes where every row is a point
A = [p1(:,1), p2(:,1)]';
B = [p1(:,2), p2(:,2)]';

if settings.D == 2
    h = line( A, B, varargin{:} );
end

if settings.D == 3
    C = [p1(:,3), p2(:,3)]';
    h = line( A, B, C, varargin{:} );
end
