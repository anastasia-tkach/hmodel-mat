function [f2, J2] = compute_energy2(poses, solid_blocks_indices, blocks, settings, display)
D = settings.D;
num_centers = length(poses{1}.centers);
f2 = zeros(0, 1);
J2 = zeros(0, settings.D * num_centers);

solid_blocks = cell(length(solid_blocks_indices), 1);
for i = 1:length(solid_blocks_indices)
    solid_blocks{i} = [];
    for j = 1:length(solid_blocks_indices{i})
        solid_blocks{i} = [solid_blocks{i}, blocks{solid_blocks_indices{i}(j)}];
    end
    solid_blocks{i} = unique(solid_blocks{i});
end

N = D * num_centers * length(poses) + num_centers;
f2 = zeros(2, 1);
J2 = zeros(2, N);
count = 1;
%{
for k = 2:length(poses)
    for b = 1:length(solid_blocks)
        indices = nchoosek(solid_blocks{b}, 2);
        index1 = indices(:, 1);
        index2 = indices(:, 2);
        for l = 1:length(index1)
            i = index1(l);
            j = index2(l);
            [fi, Ja, Jb, Jc, Jd] = jacobian_poses(poses{1}.centers{i}, poses{1}.centers{j}, poses{k}.centers{i}, poses{k}.centers{j});
            f2(count) = fi;
            J2(count, D * (i - 1) + 1 : D * i) = Ja;
            J2(count, D * (j - 1) + 1 : D * j) = Jb;
            shift = (k - 1) * D * num_centers;
            J2(count, shift + D * (i - 1) + 1 : shift + D * i) = Jc;
            J2(count, shift + D * (j - 1) + 1 : shift + D * j) = Jd;
            
            count = count + 1;
        end
    end
end
%}

for p = 1:length(poses)
    for q = p + 1:length(poses)
        for b = 1:length(solid_blocks)
            indices = nchoosek(solid_blocks{b}, 2);
            index1 = indices(:, 1);
            index2 = indices(:, 2);
            for l = 1:length(index1)
                i = index1(l);
                j = index2(l);
                [fi, Ja, Jb, Jc, Jd] = jacobian_poses(poses{p}.centers{i}, poses{p}.centers{j}, poses{q}.centers{i}, poses{q}.centers{j});
                f2(count) = fi;
                
                shift_p = (p - 1) * D * num_centers;
                J2(count, shift_p + D * (i - 1) + 1 : shift_p + D * i) = Ja;
                J2(count, shift_p + D * (j - 1) + 1 : shift_p + D * j) = Jb;
                
                shift_q = (q - 1) * D * num_centers;
                J2(count, shift_q + D * (i - 1) + 1 : shift_q + D * i) = Jc;
                J2(count, shift_q + D * (j - 1) + 1 : shift_q + D * j) = Jd;
                
                count = count + 1;
            end
        end
    end
end

%% Display shape consistency
if display
    for p = 1:length(poses)
        poses{p}.edges_length = [];
        count = 1;
        for b = 1:length(solid_blocks)
            indices = nchoosek(solid_blocks{b}, 2);
            index1 = indices(:, 1);
            index2 = indices(:, 2);
            for l = 1:length(index1)
                i = index1(l);
                j = index2(l);
                poses{p}.edges_length(count) = norm(poses{p}.centers{i} -  poses{p}.centers{j});
                count = count + 1;
            end
        end
    end
    figure; hold on;
    for p = 1:length(poses)
        stem(poses{p}.edges_length, 'filled', 'lineWidth', 2);
        poses{p} = rmfield(poses{p}, 'edges_length');
    end
    ylim([0, 3]); drawnow;
end

