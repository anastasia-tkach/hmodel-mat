clc; clear;
path = ['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\_data\convsegments\'];
load([path, 'radii']); load([path, 'blocks']); load([path, 'centers']);
pose.centers = centers;

neighbours = [2, 1];

tangent_points = cell(length(blocks), 1);
[bounding_box.min_x, bounding_box.min_y, bounding_box.min_z, bounding_box.max_x, bounding_box.max_y, bounding_box.max_z] = ...
    compute_bounding_box(centers(1:2), radii(1:2));

%% Find tangent points
for j = 1:length(blocks)
    if length(blocks{j}) > 2, continue; end;
    
    index3 = setdiff(blocks{neighbours(j)}, blocks{j});
    p = centers{index3};
    
    c1 = centers{blocks{j}(1)}; c2 = centers{blocks{j}(2)}; 
    r1 = radii{blocks{j}(1)}; r2 = radii{blocks{j}(2)};
    [v1, v2, u1, u2] = tangent_points_convsegment(c1, c2, r1, r2, p);
    tangent_points{j}.v1 = v1; tangent_points{j}.v2 = v2;
    tangent_points{j}.u1 = u1; tangent_points{j}.u2 = u2;
end

%% Find the dividing plane
i1 = rays_intersection_point(tangent_points{1}.v1, tangent_points{1}.v2, tangent_points{2}.v1, tangent_points{2}.v2);
i2 = rays_intersection_point(tangent_points{1}.u2, tangent_points{1}.u1, tangent_points{2}.u2, tangent_points{2}.u1);

indexi = intersect(blocks{1}, blocks{2});
index2 = setdiff(blocks{1}, blocks{2});
index3 = setdiff(blocks{2}, blocks{1});

ci = centers{indexi}; ri = radii{indexi};
c2 = centers{index2}; r2 = radii{index2};
c3 = centers{index3}; r3 = radii{index3};

m = cross(c2 - ci, c3 - ci); n = cross(m, i1 - i2);


%% Draw axis aligned cone
j = 1; num = 50;
c1 = centers{blocks{j}(1)}; c2 = centers{blocks{j}(2)};
r1 = radii{blocks{j}(1)}; r2 = radii{blocks{j}(2)};

z = c1 + (c2 - c1) * r1 / (r1 - r2);
beta = asin((r1 - r2) /norm(c1 - c2));
r = r1 * cos(beta);

translation_vector = z;
cone_direction = (c1 - c2) / norm(c1 - c2); 
eta1 = r1 * sin(beta); s1 = c1 - eta1 * cone_direction;
eta2 = r2 * sin(beta); s2 = c2 - eta2 * cone_direction;
h_top = norm(s2 - z); h_bottom = norm(s1 - z);

z_axis = [0; 0; 1];
rotation_axis = cross(cone_direction, z_axis);
rotation_angle = 180 * acos(z_axis' * cone_direction) / pi;
rotation_vector = [rotation_axis/norm(rotation_axis); rotation_angle]';
rotation_matrix = convert_rotations('EVtoDCM', rotation_vector, 10e-7, 0);

c = h_bottom/r; r_top = h_top/c;
[rho, theta] = meshgrid(linspace(r_top, r, num), linspace(0, 2*pi, num));
x = rho .* cos(theta); y = rho .* sin(theta); z = c * rho;

%% Display
figure('units','normalized','outerposition',[0 0 1 1]); hold on;
mesh(x, y, z, 'FaceColor', 'r', 'EdgeColor', 'none', 'FaceAlpha', 0.7);
hold on; axis equal; grid off; camlight; lighting gouraud;

%% Rotate the plane to match the axis aligned cone
point = revert_rotation_and_translation(i1, translation_vector, rotation_matrix, 'point');
normal = revert_rotation_and_translation(n / norm(n), translation_vector, rotation_matrix, 'vector');

min_corner = revert_rotation_and_translation([bounding_box.min_x; bounding_box.min_y; bounding_box.min_z], translation_vector, rotation_matrix, 'point');
max_corner = revert_rotation_and_translation([bounding_box.max_x; bounding_box.max_y; bounding_box.max_z], translation_vector, rotation_matrix, 'point');
bounding_box.min_x = min_corner(1); bounding_box.min_y = min_corner(2); bounding_box.min_z = min_corner(3);
bounding_box.max_x = - min_corner(1); bounding_box.max_y = -min_corner(2); bounding_box.max_z = max_corner(3);

%% Rotate the plane so that it does not have a 'y' component in its equation
axis_projection = z_axis * z_axis' * point;
xz_point = axis_projection + norm(point - axis_projection) * [1; 0; 0];
xz_rotation_angle = acos((point - axis_projection)'/norm(point - axis_projection) * [1; 0; 0]);

xz_rotation_matrix = axis_angle_rotation_matrix('z', xz_rotation_angle);
xz_normal = revert_rotation_and_translation(normal, [0; 0; 0], xz_rotation_matrix, 'vector');

draw_plane(xz_point, xz_normal, 'g', bounding_box);

%% Draw sphere
center = revert_rotation_and_translation(c1, translation_vector, rotation_matrix, 'point');
draw_sphere(center, r1, 'c');

%% Get cone plane intersection curve

y_handle = get_cone_plane_intersection_curve(h_bottom, r, xz_point, xz_normal);



