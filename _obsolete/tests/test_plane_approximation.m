clc; clear;
path = ['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\data\convsegments\'];
load([path, 'radii']);
load([path, 'blocks']);
load([path, 'centers']);
pose.centers = centers;

neighbours = [2, 1];

tangent_points = cell(length(blocks), 1);
[bounding_box.min_x, bounding_box.min_y, bounding_box.min_z, bounding_box.max_x, bounding_box.max_y, bounding_box.max_z] = ...
    compute_bounding_box(centers, radii);

%figure; hold on;
%% Find tangent points
for j = 1:length(blocks)
    if length(blocks{j}) > 2, continue; end;
    
    index3 = setdiff(blocks{neighbours(j)}, blocks{j});
    p = centers{index3};
    
    c1 = centers{blocks{j}(1)};
    c2 = centers{blocks{j}(2)};
    r1 = radii{blocks{j}(1)};
    r2 = radii{blocks{j}(2)};
    [v1, v2, u1, u2] = tangent_points_convsegment(c1, c2, r1, r2, p);
    tangent_points{j}.v1 = v1;
    tangent_points{j}.v2 = v2;
    tangent_points{j}.u1 = u1;
    tangent_points{j}.u2 = u2;
    
    %% Display
%     mypoint(c1, 'r'); mypoint(c2, 'r');
%     myline(c1, c2, 'b'); myline(c1, p, 'b');
%     myline(c1, v1, 'c'); myline(c2, v2, 'c');
%     myline(c1, u1, 'm'); myline(c2, u2, 'm');
%     myline(v1, v2, 'c');
%     myline(u1, u2, 'm');
%     draw_sphere(c1, r1, 'y', bounding_box);
%     draw_sphere(c2, r2, 'y', bounding_box);
    
end

i1 = rays_intersection_point(tangent_points{1}.v1, tangent_points{1}.v2, tangent_points{2}.v1, tangent_points{2}.v2);
i2 = rays_intersection_point(tangent_points{1}.u2, tangent_points{1}.u1, tangent_points{2}.u2, tangent_points{2}.u1);

%% Find intersection sphere
indexi = intersect(blocks{1}, blocks{2});
index2 = setdiff(blocks{1}, blocks{2});
index3 = setdiff(blocks{2}, blocks{1});

ci = centers{indexi}; ri = radii{indexi};
c2 = centers{index2}; r2 = radii{index2};
c3 = centers{index3}; r3 = radii{index3};

m = cross(c2 - ci, c3 - ci);
n = cross(m, i1 - i2);

figure('units','normalized','outerposition',[0 0 1 1]); hold on;
draw_plane(i1, n, 'b', bounding_box);
poses.centers = centers;
display_result_convtriangles(pose, blocks, radii, false);

% colors = {'r', 'y'};
% for j = 1:length(blocks)
%     c1 = centers{blocks{j}(1)};
%     c2 = centers{blocks{j}(2)};
%     r1 = radii{blocks{j}(1)};
%     r2 = radii{blocks{j}(2)};
%     draw_conic_surfaces_analytically(c1, c2, r1, r2, colors{j});    
% end
% draw_sphere(centers{1}, radii{1}, 'c');
xlim([0, 1]); ylim([0, 1]); zlim([0, 1]);





