clc; clear;
path = ['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\HandModel\data\convtriangles\'];
load([path, 'radii']);
load([path, 'blocks']);
load([path, 'centers']);
pose.centers = centers;

% display_result_convtriangles(pose, blocks, radii, false);

tangent_points = blocks_tangent_points(pose.centers, blocks, radii);

P = cell(length(blocks), 1);

figure('units','normalized','outerposition',[0 0 1 1]); hold on; axis equal; axis off; grid off;

for j = 1:length(blocks)
    if length(blocks{j}) == 3
        V = [tangent_points{j}.v1, tangent_points{j}.v2, tangent_points{j}.v3];
        U = [tangent_points{j}.u1, tangent_points{j}.u2, tangent_points{j}.u3];
        C = [centers{blocks{j}(1)}, centers{blocks{j}(2)}, centers{blocks{j}(3)}];
        CV12 = [centers{blocks{j}(1)}, centers{blocks{j}(2)}, tangent_points{j}.v2, tangent_points{j}.v1];
        CV13 = [centers{blocks{j}(1)}, centers{blocks{j}(3)}, tangent_points{j}.v3, tangent_points{j}.v1];
        CV23 = [centers{blocks{j}(2)}, centers{blocks{j}(3)}, tangent_points{j}.v3, tangent_points{j}.v2];
        
        CU12 = [centers{blocks{j}(1)}, centers{blocks{j}(2)}, tangent_points{j}.u2, tangent_points{j}.u1];
        CU13 = [centers{blocks{j}(1)}, centers{blocks{j}(3)}, tangent_points{j}.u3, tangent_points{j}.u1];
        CU23 = [centers{blocks{j}(2)}, centers{blocks{j}(3)}, tangent_points{j}.u3, tangent_points{j}.u2];
        
        if (j == 1)
            %hold on; fill3(V(1, :), V(2, :), V(3, :),  'c', 'EdgeColor', 'b', 'LineWidth', 2);
            %hold on; fill3(CV12(1, :), CV12(2, :), CV12(3, :),  'c', 'EdgeColor', 'b', 'LineWidth', 2);
            %hold on; fill3(CV13(1, :), CV13(2, :), CV13(3, :),  'c', 'EdgeColor', 'b', 'LineWidth', 2);
            %hold on; fill3(CV23(1, :), CV23(2, :), CV23(3, :),  'c', 'EdgeColor', 'b', 'LineWidth', 2);
            %hold on; fill3(C(1, :), C(2, :), C(3, :),  'c', 'EdgeColor', 'b', 'LineWidth', 2);
            P{j} = convh([V'; C'; U']);
        end
        if (j == 2)
            %hold on; fill3(U(1, :), U(2, :), U(3, :),  'c', 'EdgeColor', 'b', 'LineWidth', 2);
            %hold on; fill3(CU12(1, :), CU12(2, :), CU12(3, :),  'c', 'EdgeColor', 'b', 'LineWidth', 2);
            %hold on; fill3(CU13(1, :), CU13(2, :), CU13(3, :),  'c', 'EdgeColor', 'b', 'LineWidth', 2);
            %hold on; fill3(CU23(1, :), CU23(2, :), CU23(3, :),  'c', 'EdgeColor', 'b', 'LineWidth', 2);
            %hold on; fill3(C(1, :), C(2, :), C(3, :),  'c', 'EdgeColor', 'b', 'LineWidth', 2);
            P{j} = convh([U'; C'; V']);
        end
        
        
        alpha(1);
    end
end

P = intersct(P{1}, P{2});
% hold on; scatter3(P(10:end, 1), P(10:end, 2), P(10:end, 3), 30, 'r', 'filled');
% T = P(10:end, 1:3);
% line(T(1:3, 1), T(1:3, 2), T(1:3, 3), 'color', 'm', 'LineWidth', 3);

hold on; view3d(P); axis equal;
%display_result_convtriangles(pose, blocks, radii, false);
display_convsegments_in_convtriangles(pose, blocks, radii);

