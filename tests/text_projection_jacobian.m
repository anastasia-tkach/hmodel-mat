%clear;
clc; close all;
absolute_path = ['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\'];
data_path = [absolute_path, '_data\convtriangles\'];
load([data_path, 'radii']);
load([data_path, 'blocks']);

D = 3;
num_poses = 1;
num_centers = length(radii);
num_parameters = D * num_centers * num_poses + num_centers;

p = 1;
load([data_path, 'points']);
load([data_path, 'centers']);
poses{p}.num_points = length(points);
poses{p}.points = points;
poses{p}.centers = centers;
poses{p}.num_centers = num_centers;

total_num_points = 0; cumsum_num_points = zeros(num_poses + 1, 1);
total_num_points = total_num_points + poses{p}.num_points;
cumsum_num_points(p + 1) = cumsum_num_points(p) + poses{p}.num_points;

%% Render model
% display_result_convtriangles(poses{p}, blocks, radii, true);

H = 480; W = 640;
RAND_MAX = 32767;
view_axis = 'Z';
[rendered_model, camera_axis, camera_center, fov] = render_model(centers, blocks, radii, W, H, view_axis);
rendered_model(rendered_model == -RAND_MAX) = -10;
figure; imshow(rendered_model, []);

%% Render data points

focal = H/tand(fov/2);

a = camera_axis;
t = camera_center;
A = [focal, 0,      W/2;
    0,     focal,   H/2;
    0,     0,       1];

hold on;

index = randi([1, length(points)], 1, 1);

for i = 1:length(points)
    M = [points{i}; 1];
    if strcmp(view_axis, 'Z')
        b = [0; 0; -1];
        R = vrrotvec2mat(vrrotvec(a, b));
        P = A * [R -R*t];
        m = P * M;
        m = m ./ m(3);
        m = [W - m(1); m(2)];
    end
    if strcmp(view_axis, 'Y')
        b = [0; -1; 0];
        R = vrrotvec2mat(vrrotvec(a, b));
        R = [R(1, :); R(3, :); R(2, :)];
        P = A * [R -R*t];
        m = P * M;
        m = m ./ m(3);
        m = [m(1); m(2)];
    end
    if strcmp(view_axis, 'X')
        b = [-1; 0; 0];
        R = vrrotvec2mat(vrrotvec(a, b));
        R = [R(2, :); R(3, :); R(1, :)];
        P = A * [R -R*t];
        m = P * M;
        m = m ./ m(3);
        m = [W - m(1); m(2)];
    end
    mypoint(m, 'm');
    if (i == index), disp(m); end;
end

%% Compute Jacobian

if (strcmp(view_axis, 'X'))
    b = [-1; 0; 0];
    R = vrrotvec2mat(vrrotvec(a, b));
    R = [R(2, :); R(3, :); R(1, :)];
end
if (strcmp(view_axis, 'Y'))
    b = [0; -1; 0];
    R = vrrotvec2mat(vrrotvec(a, b));
    R = [R(1, :); R(3, :); R(2, :)];
end
if (strcmp(view_axis, 'Z'))
    b = [0; 0; -1];
    R = vrrotvec2mat(vrrotvec(camera_axis, b));
end

M = [points{index}; 1];

qx = M(1); qy = M(2); qz = M(3);

P = A * [R -R*t];
m = P * M;
m = m ./ m(3);
if (strcmp(view_axis, 'Y'))
    m = [m(1); m(2)];
else
    m = [W - m(1); m(2)];
end
disp(m);

%% mx

mxnum = @(qx, qy, qz) P(1, 1) * qx + P(1, 2) * qy + P(1, 3) * qz + P(1, 4);
mxdenum = @(qx, qy, qz) P(3, 1) * qx + P(3, 2) * qy + P(3, 3) * qz + P(3, 4);
mx = @(qx, qy, qz) W - mxnum(qx, qy, qz) / mxdenum(qx, qy, qz);

dmxnum_dqx = @(qx) P(1, 1);
dmxdenum_dqx = @(qx) P(3, 1);
dmx_dqx = @(qx) - (dmxnum_dqx(qx) * mxdenum(qx, qy, qz) - mxnum(qx, qy, qz) * dmxdenum_dqx(qx)) / mxdenum(qx, qy, qz)^2;

dmxnum_dqy = @(qy) P(1, 2);
dmxdenum_dqy = @(qy) P(3, 2);
dmx_dqy = @(qy) - (dmxnum_dqy(qy) * mxdenum(qx, qy, qz) - mxnum(qx, qy, qz) * dmxdenum_dqy(qy)) / mxdenum(qx, qy, qz)^2;

dmxnum_dqz = @(qz) P(1, 3);
dmxdenum_dqz = @(qz) P(3, 3);
dmx_dqz = @(qz) - (dmxnum_dqz(qz) * mxdenum(qx, qy, qz) - mxnum(qx, qy, qz) * dmxdenum_dqz(qz)) / mxdenum(qx, qy, qz)^2;

if (strcmp(view_axis, 'Y'))
    mx = @(qx, qy, qz) mxnum(qx, qy, qz) / mxdenum(qx, qy, qz);
    dmx_dqx = @(qx) (dmxnum_dqx(qx) * mxdenum(qx, qy, qz) - mxnum(qx, qy, qz) * dmxdenum_dqx(qx)) / mxdenum(qx, qy, qz)^2;
    dmx_dqy = @(qy) (dmxnum_dqy(qy) * mxdenum(qx, qy, qz) - mxnum(qx, qy, qz) * dmxdenum_dqy(qy)) / mxdenum(qx, qy, qz)^2;
    dmx_dqz = @(qz) (dmxnum_dqz(qz) * mxdenum(qx, qy, qz) - mxnum(qx, qy, qz) * dmxdenum_dqz(qz)) / mxdenum(qx, qy, qz)^2;
end

%% my

mynum = @(qx, qy, qz) P(2, 1) * qx + P(2, 2) * qy + P(2, 3) * qz + P(2, 4);
mydenum = @(qx, qy, qz) P(3, 1) * qx + P(3, 2) * qy + P(3, 3) * qz + P(3, 4);
my = @(qx, qy, qz) mynum(qx, qy, qz) / mydenum(qx, qy, qz);

dmynum_dqx = @(qx) P(2, 1);
dmydenum_dqx = @(qx) P(3, 1);
dmy_dqx = @(qx) (dmynum_dqx(qx) * mydenum(qx, qy, qz) - mynum(qx, qy, qz) * dmydenum_dqx(qx)) / mydenum(qx, qy, qz)^2;

dmynum_dqy = @(qy) P(2, 2);
dmydenum_dqy = @(qy) P(3, 2);
dmy_dqy = @(qy) (dmynum_dqy(qy) * mydenum(qx, qy, qz) - mynum(qx, qy, qz) * dmydenum_dqy(qy)) / mydenum(qx, qy, qz)^2;

dmynum_dqz = @(qz) P(2, 3);
dmydenum_dqz = @(qz) P(3, 3);
dmy_dqz = @(qz) (dmynum_dqz(qz) * mydenum(qx, qy, qz) - mynum(qx, qy, qz) * dmydenum_dqz(qz)) / mydenum(qx, qy, qz)^2;

%% Assemble

Jproj = @(qx, qy, qz) [dmx_dqx(qx) dmx_dqy(qy) dmx_dqz(qz);
    dmy_dqx(qx) dmy_dqy(qy) dmy_dqz(qz)];
%% Verify

m = @(qx, qy, qz) [mx(qx, qy, qz); my(qx, qy, qz)];

disp(m(qx, qy, qz));

m_qx = @(qx) m(qx, qy, qz);
m_qy = @(qy) m(qx, qy, qz);
m_qz = @(qz) m(qx, qy, qz);
disp([my_gradient(m_qx, qx), my_gradient(m_qy, qy), my_gradient(m_qz, qz)]);
disp(Jproj(qx, qy, qz));




