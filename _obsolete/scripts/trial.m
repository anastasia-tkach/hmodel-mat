%function [] = display_convolutional_surface()

D = 3;
while(true)
    c1 = 0.5 * rand(D ,1);
    c2 = 0.5 * rand(D ,1);
    x1 = rand(1 ,1);
    x2 = rand(1 ,1);
    r1 = max(x1, x2);
    r2 = min(x1, x2);
    p = rand(2, 1);
    if norm(c1 - c2) > r1
        break;
    end
end
n = 100;
color = 'c';
domain = [-1 1 -1 1 -1 1];

%% Generating the volumetric domain data:
xm = linspace(domain(1),domain(2),n);
ym = linspace(domain(3),domain(4),n);
zm = linspace(domain(5),domain(6),n);
[x,y,z] = meshgrid(xm,ym,zm);

%% Evaluating "f_handle" in domain:

tic
N = numel(x);
points = [reshape(x, N, 1), reshape(y, N, 1), reshape(z, N, 1)];
fvalues = compute_distances_to_model(c1, c2, r1, r2, points');
fvalues = reshape(fvalues, size(x));
toc

% tic
% fvalues = tangent_distance(x,y,z, c1, c2, r1, r2);
% toc

%% Making the 3D graph of the 0-level surface of the 4D function "fun":
figure; hold on;
h = patch(isosurface(x, y, z, fvalues,0)); 
isonormals(x, y, z, fvalues, h);
set(h,'FaceColor',color,'EdgeColor','none');

%% Aditional graphic details:
alpha(0.7); grid on; view([1,1,1]); 
axis equal; camlight; lighting gouraud;



