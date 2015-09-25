global a; global b; global c; global u; global v; global w;
a = randn(1);
b = randn(1);
c = randn(1);
u = randn(1);
v = randn(1);
w = randn(1);

f = @(x,y,z) a*x^2 + b*y^2 + c*z^2 + 2*u*x*y + 2*v*y*z + 2*w*x*z;
ezimplot3(f,[-5 5])

%% Cylindrical coordinates
% th = (0:5:360)*pi/180;%
% r = 0:.05:1;
% [TH,R] = meshgrid(th,r);
% [X,Y] = pol2cart(TH,R);
% Z = X + 1i*Y;
% f = (Z.^4-1).^(1/4);
%
% figure
% surf(X,Y,abs(f))
% colormap summer

%% 3D Polar plot
% [t,r] = meshgrid(linspace(0,2*pi,361),linspace(-4,4,101));
% [x,y] = pol2cart(t,r);
% P = peaks(x,y);         
% figure('color','white');            
% polarplot3d(P,'PlotType','surfn','PolarGrid',{4 24},'TickSpacing',8, 'AngularRange',[30 270]*pi/180,'RadialRange',[.8 4]);

